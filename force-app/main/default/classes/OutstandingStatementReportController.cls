public with sharing class OutstandingStatementReportController {
    public List<ReportWrapper> lstReportWrapper { get; set; }
    public Map<String, ReportWrapper> mapReportWrapper;
    public Decimal grandDebit { get; set; }
    public Decimal grandCredit { get; set; }
    public Decimal grandBalance { get; set; }
    public Date fromDate { get; set; }
    public Date toDate { get; set; }
    public String sFromDate { get; set; }
    public String sToDate { get; set; }
    public String partnerName { get; set; }
    public String pageType { get; set; }
    public String customerId { get; set; }
    public String customerName { get; set; }
    public String customerENName { get; set; }
    public String reportOption { get; set; }
    public String message { get; set; }
    public String money { get; set; }
    public String reportType { get; set; }
    public String reportName { get; set; }
    public String tableDisplay { get; set; }
    public String reportPrintType { get; set; }
    public ReportWrapper detailReportData { get; set; }
    public String selectedLanguage { get; set; }
    public Map<String, Decimal> mapCreditLocal {get; set;}
    public Map<String, ReportLocal> mapLocal {get; set;}
    public Map<String, ReportLocal> mapSubTotalLocal {get; set;}
    public ReportLocal grandTotalLocal {get; set;}
    public Map<String, List<AnkenDetail>> mapAnkenDetail {get; set;}
    public Map<String, Boolean> mapShowHideDetail {get; set;}
    public Map<String, Boolean> mapShowHideTable {get; set;}
    public String searchType {get; set;}
    public String showType {get; set;}
    public Map<String, List<DCB_ReportLineItem>> reportCustomerDetail {get; set;}
    
    public List<SelectOption> lstName {get; set;}
    public String strNameId {get; set;}
    public String strTblName {get; set;}
    public Boolean isCustomer {get; set;}
    public Boolean isShowHideExist {get; set;}
    public Boolean isAnkenDetailExist {get; set;}
    
    public Map<String, Boolean> mapShowHideDetailCustomer {get; set;}
    public Map<String, List<String>> mapTableAndDetailCustomer {get; set;}
    public Map<String, Boolean> mapShowHideTableCustomer {get; set;}
    
    private Map<String, List<String>> mapTableAndDetail {get; set;}
    private Map<String, Id> mapRecordTypes = new Map<String, Id>();
    
    /**
     * For Domestic Customer Billing report
     */
    public DCB_ReportWrapper dcbReportWrapper { get; set; }
    public String dcbReportOption { get; set; }
    public Map<String, String> translations { get; private set; }

    private static Map<String, PageReference> reportMappingPDF = new Map<String, PageReference>();
    private static Map<String, PageReference> reportMappingExcel = new Map<String, PageReference>();
    private static Map<String, String> reportTypeBusinessRelationship = new Map<String, String>();

    static {
        reportMappingPDF.put('en_US', Page.page_DCBReportPDF_EN);
        reportMappingPDF.put('ja', Page.page_DCBReportPDF);
        reportMappingPDF.put('vi', Page.page_DCBReportPDF_VN);
        reportMappingPDF.put('ko', Page.page_DCBReportPDF_KR);

        reportMappingExcel.put('en_US', Page.page_DCBReportEXCEL_EN);
        reportMappingExcel.put('ja', Page.page_DCBReportEXCEL);
        reportMappingExcel.put('vi', Page.page_DCBReportEXCEL_VN);
        reportMappingExcel.put('ko', Page.page_DCBReportEXCEL_KR);

        reportTypeBusinessRelationship.put('Outstanding', Constants.PARTNER_RELATIONSHIP);
        reportTypeBusinessRelationship.put('DOMESTIC', Constants.CUSTOMER_RELATIONSHIP);
        reportTypeBusinessRelationship.put('VENDOR', Constants.VENDOR_RELATIONSHIP);
    }

    public OutstandingStatementReportController() {
        initializeTranslation();
        money = 'USD';
        reportName = 'PARTNER OUTSTANDING STATEMENT REPORT';
        searchType = 'ETD';
        showType = 'Both';
        lstName = new List<SelectOption>();
        strNameId = '';
        isCustomer = false;
        isShowHideExist = false;
        isAnkenDetailExist = false;
        reportPrintType = '';
        reportType = 'Outstanding';
        strTblName = Constants.PARTNER_RELATIONSHIP;
        Map<String, String> mapPrtVenName = getParnerVendorName(null, null, reportType, strTblName);
        for(String key: mapPrtVenName.keySet()){
            lstName.add(new SelectOption(key, mapPrtVenName.get(key)));
        }
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('OutstandingStatementReport', UserInfo.getLanguage());
        translations = translationService.getTranslations();
        for(String key : translations.keySet()){
        }
        
    }
    
    public void onChangeType(){
        if (reportType.equalsIgnoreCase('VENDOR')){
            strTblName = Constants.VENDOR_RELATIONSHIP;
        }
        else if (reportType.equalsIgnoreCase('Outstanding')){
            strTblName = Constants.PARTNER_RELATIONSHIP;
        }
        else if (reportType.equalsIgnoreCase('DOMESTIC')){
            strTblName = Constants.CUSTOMER_RELATIONSHIP;
        }
        else if (reportType.equalsIgnoreCase('DOMESTIC_CREDIT_DEBIT')){
            strTblName = Constants.CUSTOMER_RELATIONSHIP;
        }
        onChangeDate();
        reset();
    }

    private void reset(){
        tableDisplay = '';
        message = '';
        money = '';
        reportName = '';
        dcbReportWrapper = null;
        mapReportWrapper = new Map<String, ReportWrapper>();
        lstReportWrapper = new List<ReportWrapper>();
        mapCreditLocal = new Map<String, Decimal>();
        mapLocal = new Map<String, ReportLocal>();
        mapSubTotalLocal = new Map<String, ReportLocal>();
        grandTotalLocal = new ReportLocal();
        mapAnkenDetail = new Map<String, List<AnkenDetail>>();
        mapShowHideDetail = new Map<String, Boolean>();
        mapShowHideTable = new Map<String, Boolean>();
        mapTableAndDetail = new Map<String, List<String>>();
        reportCustomerDetail = new Map<String, List<DCB_ReportLineItem>>();
        mapShowHideDetailCustomer = new Map<String, Boolean>();
        mapTableAndDetailCustomer = new Map<String, List<String>>();
        mapShowHideTableCustomer = new Map<String, Boolean>();
    }
    
    public void onChangeDate(){
        if(!String.isBlank(sFromDate)){
            fromDate = DateTimeUtils.parseDate(sFromDate, '/');
        }
        else{
            fromDate = null;
        }
        if(!String.isBlank(sToDate)){
            toDate = DateTimeUtils.parseDate(sToDate, '/');
        }
        else{
            toDate = null;
        }
        lstName = new List<SelectOption>();
        Map<String, String> mapPrtVenName = getParnerVendorName(fromDate, toDate, reportType, strTblName);
        for(String key: mapPrtVenName.keySet()){
            lstName.add(new SelectOption(key, mapPrtVenName.get(key)));
        }
    }

    public void generateReport() {
        tableDisplay = '';
        message = '';
        money = '';
        reportName = '';
        mapReportWrapper = new Map<String, ReportWrapper>();
        lstReportWrapper = new List<ReportWrapper>();
        mapCreditLocal = new Map<String, Decimal>();
        mapLocal = new Map<String, ReportLocal>();
        mapSubTotalLocal = new Map<String, ReportLocal>();
        grandTotalLocal = new ReportLocal();
        mapAnkenDetail = new Map<String, List<AnkenDetail>>();
        mapShowHideDetail = new Map<String, Boolean>();
        mapShowHideTable = new Map<String, Boolean>();
        mapTableAndDetail = new Map<String, List<String>>();
        reportCustomerDetail = new Map<String, List<DCB_ReportLineItem>>();
        mapShowHideDetailCustomer = new Map<String, Boolean>();
        mapTableAndDetailCustomer = new Map<String, List<String>>();
        mapShowHideTableCustomer = new Map<String, Boolean>();

        List<AnkenMeisai__c> lstAnkenMeisei = new List<AnkenMeisai__c>();
        fromDate = DateTimeUtils.parseDate(sFromDate, '/');
        toDate = DateTimeUtils.parseDate(sToDate, '/');

        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()
                && PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleServiceMaster()) {
            if (reportType.equalsIgnoreCase('DOMESTIC') || reportType.equalsIgnoreCase('DOMESTIC_CREDIT_DEBIT')) {
                DCBReportService service = new DCBReportService();
                
                //dcbReportWrapper = service.generateGeneralReport(String.valueOf(fromDate), String.valueOf(toDate));
                
                if(reportType.equalsIgnoreCase('DOMESTIC')){
                    dcbReportWrapper = service.generateGeneralReportCustomer('',strNameId, String.valueOf(fromDate), String.valueOf(toDate), searchType);
                    reportCustomerDetail = service.generateGeneralReportCustomerDetail('',strNameId, String.valueOf(fromDate), String.valueOf(toDate), searchType);
                }else{
                    dcbReportWrapper = service.generateGeneralReportCustomerCreditDebit('',strNameId, String.valueOf(fromDate), String.valueOf(toDate), searchType);
                    reportCustomerDetail = service.generateGeneralReportCustomerCreditDebitDetail('',strNameId, String.valueOf(fromDate), String.valueOf(toDate), searchType);
                }
                
                isCustomer = false;
                for(String key : reportCustomerDetail.keySet()){
                    isCustomer = true;
                    mapShowHideDetailCustomer.put(key, false);
                    for(DCB_ReportLineItem rpItem : reportCustomerDetail.get(key)){
                        if(!mapTableAndDetailCustomer.containsKey(rpItem.customerName)){
                            mapTableAndDetailCustomer.put(rpItem.customerName, new List<String>());
                        }
                        if(!mapShowHideTableCustomer.containsKey(rpItem.customerName)){
                            mapShowHideTableCustomer.put(rpItem.customerName, false);
                        }
                        mapTableAndDetailCustomer.get(rpItem.customerName).add(rpItem.customerName + rpItem.wkid);
                    }
                }
                                
                if(reportType.equalsIgnoreCase('DOMESTIC')){
                    reportName = 'CUSTOMER INVOICE SUMMARY REPORT';
                    }else{
                    reportName = 'CUSTOMER DEBIT & CREDIT SUMMARY REPORT';
                }
                
            } else {
                String relationship = '';

                if (reportType.equalsIgnoreCase('Outstanding')) {
                    tableDisplay = 'Partner Name: ';
                    reportName = 'PARTNER OUTSTANDING STATEMENT REPORT';
                    relationship = Constants.PARTNER_RELATIONSHIP;
                } else if (reportType.equalsIgnoreCase('VENDOR')) {
                    tableDisplay = 'Vendor Name: ';
                    reportName = 'VENDOR OUTSTANDING STATEMENT REPORT';
                    relationship = Constants.VENDOR_RELATIONSHIP;
                }
                if(String.isBlank(strNameId)){
                    message = 'There is no data in this period';
                    //return null;
                }
                String soqlComm = generateSOQL(strNameId, fromDate, toDate, reportType, relationship);

                if (!StringUtils.isEmpty(soqlComm)) {
                    lstAnkenMeisei = Database.query(soqlComm);

                    if (!lstAnkenMeisei.isEmpty()) {
                        resultInUSD(lstAnkenMeisei, relationship);
                        
                        for(AnkenMeisai__c anken : lstAnkenMeisei){
                            String partName = '';
                            AnkenDetail ankenTemp = new AnkenDetail();
                            ankenTemp.anken = anken;
                            ankenTemp.debitLocal = anken.SellInTaxAmountJPY__c;
                            ankenTemp.debitUSD = anken.SellInTaxAmount_USD__c;
                            ankenTemp.creditLocal = anken.BuyInTaxAmountJPY__c;
                            ankenTemp.creditUSD = anken.BuyInTaxAmountUSD__c;
                            
                            String strSaleDate = String.valueOf(anken.SalesAccountedDate__c);
                            if(!String.isEmpty(strSaleDate)){
                                Date saleDate = anken.SalesAccountedDate__c;
                                strSaleDate = saleDate.day() + '/' + saleDate.month() + '/' + saleDate.year();
                            }
                            
                            if (relationship.equals(anken.Seikyusaki__r.Business_Relationship__c)
                                && anken.NyukinKakuninzumi__c == false
                                && (anken.UNPAID_BALANCE_OF_SELLING_USD__c != 0 || anken.SellDifferentiation__c != 0)) {
                                partName = anken.Seikyusaki__r.Name;
                                ankenTemp.creditLocal = 0;
                                ankenTemp.creditUSD = 0;
                                ankenTemp.balanceLocal = ankenTemp.debitLocal - ankenTemp.creditLocal;
                                ankenTemp.balanceUSD = ankenTemp.debitUSD - ankenTemp.creditUSD;
                                setResultInLocal(reportType, partName, anken.Anken__r.Name, anken.SellDifferentiation__c, 
                                                 0, strSaleDate);
                                        
                                if(!mapAnkenDetail.containsKey(reportType + partName + anken.Anken__r.Name)){
                                    mapAnkenDetail.put(reportType + partName + anken.Anken__r.Name, new List<AnkenDetail>());   
                                }
                                mapAnkenDetail.get(reportType + partName + anken.Anken__r.Name).add(ankenTemp); 
                            }
                
                            else if (relationship.equals(anken.PaymentTo__r.Business_Relationship__c)
                                    && anken.SiharaiKakuninzumi__c == false
                                    && (anken.UNPAID_BALANCE_OF_BUYING_USD__c != 0 || anken.BuyDifferentiation__c != 0)) {
                                partName = anken.PaymentTo__r.Name;
                                setResultInLocal(reportType, partName, anken.Anken__r.Name, 0, 
                                                 anken.BuyDifferentiation__c, strSaleDate);
                                ankenTemp.debitLocal = 0;
                                ankenTemp.debitUSD = 0;
                                ankenTemp.balanceLocal = ankenTemp.debitLocal - ankenTemp.creditLocal;
                                ankenTemp.balanceUSD = ankenTemp.debitUSD - ankenTemp.creditUSD;
                                if(!mapAnkenDetail.containsKey(reportType + partName + anken.Anken__r.Name)){
                                    mapAnkenDetail.put(reportType + partName + anken.Anken__r.Name, new List<AnkenDetail>());
                                }
                                mapAnkenDetail.get(reportType + partName + anken.Anken__r.Name).add(ankenTemp);        
                            }
  
                        }
                        
                    }
                    else{
                        
                    }

                    //Initiate grand value
                    grandDebit = 0;
                    grandCredit = 0;
                    grandBalance = 0;

                    convertMapToList();

                    if (lstReportWrapper.isEmpty()) {
                        message = 'There is no data in this period';
                    }
                }
                /// check exist
                isShowHideExist = false;
                isAnkenDetailExist = false;
                if(mapShowHideDetail.size() > 0){
                    isShowHideExist = true;
                }
                if(mapAnkenDetail.size() > 0){
                    isAnkenDetailExist = true;
                }
            }
        } else {
            message = 'Insufficient Permissions';
        }
    }
    
    private void setResultInLocal(String reportType, String partName, String ankenName, Decimal debit, Decimal credit, String dateSalesAccountDate){
        String keyLocal = reportType + partName + ankenName;
        String keySubTotal = reportType + partName;
        mapShowHideDetail.put(reportType + partName + ankenName, false);
        mapShowHideTable.put(reportType + partName, false);
        
        if(!mapTableAndDetail.containsKey(reportType + partName)){
            mapTableAndDetail.put(reportType + partName, new List<String>());
        }
        
        mapTableAndDetail.get(reportType + partName).add(reportType + partName + ankenName);
        
        if(!mapLocal.containsKey(keyLocal)){
            mapLocal.put(keyLocal, new ReportLocal());
        }
        mapLocal.get(keyLocal).creditLocal += credit;
        mapLocal.get(keyLocal).debitLocal += debit;
        mapLocal.get(keyLocal).balanceLocal = mapLocal.get(keyLocal).debitLocal - mapLocal.get(keyLocal).creditLocal;
        mapLocal.get(keyLocal).salesAccountedDate = dateSalesAccountDate;
        
        if(!mapSubTotalLocal.containsKey(keySubTotal)){
            mapSubTotalLocal.put(keySubTotal, new ReportLocal());
        }
        mapSubTotalLocal.get(keySubTotal).creditLocal += credit;
        mapSubTotalLocal.get(keySubTotal).debitLocal += debit;
        mapSubTotalLocal.get(keySubTotal).balanceLocal = mapSubTotalLocal.get(keySubTotal).debitLocal - mapSubTotalLocal.get(keySubTotal).creditLocal;
        
        grandTotalLocal.creditLocal += credit;
        grandTotalLocal.debitLocal += debit;
        grandTotalLocal.balanceLocal = grandTotalLocal.debitLocal - grandTotalLocal.creditLocal;
        
    }
    
    public void displayDetailTableName(){
        if (reportType.equalsIgnoreCase('DOMESTIC') ||reportType.equalsIgnoreCase('DOMESTIC_CREDIT_DEBIT')) 
        {
            if(!mapShowHideTableCustomer.isEmpty()){
                List<String> lstShow = new List<String>();
                for(String key : mapShowHideTableCustomer.keySet()){
                    lstShow = new List<String>();
                    lstShow = mapTableAndDetailCustomer.get(key);
                    if(mapShowHideTableCustomer.get(key) == true){
                        for(String detail : lstShow){
                            mapShowHideDetailCustomer.put(detail, true);
                        }
                    }else{
                        for(String detail : lstShow){
                            mapShowHideDetailCustomer.put(detail, false);
                        }
                    }
                }
            }
        }
        else{
            if(!mapShowHideTable.isEmpty()){
                List<String> lstShow = new List<String>();
                for(String key : mapShowHideTable.keySet()){
                    if(mapShowHideTable.get(key) == true){
                        lstShow = new List<String>();
                        lstShow = mapTableAndDetail.get(key);
                        for(String detail : lstShow){
                            mapShowHideDetail.put(detail, true);
                        }
                    }
                    else{
                        lstShow = new List<String>();
                        lstShow = mapTableAndDetail.get(key);
                        for(String detail : lstShow){
                            mapShowHideDetail.put(detail, false);
                        }
                    }
                }
            }
        }
        
    }

    public PageReference generateDetailReport() {
        PageReference detail;

        if (partnerName != null && pageType != null) {
            detailReportData = mapReportWrapper.get(EncodingUtil.urlDecode(partnerName, 'UTF-8'));

            if ('Outstanding'.equalsIgnoreCase(reportType) || 'VENDOR'.equalsIgnoreCase(reportType)) {
                if (pageType == 'excel') {
                    detail = Page.page_OutStandingStatementDetail;
                } else if (pageType == 'pdf') {
                    detail = Page.page_OutStandingStatementDetailPDF;
                }
            }
            
            String strLstWid = '';

            detail.setRedirect(true);

            detail.getParameters().put('partnerName', EncodingUtil.urlEncode(detailReportData.partnerName, 'UTF-8'));
            detail.getParameters().put('partnerENName', EncodingUtil.urlEncode(detailReportData.partnerEnglishName, 'UTF-8'));
            detail.getParameters().put('relationship', EncodingUtil.urlEncode(reportTypeBusinessRelationship.get(reportType), 'UTF-8'));
            detail.getParameters().put('currency', EncodingUtil.urlEncode(showType, 'UTF-8'));
            detail.getParameters().put('searchType', EncodingUtil.urlEncode(searchType, 'UTF-8'));
            String strWkid = '';
            if(!mapShowHideDetail.isEmpty()){
                for(String key : mapShowHideDetail.keySet()){
                    if(mapShowHideDetail.get(key) == true){
                        List<AnkenDetail> lstAnken = new List<AnkenDetail>();
                        lstAnken = mapAnkenDetail.get(key);
                        for(AnkenDetail item : lstAnken){
                            strWkid += item.anken.Id + ',';
                        }
                    }
                }
                strWkid = strWkid.removeEnd(',');
            }
            detail.getParameters().put('strWkid', EncodingUtil.urlEncode(strWkid, 'UTF-8'));

            if (toDate != null) {
                detail.getParameters().put('toDate', String.valueof(toDate));
            }
            if (fromDate != null) {
                detail.getParameters().put('fromDate', String.valueof(fromDate));
            }
        }

        return detail;
    }

    public List<SelectOption> getLanguages() {
        List<SelectOption> languages = new List<SelectOption>();
        languages.add(new SelectOption('en_US', 'English'));
        languages.add(new SelectOption('ja', '日本語'));
        languages.add(new SelectOption('vi', 'Tiếng Việt'));
        languages.add(new SelectOption('ko', '한국어'));

        return languages;
    }

    public List<SelectOption> getReportTypes() {
        List<SelectOption> reportTypes = new List<SelectOption>();
        reportTypes.add(new SelectOption('Outstanding', 'PARTNER OUTSTANDING STATEMENT REPORT'));
        reportTypes.add(new SelectOption('VENDOR', 'VENDOR OUTSTANDING STATEMENT REPORT'));
        reportTypes.add(new SelectOption('DOMESTIC', 'CUSTOMER INVOICE SUMMARY REPORT'));
        reportTypes.add(new SelectOption('DOMESTIC_CREDIT_DEBIT', 'CUSTOMER DEBIT & CREDIT SUMMARY REPORT'));

        return reportTypes;
    }
    
    public List<SelectOption> getSearchConditions(){
        List<SelectOption> searchConditions = new List<SelectOption>();
        searchConditions.add(new SelectOption('ETD', 'ETD'));
        searchConditions.add(new SelectOption('ETA', 'ETA'));
        searchConditions.add(new SelectOption('SHIPMENTORDER', 'SALES ACCOUNTED DATE (SHIPMENT ORDER)'));
        searchConditions.add(new SelectOption('INVOICING', 'SALES ACCOUNTED DATE (INVOICING)'));
        
        return searchConditions;
    }
    
    public List<SelectOption> getShowTypes(){
        List<SelectOption> showTypes = new List<SelectOption>();
        showTypes.add(new SelectOption('USD', 'USD currency'));
        showTypes.add(new SelectOption('VND', 'VND currency'));
        showTypes.add(new SelectOption('Both', 'Both currency'));
        return showTypes;
    }

    private void convertMapToList() {
        if (!mapReportWrapper.isEmpty()) {
            for (String item : mapReportWrapper.keySet()) {
                grandDebit += mapReportWrapper.get(item).totalDebit;
                grandCredit += mapReportWrapper.get(item).totalCredit;
                grandBalance += mapReportWrapper.get(item).totalBalance;
                lstReportWrapper.add(mapReportWrapper.get(item));
            }

        }
    }
    
    private Map<String, String> getParnerVendorName(Date fromDate, Date toDate, String reportType, String relationship) {
        String soqlComm = '';
        String soqlCus = '';
        String filter = '';
        Map<String, String> mapPVName = new Map<String, String>();
        String strStatus = '\'' + PicklistReference.CANCELLED_ST + '\','
                        + '\'' + PicklistReference.COMPLETED_ST + '\','
                        + '\'' + PicklistReference.TEMPORARY_UNLOCK_FOR_ACCOUNTING_PURPOSE_ST + '\'';
        if (reportType != null) {
            List<AnkenMeisai__c> lstAnken = new List<AnkenMeisai__c>();
            if (reportType.equalsIgnoreCase('DOMESTIC') || reportType.equalsIgnoreCase('DOMESTIC_CREDIT_DEBIT')){
                Map<String, Id> mapRT = new Map<String, Id>();
                String objectName = Constants.NAMESPACE + 'CustomObject1__c';
                List<RecordType> recordTypes = [
                        SELECT Id, DeveloperName
                        FROM RecordType
                        WHERE SObjectType = :objectName AND IsActive = True
                ];
                for (RecordType rt : recordTypes) {
                    mapRT.put(rt.DeveloperName, rt.Id);
                }
                String strShipmentRT = '';
                
                if(mapRT.get(Constants.QUOTATION_RT) != null){
                    strShipmentRT += '\'' + mapRT.get(Constants.QUOTATION_RT) + '\',';
                }
                if(mapRT.get(Constants.OCEAN_EXPORT_LOCK_RT) != null){
                    strShipmentRT += '\'' + mapRT.get(Constants.OCEAN_EXPORT_LOCK_RT) + '\',';
                }
                if(mapRT.get(Constants.AIR_EXPORT_LOCK_RT) != null){
                    strShipmentRT += '\'' + mapRT.get(Constants.AIR_EXPORT_LOCK_RT) + '\',';
                }
                if(mapRT.get(Constants.AIR_IMPORT_LOCK_RT) != null){
                    strShipmentRT += '\'' + mapRT.get(Constants.AIR_IMPORT_LOCK_RT) + '\',';
                }
                if(mapRT.get(Constants.OCEAN_IMPORT_LOCK_RT) != null){
                    strShipmentRT += '\'' + mapRT.get(Constants.OCEAN_IMPORT_LOCK_RT) + '\',';
                }
                
                if(!String.isBlank(strShipmentRT)){
                    strShipmentRT = '(' + strShipmentRT.removeEnd(',') + ')';
                }
                
                
                String excludedStatuses = '(\'' + PicklistReference.COMPLETED_ST + '\''
                                        + ',\'' + PicklistReference.CANCELLED_ST + '\')';
                soqlCus = ' SELECT Seikyusaki__c sei, Seikyusaki__r.Name name '
                            + ' FROM AnkenMeisai__c '
                            + ' WHERE NyukinKakuninzumi__c = false '
                            + ' AND Anken__r.RecordTypeId NOT IN ' + strShipmentRT
                            + ' AND Anken__r.Status__c NOT IN ' + excludedStatuses
                            + ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
            }else{
                soqlComm = ' SELECT Seikyusaki__r.Name, PaymentTo__r.Name, PaymentTo__c, Seikyusaki__c, Anken__r.ID__c, '
                        + ' Seikyusaki__r.Business_Relationship__c, NyukinKakuninzumi__c, '
                        + ' UNPAID_BALANCE_OF_SELLING_USD__c, SellDifferentiation__c, '
                        + ' PaymentTo__r.Business_Relationship__c, SiharaiKakuninzumi__c, '
                        + ' UNPAID_BALANCE_OF_BUYING_USD__c, BuyDifferentiation__c '
                        + ' FROM AnkenMeisai__c  '
                        + ' WHERE Anken__r.RecordType.DeveloperName != \'Quotation\' '
                        + ' AND ((PaymentTo__r.Business_Relationship__c = \'' + relationship + '\' '
                        + ' AND SiharaiKakuninzumi__c = false '
                        + ' AND (UNPAID_BALANCE_OF_BUYING_USD__c != 0 OR BuyDifferentiation__c != 0)) '
                        + ' OR (Seikyusaki__r.Business_Relationship__c = \'' + relationship + '\' '
                        + ' AND NyukinKakuninzumi__c = false '
                        + ' AND (UNPAID_BALANCE_OF_SELLING_USD__c != 0 OR SellDifferentiation__c != 0))) '
                        + ' AND Anken__r.status__c NOT IN (' + strStatus + ') ';
            }            
            if (fromDate != null && toDate != null) {
                if (fromDate <= toDate) {
                    if(searchType.equals('ETD')){
                        filter = ' AND (Anken__r.ETD__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate) + ')';
                    }
                    else if(searchType.equals('ETA')){
                        filter = ' AND (Anken__r.ETA__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate) + ')';
                    }
                    else if(searchType.equals('SHIPMENTORDER')){
                        filter = ' AND (Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate) + ')';
                    }
                    else if(searchType.equals('INVOICING')){
                        filter = ' AND (SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate) + ')';
                    }
                    
                }
            } else if (fromDate != null && toDate == null) {
                //filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
                if(searchType.equals('ETD')){
                    filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
                }
                else if(searchType.equals('ETA')){
                    filter = ' AND Anken__r.ETA__c >= ' + String.valueOf(fromDate);
                }
                else if(searchType.equals('SHIPMENTORDER')){
                    filter = ' AND Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate);
                }
                else if(searchType.equals('INVOICING')){
                    filter = ' AND SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate);
                }
            } else if (fromDate == null && toDate != null) {
                //filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
                if(searchType.equals('ETD')){
                    filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
                }
                else if(searchType.equals('ETA')){
                    filter = ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate);
                }
                else if(searchType.equals('SHIPMENTORDER')){
                    filter = ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate);
                }
                else if(searchType.equals('INVOICING')){
                    filter = ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate);
                }
            }
    
            if (filter != '') {
                soqlComm += filter;
                soqlCus += filter;
            }
            soqlComm += ' LIMIT 10000 ';
            soqlCus += ' GROUP BY Seikyusaki__c, Seikyusaki__r.Name LIMIT 10000 ';
            
            if (reportType.equalsIgnoreCase('DOMESTIC') || reportType.equalsIgnoreCase('DOMESTIC_CREDIT_DEBIT')) {
                List<AggregateResult> lstAgg = new List<AggregateResult>();
                lstAgg = Database.query(soqlCus);
                for(AggregateResult agg : lstAgg){
                    mapPVName.put((String) agg.get('sei'), (String)  agg.get('name'));
                }
            }else{
                lstAnken = Database.query(soqlComm);
                for(AnkenMeisai__c item : lstAnken){
                    if (relationship.equals(item.Seikyusaki__r.Business_Relationship__c)
                        && item.NyukinKakuninzumi__c == false
                        && (item.UNPAID_BALANCE_OF_SELLING_USD__c != 0 || item.SellDifferentiation__c != 0)) {
                            mapPVName.put(item.Seikyusaki__c, item.Seikyusaki__r.Name);
                        }
                    else if (relationship.equals(item.PaymentTo__r.Business_Relationship__c)
                        && item.SiharaiKakuninzumi__c == false
                        && (item.UNPAID_BALANCE_OF_BUYING_USD__c != 0 || item.BuyDifferentiation__c != 0)) {
                            mapPVName.put(item.PaymentTo__c, item.PaymentTo__r.Name);
                        }
                }
            }
            
            
            
        }
        return mapPVName;
    }

    private String generateSOQL(String strNameId, Date fromDate, Date toDate, String reportType, String relationship) {
        String soqlComm = '';
        String filter = '';

        if (reportType != null) {
            money = 'USD';

            soqlComm = 'SELECT Id, Name, PartnerSeisan__c, Anken__r.partnerSeisanTani__c, BuyDifferentiation__c, SellDifferentiation__c, ' +
                    '   Anken__r.Name, Anken__r.HBL_Number_Sea_Air__c, Anken__r.MBL_Number_Sea_Air__c, Anken__r.ETD__c, Anken__r.ID__c, ' +
                    '   Anken__r.Status__c, Anken__r.ETA__c, PaymentTo__r.EnglishCompanyName__c, Seikyusaki__r.EnglishCompanyName__c, ' +
                    '   PaymentTo__r.Business_Relationship__c, PaymentTo__r.Name, Seikyusaki__r.Business_Relationship__c, Seikyusaki__r.Name, ' +
                    '   UNPAID_BALANCE_OF_BUYING_USD__c, UNPAID_BALANCE_OF_SELLING_USD__c, SiharaiKakuninzumi__c, NyukinKakuninzumi__c, ' + 
                    '   SalesAccountedDate__c, SalesAccountedDateInvoicing__c, InsatuyouSyohin__c, Seikyusaki__c, PaymentTo__c, ' + 
                    '   Description__c, Suryo__c, SellInTaxAmount_USD__c, SellInTaxAmountJPY__c, BuyInTaxAmountUSD__c, BuyInTaxAmountJPY__c ' + 
                    '   FROM AnkenMeisai__c ' +
                    ' WHERE Anken__r.RecordType.DeveloperName != \'Quotation\'' +
                    '   AND ((PaymentTo__r.Business_Relationship__c = \'' + relationship + '\'' +
                    '           AND SiharaiKakuninzumi__c = false AND (UNPAID_BALANCE_OF_BUYING_USD__c != 0 OR BuyDifferentiation__c != 0))' +
                    '       OR (Seikyusaki__r.Business_Relationship__c = \'' + relationship + '\'' +
                    '           AND NyukinKakuninzumi__c = false AND (UNPAID_BALANCE_OF_SELLING_USD__c != 0 OR SellDifferentiation__c != 0)))' +
                    '   AND Anken__r.status__c NOT IN (\'' + PicklistReference.CANCELLED_ST + '\',' +
                    '       \'' + PicklistReference.COMPLETED_ST + '\',' +
                    '       \'' + PicklistReference.TEMPORARY_UNLOCK_FOR_ACCOUNTING_PURPOSE_ST + '\')';
        }
        
        if(!String.isBlank(strNameId)){
            soqlComm += ' AND (PaymentTo__c IN (\''+ String.escapeSingleQuotes(strNameId) + '\') OR Seikyusaki__c IN (\''+ String.escapeSingleQuotes(strNameId) + '\'))';
        }

        if (fromDate != null && toDate != null) {
            if (fromDate <= toDate) {
                if(searchType.equals('ETD')){
                    filter = ' AND (Anken__r.ETD__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(searchType.equals('ETA')){
                    filter = ' AND (Anken__r.ETA__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(searchType.equals('SHIPMENTORDER')){
                    filter = ' AND (Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(searchType.equals('INVOICING')){
                    filter = ' AND (SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate) + ')';
                }
                
            } else {
                message = 'Error: The To Date must be greater then From Date';
                return null;
            }
        } else if (fromDate != null && toDate == null) {
            //filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
            if(searchType.equals('ETD')){
                filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
            }
            else if(searchType.equals('ETA')){
                filter = ' AND Anken__r.ETA__c >= ' + String.valueOf(fromDate);
            }
            else if(searchType.equals('SHIPMENTORDER')){
                filter = ' AND Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate);
            }
            else if(searchType.equals('INVOICING')){
                filter = ' AND SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate);
            }
        } else if (fromDate == null && toDate != null) {
            //filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
            if(searchType.equals('ETD')){
                filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
            }
            else if(searchType.equals('ETA')){
                filter = ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate);
            }
            else if(searchType.equals('SHIPMENTORDER')){
                filter = ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate);
            }
            else if(searchType.equals('INVOICING')){
                filter = ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate);
            }
        }

        if (filter != '') {
            soqlComm += filter;
        }
        
        soqlComm += ' ORDER BY PartnerSeisan__c, Anken__r.Name  LIMIT 10000 ';
        return soqlComm;
    }

    private void resultInUSD(List<AnkenMeisai__c> lstAnkenMeisei, String relationship) {
        for (AnkenMeisai__c item : lstAnkenMeisei) {
            String strEtd = String.valueof(item.Anken__r.ETD__c);
            String strEta = String.valueof(item.Anken__r.ETA__c);
            if(!String.isEmpty(strEtd)){
                Date etd = item.Anken__r.ETD__c;
                strEtd = etd.day() + '/' + etd.month() + '/' + etd.year();
            }
            if(!String.isEmpty(strEta)){
                Date eta = item.Anken__r.ETA__c;
                strEta = eta.day() + '/' + eta.month() + '/' + eta.year();
            }
            if (relationship.equals(item.Seikyusaki__r.Business_Relationship__c)
                    && item.NyukinKakuninzumi__c == false
                    && (item.UNPAID_BALANCE_OF_SELLING_USD__c != 0 || item.SellDifferentiation__c != 0)) {
                addToReportWrapper(item.Seikyusaki__r.Name, item.Seikyusaki__r.EnglishCompanyName__c, item.Anken__r.partnerSeisanTani__c,
                        item.UNPAID_BALANCE_OF_SELLING_USD__c, 0,
                        item.Anken__r.Name, item.Anken__r.HBL_Number_Sea_Air__c,
                        item.Anken__r.MBL_Number_Sea_Air__c, strEta, strEtd, item.Anken__r.status__c, item.Anken__c, 
                        item.Anken__r.ID__c);
            }

            else if (relationship.equals(item.PaymentTo__r.Business_Relationship__c)
                    && item.SiharaiKakuninzumi__c == false
                    && (item.UNPAID_BALANCE_OF_BUYING_USD__c != 0 || item.BuyDifferentiation__c != 0)) {
                addToReportWrapper(item.PaymentTo__r.Name, item.PaymentTo__r.EnglishCompanyName__c, item.Anken__r.partnerSeisanTani__c,
                        0, item.UNPAID_BALANCE_OF_BUYING_USD__c,
                        item.Anken__r.Name, item.Anken__r.HBL_Number_Sea_Air__c,
                        item.Anken__r.MBL_Number_Sea_Air__c, strEta, strEtd, item.Anken__r.status__c, item.Anken__c, 
                        item.Anken__r.ID__c);
            }
        }
    }

    private void addToReportWrapper(String partnerName, String partnerEnglishName, String stid, Decimal debit, Decimal credit,
            String wkid, String hbl, String mbl, String eta, String etd, String status, String hblId, String sisid) {
        ReportWrapper wrapper = new ReportWrapper();

        if (mapReportWrapper.containsKey(partnerName)) {
            wrapper = mapReportWrapper.get(partnerName);
        } else {
            wrapper.partnerName = partnerName;
            wrapper.partnerEnglishName = partnerEnglishName;
            mapReportWrapper.put(partnerName, wrapper);
        }

        wrapper.setPartnerData(stid, debit, credit, wkid, hbl, mbl, eta, etd, status, hblId, sisid);
    }

    public PageReference generateCustomerReport() {
        PageReference reportPage = null;

        if (StringUtils.isEmpty(selectedLanguage)) {
            selectedLanguage = 'en_US';
        }

        if ('pdf'.equals(pageType)) {
            reportPage = reportMappingPDF.get(selectedLanguage);
        } else if ('excel'.equals(pageType)) {
            reportPage = reportMappingExcel.get(selectedLanguage);
        }

        reportPage.getParameters().put('fromDate', String.valueof(fromDate));
        reportPage.getParameters().put('toDate', String.valueof(toDate));
        reportPage.getParameters().put('customerId', customerId);
        reportPage.getParameters().put('customerName', customerName);
        reportPage.getParameters().put('customerENName', customerENName);
        reportPage.getParameters().put('reportOption', reportOption);
        reportPage.getParameters().put('currencyType', showType);
        reportPage.getParameters().put('searchType', searchType);
        reportPage.getParameters().put('reportType', reportType);
        String strWkid = '';
        if(!mapShowHideDetailCustomer.isEmpty()){
            for(String key : mapShowHideDetailCustomer.keySet()){
                if(mapShowHideDetailCustomer.get(key) == true){
                    List<DCB_ReportLineItem> lstAnken = new List<DCB_ReportLineItem>();
                    lstAnken = reportCustomerDetail.get(key);
                    for(DCB_ReportLineItem item : lstAnken){
                        strWkid += item.id + ',';
                    }
                }
            }
            strWkid = strWkid.removeEnd(',');
        }
        reportPage.getParameters().put('strWkid', strWkid);

        reportPage.setRedirect(true);

        return reportPage;
    }

    public void updateLanguage() {
        /**
         * Just to get the selected language from VF page updated back to the controller
         * so that the commandLink with parameter can incorporate its parameters with
         * selected language for DCB report
         */
    }
    
    public class ReportLocal{
        public Decimal creditLocal {get; set;}
        public Decimal debitLocal {get; set;}
        public Decimal balanceLocal {get; set;}
        public String salesAccountedDate {get; set;}
        public ReportLocal(){
            this.creditLocal = 0;
            this.debitLocal = 0;
            this.balanceLocal = 0;
            this.salesAccountedDate = '';
        }
        
        public ReportLocal(Decimal dmlCredit, Decimal dmlDebit, Decimal dmlBalance, String strSalesAccountedDate){
            this.creditLocal = dmlCredit;
            this.debitLocal = dmlDebit;
            this.balanceLocal = dmlBalance;
            this.salesAccountedDate = strSalesAccountedDate;
        }
    }
    
    public class AnkenDetail{
        public AnkenMeisai__c anken {get; set;}
        public Decimal debitUSD {get; set;}
        public Decimal debitLocal {get; set;}
        public Decimal creditUSD {get; set;}
        public Decimal creditLocal {get; set;}
        public Decimal balanceUSD {get; set;}
        public Decimal balanceLocal {get; set;}
        public AnkenDetail(){
            this.anken = new AnkenMeisai__c();
            this.debitUSD = 0;
            this.debitLocal = 0;
            this.creditUSD = 0;
            this.creditLocal = 0;
            this.balanceUSD = 0;
            this.balanceLocal = 0;
        }
        public AnkenDetail(AnkenMeisai__c objAnken, Decimal dmlDebitUSD, Decimal dmlDebitLocal, 
                           Decimal dmlCreditUSD, Decimal dmlCreditLocal, Decimal dmlBalanceUSD, Decimal dmlBanlanceLocal){
            this.anken = objAnken;
            this.debitUSD = dmlDebitUSD;
            this.debitLocal = dmlDebitLocal;
            this.creditUSD = dmlCreditUSD;
            this.creditLocal = dmlCreditLocal;
            this.balanceUSD = dmlBalanceUSD;
            this.balanceLocal = dmlBanlanceLocal;
        }
    }
}