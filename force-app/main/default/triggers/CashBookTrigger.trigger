/**
 * Created by khanhpham on 5/22/18.
 */

trigger CashBookTrigger on CASH_BOOK__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(CASH_BOOK__c.SObjectType);
    }
}