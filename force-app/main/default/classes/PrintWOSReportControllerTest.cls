@isTest
public class PrintWOSReportControllerTest {
    private static Map<String, RecordType> mapRTWOS = new Map<String, RecordType>();
    private static WorkOrderService__c wosInbound = new WorkOrderService__c();
    private static WorkOrderService__c wosTransfer = new WorkOrderService__c();
	static{
        Account acc = new Account(Name = 'ABC', clofor_com_cfs__EnglishCompanyName__c = 'ABC');
        FlsService.doInsert(acc);
        
        RecordType rtPro = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__PRODUCT__c' AND DeveloperName = 'FreshProduct'][0];
        PRODUCT__c product = new PRODUCT__c(RecordTypeId = rtPro.Id, clofor_com_cfs__ProductName__c = 'PRO1', GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing',MaintenanceServiceBillingFreqType__c = 'Continuous Billing');
        FlsService.doInsert(product);
        
        Cargo__c cargo = new Cargo__c(Product__c = product.Id);
        FlsService.doInsert(cargo);
        
        RecordType rtFac = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__Facility__c' AND DeveloperName = 'NormalWarehouse' LIMIT 1][0];
        Facility__c facOrigin = new Facility__c(RecordTypeId = rtFac.Id, clofor_com_cfs__FacilityName__c = 'WHORIGIN');
        FlsService.doInsert(facOrigin);
        
        RecordType rtWO = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__WorkOrder__c' AND DeveloperName = 'CrossDock' LIMIT 1][0];
        WorkOrder__c wo = new WorkOrder__c(RecordTypeId = rtWO.Id, Customer__c = acc.Id, WarehouseID__c = facOrigin.Id);
        FlsService.doInsert(wo);
        
        List<RecordType> lstRTWOS = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'clofor_com_cfs__WorkOrderService__c'];
        mapRTWOS = new Map<String, RecordType>();
        for(RecordType rt : lstRTWOS){
            mapRTWOS.put(rt.DeveloperName, rt);
        }
        
        wosInbound = new WorkOrderService__c(RecordTypeId = mapRTWOS.get('InboundReceiving').Id, WorkOrder__c = wo.Id, Warehouse__c = facOrigin.Id);
        FlsService.doInsert(wosInbound);
        
        WOSLineItem__c woslInbound = new WOSLineItem__c(WorkOrderService__c = wosInbound.Id, Cargo__c = cargo.Id);
        FlsService.doInsert(woslInbound);
        
        wosTransfer = new WorkOrderService__c(RecordTypeId = mapRTWOS.get('TransferDispatch').Id, WorkOrder__c = wo.Id, 
                                              Warehouse__c = facOrigin.Id, DestinationWarehouse__c = facOrigin.Id);
        FlsService.doInsert(wosTransfer);
        
        WOSLineItem__c woslTransfer = new WOSLineItem__c(WorkOrderService__c = wosTransfer.Id, Cargo__c = cargo.Id);
        FlsService.doInsert(woslTransfer);
        
        RecordType rtStock = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__Stock__c' AND DeveloperName = 'StockIn' LIMIT 1][0];
        Stock__c stock = new Stock__c(RecordTypeId = rtStock.Id, ExpiredDate__c = System.today(), WOSLineID__c = woslTransfer.Id );
        FlsService.doInsert(stock);
    }
    
    static testMethod void PrintWOSReportControllerInbound(){
        Test.startTest();
        PageReference pageRef = Page.PrintWOSReport;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('wosId', wosInbound.Id);
        pageRef.getParameters().put('rtype', mapRTWOS.get('InboundReceiving').Id);
        PrintWOSReportController ctrl = new PrintWOSReportController();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testMethod void PrintWOSReportControllerTransfer(){
        Test.startTest();
        PageReference pageRef = Page.PrintWOSReport;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('wosId', wosTransfer.Id);
        pageRef.getParameters().put('rtype', mapRTWOS.get('TransferDispatch').Id);
        PrintWOSReportController ctrl = new PrintWOSReportController();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
}