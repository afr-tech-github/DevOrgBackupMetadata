/**
 * Created by khanhpham on 6/21/17.
 */

public with sharing class CalendarService {
    private String timezone;
    private String holidayPrefix;
    private BusinessHours businessHour;
    private List<Holiday> holidays = new List<Holiday>();

//    public CalendarService() {
//        determineCalendar();
//        loadBusinessHours();
//        loadHolidays();
//    }
//
//    public CalendarService(String timezone, String holidayPrefix) {
//        this.timezone = timezone;
//        this.holidayPrefix = holidayPrefix;
//
//        loadBusinessHours();
//        loadHolidays();
//    }
//
//    public boolean isNonWorkingDay(Date dateToCheck) {
//        BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, dateToCheck);
//        return (bizHour.startTime == null || bizHour.endTime == null);
//    }
//
//    public boolean isHoliday(Date dateToCheck) {
//        for (Holiday h : holidays) {
//            if (!h.IsRecurrence) {
//                if (DateTimeUtils.isSameDate(dateToCheck, h.ActivityDate, true)) {
//                    return true;
//                }
//            } else if (h.RecurrenceEndDateOnly == null) {
//                if (DateTimeUtils.isSameDate(dateToCheck, h.RecurrenceStartDate, false)) {
//                    return true;
//                }
//            } else if (h.RecurrenceStartDate <= dateToCheck && dateToCheck <= h.RecurrenceEndDateOnly) {
//                return true;
//            }
//        }
//
//        return false;
//    }
//
//    public BusinessHourWrapper getBusinessHours(Date targetDate) {
//        return (new BusinessHourWrapper(businessHour, targetDate));
//    }
//
//    private void determineCalendar() {
//        timezone = UserInfo.getTimeZone().getID();
//
//        if (!StringUtils.isEmpty(timezone)) {
//            TeamSettings__c settings = TeamSettings__c.getValues(timezone);
//
//            if (settings != null) {
//                holidayPrefix = settings.HolidayNamePrefix__c;
//            }
//        }
//    }
//
//    private void loadHolidays() {
//        String filterValue = holidayPrefix + '%';
//        holidays = [SELECT Name, IsRecurrence, RecurrenceStartDate, RecurrenceEndDateOnly, ActivityDate
//        FROM Holiday
//        WHERE Name LIKE :filterValue];
//    }
//
//    private void loadBusinessHours() {
//        if (Test.isRunningTest()) {
//            businessHour = createBusinessHoursForUnitTest();
//        } else {
//            businessHour = [SELECT MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime,
//                    WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime,
//                    FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime,
//                    SundayStartTime, SundayEndTime, TimeZoneSidKey
//            FROM BusinessHours
//            WHERE IsActive = TRUE AND TimeZoneSidKey = :timezone LIMIT 1];
//        }
//    }
//
//    private static boolean isSameDate(Date d1, Date d2, Boolean includedYear) {
//        if (includedYear) {
//            return (d1 == d2);
//        } else {
//            return ((d1.month() == d2.month()) && (d1.day() == d2.day()));
//        }
//    }
//
//    private static BusinessHours createBusinessHoursForUnitTest() {
//        BusinessHours sample = new BusinessHours();
//
//        sample.Name = 'Test Vietnam Team';
//        sample.TimezoneSidKey = 'Asia/Ho_Chi_Minh';
//        sample.IsActive = true;
//        sample.MondayStartTime= Time.newInstance(9, 0, 0, 0);
//        sample.MondayEndTime= Time.newInstance(18, 0, 0, 0);
//        sample.TuesdayStartTime= Time.newInstance(9, 0, 0, 0);
//        sample.TuesdayEndTime= Time.newInstance(18, 0, 0, 0);
//        sample.WednesdayStartTime= Time.newInstance(9, 0, 0, 0);
//        sample.WednesdayEndTime= Time.newInstance(18, 0, 0, 0);
//        sample.ThursdayStartTime= Time.newInstance(9, 0, 0, 0);
//        sample.ThursdayEndTime= Time.newInstance(18, 0, 0, 0);
//        sample.FridayStartTime= Time.newInstance(9, 0, 0, 0);
//        sample.FridayEndTime= Time.newInstance(18, 0, 0, 0);
//
//        return sample;
//    }
//
//    public class BusinessHourWrapper {
//        public String dayOfWeek {get; set;}
//        public Time startTime {get; set;}
//        public Time endTime {get; set;}
//
//        public BusinessHourWrapper(BusinessHours businessHour, Date fromDate) {
//            String dayOfWeek = DateTimeUtils.dayOfWeek(fromDate);
//
//            if ('Mon'.equals(dayOfWeek)) {
//                startTime = businessHour.MondayStartTime;
//                endTime = businessHour.MondayEndTime;
//            } else if ('Tue'.equals(dayOfWeek)) {
//                startTime = businessHour.TuesdayStartTime;
//                endTime = businessHour.TuesdayEndTime;
//            } else if ('Wed'.equals(dayOfWeek)) {
//                startTime = businessHour.WednesdayStartTime;
//                endTime = businessHour.WednesdayEndTime;
//            } else if ('Thu'.equals(dayOfWeek)) {
//                startTime = businessHour.ThursdayStartTime;
//                endTime = businessHour.ThursdayEndTime;
//            } else if ('Fri'.equals(dayOfWeek)) {
//                startTime = businessHour.FridayStartTime;
//                endTime = businessHour.FridayEndTime;
//            } else if ('Sat'.equals(dayOfWeek)) {
//                startTime = businessHour.SaturdayStartTime;
//                endTime = businessHour.SaturdayEndTime;
//            } else {
//                startTime = businessHour.SundayStartTime;
//                endTime = businessHour.SundayEndTime;
//            }
//
//            if (startTime != null && endTime != null) {
//                Date dummyDate = Date.newInstance(1970, 1, 1);
//
//                DateTime dtStartTime = DateTime.newInstanceGmt(dummyDate, startTime);
//                dtStartTime = DateTimeUtils.convertDateTime(dtStartTime, businessHour.TimeZoneSidKey, 'GMT');
//                startTime = dtStartTime.timeGmt();
//
//                DateTime dtEndTime = DateTime.newInstanceGmt(dummyDate, endTime);
//                dtEndTime = DateTimeUtils.convertDateTime(dtEndTime, businessHour.TimeZoneSidKey, 'GMT');
//                endTime = dtEndTime.timeGmt();
//            }
//        }
//
//        public boolean validBusinessHour() {
//            return (startTime != null && endTime != null && startTime <= endTime);
//        }
//    }
}