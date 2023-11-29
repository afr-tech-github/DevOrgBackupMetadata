/* 15-Jun-2019 | Remove exchange rate duplication rules */
public class ExchangeRateTriggerHandler {/* extends AbstractTriggerHandler {
    private List<MgmtMaster__c> exchangeRates = new List<MgmtMaster__c>();
    private static TranslationService translationService;
    
    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }
    
    public override String getHandlerName() {
        return 'ExchangeRateTriggerHandler';
    }
    
    public override void bulkBefore() {
        loadValidExchangeRates();
    }
    
	public override void beforeInsert(SObject so) {
        MgmtMaster__c exchangeRate = (MgmtMaster__c) so;
        checkDuplicatedExchangeRate(exchangeRate);            
    }
    
    public override void beforeUpdate(SObject oldSo, SObject so) {
        MgmtMaster__c exchangeRate = (MgmtMaster__c) so;
        checkDuplicatedExchangeRate(exchangeRate);
    }
    
    private void loadValidExchangeRates() {
        exchangeRates = [SELECT Id, Name, Mgmt_Exrate_Start_Date__c, Mgmt_Exrate_End_Date__c, Mgmt_Exrate_fromto__c 
                         FROM MgmtMaster__c 
                         WHERE Mgmt_Exrate_Validity__c = True]; 
    }
    
    private void checkDuplicatedExchangeRate(MgmtMaster__c exchangeRate) {
        if (exchangeRates != null && !exchangeRates.isEmpty() && exchangeRate.Mgmt_Exrate_Validity__c) { 
            for (MgmtMaster__c exRate : exchangeRates) {
                if (exRate.Id != exchangeRate.Id 
                    	&& exchangeRate.Mgmt_Exrate_fromto__c.equals(exRate.Mgmt_Exrate_fromto__c)
                    	&& exchangeRate.Mgmt_Exrate_Start_Date__c <= exRate.Mgmt_Exrate_End_Date__c 
                    	&& exchangeRate.Mgmt_Exrate_End_Date__c >= exRate.Mgmt_Exrate_Start_Date__c) {
					String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
                    String errorMessage = translationService.getTranslation(Constants.OVERLAPPED_EXCHANGE_RATE) + ' <a href="' + fullFileURL + '/' 
                            + exRate.Id + '" target="_blank">' + exRate.Name + '</a>';
                    Trigger.new[0].addError(new TriggerException(errorMessage), false);
				}
            }
        }
    }
    */
}