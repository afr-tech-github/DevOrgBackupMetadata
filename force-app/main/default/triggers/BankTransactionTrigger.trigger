trigger BankTransactionTrigger on BankTransaction__c (before insert, before Update) {
	if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(BankTransaction__c.SObjectType);
        BankTransactionTriggerHelper.calculateAmount(trigger.new);
    }
}