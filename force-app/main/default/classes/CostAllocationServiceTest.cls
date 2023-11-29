@isTest
public class CostAllocationServiceTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }
    
    testmethod static void shouldBalanceBuyingAndSelling() {
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        
        // Create account
        Map<String, Object> additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存'};                                                                        
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id, 
            										'MCBM__c' => 1};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'BuyTankaJPY__c' => 1900, 
            										'BuyTankaUSD__c' => 19, 'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

        Map<String, Object> additionFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionFields);

		// create h B/L SHIPMENT        
		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'CBM__c' => 1,
            										'Status__c' => '輸入 税関審査終了(Cunstoms Declared)',
            										'LoadLocation__c' => warehouse.Id, 'BookingNv__c' => account.Id,
                                                    'RecordTypeId' => rt.Id, 'MasterAnkenName__c' => mblShipment.Id,
                                                    'clofor_com_cfs__POD__c' => objPort.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        RecordType hblSBRT = [Select Id from RecordType where DeveloperName = 'Consolidation_Cost_allocation'];
        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id,'RecordTypeId' => hblSBRT.Id,
            									'Seikyusaki__c' => account.Id, 'AM_MasterMeisaiID__c' => masterMeisai.Id,
            									'AM_MasterID__c' => mblShipment.Id, 'BuyTankaJPY__c' => 2000, 'BuyTankaUSD__c' => 20,
            									'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};              
		AnkenMeisai__c mei1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        Test.startTest();
        mei1 = [SELECT Cost_Allocation_Margin__c FROM AnkenMeisai__c WHERE Id = :mei1.Id];
        System.assertEquals(0, mei1.Cost_Allocation_Margin__c);
        
        CostAllocationService.balanceCostAllocation(mblShipment.Id);
        
        mei1 = [SELECT BuyInTaxAmountJPY__c, Cost_Allocation_Margin__c,  BuyTankaJPY__c FROM AnkenMeisai__c WHERE Id = :mei1.Id];
        System.assertEquals(0, mei1.Cost_Allocation_Margin__c);
        Test.stopTest();
    }
}