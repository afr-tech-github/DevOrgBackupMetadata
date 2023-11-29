@isTest
private class FMS_SortByCurrentSOControllerTest {
    
    @testSetup static void setup() {
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
		FlsService.doInsert(config);
        RecordType oceanImportRecordType = [Select Id from RecordType where DeveloperName = 'RecordType1'];
        Map<String, Object> additionalFields = new Map<String, Object> {'Business_Relationship__c' => Constants.CUSTOMER_RELATIONSHIP};
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Name' => 'PARTNER001', 'Business_Relationship__c' => Constants.PARTNER_RELATIONSHIP};
        Account partner = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => oceanImportRecordType.Id,
                                                                        'ContainerNumber__c' => 1, 'Container__c' => '40`DC',
                                                                        'HBL__c' => 'IMPORT01'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入',
                                                'Subcategory__c' => '基本料金', 'Supplier__c' => account.Id,
                                                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
                                                'SerchSyubetu__c' => 'FCL輸入', 'Tariff__c' => tariff.Id,
                                                'Seikyusaki__c' => account.Id,
                                                'Selling_Tatekae__c' => false, 'SellTankaJPY__c' => 100};
        TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
                                                'Tariff__c' => tariff.Id,
                                                'Seikyusaki__c' => partner.Id, 'SerchSyubetu__c' => 'FCL輸入',
                                                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        System.assert(true);
    }
	
    testmethod static void getListAnkenMeisaiByShipment(){
        Test.startTest();
        List<AnkenMeisai__c> listMeisai = new List<AnkenMeisai__c>();
        listMeisai = [SELECT Id, Anken__c FROM AnkenMeisai__c ];
        List<clofor_com_cfs__AnkenMeisai__c> lstAnken = new List<clofor_com_cfs__AnkenMeisai__c>();
        lstAnken = FMS_SortByCurrentSOController.getListAnkenMeisaiByShipment(listMeisai.get(0).Anken__c);
        //List<AnkenWrapper> lstUpdate = FMS_SortByCurrentSOController.saveListAnken(lstAnkenData);
        System.assertEquals(2, lstAnken.size());
        Test.stopTest();
    }

    testmethod static void getPicklistValueFromObjectField(){
        Test.startTest();
        List<PicklistOption> lstOp = FMS_SortByCurrentSOController.getPicklistValueFromObjectField('clofor_com_cfs__AnkenMeisai__c',
                'clofor_com_cfs__ChargeUnit__c');
        System.assert(lstOp.size() > 0);
        Test.stopTest();
    }

    testmethod static void lookUp(){
        Test.startTest();
        List<sObject> lsAcc = FMS_SortByCurrentSOController.lookUp('', 'Account','', '', 'Name');
        System.assert(lsAcc.size() > 0);
        Test.stopTest();
    }

    testmethod static void saveListAnken(){
        Test.startTest();
        List<AnkenMeisai__c> listMeisai = new List<AnkenMeisai__c>();
        listMeisai = [SELECT Id, Anken__c FROM AnkenMeisai__c ];
        List<clofor_com_cfs__AnkenMeisai__c> lstAnken = new List<clofor_com_cfs__AnkenMeisai__c>();
        lstAnken = FMS_SortByCurrentSOController.getListAnkenMeisaiByShipment(listMeisai.get(0).Anken__c);
        FMS_SortByCurrentSOController.saveListAnken(lstAnken);
        System.assert(lstAnken.size() > 0);
        Test.stopTest();
    }

    testmethod static void deleteAnkenMeisai(){
        Test.startTest();
        List<AnkenMeisai__c> listMeisai = new List<AnkenMeisai__c>();
        listMeisai = [SELECT Id, Anken__c FROM AnkenMeisai__c ];
        List<clofor_com_cfs__AnkenMeisai__c> lstAnken = new List<clofor_com_cfs__AnkenMeisai__c>();
        lstAnken = FMS_SortByCurrentSOController.getListAnkenMeisaiByShipment(listMeisai.get(0).Anken__c);
        FMS_SortByCurrentSOController.deleteAnkenMeisai(lstAnken[0]);
        System.assert(lstAnken.size() > 0);
        Test.stopTest();
    }

}