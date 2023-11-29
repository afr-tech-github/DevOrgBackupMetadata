public class TaxRatioTriggerHandler extends AbstractTriggerHandler {
    private List<Tax_Ratio__c> existingTaxRatios = new List<Tax_Ratio__c>();
    private static TranslationService translationService;
    
    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }
    
    public override String getHandlerName() {
        return 'TaxRatioTriggerHandler';
    }
    
    public override void bulkBefore() {
        loadPotentialDupliatedTaxRatios(Trigger.new);
    }
    
    public override void beforeInsert(SObject so) {
        Tax_Ratio__c taxRatio = (Tax_Ratio__c) so;
        validate(taxRatio);
    }
    
    public override void beforeUpdate(SObject old, SObject so) {
        Tax_Ratio__c newTaxRatio = (Tax_Ratio__c) so;
        validate(newTaxRatio);
    }
    
    private void validate(Tax_Ratio__c taxRatio) {
        for (Tax_Ratio__c tx : existingTaxRatios) {
            if (tx.Id != taxRatio.Id && tx.Currency__c.equals(taxRatio.Currency__c) 
                	&& tx.Start_Date__c <= taxRatio.End_Date__c && tx.End_Date__c >= taxRatio.Start_Date__c) {
				taxRatio.addError(translationService.getTranslation(Constants.OVERLAPPED_TAX_RATIO) + ' ' + tx.Name);                        
            }
        }
    } 
    
    private void loadPotentialDupliatedTaxRatios(List<Tax_Ratio__c> toBePersistedTaxRatios) {
        Set<String> currencies = new Set<String>();
        Date minStartDate = null;
        Date maxEndDate = null;
        
        for (Tax_Ratio__c tx : toBePersistedTaxRatios) {
            if (minStartDate == null || minStartDate > tx.Start_Date__c) {
                minStartDate = tx.Start_Date__c;
            }    
            
            if (maxEndDate == null || maxEndDate < tx.End_Date__c) {
                maxEndDate = tx.End_Date__c;
            }
            
            currencies.add(tx.Currency__c);
        }
        
        existingTaxRatios = [SELECT ID, Name, Start_Date__c, End_Date__c, Currency__c 
                             FROM Tax_Ratio__c 
                             WHERE Currency__c IN :currencies  AND Start_Date__c <= :maxEndDate
                            	AND End_Date__c >= :minStartDate AND Active__c = True];
    }
}