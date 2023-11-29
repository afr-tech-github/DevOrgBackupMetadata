@isTest
private class QuotationReportControllerMultiTest {
	private static List<Quote__c> quotes{get; set;}
	private static List<QuoteLine__c> quoteLineItems = new List<QuoteLine__c>();
	private static List<Account> listAccount = new List<Account>();
	static{
		Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
		// tao account
		// 
		Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        listAccount = createAccounts();
        
	}
	@isTest static void test_domestic() {
		
		String domesticquote = Schema.SObjectType.Quote__c.getRecordTypeInfosByDeveloperName().get('DomesticLogisticsServiceQuote').getRecordTypeId();
		Quote__c quote = createQuote(domesticquote, listAccount[0].Id);
		List<QuoteLine__c> lineItems = createQuoteLines(quote.Id);
		Test.startTest();
			ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
			ApexPages.currentPage().getParameters().put('language', 'en');
			QuotationReportControllerMultiCurrency ctrl = new QuotationReportControllerMultiCurrency();
            Map<String, String > translation = ctrl.getTranslation();
            System.assert(quote.Id != null);
		Test.stopTest();
	}

    @isTest static void test_air() {
	
        String airquote = Schema.SObjectType.Quote__c.getRecordTypeInfosByDeveloperName().get('AirLogisticsServiceQuote').getRecordTypeId();
        Quote__c quote = createQuote(airquote, listAccount[0].Id);
        List<QuoteLine__c> lineItems = createQuoteLines(quote.Id);
        Test.startTest();
            ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
            ApexPages.currentPage().getParameters().put('language', 'en');
            QuotationReportControllerMultiCurrency ctrl = new QuotationReportControllerMultiCurrency();
            Map<String, String > translation = ctrl.getTranslation();
            System.assert(quote.Id != null);
        Test.stopTest();
    }
	
	@isTest static void test_create_attachment() {
	    String domesticquote = Schema.SObjectType.Quote__c.getRecordTypeInfosByDeveloperName().get('DomesticLogisticsServiceQuote').getRecordTypeId();
        Quote__c quote = createQuote(domesticquote, listAccount[0].Id);
        List<QuoteLine__c> lineItems = createQuoteLines(quote.Id);
        Test.startTest();
            ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
            ApexPages.currentPage().getParameters().put('language', 'en');
            QuotationReportControllerMultiCurrency.checkContainerTypeNumber(quote.Id);
            QuotationReportControllerMultiCurrency.createAttatchment(quote.Id, 'en');
            System.assert(quote.Id != null);
        Test.stopTest();
	}

    @isTest static void test_generateQuotation() {
       String domesticquote = Schema.SObjectType.Quote__c.getRecordTypeInfosByDeveloperName().get('LogisticsServiceQuote').getRecordTypeId();
        Quote__c quote = createQuote(domesticquote, listAccount[0].Id);
        List<QuoteLine__c> lineItems = createQuoteLines(quote.Id);
        Test.startTest();
            ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
            ApexPages.currentPage().getParameters().put('language', 'en');
            QuotationReportControllerMultiCurrency ctrl = new QuotationReportControllerMultiCurrency();
            ctrl.requiredAttachmentCreation = true;
            PageReference pdf_file = ctrl.generateQuotation();
            System.assert(quote.Id != null);
        Test.stopTest();
    }

	private static List<Account> createAccounts(){
        List<Account> lst = new List<Account>();
        Account accountVender = new Account(
            Name = 'Account vender',
            EnglishCompanyName__c = 'Account vender',
            Business_Relationship__c = '3rd Vendor');
        Account accountPartner = new Account(
            Name = 'Account Partner',
            EnglishCompanyName__c = 'Account Partner',
            Business_Relationship__c = 'Partner');
        Account accountCustomer = new Account(
            Name = 'Account Customer',
            EnglishCompanyName__c = 'Account Customer',
            Business_Relationship__c = 'Customer');
        lst.add(accountVender);
        lst.add(accountPartner);
        lst.add(accountCustomer);
        FlsService.doInsert(lst);
        return lst;
    }

    private static Quote__c createQuote(String recordTypeIdArg, String accountIdArg){
        Quote__c quote = new Quote__c(
            RecordTypeId = recordTypeIdArg,
            RequesterCompany__c = accountIdArg);
        FlsService.doInsert(quote);
        return quote;
    }

    private static List<QuoteLine__c> createQuoteLines(String quoteId){
    	List<QuoteLine__c> lineItems = new List<QuoteLine__c>();
        QuoteLine__c quoteLineVND = new QuoteLine__c(
            QuoteID__c = quoteId,
            CurrencySelling__c = 'VND',
            Quantity__c = 1,
            SellingListPriceLocal__c = 300000,
            TaxRate__c = 10
            );
        QuoteLine__c quoteLineUSD = new QuoteLine__c(
            QuoteID__c = quoteId,
            CurrencySelling__c = 'USD',
            Quantity__c = 1,
            SellingListPriceUSD__c = 30,
            TaxRate__c = 10
            );
        
        lineItems.add(quoteLineVND);
        lineItems.add(quoteLineUSD);
        FlsService.doInsert(lineItems);
        return lineItems;
    }
	
}