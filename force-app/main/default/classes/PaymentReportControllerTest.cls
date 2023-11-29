@isTest
private class PaymentReportControllerTest {
	private static CustomObject1__c forwarding;
	private static Account customer;
	static{
		
		Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
            	'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        // Create an Account
        additionalFields = new Map<String, Object> {'Currency__c' => 'USD - U.S. Dollar'};                                                                        
        customer = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // Create 2 HBL records
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
        additionalFields = new Map<String, Object> {'Field1__c' => customer.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001'};
        forwarding = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
									            'Supplier__c' => customer.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        RecordType rtAnken = [Select Id from RecordType where DeveloperName !=: Constants.SELLING_BUYING_CONSOLIDATION_RT and SObjectType = 'clofor_com_cfs__AnkenMeisai__c' AND IsActive = true Limit 1];
        additionalFields = new Map<String, Object> {'Anken__c' => forwarding.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
            									'Tariff__c' => tariff.Id, 
            									'Seikyusaki__c' => customer.Id, 'SerchSyubetu__c' => 'FCL輸入',
            									'Cost_Allocation_Catetory__c' => 'Partner Cost allocation',
												'Suryo__c' => 5,
            									'SellTankaUSD__c' => 5,
            									'PrintFlag__c' => true,
            									'RecordTypeId' => rtAnken .Id };              
		TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        TestDataFactory.createSObject(new VAT_INVOICE__c(), true, null);
	}
	@isTest static void test_method_one() {
		Test.startTest();
		ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, forwarding.Id);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_REPORT_NAME, 'debitnote');
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_LANGUAGE,'en' );
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_CUSTOMER_ID, customer.Id);
		// Implement test code
		PaymentReportController ctrl = new PaymentReportController();
		system.assert(forwarding.Id != null);
		Test.stopTest();
	}
	
	
	
}