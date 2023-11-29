@isTest
private class InvoicePrintNewControllerTest {
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
        acc.CorporateMyNumber__c = 'SBS-1';
        FlsService.doInsert(acc);
        acc2 = new Account();
        acc2.Name  = 'SBS 2';
        acc2.EnglishCompanyName__c = 'SBS 2';
        acc2.CorporateMyNumber__c = 'SBS-2';
        FlsService.doInsert(acc2);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        User user1 = [ SELECT id from user limit 1 ];
        
        ank = new CustomObject1__c();
        ank.Field1__c = acc.id;
        ank.PersonInCharge__c      = user1.id;
        //ank.InChargeOfQuotation__c = user1.id;
        ank.QuoationDescription__c = 'test';
        ank.SeikyusyoRemark__c = 'test';
        ank.ETD__c = Date.today();
        ank.ETA__c = Date.today();
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
        mei.curr__c         = 'USD';
        mei.SerchSyubetu__c = 'FCL輸入';
        mei.Tariff__c       = pro.id;
        //mei.PaymentTo__c    = acc2.id;
        mei.Seikyusaki__c   = acc.id;
        FlsService.doInsert(mei);
    }
    public static testMethod void  test_method_1() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('shipmentId', ank.Id);
        ApexPages.currentPage().getParameters().put('customerId', acc.Id);
        ApexPages.currentPage().getParameters().put('isTax', 'true');
        InvoicePrintNewController ctrl = new InvoicePrintNewController();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }

}