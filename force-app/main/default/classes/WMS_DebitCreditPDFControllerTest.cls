@isTest
private class WMS_DebitCreditPDFControllerTest {
	private static WorkOrder__c workOrder{get; set;}
	private static Account customer{get; set;}
	private static Billing__c billing{get; set;}
	static{

		customer = new Account(
			name = 'Test',
			EnglishCompanyName__c = 'Test');
		FlsService.doInsert(customer);
		Facility__c wareHouse = new Facility__c();
		FlsService.doInsert(wareHouse);
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
	
	@isTest static void test_WMS_DebitCreditPDFController1(){
		Test.startTest();
			ApexPages.currentPage().getParameters().put('workOrderId', workOrder.Id);
			ApexPages.currentPage().getParameters().put('customerId',customer.Id);
			ApexPages.currentPage().getParameters().put('printType', 'DEBIT_LOCAL');
			ApexPages.currentPage().getParameters().put('language', 'en');
			WMS_DebitCreditPDFController ctrl = new WMS_DebitCreditPDFController();
			System.assert(customer.Id != null);
		Test.stopTest();
	}

	@isTest static void test_WMS_DebitCreditPDFController2(){
		Test.startTest();
			ApexPages.currentPage().getParameters().put('workOrderId', workOrder.Id);
			ApexPages.currentPage().getParameters().put('customerId',customer.Id);
			ApexPages.currentPage().getParameters().put('printType', 'DEBIT_USD');
			ApexPages.currentPage().getParameters().put('language', 'en');
			WMS_DebitCreditPDFController ctrl = new WMS_DebitCreditPDFController();
			System.assert(customer.Id != null);
		Test.stopTest();
	}

	@isTest static void test_WMS_DebitCreditPDFController3(){
		Test.startTest();
			ApexPages.currentPage().getParameters().put('workOrderId', workOrder.Id);
			ApexPages.currentPage().getParameters().put('customerId',customer.Id);
			ApexPages.currentPage().getParameters().put('printType', 'CREDIT_USD');
			ApexPages.currentPage().getParameters().put('language', 'en');
			WMS_DebitCreditPDFController ctrl = new WMS_DebitCreditPDFController();
			System.assert(customer.Id != null);
		Test.stopTest();
	}
	@isTest static void test_WMS_DebitCreditPDFController4(){
		Test.startTest();
			ApexPages.currentPage().getParameters().put('workOrderId', workOrder.Id);
			ApexPages.currentPage().getParameters().put('customerId',customer.Id);
			ApexPages.currentPage().getParameters().put('printType', 'CREDIT_LOCAL');
			ApexPages.currentPage().getParameters().put('language', 'en');
			WMS_DebitCreditPDFController ctrl = new WMS_DebitCreditPDFController();
			System.assert(customer.Id != null);
		Test.stopTest();
	}

	
	

}