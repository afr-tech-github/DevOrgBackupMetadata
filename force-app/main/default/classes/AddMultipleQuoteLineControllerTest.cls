@isTest
public with sharing class AddMultipleQuoteLineControllerTest {
    public static testMethod void checkAddMultipleQuoteLine() {
        Test.startTest();
		List<clofor_com_cfs__QuoteLine__c> lstQuoteLine = new List<clofor_com_cfs__QuoteLine__c>();
        clofor_com_cfs__Quote__c quote = new clofor_com_cfs__Quote__c(clofor_com_cfs__QuoteName__c = 'testQuote');
        insert quote;


        clofor_com_cfs__QuoteLine__c quote1 = new clofor_com_cfs__QuoteLine__c(	clofor_com_cfs__QuoteID__c = quote.Id);
        lstQuoteLine.add(quote1);
        clofor_com_cfs__QuoteLine__c quote2 = new clofor_com_cfs__QuoteLine__c(	clofor_com_cfs__QuoteID__c = quote.Id);  
        lstQuoteLine.add(quote2);
        clofor_com_cfs__QuoteLine__c quote3 = new clofor_com_cfs__QuoteLine__c(	clofor_com_cfs__QuoteID__c = quote.Id);  
        lstQuoteLine.add(quote3);
        AddMultipleQuoteLineController.saveQuoteLineList(lstQuoteLine, quote.Id);
        // add.saveBillList(bill,shipment.Id);
        // add.saveBillList(bill,shipment.Id);
        //System.assertEquals('ONE (1) 20\'DC CONTAINER ONLY', Consol.clofor_com_cfs__NumberofContainer__c);
        
        Test.stopTest();
    }
}