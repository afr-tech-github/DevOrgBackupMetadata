@isTest
public class MassEditBuyingQuoteLineControllerTest {
    @testSetup
    static void setup() {
 		Quote__c quote = new Quote__c();
        insert quote;
        QuoteLine__c quoteLine = new QuoteLine__c(QuoteID__c = quote.Id);
        insert quoteLine;
	}

	@isTest
    static void testReturnFirstRecordId(){
        String recordTypeId = MassEditBuyingQuoteLineController.getRecordTypeId();
        System.assertNotEquals('', recordTypeId);
    }
    
    @isTest
    static void testGetAllQuoteLines(){
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        List<QuoteLine__c> allQuoteLines = MassEditBuyingQuoteLineController.getAllQuoteLines(quote.Id);
        System.assertNotEquals(0, allQuoteLines.size());
    }
    @isTest
    static void testGetAllQuoteLines1(){
        Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
        List<QuoteLine__c> allQuoteLines1 = MassEditBuyingQuoteLineController.getAllQuoteLines1(quote1.Id);
        System.assertNotEquals(0, allQuoteLines1.size());
    }
    
    @isTest
    static void testUpdateQuoteLines(){
        List<QuoteLine__c> allQuoteLines = [SELECT Id FROM QuoteLine__c];
        String jsonRecords = JSON.serialize(allQuoteLines);
        String res = MassEditBuyingQuoteLineController.updateQuoteLines(jsonRecords);
        System.assertEquals(false, res.contains('The following exception has occurred:'));
    }
    @isTest
    static void testDeleteQuoteLines(){

        QuoteLine__c quoteline = [SELECT Id FROM QuoteLine__c LIMIT 1];
        Boolean res = MassEditBuyingQuoteLineController.deleteQuoteline(quoteLine.Id);
        System.assertEquals(true, res);
        Boolean res1 = MassEditBuyingQuoteLineController.deleteQuoteline('quoteLine');
          System.assertEquals(false, res1);
    }
    @isTest
    static void testCloneQuoteLines(){

        QuoteLine__c quoteline = [SELECT Id FROM QuoteLine__c LIMIT 1];
        Boolean res = MassEditBuyingQuoteLineController.cloneQuoteline1(quoteLine.Id);
        System.assertEquals(true, res);
        Boolean res1 = MassEditBuyingQuoteLineController.cloneQuoteline1('quoteLine');
          System.assertEquals(false, res1);
    }

    @isTest
    static void testetFieldLabels(){
        String res = MassEditBuyingQuoteLineController.getFieldLabels();
        System.assertNotEquals(res, '');
    }
}