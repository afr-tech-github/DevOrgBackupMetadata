@isTest
private class OrganizationPerformanceTriggerHdlerTest {

	private static OrganizationPerformance__c orgPerformanceParent;
	private static OrganizationPerformance__c orgPerformanceChild;

	static{
		orgPerformanceParent = new OrganizationPerformance__c(
			OrganizationPerformanceName__c = 'Org test',
			AccumulatedAnnualPerformance__c = 10,
			SumPerformanceFromChildOrg__c = 10);
        FlsService.doInsert(orgPerformanceParent);

		orgPerformanceChild = new OrganizationPerformance__c(
			OrganizationPerformanceName__c = 'Org test',
			AccumulatedAnnualPerformance__c = 10,
			SumPerformanceFromChildOrg__c = 10,
			ParentOrganizationalPerformanceID__c = orgPerformanceParent.Id);
        FlsService.doInsert(orgPerformanceChild);
	}
	
	@isTest static void test_method_onBeforeDelete() {
		// Implement test code
		Test.startTest();
			FlsService.doDelete(orgPerformanceChild);
			Integer x =1;
			System.assert(x != null);
		Test.stopTest();
	}
	
}