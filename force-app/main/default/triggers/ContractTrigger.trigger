trigger ContractTrigger on Contract__c (before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
    	
        TriggerHandlerFactory.createHandler(Contract__c.sObjectType);
    }

}