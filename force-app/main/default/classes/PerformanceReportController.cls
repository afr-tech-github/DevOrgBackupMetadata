public with sharing class PerformanceReportController {
    private static final String ALL_TEAM_OPTION = 'all';
    public PerformanceReportService.SLAReport slaReport {get; private set;}
    public List<SelectOption> teams {get; private set;}
    public String selectedTeam {get; set;}
    public String fromDate {get; set;}
    public String toDate {get; set;}
    private PerformanceReportService prService;
    
    public PerformanceReportController() {
        slaReport = new PerformanceReportService.SLAReport();
        prService = new PerformanceReportService();
        setupTeamOptions();
    }

    public void generateReport() {
        Date fromDate = null;
        Date toDate = null;
        
        if (!StringUtils.isEmpty(this.fromDate)) {
            fromDate = DateTimeUtils.parseDate(this.fromDate, '/');    
        }
        
        if (!StringUtils.isEmpty(this.toDate)) {
            toDate = DateTimeUtils.parseDate(this.toDate, '/');
        }
        
        if (fromDate != null && toDate != null && fromDate > toDate) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'From Date cannot be greater than To Date. Please select dates again'));
        } else {
            if (ALL_TEAM_OPTION.equals(selectedTeam)) {
	            slaReport = prService.buildSLAReport(fromDate, toDate);    
            } else {
			    slaReport = prService.buildSLAReport(fromDate, toDate, selectedTeam);            
            }
            
            slaReport.reportLines.sort();
        }        
    }
    
    public PageReference exportExcel() {
        PageReference ref = Page.PerformanceReportExcel;
        ref.setRedirect(false);
        return ref;
    }

    public PageReference exportPDF() {
        PageReference ref = Page.PerformanceReportPDF;
        ref.setRedirect(false);
        return ref;
    }
    
    private void setupTeamOptions() {
        List<SLA_Calendar_Settings__c> settings = prService.getSLACalendarSettings();
        teams = new List<SelectOption>();
        
        teams.add(new SelectOption(ALL_TEAM_OPTION, 'All Teams'));
        for (SLA_Calendar_Settings__c setting : settings) {
            teams.add(new SelectOption(setting.Id, setting.Name));
        }
    }
}