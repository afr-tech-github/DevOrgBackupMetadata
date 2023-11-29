public with sharing class SetupContainerInfoController {
    public String hblShipmentId { get; private set; }
    public CustomObject1__c hblShipment { get; private set; }
    public Integer numberOfContainers { get; private set; }
    public List<Container_Info__c> containers { get; private set; }
    public boolean hasError { get; private set; }
    public boolean enabledSave { get; private set; }
    private ContainerInfoService ciService;
    private static TranslationService translationService;
    public Decimal totalQuantity { get; private set; }
    public Decimal totalMeasurement { get; private set; }
    public Decimal totalNetWeight { get; private set; }
    public Decimal totalGrossWeight { get; private set; }

    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }

    public SetupContainerInfoController() {
        hasError = false;
        enabledSave = true;
        hblShipmentId = ApexPages.currentPage().getParameters().get('parentId');
        ciService = new ContainerInfoService();
		containers = new List<Container_Info__c>();
        if (PermissionValidationUtil.isAccessibleHBL()) {
            loadShipment();
            populateContainerInfo();
            calculateTotalNumbers();
        }
    }

    private void calculateTotalNumbers() {
        totalQuantity = 0;
        totalMeasurement = 0;
        totalNetWeight = 0;
        totalGrossWeight = 0;
        if (containers != null && containers.size() > 0) {
            for (Container_Info__c c : containers) {
                if (c.QUANTITY_PACKAGES__c != null) {
                    totalQuantity += c.QUANTITY_PACKAGES__c;
                }
                if (c.MEASUREMENT_CBM__c != null) {
                    totalMeasurement += c.MEASUREMENT_CBM__c;
                }
                if (c.NET_WEIGHT__c != null) {
                    totalNetWeight += c.NET_WEIGHT__c;
                }
                if (c.GROSS_WEIGHT__c != null) {
                    totalGrossWeight += c.GROSS_WEIGHT__c;
                }
            }
        }
    }

    public void updateTotal() {
        calculateTotalNumbers();
    }

    public PageReference save() {
        hasError = false;

        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isCreatableHBL()
                && PermissionValidationUtil.isEditableHBL()) {
            validateContainerInfo();
            if (hasError) {
                return null;
            }

            ContainerInfoService.resetHBLContainerInfo(hblShipment, hblShipment.Container_Info__r);

            try {
                FlsService.doupsert(containers);
                FlsService.doupdate(hblShipment);
            } catch (Exception e) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
        }

        return gotoHBLShipment();
    }

    public PageReference cancel() {
        return gotoHBLShipment();
    }

    private PageReference gotoHBLShipment() {
        PageReference page = new PageReference('/' + hblShipmentId);
        
        page.setRedirect(true);

        return page;
    }

    private void validateContainerInfo() {
        Set<String> containerTypes = new Set<String>();
        String errorMessage = '';
        if (ContainerInfoService.isDuplicatedContainer(containers)) {
            hasError = true;
            errorMessage = translationService.getTranslation(Constants.NOT_UNIQUE_CONTAINER);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }

        /**
         * A valid Container No must have exactly 4 alphabetical characters and 7 digits.
         * Position of alphabetical characters and digits is not required.
         */
        for (Container_Info__c info : containers) {
            if (!ContainerInfoService.isValidContainerNo(info.Container_No__c)) {
                hasError = true;
                errorMessage = translationService.getTranslation(Constants.INVALID_CONTAINER_NO);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                break;
            }
            containerTypes.add(info.Container__c);
        }
    }

    private void populateContainerInfo() {
        Integer containerNumber = (hblShipment.ContainerNumber__c != null ? Integer.valueOf(hblShipment.ContainerNumber__c) : 0);
        Integer containerNumber2 = (hblShipment.ContainerNumber2__c != null ? Integer.valueOf(hblShipment.ContainerNumber2__c) : 0);
        Integer containerNumber3 = (hblShipment.ContainerNumber3__c != null ? Integer.valueOf(hblShipment.ContainerNumber3__c) : 0);
        Integer containerNumber4 = (hblShipment.ContainerNumber4__c != null ? Integer.valueOf(hblShipment.ContainerNumber4__c) : 0);
        // 2019/07/31 Chien Truong ADD START
        Integer containerNumber5 = (hblShipment.ContainerNumber5__c != null ? Integer.valueOf(hblShipment.ContainerNumber5__c) : 0);
        Integer containerNumber6 = (hblShipment.ContainerNumber6__c != null ? Integer.valueOf(hblShipment.ContainerNumber6__c) : 0);
        Integer containerNumber7 = (hblShipment.ContainerNumber7__c != null ? Integer.valueOf(hblShipment.ContainerNumber7__c) : 0);
        // 2019/07/31 Chien Truong ADD END
        String containerType1 = hblShipment.Container__c;
        String containerType2 = hblShipment.Container2__c;
        String containerType3 = hblShipment.Container3__c;
        String containerType4 = hblShipment.Container4__c;
        // 2019/07/31 Chien Truong ADD START
        String containerType5 = hblShipment.Container5__c;
        String containerType6 = hblShipment.Container6__c;
        String containerType7 = hblShipment.Container7__c;
        // 2019/07/31 Chien Truong ADD END
		
        // 2019/07/31 Chien Truong MODIFY START
        // numberOfContainers = containerNumber + containerNumber2 + containerNumber3 + containerNumber4;
        numberOfContainers = containerNumber + containerNumber2 + containerNumber3 + containerNumber4 + containerNumber5 + containerNumber6 + containerNumber7;
		// 2019/07/31 Chien Truong MODIFY END
		
        if (numberOfContainers < 1) {
            String errorMessage = translationService.getTranslation(Constants.EXCEEDED_NUM_CONTAINERS);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            hasError = true;
            enabledSave = false;
        } else {
            containers = new List<Container_Info__c>();
            List<Container_Info__c> existingContainers = hblShipment.Container_Info__r;
            Set<Container_Info__c> currentContainers = new Set<Container_Info__c>(existingContainers);

            if (containerNumber > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType1, containerNumber));
            }

            if (containerNumber2 > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType2, containerNumber2));
            }

            if (containerNumber3 > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType3, containerNumber3));
            }

            if (containerNumber4 > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType4, containerNumber4));
            }
			
            // 2019/07/31 Chien Truong ADD START
            if (containerNumber5 > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType5, containerNumber5));
            }
            
            if (containerNumber6 > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType6, containerNumber6));
            }
            
            if (containerNumber7 > 0) {
                containers.addAll(ciService.populateContainerInfoByType(hblShipment.Id, currentContainers,
                        containerType7, containerNumber7));
            }
            // 2019/07/31 Chien Truong ADD END
        }
    }

    private void loadShipment() {
        // 2019/07/31 Chien Truong MODIFY START
        /*hblShipment = [
                SELECT Id, Name, CreatedDate, Wkinitial__c, ContainerNumber__c, ContainerNumber2__c, Container__c, Container2__c, TranporationType__c,
                        ContainerNumber3__c, ContainerNumber4__c, Container3__c, Container4__c, Container_Measurement_Details__c, UnitType__c, (
                        SELECT Id, Container_No__c, Seal_No__c, Container__c, Container_Ownership_Code__c,
                                Container_Size_Code__c, Container_Type_Code__c, Empty_Full_Container_Identification__c,
                                QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, MEASUREMENT_CBM__c, NET_WEIGHT__c, GOODS__c
                        FROM Container_Info__r
                        ORDER BY Id
                )
                FROM CustomObject1__c
                WHERE Id = :hblShipmentId
        ];*/
        
        
        hblShipment = [
                SELECT Id, Name, CreatedDate, Wkinitial__c, ContainerNumber__c, ContainerNumber2__c, Container__c, Container2__c, TranporationType__c,
                        ContainerNumber3__c, ContainerNumber4__c, Container3__c, Container4__c, Container_Measurement_Details__c, ContainerNumberList__c, ContainerTypeList__c, UnitType__c,
            			Container5__c, ContainerNumber5__c, Container6__c, ContainerNumber6__c, Container7__c, ContainerNumber7__c, TakeContainerUnitfromSO__c, (
                        SELECT Id, Container_No__c, Seal_No__c, Container__c, Container_Ownership_Code__c,
                                Container_Size_Code__c, Container_Type_Code__c, Empty_Full_Container_Identification__c,
                                QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, MEASUREMENT_CBM__c, NET_WEIGHT__c, GOODS__c, CargoTypeUnit__c
                        FROM Container_Info__r
                        ORDER BY Id
                )
                FROM CustomObject1__c
                WHERE Id = :hblShipmentId
        ];
        // 2019/07/31 Chien Truong MODIFY END
    }
}