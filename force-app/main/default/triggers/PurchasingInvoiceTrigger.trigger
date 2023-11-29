/**
 * Created by khanhpham on 5/28/17.
 */

trigger PurchasingInvoiceTrigger on PurchasingInvoice__c (before insert, before update, after update, before delete ) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(PurchasingInvoice__c.SObjectType);
    }
}