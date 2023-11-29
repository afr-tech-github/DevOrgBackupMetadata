public with sharing class DCBDetailReportController {
    public Date fromDate {get; private set;}
    public Date toDate {get; private set;}
    public String reportOption {get; private set;}
    public String reportType {get; set;}
    public DCB_SubReportWrapper customerReport {get; set;}
    public List<DCB_ReportLineItem> lineItems {get; set;}
    public Date reportDate {get; private set;}
    public String currencyType {get; set;}
    public Boolean isDisplayDetail {get; set;}
    
    public DCBDetailReportController() {
        String sfromDate = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('fromDate'));
        String stoDate = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('toDate'));
        String customerId = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('customerId'));
        String customerName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(Apexpages.currentPage().getParameters().get('customerName'),'UTF-8'));
        String customerENName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(Apexpages.currentPage().getParameters().get('customerENName'),'UTF-8'));
        currencyType = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('currencyType'));
        String searchType = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('searchType'));
        String strWkid = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('strWkid'));
        reportType = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('reportType'));
        String strId = '';
        isDisplayDetail = false;
        if(!String.isBlank(strWkid))
        {
            List<String> lstId = new List<String>();
            lstId = strWkid.split(',');
            if(lstId.size() > 0){
                for(String sid : lstId){
                    strId += '\'' + sid + '\',';
                }
            }
            strId = strId.removeEnd(','); 
        }  
        reportOption = Apexpages.currentPage().getParameters().get('reportOption');
        
        if (!StringUtils.isEmpty(sfromDate)) {
            fromDate = DateTimeUtils.parseDate(sfromDate, '-');
        }
        
        if (!StringUtils.isEmpty(stoDate)) {
            toDate = DateTimeUtils.parseDate(stoDate, '-');    
        }
        //customerReport = generateCustomerReport();
        customerReport = generateCustomerReportExport(strId, customerId, sfromDate, stoDate, searchType, customerName, customerENName);
        lineItems =	new List<DCB_ReportLineItem>();
        if(!String.isBlank(strId)){
            lineItems = getAllLineItemByIds(strId, customerId, sfromDate, stoDate, searchType);
        }
        
        reportDate = System.today();
    }
    
    private List<DCB_ReportLineItem> getAllLineItemByIds (String strId, String customerId, String sfromDate, String stoDate, 
                                                              String searchType){
      	DCBReportService service = new DCBReportService();
        Map<String, List<DCB_ReportLineItem>> lineItemMap = new Map<String, List<DCB_ReportLineItem>>();
        if(reportType == 'DOMESTIC_CREDIT_DEBIT'){
            lineItemMap = service.generateGeneralReportCustomerCreditDebitDetail(strId, customerId, sfromDate, stoDate, searchType);
        }else{
            lineItemMap = service.generateGeneralReportCustomerDetail(strId, customerId, sfromDate, stoDate, searchType);
        }
        List<DCB_ReportLineItem> lineItemLst = new List<DCB_ReportLineItem>();
        if(lineItemMap.size() > 0){
            for(String key : lineItemMap.keySet()){
                lineItemLst.addAll(lineItemMap.get(key));
            }
        }
        return lineItemLst;
    }
    
    private DCB_SubReportWrapper generateCustomerReportExport(String strId, String customerId, String sfromDate, String stoDate, 
                                                              String searchType, String customerName, String customerENName){
        DCBReportService service = new DCBReportService();
    
        DCB_ReportWrapper customerReportWrapper = new DCB_ReportWrapper();
        if(reportType == 'DOMESTIC_CREDIT_DEBIT'){
            customerReportWrapper = service.generateGeneralReportCustomerCreditDebit(strId, customerId, sfromDate, stoDate, searchType);
        }else{
            customerReportWrapper = service.generateGeneralReportCustomer(strId, customerId, sfromDate, stoDate, searchType);
        }
        if (customerReportWrapper.customerReports.size() > 0) {
            return customerReportWrapper.customerReports.get(0);
        }
        
        DCB_SubReportWrapper report = new DCB_SubReportWrapper(customerName, customerENName, customerId);
        return report;
    }
    
    /*private DCB_SubReportWrapper generateCustomerReport() {
        
        DCBReportService service = new DCBReportService();
        String sfromDate = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('fromDate'));
        String stoDate = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('toDate'));
        String customerId = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('customerId'));
        String customerName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(Apexpages.currentPage().getParameters().get('customerName'),'UTF-8'));
        String customerENName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(Apexpages.currentPage().getParameters().get('customerENName'),'UTF-8'));
        String currencyType = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('currencyType'));
        String searchType = StringUtils.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('searchType'));
            
        reportOption = Apexpages.currentPage().getParameters().get('reportOption');

        if (!StringUtils.isEmpty(sfromDate)) {
            fromDate = DateTimeUtils.parseDate(sfromDate, '-');
        }
        
        if (!StringUtils.isEmpty(stoDate)) {
            toDate = DateTimeUtils.parseDate(stoDate, '-');    
        }

        DCB_ReportWrapper customerReportWrapper = service.generateCustomerReport(customerId, sfromDate, stoDate, reportOption);

        if (customerReportWrapper.customerReports.size() > 0) {
            return customerReportWrapper.customerReports.get(0);
        }
        
        DCB_SubReportWrapper report = new DCB_SubReportWrapper(customerName, customerENName, customerId);
        
        return report;
    }*/
}