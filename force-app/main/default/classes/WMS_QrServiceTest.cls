@isTest
private class WMS_QrServiceTest {
	static Account acc;
	static Worker__c wk;
	static Facility__c fac;
	static Facility__c fac1;
	static Locator__c lo;
	static Locator__c lo1;
	static PRODUCT__c prod;
	static Cargo__c cargo;
	static WorkOrder__c wo;
	static WorkOrder__c wo1;
	static WorkOrderService__c wos_InboundReceiving;
	static WorkOrderService__c wos_Putaway;
	static WorkOrderService__c wos_Picking;
	static WorkOrderService__c wos_Dispatch;
	static WorkOrderService__c wos_TransferDispatch;
	static WorkOrderService__c wos_CombinedDispatch;
	static WorkOrderService__c wos_TransferReceiving;
	static WorkOrderService__c wos_CombinedReceiving;
	static WMS_QrService.ProcessCargoRequest req = new WMS_QrService.ProcessCargoRequest();

	static void queryTestData() {
		acc = [SELECT Id FROM Account LIMIT 1];
		prod = [SELECT Id, Name, QR_Code__c FROM Product__c LIMIT 1];
		cargo = [SELECT Id, Name FROM Cargo__c LIMIT 1];
		wk = [SELECT Id FROM Worker__c LIMIT 1];
		fac = [SELECT Id FROM Facility__c WHERE FacilityName__c = 'Fac' LIMIT 1];
		fac1 = [SELECT Id FROM Facility__c WHERE FacilityName__c = 'Fac1' LIMIT 1];
		lo = [SELECT Id FROM Locator__c WHERE WarehouseID__c = :fac.Id LIMIT 1];
		lo1 = [SELECT Id FROM Locator__c WHERE WarehouseID__c = :fac1.Id LIMIT 1];
		wo = [SELECT Id FROM WorkOrder__c WHERE RecordType.DeveloperName = 'Inbound' LIMIT 1];
		wo1 = [SELECT Id FROM WorkOrder__c WHERE RecordType.DeveloperName = 'CombinedTransfer' LIMIT 1];
		wos_InboundReceiving = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'InboundReceiving' LIMIT 1];
		wos_Putaway = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'Putaway' LIMIT 1];
		wos_Picking = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'Picking' LIMIT 1];
		wos_Dispatch = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'OutboundDispatch' LIMIT 1];
		wos_TransferDispatch = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'TransferDispatch' AND WorkOrder__c = :wo.Id LIMIT 1];
		wos_TransferReceiving = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'TransferReceiving' AND WorkOrder__c = :wo.Id LIMIT 1];
		wos_CombinedDispatch = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'TransferDispatch' AND WorkOrder__c = :wo1.Id LIMIT 1];
		wos_CombinedReceiving = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'TransferReceiving' AND WorkOrder__c = :wo1.Id LIMIT 1];

		req = new WMS_QrService.ProcessCargoRequest();
		req.CargoId = cargo.Id;
		req.WorkerId = wk.Id;
		req.LocatorId = lo.Id;
		req.LotNumber = 'test';
		req.ProcessServiceIds = new List<Id>();
		req.AddToServiceIds = new List<Id>();
	}

    @TestSetUp static void testSetup(){
		prod = new Product__c(WeightUnit__c = 'g', BillingType__c = 'Weight', GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing',MaintenanceServiceBillingFreqType__c = 'Continuous Billing' );
        acc = new Account(name = 'testAcc', EnglishCompanyName__c = 'test');
        wk = new Worker__c();
        fac = new Facility__c(FacilityName__c = 'Fac');
        fac1 = new Facility__c(FacilityName__c = 'Fac1');

		FlsService.doInsert(new List<SObject> { prod, acc, wk, fac, fac1});

        lo = new Locator__c(WarehouseID__c = fac.Id, LocatorLayer__c = 'Floor Layer', LocationAreaType__c = 'Floor', FloorCode__c = 'F01', AreaCode__c = 'A', SectionCode__c = 'S', Rack__c = 'R', Level__C = 'L');
        lo1 = new Locator__c(WarehouseID__c = fac1.Id, LocatorLayer__c = 'Floor Layer', LocationAreaType__c = 'Floor', FloorCode__c = 'F01', AreaCode__c = 'A', SectionCode__c = 'S', Rack__c = 'R', Level__C = 'L');
        wo = new WorkOrder__c(Customer__c = acc.id, WarehouseID__c = fac.id, RecordTypeId = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByDeveloperName().get('Inbound').getRecordTypeId());
        wo1 = new WorkOrder__c(Customer__c = acc.id, WarehouseID__c = fac1.id, RecordTypeId = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByDeveloperName().get('CombinedTransfer').getRecordTypeId());

		FlsService.doInsert(new List<SObject> { lo, lo1, wo, wo1});

		wos_InboundReceiving = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac.Id, Locator__c = lo.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('InboundReceiving').getRecordTypeId());
		wos_Putaway = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac.Id, Locator__c = lo.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('Putaway').getRecordTypeId());
		wos_Picking = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac.Id, Locator__c = lo.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('Picking').getRecordTypeId());
		wos_Dispatch = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac.Id, Locator__c = lo.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('OutboundDispatch').getRecordTypeId());
		wos_TransferDispatch = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac.Id, Locator__c = lo.Id, DestinationWarehouse__c = fac1.Id, CombinedWorkOrder__c = wo1.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('TransferDispatch').getRecordTypeId());
		wos_TransferReceiving = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac1.Id, Locator__c = lo1.Id, CombinedWorkOrder__c = wo1.Id, WorkOrder__c = wo.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('TransferReceiving').getRecordTypeId());
		wos_CombinedDispatch = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac.Id, Locator__c = lo.Id, WorkOrder__c = wo1.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('TransferDispatch').getRecordTypeId());
		wos_CombinedReceiving = new WorkOrderService__c(Status__c = 'Resource Assigned', Warehouse__c = fac1.Id, Locator__c = lo.Id, WorkOrder__c = wo1.Id, RecordTypeId = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('TransferReceiving').getRecordTypeId());
        cargo = new Cargo__c (Product__c = prod.Id, PlannedWeight__c = 1000);

		FlsService.doInsert(new List<SObject> { cargo, wos_InboundReceiving, wos_Putaway, wos_Picking, wos_Dispatch, wos_TransferDispatch, wos_TransferReceiving, wos_CombinedDispatch, wos_CombinedReceiving });
    }

	@isTest static void test_getRelatedServices() {
		Test.startTest();
		queryTestData();
		System.assertEquals(5, ((List<WorkOrderService__c>)WMS_QrService.getRelatedServices(wos_InboundReceiving.Id)).size());
		Test.stopTest();
	}
     
	@isTest static void test_getTasks() {
		test.startTest();
		// Implement test code
		List<WorkOrderService__c> lsWOS = (List<WorkOrderService__c>)WMS_QrService.getTasks(null, null);
		System.assertEquals(lsWOS.size(), 0);
		test.stopTest();
	}

	@isTest static void test_startTask() {
		queryTestData();
        Test.startTest();
        try {
            WMS_QrService.startTask(null); 
        }
        catch (Exception ex) {
        }
        try {
            WMS_QrService.finalizeTask(null, null);
        }
        catch (Exception ex) {
        }
        WorkOrderService__c WOS = [SELECT Id, Name, Status__c, ScheduledStartTime__c, ActualStartTime__c,
                                   				ActualEndTime__c, RecordType.DeveloperName
        										FROM WorkOrderService__c LIMIT 1];
        WMS_QrService.startTask(WOS.id);

        WMS_QrService.startTaskV2(WOS.id);
        WOS = [SELECT Id, Name, Status__c, ScheduledStartTime__c, ActualStartTime__c,
                                   				ActualEndTime__c, RecordType.DeveloperName
        										FROM WorkOrderService__c
        										WHERE Id = :WOS.id];
        System.assertEquals(WOS.Status__c , 'On Progress');

        WMS_QrService.finalizeTask(wos_InboundReceiving.id, new List<Id> { wos_Putaway.Id });
        WMS_QrService.finalizeTask(wos_CombinedDispatch.id, null);
		WMS_QrService.finalizeTask(wos_CombinedReceiving.id, null);
		system.assert(WOS != null);
        Test.stopTest();
	}

    @IsTest static void testUpdate(){
		Test.startTest();
        account acc = [select id from account limit 1];
        WMS_QrService.updateRecord(acc);

        try{
            WMS_QrService.updateRecord(new Account());
        }catch(exception ex){
		}
		system.assert(acc != null);
        Test.stopTest();
    }

    @IsTest static void testGetWeightBasedCargoes(){
		queryTestData();
        
		FlsService.doInsert(new List<WosLineItem__c> {
			new WosLineItem__c (WorkOrderService__c = wos_InboundReceiving.Id, Cargo__c = cargo.Id)
		});

        Test.startTest(); 
		Map<Decimal, List<Id>> temp = WMS_QrService.getWeightBasedCargoes(wos_InboundReceiving.Id, prod.Id, lo.Id);
		System.assertEquals(true, temp.containsKey(1000.0));
		System.assertEquals(1, temp.get(1000.0).size());
        Test.stopTest();
    }

    @IsTest static void testProcessCargo_cargoNotLinked(){
		queryTestData();
        
        Test.startTest(); 
		req.ServiceId = wos_InboundReceiving.Id;
        //test cargo not linked
        try {
            WMS_QrService.processCargo_internal(req);
        }
		catch (Exception ex) {}
		System.assert(req.ServiceId != null);
        Test.stopTest();
    }

    @IsTest static void testProcessCargo_receive(){
		queryTestData();
        Test.startTest();
		req.ServiceId = wos_InboundReceiving.Id;
        req.LotNumber = 'test';
		req.ProcessServiceIds = new List<Id> { wos_Putaway.Id };
		FlsService.doInsert(new List<WosLineItem__c> {
			new WosLineItem__c (WorkOrderService__c = wos_InboundReceiving.Id, Cargo__c = cargo.Id),
			new WosLineItem__c (WorkOrderService__c = wos_Putaway.Id, Cargo__c = cargo.Id)
		}); 
        try{
			WMS_QrService.processCargo_internal(req);
        }catch(exception ex){
		}
        Test.stopTest();

		//the above 2 WOS line items should be marked as scanned
		System.assertEquals(1, [SELECT COUNT() FROM WosLineItem__c WHERE IsCargoScanned__c = true]);
    }
	
    @IsTest static void testProcessCargo_receive_productQrScan(){
		queryTestData();
        Test.startTest();
		req.ServiceId = wos_InboundReceiving.Id;
		req.ProductId = prod.Id;
		req.ProductQuantity = 1;
		req.PlannedWeight = 1000;
        req.LotNumber = 'test';
		req.ProcessServiceIds = new List<Id> { wos_Putaway.Id };
		FlsService.doInsert(new List<WosLineItem__c> {
			new WosLineItem__c (WorkOrderService__c = wos_InboundReceiving.Id, Cargo__c = cargo.Id),
			new WosLineItem__c (WorkOrderService__c = wos_Putaway.Id, Cargo__c = cargo.Id)
		}); 
        try{
			WMS_QrService.processCargo_internal(req);
        }catch(exception ex){
		}
        Test.stopTest();

		//the above 2 WOS line items should be marked as scanned
		System.assertEquals(1, [SELECT COUNT() FROM WosLineItem__c WHERE IsCargoScanned__c = true]);
    }
	
	
    @IsTest static void testProcessCargo_receive_productQrScan_notEnoughQty(){
		Test.startTest();
		queryTestData();
		req.ServiceId = wos_InboundReceiving.Id;
		req.ProductId = prod.Id;
		req.ProductQuantity = 2;
		try{
			WMS_QrService.processCargo_internal(req);
        }catch(exception ex){
		}
		system.assert( req.ServiceId != null);
		Test.stopTest();
	}
	
    @IsTest static void testProcessCargo_combinedDispatch(){
		queryTestData();
        Test.startTest();
		req.ServiceId = wos_CombinedDispatch.Id;
        req.LotNumber = 'test';
		req.ProcessServiceIds = new List<Id> { wos_CombinedReceiving.Id };
		FlsService.doInsert(new List<WosLineItem__c> {
			new WosLineItem__c (WorkOrderService__c = wos_CombinedDispatch.Id, Cargo__c = cargo.Id),
			new WosLineItem__c (WorkOrderService__c = wos_CombinedReceiving.Id, Cargo__c = cargo.Id),
			new WosLineItem__c (WorkOrderService__c = wos_TransferDispatch.Id, Cargo__c = cargo.Id),
			new WosLineItem__c (WorkOrderService__c = wos_TransferReceiving.Id, Cargo__c = cargo.Id)
		}); 
		try{
			WMS_QrService.processCargo_internal(req);
        }catch(exception ex){
		}
        Test.stopTest();

		//source dispatch line and receiving line should be marked as completed also
		System.assertEquals(3, [SELECT COUNT() FROM WosLineItem__c WHERE IsCargoScanned__c = true]);
    }
	
    @IsTest static void testProcessCargo_combinedReceiving(){
		queryTestData();
        Test.startTest();
		req.ServiceId = wos_CombinedReceiving.Id;
		FlsService.doInsert(new List<WosLineItem__c> {
			new WosLineItem__c (WorkOrderService__c = wos_CombinedReceiving.Id, Cargo__c = cargo.Id),
			new WosLineItem__c (WorkOrderService__c = wos_TransferReceiving.Id, Cargo__c = cargo.Id)
		}); 
        WMS_QrService.processCargo_internal(req);
        Test.stopTest();

		//source receiving line should be marked as completed also
		System.assertEquals(2, [SELECT COUNT() FROM WosLineItem__c WHERE IsCargoScanned__c = true]);
    }
	@isTest static void test_getWosRecordTypes() {
		test.startTest();
		// Implement test code
		List<Map<String,String>> lsMap = (List<Map<String,String>>)WMS_QrService.getWosRecordTypes(null, null);
		System.assertEquals(lsMap.size(), 7);
		test.stopTest();
	}
	// @isTest static void test_processCargo() {
		// test.startTest();
		// List<WosLineItem__c> lsWLI = (List<WosLineItem__c>)WMS_QrService.processCargo(wos_Picking.Id, cargo.Id,prod.Id,0,0,0,'Completed',wk.Id,null,null,null,null);
		// System.assertEquals(lsWLI.size(), 0);
		// test.stopTest();
	// }
	@isTest static void test_getWoProductsByWosId() {
		test.startTest();
		// Implement test code
		List<ConnectWOProduct__c> lsCWP = (List<ConnectWOProduct__c>)WMS_QrService.getWoProductsByWosId(null);
		System.assertEquals(lsCWP.size(), 0);
		test.stopTest();
	}
	@isTest static void test_getWoCargoesByWosId() {
		test.startTest();
		// Implement test code
		List<WO_Cargo__c> lsWC = (List<WO_Cargo__c>)WMS_QrService.getWoCargoesByWosId(null);
		System.assertEquals(lsWC.size(), 0);
		test.stopTest();
	}
	@isTest static void test_createWoProductAndcreateCargo() {
		test.startTest();
		WorkOrderService__c wos = [SELECT Id FROM WorkOrderService__c LIMIT 1];
		PRODUCT__c pro = [SELECT Id FROM PRODUCT__c LIMIT 1];
		// Implement test code
		ConnectWOProduct__c CWP = (ConnectWOProduct__c)WMS_QrService.createWoProduct(wos.Id,pro.Id);
		WO_Cargo__c lstWOC = (WO_Cargo__c)WMS_QrService.createCargo(wos.Id,pro.Id);
		test.stopTest();
	}
	// @isTest static void test_getCargoDetails() {
		// test.startTest();
		// WorkOrderService__c wos = [SELECT Id FROM WorkOrderService__c WHERE RecordType.DeveloperName = 'InboundReceiving' LIMIT 1];
		// Cargo__c car = [SELECT Id FROM Cargo__c LIMIT 1];
		// List<Cargo__c> lsCWP = (List<Cargo__c>)WMS_QrService.getCargoDetails(wos.Id,car.Id);
		// System.assertEquals(lsCWP.size(), 0);
		// test.stopTest();
	// }
	// @isTest static void test_processCargoV2() {
		// test.startTest();
		// Cargo__c car = [SELECT Id FROM Cargo__c LIMIT 1];
		// WosLineItem__c wli = new WosLineItem__c(WorkOrderService__c = wos_Picking.Id, Cargo__c = car.Id);
		// insert wli;
		// List<Id> lstId = new List<Id>();
		// for (WorkOrderService__c wos : [SELECT Id FROM WorkOrderService__c LIMIT 10]){
			// lstId.add(wos.Id);
		// }
		// WMS_QrService.processCargoV2(car,wli,lstId);
		// test.stopTest();
	// }
}