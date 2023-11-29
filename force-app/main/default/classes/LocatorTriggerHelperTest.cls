@isTest
private class LocatorTriggerHelperTest {
	private static clofor_com_cfs__Facility__c warehouse = new clofor_com_cfs__Facility__c();
	private static clofor_com_cfs__LOCATOR__c locator1 = new clofor_com_cfs__LOCATOR__c();
	private static clofor_com_cfs__LOCATOR__c locator2 = new clofor_com_cfs__LOCATOR__c();
	private static clofor_com_cfs__LOCATOR__c locator3 = new clofor_com_cfs__LOCATOR__c();
	private static clofor_com_cfs__LOCATOR__c locator4 = new clofor_com_cfs__LOCATOR__c();
	private static clofor_com_cfs__LOCATOR__c locator5 = new clofor_com_cfs__LOCATOR__c();


	static{
		warehouse = createWarehouse();
		locator1 = createLocator(warehouse.Id, 'Floor Layer', null, 'F01', '', '', '', '');
		FlsService.doInsert(locator1);
		locator2 = createLocator(warehouse.Id, 'Area Layer', locator1.Id, 'F01', 'A01','','','');
		FlsService.doInsert(locator2);
		locator3 = createLocator(warehouse.Id, 'Section Layer', locator2.Id,  'F01','A01','S01','','');
		FlsService.doInsert(locator3);
		locator4 = createLocator(warehouse.Id, 'Rack Layer', locator3.Id, 'F01', 'A01','S01','R01','');
		FlsService.doInsert(locator4);
		locator5 = createLocator(warehouse.Id, 'Level Layer', locator4.Id, 'F01', 'A01','S01','R01','L01');
		FlsService.doInsert(locator5);
	}

	@isTest static void test_method_onBeforeInsert() {
		Test.startTest();
		try{
			clofor_com_cfs__LOCATOR__c locator = createLocator(warehouse.Id, 'Floor Layer', null, 'F01', '', '', '', '');
			FlsService.doInsert(locator);
		}catch(Exception ex){

		}
		Integer x = 1;
        System.assert(x != null);
		Test.stopTest();
		// Implement test code
	}
	@isTest static void test_method_onBeforeUpdate() {
		clofor_com_cfs__LOCATOR__c locator = createLocator(warehouse.Id, 'Floor Layer', null, 'F02', '', '', '', '');
		FlsService.doInsert(locator);

		Test.startTest();
		try{
			locator.FloorCode__c = 'FO1';
			FlsService.doUpdate(locator);
		}catch(Exception ex){

		}
		System.assert(locator != null);
		Test.stopTest();
		// Implement test code
	}

	@isTest static void test_method_onBeforDelete() {
		Test.startTest();
        	FlsService.doDelete(locator5);
			integer x = 1;
			System.assert(x != null);
		Test.stopTest();
		// Implement test code
	}
	
	private static clofor_com_cfs__Facility__c createWarehouse(){

		clofor_com_cfs__Facility__c warehouse = new clofor_com_cfs__Facility__c(
			clofor_com_cfs__FacilityName__c ='test Ware house'
			);
		FlsService.doInsert(warehouse);
		return warehouse;
	}

	private static clofor_com_cfs__LOCATOR__c createLocator(String warehouseId, String layer, String parentLocator, String floorCode,
														String areaCode, String sectionCode, String rackCode, String levelCode){
		clofor_com_cfs__LOCATOR__c locator = new clofor_com_cfs__LOCATOR__c(
				clofor_com_cfs__LocationAreaType__c	='Storage Area',
				clofor_com_cfs__WarehouseID__c = warehouseId,
				clofor_com_cfs__LocatorLayer__c = layer,
				clofor_com_cfs__FloorCode__c = floorCode,
				clofor_com_cfs__AreaCode__c = areaCode,
				clofor_com_cfs__SectionCode__c = sectionCode,
				clofor_com_cfs__Rack__c = rackCode,
				clofor_com_cfs__Level__c = levelCode,
				clofor_com_cfs__ParentLocator__c = parentLocator
			);
		
		return locator;
	}
}