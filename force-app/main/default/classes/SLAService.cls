public with sharing class SLAService {
    private String timezone;
    private String holidayPrefix;
	private List<Holiday> holidays = new List<Holiday>();   
    private BusinessHours businessHour;
    
    public SLAService(String timezone, String holidayKey) {
        this.timezone = timezone;
        this.holidayPrefix = holidayKey;
        
        loadBusinessHours();
        loadHolidays();
    }
    
    public boolean determineSLAStatus(DateTime startTime, DateTime endTime, Integer slaInMinutes) {
        DateTime slaEndTime = calculateSLAEndTime(startTime, slaInMinutes);
        
        return (endTime <= slaEndTime);
    }
    
    public DateTime calculateSLAEndTime(DateTime startTime, Integer slaInMinutes) {
        DateTime slaStartTime = determineSLAStartTime(startTime);
        BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, slaStartTime.dateGmt());
        DateTime slaEndTime = slaStartTime.addMinutes(slaInMinutes);

        if (slaEndTime.timeGmt() <= bizHour.endTime) {
            return slaEndTime;
        } else {
			DateTime endTime = DateTime.newInstanceGmt(slaStartTime.dateGmt(), bizHour.endTime);
            slaInMinutes -= (Integer) ((endTime.getTime() - slaStartTime.getTime())/1000/60);
            
            DateTime newStartTime = slaStartTime.addDays(1);
            newStartTime = DateTime.newInstanceGmt(newStartTime.dateGmt(), Time.newInstance(0, 0, 0, 1));
            slaEndTime = calculateSLAEndTime(newStartTime, slaInMinutes);
        }
        
        return slaEndTime;
    }   
    
    public DateTime determineSLAStartTime(DateTime origStartTime) {
        DateTime startTime = origStartTime;

        while(true) {
            if (isHoliday(startTime.dateGmt())) {
                startTime = startTime.addDays(1);
                startTime = DateTime.newInstanceGmt(startTime.dateGmt(), Time.newInstance(0, 0, 0, 1));
            } else {
                break;
            }
        }
        
        if (isBeforeBusinessHour(startTime)) {
            BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, startTime.dateGmt());
            startTime = DateTime.newInstanceGmt(startTime.dateGmt(), bizHour.startTime);
        } else if (isAfterBusinessHour(startTime) || isNonWorkingDay(startTime)) {
            startTime = startTime.addDays(1);
            startTime = DateTime.newInstanceGmt(startTime.dateGmt(), Time.newInstance(0, 0, 0, 1));
            startTime = determineSLAStartTime(startTime);
        }
        
        return startTime;
    }
    
    public Integer calculateSpentTime(DateTime startTime, DateTime completedTime) {
        Integer spentTime = 0;
        DateTime slaStartTime = determineSLAStartTime(startTime);
        
        spentTime = accumulateSpentTimeInMinutes(slaStartTime, completedTime);
        return spentTime;
    }
    
    private Integer accumulateSpentTimeInMinutes(DateTime slaStartTime, DateTime endTime) {
        Integer accumulatedTime = 0;
        Time s = slaStartTime.timeGmt();
        Time endTimeOfDay = getEndTimeOfDay(slaStartTime.dateGmt());
 
        if (slaStartTime.dateGmt() == endTime.dateGmt()) {
            DateTime et = DateTime.newInstanceGmt(slaStartTime.dateGmt(), endTimeOfDay);
            et = (et < endTime ? et : endTime);
            
			Long diffInMillis = DateTimeUtils.timeDiffInMilliseconds(slaStartTime.dateGmt(), slaStartTime.timeGmt(), et.timeGmt());	 
            
            if (diffInMillis > 0) {
                accumulatedTime += (Integer) diffInMillis/1000/60;
            }
        } else if (slaStartTime.dateGmt() < endTime.dateGmt()) {
            Long diffInMillis = DateTimeUtils.timeDiffInMilliseconds(slaStartTime.dateGmt(), slaStartTime.timeGmt(), endTimeOfDay);
            accumulatedTime += (Integer) diffInMillis/1000/60;
            
            DateTime startTime = DateTime.newInstanceGmt(slaStartTime.dateGmt(), Time.newInstance(0, 0, 0, 0));
            startTime = startTime.addDays(1);
            slaStartTime = determineSLAStartTime(startTime);
            accumulatedTime += accumulateSpentTimeInMinutes(slaStartTime, endTime);
        } 
        
        return accumulatedTime;
    }
    
    private void loadBusinessHours() {
        if (Test.isRunningTest()) {
            businessHour = createBusinessHoursForUnitTest();
        } else {
            businessHour = [SELECT MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime,
                            WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                            FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime,
                            SundayStartTime, SundayEndTime, TimeZoneSidKey
                            FROM BusinessHours 
                            WHERE IsActive = TRUE AND TimeZoneSidKey = :timezone LIMIT 1];
        }
    }
    
    private void loadHolidays() {
        String filterValue = holidayPrefix + '%';
		holidays = [SELECT Name, IsRecurrence, RecurrenceStartDate, RecurrenceEndDateOnly 
                    FROM Holiday 
                    WHERE Name LIKE :filterValue];		    	    
    }
    
    private boolean isHoliday(Date dateToCheck) {
        for (Holiday h : holidays) {
            if (!h.IsRecurrence) {
                if (DateTimeUtils.isSameDate(dateToCheck, h.ActivityDate, true)) {
                    return true;
                }
            } else if (h.RecurrenceEndDateOnly == null) {
                if (DateTimeUtils.isSameDate(dateToCheck, h.RecurrenceStartDate, false)) {
                    return true;
                }
            } else if (h.RecurrenceStartDate <= dateToCheck && dateToCheck <= h.RecurrenceEndDateOnly) {
				return true;                
            }
        }
        
        return false;
    }
    
    private boolean isNonWorkingDay(DateTime timeToCheck) {
        BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, timeToCheck.date());
        
        return (bizHour.startTime == null || bizHour.endTime == null);
    }
    
    private boolean isBeforeBusinessHour(DateTime timeToCheck) {
        BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, timeToCheck.date());
        return (bizHour.validBusinessHour() && (timeToCheck.timeGmt() < bizHour.startTime));
    }
    
    private boolean isAfterBusinessHour(DateTime timeToCheck) {
        BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, timeToCheck.date());
        return (bizHour.validBusinessHour() && (timeToCheck.timeGmt() > bizHour.endTime));
    }
    
    private Time getEndTimeOfDay(Date dateToCheck) {
        Time endTime = null;
        
        if (!isHoliday(dateToCheck)) {
            BusinessHourWrapper bizHour = new BusinessHourWrapper(businessHour, dateToCheck);
            endTime = bizHour.endTime;
        }
        
        return endTime;
    }
    
    /**
     * There is a limitation where BusinessHours cannot be created from testing context.
     * This method is to create in-memory BusinessHours instance to support testing only.
     * Do not use it for other purposes.
     */ 
    private static BusinessHours createBusinessHoursForUnitTest() {
        BusinessHours sample = new BusinessHours();
        
        sample.Name = 'Test Vietnam Team';
        sample.TimezoneSidKey = 'Asia/Ho_Chi_Minh';
		sample.IsActive = true;
        sample.MondayStartTime= Time.newInstance(9, 0, 0, 0);
        sample.MondayEndTime= Time.newInstance(18, 0, 0, 0);
        sample.TuesdayStartTime= Time.newInstance(9, 0, 0, 0);
        sample.TuesdayEndTime= Time.newInstance(18, 0, 0, 0);
        sample.WednesdayStartTime= Time.newInstance(9, 0, 0, 0);
        sample.WednesdayEndTime= Time.newInstance(18, 0, 0, 0);
        sample.ThursdayStartTime= Time.newInstance(9, 0, 0, 0);
        sample.ThursdayEndTime= Time.newInstance(18, 0, 0, 0);
        sample.FridayStartTime= Time.newInstance(9, 0, 0, 0);
        sample.FridayEndTime= Time.newInstance(18, 0, 0, 0);
        
        return sample;
    }
    
    public class BusinessHourWrapper {
        public String dayOfWeek {get; set;}
        public Time startTime {get; set;}
        public Time endTime {get; set;}
        
        public BusinessHourWrapper(BusinessHours businessHour, Date fromDate) {
            String dayOfWeek = DateTimeUtils.dayOfWeek(fromDate);
            
            if ('Mon'.equals(dayOfWeek)) {
                startTime = businessHour.MondayStartTime;
                endTime = businessHour.MondayEndTime;
            } else if ('Tue'.equals(dayOfWeek)) {
                startTime = businessHour.TuesdayStartTime;
                endTime = businessHour.TuesdayEndTime;
            } else if ('Wed'.equals(dayOfWeek)) {
                startTime = businessHour.WednesdayStartTime;
                endTime = businessHour.WednesdayEndTime;
            } else if ('Thu'.equals(dayOfWeek)) {
                startTime = businessHour.ThursdayStartTime;
                endTime = businessHour.ThursdayEndTime;
            } else if ('Fri'.equals(dayOfWeek)) {
                startTime = businessHour.FridayStartTime;
                endTime = businessHour.FridayEndTime;
            } else if ('Sat'.equals(dayOfWeek)) {
                startTime = businessHour.SaturdayStartTime;
                endTime = businessHour.SaturdayEndTime;                
            } else {
                startTime = businessHour.SundayStartTime;
                endTime = businessHour.SundayEndTime;
            }
            
            if (startTime != null && endTime != null) {
                Date dummyDate = Date.newInstance(1970, 1, 1);
                
                DateTime dtStartTime = DateTime.newInstanceGmt(dummyDate, startTime);
                dtStartTime = DateTimeUtils.convertDateTime(dtStartTime, businessHour.TimeZoneSidKey, 'GMT');
                startTime = dtStartTime.timeGmt();
                
                DateTime dtEndTime = DateTime.newInstanceGmt(dummyDate, endTime);
                dtEndTime = DateTimeUtils.convertDateTime(dtEndTime, businessHour.TimeZoneSidKey, 'GMT');
                endTime = dtEndTime.timeGmt();
            }
        }
        
        public boolean validBusinessHour() {
       		return (startTime != null && endTime != null && startTime <= endTime);
    	}
    }
}