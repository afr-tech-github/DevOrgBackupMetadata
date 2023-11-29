trigger DepositCashTrigger on DepositCash__c (after insert, after update, before delete, before insert, before update) {

	if (ValidationUtils.canExecuteTrigger()) {

		
		if(Trigger.isAfter && Trigger.isInsert){
    		// DepositCashTriggerHelper.onAfterInsert(Trigger.new);
	    }

	    if(Trigger.isBefore && Trigger.isDelete){
	    	// DepositCashTriggerHelper.onBeforeDelete(Trigger.old);
	    }
        TriggerHandlerFactory.createHandler(DepositCash__c.SObjectType);
    }
	
}