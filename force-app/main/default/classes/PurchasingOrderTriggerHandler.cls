/**
 * Created by khanhpham on 5/18/17.
 */

public with sharing class PurchasingOrderTriggerHandler extends AbstractTriggerHandler {
    public override void beforeUpdate(SObject oldSo, SObject so) {
        PurchasingOrder__c oldPO = (PurchasingOrder__c) oldSo;
        PurchasingOrder__c newPO = (PurchasingOrder__c) so;

        lockRecordOnCompletion(oldPO, newPO);
    }

    private void lockRecordOnCompletion(PurchasingOrder__c oldPO, PurchasingOrder__c newPO) {
        if (!(PicklistReference.PO_PAYMENT_SETTLED.equalsIgnoreCase(oldPO.Status__c) && oldPO.TotalUnpaidBalanceLocal__c == 0)
                && (PicklistReference.PO_PAYMENT_SETTLED.equalsIgnoreCase(newPO.Status__c) && newPO.TotalUnpaidBalanceLocal__c == 0)) {
            String recordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(PurchasingOrder__c.SObjectType, Constants.PO_LOCK_RT);

            if (recordTypeId != null) {
                newPO.RecordTypeId = recordTypeId;
            }
        }
    }
}