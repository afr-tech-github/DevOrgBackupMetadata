trigger ConsolCNTRTrigger on clofor_com_cfs__ConsolCNTR__c (after insert,after update, after delete) {
    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
            ConsolCNTRTriggerClass.onInsertUpdateDelete(trigger.new, trigger.Old);
        }
    }
}