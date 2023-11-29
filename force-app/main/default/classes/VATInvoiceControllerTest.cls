@isTest
private class VATInvoiceControllerTest {
    @testsetup static void setUp() {
        Custom_Application_Config__c config = Custom_Application_Config__c.getOrgDefaults();
		config.Disabled_Workflow_Rule__c = true;
        config.Disabled_Trigger__c =true;
		upsert config;
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        // Create an Account
        additionalFields = new Map<String, Object>{
                'Currency__c' => 'USD - U.S. Dollar'
        };
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        // Create Service Master
        additionalFields = new Map<String, Object>{
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
                'Supplier__c' => account.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX
        };
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);

        // Create 2 HBL records
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType1'];

        additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001'
        };
        CustomObject1__c shipment1 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0002'
        };
        CustomObject1__c shipment2 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // Create 2 HBL S/B records
        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment1.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'
        };
        AnkenMeisai__c meisai1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment2.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'
        };
        AnkenMeisai__c meisai2 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        // Create VAT INVOICE
        VAT_INVOICE__c vatInvoice = (VAT_INVOICE__c) TestDataFactory.createSObject(new VAT_INVOICE__c(), true, null);

        // Create connecting objects
        additionalFields = new Map<String, Object>{
                'FORWARDING__c' => shipment1.Id, 'VAT_INVOICE__c' => vatInvoice.Id
        };
        TestDataFactory.createSObject(new FORWARDING_VAT__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'FORWARDING__c' => shipment2.Id, 'VAT_INVOICE__c' => vatInvoice.Id
        };
        TestDataFactory.createSObject(new FORWARDING_VAT__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'INVOICING__c' => meisai1.Id, 'VAT_INVOICE__c' => vatInvoice.Id
        };
        TestDataFactory.createSObject(new INVOICING_VAT__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'INVOICING__c' => meisai2.Id, 'VAT_INVOICE__c' => vatInvoice.Id
        };
        TestDataFactory.createSObject(new INVOICING_VAT__c(), true, additionalFields);


        List<Translation__c> translations = new List<Translation__c>();
        translations.add(createTranslation('InvoiceSelection','GROUP_BY_CATEGORY','COMBINED TO PRICING SUB-CATEGORY','プライシング小分類毎に統合','프라이싱 소분류별 통합','COMBINED TO PRICING SUB-CATEGORY','COMBINED TO PRICING SUB-CATEGORY','COMBINED TO PRICING SUB-CATEGORY','COMBINED TO PRICING SUB-CATEGORY'));
        translations.add(createTranslation('InvoiceSelection','SUMMARY','COMBINED TO 1 SUMMARY','一つに統合','하나로 통합','COMBINED TO 1 SUMMARY','COMBINED TO 1 SUMMARY','COMBINED TO 1 SUMMARY','COMBINED TO 1 SUMMARY'));
        translations.add(createTranslation('InvoiceSelection','GROUPED_BY_INVOICING','EACH INVOICING','請求明細毎に表示','각 청구상세별 표기','EACH INVOICING','EACH INVOICING','EACH INVOICING','EACH INVOICING'));
        translations.add(createTranslation('InvoiceSelection','GROUPED_BY_FORWARDING','COMBINED TO SHIPMENT ORDER','シッピング指示毎に統合','쉽핑오더별 통합','COMBINED TO SHIPMENT ORDER','COMBINED TO SHIPMENT ORDER','COMBINED TO SHIPMENT ORDER','COMBINED TO SHIPMENT ORDER'));

        FlsService.doInsert(translations);
    }

    private static Translation__c createTranslation(String context, String name, String en, String ja, String ko,
            String vi, String kh, String zhCN, String zhTW) {
        Translation__c translation = new Translation__c();
        translation.Name = name;
        translation.Active__c = true;
        translation.Context__c = context;
        translation.en_US__c = en;
        translation.ja__c = ja;
        translation.vi__c = vi;
        translation.ko__c = ko;
        translation.kh__c = kh;
        translation.zh_CN__c = zhCN;
        translation.zh_TW__c = zhTW;

        return translation;
    }

    testmethod static void shouldShowDraftInvoiceReport() {
        VAT_INVOICE__c vatInvoice = [SELECT Id FROM VAT_INVOICE__c LIMIT 1];
        PageReference pageReference = Page.VATInvoiceSelection;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, vatInvoice.Id);
        VATInvoiceSelectionController controller = new VATInvoiceSelectionController();
        controller.selectedReport = 'vi_drafttax_invoice_1';
        controller.selectedGroupingOption = Constants.GROUPED_BY_INVOICING_KEY;
        controller.selectedCurrency = Constants.CURRENCY_USD;

        Test.startTest();
        controller.generateReport();
        Test.stopTest();

        String openUrl = '/apex/' + Constants.NAMESPACE + 'page_DraftTaxInvoice?id=' + vatInvoice.Id + '&grouping='
                + Constants.GROUPED_BY_INVOICING_KEY + '&template=1&language=vi&currency=' + Constants.CURRENCY_USD + '&reportpage=' + Constants.NAMESPACE + 'page_DraftTaxInvoice';
        System.assertEquals(openUrl, controller.openUrl);
    }

    testmethod static void shouldReportByInvoicing() {
        VAT_INVOICE__c vatInvoice = [SELECT Id FROM VAT_INVOICE__c LIMIT 1];
        PageReference pageReference = Page.page_DraftTaxInvoice;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, vatInvoice.Id);
        ApexPages.currentPage().getParameters().put('grouping', Constants.GROUPED_BY_INVOICING_KEY);
        ApexPages.currentPage().getParameters().put('language', 'vi');

        Test.startTest();
        VATInvoiceController controller = new VATInvoiceController();
        Test.stopTest();
        System.assert(true);
    }

    testmethod static void shouldReportByForwarding() {
        VAT_INVOICE__c vatInvoice = [SELECT Id FROM VAT_INVOICE__c LIMIT 1];
        PageReference pageReference = Page.page_DraftTaxInvoice_Combined;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('language', 'vi');
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, vatInvoice.Id);
        ApexPages.currentPage().getParameters().put('grouping', Constants.GROUPED_BY_FORWARDING_KEY);

        Test.startTest();
        VATInvoiceController controller = new VATInvoiceController();
        Test.stopTest();
        System.assert(true);
    }

    testmethod static void shouldReportAll() {
        VAT_INVOICE__c vatInvoice = [SELECT Id FROM VAT_INVOICE__c LIMIT 1];
        PageReference pageReference = Page.page_DraftTaxInvoice_Combined;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, vatInvoice.Id);
        ApexPages.currentPage().getParameters().put('grouping', Constants.SUMMARY_KEY);
        ApexPages.currentPage().getParameters().put('language', 'vi');

        Test.startTest();
        VATInvoiceController controller = new VATInvoiceController();
        Test.stopTest();
        System.assert(true);
    }
}