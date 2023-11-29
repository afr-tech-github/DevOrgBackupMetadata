/**
 * Created by khanhpham on 6/22/17.
 */

public with sharing class LogTimeController {
    public Date workingDate { get; private set; }
    public boolean disabledEnterButton { get; private set; }
    public boolean disabledLeaveButton { get; private set; }
    public TimeEntry__c timeEntry { get; private set; }
    public Decimal loggedTime { get; private set; }
    public String errorMessage { get; private set; }
//    private static TimeEntryService teService = new TimeEntryService();

    public LogTimeController() {
    }

    public void enter() {
    }

    public void leave() {
    }

    private void initialize() {
    }
}