@IsTest
public class WMS_WO_PrintLabelTest {
    @TestSetUp static void testSetUP(){
        Account acc = new Account();
        acc.name = 'testAcc';
        acc.EnglishCompanyName__c = 'test';
        FlsService.doInsert(acc);
        
        RecordType rtPro = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__PRODUCT__c' AND DeveloperName = 'FreshProduct'][0];
        PRODUCT__c product = new PRODUCT__c(RecordTypeId = rtPro.Id, clofor_com_cfs__ProductName__c = 'PRO1',MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
                                 GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing',
                                   BuyingCommercialValuePerUnitLocal__c = 100, TaxRateBuying__c = 10);
        FlsService.doInsert(product);

        Cargo__c cargo = new Cargo__c(Product__c = product.Id);
        FlsService.doInsert(cargo);

        facility__c fac = new facility__c();
        FlsService.doInsert(fac);
        
        WorkOrder__c wo = new WorkOrder__c();
        wo.Customer__c = acc.id;
        wo.WarehouseID__c = fac.id;
        Id RecordTypeIdWorkOrder = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByDeveloperName().get('Inbound').getRecordTypeId();
        wo.RecordTypeId = RecordTypeIdWorkOrder;
        FlsService.doInsert(wo);
        Facility__c facOrigin = new Facility__c(clofor_com_cfs__FacilityName__c = 'WHORIGIN');
        FlsService.doInsert(facOrigin);
        WorkOrderService__c wosInbound = new WorkOrderService__c(WorkOrder__c = wo.Id, Warehouse__c = facOrigin.Id);
        FlsService.doInsert(wosInbound);
        WOSLineItem__c woslInbound = new WOSLineItem__c(WorkOrderService__c = wosInbound.Id, Cargo__c = cargo.Id);
        FlsService.doInsert(woslInbound);
    }
    
    @IsTest static void test_Contructor(){
        Test.startTest();
        WorkOrder__c wo = [select id from WorkOrder__c limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        WMS_WO_PrintLabel pl = new WMS_WO_PrintLabel(sc);
        system.assert(true);
        Test.stopTest();
    }
}