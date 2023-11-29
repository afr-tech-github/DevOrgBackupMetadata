trigger ContainerGoodSOTrigger on clofor_com_cfs__ContainerGoodSO__c (after insert, after update, after delete) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(clofor_com_cfs__ContainerGoodSO__c.sObjectType);
    }
}