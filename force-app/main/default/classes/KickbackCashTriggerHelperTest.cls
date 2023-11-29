@isTest
private class KickbackCashTriggerHelperTest {
    private static List<CASH_BOOK__c> listCash = new List<CASH_BOOK__c>();
    static  {
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
                'UnitPriceUSD__c' => 100, 'PaymentConfirmed__c' => false
        };

        TestDataFactory.createSObject(new Kickback__c(), true, additionalFields);

        Map<String, Schema.RecordTypeInfo> mapCashRecordTypeByDeveloperName = Schema.getGlobalDescribe().get('clofor_com_cfs__CASH_BOOK__c').getDescribe().getRecordTypeInfosByDeveloperName();

        CASH_BOOK__c cash1 = new CASH_BOOK__c(
            RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashIn').getRecordTypeId()
        );
        CASH_BOOK__c cash2 = new CASH_BOOK__c(
            RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashOut').getRecordTypeId()
        );

        listCash.add(cash1);
        listCash.add(cash2);

        insert listCash;
    }
    @isTest static void test_method_afterInsert() {
        // Implement test code
        Test.startTest();
            List<Kickback__c> listKickBack = [SELECT Id FROM Kickback__c];
            ConnectKickabckCash__c link = new ConnectKickabckCash__c(
                Cashbook__c = listCash[0].Id,
                KickbackID__c = listKickBack[0].Id
            );
                        insert link;
                        system.assert(link != null);
        Test.stopTest();
    }
    @isTest static void test_method_onBeforeDelete() {

        List<Kickback__c> listKickBack = [SELECT Id FROM Kickback__c];
            ConnectKickabckCash__c link = new ConnectKickabckCash__c(
                Cashbook__c = listCash[0].Id,
                KickbackID__c = listKickBack[0].Id
            );
            insert link;
        // Implement test code
        Test.startTest();
                        delete link;
                        system.assert(listCash != null);
        Test.stopTest();
    }
    
}