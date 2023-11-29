@isTest
private class PaymentRequestTriggerHelperTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
		PaymentRequest__c request = new PaymentRequest__c();
        FlsService.doInsert(request);
		System.assert(request != null);
		Test.stopTest();
	}
	
}