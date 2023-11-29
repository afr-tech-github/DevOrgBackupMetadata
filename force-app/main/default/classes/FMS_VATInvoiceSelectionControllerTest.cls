@isTest
private class FMS_VATInvoiceSelectionControllerTest {
	private static WorkOrder__c workOrder{get; set;}
	private static VAT_INVOICE__c currentVAT_FMS{get; set;}
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

		currentVAT_FMS = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('CloWMSVATInvoice').getRecordTypeId()
			);
		FlsService.doInsert(currentVAT_FMS);
	}
	@isTest static void test_method_Contructor() {
		Test.startTest();
		ApexPages.currentPage().getParameters().put('invoiceId', currentVAT_FMS.Id);
		FMS_VATInvoiceSelectionController ctrl = new FMS_VATInvoiceSelectionController();
		ctrl.requiredAttachmentCreation = true;
		ctrl.generateInvoice();
		System.assert(currentVAT_FMS.Id != NULL);
		Test.stopTest();
		// Implement test code
	}

	
	
	
}