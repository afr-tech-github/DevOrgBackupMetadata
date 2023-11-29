@isTest
private class ConsolCNTRTriggerClassTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        Date etd = Date.newInstance(2015, 07, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存', 'Business_Relationship__c' => 'Customer'};                                                                    
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionalFields);

		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'ETD__c' => etd, 'Status__c' => '輸入 税関審査終了(Cunstoms Declared)', 'RecordTypeId' => rt.Id, 'clofor_com_cfs__POD__c' => objPort.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);                                                                 
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id, 'Seikyusaki__c' => account.Id,
            									'NyukinKakuninzumi__c' => false};
		AnkenMeisai__c mei = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Name' => 'Test', 'MContainer__c' => '20\'DC', 'MContainer2__c' => '40\'DC', 'MContainerNumber__c' => 2, 'MContainerNumber2__c' => 3};
        MasterAnken__c consol = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
    }
    
    testmethod static void CheckConsolCNTR() {
        Test.startTest();
        MasterAnken__c cs = [SELECT Id FROM MasterAnken__c LIMIT 1];
        ConsolCNTR__c consol = new ConsolCNTR__c(ContainerType__c = '20\'DC',Consolidation__c = cs.Id);
        insert consol;
        Test.stopTest();
    }
}