trigger WorkOrderTrigger on WorkOrder__c (before insert, after update, before update) {	
    if (ValidationUtils.canExecuteTrigger()) {
    	if(Trigger.isAfter && Trigger.isUpdate){
			//WorkOrderTriggerHandler.onAfterUpdate(Trigger.new);
		}
        TriggerHandlerFactory.createHandler(WorkOrder__c.sObjectType);
    }

}