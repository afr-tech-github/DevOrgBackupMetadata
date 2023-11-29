@isTest
private class GoodsPurchasingOrderTriggerHelperTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
		GoodsPurchasingOrder__c gPrurchasingOrder = new GoodsPurchasingOrder__c();
        FlsService.doInsert(gPrurchasingOrder);
		System.assert(gPrurchasingOrder != null);
		Test.stopTest();
	}
	
}