/**
 * Created by khanhpham on 5/2/17.
 */

trigger LoadingLocationTrigger on LoadingLocation__c (before insert, before update, before delete, after insert, after delete) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(LoadingLocation__c.SObjectType);
    }
}