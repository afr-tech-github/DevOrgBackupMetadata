trigger MBLBuyingTrigger on MasterAnkenMeisai__c (before insert, after insert, before update, after update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(MasterAnkenMeisai__c.sObjectType);
    }
}