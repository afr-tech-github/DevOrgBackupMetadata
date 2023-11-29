trigger CargoDeliveryTrigger on Cargo_Delivery__c (before insert, after insert, before update, after update, after delete) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Cargo_Delivery__c.SObjectType);
    }
}