/**
 * Created by khanhpham on 5/25/17.
 */
@IsTest(SeeAllData = false)
private with sharing class PurchasingOrderTriggerHandlerTest {
    @TestSetup static void setUp() {
        String poRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(PurchasingOrder__c.SObjectType, 'PurchasingOrder');

        Map<String, Object> additionalFields = new Map<String, Object>{
                'RecordTypeId' => poRecordTypeId
        };
        TestDataFactory.createSObject(new PurchasingOrder__c(), true, additionalFields);
    }

    @IsTest static void shouldLockOnCompletion() {
        PurchasingOrder__c po = [SELECT Status__c FROM PurchasingOrder__c LIMIT 1];
        String poLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(PurchasingOrder__c.SObjectType, 'LockedPurchasingOrder');

        System.assertNotEquals(po.Status__c, 'Payment Settled');
        Test.startTest();
        po.Status__c = 'Payment Settled';
        FlsService.doUpdate(po);
        Test.stopTest();
        po = [SELECT RecordTypeId, Status__c FROM PurchasingOrder__c LIMIT 1];
        System.assertEquals(po.RecordTypeId, poLockedRecordTypeId);
    }
}