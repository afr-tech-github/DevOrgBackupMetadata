/**
 * Created by khanhpham on 12/14/17.
 */

trigger KickbackTrigger on Kickback__c (before insert, before update, after update, before delete ) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Kickback__c.sObjectType);
    }
}