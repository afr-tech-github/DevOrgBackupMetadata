public class DCBReportController {
    public String fromDate {get;set;}
    public String toDate {get;set;}
    public String customerId {get;set;}
    public String customerName {get;set;}
    public String customerENName {get;set;}
    public String reportOption {get;set;}
    public String pageType {get;set;}
    public String language {get;set;}
    public String selectedLanguage {get;set;}    
    public Map<String, String> translations {get; private set;}
    private static Map<String, PageReference> reportMappingPDF = new Map<String, PageReference>();
    private static Map<String, PageReference> reportMappingExcel = new Map<String, PageReference>();
    
    static {
        reportMappingPDF.put('en_US', Page.page_DCBReportPDF_EN);
        reportMappingPDF.put('ja', Page.page_DCBReportPDF);
        reportMappingPDF.put('vi', Page.page_DCBReportPDF_VN);
        reportMappingPDF.put('ko', Page.page_DCBReportPDF_KR);
        
        reportMappingExcel.put('en_US', Page.page_DCBReportEXCEL_EN);
        reportMappingExcel.put('ja', Page.page_DCBReportEXCEL);
        reportMappingExcel.put('vi', Page.page_DCBReportEXCEL_VN);
        reportMappingExcel.put('ko', Page.page_DCBReportEXCEL_KR);
    }
    
    public DCBReportController() {
        initializeTranslation();
    }
    
    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('OutstandingStatementReport', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }
    
    public PageReference generateCustomerReport() {
        PageReference reportPage = null;
		
        if (StringUtils.isEmpty(language)) {
        	language = 'en_US';    
        }
        
        if ('pdf'.equals(pageType)) {
            reportPage = reportMappingPDF.get(language);
        } else if ('excel'.equals(pageType)) {
            reportPage = reportMappingExcel.get(language);
        }

        reportPage.getParameters().put('fromDate', fromDate);
        reportPage.getParameters().put('toDate', toDate);
        reportPage.getParameters().put('customerId', customerId);
        reportPage.getParameters().put('customerName', customerName);
        reportPage.getParameters().put('customerENName', customerENName);
        reportPage.getParameters().put('reportOption', reportOption);

        reportPage.setRedirect(true);
        
        return reportPage;
    }
}