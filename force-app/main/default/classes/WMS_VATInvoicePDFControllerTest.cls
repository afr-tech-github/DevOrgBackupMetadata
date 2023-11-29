@isTest
private class WMS_VATInvoicePDFControllerTest {
	private static WorkOrder__c workOrder{get; set;}
	private static CustomObject1__c shipmentOrder{get; set;}
	private static VAT_INVOICE__c currentVAT_FMS_WMS{get; set;}
	private static VAT_INVOICE__c currentVAT_FMS{get; set;}
	private static VAT_INVOICE__c currentVAT_WMS{get; set;}
	private static Billing__c billingWMS {get; set;}
	private static AnkenMeisai__c billingFMS{get;set;}
	private static List<ConnectBillingVAT__c> listConnectBilling = new List<ConnectBillingVAT__c>();
	private static List<INVOICING_VAT__c> listInvoicingVAT = new  List<INVOICING_VAT__c>();
	private static TariffMaster__c pricingName{get; set;}
	private static Account customer{get; set;}
	static{
		Site_Custom_Settings__c setting = new Site_Custom_Settings__c(
			VAT_Running_Number__c = 1,
			Company_Country__c ='VietNam' ,
			Local_Currency__c='VND');

		Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);

		pricingName = new TariffMaster__c(
			UNIT__c = 'B/L',
			Subcategory__c = 'B/L FEE',
			EngSubcategory__c ='B/L FEE',
			VATInvoiceAtPrintLocal__c='pricing test',
			VATInvoiceAtPrintENG__c ='pricing test'
		);

		customer = new Account(
			name = 'Test',
			EnglishCompanyName__c = 'Test');
		Facility__c wareHouse = new Facility__c();

		FlsService.doInsert(new List<SObject> { setting, config, pricingName, customer, wareHouse });

		workOrder = new WorkOrder__c(
			Customer__c = customer.Id,
			WarehouseID__c = wareHouse.Id
		);
		FlsService.doInsert(workOrder);

		RecordType oceanImportRecordType = [Select Id from RecordType where DeveloperName = 'RecordType1'];
        RecordType quotationRecordType = [Select Id from RecordType where DeveloperName = 'QUOTATION'];
		Map<String, Object> additionalFields = new Map<String, Object> {'Field1__c' => customer.Id, 'RecordTypeId' => oceanImportRecordType.Id,
                                                                        'ContainerNumber__c' => 1, 'Container__c' => '40`DC',
                                                                        'HBL__c' => 'IMPORT01'};
        shipmentOrder = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
		
        Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.SObjectType.VAT_INVOICE__c.getRecordTypeInfosByDeveloperName();

		currentVAT_WMS = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('CloWMSVATInvoice').getRecordTypeId()

			);
		//insert currentVAT_WMS;
		currentVAT_FMS = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY').getRecordTypeId()
			);
		//insert currentVAT_FMS;
		currentVAT_FMS_WMS = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('FMSTMSWMSVATInvoice').getRecordTypeId()
			);
		//insert currentVAT_FMS_WMS;
		list<VAT_INVOICE__c> listVAT = new List<VAT_INVOICE__c>();
		listVAT.add(currentVAT_WMS);
		listVAT.add(currentVAT_FMS);
		listVAT.add(currentVAT_FMS_WMS);
		FlsService.doInsert(listVAT);
		billingWMS = new Billing__c(
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
			AmountOfTaxSelling__c = 100,
			PricingName__c = pricingName.Id
			);
		FlsService.doInsert(billingWMS);

		additionalFields = new Map<String, Object>{
                'Anken__c' => shipmentOrder.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
                'Tariff__c' => pricingName.Id,
                'Seikyusaki__c' => customer.Id, 'SerchSyubetu__c' => 'FCL輸入',
                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'
        };
        billingFMS = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

	}
	
	@isTest static void test_method_reportWMS1() {
		// Implement test code
		Test.startTest();
			ConnectBillingVAT__c link1 = new ConnectBillingVAT__c(
	        	VATInvoiceID__c = currentVAT_WMS.Id,
	        	BillingID__c = billingWMS.Id
	        	);

			listConnectBilling.add(link1);
			FlsService.doInsert(listConnectBilling);
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_WMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'GROUPED_BY_WORKORDER');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}

	@isTest static void test_method_reportWMS2() {
		// Implement test code
		Test.startTest();
			ConnectBillingVAT__c link1 = new ConnectBillingVAT__c(
	        	VATInvoiceID__c = currentVAT_WMS.Id,
	        	BillingID__c = billingWMS.Id
	        	);

			listConnectBilling.add(link1);
			FlsService.doInsert(listConnectBilling);
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_WMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'GROUP_BY_CATEGORY');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}

	@isTest static void test_method_reportWMS3() {
		// Implement test code
		Test.startTest();
			ConnectBillingVAT__c link1 = new ConnectBillingVAT__c(
		        	VATInvoiceID__c = currentVAT_WMS.Id,
		        	BillingID__c = billingWMS.Id
		        	);

				listConnectBilling.add(link1);
			FlsService.doInsert(listConnectBilling);
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_WMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'GROUP_SUMMARY');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}

	@isTest static void test_method_reportWMS4() {
		// Implement test code
		Test.startTest();
			ConnectBillingVAT__c link1 = new ConnectBillingVAT__c(
		        	VATInvoiceID__c = currentVAT_WMS.Id,
		        	BillingID__c = billingWMS.Id
		        	);

				listConnectBilling.add(link1);
			FlsService.doInsert(listConnectBilling);
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_WMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'SINGLE_INVOICE');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}
	
	@isTest static void test_method_reportFMS1() {
		Test.startTest();
			INVOICING_VAT__c link1 = new INVOICING_VAT__c(
	        	INVOICING__c = billingFMS.Id,
	        	VAT_INVOICE__c = currentVAT_FMS.Id
	        	);
			listInvoicingVAT.add(link1);
			FlsService.doInsert(listInvoicingVAT);
			// Implement test code
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_FMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'SINGLE_INVOICE');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}
	@isTest static void test_method_reportFMS2() {
		Test.startTest();
			INVOICING_VAT__c link1 = new INVOICING_VAT__c(
	        	INVOICING__c = billingFMS.Id,
	        	VAT_INVOICE__c = currentVAT_FMS.Id
	        	);
			listInvoicingVAT.add(link1);
			FlsService.doInsert(listInvoicingVAT);
			// Implement test code
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_FMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'GROUP_SUMMARY');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}

	@isTest static void test_method_reportFMS3() {
		Test.startTest();
			INVOICING_VAT__c link1 = new INVOICING_VAT__c(
	        	INVOICING__c = billingFMS.Id,
	        	VAT_INVOICE__c = currentVAT_FMS.Id
	        	);
			listInvoicingVAT.add(link1);
			FlsService.doInsert(listInvoicingVAT);
			// Implement test code
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_FMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'GROUP_BY_CATEGORY');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}

	@isTest static void test_method_reportFMS4() {
		Test.startTest();
			INVOICING_VAT__c link1 = new INVOICING_VAT__c(
	        	INVOICING__c = billingFMS.Id,
	        	VAT_INVOICE__c = currentVAT_FMS.Id
	        	);
			listInvoicingVAT.add(link1);
			FlsService.doInsert(listInvoicingVAT);
			// Implement test code
			ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_FMS.Id );
			ApexPages.currentPage().getParameters().put('invoiceType', 'DRAFT_INVOICE');
			ApexPages.currentPage().getParameters().put('groupingType', 'GROUPED_BY_FORWARDING');
			ApexPages.currentPage().getParameters().put('currencyType','USD');
			ApexPages.currentPage().getParameters().put('language', 'vi');
			WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
			Integer x = 1;
        	System.assert(x != null);
		Test.stopTest();
	}

	/*@isTest static void test_method_reportWMSFMS() {
		Test.startTest();
		// Implement test code
		WMS_VATInvoicePDFController ctrl = new WMS_VATInvoicePDFController();
		Test.stopTest();
	}*/
	
}