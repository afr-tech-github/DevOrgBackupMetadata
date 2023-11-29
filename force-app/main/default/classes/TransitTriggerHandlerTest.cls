/**
 * Created by khanhpham on 7/17/17.
 */

@IsTest
private with sharing class TransitTriggerHandlerTest {
    @testsetup static void setUp() {
        Date etd = Date.newInstance(2015, 01, 02);
        Date eta = Date.newInstance(2015, 02, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_IMPORT_RT];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
         setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        Map<String, Object> additionFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'HBL__c' => 'T123',
                'RecordTypeId' => rt.Id, 'ETD__c' => etd, 'ETA__c' => eta,
                'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES,
                'TranporationType__c' => 'LCL', 'MultiTransitRequired__c' => '1'
        };
        TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        System.assert(true);
    }

    @IsTest static void shouldAssignCorrectOrder() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = 'T123'];
        System.assertNotEquals(null, shipment);

        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.TRANSIT_SHIPMENT_RT];
        Map<String, Object> additionFields = new Map<String, Object>{
                'RecordTypeId' => rt.Id, 'ShipmentOrder__c' => shipment.Id
        };
        Transit__c transit = (Transit__c) TestDataFactory.createSObject(new Transit__c(), false, additionFields);

        Test.startTest();
        FlsService.doInsert(transit);
        Test.stopTest();
        transit = [SELECT Id, InOrderOfTransit__c FROM Transit__c WHERE Id = :transit.Id];
        System.assertEquals(2, transit.InOrderOfTransit__c);
    }

    @IsTest static void shouldFailIfOutOfRangeOrder() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = 'T123'];
        Transit__c transit = [SELECT Id, InOrderOfTransit__c FROM Transit__c WHERE ShipmentOrder__c = :shipment.Id];

        System.assertEquals(1, transit.InOrderOfTransit__c);
        Test.startTest();

        try {
            transit.InOrderOfTransit__c = 10;
            FlsService.doUpdate(transit);
            
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }

        Test.stopTest();
    }
}