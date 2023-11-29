trigger VATInvoiceTrigger on clofor_com_cfs__VAT_INVOICE__c (before insert, after update, before update) {  
    System.debug('=================firstRun: ' + excuteTriggerControll.firstRun);
    //if (ValidationUtils.canExecuteTrigger() && excuteTriggerControll.firstRun) {
    if (ValidationUtils.canExecuteTrigger()) {
        //excuteTriggerControll.firstRun = false;
        TriggerHandlerFactory.createHandler(VAT_INVOICE__c.SObjectType);
    }
}