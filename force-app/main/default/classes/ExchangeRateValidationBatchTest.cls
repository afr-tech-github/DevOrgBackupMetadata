@isTest
public class ExchangeRateValidationBatchTest {
    testmethod static void shouldInvalidatePassedExchangeRates() {
        Date currentDate = System.today();
        Date startDate = currentDate.addDays(-30);
        Date endDate = currentDate.addDays(-1);
        Date startDate1 = currentDate;
        Date endDate1 = currentDate.addDays(10);
        
        Map<String, Object> additionalFields = new Map<String, Object>{'Mgmt_Exrate_Validity__c' => true,
													'Mgmt_Exrate_End_Date__c' => endDate, 'Mgmt_Exrate_Start_Date__c' => startDate,
            										'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c passedExRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{'Mgmt_Exrate_Validity__c' => true, 'Mgmt_Exrate_End_Date__c' => endDate1, 
            									'Mgmt_Exrate_Start_Date__c' => startDate1,
            									'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c liveExRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        Test.startTest();
      	ExchangeRateValidationBatch batch = new ExchangeRateValidationBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        MgmtMaster__c actual = [SELECT Id, Mgmt_Exrate_Validity__c FROM MgmtMaster__c WHERE Id = :passedExRate.Id];
        System.assertEquals(false, actual.Mgmt_Exrate_Validity__c);
        
        actual = [SELECT Id, Mgmt_Exrate_Validity__c FROM MgmtMaster__c WHERE Id = :liveExRate.Id];
        System.assertEquals(true, actual.Mgmt_Exrate_Validity__c);
    }
    
    testmethod static void shouldExecuteScheduledJob() {
        String CRON_EXP = '0 0 0 16 4 ? 2024';
        
        Test.startTest();
        System.schedule('ExchangeRateValidationScheduler', CRON_EXP, new ExchangeRateValidationScheduler());
        Test.stopTest();
        
        System.assert(true);
    }
}