trigger GoodsPurchasingOrderTrigger on GoodsPurchasingOrder__c (before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
    	
        TriggerHandlerFactory.createHandler(GoodsPurchasingOrder__c.sObjectType);
    }
}