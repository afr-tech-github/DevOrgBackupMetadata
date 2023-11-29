@isTest 
private class ContainerGoodSOTriggerHandlerTest {
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
            FlsService.doDelete(container1);
            container2.clofor_com_cfs__ContainerType__c = '40\'DC';
            FlsService.doUpdate(container2);
			System.assert(salesOrder != null);
		Test.stopTest();
	}
}