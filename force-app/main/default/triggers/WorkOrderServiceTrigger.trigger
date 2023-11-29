trigger WorkOrderServiceTrigger on WorkOrderService__c (before insert, before update, before delete, after insert, after update, after delete) {

	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
            WorkOrderServiceTriggerHelper.autoPopulateFields(Trigger.new, null);
		} 
		if(Trigger.isUpdate) {
            WorkOrderServiceTriggerHelper.autoPopulateFields(Trigger.new, Trigger.oldMap);
		} 
		if(Trigger.isDelete) {
		}
	} 
	if (Trigger.isAfter) {
		if(Trigger.isInsert) {
		} 
		if(Trigger.isUpdate) {
            WorkOrderServiceTriggerHelper.generateStockAndUpdateCargoLifeCycle(Trigger.new, Trigger.oldMap);
		} 
		if(Trigger.isDelete) {
		}
	}
}