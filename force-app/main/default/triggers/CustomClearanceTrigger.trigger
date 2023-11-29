trigger CustomClearanceTrigger on Custom_Clearance__c (before update, after update, after delete) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Custom_Clearance__c.SObjectType);
    }
}