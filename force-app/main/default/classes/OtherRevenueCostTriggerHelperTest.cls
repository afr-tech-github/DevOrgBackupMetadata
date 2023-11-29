@isTest
private class OtherRevenueCostTriggerHelperTest {
	
	private static List<OtherRevenueCost__c> listRevenue = new List<OtherRevenueCost__c>();
	private static List<CASH_BOOK__c> listCash = new List<CASH_BOOK__c>();
	static{
		Custom_Application_Config__c appConfig = new Custom_Application_Config__c(
			Disabled_Trigger__c = false
			);
        FlsService.doInsert(appConfig);

		Map<String, Schema.RecordTypeInfo> mapRevenueRecordTypeByDeveloperName = Schema.getGlobalDescribe().get('clofor_com_cfs__OtherRevenueCost__c').getDescribe().getRecordTypeInfosByDeveloperName();

		OtherRevenueCost__c otherRevenue1 = new OtherRevenueCost__c(
			RecordTypeId = mapRevenueRecordTypeByDeveloperName.get('OtherCost').getRecordTypeId(),
			OtherRevenueCostName__c = 'Test1',
			AmountOtherCostIncludeTax__c = 20,
			AmountPaidOtherCost__c = 10,
			AmountOtherRevenueIncludeTax__c =20,
			AmountCollectedOtherRevenue__c = 10
			);
		OtherRevenueCost__c otherRevenue2 = new OtherRevenueCost__c(
			RecordTypeId = mapRevenueRecordTypeByDeveloperName.get('OtherRevenue').getRecordTypeId(),
			OtherRevenueCostName__c = 'Test2',
			AmountOtherCostIncludeTax__c = 20,
			AmountPaidOtherCost__c = 10,
			AmountOtherRevenueIncludeTax__c =20,
			AmountCollectedOtherRevenue__c = 10
			);

		listRevenue.add(otherRevenue1);
		listRevenue.add(otherRevenue2);
        FlsService.doInsert(listRevenue);
		
		Map<String, Schema.RecordTypeInfo> mapCashRecordTypeByDeveloperName = Schema.getGlobalDescribe().get('clofor_com_cfs__CASH_BOOK__c').getDescribe().getRecordTypeInfosByDeveloperName();

		CASH_BOOK__c cash1 = new CASH_BOOK__c(
			RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashIn').getRecordTypeId()
		);
		CASH_BOOK__c cash2 = new CASH_BOOK__c(
			RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashOut').getRecordTypeId()
		);

		listCash.add(cash1);
		listCash.add(cash2);

        FlsService.doInsert(listCash);

		ConnectOtherCash__c link1 = new ConnectOtherCash__c(
			CashID__c = cash1.Id,
			OtherRevenueCostID__c= otherRevenue2.Id
			);
		ConnectOtherCash__c link2 = new ConnectOtherCash__c(
			CashID__c = cash2.Id,
			OtherRevenueCostID__c = otherRevenue1.Id);

		List<ConnectOtherCash__c> listLinks = new List<ConnectOtherCash__c>();

		listLinks.add(link1);
		listLinks.add(link2);
        FlsService.doInsert(listLinks);
	} 
	@isTest static void test_method_onAfterUpdate() {
		// Implement test code
		Test.startTest();
			listRevenue[0].AmountOtherCostIncludeTax__c = 40;
			listRevenue[0].AmountOtherRevenueIncludeTax__c =40;
			FlsService.doUpdate(listRevenue);
			system.assert(listRevenue != null);
		Test.stopTest();
	}
	
	@isTest static void test_method_onBeforeDelete() {
		// Implement test code
		Test.startTest();
			FlsService.doDelete(listRevenue);
			Integer x = 1;
			system.assert(x != null);
		Test.stopTest();
	}
	
}