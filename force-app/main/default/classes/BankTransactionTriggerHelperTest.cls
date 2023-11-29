@isTest
private class BankTransactionTriggerHelperTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
			BankTransaction__c bank = new BankTransaction__c();
			FlsService.doInsert(bank);
			System.assert(bank != null);
		Test.stopTest();
	}
	
}