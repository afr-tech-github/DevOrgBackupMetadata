public with sharing class ContainerInfoService {
    private static Map<String, String> mapContainerTypeToCode = new Map<String, String>();
    private static Map<String, String> mapContainerTypeToSize = new Map<String, String>();
    private static Map<String, String> appSettings = new Map<String, String>();
    private static final String CONTAINER_INFO_APPLIED_DATE = 'CONTAINER_INFO_APPLIED_DATE';
    private static TranslationService translationService;

    static {
        loadContainerInfoMappings();
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }

    public List<Container_Info__c> populateContainerInfoByType(String hblShipmentId, Set<Container_Info__c> existingContainers,
            String containerType, Integer numOfContainers) {
        Integer existingCount = 0;
        List<Container_Info__c> containers = new List<Container_Info__c>();

        if (numOfContainers > 0) {
            for (Container_Info__c container : existingContainers) {
                if (existingCount == numOfContainers) {
                    break;
                }

                if (containerType.equalsIgnoreCase(container.Container__c)) {
                    existingContainers.remove(container);
                    String containerNo = container.Container_NO__c;
                    if (containerNo != null) {
                        container.Container_NO__c = containerNo.toUpperCase();
                    }

                    container.Bypass_Container_Type_Check__c = true;
                    containers.add(container);
                    existingCount++;
                }
            }

            createContainers(hblShipmentId, containerType, numOfContainers - existingCount, containers);
        }

        return containers;
    }

    public void createContainers(String hblShipmentId, String containerType, Integer numOfContainersToAdd,
            List<Container_Info__c> containers) {
        if (numOfContainersToAdd > 0) {
            for (Integer i = 0; i < numOfContainersToAdd; i++) {
                Container_Info__c container = new Container_Info__c();
                container.HBL_SHIPMENT__c = hblShipmentId;
                container.Container__c = containerType;
                container.Bypass_Container_Type_Check__c = true;

                if (mapContainerTypeToCode.containsKey(containerType)) {
                    container.Container_Type_Code__c = mapContainerTypeToCode.get(containerType);
                }

                if (mapContainerTypeToSize.containsKey(containerType)) {
                    container.Container_Size_Code__c = mapContainerTypeToSize.get(containerType);
                }

                containers.add(container);
            }
        }
    }

    private static void loadContainerInfoMappings() {
        List<CONTAINER_INFO_MAPPINGS__c> settings = [
                SELECT Type__c, Code__c, Size__c
                FROM CONTAINER_INFO_MAPPINGS__c
                WHERE Code__c != null
        ];

        for (CONTAINER_INFO_MAPPINGS__c setting : settings) {
            if (setting.Code__c != null) {
                mapContainerTypeToCode.put(setting.Type__c, setting.Code__c);
            }

            if (setting.Size__c != null) {
                mapContainerTypeToSize.put(setting.Type__c, setting.Size__c);
            }
        }
    }

    public static boolean isValidContainerNo(String containerNo) {
        if (containerNo != null) {
            Integer numOfDigits = RegExUtils.countDigitOccurrences(containerNo);
            Integer numOfAlphas = RegExUtils.countAlphabetCharacterOccurrences(containerNo);

            if (numOfDigits != 7 || numOfAlphas != 4) {
                return false;
            }
        }

        return true;
    }

    public static boolean isDuplicatedContainer(List<Container_Info__c> containers) {
        System.debug('=======containers: ' + containers);
        List<Container_Info__c> clonedContainers = containers.clone();

        // for (Container_Info__c ci : containers) {
        //     for (Container_Info__c clonedCI : containers) {
        //         if ((
        //             ci.Id != clonedCI.Id) 
        //             && (
        //                 (!StringUtils.isEmpty(ci.Container_No__c) && ci.Container_No__c == clonedCI.Container_No__c)
        //                 ////[2019-01-24][Tan Phan] Seal No is no longer requried to be unique to avoid complication for some clients
        //                 //|| (!StringUtils.isEmpty(ci.Seal_No__c) && ci.Seal_No__c == clonedCI.Seal_No__c)
        //             )
        //         ) 
        //         {
        //             return true;
        //         }
        //     }
        // }

        // return false;

        // Nga Do
        Map<String, List<String>> mapContainerNo = new Map<String, List<String>>();
        for(Container_Info__c ct :containers ){
            if(!mapContainerNo.containsKey(ct.Container_No__c) && ct.Container_No__c != null){
                mapContainerNo.put(ct.Container_No__c, new List<String>{ct.Id});
            }else{
                /*if(mapContainerNo.get(ct.Container_No__c)[0] == null && ct.Id == null){
                    return true;
                }*/
                if(mapContainerNo.get(ct.Container_No__c) != null && ct.Id != mapContainerNo.get(ct.Container_No__c)[0]){
                    return true;
                }
            }
        }
        return false;
    }

    public static void validate(List<Container_Info__c> existingContainers, Container_Info__c container) {
        if (!isValidContainerNo(container.Container_NO__c)) {
            //container.addError(translationService.getTranslation(Constants.INVALID_CONTAINER_NO));
        }

        if (!StringUtils.isEmpty(container.Container__c)) {
//            List<Container_Info__c> existingContainers = shipment.Container_Info__r;

            if (existingContainers != null && !existingContainers.isEmpty()) {
                // validate uniqueness of Container No and Seal No
                List<Container_Info__c> allContainers = new List<Container_Info__c>();
                allContainers.addAll(existingContainers);
                allContainers.add(container);

                if (isDuplicatedContainer(allContainers)) {
                    container.addError(translationService.getTranslation(Constants.DUPLICATED_CONTAINER_NO));
                    return;
                }

                // validate container types limitation
                Set<String> containerTypes = new Set<String>();
                containerTypes.add(container.Container__c);

                for (Container_Info__c ci : existingContainers) {
                    if (ci.Container__c != null && ci.Id != container.Id) {
                        containerTypes.add(ci.Container__c);
                    }
                }
				
                // 2019/07/31 Chien Truong MODIFY START
                //if (containerTypes.size() > 4) {
                if (containerTypes.size() > 7) {
                // 2019/07/31 Chien Truong MODIFY end
                    container.addError(translationService.getTranslation(Constants.EXCEEDED_NUM_CONTAINERS));
                }
            }
        }
    }

    public static void resetHBLContainerInfo(CustomObject1__c hbl, List<Container_Info__c> containerInfos) {
        Map<String, Integer> numOfContainersByType = new Map<String, Integer>();
        String containerSealNo = '';
        String containerDetails = '';
        String containerDetailsOnSL = '';
        String containerNLF = '';
        String containerTLF = '';
        // 2019/07/11 Chien Truong ADD START
        String containerDetails2 = '';
        String containerDetailsOnSL2 = '';
        // 2019/07/11 Chien Truong ADD END
        Decimal totalPackages = 0;
        Decimal totalNetWeitght = 0;
        Decimal totalGrossWeigth = 0;
        Decimal totalMeasurement = 0;

        if (containerInfos != null && !containerInfos.isEmpty()) {
            for (Container_Info__c container : containerInfos) {
                String containerType = container.Container__c;
                String quantityUnit = container.QUANTITY_PACKAGES__c > 1 ? (hbl.UnitType__c + 's') : hbl.UnitType__c;
                String grossWeightUnit = container.GROSS_WEIGHT__c > 1 ? 'KGS' : 'KG';
                String cbmUnit = 'CBM';

                Decimal quantity = (container.QUANTITY_PACKAGES__c != null ? container.QUANTITY_PACKAGES__c : 0);
                Decimal grossWeigth = (container.GROSS_WEIGHT__c != null ? container.GROSS_WEIGHT__c : 0);
                Decimal cbm = (container.MEASUREMENT_CBM__c != null ? container.MEASUREMENT_CBM__c : 0);

                if (containerType != null) { 
                    containerSealNo += (container.Container_NO__c != null ? container.Container_NO__c.toUpperCase() : '<missing>') + '/'
                            + (container.Seal_No__c != null ? container.Seal_No__c.toUpperCase() : '<missing>') + ' ';
				
                    String numberAndTypeInfo = (container.Container_NO__c != null ? container.Container_NO__c.toUpperCase()+ ' / ' : '') 
                            + (container.Seal_No__c != null ? container.Seal_No__c.toUpperCase()+ ' / ' : '') 
                            + container.Container__c;
                    String measurementInfo = (quantity > 0 ? (quantity + quantityUnit + ' / ') : '')
                            + (grossWeigth > 0 ? (grossWeigth + grossWeightUnit + ' / ') : '')
                            + (cbm > 0 ? (cbm + cbmUnit) : '');
                    String numberAndTypeInfo1 = (container.Container_NO__c != null ? container.Container_NO__c.toUpperCase() + ' / ': '') + container.Container__c;
                    String numberListField = (container.Container_NO__c != null ? container.Container_NO__c.toUpperCase():'');
                    String typeListField = (container.Container__c != null ? container.Container__c.toUpperCase():'');
                    // 2021/07/21 Chien Truong ADD START
                    String quantityUnitNew = '';
                    if (hbl.TakeContainerUnitfromSO__c == 'Yes'){
                        quantityUnitNew = container.QUANTITY_PACKAGES__c > 1 ? (hbl.UnitType__c + 's') : hbl.UnitType__c;
                    } else {
                        quantityUnitNew = container.QUANTITY_PACKAGES__c > 1 ? (container.CargoTypeUnit__c + 's') : container.CargoTypeUnit__c;
                    }
                    // String quantityUnitNew = container.QUANTITY_PACKAGES__c > 1 ? (container.CargoTypeUnit__c + 's') : container.CargoTypeUnit__c;
                    String numberAndTypeInfoNew = (container.Container_NO__c != null ? container.Container_NO__c.toUpperCase()+ ' / ' : '') 
                            + (container.Seal_No__c != null ? container.Seal_No__c.toUpperCase()+ ' / ' : '') 
                            + container.Container__c;
                    String measurementInfoNew = (quantity > 0 ? (quantity + ' ' + quantityUnitNew + ' / ') : '')
                            + (grossWeigth > 0 ? (grossWeigth + grossWeightUnit + ' / ') : '')
                            + (cbm > 0 ? (cbm + cbmUnit) : '');
                    // 2021/07/21 Chien Truong ADD END
					
                    // 2021/07/21 Chien Truong MODIFY START
                    // containerDetails += numberAndTypeInfo + (measurementInfo != '' ? ('/' + measurementInfo + '\n') : '\n');
					containerDetails += numberAndTypeInfoNew + (measurementInfoNew != '' ? (' / ' + measurementInfoNew + '\n') : '\n');
					// 2021/07/21 Chien Truong MODIFY END
					containerNLF += numberListField + '\n';
                    containerTLF += typeListField + '\n';
                    measurementInfo += (container.GOODS__c != null ? (' / ' + container.GOODS__c) : '');
                    containerDetailsOnSL += numberAndTypeInfo + '\n' ;
                    // + (measurementInfo != '' ? (' / ' + measurementInfo + '\n') : '\n');

                    // 2019/07/11 Chien Truong ADD START
                    String measurementInfo2 = (quantity > 0 ? (quantity + ' / ') : '')
                            + (grossWeigth > 0 ? (grossWeigth + ' / ') : '')
                            + (cbm > 0 ? String.valueOf(cbm)  : '');
                    
                    containerDetails2 += numberAndTypeInfo1 + '\n' ;//+ (measurementInfo2 != '' ? ('/' + measurementInfo2 + '\n') : '\n');
                    
                    measurementInfo2 += (container.GOODS__c != null ? (' / ' + container.GOODS__c) : '');
                    containerDetailsOnSL2 += numberAndTypeInfo + (measurementInfo2 != '' ? (' / ' + measurementInfo2 + '\n') : '\n');
                    // 2019/07/11 Chien Truong ADD END

                    if (numOfContainersByType.containsKey(containerType)) {
                        Integer numOfContainers = numOfContainersByType.get(containerType);
                        numOfContainersByType.put(containerType, numOfContainers + 1);
                    } else {
                        numOfContainersByType.put(containerType, 1);
                    }
                }

                totalPackages += quantity;
                totalNetWeitght += (container.NET_WEIGHT__c != null) ? container.NET_WEIGHT__c : 0;
                totalGrossWeigth += grossWeigth;
                totalMeasurement += cbm;
            }
        }
		
        // 2019/07/31 Chien Truong MODIFY START
        // Integer numOfContainerTypes = 4;
         Integer numOfContainerTypes = 7;
        // 2019/07/31 Chien Truong MODIFY END
        for (Integer i = 1; i <= numOfContainerTypes; i++) {
            String containerField = (i == 1 ? 'Container__c' : ('Container' + i + '__c'));
            String containerNumField = (i == 1 ? 'ContainerNumber__c' : ('ContainerNumber' + i + '__c'));
            hbl.put(containerField, null);
            hbl.put(containerNumField, null);
        }

        hbl.ContainerSealNo__c = null;
        List<String> containerTypes = new List<String>(numOfContainersByType.keySet());

        if (!containerTypes.isEmpty()) {
            hbl.ContainerSealNo__c = containerSealNo;
            hbl.Container_Measurement_Details__c = containerDetails;
            hbl.Container_Details_SL__c = containerDetailsOnSL;
            hbl.ContainerNumberList__c = containerNLF;
            hbl.ContainerTypeList__c = containerTLF;
            // 2019/07/11 Chien Truong ADD START
            hbl.ContainerDetailBLType2__c = containerDetails2;
            hbl.ContainerDetailSIType2__c = containerDetailsOnSL2;
            // 2019/07/11 Chien Truong ADD END

            for (Integer i = 0; i < containerTypes.size(); i++) {
                String containerField = (i == 0 ? 'Container__c' : ('Container' + (i + 1) + '__c'));
                String containerNumField = (i == 0 ? 'ContainerNumber__c' : ('ContainerNumber' + (i + 1) + '__c'));

                hbl.put(containerField, containerTypes.get(i));
                hbl.put(containerNumField, numOfContainersByType.get(containerTypes.get(i)));
            }
        }

        hbl.carton__c = (totalPackages > 0) ? totalPackages : hbl.carton__c;
        hbl.NET_NET_Weight__c = (totalNetWeitght > 0) ? totalNetWeitght : hbl.NET_NET_Weight__c;
        hbl.weight__c = (totalGrossWeigth > 0) ? totalGrossWeigth : hbl.weight__c;
        hbl.CBM__c = (totalMeasurement > 0) ? totalMeasurement : hbl.CBM__c;
    }

    public static String extractContainerNo(String containerSealNo) {
        List<String> containerSealNumbers = containerSealNo.split(' ');
        String containerNumbers = '';
        for (String containerSealNumber : containerSealNumbers) {
            List<String> tokens = containerSealNumber.split('/');

            if (tokens.size() > 0) {
                containerNumbers += tokens.get(0) + ' ';
            }
        }

        return containerNumbers;
    }
}