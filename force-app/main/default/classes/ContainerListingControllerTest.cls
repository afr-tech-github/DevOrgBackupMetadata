/**
 * Created by khanhpham on 10/25/17.
 */
@IsTest(SeeAllData=false)
private with sharing class ContainerListingControllerTest {
    @testsetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        // Create an Account
        additionalFields = new Map<String, Object>{
                'Currency__c' => 'USD - U.S. Dollar'
        };
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        // Create SHIPMENT ORDER
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];

        additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001',
                'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES,
                'DeliveryService_required__c' => '2'
        };
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // Create Container Info
        additionalFields = new Map<String, Object>{
                'HBL_SHIPMENT__c' => shipment.Id, 'Container_NO__c' => 'BMOU6260034', 'Seal_No__c' => 'KG281561',
                'Container__c' => '20\'DC'
        };
        TestDataFactory.createSObject(new Container_Info__c(), true, additionalFields);
    }

    @IsTest static void shouldGenerateContainerLists() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = 'TEST0001'];
        PageReference pageReference = Page.ContainersList;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, String.valueOf(shipment.Id));
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_CHECK_FLAG, 'true');

        ContainerListingController controller = new ContainerListingController();

        Test.startTest();
        controller.buildContainerLists();
        Test.stopTest();
        System.assertEquals(1, controller.pages.size());
    }
}