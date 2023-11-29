trigger HSCodeTrigger on HS_Code__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
    	TriggerHandlerFactory.createHandler(HS_Code__c.SObjectType);    
    }
}