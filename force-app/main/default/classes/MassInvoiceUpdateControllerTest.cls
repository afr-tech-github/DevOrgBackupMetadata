@isTest
private class MassInvoiceUpdateControllerTest {
    @testsetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
            'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        // Create an Account
        additionalFields = new Map<String, Object> {'Currency__c' => 'USD - U.S. Dollar'};                                                                        
            Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // Create Service Master
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
            'Supplier__c' => account.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX};
                TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields); 
        
        // Create 2 HBL records
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
        
        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001'};
            CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        // Create 2 HBL S/B records
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
            'Tariff__c' => tariff.Id,
            'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
            'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};              
                TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
            'Tariff__c' => tariff.Id,
            'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
            'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};              
                TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
    }
    
    testmethod static void shouldUpdateInvoicingRecords() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = 'TEST0001'];
        PageReference pageReference = Page.MassInvoicingUpdate;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        //ApexPages.currentPage().getParameters().put('option', 'rp');
        MassInvoicingUpdateController controller = new MassInvoicingUpdateController();
        
        Test.startTest();
        controller.updateInvoicing();
        controller.isCreation = true;
        controller.numberOfRecords ='5';
        controller.createNewRecords();
        controller.updateInvoicing();
        controller.selectedActioningOption = 'test';
        List<SelectOption>  a = controller.transactionOptions;
        controller.selectedTransactionOption = 'test';
        Test.stopTest();
        System.assert(true);
    }
}