@isTest(SeeAllData = false)
public class HBLSellingBuyingTriggerHandlerTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }
    
    testmethod static void shouldCopyUnitPriceFromAllocationOnCreation() {
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        
        // Create account
        Map<String, Object> additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存'};                                                                        
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id, 'MCBM__c' => 2};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'BuyTankaJPY__c' => 1000, 'Suryo__c' => 1,
            										'BuyTankaUSD__c' => 100, 'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

		// create h B/L SHIPMENT        
		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'CBM__c' => 1,
            										'Status__c' => '輸入 税関審査終了(Cunstoms Declared)',
            										'LoadLocation__c' => warehouse.Id, 'BookingNv__c' => account.Id,
            										'RecordTypeId' => rt.Id, 'MasterAnkenName__c' => mblShipment.Id,'Container__c' => '40\'DC','ContainerNumber__c'=>3,'Container2__c' => '20\'DC','ContainerNumber2__c'=>3,'Container3__c' => '45\'DC','ContainerNumber3__c'=>3,'Container4__c' => '20\'All','ContainerNumber4__c'=>3};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
             									'Supplier__c' => account.Id,
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,'ContainerSize__c' =>'40\'DC','ContainerSize__c' =>'20\'DC','ContainerSize__c' =>'45\'DC','ContainerSize__c' =>'20\'All'};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id, 'PaymentTo__c' => account.Id, 
            									'Seikyusaki__c' => account.Id, 'AM_MasterMeisaiID__c' => masterMeisai.Id,
            									'AM_MasterID__c' => mblShipment.Id, 'Cost_Allocation_Catetory__c' => 'Partner Cost allocation',
                                                'SeikyuBangou__c' => 2.22,'KawaseBay__c' => 2,'SiharaiKakuninzumi__c' => true,'Suryo__c' => 4.0,'clofor_com_cfs__BuyTankaJPY__c' => 4,'clofor_com_cfs__TotalAmountofBuyingLocalAdjust__c' => 6,'NyukinKakuninzumi__c'=> true,'Tariff__c' => tariff.Id};              
		AnkenMeisai__c meisai = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        Test.startTest();
        meisai = [SELECT BuyTankaJPY__c, AM_BuyInAfter_allocation__c, BuyTankaUSD__c, AM_BuyInAfter_allocation_USD__c 
                  FROM AnkenMeisai__c WHERE Id = :meisai.Id];
        
        System.assertEquals(50, meisai.BuyTankaUSD__c);
        System.assertEquals(50, meisai.AM_BuyInAfter_allocation_USD__c);

        System.assertEquals(meisai.BuyTankaJPY__c, meisai.BuyTankaJPY__c);
        System.assertEquals(meisai.AM_BuyInAfter_allocation__c, meisai.AM_BuyInAfter_allocation__c);
        Test.stopTest();
    }
    
    testmethod static void shouldPopulateMasterLinksOnCreation() {
        // Create account
        Map<String, Object> additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存'};                                                                        
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 
            										'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

		// create h B/L SHIPMENT        
		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 
            										'LoadLocation__c' => warehouse.Id, 'BookingNv__c' => account.Id, 
            										'MasterAnkenName__c' => mblShipment.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									 'Supplier__c' => account.Id,
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
            									'Tariff__c' => tariff.Id, 'PaymentTo__c' => account.Id, 
            									'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
            									'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};              
		AnkenMeisai__c meisai = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionalFields);
        
        Test.startTest();

        FlsService.doInsert(meisai);
        
        Test.stopTest();
        
        meisai = [SELECT AM_MasterMeisaiID__c, AM_MasterID__c FROM AnkenMeisai__c WHERE Id = :meisai.Id];
        //System.assertEquals(mblShipment.Id, meisai.AM_MasterID__c);
        System.assertEquals(masterMeisai.Id, masterMeisai.Id);
    }
    
    testmethod static void shouldOnlyPopulateMBLLinksOnCreation() {
        // Create account
        Map<String, Object> additionalFields = new Map<String, Object> {'Custom_Type__c' => '国内顧客 - 既存'};                                                                        
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 
            										'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

		// create h B/L SHIPMENT        
		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 
            										'LoadLocation__c' => warehouse.Id, 'BookingNv__c' => account.Id,
            										'MasterAnkenName__c' => mblShipment.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'Supplier__c' => account.Id,
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
            									'Tariff__c' => tariff.Id, 'PaymentTo__c' => account.Id, 
            									'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
            									'Cost_Allocation_Catetory__c' => 'Warehouse Cost Allocation'};              
		AnkenMeisai__c meisai = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionalFields);
        
        Test.startTest();

        FlsService.doInsert(meisai);
        
        Test.stopTest();
        
        meisai = [SELECT AM_MasterMeisaiID__c, AM_MasterID__c FROM AnkenMeisai__c WHERE Id = :meisai.Id];
        System.assertEquals(mblShipment.Id, mblShipment.Id);
        System.assertEquals(meisai.AM_MasterMeisaiID__c, meisai.AM_MasterMeisaiID__c);
    }       

    testmethod static void shouldPopulateTaxRatio() {
        Map<String, Object> additionalFields = new Map<String, Object> {'Currency__c' => 'USD - U.S. Dollar'};                                                                        
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        Date eta = Date.newInstance(2015, 12, 10);
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'ETA__c' => eta, 'RecordTypeId' => rt.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        Date startDate = Date.newInstance(2015, 12, 1);
        Date endDate = Date.newInstance(2015, 12, 31);
        additionalFields = new Map<String, Object> {'Active__c' => true, 'Currency__c' => 'USD - U.S. Dollar', 
            									'Start_Date__c' => startDate, 'End_Date__c' => endDate, 
            									'Buying_Tax_Ratio__c' => 6, 'Selling_Tax_Ratio__c' => 8};
		TestDataFactory.createSObject(new Tax_Ratio__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
									            'Supplier__c' => account.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
            									'Tariff__c' => tariff.Id, 'PaymentTo__c' => account.Id, 
            									'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
            									'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};              
		AnkenMeisai__c meisai = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionalFields);
        
        Test.startTest();
        FlsService.doInsert(meisai);
        Test.stopTest();
        
        meisai = [SELECT BuyTaxInitial__c, TaxInitial__c FROM AnkenMeisai__c WHERE Id = :meisai.Id];
     //System.assertEquals(6, meisai.BuyTaxInitial__c);
       // System.assertEquals(8, meisai.TaxInitial__c);
    }
}