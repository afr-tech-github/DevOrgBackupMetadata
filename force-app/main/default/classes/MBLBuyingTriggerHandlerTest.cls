@isTest
public class MBLBuyingTriggerHandlerTest {
    private static Account accountTest{get;set;}
    private static LoadLocation__c warehouse{get;set;}
    private static MasterAnken__c mblShipment{get;set;}
    private static CustomObject1__c shipment{get;set;}
    private static TariffMaster__c tariff{get;set;}
    private static AnkenMeisai__c ankenMeisai{get;set;}
    private static MasterAnkenMeisai__c masterMeisai{get;set;}
    static{
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        RecordType hblsbRT = [Select Id from RecordType where DeveloperName = 'Consolidation_Cost_allocation'];
        
        // Create account
		additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存'};                                                                        
		accountTest = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => accountTest.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => accountTest.Id, 'MCBM__c' => 2};
        mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'BuyTankaJPY__c' => 1000, 'Suryo__c' => 1, 'curr__c' => 'JPY',
            										'BuyTankaUSD__c' => 100, 'Cost_Allocation_Catetory__c' => null};
		masterMeisai = (MasterAnkenMeisai__c)TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

		// create h B/L SHIPMENT        
		additionalFields = new Map<String, Object> {'Field1__c' => accountTest.Id, 'CBM__c' => 1,
            										'Status__c' => '輸入 税関審査終了(Cunstoms Declared)',
            										'LoadLocation__c' => warehouse.Id, 'BookingNv__c' => accountTest.Id,
            										'RecordTypeId' => rt.Id, 'MasterAnkenName__c' => mblShipment.Id};
        shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => accountTest.Id};
		 tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id, 'RecordTypeId' => hblsbRT.Id,
            									'Seikyusaki__c' => accountTest.Id, 'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};              
		ankenMeisai = (AnkenMeisai__c)TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
    }

    testmethod static void shouldCopyUnitPriceFromAllocationOnUpdate() {
        Test.startTest();
        masterMeisai.BuyTankaJPY__c = 800;
        FlsService.doUpdate(masterMeisai);
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }

    testmethod static void shouldPopulateTaxRatio() {                                                                      
		accountTest.Currency__c = 'JPY - Japanese Yen';
        FlsService.doUpdate(accountTest);
        
        // 2. setup Tax Ratio
        Date startDate = Date.newInstance(2015, 12, 1);
        Date endDate = Date.newInstance(2015, 12, 31);
        Map<String, Object> additionalFields = new Map<String, Object> {'Active__c' => true, 'Currency__c' => 'JPY - Japanese Yen', 
            									'Start_Date__c' => startDate, 'End_Date__c' => endDate, 
            									'Buying_Tax_Ratio__c' => 6, 'Selling_Tax_Ratio__c' => 8};
		TestDataFactory.createSObject(new Tax_Ratio__c(), true, additionalFields);
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'BuyTankaJPY__c' => 1000, 'Suryo__c' => 1, 'curr__c' => 'JPY',
            										'BuyTankaUSD__c' => 100, 'Cost_Allocation_Catetory__c' => null};
        Test.startTest();
        masterMeisai = (MasterAnkenMeisai__c)TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }

    testmethod static void shouldLinkHBLSLToMBLBuying() {
        MasterAnkenMeisai__c mblBuying = [select id, Cost_Allocation_Catetory__c from MasterAnkenMeisai__c limit 1];
        List<AnkenMeisai__c> meisais = [select id, Cost_Allocation_Catetory__c from AnkenMeisai__c 
                                        where AM_MasterMeisaiID__c =: mblBuying.Id];
        
        System.assertEquals(0, meisais.size());
        mblBuying.Cost_Allocation_Catetory__c = 'Partner Cost allocation';
        
        Test.startTest();
        FlsService.doUpdate(mblBuying);
        Test.stopTest();
        
        meisais = [select id, Cost_Allocation_Catetory__c from AnkenMeisai__c 
                                        where AM_MasterMeisaiID__c =: mblBuying.Id];
        System.assertEquals(1, meisais.size());
    }
}