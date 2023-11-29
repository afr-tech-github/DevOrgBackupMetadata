public with sharing class CargoDeliveryTriggerHandler extends AbstractTriggerHandler {
    private Map<Id, CustomObject1__c> mapParentShipments = new Map<Id, CustomObject1__c>();
    private Set<CustomObject1__c> toBeUpdatedShipments = new Set<CustomObject1__c>();
    private static TranslationService translationService;

    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }

    public override String getHandlerName() {
        return 'CargoDeliveryTriggerHandler';
    }

    public override void bulkBefore() {
        loadParentShipments();
    }

    public override void bulkAfter() {
        loadParentShipments();
    }

    public override void beforeInsert(SObject so) {
        Cargo_Delivery__c cd = (Cargo_Delivery__c) so;

        if (!validate(cd)) {
            return;
        }
    }

    public override void afterInsert(SObject so) {
        Cargo_Delivery__c cd = (Cargo_Delivery__c) so;

        if (!TriggerExecutionHelper.isRunning('HBLShipmentsTriggerHandler')) {
            addCargoDeliveryToHBL(cd.HBL_SHIPMENT__c);
        }
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        Cargo_Delivery__c newCD = (Cargo_Delivery__c) so;

        if (!validate(newCD)) {
            return;
        }
    }

    public override void afterUpdate(SObject oldSo, SObject so) {
        Cargo_Delivery__c newCD = (Cargo_Delivery__c) so;
        Cargo_Delivery__c oldCD = (Cargo_Delivery__c) oldSo;

        if (oldCD.HBL_SHIPMENT__c != newCD.HBL_SHIPMENT__c) {
            addCargoDeliveryToHBL(newCD.HBL_SHIPMENT__c);
            removeCargoDeliveryFromHBL(oldCD.HBL_SHIPMENT__c);
        }

        if (newCD.DeliveryDate__c != null) {
            updateHBLDeliveryDate(newCD);
        }
    }

    public override void afterDelete(SObject so) {
        Cargo_Delivery__c cd = (Cargo_Delivery__c) so;

        if (!TriggerExecutionHelper.isRunning('HBLShipmentsTriggerHandler')) {
            removeCargoDeliveryFromHBL(cd.HBL_SHIPMENT__c);
        }
    }

    public override void andFinally() {
        if (toBeUpdatedShipments.size() > 0) {
		    FlsService.doUpdate(new List<CustomObject1__c>(toBeUpdatedShipments));
        }
    }

    private void loadParentShipments() {
        Set<Id> parentId = new Set<Id>();
        Set<Cargo_Delivery__c> cds = new Set<Cargo_Delivery__c>();

        if (Trigger.IsInsert) {
            cds.addAll((List<Cargo_Delivery__c>) Trigger.new);
        } else if (Trigger.IsUpdate) {
            cds.addAll((List<Cargo_Delivery__c>) Trigger.new);
            cds.addAll((List<Cargo_Delivery__c>) Trigger.old);
        } else if (Trigger.IsDelete) {
            cds.addAll((List<Cargo_Delivery__c>) Trigger.old);
        }

        for (Cargo_Delivery__c cd : cds) {
            parentId.add(cd.HBL_SHIPMENT__c);
        }

        mapParentShipments = new Map<Id, CustomObject1__c>([
                SELECT Id, DeliveryService_required__c, RecordTypeId, ETD__c, T_ETD__c,
                        ETA__c, CustomsReleaseDay__c, CutDay__c, (SELECT Id, Pickupdate__c, DeliveryDate__c FROM Cargo_Delivery__r),
                        (SELECT Id, Customs_Release_Day__c FROM Custom_Clearance__r)
                FROM CustomObject1__c
                WHERE Id IN :parentId
        ]);
    }

    private void addCargoDeliveryToHBL(Id shipmentId) {
        CustomObject1__c shipment = mapParentShipments.get(shipmentId);

        if (shipment != null) {
            String delieryLocations = LegacyResourceUtils.getHBLDeliveryServiceRequired(shipment.DeliveryService_required__c);
            Integer locations = (StringUtils.isEmpty(delieryLocations) ? 0 : Integer.valueOf(delieryLocations));

            locations++;
            shipment.DeliveryService_required__c = String.valueOf(locations);
            toBeUpdatedShipments.add(shipment);
        }
    }

    private void removeCargoDeliveryFromHBL(Id shipmentId) {
        CustomObject1__c shipment = mapParentShipments.get(shipmentId);

        if (shipment != null) {
            String deliveryLocations = LegacyResourceUtils.getHBLDeliveryServiceRequired(shipment.DeliveryService_required__c);
            Integer locations = (StringUtils.isEmpty(deliveryLocations) ? 0 : Integer.valueOf(deliveryLocations));

            if (locations > 0) {
                locations--;
                shipment.DeliveryService_required__c = String.valueOf(locations);
                toBeUpdatedShipments.add(shipment);
            }
        }
    }

    private boolean isValidRecordType(Cargo_Delivery__c cd) {
        // 2019/08/13 Chien Truong DELETE START
        /*
        CustomObject1__c shipment = mapParentShipments.get(cd.HBL_SHIPMENT__c);
        String recordTypeName = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);

        if (Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(recordTypeName) || Constants.DOMESTIC_TRANSPORTATION_LOCK_RT.equalsIgnoreCase(recordTypeName)
           || Constants.CROSS_BOARDER_RT.equalsIgnoreCase(recordTypeName) || Constants.CROSS_BOARDER_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
            return true;
        }
        boolean isImportHBL = ObjectClassificationUtils.isImportHBL(shipment);
        boolean isExportHBL = ObjectClassificationUtils.isExportHBL(shipment);
        boolean isImportCargo = ObjectClassificationUtils.isImportCargoDelivery(cd.RecordTypeId);
        boolean isExportCargo = ObjectClassificationUtils.isExportCargoDelivery(cd.RecordTypeId);

        if ((isImportHBL && isImportCargo) || (isExportHBL && isExportCargo)) {
            return true;
        }

        return false;
        */
        // 2019/08/13 Chien Truong DELETE END

        // 2019/08/13 Chien Truong ADD START
        return true;
        // 2019/08/13 Chien Truong ADD END
    }

    private boolean validate(Cargo_Delivery__c cd) {
        boolean result = true;

        if (!isValidRecordType(cd)) {
            cd.addError(translationService.getTranslation(Constants.INVALID_RECORD_TYPE));
            result = false;
        } else {
            CustomObject1__c shipment = mapParentShipments.get(cd.HBL_SHIPMENT__c);
            List<Cargo_Delivery__c> cds = shipment.Cargo_Delivery__r;
            if (cd.Id == null) {
                cds.add(cd);
            } else {
                for (Cargo_Delivery__c cargo : cds) {
                    if (cd.Id == cargo.Id) {
                        cargo.Pickupdate__c = cd.Pickupdate__c;
                        cargo.DeliveryDate__c = cd.DeliveryDate__c;
                    }
                }
            }

            String errorMessage = ValidationUtils.validateDeliveryDates(shipment, cds, shipment.Custom_Clearance__r);
            if (!Stringutils.isEmpty(errorMessage)) {
                cd.addError(translationService.getTranslation(errorMessage));
                result = false;
            }
        }

        return result;
    }

    private void updateHBLDeliveryDate(Cargo_Delivery__c cd) {
        CustomObject1__c shipment = mapParentShipments.get(cd.HBL_SHIPMENT__c);
        List<Cargo_Delivery__c> cds = shipment.Cargo_Delivery__r;
        cds.add(cd);

        Date minDeliveryDate = ValidationUtils.getAggregateDateForCargo(cds, 'DeliveryDate__c', ValidationUtils.AGGREGATE_MIN);
        if (minDeliveryDate != null) {
            shipment.DeliveryDate__c = minDeliveryDate;
            toBeUpdatedShipments.add(shipment);
        }
    }
}