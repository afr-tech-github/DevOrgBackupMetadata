trigger CashPaymentAutoProcesing on clofor_com_cfs__CASH_BOOK__c (after update)  {

    if(trigger.isUpdate && excuteTriggerControll.firstRunCashPaymentAutoProcesing){
        CashPaymentAutoProcesingHandler.cashPaymentAuto(trigger.newMap);
        excuteTriggerControll.firstRunCashPaymentAutoProcesing = false;
    }
}