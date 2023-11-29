trigger AccountTrigger on Account (before insert, before update) {
	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}


	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
            AccountTriggerHandler.syncRecordTypes(Trigger.new, null);
		} 
		if(Trigger.isUpdate) {
            AccountTriggerHandler.syncRecordTypes(Trigger.new, Trigger.oldMap);
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
	TriggerHandlerFactory.createHandler(Account.sObjectType);

}