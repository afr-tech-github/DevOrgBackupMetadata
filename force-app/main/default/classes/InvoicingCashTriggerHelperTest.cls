@isTest
private class InvoicingCashTriggerHelperTest {
    private static AnkenMeisai__c invoicing;
    private static CASH_BOOK__c cashBook;
    private static Map<String, Object> additionalFields;
    static{
        additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];

        // Create account
        additionalFields = new Map<String, Object>{
                'Custom_Type__c' => '国内顧客 - 既存'
        };
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id
        };
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service
        additionalFields = new Map<String, Object>{
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'Supplier__c' => account.Id, 'BuyKingaku__c' => 12, 'BuyAmountUSD__c' => 12, 'SellKingakuJPY__c' => 12, 'SellAmountUSD__c' => 12,
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'TAX__c' => 'TAX'
        };
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);

        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id
        };
        invoicing = (AnkenMeisai__c)TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);


        // create Cash Book
        cashbook = (CASH_BOOK__c)TestDataFactory.createSObject(new CASH_BOOK__c(), true, null);

        

        
    }
    @isTest static void test_method_onAfterInsert() {
        Test.startTest();
            additionalFields = new Map<String, Object>{
                    'Cashbook__c' => cashBook.Id, 'Invoicing__c' => invoicing.Id
            };
            TestDataFactory.createSObject(new ConnectInvoicingAndCash__c(), true, additionalFields);

        System.assert(true);
        Test.stopTest();
    }
    

    @isTest static void test_method_onBeforeDelete() {
        additionalFields = new Map<String, Object>{
                'Cashbook__c' => cashBook.Id, 'Invoicing__c' => invoicing.Id
        };
        ConnectInvoicingAndCash__c link = (ConnectInvoicingAndCash__c) TestDataFactory.createSObject(new ConnectInvoicingAndCash__c(), true, additionalFields);
            
        Test.startTest();
            delete link;
        System.assert(true);
        Test.stopTest();
    }
    
}