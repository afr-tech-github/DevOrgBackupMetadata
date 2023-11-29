trigger ContainerInfoTrigger on Container_Info__c (before insert, after insert, before update, after update) {
    try {
        if (ValidationUtils.canExecuteTrigger()) {
            TriggerHandlerFactory.createHandler(Container_Info__c.SObjectType);
        }
    } catch (Exception ex) {
    }
}