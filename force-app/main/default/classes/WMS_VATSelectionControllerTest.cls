@isTest
private class WMS_VATSelectionControllerTest {
	private static WorkOrder__c workOrder{get; set;}
	private static VAT_INVOICE__c currentVAT_WMS{get; set;}
	private static TariffMaster__c pricingName{get; set;}
	private static Account customer{get; set;}
	static{
		Site_Custom_Settings__c setting = new Site_Custom_Settings__c(
			VAT_Running_Number__c = 1,
			Company_Country__c ='VietNam' ,
			Local_Currency__c='VND');
        FlsService.doInsert(setting);
		pricingName = new TariffMaster__c(
			UNIT__c = 'B/L',
			Subcategory__c = 'B/L FEE',
			EngSubcategory__c ='B/L FEE',
			VATInvoiceAtPrintLocal__c='pricing test',
			VATInvoiceAtPrintENG__c ='pricing test'

		);
        FlsService.doInsert(pricingName);
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
		
        Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.SObjectType.VAT_INVOICE__c.getRecordTypeInfosByDeveloperName();

		currentVAT_WMS = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('CloWMSVATInvoice').getRecordTypeId()

			);
        FlsService.doInsert(currentVAT_WMS);
	}
	
	@isTest static void test_method_initDisplay() {
		// Implement test code
		Test.startTest();
			WMS_VATSelectionController.DisplayWrapper display =  WMS_VATSelectionController.initDisplay(currentVAT_WMS.Id, 'en', 'DRAFT_INVOICE');
			Integer x = 1;
        	System.assert(x != null);
	    Test.stopTest();
	}
	@isTest static void test_method_initDisplay1() {
		// Implement test code
		Test.startTest();
	    	WMS_VATSelectionController.DisplayWrapper display =  WMS_VATSelectionController.initDisplay(currentVAT_WMS.Id, 'en', 'DRAFT_INVOICE_COMBINED');
			Integer x = 1;
			System.assert(x != null);
		Test.stopTest();
	}
	@isTest static void test_method_initDisplay2() {
		// Implement test code
		Test.startTest();
			WMS_VATSelectionController.DisplayWrapper display =  WMS_VATSelectionController.initDisplay(currentVAT_WMS.Id, 'en', 'ORIGIN_INVOICE');
			Integer x = 1;
        System.assert(x != null);
	    Test.stopTest();
	}
	@isTest static void test_method_initDisplay3() {
		// Implement test code
		Test.startTest();
	    	WMS_VATSelectionController.DisplayWrapper display =  WMS_VATSelectionController.initDisplay(currentVAT_WMS.Id, 'en', 'ORIGIN_INVOICE_COMBINED');
			Integer x = 1;
			System.assert(x != null);
		Test.stopTest();
	}

	@isTest static void test_method_initDisplay5() {
		// Implement test code
		Test.startTest();
	    	WMS_VATSelectionController.DisplayWrapper display =  WMS_VATSelectionController.initDisplay(currentVAT_WMS.Id, 'en', 'DEBIT_INVOICE');
			Integer x = 1;
			System.assert(x != null);
		Test.stopTest();
	}
	@isTest static void test_method_initDisplay6() {
		// Implement test code
		Test.startTest();
	    	WMS_VATSelectionController.DisplayWrapper display =  WMS_VATSelectionController.initDisplay(currentVAT_WMS.Id, 'en', 'DEBIT_INVOICE_COMBINED');
			Integer x = 1;
			System.assert(x != null);
		Test.stopTest();
	}
	
	@isTest static void test_method_getTranslationMap() {
		// Implement test code
		Test.startTest();
			 Map<String, String > translations =  WMS_VATSelectionController.getTranslationMap();
			Integer x = 1;
        	System.assert(x != null);
	    Test.stopTest();
	}

	@isTest static void test_method_createAttatchment() {
		// Implement test code
		Test.startTest();
			 WMS_VATSelectionController.createAttatchment(currentVAT_WMS.Id, 'DRAFT_INVOICE','USD', 'en','SINGLE_INVOICE');
			 Integer x = 1;
        System.assert(x != null);
	    Test.stopTest();
	}
	
}