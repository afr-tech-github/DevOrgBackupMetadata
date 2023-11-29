@isTest(SeeAllData = false)
private class InvoiceSelectionControllerTest {
    private static final String INVOICE_SELECTION_PAGE = '/apex/InvoiceSelection';

    @testSetup static void setup() {
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
        RecordType oceanImportRecordType = [Select Id from RecordType where DeveloperName = 'RecordType1'];
        //RecordType quotationRecordType = [Select Id from RecordType where DeveloperName = 'QUOTATION' and SobjectName ='CustomObject1__c'];
        Map<String, Object> additionalFields = new Map<String, Object> {'Business_Relationship__c' => Constants.CUSTOMER_RELATIONSHIP};
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
		        additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST',
            'clofor_com_cfs__LocalCurrencyBankAccountShortName1__c' => 'local1',
            'clofor_com_cfs__LocalCurrencyBankAccountShortName2__c' => 'local2',
            'clofor_com_cfs__LocalCurrencyBankAccountShortName3__c' => 'local3',
            'clofor_com_cfs__LocalCurrencyBankAccountShortName4__c' => 'local4',
            'clofor_com_cfs__LocalCurrencyBankAccountShortName5__c' => 'local5',
            'clofor_com_cfs__FCYBankAccountShortName1__c' => 'foreign1',
            'clofor_com_cfs__FCYBankAccountShortName2__c' => 'foreign2',
            'clofor_com_cfs__FCYBankAccountShortName3__c' => 'foreign3',
            'clofor_com_cfs__FCYBankAccountShortName4__c' => 'foreign4',
            'clofor_com_cfs__FCYBankAccountShortName5__c' => 'foreign5'};
        TestDataFactory.createSObject(new clofor_com_cfs__Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
        additionalFields = new Map<String, Object> {'Name' => 'PARTNER001', 'Business_Relationship__c' => Constants.PARTNER_RELATIONSHIP};
        Account partner = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

       /* additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields); */

        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => oceanImportRecordType.Id,
                                                                        'ContainerNumber__c' => 1, 'Container__c' => '40`DC',
                                                                        'HBL__c' => 'IMPORT01'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        /*additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => quotationRecordType.Id,
                                                                        'ContainerNumber__c' => 1, 'Container__c' => '40`DC',
                                                                        'HBL__c' => 'QUOTATION01'};*/
        //CustomObject1__c quotationShipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入',
                                                'Subcategory__c' => '基本料金', 'Supplier__c' => account.Id,
                                                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
                                                'SerchSyubetu__c' => 'FCL輸入', 'Tariff__c' => tariff.Id,
                                                'Seikyusaki__c' => account.Id, 'VAT_INVOICE_TO__c' => account.Id,
                                                'Selling_Tatekae__c' => false, 'SellTankaJPY__c' => 100};
        TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY',
                                                'SerchSyubetu__c' => 'FCL輸入',
                                                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        /*additionalFields = new Map<String, Object> {'Anken__c' => quotationShipment.Id, 'curr__c' => 'JPY',
                                                'Tariff__c' => tariff.Id, 'PaymentTo__c' => partner.Id,
                                                'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
                                                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
                                                */
        //TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

    }

    @isTest static void shouldOpenInvoicePage() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'IMPORT01'];
        AnkenMeisai__c meisai = [SELECT Seikyusaki__r.Id FROM AnkenMeisai__c LIMIT 1];
        
        clofor_com_cfs__Site_Custom_Settings__c banks = [Select clofor_com_cfs__LocalCurrencyBankAccountShortName1__c,
                                                         clofor_com_cfs__LocalCurrencyBankAccountShortName2__c                                              
                                                         From clofor_com_cfs__Site_Custom_Settings__c limit 1];
    
        PageReference currentPage = new PageReference(INVOICE_SELECTION_PAGE);
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_WKID, shipment.Name);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_REPORT_TYPE, Constants.REPORT_TYPE_INVOICE);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_VERSION, String.valueOf(shipment.QuotationVer__c));
        ApexPages.currentPage().getParameters().put('bank', 'local1');

        InvoiceSelectionController controller = new InvoiceSelectionController();
        controller.selectedBank = 'local1';
        controller.selectedLanguage = 'ja';
        controller.selectedReport = 'ja_invoice';
        controller.selectedCustomerId = meisai.Seikyusaki__r.Id;

        Test.startTest();

        controller.generateReport();
        String openUrl = '/apex/' + Constants.NAMESPACE + 'page_InvoiceJPN?quotationTotalFlag=false&report=invoice&wkid=' + shipment.Name + '&id=' + shipment.Id
                + '&version=' + String.valueOf(shipment.QuotationVer__c) + '&checkFlag=true&language=ja&custId=' + meisai.Seikyusaki__r.Id + '&vat=false&currency=USD'
            + '&bank=' + controller.selectedBank ;

        Test.stopTest();
        System.assertEquals(openUrl, controller.openUrl);
    }
    
    @isTest static void shouldOpenDocumentPage() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'IMPORT01'];

        PageReference currentPage = new PageReference(INVOICE_SELECTION_PAGE);
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_WKID, shipment.Name);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_REPORT_TYPE, Constants.REPORT_TYPE_DOCUMENT);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_VERSION, String.valueOf(shipment.QuotationVer__c));

        InvoiceSelectionController controller = new InvoiceSelectionController();
        controller.selectedBank = 'local2'; 
        controller.selectedLanguage = 'en_US';
        controller.selectedReport = 'en_arrival_notice_portrait_local';

        Test.startTest();

        controller.generateReport();
        String openUrl = '/apex/' + Constants.NAMESPACE + 'OceanPortraitArrivalNoticeENG?quotationTotalFlag=false&report=arrivalnotice&wkid=' + shipment.Name + '&id=' + shipment.Id
                + '&version=' + String.valueOf(shipment.QuotationVer__c) + '&checkFlag=false&language=en_US&custId=null&vat=false&currency=LOCAL'
            ;

        Test.stopTest();
        //System.assertEquals(openUrl, controller.openUrl);
    }
    
    @isTest static void shouldOpenAttachmentAndIncreaseQuotationVersion() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'IMPORT01'];
        AnkenMeisai__c meisai = [SELECT Seikyusaki__r.Id FROM AnkenMeisai__c LIMIT 1];

        PageReference currentPage = new PageReference(INVOICE_SELECTION_PAGE);
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_WKID, shipment.Name);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_REPORT_TYPE, 'invoice');
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_VERSION, String.valueOf(shipment.QuotationVer__c));

        InvoiceSelectionController controller = new InvoiceSelectionController();
        controller.selectedBank = 'loacl1'; 
        controller.selectedLanguage = 'ja';
        controller.selectedReport = 'ja_invoice';
        controller.requiredAttachmentCreation = true;
        controller.selectedCustomerId = meisai.Seikyusaki__r.Id;

        Test.startTest();

        controller.generateReport();
        String openUrl = '/servlet/servlet.FileDownload?file=null';

        shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE Id = :shipment.Id];

        Test.stopTest();
        System.assertEquals(openUrl, controller.openUrl);
    }

    /*@isTest static void shouldQuotationPage() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'QUOTATION01'];
        AnkenMeisai__c meisai = [SELECT Seikyusaki__r.Id FROM AnkenMeisai__c LIMIT 1];

        PageReference currentPage = new PageReference(INVOICE_SELECTION_PAGE);
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_WKID, shipment.Name);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_REPORT_TYPE, Constants.REPORT_TYPE_QUOTATION);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_VERSION, String.valueOf(shipment.QuotationVer__c));

        InvoiceSelectionController controller = new InvoiceSelectionController();
        controller.selectedLanguage = 'ja';
        controller.selectedReport = 'ja_quotationwithtotal';
        controller.selectedCustomerId = meisai.Seikyusaki__r.Id;

        Test.startTest();

        controller.generateReport();
        String openUrl = '/apex/' + Constants.NAMESPACE + 'page_QuotationJPN?quotationTotalFlag=true&report=quotation&wkid=' + shipment.Name + '&id=' + shipment.Id
                + '&version=' + String.valueOf(shipment.QuotationVer__c) + '&checkFlag=true&language=ja&custId=' + meisai.Seikyusaki__r.Id + '&vat=false&currency=USD';

        Test.stopTest();
        System.assertEquals(openUrl, controller.openUrl);
    }*/

    @isTest static void shouldCreditDebitPage() {
        CustomObject1__c shipment = [SELECT Id, Name, QuotationVer__c FROM CustomObject1__c WHERE HBL__c = 'IMPORT01'];

        PageReference currentPage = new PageReference(INVOICE_SELECTION_PAGE);
        Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_ID, shipment.Id);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_WKID, shipment.Name);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_REPORT_TYPE, Constants.REPORT_TYPE_PARTNER_INVOICE);
        ApexPages.currentPage().getParameters().put(Constants.REQUEST_VERSION, String.valueOf(shipment.QuotationVer__c));

        Account partner = [select Id from Account where Name = 'PARTNER001'];

        InvoiceSelectionController controller = new InvoiceSelectionController();
        controller.selectedBank = 'local2'; 
        controller.selectedLanguage = 'en_US';
        controller.selectedReport = 'en_debitnote';
        controller.selectedCustomerId = partner.Id;

        Test.startTest();

        controller.generateReport();
        String openUrl = '/apex/' + Constants.NAMESPACE + 'page_CreditDebitNoteENG?quotationTotalFlag=false&report=debitnote&wkid=' + shipment.Name + '&id=' + shipment.Id
                + '&version=' + String.valueOf(shipment.QuotationVer__c) + '&checkFlag=true&language=en_US&custId=' + partner.Id + '&vat=false&currency=USD'
            ;

        Test.stopTest();
        //System.assertEquals(openUrl, controller.openUrl);
    }

}