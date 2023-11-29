trigger BillingTrigger on clofor_com_cfs__Billing__c (before insert, before update) {
	// insert work order
	// insert billig
	// 
	if (ValidationUtils.canExecuteTrigger()) {

		if(Trigger.isBefore && Trigger.isInsert){
			BillingTriggerHelper.onBeforeInsert(Trigger.new);
            BillingTriggerHelper.translateUnitValue(trigger.new);
		}
		if(Trigger.isBefore && Trigger.isUpdate){
			BillingTriggerHelper.onBeforeUpdate(Trigger.new);
            BillingTriggerHelper.translateUnitValue(trigger.new);
		}

        TriggerHandlerFactory.createHandler(clofor_com_cfs__Billing__c.SObjectType);
    }
}