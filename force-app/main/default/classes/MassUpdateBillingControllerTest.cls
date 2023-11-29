@isTest
public class MassUpdateBillingControllerTest {
    // @testSetup
    // static void setup() {
    //     Account acc = new Account(Name = 'test acc');
    //     insert acc;
    //     clofor_com_cfs__CustomObject1__c shipment = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__Field1__c = acc.Id);
    //     insert shipment;
    //     clofor_com_cfs__AnkenMeisai__c billing = new clofor_com_cfs__AnkenMeisai__c(clofor_com_cfs__Anken__c = shipment.Id);
    //     insert billing;
	// }
	private static Account acc{get;set;}
    private static Account acc2{get;set;}
    private static CustomObject1__c ank{get;set;}
    static{
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
        acc = new Account();
        acc.Name  = 'SBS';
        acc.EnglishCompanyName__c = 'SBS';
        acc.BillingStreet = 'a';
        acc.BillingCity = 'a';
        acc.BillingState = 'a';
        acc.BillingPostalCode = 'a';
        acc.BillingCountry = 'a';
        acc.CorporateMyNumber__c = 'SBS';
        FlsService.doInsert(acc);
        acc2 = new Account();
        acc2.Name  = 'SBS 2';
        acc2.EnglishCompanyName__c = 'SBS 2';
        acc2.CorporateMyNumber__c = 'SBS 2';
        FlsService.doInsert(acc2);
                Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
         setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        User user1 = [ SELECT id from user limit 1 ];
        
        ank = new CustomObject1__c();
        ank.Field1__c = acc.id;
        ank.PersonInCharge__c      = user1.id;
        //ank.InChargeOfQuotation__c = user1.id;
        ank.QuoationDescription__c = 'test';
        ank.SeikyusyoRemark__c = 'test';
        FlsService.doInsert(ank);
        
        TariffMaster__c pro = new TariffMaster__c();
        pro.Name = 'LCL';
        pro.ProductSearch__c    = 'FCL輸入';      //大分類
        pro.Subcategory__c      = '基本料金';     //小分類
        pro.EngProductSearch__c = 'FCL Import';   //ENG大分類
        pro.EngSubcategory__c   = 'Basic charge'; //ENG子分類
        pro.ProductFlag__c      = true;
        pro.Supplier__c = acc.Id;
        FlsService.doInsert(pro);
        
        AnkenMeisai__c mei = new AnkenMeisai__c();        
        mei.Anken__c        = Ank.id;
        mei.curr__c         = 'JPY';
        mei.SerchSyubetu__c = 'FCL輸入';
        mei.Tariff__c       = pro.id;
        //mei.PaymentTo__c    = acc2.id;
        mei.Seikyusaki__c   = acc.id;
        FlsService.doInsert(mei);
        

    }

	@isTest
    static void testReturnFirstRecordId(){
        String recordTypeId = MassUpdateBillingController.getRecordTypeId();
        System.assertNotEquals('', recordTypeId);
    }

	@isTest
    static void testGetDescribeSobjectResult(){
        String objResult = MassUpdateBillingController.getDescribeSobjectResult();
        System.assertNotEquals('', objResult);
    }

    @isTest
    static void testGetAllSellingBillings(){
        // clofor_com_cfs__CustomObject1__c shipment = [SELECT Id FROM clofor_com_cfs__CustomObject1__c LIMIT 1];
        clofor_com_cfs__AnkenMeisai__c billing = [SELECT Id, clofor_com_cfs__Anken__c FROM clofor_com_cfs__AnkenMeisai__c LIMIT 1];
        List<clofor_com_cfs__AnkenMeisai__c> allBillings = MassUpdateBillingController.getAllBillings(billing.clofor_com_cfs__Anken__c, true);
        System.assertNotEquals(0, allBillings.size());
    }

    @isTest
    static void testGetAllBuyingBillings(){
        // clofor_com_cfs__CustomObject1__c shipment = [SELECT Id FROM clofor_com_cfs__CustomObject1__c LIMIT 1];
        clofor_com_cfs__AnkenMeisai__c billing = [SELECT Id, clofor_com_cfs__Anken__c FROM clofor_com_cfs__AnkenMeisai__c LIMIT 1];
        List<clofor_com_cfs__AnkenMeisai__c> allBillings = MassUpdateBillingController.getAllBillings(billing.clofor_com_cfs__Anken__c, false);
        System.assertNotEquals(0, allBillings.size());
    }

  /*  @isTest
    (SeeAllData = true)
    static void testUpdateBillingsWithSelling(){
        List<clofor_com_cfs__AnkenMeisai__c> allBillings = [SELECT Id FROM clofor_com_cfs__AnkenMeisai__c LIMIT 1];
        String jsonRecords = JSON.serialize(allBillings);
        String res = MassEditBillingController.updateBillings(jsonRecords, true);
        System.assertEquals(false, res.contains('The following exception has occurred:'));
    }*/

     @isTest
     static void testUpdateBillingsWithBuying(){
         List<clofor_com_cfs__AnkenMeisai__c> allBillings = [SELECT Id,Name,clofor_com_cfs__SeikyuBangou__c,clofor_com_cfs__Tariff__c,clofor_com_cfs__Seikyusaki__c,clofor_com_cfs__PaymentTo__c,
        clofor_com_cfs__Suryo__c,clofor_com_cfs__ChargeUnitInPrint__c,clofor_com_cfs__ChargeUnit__c,clofor_com_cfs__ContainerSize__c,clofor_com_cfs__PrintFlag__c,clofor_com_cfs__curr__c,clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c,
        clofor_com_cfs__SellTankaJPY__c,clofor_com_cfs__SellTankaUSD__c,clofor_com_cfs__UnitPriceofSelling3rdCurrency__c,clofor_com_cfs__TaxInitial__c,clofor_com_cfs__VATrateselling__c,
        clofor_com_cfs__ExchangeRateID__c,clofor_com_cfs__KawaseSel__c,clofor_com_cfs__FxrateSelling3rdCurrencyFCY__c,clofor_com_cfs__FxrateSelling3rdCurrencyLocal__c,clofor_com_cfs__CurrencyConversionSelling__c,clofor_com_cfs__CurrencyBuying__c,
        clofor_com_cfs__InsatuyouSyohinEng__c,clofor_com_cfs__BuyTankaJPY__c,clofor_com_cfs__BuyTankaUSD__c,clofor_com_cfs__UnitPriceofBuying3rdCurrency__c,clofor_com_cfs__BuyTaxInitial__c,clofor_com_cfs__VATratebuying__c,clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c,
        clofor_com_cfs__AmountBuyingIncTaxLocalInput__c,clofor_com_cfs__AmountBuyingIncTaxFCYInput__c,clofor_com_cfs__KawaseBay__c,clofor_com_cfs__FxrateBuying3rdCurrencyFCY__c,clofor_com_cfs__FxrateBuying3rdCurrencyLocal__c,clofor_com_cfs__CurrencyConversionBuying__c
        FROM clofor_com_cfs__AnkenMeisai__c];
         String jsonRecords = JSON.serialize(allBillings);
         String res = MassUpdateBillingController.updateBillings(jsonRecords, false, false, false, false, false, false, false, false, false, false);
         System.assertEquals(false, res.contains('The following exception has occurred:'));
    }
    
    @isTest
    static void testDeleteBilling(){
        // List<clofor_com_cfs__AnkenMeisai__c> allBillings = [SELECT Id FROM clofor_com_cfs__AnkenMeisai__c LIMIT 1];
        List<clofor_com_cfs__AnkenMeisai__c> allBillings = [SELECT Id FROM clofor_com_cfs__AnkenMeisai__c LIMIT 1];
        String jsonRecords = JSON.serialize(allBillings);
        Boolean res = MassUpdateBillingController.deleteBilling(allBillings.get(0).Id);
        System.assertEquals(true, res);
    }
}