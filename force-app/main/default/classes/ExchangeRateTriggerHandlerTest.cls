@isTest
public class ExchangeRateTriggerHandlerTest {/*
    testmethod static void shouldPreventDuplicatedOnCreation() {
        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        
        Map<String, Object> additionalFields = new Map<String, Object>{'Mgmt_Exrate_Start_Date__c' => startDate, 
                                                'Mgmt_Exrate_End_Date__c' => endDate,
                                                'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c existingExRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        Test.startTest();
        MgmtMaster__c newExRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), false, additionalFields);
        
        try {
            insert newExRate;
            System.assert(false);
        } catch(System.DmlException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    testmethod static void shouldPreventDuplicatedOnUpdate() {
        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        Date startDate1 = Date.newInstance(2015, 10, 10);
        Date endDate1 = Date.newInstance(2015, 10, 20);

        Map<String, Object> additionalFields = new Map<String, Object>{'Mgmt_Exrate_Start_Date__c' => startDate, 
                                                    'Mgmt_Exrate_End_Date__c' => endDate,
                                                    'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c exRate1 = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{'Mgmt_Exrate_Start_Date__c' => startDate1, 
                                                    'Mgmt_Exrate_End_Date__c' => endDate1,
                                                    'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c exRate2 = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        Test.startTest();
        MgmtMaster__c updatedExRate = [SELECT Id, Mgmt_Exrate_Start_Date__c, Mgmt_Exrate_End_Date__c, Mgmt_Exrate_Validity__c 
                                       FROM MgmtMaster__c 
                                       WHERE Id =: exRate2.Id];
        updatedExRate.Mgmt_Exrate_Start_Date__c = startDate;
        updatedExRate.Mgmt_Exrate_End_Date__c = endDate;
        
        try {
            update updatedExRate;
            System.assert(false);
        } catch(System.DmlException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    */
}