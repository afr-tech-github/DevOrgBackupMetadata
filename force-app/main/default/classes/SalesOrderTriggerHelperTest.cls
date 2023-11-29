@isTest
private class SalesOrderTriggerHelperTest {
	private static Contract__c contract;
	static{
		contract = new Contract__c();
        FlsService.doInsert(contract);
	}
	@isTest static void test_method_one() {
		Test.startTest();
			SALES_ORDER__c salesOrder = new SALES_ORDER__c(
				ContractID__c = contract.Id);
			FlsService.doInsert(salesOrder);
			clofor_com_cfs__ContainerGoodSO__c container1 = new clofor_com_cfs__ContainerGoodSO__c(
				clofor_com_cfs__ContainerType__c = '20\'DC',
				clofor_com_cfs__GOODSSO__c = salesOrder.Id
			);
			clofor_com_cfs__ContainerGoodSO__c container2 = new clofor_com_cfs__ContainerGoodSO__c(
				clofor_com_cfs__ContainerType__c = '20\'All',
				clofor_com_cfs__GOODSSO__c = salesOrder.Id
			);
			clofor_com_cfs__ContainerGoodSO__c container3 = new clofor_com_cfs__ContainerGoodSO__c(
				clofor_com_cfs__ContainerType__c = '40\'DC',
				clofor_com_cfs__GOODSSO__c = salesOrder.Id
			);
			clofor_com_cfs__ContainerGoodSO__c container4= new clofor_com_cfs__ContainerGoodSO__c(
				clofor_com_cfs__ContainerType__c = '40\'DC',
				clofor_com_cfs__GOODSSO__c = salesOrder.Id
			);
			List<clofor_com_cfs__ContainerGoodSO__c> containers = new List<clofor_com_cfs__ContainerGoodSO__c>{container1, container2, container3, container4};
			FlsService.doInsert(containers);
			System.assert(salesOrder != null);
		Test.stopTest();
	}

	@isTest static void test_method_two() {
		Test.startTest();
			SALES_ORDER__c salesOrder = new SALES_ORDER__c(
				ContractID__c = contract.Id);
			FlsService.doInsert(salesOrder);
			salesOrder.clofor_com_cfs__NumberofContainer_inwords__c = 'test';
			FlsService.doUpdate(salesOrder);
			System.assert(salesOrder != null);
		Test.stopTest();
	}
	
	
}