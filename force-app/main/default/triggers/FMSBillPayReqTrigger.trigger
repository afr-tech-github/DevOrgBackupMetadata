trigger FMSBillPayReqTrigger on FMSBillPayReq__c(before insert, before update, after insert, after update, after delete) {
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){

        
        if(trigger.isInsert){
            FMSBillPayReqTriggerHelper.checkDuplicate(trigger.new);
            if(!FMSBillPayReqTriggerHelper.rollupFlag){
                FMSBillPayReqTriggerHelper.rollupAmountToPaymentRequest(trigger.new, new Map<Id, FMSBillPayReq__c>());
                FMSBillPayReqTriggerHelper.rollupFlag = true;
            }
            
            
        }
        if(trigger.isUpdate){
            if(!FMSBillPayReqTriggerHelper.rollupFlag){
                FMSBillPayReqTriggerHelper.rollupAmountToPaymentRequest(trigger.new, trigger.oldMap);
                FMSBillPayReqTriggerHelper.rollupFlag = true;
            }
            
        }
        
    }
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if(!FMSBillPayReqTriggerHelper.recalculateFlag){
            FMSBillPayReqTriggerHelper.reCacualateAmountToPaymentRequest(trigger.new);
            FMSBillPayReqTriggerHelper.recalculateFlag = true;
        }
    }

    if(trigger.isAfter && trigger.isDelete){
        FMSBillPayReqTriggerHelper.reCacualateAmountToPaymentRequest(trigger.old);
    }

}