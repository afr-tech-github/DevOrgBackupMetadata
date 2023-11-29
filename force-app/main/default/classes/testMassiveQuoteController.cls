public class testMassiveQuoteController {
	@AuraEnabled
    public static List<QuoteLine__c> getAllQuoteLines(String quoteId){
        return [Select id FROM QuoteLine__c WHERE QuoteID__c = :quoteId  LIMIT 5];
    } 
}