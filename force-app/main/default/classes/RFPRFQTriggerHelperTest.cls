@isTest
private class RFPRFQTriggerHelperTest {
	
	@isTest static void test_method_one() {
		// Implement test code
		Test.startTest();
			RFPRFQ__c rfRecord = new RFPRFQ__c();
			FlsService.doInsert(rfRecord);
			System.assert(rfRecord != null);
		Test.stopTest();
	}
	
}