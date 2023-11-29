@isTest
private class ConnectOtherCashTriggerHelperTest {
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
	
	@isTest static void test_method_onAfterInsert() {
		// Implement test code
		Test.startTest();
			ConnectOtherCash__c link1 = new ConnectOtherCash__c(
			CashID__c = listCash[0].Id,
			OtherRevenueCostID__c= listRevenue[1].Id
			);
			ConnectOtherCash__c link2 = new ConnectOtherCash__c(
				CashID__c = listCash[1].Id,
				OtherRevenueCostID__c = listRevenue[0].Id);

			List<ConnectOtherCash__c> listLinks = new List<ConnectOtherCash__c>();

			listLinks.add(link1);
			listLinks.add(link2);
			FlsService.doInsert(listLinks);
			System.assert(listLinks != null);
		Test.stopTest();
	}

	@isTest static void test_method_onBeforeDelete() {
		
		ConnectOtherCash__c link1 = new ConnectOtherCash__c(
		CashID__c = listCash[0].Id,
		OtherRevenueCostID__c= listRevenue[1].Id
		);
		ConnectOtherCash__c link2 = new ConnectOtherCash__c(
			CashID__c = listCash[1].Id,
			OtherRevenueCostID__c = listRevenue[0].Id);

		List<ConnectOtherCash__c> listLinks = new List<ConnectOtherCash__c>();

		listLinks.add(link1);
		listLinks.add(link2);
		FlsService.doInsert(listLinks);
		// Implement test code
		Test.startTest();
			FlsService.doDelete(listLinks);
			System.assert(listRevenue != null);
		Test.stopTest();
	}
	
}