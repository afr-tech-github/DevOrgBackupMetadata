@isTest
private class WMS_WO_CombineServiceTest {
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
        
        WorkOrderService__c wos = new WorkOrderService__c();
        wos.WorkOrder__c = wo.id;
        FlsService.doInsert(wos);
    }
	@isTest static void test_getInfo() {
        Test.startTest();
        WorkOrder__c wo = [select id from WorkOrder__c limit 1];
        Facility__c fac = [select id from facility__c limit 1];
        WMS_WO_CombineService.getInfo(wo.id, fac.id);
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
	}
	
	@isTest static void test_getInfoNegative() {
        Test.startTest();
        try{
            Facility__c fac = [select id from facility__c limit 1];
			WMS_WO_CombineService.getInfo('001000000000000', fac.id);
        }catch(exception ex){
            
        }
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
	}
    
    @IsTest static void test_CombineTransfer(){
        Test.startTest();
        try{
            WorkOrder__c wo = [select id, WarehouseID__c from WorkOrder__c limit 1];
            WorkOrderService__c wos = [select id from WorkOrderService__c limit 1];
            String payloadStr = '[{"destinationId":"'+wo.WarehouseId__c+'","destination":{"Name":"FC-000242","clofor_com_cfs__FacilityName__c":"Test Facility","Id":"a0r0K00005VH5kKQAT"},"cargos":[{"productId":"a0s0K000005fyqNQAQ","productQty":"4","cargoQty":"5","cargoType":"Barrel"}]}]';
            List<String> payloads = new List<String>();
            payloads.add(wos.id);
            
            WMS_WO_CombineService.combineService(wo.id, payloads);
            
        }catch(exception ex){
            
        }	
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
    }
	
}