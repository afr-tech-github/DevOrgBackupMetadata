/**
 * Created by khanhpham on 6/22/17.
 */

public with sharing class TimeEntryTriggerHandler extends AbstractTriggerHandler {
    private static Integer WORKING_HOURS_PER_DAY = 8;
    private static TimeEntryService teService = new TimeEntryService();
    private Set<TimeEntry__c> toBeRemovedTEs = new Set<TimeEntry__c>();

//    public override void beforeInsert(SObject so) {
//        TimeEntry__c te = (TimeEntry__c) so;
//        String validationError = teService.validate(te, true);
//
//        try {
//            if (StringUtils.isEmpty(validationError)) {
//                teService.updateLoggedTime(te);
//                teService.populateBusinessHours(te);
//                List<TimeEntry__c> existingTEs = teService.findTimeEntryByUserAndDate(UserInfo.getUserId(), te.LogDate__c);
//
//                if (!existingTEs.isEmpty()) {
//                    TimeEntry__c existingTE = existingTEs.get(0);
//                    if (existingTE.PublicHoliday__c) {
//                        toBeRemovedTEs.add(existingTE);
//                        te.OT__c = true;
//                        te.PublicHoliday__c = true;
//                    }
//                }
//
//                updateNotifyManagerFlag(null, te);
//            } else {
//                te.addError(validationError);
//            }
//        } catch(CustomException e) {
//            so.addError(e.getMessage());
//        }
//
//        if (te.OT__c != true && te.LoggedHours__c > WORKING_HOURS_PER_DAY) {
//            te.LoggedHours__c = WORKING_HOURS_PER_DAY;
//        }
//    }
//
//    public override void beforeUpdate(SObject oldSo, SObject so) {
//        TimeEntry__c oldTE = (TimeEntry__c) oldSo;
//        TimeEntry__c newTE = (TimeEntry__c) so;
//        String validationError = teService.validate(newTE, false);
//
//        try {
//            if (StringUtils.isEmpty(validationError)) {
//                teService.updateLoggedTime(newTE);
//                updateNotifyManagerFlag(oldTE, newTE);
//            } else {
//                newTE.addError(validationError);
//            }
//        } catch(CustomException e) {
//            so.addError(e.getMessage());
//        }
//
//        if (newTE.OT__c != true && newTE.LoggedHours__c > WORKING_HOURS_PER_DAY) {
//            newTE.LoggedHours__c = WORKING_HOURS_PER_DAY;
//        }
//    }
//
//    public override void andFinally() {
//        if (!toBeRemovedTEs.isEmpty()) {
//            delete (new List<TimeEntry__c>(toBeRemovedTEs));
//        }
//    }
//
//    private void updateNotifyManagerFlag(TimeEntry__c oldTE, TimeEntry__c newTE) {
//        newTE.NotifyManager__c = false;
//
//        if ((oldTE == null && newTE.EnterTime__c != null)
//                || (oldTE.EnterTime__c == null && newTE.EnterTime__c != null)) {
//            newTE.NotifyManager__c = true;
//            newTE.ComeOrLeave__c = 'comes';
//        } else if (oldTE.LeaveTime__c == null && newTE.LeaveTime__c != null) {
//            newTE.NotifyManager__c = true;
//            newTE.ComeOrLeave__c = 'leaves';
//        }
//    }
}