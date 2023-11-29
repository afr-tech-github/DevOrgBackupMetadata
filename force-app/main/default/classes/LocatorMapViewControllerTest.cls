@isTest
private class LocatorMapViewControllerTest {
	
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
	@isTest static void testLocatorMapView1() {
		Test.startTest();
			LocatorMapViewController ctrl = new LocatorMapViewController();
			ctrl.doInit();
			//ctrl.locatorSearch = new 
			ctrl.doSearch();
			Integer totalpageSearch = ctrl.getTotalPageSearchs();
			List<clofor_com_cfs__LOCATOR__c> locatorResult = ctrl.getLocatorSearchResult();
			ApexPages.currentPage().getParameters().put('warehouseId', warehouse.Id);
	      	ApexPages.currentPage().getParameters().put('locatorParentId', locator1.Id);
	      	ApexPages.currentPage().getParameters().put('indexTreeParam', '0');
	      	ApexPages.currentPage().getParameters().put('locatorLayer','Floor Layer');
			ctrl.viewLocators();
			PageReference page = ctrl.refreshPageSizeSearch();
		Test.stopTest();
		system.assertEquals(page, null);
	}
	
	@isTest static void testLocatorMapView2() {
		Test.startTest();
			LocatorMapViewController ctrl = new LocatorMapViewController();
			ApexPages.currentPage().getParameters().put('locatorParentId', locator1.Id);
	      	ApexPages.currentPage().getParameters().put('indexTreeParam', '');
	      	ApexPages.currentPage().getParameters().put('locatorLayer','Area Layer');
	      	ctrl.viewLocators();
	      	List<clofor_com_cfs__LOCATOR__c> locatorResult = ctrl.getLocatorSearchResult();
	      	List<clofor_com_cfs__Facility__c> facilityResult = ctrl.getWarehouseResult();
	      	PageReference page = ctrl.refreshPageSizeSearch();
		Test.stopTest();
		system.assertEquals(page, null);
	}
	@isTest static void testLocatorMapView3() {
		Test.startTest();
			LocatorMapViewController ctrl = new LocatorMapViewController();
			ApexPages.currentPage().getParameters().put('locatorParentId', locator2.Id);
	      	ApexPages.currentPage().getParameters().put('indexTreeParam', '');
	      	ApexPages.currentPage().getParameters().put('locatorLayer','Section Layer');
	      	List<clofor_com_cfs__LOCATOR__c> locatorResult = ctrl.getChildLocatorResult();
	      	ctrl.viewLocators();
	      	PageReference page = ctrl.refreshPageSizeSearch();
		Test.stopTest();
		system.assertEquals(page, null);

	}
	@isTest static void testLocatorMapView4() {
		Test.startTest();
			LocatorMapViewController ctrl = new LocatorMapViewController();
			ApexPages.currentPage().getParameters().put('locatorParentId', locator3.Id);
	      	ApexPages.currentPage().getParameters().put('indexTreeParam', '');
	      	ApexPages.currentPage().getParameters().put('locatorLayer','Rack Layer');
	      	ctrl.viewLocators();
	      	PageReference page = ctrl.refreshPageSizeSearch();
	      	PageReference page1 = ctrl.refreshPageSizeChildLocator();
	      	PageReference page2 = ctrl.refreshPageSizeWarehouse();
		Test.stopTest();
		system.assertEquals(page, null);
	}
	@isTest static void testLocatorMapView5() {
		Test.startTest();
			LocatorMapViewController ctrl = new LocatorMapViewController();
	      	ApexPages.currentPage().getParameters().put('locatorParentId', locator4.Id);
	      	ApexPages.currentPage().getParameters().put('indexTreeParam', '');
	      	ApexPages.currentPage().getParameters().put('locatorLayer','Level Layer');
	      	ctrl.viewLocators();
	      	Integer totalPageChildLocators =  ctrl.getTotalPageChildLocators();
	      	Integer totalPageWarehouses =  ctrl.getTotalPageWarehouses();
	      	PageReference page = ctrl.refreshPageSizeWarehouse();
		Test.stopTest();
		system.assertEquals(page, null);

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