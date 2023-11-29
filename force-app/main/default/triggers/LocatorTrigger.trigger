trigger LocatorTrigger on clofor_com_cfs__LOCATOR__c (before Update, before Delete, after Insert, before Insert) {
    	if (ValidationUtils.canExecuteTrigger()) {
            if(Trigger.isBefore && Trigger.isDelete ){
            //LocatorTriggerHelper.calculateCapacityLocatorDeleteChild(Trigger.old);
            LocatorTriggerHelper.onBeforeDelete(Trigger.old);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            //LocatorTriggerHelper.calculateCapacityLocatorUpdateChild(Trigger.new, Trigger.oldMap);
            LocatorTriggerHelper.onBeforeUpdate(Trigger.new, Trigger.oldMap);

        }
        if(Trigger.isAfter && Trigger.isInsert){
            //LocatorTriggerHelper.calculateShareCapacityInsertChild(Trigger.new);
            LocatorTriggerHelper.onAfterInsert(Trigger.new);

        }
        if(Trigger.isBefore && Trigger.isInsert){
            //LocatorTriggerHelper.calculateShareCapacityInsertChild(Trigger.new);
            LocatorTriggerHelper.onBeforeInsert(Trigger.new);

        }
        TriggerHandlerFactory.createHandler(LOCATOR__c.sObjectType);
    }

}