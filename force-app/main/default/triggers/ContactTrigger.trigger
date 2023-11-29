trigger ContactTrigger on Contact (after update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Contact.SObjectType);
    }
}