@IsTest
public with sharing class UtilTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        // Setup an Account
        Date printDate = Date.newInstance(2015, 09, 09);
        additionalFields = new Map<String, Object>{
                'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING,
                'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
                'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong'
        };
        Account domesticCustomer = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        // Setup a SHIPMENT ORDER
        String shipmentRecordTypeOceIm = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.OCEAN_IMPORT_RT);
        additionalFields = new Map<String, Object>{
                'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeOceIm,
                'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        };
        CustomObject1__c shipmentOrder = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
            'Anken__c' => shipmentOrder.Id,'Suryo__c'=>3.000,'SellTankaJPY__c'=>0,'TaxInitial__c'=>0,'TAX_ADJUSTMENTSELL__c'=>0,'BuyTankaJPY__c'=>0
            ,'BuyTaxInitial__c'=>0,'Cost_Allocation_Margin__c'=>0
        }; 
        AnkenMeisai__c bill = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
            'AccoutantFullName__c' => 'Test1234'
        };
        CASH_BOOK__c cash = (CASH_BOOK__c) TestDataFactory.createSObject(new CASH_BOOK__c(), true, additionalFields);
    }

    @IsTest
    static void TestUnit() {
    System.assertEquals(5,Util.ConvertWeightToBaseUnit('g',5));
    System.assertEquals(null,Util.ConvertWeightToBaseUnit('g',null));
    System.assertEquals(5,Util.ConvertWeightFromBaseUnit('g',5));
    System.assertEquals(null,Util.ConvertWeightFromBaseUnit('g',null));
    System.assertEquals(5000,Util.ConvertWeightToUnit('Kg','g',5));
    System.assertEquals(5,Util.ConvertWeightToUnit('g','g',5));
    }
    @IsTest
    static void TestgetObjectCustomFields() {
        List<String> lstfield = Util.getObjectCustomFields(CustomObject1__c.SObjectType);
        System.assertEquals('a06',Util.getObjectTypeId('clofor_com_cfs__CustomObject1__c'));
        // System.assertEquals(true,ObjectClassificationUtils.isOverseaCustomerOrPartner('海外'));
        }
    @IsTest
    static void TestURL(){
        String url = Util.getServerInstance();
        String domain = Util.getServerInstanceByDomainName('quan');
        String domain2 = Util.getSFDomainFromBaseURL('https://api.status.salesforce.com/v1/instanceAliases/quan');
        // System.assertEquals(true,ObjectClassificationUtils.isImportMBL('import'));
    }
    @IsTest
    static void TestCashBook(){
        CASH_BOOK__c cash = [SELECT id,RecordTypeId FROM CASH_BOOK__c LIMIT 1];
        System.assertEquals(true,Util.isCashOut(cash));
        System.assertEquals(false,Util.isCashIn(cash));
    }
    @IsTest
    static void TestBill(){
        AnkenMeisai__c bill = [SELECT id,RecordTypeId,Suryo__c,SellTankaJPY__c,TaxInitial__c,TAX_ADJUSTMENTSELL__c,BuyTankaJPY__c,BuyTaxInitial__c,Cost_Allocation_Margin__c FROM AnkenMeisai__c LIMIT 1];
        System.assertEquals(0,Util.calculateSellingAmount(bill));
        System.assertEquals(0,Util.calculateBuyingAmount(bill));
        System.assertEquals(0,Util.calculateBuyingInTaxAmount(bill));
        System.assertEquals(0,Util.calculateSellingInTaxAmount(bill));
    }
    @IsTest
    static void TestField(){
        AnkenMeisai__c bill = [SELECT id,RecordTypeId FROM AnkenMeisai__c LIMIT 1];
        Map<String, Amount_Wording_Setting__mdt> wordingFieldMap = new Map<String, Amount_Wording_Setting__mdt>(); 
        Util.listOutFieldsWordingForObject('clofor_com_cfs__CustomObject1__c');
        Util.wordingFields(bill,wordingFieldMap);
    }
}