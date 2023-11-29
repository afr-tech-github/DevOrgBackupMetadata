trigger WoCargoTrigger on WO_Cargo__c (before insert, before update, before delete, after insert, after update, after delete) {

	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
            WoCargoTriggerHandler.autoPopulateFields(Trigger.new);
		} 
		if(Trigger.isUpdate) {
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