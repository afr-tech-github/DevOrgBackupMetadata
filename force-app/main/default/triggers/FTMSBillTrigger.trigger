trigger FTMSBillTrigger on clofor_com_cfs__AnkenMeisai__c (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        FTMSBillTriggerHandler.deleteFTMSBill(Trigger.oldMap);
    }
}