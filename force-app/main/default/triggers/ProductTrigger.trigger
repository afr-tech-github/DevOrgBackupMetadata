trigger ProductTrigger on PRODUCT__c (before insert, before update, before delete, after insert, after update, after delete) {

	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
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