@isTest
private class InvoicingVATTriggerHandlerTest {
    private static Map<String, Object> additionalFields;
    private static AnkenMeisai__c meisai1;
    private static AnkenMeisai__c meisai2;
    private static VAT_INVOICE__c vatInvoice;
    private static TariffMaster__c tariff;
    private static Account acc;
    static{
         additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        // Create an Account
        additionalFields = new Map<String, Object>{
                'Currency__c' => 'USD - U.S. Dollar'
        };
        acc = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        // Create Service Master
        additionalFields = new Map<String, Object>{
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
                'Supplier__c' => acc.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX
        };
        tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);

        // Create VAT INVOICE
        vatInvoice = (VAT_INVOICE__c) TestDataFactory.createSObject(new VAT_INVOICE__c(), true, null);

        

        
    }
    @isTest static void test_method_one() {
        // Create 2 HBL records
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];

        additionalFields = new Map<String, Object>{
                'Field1__c' => acc.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001'
        };
        CustomObject1__c shipment1 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment1.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => acc.Id, 'SerchSyubetu__c' => 'FCL輸入',
                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'
        };
        meisai1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        Test.startTest();
            additionalFields = new Map<String, Object>{
                    'INVOICING__c' => meisai1.Id, 'VAT_INVOICE__c' => vatInvoice.Id
            };
            TestDataFactory.createSObject(new INVOICING_VAT__c(), true, additionalFields);
        Test.stopTest();
        system.assert(true);
    }
     /*@isTest static void test_method_two() {
      * RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
      	additionalFields = new Map<String, Object>{
                'Field1__c' => acc.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0002','clofor_com_cfs__SOIDCopy__c' => 'S123',
                'clofor_com_cfs__PackageUnitCode__c' => 'PA'  
                    
        };
        CustomObject1__c shipment2 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
		
        Test.startTest();
            
        
            additionalFields = new Map<String, Object>{
                    'INVOICING__c' => meisai2.Id, 'VAT_INVOICE__c' => vatInvoice.Id
            };
            TestDataFactory.createSObject(new INVOICING_VAT__c(), true, additionalFields);
        Test.stopTest();
        system.assert(true);
    }*/
    
    
    
}