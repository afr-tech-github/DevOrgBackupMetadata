/**
 * Created by khanhpham on 6/21/17.
 */

public with sharing class TimeEntryService {
    private CalendarService caService;

//    public TimeEntryService() {
//        caService = new CalendarService();
//    }
//
//    public void updateLoggedTime(TimeEntry__c te) {
//        if (te.LeaveTime__c != null) {
//            te.LoggedHours__c = ((Decimal)DateTimeUtils.timeDiffInMinutes(te.EnterTime__c, te.LeaveTime__c))/60;
//        }
//    }
//
//    public void populateBusinessHours(TimeEntry__c te) {
//        Site_Custom_Settings__c settings = Site_Custom_Settings__c.getOrgDefaults();
//        CalendarService.BusinessHourWrapper bizHours = caService.getBusinessHours(te.LogDate__c);
//
//        if (bizHours.startTime == null || bizHours.endTime == null) {
//            throw new CustomException('No Business Hours found for the day');
//        }
//
//        DateTime beginTime = DateTime.newInstanceGmt(te.LogDate__c, bizHours.startTime);
//        te.BusinessHoursStartTime__c = beginTime.format('hh:mm a');
//
//        DateTime endTime = DateTime.newInstanceGmt(te.LogDate__c, bizHours.endTime);
//        te.BusinessHoursEndTime__c = endTime.format('hh:mm a');
//
//        Decimal businessHours = DateTimeUtils.timeDiffInMinutes(beginTime, endTime)/60;
//        if (businessHours > 4) {
//            Decimal lunchBreakHours = (settings.LunchBreakHours__c != null ? settings.LunchBreakHours__c : 1);
//            te.BusinessHours__c = businessHours - lunchBreakHours;
//        } else {
//            te.BusinessHours__c = businessHours;
//        }
//    }
//
//    public List<TimeEntry__c> findTimeEntryByUserAndDate(Id userId, Date findDate) {
//        try {
//            return [SELECT Id, EnterTime__c, LeaveTime__c, LoggedHours__c, OnLeave__c, PublicHoliday__c, OT__c
//            FROM TimeEntry__c
//            WHERE Employee__c = :userId AND LogDate__c = :findDate];
//        } catch(Exception e) {
//            return null;
//        }
//    }
//
//    public boolean isHoliday(Date dateToCheck) {
//        return caService.isHoliday(dateToCheck);
//    }
//
//    public String validate(TimeEntry__c te, boolean isNew) {
//        String result = '';
//
//        if (te.Employee__c == null) {
//            result = 'Employee field is required';
//        } else {
//            List<TimeEntry__c> existingTEs = findTimeEntryByUserAndDate(te.Employee__c, te.LogDate__c);
//
//            if (!existingTEs.isEmpty()) {
//                if (existingTEs.size() > 1) {
//                    result = 'There is an issue with existing data where having more than one time entries in the date '
//                            + te.LogDate__c.format() + ' for employee ' + te.Employee__c;
//                } else {
//                    TimeEntry__c existingTE = existingTEs.get(0);
//
//                    if ((isNew && (existingTE.OT__c || !existingTE.PublicHoliday__c)) || (!isNew && te.Id != existingTE.Id)) {
//                        result = 'Duplicated time entry';
//                    }
//                }
//            }
//        }
//
//        return result;
//    }
}