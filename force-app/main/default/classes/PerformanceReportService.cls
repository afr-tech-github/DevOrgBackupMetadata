public with sharing class PerformanceReportService {
    private static final String SLA_MET = 'Met';
    private static final String SLA_NOT_MET = 'Not-Met';
    private static final String SLA_NEUTRAL = 'Neutral';
    private Map<String, SLA_Calendar_Settings__c> slaCalendarSettings = new Map<String, SLA_Calendar_Settings__c>();
    
    public PerformanceReportService() {
        loadSLACalendarSettings();
    }
    
    public List<SLA_Calendar_Settings__c> getSLACalendarSettings() {
        return slaCalendarSettings.values();
    }    
    
    public SLAReport buildSLAReport(Date fromDate, Date toDate) {
        SLAReport slaReport = new SLAReport();
        
        if (!slaCalendarSettings.isEmpty()) {
            for (String reportTeam : slaCalendarSettings.keySet()) {
                SLA_Calendar_Settings__c setting = slaCalendarSettings.get(reportTeam);
                String timezone = setting.Timezone__c;
                String prefix = setting.Holiday_Name_Prefix__c;
                String team = setting.Name;
                Map<Id, User> members = findUsersByTimezone(timezone);
                
                if (!members.isEmpty()) {
                    buildSLAReportForHBL(slaReport, fromDate, toDate, timezone, prefix, team, members);
                    buildSLAReportForMBL(slaReport, fromDate, toDate, timezone, prefix, team, members);                
                }
                
            }
        }
        
        return slaReport;
    }
    
    public SLAReport buildSLAReport(Date fromDate, Date toDate, String reportTeam) {
        SLAReport slaReport = new SLAReport();
        SLA_Calendar_Settings__c setting = slaCalendarSettings.get(reportTeam);
        
        if (setting != null) {
            String timezone = setting.Timezone__c;
            String prefix = setting.Holiday_Name_Prefix__c;
            String team = setting.Name;
            Map<Id, User> members = findUsersByTimezone(timezone);
            
            if (!members.isEmpty()) {
                buildSLAReportForHBL(slaReport, fromDate, toDate, timezone, prefix, team, members);
                buildSLAReportForMBL(slaReport, fromDate, toDate, timezone, prefix, team, members);                
            }
        }
        
        return slaReport;
    }
    
    private void buildSLAReportForHBL(SLAReport slaReport, Date fromDate, Date toDate, String timezone, String prefix, String team, Map<Id, User> members) {
        List<Id> createdByIds = new List<Id>(members.keySet());
        List<CustomObject1__c> shipments = getRegisteredShipments(fromDate, toDate, createdByIds);
        
        if (!shipments.isEmpty()) {
            SLAService slaService = new SLAService(timezone, prefix);
            
            for (CustomObject1__c shipment : shipments) {
                DateTime endTime = shipment.First_Approval_Time__c;
                
                if (shipment.First_Approval_Time__c == null) {
                    endTime = System.now(); 
                    endTime.addMinutes(5); // 5 minutes as buffer
                }
                Integer slaDuration = determineSLALength(shipment.Vessel_Type__c);
                Integer actualDuration = slaService.calculateSpentTime(shipment.Document_Receipt_Time__c, endTime);
                Boolean slaStatus = (actualDuration < slaDuration);
                String wkid = 'S' + shipment.WkInitial__c + shipment.Name;
                ReportLine reportLine = new ReportLine('HBL-SHIPMENT', shipment.Id, wkid, shipment.Document_Receipt_Time__c,
                                                 	shipment.First_Approval_Time__c, shipment.Vessel_Type__c, shipment.CarrierType__c, 
                                                    slaStatus, timezone, slaDuration, actualDuration, team, members.get(shipment.CreatedById).Username);
                slaReport.addReportLine(reportLine);
            }
        }
    }
    
    private void buildSLAReportForMBL(SLAReport slaReport, Date fromDate, Date toDate, String timezone, String prefix, String team, Map<Id, User> members) {
        List<Id> createdByIds = new List<Id>(members.keySet());
        List<MasterAnken__c> mblShipments = getRegisteredMasterShipments(fromDate, toDate, createdByIds);
            
        if (!mblShipments.isEmpty()) {
            SLAService slaService = new SLAService(timezone, prefix);
            
            for (MasterAnken__c mbl : mblShipments) {
                DateTime endTime = mbl.First_Approval_Time__c;
                
                if (mbl.First_Approval_Time__c == null) {
                    endTime = System.now(); 
                    endTime.addMinutes(5); // 5 minutes as buffer
                }
                Integer slaDuration = determineSLALength(mbl.Vessel_Type__c);
                Integer actualDuration = slaService.calculateSpentTime(mbl.Document_Receipt_Time__c, endTime);
                Boolean slaStatus = (actualDuration < slaDuration);
                String wkid = mbl.Name;
                ReportLine reportLine = new ReportLine('MBL-SHIPMENT', mbl.Id, wkid, mbl.Document_Receipt_Time__c, 
                                                       mbl.First_Approval_Time__c, mbl.Vessel_Type__c, 'N/A', slaStatus, timezone, 
                                                       slaDuration, actualDuration, team, members.get(mbl.CreatedById).Username);
                slaReport.addReportLine(reportLine);
            }
        }
    }
    
    private void loadSLACalendarSettings() {
        slaCalendarSettings = new Map<String, SLA_Calendar_Settings__c>([SELECT Name, Timezone__c, Holiday_Name_Prefix__c, Order__c 
                                                                         FROM SLA_Calendar_Settings__c 
                                                                         WHERE Active__c = TRUE ORDER BY Order__c ASC]);
    }
    
    private List<CustomObject1__c> getRegisteredShipments(Date fromDate, Date toDate, List<Id> createdByIds) {
        DateTime fromTime = (fromDate != null ? Datetime.newInstanceGmt(fromDate.year(), fromDate.month(), fromDate.day(), 0, 0, 0) : null);
        DateTime toTime = (toDate != null ? Datetime.newInstanceGmt(toDate.year(), toDate.month(), toDate.day(), 23, 59, 59) : null);
        String selectClause = 'SELECT Id, Name, CreatedById, WkInitial__c, Document_Receipt_Time__c, First_Approval_Time__c, Vessel_Type__c, CarrierType__c';
        String fromClause = ' FROM CustomObject1__c ';
        String whereClause = ' WHERE Document_Receipt_Time__c != null AND (Vessel_Type__c = \'' 
            						+ PicklistReference.VESSEL_FERRY + '\' OR Vessel_Type__c = \'' 
            						+ PicklistReference.VESSEL_CONTAINER_FERRY + '\') AND (CreatedById IN ' + buildInClauseValues(createdByIds) + ')';
        
        if (fromTime != null && toTime != null) {
            whereClause += ' AND Document_Receipt_Time__c >= :fromTime AND Document_Receipt_Time__c <= :toTime';
        } else if (fromTime != null) {
            whereClause += ' AND Document_Receipt_Time__c >= :fromTime';
        } else if (toTime != null) {
            whereClause += ' AND Document_Receipt_Time__c <= :toTime';
        }

        if (PermissionValidationUtil.isAccessibleHBL()) {
        	return Database.query(selectClause + fromClause + whereClause);    
        }
        
        return (new List<CustomObject1__c>());
    }
    
    private List<MasterAnken__c> getRegisteredMasterShipments(Date fromDate, Date toDate, List<Id> createdByIds) {
        DateTime fromTime = (fromDate != null ? Datetime.newInstanceGmt(fromDate.year(), fromDate.month(), fromDate.day(), 0, 0, 0) : null);
        DateTime toTime = (toDate != null ? Datetime.newInstanceGmt(toDate.year(), toDate.month(), toDate.day(), 23, 59, 59) : null);
        String selectClause = 'SELECT Id, Name, CreatedById, Document_Receipt_Time__c, First_Approval_Time__c, Vessel_Type__c';
        String fromClause = ' FROM MasterAnken__c ';
        String whereClause = ' WHERE Document_Receipt_Time__c != null AND (Vessel_Type__c = \'' 
            						+ PicklistReference.VESSEL_FERRY + '\' OR Vessel_Type__c = \'' 
            						+ PicklistReference.VESSEL_CONTAINER_FERRY + '\') AND (CreatedById IN ' + buildInClauseValues(createdByIds) + ')';
        
        if (fromTime != null && toTime != null) {
            whereClause += ' AND Document_Receipt_Time__c >= :fromTime AND Document_Receipt_Time__c <= :toTime';
        } else if (fromTime != null) {
            whereClause += ' AND Document_Receipt_Time__c >= :fromTime';
        } else if (toTime != null) {
            whereClause += ' AND Document_Receipt_Time__c <= :toTime';
        }

        if (PermissionValidationUtil.isAccessibleMBL()) {
        	return Database.query(selectClause + fromClause + whereClause);    
        }
        
        return (new List<MasterAnken__c>());
    }
    
    private static Integer determineSLALength(String vesselType) {
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();
        Integer slaLength = 0;
        
        if (PicklistReference.VESSEL_FERRY.equals(vesselType)) {
            slaLength = (Integer) (setting.Ferry_SLA__c > 0 ? setting.Ferry_SLA__c : 0); // minutes
        } else if (PicklistReference.VESSEL_CONTAINER_FERRY.equals(vesselType)) {
            slaLength = (Integer) (setting.Container_Vessel_SLA__c > 0 ? setting.Container_Vessel_SLA__c : 0); // minutes
        }
        
        return slaLength;
    }
    
    private Map<Id, User> findUsersByTimezone(String timezone) {
        if (PermissionValidationUtil.isAccessibleUser()) {
            return new Map<Id, User>([SELECT Id, Username FROM User WHERE TimezoneSidKey = :timezone]);
        }
        
        return (new Map<Id, User>());
    }
    
    private String buildInClauseValues(List<Id> ids) {
        String result = '';
        
        for (Id item : ids) {
        	result += ',\'' + item + '\'';    
        }
        result = result.replaceFirst(',', '');
        result = '(' + result + ')';
        
        return result;
    }
    
    public class ReportLine implements Comparable {
        public String reportObject {get; private set;}
        public Id referenceId {get; private set;}
        public String referenceName {get; private set;}
        public DateTime receivedTime {get; private set;}
        public DateTime completedTime {get; private set;}
        public String vesselType {get; private set;}
        public String transportType {get; private set;}
        public String slaStatus {get; private set;}
        public Integer slaDuration {get; private set;}
        public Integer actualDuration {get; private set;}
        public String dataEntryUser {get; private set;}
        public String team {get; private set;}
        private Integer weight;     
        
        public ReportLine(String reportObject, Id referenceId, String referenceName, Datetime receivedTime, 
                          DateTime completedTime, String vesselType, String transportType, Boolean sla, String timezone, 
                          Integer slaDuration, Integer actualDuration, String team, String dataEntryUser) {
            this.reportObject = reportObject;
            this.referenceId = referenceId;
            this.referenceName = referenceName;
            this.vesselType = vesselType;
            this.transportType = transportType;
            this.receivedTime = DateTimeUtils.convertDateTime(receivedTime, 'GMT', timezone);
			this.slaDuration = slaDuration;
			this.actualDuration = actualDuration;
			this.team = team;
			this.dataEntryUser = dataEntryUser;

            if (completedTime != null) {
                this.completedTime = DateTimeUtils.convertDateTime(completedTime, 'GMT', timezone);    
            }
            
            if (sla) {
                if (completedTime == null) {
                    weight = 2;
                    this.slaStatus = SLA_NEUTRAL;
                } else {
                    this.slaStatus = SLA_MET;
                    weight = 3;
                }
            } else        {
                this.slaStatus = SLA_NOT_MET;
                weight = 1;
            }
        }
        
        public Integer compareTo(Object obj) {
            ReportLine compareToObj = (ReportLine) obj;
            
            if (this.weight > compareToObj.weight) {
                return 1;
            } else if (this.weight < compareToObj.weight) {
                return -1;
            } else {
                return 0;
            }
        }
    }
    
    public class SLAReport {
        public Integer metSLACount {get; private set;}
        public Integer notMetSLACount {get; private set;}
        public Integer neutralSLACount {get; private set;}
        public List<ReportLine> reportLines {get; private set;}
        
        public SLAReport() {
            reportLines = new List<ReportLine>();
            metSLACount = 0;
            notMetSLACount = 0;
            neutralSLACount = 0;
        }
        
        public void addReportLine(ReportLine reportLine) {
            reportLines.add(reportLine);
            
            if (SLA_MET.equals(reportLine.slaStatus)) {
                metSLACount++;
            } else if (SLA_NOT_MET.equals(reportLine.slaStatus)) {
                notMetSLACount++;
            } else if (SLA_NEUTRAL.equals(reportLine.slaStatus)) {
                neutralSLACount++;
            }
        }
    }
}