trigger ProjectTrigger on PROJECT__c (before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
    	
        TriggerHandlerFactory.createHandler(PROJECT__c.sObjectType);
    }
}