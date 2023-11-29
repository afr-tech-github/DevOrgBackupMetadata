@isTest
private class WorkOrderServiceTriggerHelperTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
		Cargo__c car = new Cargo__c();
		insert car;
		Facility__c ware = new Facility__c();
		insert ware;
		Locator__c loc = new Locator__c(WarehouseID__c = ware.Id,FloorCode__c='F321');
		insert loc;
		Locator__c loc2 = new Locator__c(WarehouseID__c = ware.Id,FloorCode__c='F323');
		insert loc2;
		WorkOrderService__c workOrderService = new WorkOrderService__c(Locator__c = loc.Id, Status__c = 'Completed', RecordTypeId = '0120K000000ygE3QAI');
        FlsService.doInsert(workOrderService);
		workOrderService.Locator__c = loc2.Id;
		update workOrderService;
		system.assert(workOrderService != null);
		WorkOrderService__c workOrderService2 = new WorkOrderService__c(Locator__c = loc.Id, RecordTypeId = '0120K000000ygE3QAI');
		FlsService.doInsert(workOrderService2);
		workOrderService2.Locator__c = loc2.Id;
		workOrderService2.Status__c = 'Completed';
		update workOrderService2;
		system.assert(workOrderService2 != null);
		clofor_com_cfs__WOSLineItem__c wosline = new clofor_com_cfs__WOSLineItem__c (WorkOrderService__c = workOrderService2.Id, CargoStatus__c = 'Completed',clofor_com_cfs__Cargo__c = car.Id);
		insert wosline;
		Test.stopTest();
	}
}