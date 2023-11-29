/**
 * Created by khanhpham on 5/28/17.
 */

trigger InvoiceCashTrigger on ConnectInvoicingAndCash__c (after insert, after update, before delete, before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        //TriggerHandlerFactory.createHandler(ConnectInvoicingAndCash__c.SObjectType);
        if(Trigger.isAfter && Trigger.isInsert){
        	// InvoicingCashTriggerHelper.onAfterInsert(Trigger.new);
        }

        if(Trigger.isBefore && Trigger.isDelete){
        	// InvoicingCashTriggerHelper.onBeforeDelete(Trigger.old);
        }
        TriggerHandlerFactory.createHandler(ConnectInvoicingAndCash__c.SObjectType);
    }
}