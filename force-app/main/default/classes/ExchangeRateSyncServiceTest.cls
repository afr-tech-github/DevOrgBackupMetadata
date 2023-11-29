@isTest
public class ExchangeRateSyncServiceTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }
    
    testmethod static void shouldSyncStandardExRateToHBLShipmentAndRelated() {
        Date printDate = Date.newInstance(2015, 09, 09);
		RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
		Map<String, Object> additionalFields = new Map<String, Object> {
            							'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING,
                                        'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
                                        'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong',
                                        'CorporateMyNumber__c' => 'AcountTest1'};
		Account domesticCustomer = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.OVERSEA_PARTNER_EXISTING,
            							'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
                                        'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong',
                                        'CorporateMyNumber__c' => 'AcountTest2'};
		Account overseaPartner = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
		additionalFields = new Map<String, Object> {'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => rt.Id, 
            									'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
            									'PrinteDate_ED__c' => printDate};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 
            									'Subcategory__c' => '基本料金', 'Supplier__c' => domesticCustomer.Id,
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);                                                                 
        
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 
            									'SerchSyubetu__c' => 'FCL輸入', 'Tariff__c' => tariff.Id, 
            									'Seikyusaki__c' => domesticCustomer.Id};
		AnkenMeisai__c meisai = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object> {'Mgmt_Exrate_Start_Date__c' => startDate, 'Mgmt_Exrate_End_Date__c' => endDate,
            							'Mgmt_Exrate_FowardingtoDomesticCustomer__c' => 100, 'Mgmt_Exrate_SellingtoPartner__c' => 130,
            							'Mgmt_Exrate_BuyingfromPartner__c' => 200, 'Mgmt_Exrate_CCtoDomesticCustomer__c' => 120,
            							'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c exchangeRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        Test.startTest();

        ExchangeRateSynchronizationService.syncHBLShipmentAndSellingBuyings(shipment.Id);
        
        Test.stopTest();        

        shipment = [SELECT Id, ExchangeRate__c, (SELECT KawaseSel__c, KawaseBay__c FROM Anken__r)
                    FROM CustomObject1__c WHERE Id = :shipment.Id];
        
        System.assertEquals(100.00, shipment.ExchangeRate__c);
        
        meisai = shipment.Anken__r.get(0);
        //System.assertEquals(100.00, meisai.KawaseSel__c);
        //System.assertEquals(200.00, meisai.KawaseBay__c);
    }

    testmethod static void shouldSyncNonStandardExRateToHBLShipmentAndRelated() {
        Date printDate = Date.newInstance(2015, 09, 09);
		RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];
		Map<String, Object> additionalFields = new Map<String, Object> {
            'Business_Relationship__c' => Constants.CUSTOMER_RELATIONSHIP,
            'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING,
            'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
            'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong',
            'RecordTypeId' => Constants.RecordTypeId_Account_Customer,
            'CorporateMyNumber__c' => 'AcountTest3'
        };
		Account domesticCustomer = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {
            'Custom_Type__c' => PicklistReference.OVERSEA_PARTNER_EXISTING,
            'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
            'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong',
            'Business_Relationship__c' => Constants.PARTNER_RELATIONSHIP ,
            'RecordTypeId' => Constants.RecordTypeId_Account_Partner,
            'CorporateMyNumber__c' => 'AcountTest4'
        };
		Account overseaPartner = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
		additionalFields = new Map<String, Object> {'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => rt.Id, 
            									'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
            									'PrinteDate_ED__c' => printDate};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 
            									'Subcategory__c' => '基本料金', 'Supplier__c' => domesticCustomer.Id,
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);                                                                 
        
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 
            									'SerchSyubetu__c' => 'FCL輸入', 'Tariff__c' => tariff.Id, 
            									'PaymentTo__c' => overseaPartner.Id, 'Seikyusaki__c' => domesticCustomer.Id};
		AnkenMeisai__c meisai = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
        
        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object> {'Mgmt_Exrate_Start_Date__c' => startDate, 'Mgmt_Exrate_End_Date__c' => endDate,
            							'Mgmt_Exrate_FowardingtoDomesticCustomer__c' => 100, 'Mgmt_Exrate_SellingtoPartner__c' => 130,
            							'Mgmt_Exrate_BuyingfromPartner__c' => 200, 'Mgmt_Exrate_CCtoDomesticCustomer__c' => 120,
							            'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c exchangeRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Exchange_Rate__c' => exchangeRate.Id, 'CUSTOMER__c' => domesticCustomer.Id,
            								'Selling_Ex_Rate_To_Customer__c' => 310, 'Selling_Ex_Rate_To_Partner__c' => 320};
        Non_Standard_Exchange_Rate__c nonExRate1 = (Non_Standard_Exchange_Rate__c) TestDataFactory.createSObject(
            													new Non_Standard_Exchange_Rate__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Exchange_Rate__c' => exchangeRate.Id,
            								'PARTNER__c' => overseaPartner.Id, 'Buying_Ex_Rate_From_Partner__c' => 300};
        Non_Standard_Exchange_Rate__c nonExRate2 = (Non_Standard_Exchange_Rate__c) TestDataFactory.createSObject(
            													new Non_Standard_Exchange_Rate__c(), true, additionalFields);
        
        Test.startTest();
        ExchangeRateSynchronizationService.syncHBLShipmentAndSellingBuyings(shipment.Id);
        
        shipment = [SELECT Id, ExchangeRate__c, Custom__c, SalesAccountedDate__c, Field1__c,
                                        (SELECT Id, Seikyusaki__c, KawaseSel__c, PaymentTo__c, KawaseBay__c, 
                                                Seikyusaki__r.Custom_Type__c, PaymentTo__r.Custom_Type__c 
                                         FROM Anken__r)
                    FROM CustomObject1__c WHERE Id = :shipment.Id];
        
        System.assertEquals(310.00, shipment.ExchangeRate__c);
        
        meisai = shipment.Anken__r.get(0);
        //System.assertEquals(310.00, meisai.KawaseSel__c);
        // System.assertEquals(300.00, meisai.KawaseBay__c);
        Test.stopTest();        
    }

    testmethod static void shouldSyncStandardExRateToImportMBLBuying() {
        Map<String, Object> additionalFields = new Map<String, Object> {
            							'Custom_Type__c' => PicklistReference.OVERSEA_PARTNER_EXISTING,
                                        'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
                                        'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong',
                                        'CorporateMyNumber__c' => 'AcountTest5'};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        Date metd = Date.newInstance(2015, 08, 01);
        Date meta = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
									            'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id,
            										'METD__c' => metd, 'META__c' => meta, 'Master_Record_Type__c' => 'Ocean Import'};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'MTariff__c' => tariff.Id, 'SerchSyubetu__c' => 'FCL輸入'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object> {'Mgmt_Exrate_Start_Date__c' => startDate, 'Mgmt_Exrate_End_Date__c' => endDate,
            										'Mgmt_Exrate_BuyingfromPartner__c' => 100,
										            'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c exchangeRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        Test.startTest();
        ExchangeRateSynchronizationService.syncMBLBuyings(mblShipment.Id);
        masterMeisai = [SELECT KawaseBay__c FROM MasterAnkenMeisai__c WHERE Id = :masterMeisai.Id];
        System.assertEquals(100.00, masterMeisai.KawaseBay__c);
        Test.stopTest();
    }
    
    testmethod static void shouldSyncStandardExRateToExportMBLBuying() {
        Map<String, Object> additionalFields = new Map<String, Object> {
            							'Custom_Type__c' => PicklistReference.OVERSEA_PARTNER_EXISTING,
                                        'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
                                        'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong',
                                        'CorporateMyNumber__c' => 'AcountTest6'};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        // create warehouse
        Date metd = Date.newInstance(2015, 09, 01);
        Date meta = Date.newInstance(2015, 10, 30);
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
									            'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);
        
        // create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => account.Id,
            										'METD__c' => metd, 'META__c' => meta, 'Master_Record_Type__c' => 'Ocean Export'};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'MTariff__c' => tariff.Id, 'SerchSyubetu__c' => 'FCL輸入'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object> {'Mgmt_Exrate_Start_Date__c' => startDate, 'Mgmt_Exrate_End_Date__c' => endDate,
            										'Mgmt_Exrate_BuyingfromPartner__c' => 100,
										            'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'};
        MgmtMaster__c exchangeRate = (MgmtMaster__c) TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);
        
        Test.startTest();
        ExchangeRateSynchronizationService.syncMBLBuyings(mblShipment.Id);
        masterMeisai = [SELECT KawaseBay__c FROM MasterAnkenMeisai__c WHERE Id = :masterMeisai.Id];
        System.assertEquals(100.00, masterMeisai.KawaseBay__c);
        Test.stopTest();
    }
}