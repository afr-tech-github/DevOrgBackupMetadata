trigger ConnectOtherCashTrigger on ConnectOtherCash__c (after insert, after update, before delete, before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {

		
		if(Trigger.isAfter && Trigger.isInsert){
    		// ConnectOtherCashTriggerHelper.onAfterInsert(Trigger.new);
	    }

	    if(Trigger.isBefore && Trigger.isDelete){
	    	// ConnectOtherCashTriggerHelper.onBeforeDelete(Trigger.old);
	    }
        TriggerHandlerFactory.createHandler(ConnectOtherCash__c.SObjectType);
    }
	
}