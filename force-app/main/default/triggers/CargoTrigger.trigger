trigger CargoTrigger on Cargo__c (before insert, before update, before delete, after insert, after update, after delete) {
	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
			CargoTriggerHandler.autoPopulateFields(Trigger.new, null);
		} 
		if(Trigger.isUpdate) {
			CargoTriggerHandler.autoPopulateFields(Trigger.new, Trigger.oldMap);
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