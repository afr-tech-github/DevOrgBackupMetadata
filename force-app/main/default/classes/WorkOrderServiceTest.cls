@isTest 
private class WorkOrderServiceTest {
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
	
	static void queryTestData() {
		fac = [SELECT Id, Name FROM Facility__c LIMIT 1];
		prod = [SELECT Id, Name, QR_Code__c FROM Product__c WHERE ProductName__c = 'prod' LIMIT 1];
		prod1 = [SELECT Id, Name, QR_Code__c FROM Product__c WHERE ProductName__c = 'prod1' LIMIT 1];
		acc = [SELECT Id FROM Account LIMIT 1];
		po = [SELECT Id FROM GoodsPurchasingOrder__c WHERE GoodsPurchasingOrderName__c = 'po' LIMIT 1];
		po1 = [SELECT Id FROM GoodsPurchasingOrder__c WHERE GoodsPurchasingOrderName__c = 'po1' LIMIT 1];
		so = [SELECT Id FROM SALES_ORDER__c WHERE SalesOrderName__c = 'so' LIMIT 1];
		so1 = [SELECT Id FROM SALES_ORDER__c WHERE SalesOrderName__c = 'so' LIMIT 1];
		poProd = [SELECT Id, PlanQuantity__c, TotalNetWeight__c FROM GoodsPOProduct__c LIMIT 1];
		soProd = [SELECT Id, PlannedQuantity__c, TotalNetWeight__c FROM SalesOrderProduct__c LIMIT 1];
		wo = [SELECT Id FROM WorkOrder__c WHERE PurchasingOrderID__c = :po.Id LIMIT 1];
		wo1 = [SELECT Id FROM WorkOrder__c WHERE PurchasingOrderID__c = :po1.Id LIMIT 1];
	}

    @TestSetUp static void testSetup(){
		Custom_Application_Config__c config = new Custom_Application_Config__c();
		config.Disabled_Workflow_Rule__c = true;
        config.Disabled_Trigger__c =true;
        FlsService.doInsert(config);

		Contract__c con = new Contract__c();
        acc = new Account(name = 'testAcc', EnglishCompanyName__c = 'test');
        FlsService.doInsert(new List<SObject> { acc, con });

        fac = new Facility__c(FacilityName__c = 'Fac');
		prod = new Product__c(ProductName__c = 'prod', WeightUnit__c = 'g', BuyingWeightUnit__c = 'Kg', GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing',MaintenanceServiceBillingFreqType__c = 'Continuous Billing');
		prod1 = new Product__c(ProductName__c = 'prod1',GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing', MaintenanceServiceBillingFreqType__c = 'Continuous Billing');
		po = new GoodsPurchasingOrder__c(GoodsPurchasingOrderName__c = 'po', ContractID__c = con.Id);
		po1 = new GoodsPurchasingOrder__c(GoodsPurchasingOrderName__c = 'po1', ContractID__c = con.Id);
		so = new SALES_ORDER__c(SalesOrderName__c = 'so', ContractID__c = con.Id, CustomerCompanyName__c = acc.Id);
		so1 = new SALES_ORDER__c(SalesOrderName__c = 'so1', ContractID__c = con.Id, CustomerCompanyName__c = acc.Id);

        FlsService.doInsert(new List<SObject> { prod, prod1, po, po1, so, so1, fac});

        wo = new WorkOrder__c(Customer__c = acc.id, SalesOrderId__c = so.Id, PurchasingOrderID__c = po.Id, WarehouseId__c = fac.Id);
        wo1 = new WorkOrder__c(Customer__c = acc.id, SalesOrderId__c = so1.Id, PurchasingOrderID__c = po1.Id, WarehouseId__c = fac.Id);
		poProd = new GoodsPOProduct__c(ProductId__c = prod.Id, GoodsPOID__c = po.Id, PlanQuantity__c = 2, TotalNetWeight__c = 1500);
		soProd = new SalesOrderProduct__c(ProductId__c = prod.Id, GoodSalesOrderID__c = so.Id, PlannedQuantity__c = 3, TotalNetWeight__c = 1500);

        FlsService.doInsert(new List<SObject> { wo, wo1, poProd, soProd });
    }
    

	@IsTest static void test_WO_Cargo() {
		
		queryTestData();
		Test.startTest();
		//check WO+Product created
		WorkOrderService.sync_WoProd_Po(new List<Id> { wo.Id, wo1.Id }, true);
        
        Cargo__c cargo = new Cargo__c(Product__c = prod.Id);
        FlsService.doInsert(cargo);
        FlsService.doInsert(new WO_Cargo__c(WorkOrder__c = wo.Id, Cargo__c = cargo.Id));
		system.assert(cargo != null);
		Test.stopTest();
    }

	@IsTest static void test_sync_WoProd_Po() {
		queryTestData();
		Test.startTest();
		//check WO+Product created
		WorkOrderService.sync_WoProd_Po(new List<Id> { wo.Id, wo1.Id }, true);
		ConnectWOProduct__c woProd = [SELECT Id, NetWeightKg__c, Quantity__c FROM ConnectWOProduct__c WHERE WorkOrderID__c = :wo.Id AND ProductId__c = :prod.Id AND Quantity__c = :poProd.PlanQuantity__c];
		System.assertEquals(woProd.Quantity__c, poProd.PlanQuantity__c);
        System.assertEquals(1500000, woProd.NetWeightKg__c);
		//then test if WO+Product final quantity can be sync back to PO+Product
		//set WO+Product final quantity to a dummy value
		woProd.FinalQuantity__c = 3;
        woProd.FinalNetWeight__c = 2000;
		FlsService.doUpdate(woProd);
		//sync
		WorkOrderService.sync_WoProd_Po(new List<Id> { wo.Id, wo1.Id }, false);
		//refresh PO+Product and assert final quantity match that of WO+Product
		poProd = [SELECT Id, FinalQuantity__c, FinalNetWeight__c FROM GoodsPOProduct__c LIMIT 1];
		System.assertEquals(woProd.FinalQuantity__c, poProd.FinalQuantity__c);
		System.assertEquals(2, poProd.FinalNetWeight__c);
		Test.stopTest();
	}

	@IsTest static void test_sync_WoProd_So() {
		queryTestData();
		Test.startTest();
		//check WO+Product created
		WorkOrderService.sync_WoProd_So(new List<Id> { wo.Id, wo1.Id }, true);
		ConnectWOProduct__c woProd = [SELECT Id, NetWeightKg__c, Quantity__c FROM ConnectWOProduct__c WHERE WorkOrderID__c = :wo.Id AND ProductId__c = :prod.Id AND Quantity__c = :soProd.PlannedQuantity__c];
		System.assertEquals(woProd.Quantity__c, soProd.PlannedQuantity__c);
        System.assertEquals(1500, woProd.NetWeightKg__c);
		
		//then test if WO+Product final quantity can be sync back to SO+Product
		//set WO+Product final quantity to a dummy value
		woProd.FinalQuantity__c = 2;
        woProd.FinalNetWeight__c = 2;
		FlsService.doUpdate(woProd);
		//sync
		WorkOrderService.sync_WoProd_So(new List<Id> { wo.Id, wo1.Id }, false);
		//refresh SO+Product and assert final quantity match that of WO+Product
		soProd = [SELECT Id, FinalQuantity__c, FinalNetWeight__c FROM SalesOrderProduct__c LIMIT 1];
		System.assertEquals(woProd.FinalQuantity__c, soProd.FinalQuantity__c);
		System.assertEquals(2, soProd.FinalNetWeight__c);
		Test.stopTest();
		
	}

	@IsTest static void test_updateWoProdFinalQtyFromWos() {
		queryTestData();
		Test.startTest();
		//create WOS and 3 cargos, 2 of "prod" and 1 of "prod1". Create WO+Product only for "prod", so the expect result is this record final quantity is 2
		WorkOrderService__c wos_InboundReceiving = new WorkOrderService__c(Status__c = 'Completed', ActualEndTime__c = System.now(), Warehouse__c = fac.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('InboundReceiving').getRecordTypeId());
        ConnectWOProduct__c woProd = new ConnectWOProduct__c(WorkOrderID__c = wo.Id, ProductId__c = prod.Id);
		Cargo__c cargo = new Cargo__c (Product__c = prod.Id, Weight__c = 3000);
        Cargo__c cargo1 = new Cargo__c (Product__c = prod.Id, Weight__c = 1500);
        Cargo__c cargo2 = new Cargo__c (Product__c = prod1.Id, Weight__c = 700);
        FlsService.doInsert(new List<SObject> { cargo, cargo1, cargo2, wos_InboundReceiving, woProd});
		
		//link 3 cargoes to the wos
        FlsService.doInsert(new List<SObject> { 
			new WosLineItem__c (WorkOrderService__c = wos_InboundReceiving.Id, Cargo__c = cargo.Id, CargoStatus__c = 'Completed'),
			new WosLineItem__c (WorkOrderService__c = wos_InboundReceiving.Id, Cargo__c = cargo1.Id, CargoStatus__c = 'Completed'),
			new WosLineItem__c (WorkOrderService__c = wos_InboundReceiving.Id, Cargo__c = cargo2.Id, CargoStatus__c = 'Completed')
		}); 

		//sync
		WorkOrderService.updateWoProdFinalQtyFromWos(new List<Id> { wo.Id, wo1.Id });
		//assert 
		woProd = [SELECT Id, FinalQuantity__c, FinalNetWeight__c FROM ConnectWOProduct__c WHERE Id = :woProd.Id];
		System.assertEquals(2, woProd.FinalQuantity__c);
		System.assertEquals(4500, woProd.FinalNetWeight__c);
		Test.stopTest();
		
	}
}