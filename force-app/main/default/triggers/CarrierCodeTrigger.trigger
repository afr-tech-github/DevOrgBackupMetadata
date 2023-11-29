trigger CarrierCodeTrigger on Carrier_Code__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Carrier_Code__c.SObjectType);
    }
}