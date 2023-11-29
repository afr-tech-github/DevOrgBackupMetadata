@isTest
private class ProjectTriggerHelperTest {
	
	@isTest static void test_method_one() {
		// Implement test code
		Test.startTest();
		PROJECT__c project = new PROJECT__c();
        FlsService.doInsert(project);
		System.assert(project != null);
		Test.stopTest();
	}
	
}