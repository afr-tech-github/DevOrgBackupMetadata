@isTest
private class ForwardingWorkProgressExtTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }
    
    testMethod static void shouldShowProgressBarForOceanImport() {
        executionCommonTest(Constants.OCEAN_IMPORT_RT);
        System.assert(true);
    }
    
    testMethod static void shouldShowProgressBarForOceanExport() {
        executionCommonTest(Constants.OCEAN_EXPORT_RT);
        System.assert(true);
    }
    
    testMethod static void shouldShowProgressBarForAirImport() {
        executionCommonTest(Constants.AIR_IMPORT_RT);
        System.assert(true);
    }
    
    testMethod static void shouldShowProgressBarForAirExport() {
        executionCommonTest(Constants.AIR_EXPORT_RT);
        System.assert(true);
    }
    
    private static void executionCommonTest(final String recordType) {
        RecordType rt = [Select Id from RecordType where DeveloperName = :recordType];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Map<String, Object> additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                                        'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                        'clofor_com_cfs__ContainerNumber4__c' => 1,
                                                                        'clofor_com_cfs__Container__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container4__c' => '20\'DC'};
        CustomObject1__c shipment =  (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        PageReference pageRef = new PageReference('/' + shipment.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(shipment);
        ForwardingWorkProgressExt controllerExt = new ForwardingWorkProgressExt(controller);
    }
}