/**
 * The batch job will find any Exchange Rate that effective period was passed and invalidate them.
 * Note: It is necessary to setup a Apex job run at the beginning for the day such as 0:00 AM
 */ 
global with sharing class ExchangeRateValidationBatch implements Database.Batchable<SObject> {
	global final String query;
    
    global ExchangeRateValidationBatch() {
        DateTime currentTime = System.now();
        
        query = 'SELECT Mgmt_Exrate_Validity__c FROM MgmtMaster__c ' + 
            	'WHERE (Mgmt_Exrate_Validity__c = True) AND (Mgmt_Exrate_End_Date__c < ' + currentTime.format('yyyy-MM-dd') + ')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        for (SObject s : scope) {
            MgmtMaster__c exRate = (MgmtMaster__c) s;
            exRate.Mgmt_Exrate_Validity__c = false;
        }
        
        FlsService.doUpdate(scope);
    }
    
    global void finish(Database.BatchableContext bc) {}
}