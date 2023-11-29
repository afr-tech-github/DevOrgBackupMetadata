@IsTest
private class CargoStandardLabelControllerTest {
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
        Id RecordTypeIdWorkOrder = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByDeveloperName().get('Inbound').getRecordTypeId();
        wo.RecordTypeId = RecordTypeIdWorkOrder;
		FlsService.doInsert(wo);
    }
    
    @IsTest static void test_Contructor(){
        Test.startTest();
        WorkOrder__c wo = [select id from WorkOrder__c limit 1];
        ApexPages.currentPage().getParameters().put('id',wo.Id);
        CargoStandardLabelController pl = new CargoStandardLabelController();
        pl.getWosLineItems();
        System.assert(wo != null);
        
        Test.stopTest();
    }
}