/**
 * Created by khanhpham on 5/28/17.
 */

trigger POCashTrigger on ConnectPurchasingInvoiceCash__c (after insert, before delete, after update, before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        //TriggerHandlerFactory.createHandler(ConnectPurchasingInvoiceCash__c.SObjectType);

        if(Trigger.isAfter && Trigger.isInsert){
        	// POCashTriggerHelper.onAfterInsert(Trigger.new);
        }

        if(Trigger.isBefore && Trigger.isDelete){
        	// POCashTriggerHelper.onBeforeDelete(Trigger.old);
        }

        TriggerHandlerFactory.createHandler(ConnectPurchasingInvoiceCash__c.SObjectType);
    }

}