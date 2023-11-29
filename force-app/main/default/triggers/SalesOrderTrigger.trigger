trigger SalesOrderTrigger on SALES_ORDER__c (before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
    	
        TriggerHandlerFactory.createHandler(SALES_ORDER__c.sObjectType);
    }
}