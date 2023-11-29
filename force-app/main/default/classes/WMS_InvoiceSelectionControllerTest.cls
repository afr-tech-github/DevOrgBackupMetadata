@isTest
private class WMS_InvoiceSelectionControllerTest {
	private static WorkOrder__c workOrder{get; set;}
	private static Account customer{get; set;}
	private static Billing__c billing{get; set;}
	static{

		customer = new Account(
			name = 'Test',
			EnglishCompanyName__c = 'Test');
		Facility__c wareHouse = new Facility__c();
		FlsService.doInsert(new List<SObject> { customer, wareHouse });
		
		workOrder = new WorkOrder__c(
			Customer__c = customer.Id,
			WarehouseID__c = wareHouse.Id
			);
		FlsService.doInsert(workOrder);

		billing = new Billing__c(
			WorkOrderID__c = workOrder.Id,
			PaymentTo__c = customer.Id, 
			InvoiceTo__c = customer.Id,
			Unit__c = 'Container',
			TimeUnit__c = 'Day',
			ChargeUnitTotal__c = 10,
			PeriodUnit__c = 2,
			PricingNameAtPrintENG__c ='test',
			PricingNameAtPrintLocal__c ='Test',
			TaxRatioSelling__c = 10,
			TaxRatioBuying__c = 10,
			UnitPriceOfSellingLocal__c = 1000,
			TotalAmountOfSellingUSD__c = 1000,
			AmountOfTaxSelling__c = 100
			);
		FlsService.doInsert(billing);
	}
	
	@isTest static void test_method_initDisplay() {
		// Implement test code
		Test.startTest();
		WMS_InvoiceSelectionController.DisplayWrapper displayResult = WMS_InvoiceSelectionController.initDisplay(workOrder.Id, 'en', 'DEBIT_LOCAL');
		Map<String, String > translation = WMS_InvoiceSelectionController.getTranslationMap();
		System.assert(displayResult != null);
		Test.stopTest();
	}

	@isTest static void test_method_initDisplay2() {
		// Implement test code
		Test.startTest();
		WMS_InvoiceSelectionController.DisplayWrapper displayResult = WMS_InvoiceSelectionController.initDisplay(workOrder.Id, '', 'CREDIT_LOCAL');
		WMS_InvoiceSelectionController.createAttatchment(workOrder.Id, customer.Id,'DEBIT_LOCAL','en');
		System.assert(displayResult != null);
		Test.stopTest();
	}
	
}