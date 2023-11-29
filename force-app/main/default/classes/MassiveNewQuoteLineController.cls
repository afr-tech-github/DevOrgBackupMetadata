public with sharing class MassiveNewQuoteLineController {
    public Integer recordsNumber{get;set;}
    private String recordtypeId;
    public Boolean initialMode{get;set;}
    public Quote__c quote {get;set;}
    public List<QuoteLine__c> listQuoteLine{get;set;}
    private Decimal maxQuoteLineNumber{get;set;}
    public MassiveNewQuoteLineController() {
        initialMode = true;
        listQuoteLine = new List<QuoteLine__c>();
        maxQuoteLineNumber = 0;
        Map<String, String> recordTypesMap = new Map<String, String>();
        recordTypesMap.put('LogisticsServiceQuote','ServiceQuoteLine');
        recordTypesMap.put('AirLogisticsServiceQuote','AirLogisticsServiceQuote');
        recordTypesMap.put('DomesticLogisticsServiceQuote','DomesticLogisticsServiceQuote');
        recordTypesMap.put('ProductQuote ','ProductQuoteLine');
        String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        if(!String.isBlank(quoteId)){
            List<Quote__c> quotes = [Select Id, RecordType.DeveloperName From Quote__c where Id =: quoteId];
            if(!quotes.isEmpty()){
                quote = quotes[0];
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Quote was not found.'));
                return;
            }
            recordtypeId = Schema.SObjectType.QuoteLine__c.getRecordTypeInfosByDeveloperName().get(recordTypesMap.get(quote.RecordType.DeveloperName)).getRecordTypeId();
            List<AggregateResult> maxResult = [SELECT MAX(clofor_com_cfs__QuoteLineNumber__c) maxNumber FROM QuoteLine__c where clofor_com_cfs__QuoteID__c =: quote.Id];
            if(maxResult.size() > 0 && maxResult[0].get('maxNumber') != null){
                maxQuoteLineNumber  = (Decimal)maxResult[0].get('maxNumber');
            }else{
                maxQuoteLineNumber = 0;
            }
            
        }else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please specify the quote Id.'));
            return;
        }
    }
    public void initiateQuoteLineItems(){
        if(recordsNumber <= 0 ){
            return;
        }
        for(Integer i = 0; i < recordsNumber; i++){
            QuoteLine__c newQuoteLine = new QuoteLine__c(
                RecordtypeId = recordtypeId,
                PrintingSection__c = '1st Section',
                Print__c = true,
                QuoteID__c = quote.Id
            );
            listQuoteLine.add(newQuoteLine);
        }
        initialMode = false;
    }
    public Pagereference createQuoteLines(){
        //try{
            List<QuoteLine__c> newLines = new List<QuoteLine__c>();
            for(QuoteLine__c line : listQuoteLine ){
                if(line.clofor_com_cfs__ServicePricingID__c != null 
                || !String.isBlank(line.clofor_com_cfs__LineItemName__c) 
                || line.Quantity__c != null || line.ContainerType__c != null 
                || line.CurrencySelling__c != null || line.SellingListPriceLocal__c != null
                || line.SellingListPriceUSD__c != null || line.TaxRate__c != null || !String.isBlank(Line.Remarks__c ) ){
                    line.QuoteLineNumber__c = maxQuoteLineNumber + 1;
                    maxQuoteLineNumber += 1;
                    newLines.add(line);
                }
            }
            
            FlsService.doInsert(newLines);
            PageReference pg = new PageReference('/'+quote.Id);
            pg.setRedirect(true);
            return pg;
        //}catch(Exception ex){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
           // return null;
        //}
    }
    public void addMore(){
        recordsNumber ++;
        listQuoteLine.add(new QuoteLine__c(
            RecordtypeId = recordtypeId,
            PrintingSection__c = '1st Section',
            Print__c = true,
            QuoteID__c = quote.Id
        ));
    }
}