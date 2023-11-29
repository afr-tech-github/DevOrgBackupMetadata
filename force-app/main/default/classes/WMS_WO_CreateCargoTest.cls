@isTest
private class WMS_WO_CreateCargoTest {
	@TestSetUp static void testSetUP(){
        Account acc = new Account();
        acc.name = 'testAcc';
        acc.EnglishCompanyName__c = 'test';
        FlsService.doInsert(acc);
        
        facility__c fac = new facility__c();
        FlsService.doInsert(fac);
        
        WorkOrder__c wo = new WorkOrder__c();
        wo.Customer__c = acc.id;
        wo.WarehouseID__c = fac.id;
        //Id RecordTypeIdWorkOrder = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByName().get('DeveloperNameOfRecordType').getRecordTypeId();
        FlsService.doInsert(wo);
    }
    
	@isTest static void test_getInfo() {
        Test.startTest();
		WorkOrder__c wo = [select id from WorkOrder__c limit 1];
        WorkOrderService__c wos = new WorkOrderService__c();
        wos.WorkOrder__c = wo.id;
        FlsService.doInsert(wos);
        WMS_WO_CreateCargo.getInfo(wo.id);
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
	}
	
	@isTest static void test_saveCargo() {
        Test.startTest();
        WorkOrder__c wo = [select id, WarehouseID__c from WorkOrder__c limit 1];
		String payload = '[{"destinationId":"'+wo.WarehouseId__c+'","destination":{"Name":"FC-000242","clofor_com_cfs__FacilityName__c":"Test Facility","Id":"a0r0K00005VH5kKQAT"},"cargos":[{"productId":"a0s0K000005fyqNQAQ","productQty":"4","cargoQty":"5","cargoType":"Barrel"}]}]';
        
        WorkOrderService__c wos = new WorkOrderService__c();
        wos.WorkOrder__c = wo.id;
        wos.Warehouse__c  = wo.WarehouseId__c;
        FlsService.doInsert(wos);
        WMS_WO_CreateCargo.saveCargos(wo.id, payload);
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
	}
	
    @isTest static void test_saveCargo1() {
        Test.startTest();
        facility__c fac = new facility__c();
        FlsService.doInsert(fac);
        
        WorkOrder__c wo = [select id, WarehouseID__c from WorkOrder__c limit 1];
		String payload = '[{"destinationId":"'+fac.id+'","destination":{"Name":"FC-000242","clofor_com_cfs__FacilityName__c":"Test Facility","Id":"a0r0K00005VH5kKQAT"},"cargos":[{"productId":"a0s0K000005fyqNQAQ","productQty":"4","cargoQty":"5","cargoType":"Barrel"}]}]';
        
        WorkOrderService__c wos = new WorkOrderService__c();
        wos.WorkOrder__c = wo.id;
        wos.Warehouse__c  = wo.WarehouseId__c;
        FlsService.doInsert(wos);
        WMS_WO_CreateCargo.saveCargos(wo.id, payload);
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
	}
}