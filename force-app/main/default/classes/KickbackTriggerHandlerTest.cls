/**
 * Created by khanhpham on 12/23/17.
 */
@IsTest(SeeAllData=false)
private with sharing class KickbackTriggerHandlerTest {
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
        String shipmentRecordType = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.OCEAN_IMPORT_RT);
        additionalFields = new Map<String, Object>{
                'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordType,
                'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        };
        CustomObject1__c shipmentOrder = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // Setup an Exchange Rate record
        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object>{
                'Mgmt_Exrate_Start_Date__c' => startDate, 'Mgmt_Exrate_End_Date__c' => endDate,
                'Mgmt_Exrate_FowardingtoDomesticCustomer__c' => 100, 'Mgmt_Exrate_SellingtoPartner__c' => 130,
                'Mgmt_Exrate_BuyingfromPartner__c' => 200, 'Mgmt_Exrate_CCtoDomesticCustomer__c' => 120,
                'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'
        };
        TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);


        String kickbackRecordType = RecordTypeUtil.getRecordTypeIdByDeveloperName(Kickback__c.SObjectType, Constants.KICKBACK_TO_CUSTOMER_RT);
        additionalFields = new Map<String, Object>{
                'ShipmentOrder__c' => shipmentOrder.Id, 'KickbackTo__c' => domesticCustomer.Id,
                'RecordTypeId' => kickbackRecordType, 'ChargeUnit__c' => 1,
                'UnitPriceUSD__c' => 100, 'PaymentConfirmed__c' => false, 'ExchangeRate__c' => 1
        };
        Kickback__c kickback = (Kickback__c) TestDataFactory.createSObject(new Kickback__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'CashTo__c' => domesticCustomer.Id
        };
        CASH_BOOK__c cash = (CASH_BOOK__c) TestDataFactory.createSObject(new CASH_BOOK__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Cashbook__c' => cash.Id, 'KickbackID__c' => kickback.Id
        };
        ConnectKickabckCash__c kbc = (ConnectKickabckCash__c) TestDataFactory.createSObject(new ConnectKickabckCash__c(), true, additionalFields);

        System.assert(true);
    }

    @IsTest static void shouldSyncExchangeRateSuccessfully() {
        Test.startTest();
        
        Kickback__c kickback = [SELECT ExchangeRate__c, UnitPrice__c, UnitPriceUSD__c FROM Kickback__c LIMIT 1];
        System.assertNotEquals(null, kickback.ExchangeRate__c);
        System.assertEquals(kickback.UnitPriceUSD__c * kickback.ExchangeRate__c, kickback.UnitPrice__c);

        Test.stopTest();
    }

    @IsTest static void shouldSettlePaymentSucessfully() {
        Kickback__c kickback = [SELECT PaymentConfirmed__c, PaymentSettledDate__c FROM Kickback__c LIMIT 1];

        Test.startTest();
        System.assertEquals(false, kickback.PaymentConfirmed__c);
        kickback.PaymentConfirmed__c = true;
        FlsService.doUpdate(kickback);
        Test.stopTest();

        kickback = [SELECT PaymentSettledDate__c, PaidAmount__c, PaidAmountUSD__c, UnitPrice__c, UnitPriceUSD__c FROM Kickback__c WHERE Id = :kickback.Id];
        System.assertEquals(System.today(), kickback.PaymentSettledDate__c);
        System.assertEquals(kickback.UnitPrice__c, kickback.PaidAmount__c);
        System.assertEquals(kickback.UnitPriceUSD__c, kickback.PaidAmountUSD__c);
    }

    @IsTest static void testDelete() {
        Kickback__c kickback = [SELECT PaymentConfirmed__c, PaymentSettledDate__c FROM Kickback__c LIMIT 1];
        Test.startTest();
        try {
                delete kickback;
        }
        catch (Exception ex) {
        }
        Test.stopTest();
    }
}