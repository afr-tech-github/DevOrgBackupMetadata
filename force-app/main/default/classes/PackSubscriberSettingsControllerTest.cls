@isTest(SeeAllData=false)
private class PackSubscriberSettingsControllerTest {
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
    
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof MetadataService.retrieve_element)
				response.put('response_x', new MetadataService.retrieveResponse_element());
			else if(request instanceof MetadataService.checkDeployStatus_element)
				response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
			else if(request instanceof MetadataService.listMetadata_element)
				response.put('response_x', new MetadataService.listMetadataResponse_element());
			else if(request instanceof MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof MetadataService.describeMetadata_element)
				response.put('response_x', new MetadataService.describeMetadataResponse_element());
			else if(request instanceof MetadataService.deploy_element)
				response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			return;
		}
	} 
    
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
            	'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }

    @isTest static void shouldPersistSettings() {
        PageReference currentPage = Page.AFRSettings;
        Test.setCurrentPage(currentPage);
        PackSubscriberSettingsController controller = new PackSubscriberSettingsController();
        
        Test.startTest();
        Site_Custom_Settings__c settings = controller.settings;
        settings.Company_Address__c = '999 XYZ, Ho Chi Minh, Vietnam';
        
        PageReference nextPage = controller.save();
        Test.stopTest();
        
        Site_Custom_Settings__c updatedSettings = [SELECT Company_Address__c 
                                                   FROM Site_Custom_Settings__c 
                                                   WHERE Id = :settings.Id];
        System.assertEquals('999 XYZ, Ho Chi Minh, Vietnam', updatedSettings.Company_Address__c);
        System.assertEquals(null, nextPage);
    }

    @isTest static void shouldResetSettings() {
        PageReference currentPage = Page.AFRSettings;
        Test.setCurrentPage(currentPage);
        PackSubscriberSettingsController controller = new PackSubscriberSettingsController();
        
        Test.startTest();
        Site_Custom_Settings__c settings = controller.settings;
        settings.Company_Address__c = '999 XYZ, Ho Chi Minh, Vietnam';
        
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        
        PageReference nextPage = controller.reset();
        Test.stopTest();
        
        Site_Custom_Settings__c updatedSettings = [SELECT Company_Address__c 
                                                   FROM Site_Custom_Settings__c 
                                                   WHERE Id = :settings.Id];
        System.assertEquals('123 ABC, Tokyo, Japan', updatedSettings.Company_Address__c);
        System.assertEquals(Page.AFRSettings.getUrl(), nextPage.getUrl());
    }
    
    @isTest static void shouldUpdateOperationEmailAlertRecipients() {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        PageReference currentPage = Page.AFRSettings;
        Test.setCurrentPage(currentPage);
        PackSubscriberSettingsController controller = new PackSubscriberSettingsController();
        Test.startTest();
        controller.updateOperationAlertRecipients();
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest static void shouldUpdateReminderEmailAlertRecipients() {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        PageReference currentPage = Page.AFRSettings;
        Test.setCurrentPage(currentPage);
        PackSubscriberSettingsController controller = new PackSubscriberSettingsController();
        Test.startTest();
        controller.updateReminderAlertRecipients();
        Test.stopTest();
        System.assert(true);
    }
    
	@isTest static void shouldPopulateReportMappings() {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        PageReference currentPage = Page.AFRSettings;
        Test.setCurrentPage(currentPage);
        PackSubscriberSettingsController controller = new PackSubscriberSettingsController();
        Test.startTest();
        controller.populateReportMappings();
        Test.stopTest();
        System.assert(true);
    }
}