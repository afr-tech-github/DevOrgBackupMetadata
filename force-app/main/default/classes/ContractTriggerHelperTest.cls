@isTest
private class ContractTriggerHelperTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
		Contract__c contract = new Contract__c();
		FlsService.doInsert(contract);
		System.assert(contract != null);
		Test.stopTest();
	}
	
}