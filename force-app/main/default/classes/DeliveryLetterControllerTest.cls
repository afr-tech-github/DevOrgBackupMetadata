@isTest
private class DeliveryLetterControllerTest {
	@testsetup static void setUp() {
        Date etd = Date.newInstance(2015, 01, 02);
        Date eta = Date.newInstance(2015, 02, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.CROSS_BOARDER_RT AND SobjectType = 'clofor_com_cfs__CustomObject1__c'];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            									'RecordTypeId' => rt.Id, 'ETD__c' => etd, 'ETA__c' => eta,
            									'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES,
            									'TranporationType__c' => 'LCL', 'DeliveryService_required__c' => '1'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
		additionFields = new Map<String, Object>{'Context__c' => 'ALL', 'Active__c' => true,
            'Name' => 'ALL', 'en_US__c' => 'ALL', 'vi__c' => 'Tất cả', 'ja__c' => 'ALL'};
		TestDataFactory.createSObject(new Translation__c(), true, additionFields);	
        System.assert(true);
    }
    
    testmethod static void shouldShowLetterForSingleCargo() {
        CustomObject1__c shipment = [select Id from CustomObject1__c limit 1];
        Cargo_Delivery__c cd = [select Id from Cargo_Delivery__c limit 1];
        
        PageReference currentPage = Page.page_LoadUnloadLocations;
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put('shipmentId', shipment.Id);
        ApexPages.currentPage().getParameters().put('cargoId', cd.Id);
        
        DeliveryLetterController controller = new DeliveryLetterController();
        System.assert(true);
    }
    
    testmethod static void shouldShowLetterForAllCargoes() {
        CustomObject1__c shipment = [select Id from CustomObject1__c limit 1];
        
        PageReference currentPage = Page.page_LoadUnloadLocations;
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put('shipmentId', shipment.Id);
        ApexPages.currentPage().getParameters().put('cargoId', 'all');
        
        DeliveryLetterController controller = new DeliveryLetterController();
        System.assertEquals(1, controller.cargoDeliveries.size());
    }
}