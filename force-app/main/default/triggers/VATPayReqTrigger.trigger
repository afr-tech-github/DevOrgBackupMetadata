trigger VATPayReqTrigger on VATPayReq__c (after insert) {
	
	if (ValidationUtils.canExecuteTrigger()) {
        VATPayReqTriggerHelper.connectSOANDBillToTransactionPlan(trigger.new);
    }
}