/**
 * Created by khanhpham on 12/27/17.
 */

trigger KickbackCashTrigger on ConnectKickabckCash__c (after insert, before insert, before delete, after delete, after update) {
    if (ValidationUtils.canExecuteTrigger()) {
        //TriggerHandlerFactory.createHandler(ConnectKickabckCash__c.sObjectType);
        
         if(Trigger.isAfter && Trigger.isInsert){
        	// KickbackCashTriggerHelper.onAfterInsert(Trigger.new);
        }

        if(Trigger.isBefore && Trigger.isDelete){
        	// KickbackCashTriggerHelper.onBeforeDelete(Trigger.old);
        }
        TriggerHandlerFactory.createHandler(ConnectKickabckCash__c.sObjectType);

    }
}