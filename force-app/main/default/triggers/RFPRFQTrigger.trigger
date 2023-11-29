trigger RFPRFQTrigger on RFPRFQ__c (before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
    	
        TriggerHandlerFactory.createHandler(RFPRFQ__c.sObjectType);
    }
}