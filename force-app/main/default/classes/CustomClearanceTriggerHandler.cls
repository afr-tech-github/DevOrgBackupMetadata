public with sharing class CustomClearanceTriggerHandler extends AbstractTriggerHandler {
    private Set<CustomObject1__c> toBeUpdatedShipments = new Set<CustomObject1__c>();
    private Map<String, CustomObject1__c> mapShipments = new Map<String, CustomObject1__c>();
    private static TranslationService translationService;

    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }

    public override String getHandlerName() {
        return 'CustomClearanceTriggerHandler';
    }

    public override void bulkAfter() {
        loadShipments(Trigger.old);
    }

    public override void bulkBefore() {
        loadShipments(Trigger.old);
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        Custom_Clearance__c cc = (Custom_Clearance__c) so;

        if (!validate(cc)) {
            return;
        }
    }

    public override void afterUpdate(SObject oldSo, SObject so) {
        Custom_Clearance__c oldCC = (Custom_Clearance__c) oldSo;
        Custom_Clearance__c newCC = (Custom_Clearance__c) so;

        if ((newCC.Customs_Release_Day__c != null & oldCC.Customs_Release_Day__c != newCC.Customs_Release_Day__c)
                || (newCC.clofor_com_cfs__CustomerClearance_broker__c != oldCC.clofor_com_cfs__CustomerClearance_broker__c)) {
            CustomObject1__c shipment = mapShipments.get(newCC.HBL_SHIPMENT__c);
            shipment.CustomsReleaseDay__c = getLatestCustomClearanceDate(shipment.Id);
            shipment.Custom_Clearance_Broker__c = newCC.clofor_com_cfs__CustomerClearance_broker__c ;
            toBeUpdatedShipments.add(shipment);
        }
    }

    public override void afterDelete(SObject so) {
        Custom_Clearance__c cc = (Custom_Clearance__c) so;
        CustomObject1__c shipment = mapShipments.get(cc.HBL_SHIPMENT__c);

        if (shipment != null && PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(shipment.Custom__c)) {
            List<Custom_Clearance__c> customClearances = shipment.Custom_Clearance__r;

            if (customClearances.isEmpty()) {
                shipment.Custom__c = PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO;
                toBeUpdatedShipments.add(shipment);
            }
        }
    }

    public override void andFinally() {
        try {
            if (!toBeUpdatedShipments.isEmpty()) {
                FlsService.doUpdate(new List<CustomObject1__c>(toBeUpdatedShipments));
            }
        } catch (Exception e) {
            Trigger.new[0].addError(e.getMessage());
        }
    }

    private void loadShipments(List<Custom_Clearance__c> customClearances) {
        Set<Id> shipmentIds = new Set<Id>();

        for (Custom_Clearance__c cc : customClearances) {
            shipmentIds.add(cc.HBL_SHIPMENT__c);
        }

        mapShipments = new Map<String, CustomObject1__c>([
                SELECT Id, Custom__c, RecordTypeId, ETD__c, T_ETD__c, ETA__c, CustomsReleaseDay__c, CutDay__c,
                    (SELECT Id, Pickupdate__c, DeliveryDate__c FROM Cargo_Delivery__r),
                    (SELECT Id, Customs_Release_Day__c FROM Custom_Clearance__r)
                FROM CustomObject1__c
                WHERE Id IN :shipmentIds
        ]);
    }

    private boolean validate(Custom_Clearance__c cc) {
        if (!isValidRecordType(cc) || !isValidCustomClearanceDate(cc)) {
            return false;
        }

        return true;
    }

    private boolean isValidRecordType(Custom_Clearance__c cc) {
        // 2019/08/17 Chien Truong DELETE START
        /*
        CustomObject1__c shipment = mapShipments.get(cc.HBL_SHIPMENT__c);
        String ccRecordType = RecordTypeUtil.getRecordTypeDeveloperNameById(Custom_Clearance__c.SObjectType, cc.RecordTypeId);
        String hblRecordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);

        if ((Constants.AIR_EXPORT_RT.equals(hblRecordType) && Constants.CC_AIR_EXPORT_RT.equals(ccRecordType))
                || (Constants.AIR_IMPORT_RT.equals(hblRecordType) && Constants.CC_AIR_IMPORT_RT.equals(ccRecordType))
                || (Constants.OCEAN_EXPORT_RT.equals(hblRecordType) && Constants.CC_OCEAN_EXPORT_RT.equals(ccRecordType))
                || (Constants.OCEAN_IMPORT_RT.equals(hblRecordType) && Constants.CC_OCEAN_IMPORT_RT.equals(ccRecordType))
                || (Constants.CROSS_BOARDER_RT.equals(hblRecordType) && (Constants.CC_INLAND_IMPORT_RT.equals(ccRecordType) || Constants.CC_INLAND_EXPORT_RT.equals(ccRecordType)))
                || Constants.DOMESTIC_TRANSPORTATION_RT.equals(hblRecordType)) {
            return true;
        } else {
            cc.addError(translationService.getTranslation(Constants.INVALID_RECORD_TYPE));
            return false;
        }*/
        // 2019/08/17 Chien Truong DELETE END

        // 2019/08/17 Chien Truong ADD START
        return true;
        // 2019/08/17 Chien Truong ADD END
    }

    private boolean isValidCustomClearanceDate(Custom_Clearance__c cc) {
        boolean result = true;

        if (cc.Customs_Release_Day__c != null) {
            CustomObject1__c shipment = mapShipments.get(cc.HBL_SHIPMENT__c);
            List<Custom_Clearance__c> ccs = shipment.Custom_Clearance__r;

            if (cc.Id == null) {
                ccs.add(cc);
            } else {
                for (Custom_Clearance__c temp : ccs) {
                    if (temp.Id == cc.Id) {
                        temp.Customs_Release_Day__c = cc.Customs_Release_Day__c;
                    }
                }
            }

            String errorMessage;
            /*cmt for verify- Nga do 03-09-2018
            // = ValidationUtils.validateDeliveryDates(shipment, shipment.Cargo_Delivery__r, ccs);
            */
            if (!StringUtils.isEmpty(errorMessage)) {
                cc.addError(errorMessage);
                result = false;
            }
        }

        return result;
    }

    private Date getLatestCustomClearanceDate(String shipmentId) {
        Date latestCustomClearanceDate = null;
        CustomObject1__c shipment = mapShipments.get(shipmentId);

        if (shipment != null) {
            List<Custom_Clearance__c> customClearanceList = shipment.Custom_Clearance__r;

            if (customClearanceList != null && !customClearanceList.isEmpty()) {
                for (Custom_Clearance__c cc : customClearanceList) {
                    if (latestCustomClearanceDate == null || latestCustomClearanceDate < cc.Customs_Release_Day__c) {
                        latestCustomClearanceDate = cc.Customs_Release_Day__c;
                    }
                }
            }
        }

        return latestCustomClearanceDate;
    }
}