trigger OtherRevenueCostTrigger on OtherRevenueCost__c (after update, before delete, before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
		if(Trigger.isAfter && Trigger.isUpdate){
			//OtherRevenueCostTriggerHelper.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
		}
		if(Trigger.isBefore && Trigger.isDelete){
			//OtherRevenueCostTriggerHelper.onBeforeDelete(Trigger.oldMap);
		}

        TriggerHandlerFactory.createHandler(OtherRevenueCost__c.sObjectType);
    }
	
}