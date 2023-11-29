trigger OrganizationPerformanceTrigger on OrganizationPerformance__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if (ValidationUtils.canExecuteTrigger()) {
        //TriggerHandlerFactory.createHandler(ConnectInvoicingAndCash__c.SObjectType);
        if(Trigger.isBefore && Trigger.isDelete){

		OrganizationPerformanceTriggerHandler.onBeforeDelete(Trigger.old);

		}
        TriggerHandlerFactory.createHandler(OrganizationPerformance__c.SObjectType);
    }
	

}