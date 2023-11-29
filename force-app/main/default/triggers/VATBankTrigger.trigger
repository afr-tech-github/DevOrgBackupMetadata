trigger VATBankTrigger on clofor_com_cfs__VATBank__c (after insert) {
    if (ValidationUtils.canExecuteTrigger()) {
        VATBankTriggerHelper.connectBillToBank(trigger.new);
    }
}