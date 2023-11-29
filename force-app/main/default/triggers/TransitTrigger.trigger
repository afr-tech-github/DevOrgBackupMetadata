/**
 * Created by khanhpham on 7/14/17.
 */

trigger TransitTrigger on Transit__c (before insert, after insert, before update, after update, after delete) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(Transit__c.SObjectType);
    }
}