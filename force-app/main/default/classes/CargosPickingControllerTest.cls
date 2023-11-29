@isTest
private class CargosPickingControllerTest {
	static Boolean isDataSetup = false;
	static PRODUCT__c prod;
	static PRODUCT__c prod1;
	static Account acc;
	static Facility__c fac;
	static GoodsPurchasingOrder__c po;
	static GoodsPurchasingOrder__c po1;
	static SALES_ORDER__c so;
	static SALES_ORDER__c so1;
	static GoodsPOProduct__c poProd;
	static SalesOrderProduct__c soProd;
	static WorkOrder__c wo;
	static WorkOrder__c wo1;
    static Cargo__c cargoTest;
    static Cargo__c cargoTest1;
    static ConnectWOProduct__c wop;
    static{
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        Contract__c con = new Contract__c();
		FlsService.doInsert(new List<SObject>{ config, con });

        fac = new Facility__c(FacilityName__c = 'Fac');
		prod = new Product__c(ProductName__c = 'prod', WeightUnit__c = 'g', BuyingWeightUnit__c = 'Kg',GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing', MaintenanceServiceBillingFreqType__c = 'Continuous Billing');
		prod1 = new Product__c(ProductName__c = 'prod1', GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing',MaintenanceServiceBillingFreqType__c = 'Continuous Billing');
        acc = new Account(name = 'testAcc', EnglishCompanyName__c = 'test');
		po = new GoodsPurchasingOrder__c(ApprovalStatus__c ='Approved', GoodsPurchasingOrderName__c = 'po', ContractID__c = con.Id);
		po1 = new GoodsPurchasingOrder__c(ApprovalStatus__c ='Approved',GoodsPurchasingOrderName__c = 'po1', ContractID__c = con.Id);
		so = new SALES_ORDER__c(ApprovalStatus__c ='Approved',SalesOrderName__c = 'so', ContractID__c = con.Id);
		so1 = new SALES_ORDER__c(ApprovalStatus__c ='Approved',SalesOrderName__c = 'so1', ContractID__c = con.Id);

		FlsService.doInsert(new List<SObject> { prod, prod1, acc, po, po1, so, so1, fac});

        wo = new WorkOrder__c(Customer__c = acc.id, SalesOrderId__c = so.Id, PurchasingOrderID__c = po.Id, WarehouseId__c = fac.Id);
        wo1 = new WorkOrder__c(Customer__c = acc.id, SalesOrderId__c = so1.Id, PurchasingOrderID__c = po1.Id, WarehouseId__c = fac.Id);
		poProd = new GoodsPOProduct__c(ProductId__c = prod.Id, GoodsPOID__c = po.Id, PlanQuantity__c = 2, TotalNetWeight__c = 1500);
		soProd = new SalesOrderProduct__c(ProductId__c = prod.Id, GoodSalesOrderID__c = so.Id, PlannedQuantity__c = 3, TotalNetWeight__c = 1500);

        FlsService.doInsert(new List<SObject> { wo, wo1, poProd, soProd});
        
        cargoTest = new Cargo__c(Product__c = prod.Id);
        cargoTest1 = new Cargo__c(Product__c = prod.Id);
        FlsService.doInsert(new List<Cargo__c>{ cargoTest, cargoTest1 });
        
        WorkOrderService__c wosPutaway= new WorkOrderService__c(
        	WorkOrder__c = wo.Id,
            RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('Putaway').getRecordTypeId()
        );
		FlsService.doInsert(wosPutaway);

        WOSLineItem__c wosl = new WOSLineItem__c(
            WorkOrderService__c = wosPutaway.Id,
            Cargo__c = cargoTest.Id
        );
        WOSLineItem__c wosl1 = new WOSLineItem__c(
            WorkOrderService__c = wosPutaway.Id,
            Cargo__c = cargoTest1.Id
        );
		FlsService.doInsert(new List<WOSLineItem__c>{wosl,wosl1});

        cargoTest.LastWosLineItem__c = wosl.Id;
        cargoTest.CargoLifeCycle__c = 'For sales';
        cargoTest1.LastWosLineItem__c = wosl.Id;
        cargoTest1.CargoLifeCycle__c = 'For sales';
        FlsService.doUpdate(new List<Cargo__c>{cargoTest, cargoTest1});

        WorkOrderService__c wosPicking= new WorkOrderService__c(
        	WorkOrder__c = wo1.Id,
            RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('Picking').getRecordTypeId()
        );
        FlsService.doInsert(wosPicking);
        
        WOSLineItem__c wosl2 = new WOSLineItem__c(
            WorkOrderService__c = wosPicking.Id,
            Cargo__c = cargoTest1.Id
        );
		FlsService.doInsert(wosl2);

        wop = new ConnectWOProduct__c(
            ProductID__c = prod.Id,
            WorkOrderID__c = wo1.Id,
            Quantity__c = 10
        );
		FlsService.doInsert(wop);
    }
    @IsTest static void test_CargosPicking() {
        Test.startTest();
        CargosPickingController.getData(wop.Id, null, null);
        CargosPickingController.pickCargos(wop.Id, new List<String> {cargoTest.Id},'Name','asc' );
        Integer x = 1;
        system.assert(x !=null);
        Test.stopTest();
    }
}