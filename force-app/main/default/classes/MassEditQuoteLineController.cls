public class MassEditQuoteLineController {
	@AuraEnabled
    public static String getRecordTypeId(){
        return [SELECT Id,SobjectType FROM RecordType WHERE SobjectType = 'clofor_com_cfs__QuoteLine__c' AND DeveloperName = 'ServiceQuoteLine'].Id;
    }
    
    @AuraEnabled
    public static string getFieldLabels(){
        try {
            Map<String, String> fieldLabels = new Map<String, String>();
            fieldLabels.put('Name', SObjectType.clofor_com_cfs__QuoteLine__c.fields.Name.getLabel());
            fieldLabels.put('clofor_com_cfs__PrintingSection__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__PrintingSection__c.getLabel());
            fieldLabels.put('clofor_com_cfs__ServicePricingID__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__ServicePricingID__c.getLabel());
            fieldLabels.put('clofor_com_cfs__Invoice_to__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__Invoice_to__c.getLabel());
            fieldLabels.put('clofor_com_cfs__CarrierAirlinerVendor__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__CarrierAirlinerVendor__c.getLabel());
            fieldLabels.put('clofor_com_cfs__LineItemName__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__LineItemName__c.getLabel());
            fieldLabels.put('clofor_com_cfs__POLAOD__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__POLAOD__c.getLabel());
            fieldLabels.put('clofor_com_cfs__PODAOA__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__PODAOA__c.getLabel());
            fieldLabels.put('clofor_com_cfs__Print__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__Print__c.getLabel());
            fieldLabels.put('clofor_com_cfs__Quantity__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__Quantity__c.getLabel());
            fieldLabels.put('clofor_com_cfs__Unit__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__Unit__c.getLabel());
            fieldLabels.put('clofor_com_cfs__ContainerType__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__ContainerType__c.getLabel());
            fieldLabels.put('clofor_com_cfs__CurrencySelling__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__CurrencySelling__c.getLabel());
            fieldLabels.put('clofor_com_cfs__TaxRate__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__TaxRate__c.getLabel());
            fieldLabels.put('clofor_com_cfs__SellingListPriceLocal__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__SellingListPriceLocal__c.getLabel());
            fieldLabels.put('clofor_com_cfs__SellingListPriceUSD__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__SellingListPriceUSD__c.getLabel());
            fieldLabels.put('clofor_com_cfs__ServiceSchedule__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__ServiceSchedule__c.getLabel());
            fieldLabels.put('clofor_com_cfs__TransitTimeDays__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__TransitTimeDays__c.getLabel());
            fieldLabels.put('clofor_com_cfs__Remarks__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__Remarks__c.getLabel());
            fieldLabels.put('clofor_com_cfs__SellingListPrice3rdCurrency__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__SellingListPrice3rdCurrency__c.getLabel());
            fieldLabels.put('clofor_com_cfs__Route__c', SObjectType.clofor_com_cfs__QuoteLine__c.fields.clofor_com_cfs__Route__c.getLabel());


            return JSOn.serialize(fieldLabels);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

	@AuraEnabled
    public static List<QuoteLine__c> getAllQuoteLines(String quoteId){
        return [Select id FROM QuoteLine__c WHERE QuoteID__c = :quoteId ORDER BY Route__c ASC,PrintingSection__c  ASC,SellingListPriceUSD__c DESC];
    }
    @AuraEnabled
    public static List<QuoteLine__c> getAllQuoteLines1(String quoteId){
        return [Select id FROM QuoteLine__c  WHERE QuoteID__c = :quoteId ];
    }
    
    @AuraEnabled
    public static Boolean deleteQuoteline(String id){
        try {
            List<QuoteLine__c> quotelines = [Select Id FROM clofor_com_cfs__QuoteLine__c WHERE Id = :id];
            if(quotelines.size() == 0)
                return false;
            delete quotelines;
            return true;
        } catch (DmlException e) {
            throw e;
        }
    }
    @AuraEnabled
    public static Boolean cloneQuoteline(String id){
        try {
            List<QuoteLine__c> quotelines = [Select Id,QuoteID__c,
            PrintingSection__c,
            ServicePricingID__c,
            Invoice_to__c,
            CarrierAirlinerVendor__c,
            POLAOD__c,
            PODAOA__c,
            Print__c,
            Quantity__c,
            Unit__c,
            ContainerType__c,
            CurrencySelling__c,
            TaxRate__c,
            LineItemName__c,
            SellingListPriceLocal__c,
            SellingListPriceUSD__c, 
            ServiceSchedule__c,
            TransitTimeDays__c,
            Remarks__c,
            SellingListPrice3rdCurrency__c,
            Route__c
            FROM clofor_com_cfs__QuoteLine__c WHERE Id = :id];
    // String quote = '';
    List<QuoteLine__c> lstIn = new List<QuoteLine__c>();
            if(quotelines.size() == 0)
                return false;
                
                
                 for(QuoteLine__c ql : quotelines){
                    QuoteLine__c ql11 = ql.clone(false);
                    System.debug('ql11 :'+ql11);
                //    quote = ql.QuoteID__c;
                lstIn.add(ql11);
                 }
                 insert lstIn;
                 System.debug('lstIn :'+lstIn);
                 
//                  List<QuoteLine__c> quotelines3 = [Select Id,QuoteID__c FROM clofor_com_cfs__QuoteLine__c WHERE QuoteID__c = :quote];
// System.debug('quotelines3 :'+quotelines3.size());
            // QuoteLine__c ql11 = new QuoteLine__c(QuoteID__c = quote);
            // insert ql11;
            return true;
            
        } catch (DmlException e) {
            throw e;
        }
    }

	@AuraEnabled
    public static String updateQuoteLines(String jsonRecords){
		List<QuoteLine__c> records = (List<QuoteLine__c>) JSON.deserialize(jsonRecords, List<QuoteLine__c>.class);
        System.debug('records: ' + records);
        Set<Id> ids = (new Map<Id,SObject>(records)).keySet();
        System.debug('ids: ' + ids);
        List<QuoteLine__c>  quoteLines = [SELECT Id FROM QuoteLine__c WHERE Id in :ids];
        for(Integer i  = 0; i < records.size(); i++){
            QuoteLine__c r = records[i];
            for(Integer j  = 0; j < quoteLines.size(); j++){
                if(quoteLines[j].Id == r.Id){
        			System.debug('r.Id: ' + r.Id);
                    quoteLines[j].clofor_com_cfs__PrintingSection__c = r.clofor_com_cfs__PrintingSection__c;
                    quoteLines[j].clofor_com_cfs__ServicePricingID__c = r.clofor_com_cfs__ServicePricingID__c;
                    quoteLines[j].clofor_com_cfs__LineItemName__c = r.clofor_com_cfs__LineItemName__c;
                    quoteLines[j].clofor_com_cfs__Invoice_to__c = r.clofor_com_cfs__Invoice_to__c;
                    quoteLines[j].clofor_com_cfs__CarrierAirlinerVendor__c = r.clofor_com_cfs__CarrierAirlinerVendor__c;
                    quoteLines[j].clofor_com_cfs__POLAOD__c = r.clofor_com_cfs__POLAOD__c;
                    quoteLines[j].clofor_com_cfs__PODAOA__c = r.clofor_com_cfs__PODAOA__c;
                    quoteLines[j].clofor_com_cfs__Route__c = r.clofor_com_cfs__Route__c;
                    quoteLines[j].clofor_com_cfs__Print__c = r.clofor_com_cfs__Print__c;
                    quoteLines[j].clofor_com_cfs__TransitTimeDays__c = r.clofor_com_cfs__TransitTimeDays__c;
                    quoteLines[j].clofor_com_cfs__ServiceSchedule__c = r.clofor_com_cfs__ServiceSchedule__c;
                    quoteLines[j].clofor_com_cfs__Quantity__c = r.clofor_com_cfs__Quantity__c;
                    quoteLines[j].clofor_com_cfs__Unit__c = r.clofor_com_cfs__Unit__c;
                    quoteLines[j].clofor_com_cfs__ContainerType__c = r.clofor_com_cfs__ContainerType__c;
                    quoteLines[j].clofor_com_cfs__CurrencySelling__c = r.clofor_com_cfs__CurrencySelling__c;
                    quoteLines[j].clofor_com_cfs__SellingListPriceLocal__c = r.clofor_com_cfs__SellingListPriceLocal__c;
                    quoteLines[j].clofor_com_cfs__SellingListPriceUSD__c = r.clofor_com_cfs__SellingListPriceUSD__c;
                    quoteLines[j].clofor_com_cfs__SellingListPrice3rdCurrency__c = r.clofor_com_cfs__SellingListPrice3rdCurrency__c;
                    quoteLines[j].clofor_com_cfs__Remarks__c = r.clofor_com_cfs__Remarks__c;
                    quoteLines[j].clofor_com_cfs__TaxRate__c = r.clofor_com_cfs__TaxRate__c;
                    // System.debug('r.clofor_com_cfs__Unit__c ' + r.Id + r.clofor_com_cfs__Unit__c);
                    break;
                }
            }
        }
        try {
        	update quoteLines;
        	return JSON.serialize(quoteLines);
        }
        catch (Exception e) {
   			// System.debug('The following exception has occurred: ' + e.getMessage());
            // return 'The following exception has occurred: ' + e.getMessage();
            throw new DmlException(e.getMessage());
        }
    }
}