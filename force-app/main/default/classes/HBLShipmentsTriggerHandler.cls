public with sharing class HBLShipmentsTriggerHandler extends AbstractTriggerHandler {
    private static boolean isRunning = false;
    private static Map<Id, String> mapRecordTypeIdToName = new Map<Id, String>();
    private static Map<String, String> mapRecordTypeNameToId = new Map<String, String>();
    private static Set<Id> newCustomersForAlertIds = new Set<Id>();
    private Map<Id, List<AnkenMeisai__c>> mapAnkensPerShipment = new Map<Id, List<AnkenMeisai__c>>();
    private Map<String, Common_Settings__c> mapHBLRunningNumbers = new Map<String, Common_Settings__c>();
    private Map<Id, LoadLocation__c> mapWarehouses = new Map<Id, LoadLocation__c>();
    private List<MgmtMaster__c> exchangeRates = new List<MgmtMaster__c>();
    private Map<Id, CustomObject1__c> mapShipmentsWithChildren = new Map<Id, CustomObject1__c>();
    private Map<Id, Contact> mapPicOfCustomClearanceBrokers = new Map<Id, Contact>();
    private Map<Id, Contact> mapPartnerReps = new Map<Id, Contact>();
    private Map<Id, Contact> mapCustomersInCharge = new Map<Id, Contact>();
    private Map<Id, Account> customers = new Map<Id, Account>();
    private Map<Id, Port__c> mapPorts = new Map<Id, Port__c>();
    private ContainerInfoService containerInfoService;

    private Set<AnkenMeisai__c> toBeUpdated = new Set<AnkenMeisai__c>();
    private Map<Id, Common_Settings__c> toBeUpdateRunningNumbers = new Map<Id, Common_Settings__c>();
    private List<Container_Info__c> toBeDeletedContainers = new List<Container_Info__c>();
    private List<Container_Info__c> toBeUpdatedContainers = new List<Container_Info__c>();
    private List<Cargo_Delivery__c> toBeAddedCargoDeliveries = new List<Cargo_Delivery__c>();
    private List<Cargo_Delivery__c> toBeDeletedCargoDeliveries = new List<Cargo_Delivery__c>();
    private List<Transit__c> toBeAddedTransits = new List<Transit__c>();
    private List<Transit__c> toBeDeletedTransits = new List<Transit__c>();
    private List<Custom_Clearance__c> toBeAddedCustomClearances = new List<Custom_Clearance__c>();
    private List<Custom_Clearance__c> toBeDeletedcustomClearances = new List<Custom_Clearance__c>();
    private static TranslationService translationService;

    static {
        loadRecordTypes();
        findNewCustomers();

        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }

    public HBLShipmentsTriggerHandler() {
        containerInfoService = new containerInfoService();
        loadReferenceContacts(Trigger.new);
    }

    public override String getHandlerName() {
        return 'HBLShipmentsTriggerHandler';
    }

    public override void bulkAfter() {
        if(mapWarehouses.isEmpty()){
           loadLinkedWarehouses(Trigger.new); 
        }
        if(mapShipmentsWithChildren.isEmpty()){
           loadShipmentChildren(Trigger.new); 
        }
        if (Trigger.IsUpdate) {
            loadLinkedHBLSellingBuying();
        }
    }

    public override void bulkBefore() {
        if(mapWarehouses.isEmpty()){
           loadLinkedWarehouses(Trigger.new); 
        }
        if(mapShipmentsWithChildren.isEmpty()){
           loadShipmentChildren(Trigger.new); 
        }
        loadHBLRunningNumber(Trigger.new);
        loadCustomers(Trigger.new);
        if (Trigger.old == null) {
            exchangeRates = ExchangeRateSynchronizationService.loadMasterExchangeRates();
        }

        if (Trigger.isUpdate) {
            loadPorts(Trigger.new);
        }
    }

    public override void beforeInsert(SObject so) {
        CustomObject1__c shipment = (CustomObject1__c) so;

        if (!validateBeforeInsert(shipment)) {
            return;
        }
        resetNumberOfContainers(shipment, null);
        setStartingReminderDateForCompleteShipment(shipment);
        setInitialQuotationVersionOnCreation(shipment);
        setNotifyNewCustomerAlert(shipment);
        setNotifyCustomersFlag(shipment);
        capitalizeFields(shipment);

        if (PicklistReference.COMPLETED_ST.equalsIgnoreCase(shipment.Status__c)) {
            String recordTypeId = changeRecordTypeOnCompletion(shipment.RecordTypeId);
            if (recordTypeId != null) {
                shipment.RecordTypeId = recordTypeId;
            }
        }

        // Assign House BL NO (HBL__c)
        if (shipment.ETD__c != null && mapRecordTypeIdToName.containsKey(shipment.RecordTypeId)) {
            if (requiredHBLNo(shipment)) {
                // 2019/08/07 Chien Truong MODIFY START
                // assignNextRunningNumber(shipment);
                assignNextRunningNumber(shipment, null, true);
                // 2019/08/07 Chien Truong MODIFY END
            }
        }

        Account customer = customers.get(shipment.Field1__c);
        ExchangeRateSynchronizationService.applyExchangeRateToShipment(shipment, exchangeRates, customer);
        // 2021/08/19 Chien Truong START END
        // updateSalesAccountedDate(shipment, null);
        // 2021/08/19 Chien Truong DELETE END
        // assignREFNo(shipment);
        updateCustomClearanceFlag(shipment);
    }

    public override void afterInsert(SObject so) {
        CustomObject1__c shipment = (CustomObject1__c) so;
        String recordTypeName = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosById().get(shipment.RecordTypeId).getDeveloperName();

        syncContainerInfos(null, shipment);

        if (!Constants.QUOTATION_RT.equals(recordTypeName) ) {
            if (recordTypeName == 'CrossBoarder' ) {
                System.debug('123456789');
                updateCargoDelivery(shipment);
            }
            // updateCargoDelivery(shipment);
            updateTransits(shipment);
            setupCustomClearance(shipment, null, true);
        }
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        CustomObject1__c newShipment = (CustomObject1__c) so;
        CustomObject1__c oldShipment = (CustomObject1__c) oldSo;

        if (!validateBeforeUpdate(newShipment)) {
            return;
        }

        boolean canEdit = canEdit(oldShipment.RecordTypeId);
        if (canEdit) {
            resetNumberOfContainers(newShipment, oldShipment);
            setStartingReminderDateForCompleteShipment(newShipment);
            setNotifyCustomersFlag(newShipment);
            capitalizeFields(newShipment);

            if (PicklistReference.COMPLETED_ST.equalsIgnoreCase(newShipment.Status__c)
                    && !PicklistReference.COMPLETED_ST.equalsIgnoreCase(oldShipment.Status__c)
                    && (newShipment.BuyDifferentiation_sum2__c == null || newShipment.BuyDifferentiation_sum2__c == 0)
                    && (newShipment.NyukinzandakaJPY__c == null || newShipment.NyukinzandakaJPY__c == 0)
                    && (newShipment.UNPAID_BALANCE_OF_BUYING_USD__c == null || newShipment.UNPAID_BALANCE_OF_BUYING_USD__c == 0)
                    && (newShipment.UNPAID_BALANCE_OF_SELLING_USD__c == null || newShipment.UNPAID_BALANCE_OF_SELLING_USD__c == 0)) {
                String recordTypeId = changeRecordTypeOnCompletion(newShipment.RecordTypeId);
                if (recordTypeId != null) {
                    newShipment.RecordTypeId = recordTypeId;
                }
            }
            if ((StringUtils.isEmpty(newShipment.HBL__c) || StringUtils.isEmpty(newShipment.HAWB__c))
                    && newShipment.ETD__c != null
                    && mapRecordTypeIdToName.containsKey(newShipment.RecordTypeId)) {
                if (requiredHBLNo(newShipment)) {
                    //2018-12-11: if the HBL field is deleted by user, and is required to be populated, then prompt user for error. Otherwise a new number will be assigned for the same record.
                    // 2019/08/07 Chien Truong MODIFY START
                    /*
                    if (!String.isBlank(oldShipment.HBL__C) && String.isBlank(newShipment.HBL__c)) {
                        newShipment.addError('Input H B/L No or Temporary No, or change to B/L Type to "Direct M B/L(H B/L Issue Not Required)"');
                        return;
                    }*/
                    // 2021/08/28 Chien Truong DELETE START
                    /*if (newShipment.UpdateHBLNumber__c == false && !String.isBlank(oldShipment.HBL__C) && String.isBlank(newShipment.HBL__c)) {
                        newShipment.addError('Input H B/L No or Temporary No, or change to B/L Type to "Direct M B/L(H B/L Issue Not Required)"');
                        return;
                    }
                    // 2019/08/07 Chien Truong MODIFY END

                    if (!String.isBlank(oldShipment.HAWB__c) && String.isBlank(newShipment.HAWB__c)) {
                        newShipment.addError('Input HAWB Number or Temporary No, or change to B/L Type to "Direct M B/L(H B/L Issue Not Required)"');
                        return;
                    }*/
                     // 2021/08/28 Chien Truong DELETE END

                    // 2019/08/07 Chien Truong MODIFY START
                    // assignNextRunningNumber(newShipment);
                    assignNextRunningNumber(newShipment, oldShipment, false);
                    // 2019/08/07 Chien Truong MODIFY END
                }
            }

            // updateSalesAccountedDate(newShipment, oldShipment);
            updateTransitInfo(newShipment, oldShipment);
        } else {
            newShipment.addError(translationService.getTranslation(Constants.NOT_ALLOWED_EDIT_LOCKED_HBL));
        }
    }

    public override void afterUpdate(SObject oldSo, SObject so) {
        CustomObject1__c newShipment = (CustomObject1__c) so;
        CustomObject1__c oldShipment = (CustomObject1__c) oldSo;
        String recordTypeName = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosById().get(newShipment.RecordTypeId).getDeveloperName();

        updateHBLSellingBuyings(oldShipment, newShipment);
        syncContainerInfos(oldShipment, newShipment);

        if (!Constants.QUOTATION_RT.equals(recordTypeName)) {
            if (recordTypeName == 'CrossBoarder' ) {
                updateCargoDelivery(newShipment);
            }
            // updateCargoDelivery(newShipment);
            updateTransits(newShipment);
            setupCustomClearance(newShipment, oldShipment, false);
        }
    }

    public override void andFinally() {
        try {
            if (toBeUpdated.size() > 0) {
                // FlsService.doUpdate(new List<AnkenMeisai__c>(toBeUpdated));
            }

            // add Reference Numbers
            if (toBeUpdateRunningNumbers.values().size() > 0) {
                upsert new List<Common_Settings__c>(toBeUpdateRunningNumbers.values());
            }

            if (toBeDeletedContainers.size() > 0) {
                FlsService.dodelete(toBeDeletedContainers);
            }

            if (toBeUpdatedContainers.size() > 0) {
                FlsService.doupsert (toBeUpdatedContainers);
            }

            if (toBeAddedCargoDeliveries.size() > 0) {
                FlsService.doinsert(toBeAddedCargoDeliveries);
            } else if (toBeDeletedCargoDeliveries.size() > 0) {
                FlsService.dodelete (new List<Cargo_Delivery__c>(toBeDeletedCargoDeliveries));
            }

            if (!toBeAddedCustomClearances.isEmpty()) {
                FlsService.doinsert(toBeAddedCustomClearances);
            }

            if (toBeDeletedcustomClearances != null && !toBeDeletedcustomClearances.isEmpty()) {
                FlsService.dodelete( toBeDeletedcustomClearances);
            }

            if (toBeAddedTransits.size() > 0) {
                FlsService.doinsert(toBeAddedTransits);
            } else if (toBeDeletedTransits.size() > 0) {
                FlsService.dodelete(toBeDeletedTransits);
            }
        } catch (Exception e) {
            Trigger.new[0].addError(e.getMessage());
        }
    }

    private void resetNumberOfContainers(CustomObject1__c shipment, CustomObject1__c oldShipment) {
        String words = '';

        /*if (!StringUtils.isEmpty(shipment.TranporationType__c)
                && PicklistReference.TRANSPORTATION_LCL.equals(shipment.TranporationType__c) && shipment.carton__c != null) {

        } else*/ if (!StringUtils.isEmpty(shipment.TranporationType__c)
                && PicklistReference.TRANSPORTATION_FCL.equals(shipment.TranporationType__c)) {
            List<String> wordsPerContainerType = new List<String>();

            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber__c, shipment.Container__c);
            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber2__c, shipment.Container2__c);
            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber3__c, shipment.Container3__c);
            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber4__c, shipment.Container4__c);
			// 2019/08/05 Chien Truong ADD START
            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber5__c, shipment.Container5__c);
            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber6__c, shipment.Container6__c);
            generateWordingForContainer(wordsPerContainerType, (Integer) shipment.ContainerNumber7__c, shipment.Container7__c);
			// 2019/08/05 Chien Truong ADD END
			
            if (!wordsPerContainerType.isEmpty()) {
                words = String.join(wordsPerContainerType, ' AND ').toUpperCase();
            }
        } else {
            Integer numberOfPackage = (Integer) shipment.carton__c;
            words = NumbericUtils.convertNumberToEnglishText(numberOfPackage) + ' (' + numberOfPackage + ') '
                    + (StringUtils.isEmpty(shipment.UnitType__c) ? '' : ' ' + shipment.UnitType__c)
                    + (numberOfPackage > 1 ? 'S' : '');
        }

        // 2019/08/08 Chien Truong MODIFY START
        /*
        if (shipment.NumberOfContainers__c == null & !StringUtils.isEmpty(words)) {
            shipment.NumberOfContainers__c = (words + ' ONLY').toUpperCase();
        }*/        
        if (String.isBlank(shipment.NumberOfContainers__c) || 
            (oldShipment != null && (shipment.ContainerNumber__c != oldShipment.ContainerNumber__c
            || shipment.Container__c != oldShipment.Container__c
            || shipment.ContainerNumber2__c != oldShipment.ContainerNumber2__c
            || shipment.Container2__c != oldShipment.Container2__c
            || shipment.ContainerNumber3__c != oldShipment.ContainerNumber3__c
            || shipment.Container3__c != oldShipment.Container3__c
            || shipment.ContainerNumber4__c != oldShipment.ContainerNumber4__c
            || shipment.Container4__c != oldShipment.Container4__c
            || shipment.ContainerNumber5__c != oldShipment.ContainerNumber5__c
            || shipment.Container5__c != oldShipment.Container5__c
            || shipment.ContainerNumber6__c != oldShipment.ContainerNumber6__c
            || shipment.Container6__c != oldShipment.Container6__c
            || shipment.ContainerNumber7__c != oldShipment.ContainerNumber7__c
            || shipment.Container7__c != oldShipment.Container7__c))) {
            shipment.NumberOfContainers__c = null;
            if (!StringUtils.isEmpty(words)) {
                shipment.NumberOfContainers__c = (words + ' ONLY').toUpperCase();
            }
        }
        // 2019/08/08 Chien Truong MODIFY END
    }

    private void generateWordingForContainer(List<String> wordsPerContainerType, Integer numberOfContainers, String containerType) {
        if (!StringUtils.isEmpty(containerType) && Constants.CONTAINER_TYPE_NAMES.get(containerType) != null) {
            String wording = NumbericUtils.convertNumberToEnglishText(numberOfContainers)
                    + ' (' + numberOfContainers + ')'
                    + ' ' + Constants.CONTAINER_TYPE_NAMES.get(containerType)
                    + (numberOfContainers > 1 ? 'S' : '');

            wordsPerContainerType.add(wording);
        }
    }

    private void updateCustomClearanceFlag(CustomObject1__c shipment) {
        String shipmentRecordType = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosById().get(shipment.RecordTypeId).getDeveloperName();

        if (Constants.CROSS_BOARDER_RT.equalsIgnoreCase(shipmentRecordType)) {
            shipment.Custom__c = PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES;
        }
    }

    private boolean requiredHBLNo(CustomObject1__c shipment) {
        // 2021/08/28 Chien Truong MODIFY START
        /*return shipment.BL_TYPE__c == PicklistReference.HBL_NO_REQUIRED 
            && (
                Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.AIR_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.CROSS_BOARDER_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
            );*/
        
        return  Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.AIR_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.CROSS_BOARDER_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId));
        // 2021/08/28 Chien Truong MODIFY END
    }

    private void assignNextRunningNumber(CustomObject1__c shipment, CustomObject1__c oldShipment, Boolean isInsert) {
        String hblNoPrefix = null;
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();

        if (Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.CROSS_BOARDER_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                || Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))) {
            if (!StringUtils.isEmpty(shipment.HBL__c)) {
                // 2021/08/28 Chien Truong ADD START
                if (shipment.HBL__c.length() == 13) {
                    return;
                }
               
                // String keyYearMonth = shipment.HBL__c.subString(3, 9);
                String keyYearMonth = shipment.HBL__c;
                String inputNumber = shipment.HBL__c.right(3);

                if (!keyYearMonth.isNumeric() || !inputNumber.isNumeric()) {
                    return;
                }

                Integer nextNumber = Integer.valueOf(inputNumber);       
                String keyword = 'HBL_NO-' + keyYearMonth;

                Common_Settings__c lastNumber = null;                
                if (mapHBLRunningNumbers.containsKey(keyword)) {
                    lastNumber = mapHBLRunningNumbers.get(keyword);
                    
                    if (nextNumber > Integer.valueOf(lastNumber.Value__c)) {
                        lastNumber.Value__c = inputNumber;
                    }
                } else {
                    String name = 'HBL_NO-' + System.now();
                    lastNumber = new Common_Settings__c(Name = name, Keyword__c = keyword, Value__c = inputNumber);
                    mapHBLRunningNumbers.put(keyword, lastNumber);
                }
                
                if (toBeUpdateRunningNumbers.containsKey(lastNumber.Id)) { 
                    Common_Settings__c temp = toBeUpdateRunningNumbers.get(lastNumber.Id);
                    temp.Value__c = lastNumber.Value__c;
                } else {  
                    toBeUpdateRunningNumbers.put(lastNumber.Id, lastNumber);
                }                
                // 2021/08/28 Chien Truong ADD END
                return;
            }

            hblNoPrefix = setting.Ocean_HBL_No_Prefix__c;
        } else if (Constants.AIR_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))) {
            // For AIR EXPORT, if already input HAWB No manually, ignore auto generation.
            if (!StringUtils.isEmpty(shipment.HAWB__c)) {
                return;
            }

            hblNoPrefix = setting.Air_HBL_No_Prefix__c;
        }

        if (!StringUtils.isEmpty(hblNoPrefix)) {
            String keyword = formRunningNumberKey('HBL_NO', shipment.ETD__c, false);
            // 2021/08/28 Chien Truong ADD START
            // Thao NGO add oldShipment.ETD__c != null for issue Attempt to de-reference a null object
            String oldKeyword = null;
            if (oldShipment != null && oldShipment.ETD__c != null) {
                oldKeyword = formRunningNumberKey('HBL_NO', oldShipment.ETD__c, false);
            }
            // 2021/08/28 Chien Truong ADD END

            Common_Settings__c lastNumber = null;
            if (mapHBLRunningNumbers.containsKey(keyword)) {
                lastNumber = mapHBLRunningNumbers.get(keyword);
            } else {
                String name = 'HBL_NO-' + System.now();
                lastNumber = new Common_Settings__c(Name = name, Keyword__c = keyword, Value__c = '000');
                mapHBLRunningNumbers.put(keyword, lastNumber);
            }

            // 2021/08/28 Chien Truong MODIFY START
            // Integer nextNumber = Integer.valueOf(lastNumber.Value__c) + 1;
            Integer nextNumber = Integer.valueOf(lastNumber.Value__c);           
            if (keyword != oldKeyword) {
                nextNumber += 1;
            }
            // 2021/08/28 Chien Truong MODIFY END

            String nextNumberValue = StringUtils.prependZerosToNumber(nextNumber, 3);
            lastNumber.Value__c = nextNumberValue;

            if (toBeUpdateRunningNumbers.containsKey(lastNumber.Id)) {
                Common_Settings__c temp = toBeUpdateRunningNumbers.get(lastNumber.Id);
                temp.Value__c = lastNumber.Value__c;
            } else {
                toBeUpdateRunningNumbers.put(lastNumber.Id, lastNumber);
            }

            if (Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                    || Constants.CROSS_BOARDER_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                    || Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))) {
                // 2019/08/07 Chien Truong MODIFY START
                // shipment.HBL__c = hblNoPrefix + lastNumber.Keyword__c.substring(7) + lastNumber.Value__c;
                if ((isInsert == true || (isInsert == false && shipment.UpdateHBLNumber__c == false)) && shipment.BL_TYPE__c == 'H B/L Issue Required') {
                    shipment.HBL__c = hblNoPrefix + lastNumber.Keyword__c.substring(7) + lastNumber.Value__c;                    
                }
                // 2019/08/07 Chien Truong MODIFY END                
            } else if ((Constants.AIR_EXPORT_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))) && shipment.BL_TYPE__c == 'H B/L Issue Required') {
                shipment.HAWB__c = hblNoPrefix + lastNumber.Keyword__c.substring(7) + lastNumber.Value__c;
            }            
        }
    }

    private void assignREFNo(CustomObject1__c shipment) {
        String prefix = '';

        if (ObjectClassificationUtils.isOceanHBL(shipment) && ObjectClassificationUtils.isImportHBL(shipment)) {
            prefix = Constants.REF_OCEAN_IMPORT;
        } else if (ObjectClassificationUtils.isOceanHBL(shipment) && ObjectClassificationUtils.isExportHBL(shipment)) {
            prefix = Constants.REF_OCEAN_EXPORT;
        } else if (ObjectClassificationUtils.isAirHBL(shipment) && ObjectClassificationUtils.isImportHBL(shipment)) {
            prefix = Constants.REF_AIR_IMPORT;
        } else if (ObjectClassificationUtils.isAirHBL(shipment) && ObjectClassificationUtils.isExportHBL(shipment)) {
            prefix = Constants.REF_AIR_EXPORT;
        } else if (ObjectClassificationUtils.isCrossBoarder(shipment)) {
            prefix = Constants.REF_CROSS_BORDER;
        } else if (ObjectClassificationUtils.isDomesticTransportation(shipment)) {
            prefix = Constants.REF_DOMESTIC_TRANSPORTATION;
        }

        if (!StringUtils.isEmpty(prefix)) {
            DateTime dt = System.now();
            Date currentDate = Date.newInstance(dt.year(), dt.month(), dt.day());

            String keyword = formRunningNumberKey('REF_' + prefix, currentDate, true);
            Common_Settings__c lastNumber = null;

            if (mapHBLRunningNumbers.containsKey(keyword)) {
                lastNumber = mapHBLRunningNumbers.get(keyword);
            } else {
                String name = 'REF_' + prefix + '-' + System.now();
                lastNumber = new Common_Settings__c(Name = name, Keyword__c = keyword, Value__c = '0000');
                mapHBLRunningNumbers.put(keyword, lastNumber);
            }

            Integer nextNumber = Integer.valueOf(lastNumber.Value__c) + 1;
            String nextNumberValue = StringUtils.prependZerosToNumber(nextNumber, 4);
            lastNumber.Value__c = nextNumberValue;

            if (toBeUpdateRunningNumbers.containsKey(lastNumber.Id)) {
                Common_Settings__c temp = toBeUpdateRunningNumbers.get(lastNumber.Id);
                temp.Value__c = lastNumber.Value__c;
            } else {
                toBeUpdateRunningNumbers.put(lastNumber.Id, lastNumber);
            }
            //shipment.REFNO__c = prefix + lastNumber.Keyword__c.substring(7) + lastNumber.Value__c;
        }
    }

    private static String formRunningNumberKey(String prefix, Date etd, Boolean shortYear) {
        Integer year = etd.year();
        Integer month = etd.month();
        String keyword = prefix + '-';

        if (shortYear) {
            String yearString = '' + year;
            keyword += yearString.substring(2);
        } else {
            keyword += year;
        }
        keyword += StringUtils.prependZerosToNumber(month, 2);

        return keyword;
    }

    private void loadLinkedHBLSellingBuying() {
        Set<Id> shipmentIds = Trigger.newMap.keySet();
        Set<Id> lockedShipments = loadApprovalProcessLockedShipments(shipmentIds);

        shipmentIds.removeAll(lockedShipments);

        for (List<AnkenMeisai__c> ankens : [
                SELECT Id, Anken__c, Suryo__c, RecordType__c,
                        Tariff__r.Unit__c, Tariff__r.ContainerSize__c, Tariff__r.Subcategory__c,
                        Anken__r.FlgCopy__c, SerchSyubetu__c, DUE_DATE_OF_PAYMENT_EXCLUDE_TAX__c,
                        Invoice_Destination_Type__c, Seikyusaki__r.Custom_Type__c
                FROM AnkenMeisai__c
                WHERE Anken__c IN :shipmentIds
        ]) {
            for (AnkenMeisai__c anken : ankens) {
                if (mapAnkensPerShipment.get(anken.Anken__c) != null) {
                    mapAnkensPerShipment.get(anken.Anken__c).add(anken);
                } else {
                    List<AnkenMeisai__c> lstAnkens = new List<AnkenMeisai__c>();
                    lstAnkens.add(anken);
                    mapAnkensPerShipment.put(anken.Anken__c, lstAnkens);
                }
            }
        }
    }

    private void updateHBLSellingBuyings(CustomObject1__c oldShipment, CustomObject1__c newShipment) {
        List<AnkenMeisai__c> ankens = mapAnkensPerShipment.get(newShipment.Id);

        if (ankens != null && ankens.size() > 0) {
            for (AnkenMeisai__c anken : ankens) {
                /**
                 * There is a validation rule which prevent any modification if HBL record type is "locked"
                 * and the COPY FLAG is not TRUE. 
                 */
                if ((!StringUtils.isEmpty(anken.Recordtype__c) && !anken.Recordtype__c.contains('ロック'))
                        || anken.Anken__r.FlgCopy__c == null
                        || anken.Anken__r.FlgCopy__c.length() == 0) {
                    // Update QUANTITY
                    boolean requiredUpdate = updateQuantityOnChanged(oldShipment, newShipment, anken);

                    // Update DUE DATE
                    if (newShipment.DeadlineForPaymentOfInvoices__c != null) {
                        anken.DUE_DATE_OF_PAYMENT_EXCLUDE_TAX__c = (newShipment.DeadlineForPaymentOfInvoices__c.daysBetween(System.today()));
                        requiredUpdate = true;
                    }

                    if (oldShipment.MasterAnkenName__c != newShipment.MasterAnkenName__c) {
                        requiredUpdate = true;
                    }

                    if (requiredUpdate) {
                        anken.BY_PASS_VALIDATION_RULE__c = true;
                        toBeUpdated.add(anken);
                    }
                }
            }
        }
    }
    
    /**
     * Determine if QUANTITY (Suryo__c) is required to be updated.
     * If required, update it and return indicator of operation
     * Return: TRUE if required to update and FALSE to otherwise
     */
    private boolean updateQuantityOnChanged(CustomObject1__c oldShipment, CustomObject1__c newShipment, AnkenMeisai__c anken) {
        Double quantity = anken.Suryo__c;

        if (PicklistReference.UNIT_RTON.equalsIgnoreCase(anken.Tariff__r.Unit__c)) {
            /**
             * If it is R/TON, Quantity = max {Measurement, Gross Weight/1000}
             */
            if ((oldShipment.CBM__c != newShipment.CBM__c) || (oldShipment.weight__c != newShipment.weight__c)) {
                /**
                 * Measurement (CBM__c) is managed as TON while Gross Weight (weight__c) is
                 * managed as KG so Gross Weight has be to divided by 1000 to be in TON
                 * for comparing
                 */
                if (newShipment.CBM_Non_Zero__c < 1 && newShipment.Gross_Weight_RTON__c < 1) {
                    quantity = 1;
                } else if (newShipment.CBM_Non_Zero__c > newShipment.Gross_Weight_RTON__c) {
                    quantity = newShipment.CBM_Non_Zero__c;
                } else {
                    quantity = newShipment.Gross_Weight_RTON__c;
                }
            }
        } else if (PicklistReference.UNIT_CONTAINER.equalsIgnoreCase(anken.Tariff__r.Unit__c)
                && (oldShipment.Container__c != newShipment.Container__c
                || oldShipment.Container2__c != newShipment.Container2__c
                || oldShipment.ContainerNumber__c != newShipment.ContainerNumber__c
                || oldShipment.ContainerNumber2__c != newShipment.ContainerNumber2__c
                || oldShipment.Container3__c != newShipment.Container3__c
                || oldShipment.Container4__c != newShipment.Container4__c
                || oldShipment.Container5__c != newShipment.Container5__c
                || oldShipment.Container6__c != newShipment.Container6__c
                || oldShipment.Container7__c != newShipment.Container7__c
                || oldShipment.ContainerNumber3__c != newShipment.ContainerNumber3__c
               	|| oldShipment.ContainerNumber4__c != newShipment.ContainerNumber4__c
                || oldShipment.ContainerNumber5__c != newShipment.ContainerNumber5__c
                || oldShipment.ContainerNumber6__c != newShipment.ContainerNumber6__c
                || oldShipment.ContainerNumber7__c != newShipment.ContainerNumber7__c)) {
            if (PicklistReference.SEARCH_ENGINE_FCL_EXPORT.equals(anken.SerchSyubetu__c)
                    || PicklistReference.SEARCH_ENGINE_FCL_IMPORT.equals(anken.SerchSyubetu__c)) {
                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container__c)) {
                    quantity = newShipment.ContainerNumber__c;
                }

                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container2__c)) {
                    quantity = newShipment.ContainerNumber2__c;
                }

                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container3__c)) {
                    quantity = newShipment.ContainerNumber3__c;
                }

                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container4__c)) {
                    quantity = newShipment.ContainerNumber4__c;
                }
                
                // 2019/08/05 Chien Truong ADD START
                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container5__c)) {
                    quantity = newShipment.ContainerNumber5__c;
                }
                        
                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container6__c)) {
                    quantity = newShipment.ContainerNumber6__c;
                }
                        
                if (!StringUtils.isEmpty(anken.Tariff__r.ContainerSize__c)
                        && anken.Tariff__r.ContainerSize__c.equals(newShipment.Container7__c)) {
                    quantity = newShipment.ContainerNumber7__c;
                }
                // 2019/08/05 Chien Truong ADD END
            }
        }

        if (quantity != anken.Suryo__c) {
            anken.Suryo__c = quantity;
            return true;
        }

        return false;
    }

    private void loadHBLRunningNumber(List<CustomObject1__c> shipments) {
        List<Common_Settings__c> settings = new List<Common_Settings__c>();
        settings = [
                SELECT Value__c, Keyword__c
                FROM Common_Settings__c
                LIMIT 1000
                FOR UPDATE
        ];

        for (Common_Settings__c cs : settings) {
            mapHBLRunningNumbers.put(cs.Keyword__c, cs);
        }
    }

    private static void loadRecordTypes() {
        String objectName = Constants.NAMESPACE + 'CustomObject1__c';
        List<RecordType> recordTypes = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE SObjectType = :objectName AND IsActive = True
        ];
        for (RecordType rt : recordTypes) {
            mapRecordTypeIdToName.put(rt.Id, rt.DeveloperName);
            mapRecordTypeNameToId.put(rt.DeveloperName, rt.Id);
        }
    }

    Integer count = 0;

    private void loadLinkedWarehouses(List<CustomObject1__c> shipments) {
        Set<Id> warehouseIds = new Set<Id>();
        for (CustomObject1__c shipment : shipments) {
            if (!StringUtils.isEmpty(shipment.LoadLocation__c)) {
                warehouseIds.add(shipment.LoadLocation__c);
            }
        }

        for (List<LoadLocation__c> warehouses : [SELECT Id, Name, LoadAddress__c FROM LoadLocation__c WHERE Id IN :warehouseIds]) {
            for (LoadLocation__c warehouse : warehouses) {
                mapWarehouses.put(warehouse.Id, warehouse);
            }
        }
    }

    private void loadReferenceContacts(List<CustomObject1__c> shipments) {
        Set<Id> brokerIds = new Set<Id>();
        Set<Id> partnerIds = new Set<Id>();
        Set<Id> customerIds = new Set<Id>();

        for (CustomObject1__c shipment : shipments) {
            if (shipment.PartnerRep__c != null) {
                partnerIds.add(shipment.PartnerRep__c);
            }

            if (shipment.CustmerInCharge__c != null) {
                customerIds.add(shipment.CustmerInCharge__c);
            }
        }

        Set<Id> ids = new Set<Id>();
        ids.addAll(brokerIds);
        ids.addAll(partnerIds);
        ids.addAll(customerIds);

        if (ids.size() > 0) {
            for (List<Contact> contacts : [SELECT Id, Phone, MailS__c FROM Contact WHERE Id IN :ids]) {
                for (Contact con : contacts) {
                    if (brokerIds.contains(con.Id)) {
                        mapPicOfCustomClearanceBrokers.put(con.Id, con);
                    }

                    if (partnerIds.contains(con.Id)) {
                        mapPartnerReps.put(con.Id, con);
                    }

                    if (customerIds.contains(con.Id)) {
                        mapCustomersInCharge.put(con.Id, con);
                    }
                }
            }
        }
    }

    private Set<Id> loadApprovalProcessLockedShipments(Set<Id> ids) {
        Set<Id> lockedForApprovalShipments = new Set<Id>();

        for (List<ProcessInstance > instances: [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :ids AND Status = 'Pending']) {
            for (ProcessInstance instance : instances) {
                lockedForApprovalShipments.add(instance.Id);
            }
        }

        return lockedForApprovalShipments;
    }

    private void loadPorts(List<CustomObject1__c> shipments) {
        Set<Id> portIds = new Set<Id>();

        for (CustomObject1__c shipment : shipments) {
            if (mapShipmentsWithChildren.get(shipment.Id) != null) {
                List<Transit__c> transits = mapShipmentsWithChildren.get(shipment.Id).TRANSIT__r;

                if (transits != null && !transits.isEmpty()) {
                    for (Transit__c transit : transits) {
                        if (transit.TransitPort__c != null) {
                            portIds.add(transit.TransitPort__c);
                        }
                    }
                }

                if (shipment.POL__c != null) {
                    portIds.add(shipment.POL__c);
                }

                if (shipment.POD__c != null) {
                    portIds.add(shipment.POD__c);
                }
            }
        }

        if (!portIds.isEmpty()) {
            mapPorts = new Map<Id, Port__c>([SELECT Id, Name, Country_Name__c FROM Port__c WHERE Id IN :portIds]);
        }
    }

    private void setStartingReminderDateForCompleteShipment(CustomObject1__c shipment) {
        if (!Constants.QUOTATION_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))
                && shipment.SellInTaxAmountJPY_sum__c != 0
                && shipment.NyukinzandakaJPY__c == 0
                && shipment.BuyInTaxAmountJPY_sum__c != 0
                && shipment.BuyDifferentiation_sum2__c == 0
                && !PicklistReference.COMPLETED_ST.equalsIgnoreCase(shipment.status__c)) {
            shipment.Meet_Completed_Reminder__c = System.today();
        } else {
            shipment.Meet_Completed_Reminder__c = null;
        }
    }

    private void setInitialQuotationVersionOnCreation(CustomObject1__c shipment) {
        shipment.QuotationVer__c = 1;
    }

    private void loadShipmentChildren(List<CustomObject1__c> shipments) {
        Set<Id> shipmentIds = new Set<Id>();
        for (CustomObject1__c shipment : shipments) {
            shipmentIds.add(shipment.Id);
        }

        mapShipmentsWithChildren = new Map<Id, CustomObject1__c>([
                SELECT Id, POL__r.Country_Name__c, POD__r.Country_Name__c, RecordTypeId, TranporationType__c, CBM__c, chargable_weight__c, (
                        SELECT Container__c, Bypass_Container_Type_Check__c, Container_NO__c
                        FROM Container_Info__r
                        ORDER BY CreatedDate ASC
                ), (SELECT Id, DeliveryDate__c, Pickupdate__c FROM Cargo_Delivery__r ORDER BY CreatedDate ASC), (SELECT Id, Customs_Release_Day__c FROM Custom_Clearance__r), (
                        SELECT Id, RecordTypeId, ETDAtTransitPort__c, ETAAtTransitPort__c,
                                TransitVesselFlight__c, SwitchHBL__c, TransitPort__c
                        FROM TRANSIT__r
                        ORDER BY InOrderOfTransit__c ASC, CreatedDate ASC
                )
                FROM CustomObject1__c
                WHERE Id IN :shipmentIds
        ]);
    }

    private void syncContainerInfos(CustomObject1__c oldShipment, CustomObject1__c newShipment) {
        boolean requiredSync = requiredSync(oldShipment, newShipment);

        if (requiredSync) {
            Integer numOfContainersType1 = (newShipment.ContainerNumber__c != null ? newShipment.ContainerNumber__c.intValue() : 0);
            Integer numOfContainersType2 = (newShipment.ContainerNumber2__c != null ? newShipment.ContainerNumber2__c.intValue() : 0);
            Integer numOfContainersType3 = (newShipment.ContainerNumber3__c != null ? newShipment.ContainerNumber3__c.intValue() : 0);
            Integer numOfContainersType4 = (newShipment.ContainerNumber4__c != null ? newShipment.ContainerNumber4__c.intValue() : 0);
			// 2019/08/05 Chien Truong ADD START
            Integer numOfContainersType5 = (newShipment.ContainerNumber5__c != null ? newShipment.ContainerNumber5__c.intValue() : 0);
            Integer numOfContainersType6 = (newShipment.ContainerNumber6__c != null ? newShipment.ContainerNumber6__c.intValue() : 0);
            Integer numOfContainersType7 = (newShipment.ContainerNumber7__c != null ? newShipment.ContainerNumber7__c.intValue() : 0);
			// 2019/08/05 Chien Truong ADD END
            Map<String, Integer> containerMap = new Map<String, Integer>();
            setupContainerMap(containerMap, newShipment.Container__c, numOfContainersType1);
            setupContainerMap(containerMap, newShipment.Container2__c, numOfContainersType2);
            setupContainerMap(containerMap, newShipment.Container3__c, numOfContainersType3);
            setupContainerMap(containerMap, newShipment.Container4__c, numOfContainersType4);
            // 2019/08/05 Chien Truong ADD START
            setupContainerMap(containerMap, newShipment.Container5__c, numOfContainersType5);
            setupContainerMap(containerMap, newShipment.Container6__c, numOfContainersType6);
            setupContainerMap(containerMap, newShipment.Container7__c, numOfContainersType7);
			// 2019/08/05 Chien Truong ADD END
			
            CustomObject1__c shipment = mapShipmentsWithChildren.get(newShipment.Id);
            List<Container_Info__c> containers = shipment.Container_Info__r;
            turnOnBypassCheckingFlag(containers);

            List<Container_Info__c> toBeRemoved = filterContainerInfo(containers, containerMap.keySet(), false);
            List<Container_Info__c> toBeAdded = new List<Container_Info__c>();
            for (String containerType : containerMap.keySet()) {
                syncByContainerType(newShipment.Id, containerType, containerMap.get(containerType), containers, toBeAdded, toBeRemoved);
            }

            toBeUpdatedContainers.addAll(toBeAdded);
            toBeDeletedContainers.addAll(toBeRemoved);
        }
    }

    private void setupContainerMap(Map<String, Integer> containerMap, String containerType, Integer containerNumber) {
        if (containerNumber > 0 && !StringUtils.isEmpty(containerType)) {
            Integer updatedNumber = containerNumber;

            if (containerMap.containsKey(containerType)) {
                updatedNumber += containerMap.get(containerType);
            }
            containerMap.put(containerType, updatedNumber);
        }
    }

    private boolean requiredSync(CustomObject1__c oldShipment, CustomObject1__c newShipment) {
        if (!HBLShipmentsTriggerHandler.isRunning) {
            HBLShipmentsTriggerHandler.isRunning = true;
        } else {
            return false;
        }

        if (oldShipment != null) {
            Integer numOfNewContainersType1 = (newShipment.ContainerNumber__c != null ? Integer.valueOf(newShipment.ContainerNumber__c) : 0);
            Integer numOfNewContainersType2 = (newShipment.ContainerNumber2__c != null ? Integer.valueOf(newShipment.ContainerNumber2__c) : 0);
            Integer numOfNewContainersType3 = (newShipment.ContainerNumber3__c != null ? Integer.valueOf(newShipment.ContainerNumber3__c) : 0);
            Integer numOfNewContainersType4 = (newShipment.ContainerNumber4__c != null ? Integer.valueOf(newShipment.ContainerNumber4__c) : 0);
            // 2019/08/05 Chien Truong ADD START
            Integer numOfNewContainersType5 = (newShipment.ContainerNumber5__c != null ? Integer.valueOf(newShipment.ContainerNumber5__c) : 0);
            Integer numOfNewContainersType6 = (newShipment.ContainerNumber6__c != null ? Integer.valueOf(newShipment.ContainerNumber6__c) : 0);
            Integer numOfNewContainersType7 = (newShipment.ContainerNumber7__c != null ? Integer.valueOf(newShipment.ContainerNumber7__c) : 0);
			// 2019/08/05 Chien Truong ADD END
			
            Map<String, Integer> newContainerMap = new Map<String, Integer>();
            setupContainerMap(newContainerMap, newShipment.Container__c, numOfNewContainersType1);
            setupContainerMap(newContainerMap, newShipment.Container2__c, numOfNewContainersType2);
            setupContainerMap(newContainerMap, newShipment.Container3__c, numOfNewContainersType3);
            setupContainerMap(newContainerMap, newShipment.Container4__c, numOfNewContainersType4);
            // 2019/08/05 Chien Truong ADD START
            setupContainerMap(newContainerMap, newShipment.Container5__c, numOfNewContainersType5);
            setupContainerMap(newContainerMap, newShipment.Container6__c, numOfNewContainersType6);
            setupContainerMap(newContainerMap, newShipment.Container7__c, numOfNewContainersType7);
			// 2019/08/05 Chien Truong ADD END
			
            Integer numOfOldContainersType1 = (oldShipment.ContainerNumber__c != null ? Integer.valueOf(oldShipment.ContainerNumber__c) : 0);
            Integer numOfOldContainersType2 = (oldShipment.ContainerNumber2__c != null ? Integer.valueOf(oldShipment.ContainerNumber2__c) : 0);
            Integer numOfOldContainersType3 = (oldShipment.ContainerNumber3__c != null ? Integer.valueOf(oldShipment.ContainerNumber3__c) : 0);
            Integer numOfOldContainersType4 = (oldShipment.ContainerNumber4__c != null ? Integer.valueOf(oldShipment.ContainerNumber4__c) : 0);
            Integer numOfOldContainersType5 = (oldShipment.ContainerNumber5__c != null ? Integer.valueOf(oldShipment.ContainerNumber5__c) : 0);
            Integer numOfOldContainersType6 = (oldShipment.ContainerNumber6__c != null ? Integer.valueOf(oldShipment.ContainerNumber6__c) : 0);
            Integer numOfOldContainersType7 = (oldShipment.ContainerNumber7__c != null ? Integer.valueOf(oldShipment.ContainerNumber7__c) : 0);
 
            Map<String, Integer> oldContainerMap = new Map<String, Integer>();
            setupContainerMap(oldContainerMap, oldShipment.Container__c, numOfOldContainersType1);
            setupContainerMap(oldContainerMap, oldShipment.Container2__c, numOfOldContainersType2);
            setupContainerMap(oldContainerMap, oldShipment.Container3__c, numOfOldContainersType3);
            setupContainerMap(oldContainerMap, oldShipment.Container4__c, numOfOldContainersType4);
            // 2019/08/05 Chien Truong ADD START
            setupContainerMap(oldContainerMap, oldShipment.Container5__c, numOfOldContainersType5);
            setupContainerMap(oldContainerMap, oldShipment.Container6__c, numOfOldContainersType6);
            setupContainerMap(oldContainerMap, oldShipment.Container7__c, numOfOldContainersType7);
			// 2019/08/05 Chien Truong ADD END

            return !newContainerMap.equals(oldContainerMap);
        }

        return true;
    }

    private void syncByContainerType(String shipmentId, String containerType, Integer numContainers,
            List<Container_Info__c> existingContainers, List<Container_Info__c> toBeAdded,
            List<Container_Info__c> toBeRemoved) {
        Set<String> containerTypes = new Set<String>();
        containerTypes = new Set<String>();
        containerTypes.add(containerType);

        List<Container_Info__c> containers = filterContainerInfo(existingContainers, containerTypes, true);

        if (containers.size() < numContainers) {
            Integer numOfContainersToAdd = numContainers - containers.size();
            containerInfoService.createContainers(shipmentId, containerType, numOfContainersToAdd, toBeAdded);
        } else if (containers.size() > numContainers) {
            for (Integer i = numContainers; i < containers.size(); i++) {
                toBeRemoved.add(containers.get(i));
            }
        }
    }

    private List<Container_Info__c> filterContainerInfo(List<Container_Info__c> containers,
            Set<String> containerTypes, boolean matched) {
        List<Container_Info__c> result = new List<Container_Info__c>();

        for (Container_Info__c container : containers) {
            String containerType = container.Container__c;

            if (matched) {
                if (containerTypes.contains(containerType)) {
                    result.add(container);
                }
            } else {
                if (!containerTypes.contains(containerType)) {
                    result.add(container);
                }
            }
        }

        return result;
    }

    private void turnOnBypassCheckingFlag(List<Container_Info__c> containers) {
        for (Container_Info__c container : containers) {
            container.Bypass_Container_Type_Check__c = true;
        }
    }

    private static void findNewCustomers() {
        List<String> includedTypes = new List<String>{
                PicklistReference.DOMESTIC_CUSTOMER_EXISTING,
                PicklistReference.DOMESTIC_CUSTOMER_LEAD_APPROACHING,
                PicklistReference.DOMESTIC_CUSTOMER_NO_NEED_SALES
        };
        List<Account> newCustomersForAlert = [
                SELECT Id, Custom_Type__c, (SELECT Id FROM HTqj__r)
                FROM Account
                WHERE Custom_Type__c IN :includedTypes
        ];
        for (Account account : newCustomersForAlert) {
            List<CustomObject1__c> shipments = account.HTqj__r;
            if (shipments == null || shipments.isEmpty()) {
                newCustomersForAlertIds.add(account.Id);
            }
        }
    }

    private void setNotifyNewCustomerAlert(CustomObject1__c shipment) {
        shipment.Notify_New_Customer_Alert__c = false;

        if (newCustomersForAlertIds.contains(shipment.Field1__c)
                && !Constants.QUOTATION_RT.equalsIgnoreCase(mapRecordTypeIdToName.get(shipment.RecordTypeId))) {
            shipment.Notify_New_Customer_Alert__c = true;
        }
    }

    private void setNotifyCustomersFlag(CustomObject1__c shipment) {
        shipment.Partner_Do_Not_Disturb_State__c = false;
        shipment.Customer_Do_Not_Disturb_State__c = false;

        if (shipment.PartnerRep__c != null && mapPartnerReps.containsKey(shipment.PartnerRep__c)) {
            shipment.Partner_Do_Not_Disturb_State__c = mapPartnerReps.get(shipment.PartnerRep__c).MailS__c;
        }

        if (shipment.CustmerInCharge__c != null && mapCustomersInCharge.containsKey(shipment.CustmerInCharge__c)) {
            shipment.Customer_Do_Not_Disturb_State__c = mapCustomersInCharge.get(shipment.CustmerInCharge__c).MailS__c;
        }
    }

    private void capitalizeFields(CustomObject1__c shipment) {
        shipment.Vessle__c = StringUtils.capitalize(shipment.Vessle__c);
        shipment.Master_B_L__c = StringUtils.capitalize(shipment.Master_B_L__c);
        shipment.Item__c = StringUtils.capitalize(shipment.Item__c);
        shipment.HBL__c = StringUtils.capitalize(shipment.HBL__c);
        shipment.Voy_No__c = StringUtils.capitalize(shipment.Voy_No__c);
        shipment.Marks_and_Numbers__c = StringUtils.capitalize(shipment.Marks_and_Numbers__c);
        shipment.TS__c = StringUtils.capitalize(shipment.TS__c);
        shipment.TransitV__c = StringUtils.capitalize(shipment.TransitV__c);
        shipment.HAWB__c = StringUtils.capitalize(shipment.HAWB__c);
        shipment.MAWB__c = StringUtils.capitalize(shipment.MAWB__c);
        shipment.No_Of_LoadingConfirmation__c = StringUtils.capitalize(shipment.No_Of_LoadingConfirmation__c);
        shipment.ContainerSeal_No__c = StringUtils.capitalize(shipment.ContainerSeal_No__c);
        shipment.Number_of_Containers__c = StringUtils.capitalize(shipment.Number_of_Containers__c);
        shipment.BookingNo__c = StringUtils.capitalize(shipment.BookingNo__c);
    }
    
    private static Map<Id, Id> mapRecordTypeLock = new Map<Id, Id> {
        Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.OCEAN_IMPORT_RT).getRecordTypeId() => Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.OCEAN_IMPORT_LOCK_RT).getRecordTypeId(),
        Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.OCEAN_EXPORT_RT).getRecordTypeId() => Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.OCEAN_EXPORT_LOCK_RT).getRecordTypeId(),
        Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.AIR_IMPORT_RT).getRecordTypeId() => Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.AIR_IMPORT_LOCK_RT).getRecordTypeId(),
        Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.AIR_EXPORT_RT).getRecordTypeId() => Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.AIR_EXPORT_LOCK_RT).getRecordTypeId(),
        Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.DOMESTIC_TRANSPORTATION_RT).getRecordTypeId() => Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.DOMESTIC_TRANSPORTATION_LOCK_RT).getRecordTypeId(),
        Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.CROSS_BOARDER_RT).getRecordTypeId() => Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(Constants.CROSS_BOARDER_LOCK_RT).getRecordTypeId()
    };

    private String changeRecordTypeOnCompletion(String currentRecordTypeId) {
        return mapRecordTypeLock.get(currentRecordTypeId);
    }

    private void loadCustomers(List<CustomObject1__c> shipments) {
        Set<Id> customerIds = new Set<Id>();

        for (CustomObject1__c shipment : shipments) {
            customerIds.add(shipment.Field1__c);
        }
        customers = new Map<Id, Account>([
                SELECT Id, Primary_Exchange_Rate_Currency__c, Secondary_Exchange_Rate_Currency__c, Business_Relationship__c
                FROM Account
                WHERE Id IN :customerIds
        ]);
    }
    
    /**
     * Only who has access to locked shipment can unlock
     */
    private boolean canEdit(String oldRecordTypeId) {
        String oldRecordType = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosById().get(oldRecordTypeId).getDeveloperName();

        if (oldRecordType == null) {
            return false;
        }

        return true;
    }

    private void updateTransits(CustomObject1__c shipment) {
        Integer newLocations = (StringUtils.isEmpty(shipment.MultiTransitRequired__c) || 'NO'.equalsIgnoreCase(shipment.MultiTransitRequired__c) ? 0 : Integer.valueOf(shipment.MultiTransitRequired__c));
        CustomObject1__c parent = mapShipmentsWithChildren.get(shipment.Id);
        List<Transit__c> transitList = parent.TRANSIT__r;
        Integer oldLocations = transitList.size();
        String recordTypeId = Schema.SObjectType.Transit__c.getRecordTypeInfosByDeveloperName().get('ShipmentOrderTransit').getRecordTypeId();

        if (oldLocations < newLocations && !StringUtils.isEmpty(recordTypeId)) {
            Integer numItemsToAdd = newLocations - oldLocations;
            Integer index = oldLocations;

            for (Integer i = 0; i < numItemsToAdd; i++) {
                Transit__c transit = new Transit__c();
                transit.ShipmentOrder__c = shipment.Id;
                transit.RecordTypeId = recordTypeId;
                transit.InOrderOfTransit__c = ++oldLocations;

                toBeAddedTransits.add(transit);
            }
        } else if (oldLocations > newLocations) {
            for (Integer i = newLocations; i < oldLocations; i++) {
                toBeDeletedTransits.add(transitList.get(i));
            }
        }
    }

    private void updateCargoDelivery(CustomObject1__c shipment) {
        String deliveryLocations = LegacyResourceUtils.getHBLDeliveryServiceRequired(shipment.DeliveryService_required__c);
        Integer newLocations = (StringUtils.isEmpty(deliveryLocations) ? 0 : Integer.valueOf(deliveryLocations));
        CustomObject1__c parent = mapShipmentsWithChildren.get(shipment.Id);
        List<Cargo_Delivery__c> cargoDeliveries = parent.Cargo_Delivery__r;
        Integer oldLocations = cargoDeliveries.size();
        String recordTypeId = determineCargoDeliveryType(parent);
        Boolean isImportHBL = ObjectClassificationUtils.isImportHBL(shipment);
        Boolean isExportHBL = ObjectClassificationUtils.isExportHBL(shipment);

        if (oldLocations < newLocations && !StringUtils.isEmpty(recordTypeId)) {
            Integer numItemsToAdd = newLocations - oldLocations;

            for (Integer i = 0; i < numItemsToAdd; i++) {
                Cargo_Delivery__c cd = new Cargo_Delivery__c();
                cd.HBL_SHIPMENT__c = shipment.Id;

                LoadLocation__c location = mapWarehouses.get(shipment.LoadLocation__c);
                if (location != null) {
                    if (isImportHBL) {
                        cd.Receiver__c = mapWarehouses.get(shipment.LoadLocation__c).Name;
                        cd.AddressForAccept__c = mapWarehouses.get(shipment.LoadLocation__c).LoadAddress__c;

                        if (!StringUtils.isEmpty(shipment.LoadLocationPIC__c)) {
                            cd.PersonInChargeForAccept__c = shipment.LoadLocationPIC__c.toUpperCase();
                        }
                    } else if (isExportHBL) {
                        cd.Destination__c = mapWarehouses.get(shipment.LoadLocation__c).Name;
                        cd.Destinationaddress__c = mapWarehouses.get(shipment.LoadLocation__c).LoadAddress__c;

                        if (!StringUtils.isEmpty(shipment.LoadLocationPIC__c)) {
                            cd.ReceiverRep__c = shipment.LoadLocationPIC__c.toUpperCase();
                        }
                    }
                }

                if (!StringUtils.isEmpty(recordTypeId)) {
                    cd.RecordTypeId = recordTypeId;
                }
                toBeAddedCargoDeliveries.add(cd);
            }
        } else if (oldLocations > newLocations) {
            for (Integer i = newLocations; i < oldLocations; i++) {
                Cargo_Delivery__c cd = cargoDeliveries.get(i);
                toBeDeletedCargoDeliveries.add(cd);
            }
        }
    }

    private String determineCargoDeliveryType(CustomObject1__c shipment) {
        String recordType = '';
        String importOrExport = (ObjectClassificationUtils.isImportHBL(shipment) ? 'Import' : 'Export');
        String transport = '';
        String shipmentRecordType = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosById().get(shipment.RecordTypeId).getDeveloperName();

        if (Constants.CROSS_BOARDER_RT.equalsIgnoreCase(shipmentRecordType)) {
            if (shipment.POD__c != null && shipment.POD__r.Country_Name__c == Site_Custom_Settings__c.getOrgDefaults().Company_Country__c) {
                recordType = 'Drayage_Import';
            } else if (shipment.POL__c != null && shipment.POL__r.Country_Name__c == Site_Custom_Settings__c.getOrgDefaults().Company_Country__c) {
                recordType = 'Drayage_Export';
            } else {
                recordType = 'Drayage_Import';
            }
        } else if (PicklistReference.TRANSPORTATION_FCL.equals(shipment.TranporationType__c)
                || PicklistReference.TRANSPORTATION_MTY.equals(shipment.TranporationType__c)
                || PicklistReference.TRANSPORTATION_MTY_FCL.equals(shipment.TranporationType__c)
                || PicklistReference.TRANSPORTATION_Consol.equals(shipment.TranporationType__c)) {
            transport = 'Drayage';
        } else if (PicklistReference.TRANSPORTATION_LCL.equals(shipment.TranporationType__c)) {
            if (shipment.CBM__c != null && shipment.CBM__c > 4) {
                transport = 'Charter_Truck';
            } else {
                transport = 'Consolidation_Truck';
            }
        } else if (PicklistReference.TRANSPORTATION_AIR.equals(shipment.TranporationType__c)) {
            if (shipment.chargable_weight__c != null && shipment.chargable_weight__c > 2) {
                transport = 'Charter_Truck';
            } else {
                transport = 'Consolidation_Truck';
            }
        } else if (PicklistReference.TRANSPORTATION_BULK.equals(shipment.TranporationType__c)) {
            transport = 'Charter_Truck';
        }

        if (!StringUtils.isEmpty(transport)) {
            recordType = transport + '_' + importOrExport;
        }
        return Schema.SObjectType.Cargo_Delivery__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
    }
    
    /**
     * Validate before insert
     * 
     * @return: TRUE if passed all validations; FALSE if failed any validations
     */
    private boolean validateBeforeInsert(CustomObject1__c shipment) {
        boolean result = true;

        if (ObjectClassificationUtils.isLockedHBL(shipment)) {
            shipment.addError(translationService.getTranslation(Constants.NOT_ALLOWED_CREATE_LOCKED_HBL));
            result = false;
        }

        String errorMessage = ValidationUtils.validateDeliveryDates(shipment, null, null);
        if (!Stringutils.isEmpty(errorMessage)) {
            shipment.addError(translationService.getTranslation(errorMessage));
            result = false;
        }

        return result;
    }
    
    /**
     * Validate before insert
     * 
     * @return: TRUE if passed all validations; FALSE if failed any validations
     */
    private boolean validateBeforeUpdate(CustomObject1__c shipment) {
        boolean result = true;

        CustomObject1__c parent = mapShipmentsWithChildren.get(shipment.Id);
        String errorMessage = ValidationUtils.validateDeliveryDates(shipment, parent.Cargo_Delivery__r, parent.Custom_Clearance__r);
        if (!Stringutils.isEmpty(errorMessage)) {
            shipment.addError(translationService.getTranslation(errorMessage));
            result = false;
        }

        return result;
    }

    private void createCustomClearances(CustomObject1__c shipment) {
        String recordType = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosById().get(shipment.RecordTypeId).getDeveloperName();
        String ccRecordType = null;
       
        if (Constants.OCEAN_IMPORT_RT.equalsIgnoreCase(recordType)) {
            createCustomClearance(shipment.Id, Constants.CC_OCEAN_IMPORT_RT);
        } else if (Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(recordType) || Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(recordType)) {
            createCustomClearance(shipment.Id, Constants.CC_OCEAN_EXPORT_RT);
        } else if (Constants.AIR_IMPORT_RT.equalsIgnoreCase(recordType)) {
            createCustomClearance(shipment.Id, Constants.CC_AIR_IMPORT_RT);
        } else if (Constants.AIR_EXPORT_RT.equalsIgnoreCase(recordType)) {
            createCustomClearance(shipment.Id, Constants.CC_AIR_EXPORT_RT);
        } else if (Constants.CROSS_BOARDER_RT.equalsIgnoreCase(recordType)) {
            // createCustomClearance(shipment.Id, Constants.CC_INLAND_IMPORT_RT);
            // createCustomClearance(shipment.Id, Constants.CC_INLAND_EXPORT_RT);
        }
        // 2019/08/17 Chien Truong ADD START
        else if (Constants.LOGISTICS_SERVICE.equalsIgnoreCase(recordType)) {
            createCustomClearance(shipment.Id, Constants.LOGISTICS_SERVICE);
        }
        // 2019/08/17 Chien Truong ADD END
    }

    private void createCustomClearance(String shipmentId, String ccRecordType) {
        if (!StringUtils.isEmpty(ccRecordType)) {
            String ccRecordTypeId = Schema.SObjectType.Custom_Clearance__c.getRecordTypeInfosByDeveloperName().get(ccRecordType).getRecordTypeId();
            if (!StringUtils.isEmpty(ccRecordTypeId)) {
                Custom_Clearance__c customClearance = new Custom_Clearance__c();
                customClearance.RecordTypeId = ccRecordTypeId;
                customClearance.HBL_SHIPMENT__c = shipmentId;
                toBeAddedCustomClearances.add(customClearance);
            }
        }
    }

    private void setupCustomClearance(CustomObject1__c newShipment, CustomObject1__c oldShipment, Boolean isNew) {
        if (isNew && PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(newShipment.Custom__c)) {
            createCustomClearances(newShipment);
        } else if (oldShipment != null) {
            if (PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(oldShipment.Custom__c)
                    && PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO.equalsIgnoreCase(newShipment.Custom__c)) {
                CustomObject1__c parent = mapShipmentsWithChildren.get(newShipment.Id);

                if (parent != null) {
                    toBeDeletedcustomClearances = parent.Custom_Clearance__r;
                }
            } else if (PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO.equalsIgnoreCase(oldShipment.Custom__c)
                    && PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(newShipment.Custom__c)) {
                createCustomClearances(newShipment);
            }
        }
    }

    private void updateSalesAccountedDate(CustomObject1__c newShipment, CustomObject1__c oldShipment) {
        // 2021/08/19 Chien Truong DELETE START
        /*List<Date> dates = new List<Date>();

        if (oldShipment == null
                || (oldShipment != null && oldShipment.SalesAccountedDate__c == newShipment.SalesAccountedDate__c)) {
            Port__c portPOL = mapPorts.get(newShipment.POL__c);
            Port__c portPOD = mapPorts.get(newShipment.POD__c);
            Site_Custom_Settings__c settings = Site_Custom_Settings__c.getOrgDefaults();

            if (ObjectClassificationUtils.isImportHBL(newShipment)
                    || (ObjectClassificationUtils.isCrossBoarder(newShipment)
                    && portPOD != null && settings.Company_Country__c.equals(portPOD.Country_Name__c))) {
                dates.add(newShipment.ETA__c);
                dates.add(newShipment.CustomsReleaseDay__c);
                dates.add(newShipment.DeliveryDate__c);
            } else if (ObjectClassificationUtils.isExportHBL(newShipment)
                    || ObjectClassificationUtils.isCrossBoarder(newShipment)
                    || ObjectClassificationUtils.isDomesticTransportation(newShipment)) {
                dates.add(newShipment.ETD__c);
                dates.add(newShipment.CustomsReleaseDay__c);
                dates.add(newShipment.DeliveryDate__c);
            }
            
            Date salesAccountedDate = DateTimeUtils.maxDates(dates);
            if (salesAccountedDate != null && (newShipment.SalesAccountedDate__c == null || (oldShipment != null && newShipment.SalesAccountedDate__c == oldShipment.SalesAccountedDate__c))) {
                if( (oldShipment != null && newShipment.DeliveryDate__c != oldShipment.DeliveryDate__c)
                    || (oldShipment != null && newShipment.CustomsReleaseDay__c != oldShipment.CustomsReleaseDay__c)
                    || (oldShipment != null && ObjectClassificationUtils.isImportHBL(newShipment) && newShipment.ETA__c != oldShipment.ETA__c)
                    || ( oldShipment != null && ObjectClassificationUtils.isExportHBL(newShipment) && newShipment.ETD__c != oldShipment.ETD__c)
                    || newShipment.SalesAccountedDate__c == null){
                        newShipment.SalesAccountedDate__c = salesAccountedDate;
                }                
            }
            
        }*/

        if (newShipment.SalesAccountedDate__c == null && newShipment.CreatedDate != null) {
            newShipment.SalesAccountedDate__c = Date.newInstance(newShipment.CreatedDate.year(), newShipment.CreatedDate.month(), newShipment.CreatedDate.day());
        }
        // 2021/08/19 Chien Truong DELETE END
    }

    private void updateTransitInfo(CustomObject1__c newShipment, CustomObject1__c oldShipment) {
        Integer newLocations = (StringUtils.isEmpty(newShipment.MultiTransitRequired__c) || 'NO'.equalsIgnoreCase(newShipment.MultiTransitRequired__c) ? 0 : Integer.valueOf(newShipment.MultiTransitRequired__c));
        Integer oldLocations = (StringUtils.isEmpty(oldShipment.MultiTransitRequired__c) || 'NO'.equalsIgnoreCase(oldShipment.MultiTransitRequired__c) ? 0 : Integer.valueOf(oldShipment.MultiTransitRequired__c));

        if (oldLocations > newLocations && newLocations > 0) {
            List<Transit__c> transits = mapShipmentsWithChildren.get(newShipment.Id).TRANSIT__r;

            if (transits != null && !transits.isEmpty()) {
                Transit__c transit = transits.get(newLocations - 1);

                newShipment.T_ETD__c = transit.ETDAtTransitPort__c;
                newShipment.ETAAtTransitPort__c = transit.ETAAtTransitPort__c;
                newShipment.TransitV__c = transit.TransitVesselFlight__c;
                newShipment.SwitchB_L__c = transit.SwitchHBL__c;

                if (transit.TransitPort__c != null) {
                    Port__c port = mapPorts.get(transit.TransitPort__c);

                    if (port != null) {
                        newShipment.TS__c = port.Name;
                    }
                }
            }
        } else if (newLocations == 0) {
            newShipment.T_ETD__c = null;
            newShipment.ETAAtTransitPort__c = null;
            newShipment.TransitV__c = null;
            newShipment.SwitchB_L__c = null;
            newShipment.TS__c = null;
        }
    }
}