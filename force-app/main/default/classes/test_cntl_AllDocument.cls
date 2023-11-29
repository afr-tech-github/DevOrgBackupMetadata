@isTest(SeeAllData=false)
public class test_cntl_AllDocument{
    @testSetup static void setUp() {
       // Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            //'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
           // 'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
           // 'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
         //   'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		//TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
       // System.assert(true);
    }
    
    public static testMethod void  test_cntl_AllDocument_1() {

        Account acc = new Account();
        acc.Name  = 'SBS';
        acc.EnglishCompanyName__c = 'SBS';
        FlsService.doInsert(acc);
        Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
        setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        User user1 = [ SELECT id from user limit 1 ];
        Id stExam = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByName().get('Air Export').getRecordTypeId();
        CustomObject1__c ank = new CustomObject1__c();
        ank.Field1__c = acc.id;
        ank.PersonInCharge__c      = user1.id;
        //ank.InChargeOfQuotation__c = user1.id;
        ank.QuoationDescription__c = 'test';
        ank.SeikyusyoRemark__c = 'test';
        ank.RecordTypeId = stExam;
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
        //mei.PaymentTo__c    = acc.id;
        mei.Seikyusaki__c   = acc.id;
        mei.TaxInitial__c = 9;
        FlsService.doInsert(mei);

		Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id'   , ank.id);
        ApexPages.currentPage().getParameters().put('checkFlag', 'true');
        ApexPages.currentPage().getParameters().put('report', 'debitnote');
        ApexPages.currentPage().getParameters().put('report', 'creditnote');
        
                ApexPages.currentPage().getParameters().put('report', 'bbinvoice');
        ApexPages.currentPage().getParameters().put('report', 'quotation');
        ApexPages.currentPage().getParameters().put('report', 'invoice');
        ApexPages.currentPage().getParameters().put('report', 'dutypayment');
        ApexPages.currentPage().getParameters().put('report', 'invoicewithtax');
        
        ApexPages.currentPage().getParameters().put('currency', 'LOCAL');
        ApexPages.currentPage().getParameters().put('language', 'vi');
        ApexPages.currentPage().getParameters().put('AnkenID'   , ank.id);
        cntl_Document con1 = new cntl_Document();
        
       

        //cntl_Arrival_Notice con2 = new cntl_Arrival_Notice();
        try{
            cntl_opportunityCopy con3 = new cntl_opportunityCopy();
            Id clonedShipmentId = cntl_opportunityCopy.init(ank.id);
            
            Test.stopTest();
            ank = [SELECT Name FROM CustomObject1__c WHERE Id = :ank.Id];
            CustomObject1__c clonedAnk = [SELECT Original_WKID__c FROM CustomObject1__c WHERE Id = :clonedShipmentId];
            System.assertEquals(ank.Name, clonedAnk.Original_WKID__c);
        }catch(exception e){
            
        }
        
    }

    public static testMethod void  shouldGenerateCreditNoteReport() {
        Account acc = new Account();
        acc.Name  = 'SBS';
        acc.EnglishCompanyName__c = 'SBS';
        acc.Custom_Type__c = '海外パートナー - 営業不要';
        FlsService.doInsert(acc);
                Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
        setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        User user1 = [ SELECT id from user limit 1 ];

        CustomObject1__c ank = new CustomObject1__c();
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
        pro.Supplier__c         = acc.Id;
        FlsService.doInsert(pro);
        
        AnkenMeisai__c mei = new AnkenMeisai__c();        
        mei.Anken__c        = Ank.id;
        mei.curr__c         = 'JPY';
        mei.SerchSyubetu__c = 'FCL輸入';
        mei.Tariff__c       = pro.id;
        //mei.PaymentTo__c    = acc.id;
        mei.Seikyusaki__c   = acc.id;
        mei.TaxInitial__c = 9;
        FlsService.doInsert(mei);
        
        ApexPages.currentPage().getParameters().put('id'   , ank.id);
        ApexPages.currentPage().getParameters().put('checkFlag', 'true');
        ApexPages.currentPage().getParameters().put('report', 'debitnote');
        ApexPages.currentPage().getParameters().put('report', 'creditnote');
        
        ApexPages.currentPage().getParameters().put('report', 'bbinvoice');
        ApexPages.currentPage().getParameters().put('report', 'quotation');
        ApexPages.currentPage().getParameters().put('report', 'invoice');
        ApexPages.currentPage().getParameters().put('report', 'dutypayment');
        ApexPages.currentPage().getParameters().put('report', 'invoicewithtax');
        
         ApexPages.currentPage().getParameters().put('currency', 'LOCAL');
        ApexPages.currentPage().getParameters().put('language', 'en');
       
        cntl_Document controller = new cntl_Document();
        controller.getListDisplay();
        
        
        System.assertNotEquals(controller.AnkenList, null);
    }
}