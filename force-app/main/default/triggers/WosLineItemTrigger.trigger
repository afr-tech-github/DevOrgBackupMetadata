trigger WosLineItemTrigger on WosLineItem__c (before insert, before update, before delete, after insert, after update, after delete) {

	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
            WosLineItemTriggerHelper.autoPopulateFields(Trigger.new, null);
			WosLineItemTriggerHelper.linkWoCargo(Trigger.new);
            WosLineItemTriggerHelper.updateDamagedCargoes(Trigger.new, null);
		} 
		if(Trigger.isUpdate) {
            WosLineItemTriggerHelper.autoPopulateFields(Trigger.new, Trigger.oldMap);
            WosLineItemTriggerHelper.updateDamagedCargoes(Trigger.new, Trigger.oldMap);
		} 
		if(Trigger.isDelete) {
		}
	} 
	if (Trigger.isAfter) {
		if(Trigger.isInsert) {
		} 
		if(Trigger.isUpdate) {
		} 
		if(Trigger.isDelete) {
		}
	}
}