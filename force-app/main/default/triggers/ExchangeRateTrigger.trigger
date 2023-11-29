trigger ExchangeRateTrigger on MgmtMaster__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(MgmtMaster__c.SObjectType);
    }
}