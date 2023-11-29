public with sharing class AddMultipleQuoteLineController {
    @AuraEnabled
    public static void saveQuoteLineList(List<clofor_com_cfs__QuoteLine__c> quoteLineList,Id quoteId) 
	{  
        // clofor_com_cfs__TariffMaster__c services = [select id from clofor_com_cfs__TariffMaster__c limit];
        for(clofor_com_cfs__QuoteLine__c quoLine: quoteLineList){

            quoLine.clofor_com_cfs__QuoteID__c = quoteId;
       
        }
        Insert quoteLineList;
    }
}