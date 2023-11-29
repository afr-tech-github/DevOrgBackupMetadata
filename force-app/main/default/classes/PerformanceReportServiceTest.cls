@isTest(SeeAllData=false)
private class PerformanceReportServiceTest {
    @testSetup static void setUp() {
        // Setup running user with timezone match test data
        Profile p = [SELECT Id FROM Profile WHERE UserType='Standard' LIMIT 1]; 
        DateTime currentTime = System.now();
        String username = 'dummy.' + currentTime.millisecond() + '@sample.com';
        User u = new User(Alias = 'alias', Email=username, 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='vi', 
                          LocaleSidKey='vi_VN', ProfileId = p.Id, 
                          TimeZoneSidKey='Asia/Ho_Chi_Minh', UserName=username);
        Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
         setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        System.runAs(u) {
            RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
            Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
            DateTime receiptTime = DateTime.newInstanceGmt(Date.newInstance(2016, 1, 19), Time.newInstance(2, 0, 0, 0));
            DateTime metSLATime = DateTime.newInstanceGmt(Date.newInstance(2016, 1, 19), Time.newInstance(4, 0, 0, 0));
            DateTime missedSLATime = DateTime.newInstanceGmt(Date.newInstance(2016, 1, 19), Time.newInstance(8, 0, 0, 0));
            
            // Setup HBL
            Map<String, Object> additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 
                                        'CarrierType__c' => PicklistReference.TRANSPORT_TYPE_AIR, 'Vessel_Type__c' => PicklistReference.VESSEL_FERRY, 
                                        'Document_Receipt_Time__c' => receiptTime, 'First_Approval_Time__c' => metSLATime};
            TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
            
            additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 
                                        'CarrierType__c' => PicklistReference.TRANSPORT_TYPE_SEA_AIR, 'Vessel_Type__c' => PicklistReference.VESSEL_CONTAINER_FERRY, 
                                        'Document_Receipt_Time__c' => receiptTime, 'First_Approval_Time__c' => missedSLATime};
            TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
            
            // Setup MBL
            additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
                                                        'LoadLocationPIC__c' => 'LoadLocationPIC'};
            LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
            additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id, 
                                        'Document_Receipt_Time__c' => receiptTime, 'First_Approval_Time__c' => metSLATime, 
                						'Vessel_Type__c' => PicklistReference.VESSEL_FERRY};
            TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
            
            // Setup SLA Calendar Settings
            additionalFields = new Map<String, Object> {'Name' => 'Test Vietnam Team', 'Timezone__c' => 'Asia/Ho_Chi_Minh', 
                'Holiday_Name_Prefix__c' => 'Vi', 'Active__c' => true, 'Order__c' => 1};
            TestDataFactory.createSObject(new SLA_Calendar_Settings__c(), true, additionalFields);
            
            additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
            	'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
			TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        }
    }
    
    testmethod static void shouldBuildSLAReport() {
        SLA_Calendar_Settings__c setting = [SELECT Id FROM SLA_Calendar_Settings__c WHERE Name = 'Test Vietnam Team' LIMIT 1];
        Date fromDate = Date.newInstance(2016, 1, 10);
        Date toDate = Date.newInstance(2016, 1, 22);
        String reportTeam = setting.Id;
        PerformanceReportService service = new PerformanceReportService();
        
        Test.startTest();
        PerformanceReportService.SLAReport report = service.buildSLAReport(fromDate, toDate, reportTeam);
        Test.stopTest();
        System.assertEquals(3, report.reportLines.size());
    }
    
    testmethod static void shouldBuildSLAReportWithoutSpecifyingPeriod() {
        SLA_Calendar_Settings__c setting = [SELECT Id FROM SLA_Calendar_Settings__c WHERE Name = 'Test Vietnam Team' LIMIT 1];
        String reportTeam = setting.Id;
        PerformanceReportService service = new PerformanceReportService();
        
        Test.startTest();
        PerformanceReportService.SLAReport report = service.buildSLAReport(null, null, reportTeam);
        Test.stopTest();
        System.assertEquals(3, report.reportLines.size());
    }
    
    testmethod static void shouldBuildSLAReportWithOnlyFromDate() {
        SLA_Calendar_Settings__c setting = [SELECT Id FROM SLA_Calendar_Settings__c WHERE Name = 'Test Vietnam Team' LIMIT 1];
        String reportTeam = setting.Id;
        Date fromDate = Date.newInstance(2016, 1, 10);
        PerformanceReportService service = new PerformanceReportService();
        
        Test.startTest();
        PerformanceReportService.SLAReport report = service.buildSLAReport(fromDate, null, reportTeam);
        Test.stopTest();
        System.assertEquals(3, report.reportLines.size());
    }
    
    testmethod static void shouldBuildSLAReportWithOnlyToDate() {
        SLA_Calendar_Settings__c setting = [SELECT Id FROM SLA_Calendar_Settings__c WHERE Name = 'Test Vietnam Team' LIMIT 1];
        String reportTeam = setting.Id;
        Date toDate = Date.newInstance(2016, 1, 22);
        PerformanceReportService service = new PerformanceReportService();
        
        Test.startTest();
        PerformanceReportService.SLAReport report = service.buildSLAReport(null, toDate, reportTeam);
        Test.stopTest();
        System.assertEquals(3, report.reportLines.size());
    }
}