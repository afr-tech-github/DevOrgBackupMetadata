trigger HBLShipmmentsTrigger on CustomObject1__c (before insert, after insert, before update) {
    // moved from CustomObject1Trigger created By Mr Chien on 06/07/2019 due to app exchange secutity scan: -Multiple Trigger On same sObject
    CustomObject1TriggerHndl handler = new CustomObject1TriggerHndl();
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			handler.onBeforeInsert(Trigger.new);
		} else if (Trigger.isUpdate) {
			handler.onBeforeUpdate(Trigger.oldMap, Trigger.new);
		}
	} else if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			handler.onAfterInsert(Trigger.newMap);
		}
	}
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(CustomObject1__c.sObjectType);
    }
}