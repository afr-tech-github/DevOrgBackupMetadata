/**
 * Created by khanhpham on 6/14/17.
 */

public with sharing class MassiveEditController {
    public static final String CARGO_DELIVERY_OBJECT = 'cargodelivery';
    public static final String LOADING_LOCATION_OBJECT = 'loadinglocation';
    public static final String PURCHASING_INVOICE_OBJECT = 'purchasinginvoice';
    public static final String CONSOL_BUYING_OBJECT = 'consolbuying';
    public static final String INVOICING_VAT_OBJECT = 'invoicingvat';
    public static final String SHIPMENT_VAT_OBJECT = 'shipmentvat';
    public static final String EXCHANGE_RATE_OBJECT = 'exchangerate';
    public String objectName { get; private set; }
    public List<Cargo_Delivery__c> cargoDeliveryList { get; set; }
    public List<Cargo_Delivery__c> originalCargoDeliveryList { get; set; }
    public List<LoadingLocation__c> loadingLocationList { get; set; }
    public List<PurchasingInvoice__c> purchasingInvoiceList { get; set; }
    public List<MasterAnkenMeisai__c> consolBuyngList { get; set; }
    public List<INVOICING_VAT__c> invoicingVATList { get; set; }
    public List<FORWARDING_VAT__c> shipmentVATList { get; set; }
    public List<MgmtMaster__c> exchangeRateList { get; set; }
    public Map<String, String> translations { get; private set; }
    public Boolean isCreation { get; private set; }
    public String numberOfRecords { get; set; }
    private String parentId;

    public void init() {
        
        this.objectName = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('obj'));
        this.parentId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
        final String action = ApexPages.currentPage().getParameters().get('action');
		
        if (String.isNotBlank(action) && 'new'.equalsIgnoreCase(action)) {
            isCreation = true;
            
            numberOfRecords = null;
        } else {
            isCreation = false;
        }

        if (isCreation) {
            if (CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName)) {
                cargoDeliveryList = new List<Cargo_Delivery__c>();
            } else if (LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName)) {
                loadingLocationList = new List<LoadingLocation__c>();
            } else if (PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName)) {
                purchasingInvoiceList = new List<PurchasingInvoice__c>();
            } else if (CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName)) {
                consolBuyngList = new List<MasterAnkenMeisai__c>();
            } else if (INVOICING_VAT_OBJECT.equalsIgnoreCase(objectName)) {
                invoicingVATList = new List<INVOICING_VAT__c>();
            } else if (SHIPMENT_VAT_OBJECT.equalsIgnoreCase(objectName)) {
                shipmentVATList = new List<FORWARDING_VAT__c>();
            }
        } else {
            System.debug('abcz ' + objectName);
            System.debug('abczv ' + PermissionValidationUtil.isAccessibleHBL());
            if (CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName) && PermissionValidationUtil.isAccessibleHBL()) {
                getCargoDeliveryList();
                originalCargoDeliveryList = cargoDeliveryList.deepClone();
            } else if (LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName) && PermissionValidationUtil.isAccessibleRoute()) {
                getLoadingLocationList();
            } else if (PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName) && PermissionValidationUtil.isAccessiblePurchasingOrder()) {
                getPurchasingInvoiceList();
            } else if (CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName) && PermissionValidationUtil.isAccessibleHBLBuying()) {
                getConsolBuyingList();
            } else if (EXCHANGE_RATE_OBJECT.equalsIgnoreCase(objectName) && PermissionValidationUtil.isAccessibleExchangeRate()) {
                getExchangeRateList();
            }
        }

        initializeTranslation();
    }

    public Boolean isCargoDelivery {
        get {
            return CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public Boolean isLoadingLocation {
        get {
            return LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public Boolean isPurchasingInvoice {
        get {
            return PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public Boolean isConsolBuying {
        get {
            return CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public Boolean isInvoicingVAT {
        get {
            return INVOICING_VAT_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public Boolean isShipmentVAT {
        get {
            return SHIPMENT_VAT_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public Boolean isExchangeRate {
        get {
            return EXCHANGE_RATE_OBJECT.equalsIgnoreCase(objectName);
        }
    }

    public void createNewRecords() {
                  
        if (isCreation && String.isNotBlank(numberOfRecords) && numberOfRecords.isNumeric() && Integer.valueOf(numberOfRecords) > 0) {
            Integer numOfRecords = Integer.valueOf(numberOfRecords);
            Integer numOfExistingRecords = getNumberOfExistingRecords();

            if (numOfExistingRecords > 0) {
                numOfRecords -= numOfExistingRecords;
            }

            if (numOfRecords > 0) {
                addNewRecords(numOfRecords);
            } else {
                numOfRecords *= (-1);

                if (numOfRecords <= numOfExistingRecords) {
                    removeExistingRecords(numOfRecords);
                }
            }
        }
    }

    public PageReference updateRecords() {
        try {
            if (CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName) && !cargoDeliveryList.isEmpty()) {
                upsertCargoDeliveries();
            } else if (LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName) && !loadingLocationList.isEmpty()) {
                upsertLoadingLocations();
            } else if (PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName) && !purchasingInvoiceList.isEmpty()) {
                upsertPurchasingInvoices();
            } else if (CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName) && !consolBuyngList.isEmpty()) {
                upsertConsolBuyings();
            } else if (INVOICING_VAT_OBJECT.equalsIgnoreCase(objectName) && !invoicingVATList.isEmpty()) {
                upsertInvoicingVAT();
            } else if (SHIPMENT_VAT_OBJECT.equalsIgnoreCase(objectName) && !shipmentVATList.isEmpty()) {
                upsertShipmentVAT();
            } else if (EXCHANGE_RATE_OBJECT.equalsIgnoreCase(objectName) && !exchangeRateList.isEmpty()) {
                updateExchangeRate();
            }

            if (!StringUtils.isEmpty(parentId)) {
                return goToParent();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, translations.get('OPERATION_SUCCESS')));
            }
        } catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }

    public PageReference cancel() {
        return goToParent();
    }

    public void populateDeliveryDestinationInfos() {
        populateDeliveryDestinationInfos(false);
    }

    public void populateContainerIDForCargoDelivery() {
        populateDeliveryDestinationInfos(true);
    }

    public void resetCargoDeliveries() {
		System.debug('originalCargoDeliveryList' + originalCargoDeliveryList);
        if (originalCargoDeliveryList != null && !originalCargoDeliveryList.isEmpty()) {
            Integer size = cargoDeliveryList.size();

            for (Integer index = 0; index < size; index++) {
                cargoDeliveryList.get(index).CONTAINER_ID__c = originalCargoDeliveryList.get(index).CONTAINER_ID__c;
                cargoDeliveryList.get(index).OUR_TRUCK_FLEET__c = originalCargoDeliveryList.get(index).OUR_TRUCK_FLEET__c;
                cargoDeliveryList.get(index).DeliveryCompany__c = originalCargoDeliveryList.get(index).DeliveryCompany__c;
                cargoDeliveryList.get(index).DeliveryType__c = originalCargoDeliveryList.get(index).DeliveryType__c;
                cargoDeliveryList.get(index).TRUCKING_COMPANY_PIC__c = originalCargoDeliveryList.get(index).TRUCKING_COMPANY_PIC__c;
                cargoDeliveryList.get(index).Packing_Type__c = originalCargoDeliveryList.get(index).Packing_Type__c;
                cargoDeliveryList.get(index).DeliveryNote__c = originalCargoDeliveryList.get(index).DeliveryNote__c;
                cargoDeliveryList.get(index).Pickupdate__c = originalCargoDeliveryList.get(index).Pickupdate__c;
                cargoDeliveryList.get(index).EXPECTED_PICKUP_TIME__c = originalCargoDeliveryList.get(index).EXPECTED_PICKUP_TIME__c;
                cargoDeliveryList.get(index).DeliveryTime__c = originalCargoDeliveryList.get(index).DeliveryTime__c;
                cargoDeliveryList.get(index).DeliveryDate__c = originalCargoDeliveryList.get(index).DeliveryDate__c;
                cargoDeliveryList.get(index).AddressForAccept__c = originalCargoDeliveryList.get(index).AddressForAccept__c;
                cargoDeliveryList.get(index).PersonInChargeForAccept__c = originalCargoDeliveryList.get(index).PersonInChargeForAccept__c;
                cargoDeliveryList.get(index).ReceiverContact__c = originalCargoDeliveryList.get(index).ReceiverContact__c;
                cargoDeliveryList.get(index).Destination__c = originalCargoDeliveryList.get(index).Destination__c;
                cargoDeliveryList.get(index).Destinationaddress__c = originalCargoDeliveryList.get(index).Destinationaddress__c;
                cargoDeliveryList.get(index).DeliveryPhone__c = originalCargoDeliveryList.get(index).DeliveryPhone__c;
                cargoDeliveryList.get(index).ReceiverRep__c = originalCargoDeliveryList.get(index).ReceiverRep__c;
                cargoDeliveryList.get(index).Receiver__c = originalCargoDeliveryList.get(index).Receiver__c;
            }
        }
    }

    private void populateDeliveryDestinationInfos(Boolean idOnly) {
        if (!PermissionValidationUtil.isAccessibleHBL()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            return;
        }

        List<Container_Info__c> containerInfos = [SELECT Id FROM Container_Info__c WHERE HBL_SHIPMENT__c = :parentId];

        if (!containerInfos.isEmpty() && !cargoDeliveryList.isEmpty() && cargoDeliveryList.size() <= containerInfos.size()) {
            Integer size = cargoDeliveryList.size();

            for (Integer index = 0; index < size; index++) {
                if (!idOnly && index > 0) {
                    cargoDeliveryList.get(index).OUR_TRUCK_FLEET__c = cargoDeliveryList.get(0).OUR_TRUCK_FLEET__c;
                    cargoDeliveryList.get(index).DeliveryCompany__c = cargoDeliveryList.get(0).DeliveryCompany__c;
                    cargoDeliveryList.get(index).DeliveryType__c = cargoDeliveryList.get(0).DeliveryType__c;
                    cargoDeliveryList.get(index).TRUCKING_COMPANY_PIC__c = cargoDeliveryList.get(0).TRUCKING_COMPANY_PIC__c;
                    cargoDeliveryList.get(index).Packing_Type__c = cargoDeliveryList.get(0).Packing_Type__c;
                    cargoDeliveryList.get(index).DeliveryNote__c = cargoDeliveryList.get(0).DeliveryNote__c;
                    cargoDeliveryList.get(index).Pickupdate__c = cargoDeliveryList.get(0).Pickupdate__c;
                    cargoDeliveryList.get(index).EXPECTED_PICKUP_TIME__c = cargoDeliveryList.get(0).EXPECTED_PICKUP_TIME__c;
                    cargoDeliveryList.get(index).DeliveryTime__c = cargoDeliveryList.get(0).DeliveryTime__c;
                    cargoDeliveryList.get(index).DeliveryDate__c = cargoDeliveryList.get(0).DeliveryDate__c;
                    cargoDeliveryList.get(index).AddressForAccept__c = cargoDeliveryList.get(0).AddressForAccept__c;
                    cargoDeliveryList.get(index).PersonInChargeForAccept__c = cargoDeliveryList.get(0).PersonInChargeForAccept__c;
                    cargoDeliveryList.get(index).ReceiverContact__c = cargoDeliveryList.get(0).ReceiverContact__c;
                    cargoDeliveryList.get(index).Destination__c = cargoDeliveryList.get(0).Destination__c;
                    cargoDeliveryList.get(index).Destinationaddress__c = cargoDeliveryList.get(0).Destinationaddress__c;
                    cargoDeliveryList.get(index).DeliveryPhone__c = cargoDeliveryList.get(0).DeliveryPhone__c;
                    cargoDeliveryList.get(index).ReceiverRep__c = cargoDeliveryList.get(0).ReceiverRep__c;
                    cargoDeliveryList.get(index).Receiver__c = cargoDeliveryList.get(0).Receiver__c;
                }

                cargoDeliveryList.get(index).CONTAINER_ID__c = containerInfos.get(index).Id;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The number of Container Info is not sufficient for Cargo Delivery destinations'));
        }
    }

    private Integer getNumberOfExistingRecords() {
        if (CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName)) {
            return cargoDeliveryList.size();
        } else if (LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName)) {
            return loadingLocationList.size();
        } else if (PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName)) {
            return purchasingInvoiceList.size();
        } else if (CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName)) {
            return consolBuyngList.size();
        } else if (INVOICING_VAT_OBJECT.equalsIgnoreCase(objectName)) {
            return invoicingVATList.size();
        } else if (SHIPMENT_VAT_OBJECT.equalsIgnoreCase(objectName)) {
            return shipmentVATList.size();
        }

        return 0;
    }

    private void addNewRecords(Integer numberOfRecords) {
        for (Integer i = 0; i < numberOfRecords; i++) {
            if (CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName)) {
                cargoDeliveryList.add(new Cargo_Delivery__c());
            } else if (LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName)) {
                loadingLocationList.add(new LoadingLocation__c());
            } else if (PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName)) {
                PurchasingInvoice__c pi = new PurchasingInvoice__c();
                pi.PurchasingOrder__c = parentId;
                purchasingInvoiceList.add(pi);
            } else if (CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName)) {
                MasterAnkenMeisai__c consolBuying = new MasterAnkenMeisai__c();
                consolBuying.MasterAnken__c = parentId;
                consolBuyngList.add(consolBuying);
            } else if (INVOICING_VAT_OBJECT.equalsIgnoreCase(objectName)) {
                INVOICING_VAT__c invoicingVAT = new INVOICING_VAT__c();
                invoicingVAT.VAT_INVOICE__c = parentId;
                invoicingVATList.add(invoicingVAT);
            } else if (SHIPMENT_VAT_OBJECT.equalsIgnoreCase(objectName)) {
                FORWARDING_VAT__c shipmentVAT = new FORWARDING_VAT__c();
                shipmentVAT.VAT_INVOICE__c = parentId;
                shipmentVATList.add(shipmentVAT);
            }
        }
    }

    private void removeExistingRecords(Integer numberOfRecords) {
        for (Integer i = 0; i < numberOfRecords; i++) {
            if (CARGO_DELIVERY_OBJECT.equalsIgnoreCase(objectName)) {
                cargoDeliveryList.remove(numberOfRecords - i - 1);
            } else if (LOADING_LOCATION_OBJECT.equalsIgnoreCase(objectName)) {
                loadingLocationList.remove(numberOfRecords - i - 1);
            } else if (PURCHASING_INVOICE_OBJECT.equalsIgnoreCase(objectName)) {
                purchasingInvoiceList.remove(numberOfRecords - i - 1);
            } else if (CONSOL_BUYING_OBJECT.equalsIgnoreCase(objectName)) {
                consolBuyngList.remove(numberOfRecords - i - 1);
            } else if (INVOICING_VAT_OBJECT.equalsIgnoreCase(objectName)) {
                invoicingVATList.remove(numberOfRecords - i - 1);
            }
        }
    }

    private void upsertPurchasingInvoices() {
        if (isCreation) {
            if (!purchasingInvoiceList.isEmpty() && PermissionValidationUtil.isCreatablePurchasingOrder()) {
                FlsService.doInsert(purchasingInvoiceList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        } else {
            if (!purchasingInvoiceList.isEmpty() && PermissionValidationUtil.isEditablePurchasingOrder()) {
			    FlsService.doUpdate(purchasingInvoiceList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        }
    }

    private void upsertCargoDeliveries() {
        if (isCreation) {
            if (!cargoDeliveryList.isEmpty() && PermissionValidationUtil.isCreatableHBL()) {
                FlsService.doInsert(cargoDeliveryList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        } else {
            if (!cargoDeliveryList.isEmpty() && PermissionValidationUtil.isEditableHBL()) {
			    FlsService.doUpdate(cargoDeliveryList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        }
    }

    private void upsertLoadingLocations() {
        if (isCreation) {
            if (!loadingLocationList.isEmpty() && PermissionValidationUtil.isCreatableRoute()) {
                FlsService.doInsert(loadingLocationList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        } else {
            if (!loadingLocationList.isEmpty() && PermissionValidationUtil.isEditableRoute()) {
			    FlsService.doUpdate(loadingLocationList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        }
    }

    private void upsertConsolBuyings() {
        if (isCreation) {
            if (!consolBuyngList.isEmpty() && PermissionValidationUtil.isCreatableMBLBuying()) {
                FlsService.doInsert(consolBuyngList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        } else {
            if (!consolBuyngList.isEmpty() && PermissionValidationUtil.isEditableMBLBuying()) {
			    FlsService.doUpdate(consolBuyngList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        }
    }

    private void upsertInvoicingVAT() {
        if (isCreation) {
            if (!invoicingVATList.isEmpty() && PermissionValidationUtil.isCreatableHBLBuying() && PermissionValidationUtil.isCreatableVATInvoice()) {
                FlsService.doInsert(invoicingVATList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        }
    }

    private void upsertShipmentVAT() {
        if (isCreation) {
            if (!shipmentVATList.isEmpty() && PermissionValidationUtil.isCreatableHBL() && PermissionValidationUtil.isCreatableVATInvoice()) {
                FlsService.doInsert(shipmentVATList);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
            }
        }
    }

    private void updateExchangeRate() {
        if (!exchangeRateList.isEmpty() && PermissionValidationUtil.isEditableExchangeRate()) {
            FlsService.doUpdate(exchangeRateList);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
        }
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('MassiveUpdate', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    private PageReference goToParent() {
        PageReference page = null;

        if (!StringUtils.isEmpty(parentId)) {
            page = new PageReference('/' + parentId);
            page.setRedirect(true);
        }

        return page;
    }

    private void getCargoDeliveryList() {
        List<String> queryFieldList = getCargoDeliveryFields();
        String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                + ' FROM Cargo_Delivery__c'
                + ' WHERE HBL_SHIPMENT__r.Id = \'' + parentId + '\'';

        cargoDeliveryList = Database.query(queryString);
    }

    private List<String> getCargoDeliveryFields() {
        List<String> queryFieldList = new List<String>();
        queryFieldList.add('Id');
        queryFieldList.add('Name');
        queryFieldList.add('RecordTypeId');
        queryFieldList.addAll(Util.getObjectCustomFields(Cargo_Delivery__c.SObjectType));

        return queryFieldList;
    }

    private void getLoadingLocationList() {
        List<String> queryFieldList = getLoadingLocationFields();
        String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                + ' FROM LoadingLocation__c WHERE Route__r.Id = \'' + parentId + '\'';

        loadingLocationList = Database.query(queryString);
    }

    private List<String> getLoadingLocationFields() {
        List<String> queryFieldList = new List<String>();
        queryFieldList.add('Id');
        queryFieldList.add('Name');
        queryFieldList.addAll(Util.getObjectCustomFields(LoadingLocation__c.SObjectType));

        return queryFieldList;
    }

    private void getPurchasingInvoiceList() {
        List<String> queryFieldList = getPurchasingInvoiceFields();
        String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                + ' FROM PurchasingInvoice__c WHERE PurchasingOrder__r.Id = \'' + parentId + '\'';

        purchasingInvoiceList = Database.query(queryString);
    }

    private List<String> getPurchasingInvoiceFields() {
        List<String> queryFieldList = new List<String>();
        queryFieldList.add('Id');
        queryFieldList.add('Name');
        queryFieldList.addAll(Util.getObjectCustomFields(PurchasingInvoice__c.SObjectType));

        return queryFieldList;
    }

    private void getConsolBuyingList() {
        List<String> queryFieldList = getConsolBuyingFields();
        String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                + ' FROM MasterAnkenMeisai__c WHERE MasterAnken__r.Id = \'' + parentId + '\'';

        consolBuyngList = Database.query(queryString);
    }

    private List<String> getConsolBuyingFields() {
        List<String> queryFieldList = new List<String>();
        queryFieldList.add('Id');
        queryFieldList.add('Name');
        queryFieldList.addAll(Util.getObjectCustomFields(MasterAnkenMeisai__c.SObjectType));

        return queryFieldList;
    }

    private void getExchangeRateList() {
        List<String> queryFieldList = getExchangeRateFields();
        String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                + ' FROM MgmtMaster__c';

        exchangeRateList = Database.query(queryString);
    }

    private List<String> getExchangeRateFields() {
        List<String> queryFieldList = new List<String>();
        queryFieldList.add('Id');
        queryFieldList.add('Name');
        queryFieldList.addAll(Util.getObjectCustomFields(MgmtMaster__c.SObjectType));

        return queryFieldList;
    }
}