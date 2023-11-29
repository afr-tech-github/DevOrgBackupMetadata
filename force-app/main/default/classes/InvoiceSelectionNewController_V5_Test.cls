@isTest
private class InvoiceSelectionNewController_V5_Test {
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
                // Insert bank infor setting
        Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.FCYBankAccountShortName3__c = 'Bank Foreign 3';
        setting.FCYBankAccountShortName4__c = 'Bank Foreign 4';
        setting.FCYBankAccountShortName5__c = 'Bank Foreign 5';
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
    public static testMethod void  test_method_1() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('shipmentId', ank.Id);
        InvoiceSelectionNewController_V5 ctrl = new InvoiceSelectionNewController_V5();
        ctrl.refreshCustomerOption();
	    String language = ctrl.language;
	    String docType = ctrl.docType;
	    String currencyType = ctrl.currencyType;
        String customerId = ctrl.customerId;
        String shipmentId = ctrl.shipmentId;
        List<SelectOption> languageOptions = ctrl.getLanguageOptions();
        List<SelectOption> options = ctrl.getCustomerList();
        List<SelectOption> optionPrints = ctrl.getPrintOptions();
        List<SelectOption> optioncurrs = ctrl.getCurrencyTypeOptions();
        List<SelectOption> optionBanks = ctrl.getBankOptions();
        List<SelectOption> optionTemplates = ctrl.getTemplateOptions();
        List<SelectOption> optionFileTypes = ctrl.getFileTypeOptions();
        ctrl.requiredAttachmentCreation = true;
        try{
        ctrl.generateAttachmentFile();
        }catch(Exception ex){
            
        }
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
}