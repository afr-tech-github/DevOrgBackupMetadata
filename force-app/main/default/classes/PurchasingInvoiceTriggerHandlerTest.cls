/**
 * Created by khanhpham on 6/3/17.
 */

@IsTest(SeeAllData=false)
private with sharing class PurchasingInvoiceTriggerHandlerTest {
    @TestSetup static void setUp() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.PO_RT];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'RecordTypeId' => rt.Id, 'PurchasingOrderName__c' => 'PO Test 1'
        };
        PurchasingOrder__c po = (PurchasingOrder__c) TestDataFactory.createSObject(new PurchasingOrder__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'PurchasingOrder__c' => po.Id, 'ExchangeRate__c' => 22000, 'Currency__c' => 'USD',
                'ChargeUnit__c' => 1, 'UnitPrice__c' => 1
        };
        TestDataFactory.createSObject(new PurchasingInvoice__c(), true, additionalFields);

        System.assert(true);
    }

    @IsTest static void shouldCalculateLocalAmountCorrectOnInsert() {
        PurchasingOrder__c po = [SELECT Id FROM PurchasingOrder__c WHERE PurchasingOrderName__c = 'PO Test 1'];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'PurchasingOrder__c' => po.Id, 'ExchangeRate__c' => 22000, 'Currency__c' => 'USD',
                'ChargeUnit__c' => 2, 'UnitPrice__c' => 1
        };
        CASH_BOOK__c ca = new CASH_BOOK__c();
        ca.clofor_com_cfs__OriginalDocument__c = 'test';
        insert ca;

        Test.startTest();
        PurchasingInvoice__c invoice = (PurchasingInvoice__c) TestDataFactory.createSObject(new PurchasingInvoice__c(), true, additionalFields);
        Test.stopTest();

        invoice = [SELECT UnitPriceLocal__c, UnpaidBalanceLocal__c, UnpaidBalance__c
                                        FROM PurchasingInvoice__c WHERE Id =: invoice.Id];
        System.assertEquals(2, invoice.UnpaidBalance__c);
        System.assertEquals(44000, invoice.UnpaidBalanceLocal__c);
        System.assertEquals(22000, invoice.UnitPriceLocal__c);
    }

    @IsTest static void shouldCalculateLocalAmountCorrectOnUpdate() {
        PurchasingInvoice__c invoice = [SELECT UnitPrice__c, UnitPriceLocal__c, UnpaidBalance__c, UnpaidBalanceLocal__c
                                        FROM PurchasingInvoice__c LIMIT 1];
        System.assertEquals(1, invoice.UnpaidBalance__c);
        System.assertEquals(22000, invoice.UnpaidBalanceLocal__c);
        System.assertEquals(1, invoice.UnitPrice__c);
        System.assertEquals(22000, invoice.UnitPriceLocal__c);

        Test.startTest();
        CASH_BOOK__c ca = new CASH_BOOK__c();
        ca.clofor_com_cfs__OriginalDocument__c = 'test';
        insert ca;
        invoice.ChargeUnit__c = 2;
        FlsService.doUpdate(invoice);
        Test.stopTest();

        invoice = [SELECT UnitPrice__c, UnitPriceLocal__c, UnpaidBalance__c, UnpaidBalanceLocal__c
                                        FROM PurchasingInvoice__c WHERE Id = :invoice.Id];
        System.assertEquals(2, invoice.UnpaidBalance__c);
        System.assertEquals(44000, invoice.UnpaidBalanceLocal__c);
        System.assertEquals(1, invoice.UnitPrice__c);
        System.assertEquals(22000, invoice.UnitPriceLocal__c);
    }
}