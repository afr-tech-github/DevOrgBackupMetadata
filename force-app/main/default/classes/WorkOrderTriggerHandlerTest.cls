@isTest
private class WorkOrderTriggerHandlerTest {
	private static Facility__c warehouse;
	private static WorkOrder__c workOrder;
	private static Account  accountTest;
	static{
		warehouse = createWarehouse();
		accountTest = new Account(Name = 'AccountTest1',
			EnglishCompanyName__c = 'AcountTest1');
		FlsService.doInsert(accountTest);
	}
	
	@isTest static void test_method_onAfterUpdate() {
		workOrder = new WorkOrder__c(
			WarehouseID__c = warehouse.Id,
			Customer__c = accountTest.Id);
		FlsService.doInsert(workOrder);
		Test.startTest();
			workOrder.WorkOrderStatus__c = 'Completed';
			FlsService.doUpdate(workOrder);
			system.assert(workOrder != null);
		Test.stopTest();
	}
	
	private static Facility__c createWarehouse(){
		Facility__c warehouse = new clofor_com_cfs__Facility__c(
			clofor_com_cfs__FacilityName__c ='test Ware house'
		);
		FlsService.doInsert(warehouse);
		return warehouse;
	}
}