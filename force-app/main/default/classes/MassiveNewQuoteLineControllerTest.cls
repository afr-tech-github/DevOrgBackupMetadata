@isTest
private class MassiveNewQuoteLineControllerTest {
    private static Quote__c quote{get; set;}
    private static List<Account> listAccount = new List<Account>();
    static{
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        listAccount = createAccounts();

        String domesticquote = Schema.SObjectType.Quote__c.getRecordTypeInfosByDeveloperName().get('DomesticLogisticsServiceQuote').getRecordTypeId();
        quote = createQuote(domesticquote, listAccount[0].Id);
        
    }
    
	@isTest static void test_method_one() {
		Test.startTest();
		ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        MassiveNewQuoteLineController ctrl = new MassiveNewQuoteLineController();
        ctrl.recordsNumber = 5;
        ctrl.initiateQuoteLineItems();
        for(QuoteLine__c ql : ctrl.listQuoteLine){
            ql.clofor_com_cfs__LineItemName__c = 'test';
        }
        Pagereference pageTest = ctrl.createQuoteLines();
        System.assert(ctrl.recordsNumber != null);
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

}