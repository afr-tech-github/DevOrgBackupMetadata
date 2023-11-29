trigger TaxRatioTrigger on Tax_Ratio__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Tax_Ratio__c.SObjectType);
    }
}