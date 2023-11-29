/**
 * Created by khanhpham on 7/6/17.
 */

trigger PayslipTrigger on PayrollSlip__c (before insert, before update) {
    if (ValidationUtils.canExecuteTrigger()) {
        TriggerHandlerFactory.createHandler(PayrollSlip__c.sObjectType);
    }
}