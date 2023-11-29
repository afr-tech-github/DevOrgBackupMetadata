trigger ConsolTrigger on clofor_com_cfs__MasterAnken__c (before update,after update) {
    ConsolTriggerClass consol = new ConsolTriggerClass();
    if(Trigger.isBefore) {
        if(Trigger.isUpdate){
            consol.onBeforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }
}