trigger VATCashTrigger on VATCash__c (after insert) {
    if (ValidationUtils.canExecuteTrigger()) {
        VATCashTriggerHelper.connectBillToCash(trigger.new);
    }
}