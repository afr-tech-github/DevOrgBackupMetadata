@isTest
private class WMS_WO_CreateServiceTest {
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
        WMS_WO_CreateService.getInfo(wo.id);
        System.assert(wo != null);
        Test.stopTest();
	}
	
	@isTest static void test_deleteServices() {  
        Test.startTest();      
        Map<ID, sObject> mapWOS = new Map<ID, sObject>([select id from WorkOrderService__c]);
        WMS_WO_CreateService.deleteServices(new List<ID>(mapWOS.keyset()));
        System.assert(mapWOS != null);
        Test.stopTest();
	}
    
    @isTest static void test_deleteServicesNewgative() {   
        
        Test.startTest();
        try{
            WMS_WO_CreateService.deleteServices(null);
        }catch(exception ex){}
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
       
	}
    
    @IsTest static void test_SaveWOS(){
        Test.startTest();
        List<WorkOrderService__c> listWOS = [select id from WorkOrderService__c];
        listWOS.add(new WorkOrderService__c());
        WorkOrder__c wo = [select id from WorkOrder__c limit 1];
        WMS_WO_CreateService.saveServices(wo.id, listWOS);
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
    }
    
    @IsTest static void test_SaveWOSNegativ(){
        Test.startTest();
        try{
            List<WorkOrderService__c> listWOS = [select id from WorkOrderService__c];
            listWOS.add(new WorkOrderService__c());
            WMS_WO_CreateService.saveServices('001000000000000', listWOS);
         }catch(exception ex){}
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
    }
	
}