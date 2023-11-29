@isTest
public class DCBDetailReportControllerTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }
    
    static testmethod void shouldGenerateDetailReport() {
        Date etd = Date.newInstance(2015, 07, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存', 'Business_Relationship__c' => 'Customer'};                                                                    
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        
        additionFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionFields);

		additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'ETD__c' => etd, 'Status__c' => '輸入 税関審査終了(Cunstoms Declared)', 'RecordTypeId' => rt.Id, 'clofor_com_cfs__POD__c' => objPort.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
                
        additionFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionFields);                                                                 
        additionFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id,'Seikyusaki__c' => account.Id,
            									'NyukinKakuninzumi__c' => false};
		AnkenMeisai__c mei1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionFields);
        AnkenMeisai__c mei2 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionFields);
        
        PageReference ref = Page.page_DCBReportPDF;
        Test.setCurrentPage(ref);
        
        List<AnkenMeisai__c> lstAnlen = [SELECT Id FROM AnkenMeisai__c];
        
		ApexPages.currentPage().getParameters().put('customerId', account.Id);
        ApexPages.currentPage().getParameters().put('customerName', 'CustomerName');
        ApexPages.currentPage().getParameters().put('customerENName', 'CustomerENName');
        ApexPages.currentPage().getParameters().put('reportOption', '1');
        ApexPages.currentPage().getParameters().put('fromDate', '2015-06-30');
        ApexPages.currentPage().getParameters().put('toDate', '2015-08-01');
        ApexPages.currentPage().getParameters().put('relationship', Constants.PARTNER_RELATIONSHIP);
        ApexPages.currentPage().getParameters().put('currency', 'USD');
        ApexPages.currentPage().getParameters().put('strWkid', String.valueOf(lstAnlen.get(0).Id));
        ApexPages.currentPage().getParameters().put('searchType', 'SHIPMENTORDER');
        
        Test.startTest();
        DCBDetailReportController controller = new DCBDetailReportController();
        Test.stopTest();
        
        DCB_SubReportWrapper report = controller.customerReport;
        // System.assertEquals(0, report.lineItems.size());
    }
}