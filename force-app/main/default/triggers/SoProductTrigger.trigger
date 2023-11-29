trigger SoProductTrigger on SalesOrderProduct__c (before insert, before update, before delete, after insert, after update, after delete) {
	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
            SoProductTriggerHelper.autoPopulateFields(Trigger.new, null);
        } 
		if(Trigger.isUpdate) {
            SoProductTriggerHelper.autoPopulateFields(Trigger.new, Trigger.oldMap);
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