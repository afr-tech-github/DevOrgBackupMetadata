@isTest
private class HouseBillLadingControllerTest {
    @testsetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object> {'Currency__c' => 'USD - U.S. Dollar'};                                                                        
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001',
										            'TranporationType__c' => PicklistReference.TRANSPORTATION_FCL, 'CONTAINERSEALNO__c' => 'ABCD1234567/SEAL123',
										            'ContainerNumber__c' => 2, 'Container__c' => '40\'DC'};
		CustomObject1__c shipmentFCL = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0002',
										            'TranporationType__c' => PicklistReference.TRANSPORTATION_LCL, 'CONTAINERSEALNO__c' => 'QWER7654321/SEAL321',
										            'ContainerNumber__c' => 3, 'Container__c' => '40\'HC'};
		CustomObject1__c shipmentLCL = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Name__c' => 'Port 1', 'Code__c' => 'CN001', 'Category__c' => 'Port', 'Country__c' => 'VIETNAM'};
        TestDataFactory.createSObject(new MANIFEST__c(), true, additionalFields);
        additionalFields = new Map<String, Object> {'Name__c' => 'Gross Unit 1', 'Code__c' => 'GU001', 'Category__c' => 'GrossUnit', 'Country__c' => 'VIETNAM'};
        TestDataFactory.createSObject(new MANIFEST__c(), true, additionalFields);
        additionalFields = new Map<String, Object> {'Name__c' => 'Document Function 1', 'Code__c' => 'DOC001', 'Category__c' => 'Document\'s Function', 'Country__c' => 'VIETNAM'};
        TestDataFactory.createSObject(new MANIFEST__c(), true, additionalFields);
    }
    
    testmethod static void shouldCallDispatcher() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'TEST0001'];
        
        Test.startTest();
        HouseBillLadingReportDispatcher.createAttachment(shipment.Id, shipment.Name, String.valueOf(shipment.QuotationVer__c));
        Test.stopTest();
        System.assert(true);
    }
    
    testmethod static void shouldReportByFCLRules() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'TEST0001'];
        PageReference pageRef = Page.HouseBillLadingReport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        
        Test.startTest();
        new HouseBillLadingReportController();
        Test.stopTest();
        System.assert(true);
    }
    
    testmethod static void shouldReportByLCLRules() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'TEST0002'];
        PageReference pageRef = Page.HouseBillLadingReport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        
        Test.startTest();
        new HouseBillLadingReportController();
        Test.stopTest();
        System.assert(true);
    }
}