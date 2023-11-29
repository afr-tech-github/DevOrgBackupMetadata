trigger PayReqBankTrigger on PayReqBank__c (after insert) {
    if (ValidationUtils.canExecuteTrigger()) {
        PayReqBankTriggerHelper.connectBillToBank(trigger.new);
    }
}