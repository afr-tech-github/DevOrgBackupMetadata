trigger DepositTrigger on Deposit__c (after update, before delete) {

	if (ValidationUtils.canExecuteTrigger()) {

		
		if(Trigger.isAfter && Trigger.isUpdate){

			// DepositTriggerHelper.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
		}
		if(Trigger.isBefore && Trigger.isDelete){

			// DepositTriggerHelper.onBeforeDelete(Trigger.oldMap);
		}
        TriggerHandlerFactory.createHandler(Deposit__c.SObjectType);
    }
	
}