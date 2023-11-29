/**
 * Created by khanhpham on 5/18/17.
 */

trigger PurchasingOrderTrigger on PurchasingOrder__c (before update, before insert) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(PurchasingOrder__c.sObjectType);
    }
}