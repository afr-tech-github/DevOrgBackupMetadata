public class DateTimeUtils {
    public static Integer timeDiffInMinutes(DateTime fromTime, DateTime toTime) {
        return ((Integer) (toTime.getTime() - fromTime.getTime())/60000);
    }

    public static DateTime convertDateTime(DateTime gmtTime, String sourceTz, String destTz) {
        TimeZone customerTimeZone = TimeZone.getTimeZone(sourceTz);
        Integer offsetToCustomersTimeZone = customerTimeZone.getOffset(gmtTime);
        
        TimeZone tz = TimeZone.getTimeZone(destTz);
        Integer offsetToUserTimeZone = tz.getOffset(gmtTime);
        
        Integer correction = offsetToUserTimeZone - offsetToCustomersTimeZone;
        DateTime result = gmtTime.addMinutes(correction / (1000 * 60));

        return result;
    }
    
    /**
     * Require date string format as yyyy<delimiter>MM<delimiter>dd
     */ 
    public static Date parseDate(String dateString, String delimiter) {
        if (StringUtils.isEmpty(dateString) || StringUtils.isEmpty(delimiter)) {
            return null;
        }
            
        String[] tokens = dateString.split(delimiter);
        return Date.newInstance(Integer.valueOf(tokens[0]), Integer.valueOf(tokens[1]), Integer.valueOf(tokens[2]));
    }
    
    public static String dayOfWeek(Date dateToCheck) {
        if (dateToCheck != null) {
            DateTime dt = DateTime.newInstance(dateToCheck.year(), dateToCheck.month(), dateToCheck.day());
            return dt.format('E');
        } else {
            return null;
        }
    }
    
    public static boolean isSameDate(Date d1, Date d2, Boolean includedYear) {
        if (includedYear) {
	        return (d1 == d2);    
        } else {
            return ((d1.month() == d2.month()) && (d1.day() == d2.day()));
        }
    }
    
    public static Long timeDiffInMilliseconds(Date theDate, Time fromTime, Time toTime) {
        DateTime st = DateTime.newInstanceGmt(theDate, fromTime);
        DateTime et = DateTime.newInstanceGmt(theDate, toTime);
        return (et.getTime() - st.getTime());
    }
    
    public static Date maxDates(List<Date> values) {
        Date result = null;
        
        if (values != null && !values.isEmpty()) {
            for (Date value : values) {
                if (result == null || result < value) {
                    result = value;
                }
            }
        }
        
        return result;
    }
    
    public static Date minDates(List<Date> values) {
        Date result = null;
        
        if (values != null && !values.isEmpty()) {
            for (Date value : values) {
                if (result == null || result > value) {
                    result = value;
                }
            }
        }
        
        return result;
    }

    public static String getDateFormat() {
        Site_Custom_Settings__c settings = Site_Custom_Settings__c.getOrgDefaults();

        if (!StringUtils.isEmpty(settings.Custom_Date_Format__c)) {
            return settings.Custom_Date_Format__c;
        }

        return Constants.DEFAULT_DATE_FORMAT;
    }
}