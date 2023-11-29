@isTest
private class BillingTriggerHelperTest {
	private static Facility__c warehouse;
	private static WorkOrder__c workOrder1;
	private static WorkOrder__c workOrder2;
	private static Account  accountTest1;
	
	private static Account  accountTest2;
	static{
		warehouse = createWarehouse();
		accountTest1 = new Account(Name = 'AccountTest1',
			EnglishCompanyName__c = 'AcountTest1',
            CorporateMyNumber__c = 'AcountTest1');
		FlsService.doInsert(accountTest1);

		accountTest2 = new Account(Name = 'AccountTest2',
			EnglishCompanyName__c = 'AcountTest2',
        CorporateMyNumber__c = 'AcountTest2');
		FlsService.doInsert(accountTest2);

		workOrder1 = new WorkOrder__c(
			WarehouseID__c = warehouse.Id,
			Customer__c = accountTest1.Id);
		FlsService.doInsert(workOrder1);

		workOrder2 = new WorkOrder__c(
			WarehouseID__c = warehouse.Id,
			Customer__c = accountTest2.Id);
		FlsService.doInsert(workOrder2);
	}

	@isTest static void test_method_onBeforeInsert() {
		Test.startTest();
		Billing__c billing = new Billing__c(
			WorkOrderID__c = workOrder1.Id);
		FlsService.doInsert(billing);

		// Implement test code
		Integer x = 1;
        System.assert(x != null);
		Test.stopTest();
	}
	
	@isTest static void test_method_onBeforeUpdate() {
		
		Billing__c billing = new Billing__c(
			WorkOrderID__c = workOrder1.Id);
		FlsService.doInsert(billing);

		Test.startTest();
			billing.BillingDisplayNo__c =1;
			FlsService.doUpdate(billing);
			Integer x = 1;
        System.assert(x != null);
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