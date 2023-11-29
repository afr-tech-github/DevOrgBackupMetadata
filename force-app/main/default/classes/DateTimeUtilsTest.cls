@IsTest
public with sharing class DateTimeUtilsTest {
    @IsTest
    static void TestDateTimeUtils() {
    DateTime beginTime = DateTime.newInstance(1997, 1, 31, 10, 8, 16);
    DateTime endTime = beginTime.addMinutes(3);
    Date date1 = Date.newInstance(1997, 1, 31);
    Date date2 = Date.newInstance(1997, 2, 1);
    List<date> lstdate = new List<Date>();
    lstdate.add(date1);
    lstdate.add(date2);
    System.assertEquals(3,DateTimeUtils.timeDiffInMinutes(beginTime,endTime));
    Datetime datetimtest = DateTimeUtils.convertDateTime(beginTime, 'America/New_York', 'GMT');
    Date datetest = DateTimeUtils.parseDate('2022/02/01', '/');
    String dayweek = DateTimeUtils.dayOfWeek(date1);
    System.assertEquals(180000,DateTimeUtils.timeDiffInMilliseconds(date1, beginTime.timeGmt(), endTime.timeGmt()));
    System.assertEquals(false,DateTimeUtils.isSameDate(date1, date2, true));
    System.assertEquals(date2,DateTimeUtils.maxDates(lstdate));
    System.assertEquals(date1,DateTimeUtils.minDates(lstdate));
    String dateformat = DateTimeUtils.getDateFormat();
    }
}