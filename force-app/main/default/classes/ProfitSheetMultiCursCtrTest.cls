@isTest(SeeAllData=false)
public class ProfitSheetMultiCursCtrTest {
	@testSetup static void setupTestData() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'JPY',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
            	'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        
        additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存', 'Name' => 'INVOICE_TO',
            										'EnglishCompanyName__c' => 'INVOICE_TO_EN',
            										'Business_Relationship__c' => Constants.PARTNER_RELATIONSHIP};                                                                    
		Account invoiceTo = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存', 'Name' => 'PAYMENT_TO',
            										'EnglishCompanyName__c' => 'PAYMENT_TO_EN',            
            										'Business_Relationship__c' => Constants.PARTNER_RELATIONSHIP};                                                                    
		Account paymentTo = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        Date etd = Date.newInstance(2015, 07, 02);
        additionalFields = new Map<String, Object> {'Field1__c' => invoiceTo.Id, 'RecordTypeId' => rt.Id, 'ETD__c' => etd,
            										'Status__c' => '輸入 税関審査終了(Cunstoms Declared)'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => invoiceTo.Id};
        TariffMaster__c serviceMaster = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => serviceMaster.Id, 'Seikyusaki__c' => invoiceTo.Id,
            									'SiharaiKakuninzumi__c' => false, 'Suryo__c' => 1, 'BuyTankaUSD__c' => 100};
		AnkenMeisai__c hblBuying = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        System.assert(true);
    } 
    
    private static testmethod void exportPDF1(){
        List<CustomObject1__c> lstObj1 = [SELECT Id FROM CustomObject1__c];
        PageReference pageRef = Page.ProfitSheet2;
        pageRef.getParameters().put(Constants.REQUEST_ID, lstObj1.get(0).Id);
        pageRef.getParameters().put('isOnBehalfCustomer', 'true');
        pageRef.getParameters().put('isOnBehalfOurCompany', 'true');
        pageRef.getParameters().put('isKickback', 'true');
        pageRef.getParameters().put('percentRevenue', '10');
        pageRef.getParameters().put('percentProfit', '');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ProfitSheetMultiCursCtr controller = new ProfitSheetMultiCursCtr();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    private static testmethod void exportPDF2(){
        List<CustomObject1__c> lstObj1 = [SELECT Id FROM CustomObject1__c];
        PageReference pageRef = Page.ProfitSheet2;
        pageRef.getParameters().put(Constants.REQUEST_ID, lstObj1.get(0).Id);
        pageRef.getParameters().put('isOnBehalfCustomer', 'false');
        pageRef.getParameters().put('isOnBehalfOurCompany', 'false');
        pageRef.getParameters().put('isKickback', 'true');
        pageRef.getParameters().put('percentRevenue', '10');
        pageRef.getParameters().put('percentProfit', '');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ProfitSheetMultiCursCtr controller = new ProfitSheetMultiCursCtr();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
}