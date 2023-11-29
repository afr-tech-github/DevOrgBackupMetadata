public class ProfitSheetVFController {
	public Boolean isOnBehalfCustomer {get; set;}
    public Boolean isOnBehalfOurCompany {get; set;}
    public Boolean isKickback {get; set;}
    public String percentRevenue {get; set;}
    public String percentProfit {get; set;}
    public Map<String, String> translations { get; private set; }
    
    public ProfitSheetVFController(){
        TranslationService translationService = new TranslationService('Profit_Sheet', UserInfo.getLanguage());
        translations = translationService.getTranslations();
        isOnBehalfCustomer = false;
        isOnBehalfOurCompany = false;
        isKickback = false;
        percentRevenue = '';
        percentProfit = '';
    }
    
    public PageReference exportPDF(){
        PageReference pageRef;
        
        if(String.isEmpty(percentRevenue)){
            percentRevenue = '0';
        }
        if(String.isBlank(percentProfit)){
            percentProfit = '0';
        }
        
        String sId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
        pageRef = Page.ProfitSheet2;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', String.valueof(sId));
        pageRef.getParameters().put('isOnBehalfCustomer', String.valueof(isOnBehalfCustomer));
        pageRef.getParameters().put('isOnBehalfOurCompany', String.valueof(isOnBehalfOurCompany));
        pageRef.getParameters().put('isKickback', String.valueof(isKickback));
        pageRef.getParameters().put('percentRevenue', percentRevenue);
        pageRef.getParameters().put('percentProfit', percentProfit);
        
        if(!checkNumber(percentRevenue) && !String.isBlank(percentRevenue) || !checkNumber(percentProfit) && !String.isBlank(percentProfit)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You must input number'));
            return null;
        }
        return pageRef;
    }
    
    private Boolean checkNumber(String strNum){
        try{
            Decimal.valueOf(strNum);
            return true;
        }
        catch(Exception ex){
            return false;
        }
    }
}