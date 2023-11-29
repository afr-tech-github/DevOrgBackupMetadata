trigger InvoicingVATTrigger on clofor_com_cfs__INVOICING_VAT__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(INVOICING_VAT__c.SObjectType);
    }
}