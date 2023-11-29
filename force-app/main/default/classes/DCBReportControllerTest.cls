@isTest
private class DCBReportControllerTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        Date etd = Date.newInstance(2015, 07, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存', 'Business_Relationship__c' => 'Customer'};                                                                    
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionalFields);

		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'ETD__c' => etd, 'Status__c' => '輸入 税関審査終了(Cunstoms Declared)', 'RecordTypeId' => rt.Id, 'clofor_com_cfs__POD__c' => objPort.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);                                                                 
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id, 'Seikyusaki__c' => account.Id,
            									'NyukinKakuninzumi__c' => false};
		AnkenMeisai__c mei1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        AnkenMeisai__c mei2 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
    }
    
    testmethod static void shouldGeneratePDFReport() {
        PageReference pageReference = Page.page_OutstandingStatementReport;
        Test.setCurrentPage(pageReference);
        DCBReportController controller = new DCBReportController();
        controller.pageType = 'pdf';
        
        Test.startTest();
        PageReference result = controller.generateCustomerReport();
        Test.stopTest();
        System.assertEquals('/apex/' + Constants.NAMESPACE + 'page_dcbreportpdf_en', result.getUrl().toLowerCase());
    }
    
    testmethod static void shouldGenerateExcelReport() {
        PageReference pageReference = Page.page_OutstandingStatementReport;
        Test.setCurrentPage(pageReference);
        DCBReportController controller = new DCBReportController();
        controller.pageType = 'excel';
        
        Test.startTest();
        PageReference result = controller.generateCustomerReport();
        Test.stopTest();
        System.assertEquals('/apex/' + Constants.NAMESPACE + 'page_dcbreportexcel_en', result.getUrl().toLowerCase());
    }
}