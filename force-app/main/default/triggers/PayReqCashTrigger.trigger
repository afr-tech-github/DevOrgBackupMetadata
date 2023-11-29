trigger PayReqCashTrigger on PayReqCash__c (after insert) {
    if (ValidationUtils.canExecuteTrigger()) {
        PayReqCashTriggerHelper.connectBillToCash(trigger.new);
    }
}