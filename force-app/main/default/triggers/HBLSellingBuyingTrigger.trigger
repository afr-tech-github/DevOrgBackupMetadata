trigger HBLSellingBuyingTrigger on AnkenMeisai__c (before insert, before update, after update, before delete ) {
    if (ValidationUtils.canExecuteTrigger() && excuteTriggerControll.firstRunHBLSellingBuyingTrigger) {
        TriggerHandlerFactory.createHandler(AnkenMeisai__c.sObjectType);
        excuteTriggerControll.firstRunHBLSellingBuyingTrigger = false;
    }
    if(trigger.isBefore && (trigger.isInsert)){
        excuteTriggerControll.translateUnitValueInsert(trigger.new);
    }
    if(trigger.isBefore && (trigger.isUpdate)){
        excuteTriggerControll.translateUnitValueUpdate(trigger.old,trigger.new);
    }
    
    
}