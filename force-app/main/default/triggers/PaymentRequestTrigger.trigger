trigger PaymentRequestTrigger on PaymentRequest__c (before insert, before update) {
	if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(PaymentRequest__c.sObjectType);
    }
}