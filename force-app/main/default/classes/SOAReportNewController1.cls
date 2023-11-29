public with sharing class SOAReportNewController1 {
    public String reportType {get;set;}
    public String language  {get;set;}
    public String searchCondition {get;set;}
    public String currencyLocal {get;set;}
    public Date fromDate {get;set;}
    public Date toDate {get;set;}
    public String sFromDate { get; set; }
    public String sToDate { get; set; }
    public String currencyType{ get; set;}
    public String accountType{get; set;}
    public String businessRelationship{get; set;}
    public String accountId{get; set;}
    public List<SelectOption> accountList{get; set;}
    public String message{get; set;}
    public ReportWrapper report{get; set;}
    public Boolean displayReportTable{get; set;}
    public String advancePaymentType{get; set;}
    public String docType{get; set;}
    public String isPrint{get; set;}
    public String period{get;set;}
    public Boolean isDisplayDetail{get;set;}
    public static List<String> ankenIdList = new List<String>();
    public String ankenIds{get;set;}
    public String bankType{get;set;}
	private static Site_Custom_Settings__c  siteCustomSetting = Site_Custom_Settings__c.getInstance ();
    private static Set<String> selectFields = new Set<String>();
    private static Set<String> excludeAnKenRecordTypes = new Set<String>();
    private static Set<String> excludeStatuses = new Set<String>();
    private static Map<String, String> reportTypeBusinessRelationship = new Map<String, String>();
    private static Map<String, List<AnkenMeisai__c>> billingByClientMap = new Map<String, List<AnkenMeisai__c>>();
    public Boolean showJobId{get;set;}
    public Boolean showWKID{get;set;}

    private static final String USD = 'USD';
    private static final String VND = 'VND';
    private static final String PHP = 'PHP';
    private static final String EUR = 'EUR';
    private static final String KHR = 'KHR';
    private static final String JPY	 = 'JPY';
    private static final String KRW = 'KRW';

    static {
        selectFields.add('Anken__r.Field1__r.Name');
        selectFields.add('Anken__r.Field1__r.PaidDay__c');
        selectFields.add('Anken__r.Field1__r.PaidDayAdvance__c');
        selectFields.add('Anken__r.Name');
        selectFields.add('Anken__r.ID__c');
        selectFields.add('Anken__r.JobRequestID__c');
        selectFields.add('Anken__r.WkInitial__c');
        selectFields.add('Anken__r.QuotationVer__c');
        selectFields.add('Anken__c');
        selectFields.add('Anken__r.HBL_Number_Sea_Air__c');
        selectFields.add('Anken__r.MBL_Number_Sea_Air__c');
        selectFields.add('Anken__r.ETD__c');
        selectFields.add('Anken__r.ETA__c');
        selectFields.add('Anken__r.Ship_number__c');
        selectFields.add('Anken__r.DeadlineForPaymentOfInvoices__c');
        selectFields.add('Anken__r.DeadlineForPaymentOfExpense__c');
        selectFields.add('Anken__r.DeliveryDate__c');
        selectFields.add('Anken__r.carton__c');
        selectFields.add('Anken__r.Status__c');
        selectFields.add('UNPAID_BALANCE_OF_BUYING_USD__c');
        selectFields.add('BuyDifferentiation__c');
        selectFields.add('SellDifferentiation__c');
        selectFields.add('UNPAID_BALANCE_OF_SELLING_USD__c');
        selectFields.add('curr__c');
        selectFields.add('CurrencyBuying__c');
        selectFields.add('ProductTax__c');
        selectFields.add('SellInTaxAmountJPY__c'); // AMMOUNT SELLING INCLUDING TAX
        selectFields.add('Id');
        selectFields.add('Seikyusaki__r.Name');
        selectFields.add('Seikyusaki__r.EnglishCompanyName__c');
        selectFields.add('PartnerDebitJPN__c');
        selectFields.add('PartnerCreditJPN__c');
        selectFields.add('PartnerSeisanJPY__c');
        selectFields.add('Anken__r.SeikyusyoRemark__c');
        selectFields.add('Suryo__c');
        selectFields.add('SellTankaJPY__c');
        selectFields.add('TaxInitial__c');
        selectFields.add('TAX_ADJUSTMENTSELL__c');
        selectFields.add('Nyukingaku__c');
        selectFields.add('Siharaigaku__c');
        selectFields.add('SalesAccountedDate__c');
        selectFields.add('SalesAccountedDateInvoicing__c');
        selectFields.add('BuyTankaJPY__c');
        selectFields.add('BuyTaxInitial__c');
        selectFields.add('Cost_Allocation_Margin__c');
        selectFields.add('BuyTankaUSD__c');
        selectFields.add('SellTankaUSD__c');
        selectFields.add('AMOUNT_PAID_SELLING_USD__c');
        selectFields.add('PartnerCredit__c');
        selectFields.add('PartnerDebit__c');
        selectFields.add('PartnerSeisanUSD__c');
        selectFields.add('InsatuyouSyohin__c');
        selectFields.add('PaymentTo__r.Name');
        selectFields.add('Description__c');
        selectFields.add('Name');
        selectFields.add('BuyAmountUSD__c');
        selectFields.add('SellAmountUSD__c');
        selectFields.add('SellInTaxAmount_USD__c');
        selectFields.add('BuyInTaxAmountJPY__c');
        selectFields.add('BuyInTaxAmountUSD__c');

        selectFields.add('NyukinKakuninzumi__c');
        selectFields.add('SiharaiKakuninzumi__c');
        selectFields.add('PaymentTo__r.Business_Relationship__c');
        selectFields.add('Seikyusaki__r.Business_Relationship__c');
        selectFields.add('PaymentTo__r.EnglishCompanyName__c');
        selectFields.add('Seikyusaki__r.EnglishCompanyName__c');
        selectFields.add('InsatuyouSyohinEng__c');
        selectFields.add('Anken__r.SalesAccountedDate__c');
        selectFields.add('Anken__r.HBL__c');
        selectFields.add('Anken__r.Master_B_L__c');
        selectFields.add('Anken__r.DeadlineForPaymentOfInvoices__c');
        selectFields.add('Anken__r.InvoiceIssueStatus__c');
        selectFields.add('Anken__r.DebitIssueStatus__c');
        selectFields.add('OutboundVATInvNo__c');
        selectFields.add('InboundVATInvNo__c');
        selectFields.add('AdvancePaymentOnBehalfOfOurCompany__c');
        selectFields.add('ADVANCE_PAYMENT_ON_BEHALF_OF__c');
         
    }

    public SOAReportNewController1() {
        Site_Custom_Settings__c objSiteCustomSettings = Site_Custom_Settings__c.getOrgDefaults();
        if (String.isNotBlank(objSiteCustomSettings.Id)) {
        	currencyLocal = objSiteCustomSettings.Local_Currency__c;
        }
        advancePaymentType = 'All';
        //language = UserInfo.getLanguage();
        language = 'en_US';
        reportType = 'partner_report_type';
        accountType = 'partner';
        currencyType = currencyLocal;
        bankType = 'local1';
        isDisplayDetail = false;
        businessRelationship = Constants.PARTNER_RELATIONSHIP;
        showJobId = false;
        showWKID = false;
        
        accountList = getAccountList();
        reportTypeBusinessRelationship.put('partner_report_type', Constants.PARTNER_RELATIONSHIP);
        reportTypeBusinessRelationship.put('custommer_report_type', Constants.CUSTOMER_RELATIONSHIP);
        reportTypeBusinessRelationship.put('customer_credit_debit_report_type', Constants.CUSTOMER_RELATIONSHIP);
        reportTypeBusinessRelationship.put('vender_report_type', Constants.VENDOR_RELATIONSHIP);
        //AccountList();
        reset();
        // print report
        accountId = ApexPages.currentPage().getParameters().get('clientId');
        period = '';
        if(!String.isBlank(accountId)){
            advancePaymentType = ApexPages.currentPage().getParameters().get('advancePaymentType');
            sFromDate = ApexPages.currentPage().getParameters().get('fromDate');
            sToDate = ApexPages.currentPage().getParameters().get('toDate');
            reportType = ApexPages.currentPage().getParameters().get('reportType');
            currencyType = ApexPages.currentPage().getParameters().get('currency');
            bankType = ApexPages.currentPage().getParameters().get('bank');
            searchCondition = ApexPages.currentPage().getParameters().get('condition');
            language = ApexPages.currentPage().getParameters().get('language');
            showWKID = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showWKID'));
            showJobId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showJobId'));
            String ankenIds = ApexPages.currentPage().getParameters().get('ankenIds');

            if(!String.isBlank(ankenIds)){
                isDisplayDetail = true;
                ankenIdList = ankenIds.split(',');
            }
            report = new ReportWrapper();
            onChangeDateFrom();
            onChangeDateTo();
            generateReport();
        }
        
    }

    private void reset(){
        language = 'en_US';
        message = '';
        sFromDate = '';
        sToDate = '';
        fromDate = null;
        toDate = null;
        searchCondition = 'ETD';
        currencyType = currencyLocal;
        bankType = 'local1';
        report = new ReportWrapper();
        accountId = '';
        displayReportTable = false;
        if(reportType == 'partner_report_type'){
            report.clientType = 'Partner Name';
        }
        if(reportType == 'vender_report_type'){
            report.clientType = 'Vender Name';
        }
        if(reportType == 'customer_report_type' || reportType == 'customer_credit_debit_report_type'){
            report.clientType = 'Customer Name';
        }
        
    }

    public Map<String, String > getTranslations(){

        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('soa')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
    
    public List<SelectOption> getBankOptions(){
        clofor_com_cfs__Site_Custom_Settings__c banks = [Select clofor_com_cfs__LocalCurrencyBankAccountShortName1__c,
                                                         clofor_com_cfs__LocalCurrencyBankAccountShortName2__c,
                                                         clofor_com_cfs__LocalCurrencyBankAccountShortName3__c,
                                                         clofor_com_cfs__LocalCurrencyBankAccountShortName4__c,
                                                         clofor_com_cfs__LocalCurrencyBankAccountShortName5__c,
                                                         clofor_com_cfs__FCYBankAccountShortName1__c,
                                                         clofor_com_cfs__FCYBankAccountShortName2__c,
                                                         clofor_com_cfs__FCYBankAccountShortName3__c,
                                                        clofor_com_cfs__FCYBankAccountShortName4__c,
                                                        clofor_com_cfs__FCYBankAccountShortName5__c
                                                         From clofor_com_cfs__Site_Custom_Settings__c limit 1];
        List<SelectOption> bankOptions = new List<SelectOption>();
        // value, title
        if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName1__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName1__c != ''){
            bankOptions.add(new SelectOption('local1', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName1__c));
        }
        if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName2__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName2__c != ''){
            bankOptions.add(new SelectOption('local2', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName2__c));
        }
        if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName3__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName3__c != ''){
            bankOptions.add(new SelectOption('local3', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName3__c));
        }
        if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName4__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName4__c != ''){
            bankOptions.add(new SelectOption('local4', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName4__c));
        }
        if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName5__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName5__c != ''){
            bankOptions.add(new SelectOption('local5', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName5__c));
        }
        if(banks.clofor_com_cfs__FCYBankAccountShortName1__c != null && banks.clofor_com_cfs__FCYBankAccountShortName1__c != ''){
            bankOptions.add(new SelectOption('foreign1', banks.clofor_com_cfs__FCYBankAccountShortName1__c));
        }        
        if(banks.clofor_com_cfs__FCYBankAccountShortName2__c != null && banks.clofor_com_cfs__FCYBankAccountShortName2__c != ''){
            bankOptions.add(new SelectOption('foreign2', banks.clofor_com_cfs__FCYBankAccountShortName2__c));
        }
        if(banks.clofor_com_cfs__FCYBankAccountShortName3__c != null && banks.clofor_com_cfs__FCYBankAccountShortName3__c != ''){
            bankOptions.add(new SelectOption('foreign3', banks.clofor_com_cfs__FCYBankAccountShortName3__c));
        }
        if(banks.clofor_com_cfs__FCYBankAccountShortName4__c != null && banks.clofor_com_cfs__FCYBankAccountShortName4__c != ''){
            bankOptions.add(new SelectOption('foreign4', banks.clofor_com_cfs__FCYBankAccountShortName4__c));
        }
        if(banks.clofor_com_cfs__FCYBankAccountShortName5__c != null && banks.clofor_com_cfs__FCYBankAccountShortName5__c != ''){
            bankOptions.add(new SelectOption('foreign5', banks.clofor_com_cfs__FCYBankAccountShortName5__c));
        }
        return bankOptions;
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
        reportTypes.add(new SelectOption('partner_report_type', 'PARTNER OUTSTANDING STATEMENT REPORT'));
        reportTypes.add(new SelectOption('vender_report_type', 'VENDOR OUTSTANDING STATEMENT REPORT'));
        //reportTypes.add(new SelectOption('custommer_report_type', 'CUSTOMER INVOICE SUMMARY REPORT'));
        reportTypes.add(new SelectOption('customer_credit_debit_report_type', 'CUSTOMER DEBIT & CREDIT SUMMARY REPORT'));

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
    public List<SelectOption> getCurrencies(){
        String Local = '';
        Site_Custom_Settings__c objSiteCustomSettings = Site_Custom_Settings__c.getOrgDefaults();
        if (String.isNotBlank(objSiteCustomSettings.Id)) {
        	Local = objSiteCustomSettings.Local_Currency__c;
        }
        List<SelectOption> currencies = new List<SelectOption>();
        currencies.add(new SelectOption(Local, 'Local'));
        if (Local != USD){
        	currencies.add(new SelectOption(USD, USD));
        }
        if (Local != VND){
        	currencies.add(new SelectOption(VND, VND));
        }
        if (Local != PHP){
        	currencies.add(new SelectOption(PHP, PHP));
        }
        if (Local != EUR){
        	currencies.add(new SelectOption(EUR, EUR));
        }
        if (Local != JPY){
        	currencies.add(new SelectOption(JPY, JPY));
        }
        if (Local != KHR){
        	currencies.add(new SelectOption(KHR, KHR));
        }
        if (Local != KRW){
        	currencies.add(new SelectOption(KRW, KRW));
        }
        return currencies;
    }
    public List<SelectOption> getAdvancePaymentTypes(){
        List<SelectOption> types = new List<SelectOption>();
        types.add(new SelectOption('All', 'All'));
        types.add(new SelectOption('No', 'No'));
        types.add(new SelectOption('Both', 'Both'));
        types.add(new SelectOption('Customer', 'On-behalf-of Customer'));
        types.add(new SelectOption('OurCompany', 'On-behalf-of Our Company'));
        return types;
    }

    public List<SelectOption> getAccountList(){
        //excludeAnKenRecordTypes = getExcludeAnKenRecordTypes();
        List<SelectOption> accounts = new List<SelectOption>();
        List<AnkenMeisai__c> listBillings = new List<AnkenMeisai__c>();
        String strQuery = buildQueryClient(null);
		System.debug('THAO query ' + strQuery);
        listBillings = Database.query(strQuery);
        System.debug('THAO listBillings ' + listBillings.size() + ' ' + reportType + ' ' + businessRelationship);

        Set<Id> accountIds = new Set<Id>();
        for(AnkenMeisai__c result : listBillings){
            if(!String.isBlank(result.Seikyusaki__c)
               && !accountIds.contains(result.Seikyusaki__c)
               && !result.NyukinKakuninzumi__c
               && result.Seikyusaki__r.Business_Relationship__c == businessRelationship){
                   accounts.add(new SelectOption(result.Seikyusaki__c, result.Seikyusaki__r.Name));
                   accountIds.add(result.Seikyusaki__c);
               }
            else if(!String.isBlank(result.PaymentTo__c)
                    && !accountIds.contains(result.PaymentTo__c)
                    && !result.SiharaiKakuninzumi__c
                    && result.PaymentTo__r.Business_Relationship__c == businessRelationship){
                        accounts.add(new SelectOption(result.PaymentTo__c, result.PaymentTo__r.Name));
                        accountIds.add(result.PaymentTo__c);
                    }
            //accountIds.add(result.Seikyusaki__c);
            
            /*if(reportType == 'custommer_report_type' || reportType == 'customer_credit_debit_report_type'
                || reportType == 'partner_report_type'){
                if(!String.isBlank(result.Seikyusaki__c)
                    && !accountIds.contains(result.Seikyusaki__c)
                    && !result.NyukinKakuninzumi__c
                    && result.Seikyusaki__r.Business_Relationship__c == businessRelationship){
					System.debug('THAO SelectOption ' + result.Seikyusaki__r.Name);
                    accounts.add(new SelectOption(result.Seikyusaki__c, result.Seikyusaki__r.Name));
                    
                }
                accountIds.add(result.Seikyusaki__c);

            }
            if(reportType == 'customer_credit_debit_report_type'
                || reportType == 'partner_report_type' || reportType == 'vender_report_type'){
                if(!String.isBlank(result.PaymentTo__c)
                    && !accountIds.contains(result.PaymentTo__c)
                    && !result.SiharaiKakuninzumi__c
                    && result.PaymentTo__r.Business_Relationship__c == businessRelationship){
                    accounts.add(new SelectOption(result.PaymentTo__c, result.PaymentTo__r.Name));
                    accountIds.add(result.PaymentTo__c);
                }

                accountIds.add(result.PaymentTo__c);
            }*/
        }
        message = '';
        if(accounts.size() == 0){
            message = 'There is no result';
        }

        return accounts;
    }

    public void generateReport(){
        displayReportTable = true;
        report = new ReportWrapper();

        String strQuery = buildQueryClient(accountId);
        Account client = [Select Id, Name, EnglishCompanyName__c, Business_Relationship__c, clofor_com_cfs__TAX_CODE__c, clofor_com_cfs__EnglishAddress__c,
                          BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id =: accountId];
        report.clientId = accountId;
        report.clientName = client.Name;
        report.taxCode = client.clofor_com_cfs__TAX_CODE__c;
        if(language == 'en_US'){
            report.address = client.clofor_com_cfs__EnglishAddress__c;
        }
        else if(language == 'vi'){
            if(!String.isBlank(client.BillingStreet)){
                report.address += client.BillingStreet + ' ,';
            }
            if(!String.isBlank(client.BillingCity)){
                report.address += client.BillingCity + ' ,';
            }
            if(!String.isBlank(client.BillingState)){
                report.address += client.BillingState + ' ,';
            }
            if(!String.isBlank(client.BillingPostalCode)){
                report.address += client.BillingPostalCode + ' ,';
            }
            if(!String.isBlank(client.BillingCountry)){
                report.address += client.BillingCountry + ' ,';
            }
            if(!String.isBlank(report.address)){
                report.address = report.address.removeEnd(' ,');
            }
        }

        if(reportType == 'partner_report_type'){
            report.clientType = 'Partner Name';
        }
        if(reportType == 'vender_report_type'){
            report.clientType = 'Vender Name';
        }
        if(reportType == 'customer_report_type' || reportType == 'customer_credit_debit_report_type'){
            report.clientType = 'Customer Name';
        }
        List<AnkenMeisai__c> billings = Database.query(strQuery);
        
        Set<String>  ankenIdSet = new Set<String>();
        ReportShipmentItemWrapper shipmentItem = new ReportShipmentItemWrapper();
        Integer counter = 0;
        for(AnkenMeisai__c billing : billings){

            if(advancePaymentType == 'No'){
                if(billing.ADVANCE_PAYMENT_ON_BEHALF_OF__c || billing.AdvancePaymentOnBehalfOfOurCompany__c){
                    continue;
                }
            }
            if(advancePaymentType == 'Customer'){
                if(!billing.ADVANCE_PAYMENT_ON_BEHALF_OF__c){
                    continue;
                }
            }
            if(advancePaymentType == 'OurCompany'){
                if(!billing.AdvancePaymentOnBehalfOfOurCompany__c){
                    continue;
                }
            }
            if(advancePaymentType == 'Both'){
                if(!billing.ADVANCE_PAYMENT_ON_BEHALF_OF__c || !billing.AdvancePaymentOnBehalfOfOurCompany__c){
                    continue;
                }
            }
            
            /*if(reportType <> 'vender_report_type'){
                if(!checkDisplayWhenNull(accountId, billing)){
                    continue;
                }
            }*/
            if(!checkDisplayWhenNull(accountId, billing, siteCustomSetting, currencyType)){
               continue;
            }
            
            ReportBillingItemWrapper billingItem = new ReportBillingItemWrapper(billing, accountId, language, currencyType);
            if(!ankenIdSet.contains(billing.Anken__c)){

                ankenIdSet.add(billing.Anken__c);
                if(counter > 0){
                    report.debit += shipmentItem.debit;
                    report.credit += shipmentItem.credit;
                    report.debitUSD += shipmentItem.debitUSD;
                    report.creditUSD += shipmentItem.creditUSD;
                    report.billingTotal += shipmentItem.quantity;
                    if (shipmentItem.dueDateOfPayment <> null){
                        report.dueDateOfPaymentText += shipmentItem.dueDateOfPayment;
                    }
                    // report.dueDateOfPaymentText += shipmentItem.dueDateOfPayment;
                    report.listShipment.add(shipmentItem);
                    if(report.dueDateOfPayment == null || report.dueDateOfPayment < shipmentItem.dueDateOfPayment){
                        report.dueDateOfPayment = shipmentItem.dueDateOfPayment;
                    }
                }
                counter ++;
                shipmentItem = new ReportShipmentItemWrapper();
                shipmentItem.wkId = billing.Anken__r.Name;
                shipmentItem.shipmentId = billing.Anken__c;
                shipmentItem.shipmentNo = billing.Anken__r.ID__c;
                shipmentItem.jobID = billing.Anken__r.JobRequestID__c;
                shipmentItem.saleAccountedDate = billing.Anken__r.SalesAccountedDate__c;
                shipmentItem.noHBL = billing.Anken__r.HBL_Number_SEA_AIR__c;
                shipmentItem.noMBL = billing.Anken__r.MBL_Number_SEA_AIR__c;
                shipmentItem.dateETD = billing.Anken__r.ETD__c;
                shipmentItem.dateETA = billing.Anken__r.ETA__c;
                shipmentItem.dueDateOfPayment = billing.Anken__r.DeadlineForPaymentOfInvoices__c;
                shipmentItem.invoiceIssueStatus = billing.Anken__r.InvoiceIssueStatus__c;
                shipmentItem.debitIssueStatus = billing.Anken__r.DebitIssueStatus__c;
            }

            if(ankenIdSet.contains(billing.Anken__c)){
                shipmentItem.quantity += 1;
                shipmentItem.listBilling.add(billingItem);
                shipmentItem.debit += billingItem.debit;
                shipmentItem.credit += billingItem.credit;
                shipmentItem.debitUSD += billingItem.debitUSD;
                shipmentItem.creditUSD += billingItem.creditUSD;
                shipmentItem.balance += billingItem.balance;
                shipmentItem.balanceUSD += billingItem.balanceUSD;
                //shipmentItem.dueDateOfPaymentText += billingItem.dueDateOfPayment;
                
            }
        }
        report.debit += shipmentItem.debit;
        report.credit += shipmentItem.credit;
        report.debitUSD += shipmentItem.debitUSD;
        report.creditUSD += shipmentItem.creditUSD;
        report.billingTotal += shipmentItem.quantity;
        report.dueDateOfPaymentText += shipmentItem.dueDateOfPayment;

        report.listShipment.add(shipmentItem);
        report.balance = report.debit - report.credit;
        report.balanceUSD = report.debitUSD - report.creditUSD;
    }
    
    private Boolean checkDisplayWhenNull(String customerId, AnkenMeisai__c bill, Site_Custom_Settings__c siteCustomSetting, String currencyType){
        Decimal debit = 0;
        Decimal debitUSD = 0;
        Decimal credit = 0;
        Decimal creditUSD = 0;
        Boolean isDisplay = true;
        if(customerId == bill.Seikyusaki__c){   
            if(siteCustomSetting.Local_Currency__c == bill.curr__c){
                //debit = (bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
                debit = bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
            } else{
                debitUSD = bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
            }
        }
        if(customerId == bill.PaymentTo__c){
            if(siteCustomSetting.Local_Currency__c == bill.clofor_com_cfs__CurrencyBuying__c){
                credit = bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
            } else{
                creditUSD = bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
            }
        }
        /*if(currencyType == 'VND'){
        if(siteCustomSetting.Local_Currency__c == bill.curr__c){
            if(customerId == bill.Seikyusaki__c){   
                debit = (bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
                debitUSD = (bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP));
            }
            if(customerId == bill.PaymentTo__c){
                credit = (bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
                creditUSD = (bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP));
            }
        } 
        }
        else{
            if(customerId == bill.Seikyusaki__c){   
                if(bill.curr__c == 'VND' || String.isBlank(bill.curr__c)){
                    debit = (bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
                }else{
                    debitUSD = (bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP));
                }
            }
            if(customerId == bill.PaymentTo__c){
                if(bill.CurrencyBuying__c == 'VND' || String.isBlank(bill.CurrencyBuying__c)){
                    credit = (bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
                }else{
                    creditUSD = (bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP)); 
                }
            }
        }
        
        if(customerId == bill.Seikyusaki__c){   
            if(bill.curr__c == 'VND' || String.isBlank(bill.curr__c)){
                debit = (bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
            }else{
                debitUSD = (bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP));
            }
        }
        if(customerId == bill.PaymentTo__c){
            if(bill.CurrencyBuying__c == 'VND' || String.isBlank(bill.CurrencyBuying__c)){
                credit = (bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP));
            }else{
                creditUSD = (bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP)); 
            }
        }*/
        
        if(debit == debitUSD && credit == creditUSD && debit == 0){
            isDisplay = false;
        }
        return isDisplay;
    }

    public void onChangeType(){
        if(reportType == 'partner_report_type'){
            accountType = 'partner';
            businessRelationship = Constants.PARTNER_RELATIONSHIP;
        }
        if(reportType == 'vender_report_type'){
            accountType = 'vender';
            businessRelationship = Constants.VENDOR_RELATIONSHIP;
        }
        if(reportType == 'custommer_report_type'){
            accountType = 'customer';
            businessRelationship = Constants.CUSTOMER_RELATIONSHIP;
        }
        if(reportType == 'customer_credit_debit_report_type'){
            accountType = 'customer';
            businessRelationship = Constants.CUSTOMER_RELATIONSHIP;
        }
        reset();
        accountList = getAccountList();
        
    }
    public void onChangeDateFrom(){
        if(!String.isBlank(sFromDate)){
            fromDate = DateTimeUtils.parseDate(sFromDate, '/');
        }
        else{
            fromDate = null;
        }
        accountList = getAccountList();

    }
    public void onChangeDateTo(){
        if(!String.isBlank(sToDate)){
            toDate = DateTimeUtils.parseDate(sToDate, '/');
        }
        else{
            toDate = null;
        }
        accountList = getAccountList();
    }
    public void onChangeCurrency(){
        accountList = getAccountList();
    }

    private String buildQueryClient(String customerId){
        excludeAnKenRecordTypes = getExcludeAnKenRecordTypes();
        excludeStatuses = getExcludeStatuses();
        String selectStr = 'SELECT ' + String.join(new List<String>(selectFields), ',');
        String fromStr = ' FROM AnkenMeisai__c';
        String whereStr = ' AND Anken__r.RecordType.DeveloperName NOT IN: excludeAnKenRecordTypes';
        
        whereStr += ' AND Anken__r.Status__c NOT IN: excludeStatuses';
        whereStr += ' AND (clofor_com_cfs__curr__c = \'' + currencyType + '\' OR clofor_com_cfs__CurrencyBuying__c = \'' + currencyType + '\')';
        
        String filter = '';
        if (fromDate != null && toDate != null) {
            if (fromDate <= toDate) {
                if(searchCondition.equals('ETD')){
                    filter = ' AND (Anken__r.ETD__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(searchCondition.equals('ETA')){
                    filter = ' AND (Anken__r.ETA__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(searchCondition.equals('SHIPMENTORDER')){
                    filter = ' AND (Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(searchCondition.equals('INVOICING')){
                    filter = ' AND (SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate) + ')';
                }
                
            }
            period = 'From ' + fromDate + ' To ' + toDate;
        } else if (fromDate != null && toDate == null) {
            //filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
            if(searchCondition.equals('ETD')){
                filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
            }
            else if(searchCondition.equals('ETA')){
                filter = ' AND Anken__r.ETA__c >= ' + String.valueOf(fromDate);
            }
            else if(searchCondition.equals('SHIPMENTORDER')){
                filter = ' AND Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate);
            }
            else if(searchCondition.equals('INVOICING')){
                filter = ' AND SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate);
            }
            period = 'From ' + fromDate;
        } else if (fromDate == null && toDate != null) {
            //filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
            if(searchCondition.equals('ETD')){
                filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
            }
            else if(searchCondition.equals('ETA')){
                filter = ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate);
            }
            else if(searchCondition.equals('SHIPMENTORDER')){
                filter = ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate);
            }
            else if(searchCondition.equals('INVOICING')){
                filter = ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate);
            }
            period = 'To ' + toDate;
        }
        whereStr += filter;
        if(!String.isBlank(customerId)){
            whereStr += ' AND ( Seikyusaki__c =\'' + String.escapeSingleQuotes(customerId) + '\' OR PaymentTo__c =\'' + String.escapeSingleQuotes(customerId) + '\') ';
            if(reportType == 'partner_report_type' || reportType == 'customer_credit_debit_report_type' || reportType == 'vender_report_type'){
                whereStr += ' AND ( (( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false)';
                whereStr += ' OR (( BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false))';
                //whereStr += ' AND ( (( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false AND Seikyusaki__c =\'' + String.escapeSingleQuotes(customerId) + '\')';
                //whereStr += ' OR ( ( BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false AND PaymentTo__c =\'' + String.escapeSingleQuotes(customerId) + '\') )';
            }
            /*if(reportType == 'vender_report_type'){
                whereStr += ' AND ( (BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false ) ';
            }*/
            if(reportType == 'custommer_report_type'){
                whereStr += ' AND ( ( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false )';
                //whereStr += ' AND ( ( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false AND Seikyusaki__c =\'' + String.escapeSingleQuotes(customerId) + '\')';
                ////whereStr += ' OR ( SiharaiKakuninzumi__c = false AND PaymentTo__c =\'' + customerId + '\') )';
            }
        }else{
            whereStr += ' AND ( Seikyusaki__r.Business_Relationship__c =\'' + String.escapeSingleQuotes(businessRelationship) + '\' OR PaymentTo__r.Business_Relationship__c =\'' + String.escapeSingleQuotes(businessRelationship) + '\') ';
            whereStr += ' AND ( (( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false)';
            whereStr += ' OR (( BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false))';
            //whereStr += ' AND ( (( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false AND Seikyusaki__r.Business_Relationship__c =\'' + String.escapeSingleQuotes(businessRelationship) + '\')';
            //whereStr += ' OR ( (BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false AND PaymentTo__r.Business_Relationship__c =\'' + String.escapeSingleQuotes(businessRelationship) + '\') )';
        }
        if(ankenIdList.size() > 0){
            whereStr += ' AND Anken__c IN : ankenIdList';
        }
        whereStr = whereStr.replaceFirst('AND', 'WHERE');
        System.debug('THAO where ' + whereStr);
        return selectStr + fromStr + whereStr + ' ORDER BY Anken__c,Seikyusaki__c  LIMIT 50000';
    }

    private Set<String> getExcludeAnKenRecordTypes(){
        Set<String> recordTypeNames = new Set<String>();
        recordTypeNames.add(Constants.QUOTATION_RT);
        recordTypeNames.add(Constants.OCEAN_EXPORT_LOCK_RT);
        recordTypeNames.add(Constants.AIR_EXPORT_LOCK_RT);
        recordTypeNames.add(Constants.AIR_IMPORT_LOCK_RT);
        recordTypeNames.add(Constants.OCEAN_IMPORT_LOCK_RT);
        return recordTypeNames;
    }

    private Set<String> getExcludeStatuses(){
        Set<String> statuses = new Set<String>();
        statuses.add(PicklistReference.CANCELLED_ST);
        statuses.add(PicklistReference.COMPLETED_ST);
        statuses.add(PicklistReference.TEMPORARY_UNLOCK_FOR_ACCOUNTING_PURPOSE_ST);
        return statuses;
    }
    
    public Class ReportWrapper{
        public String clientType{get; set;}
        public String clientId{get; set;}
        public String clientName{get; set;}
        public String taxCode {get; set;}
        public String address {get; set;}
        public String dueDateOfPaymentText {get; set;}
        public Date dueDateOfPayment{get; set;}
        public Decimal debit{get; set;}
        public Decimal debitUSD{get; set;}
        public Decimal credit{get; set;}
        public Decimal creditUSD{get; set;}
        public Decimal balance{get; set;}
        public Decimal balanceUSD{get; set;}
        public Integer billingTotal{get; set;}
        public List<ReportShipmentItemWrapper> listShipment{get; set;}
        public ReportWrapper(){
            dueDateOfPayment = null;
            dueDateOfPaymentText = '';
            clientType = '';
            clientId = '';
            clientName = '';
            taxCode = '';
            address = '';
            debit = 0; 
            debitUSD = 0;
            credit = 0;
            creditUSD = 0;
            balance = 0;
            balanceUSD = 0;
            billingTotal = 0;
            listShipment = new List<ReportShipmentItemWrapper>();
        }
    }
    public Class ReportShipmentItemWrapper{
        public String shipmentNo{get; set;}
        public String jobID{get; set;}
        public String  wkId{get; set;}
        public String shipmentId{get; set;}
        public Date saleAccountedDate{get;set;}
        public String noHBL{get; set;}
        public String noMBL{get; set;}
        public Date dateETD{get; set;}
        public Date dateETA{get; set;}
        public Integer quantity{get; set;}
        public Date dueDateOfPayment{get; set;}
        public String dueDateOfPaymentText{get; set;}
        public Decimal debit{get; set;}
        public Decimal debitUSD{get; set;}
        public Decimal credit{get; set;}
        public Decimal creditUSD{get; set;}
        public Decimal balance{get; set;}
        public Decimal balanceUSD{get; set;}
        public String invoiceIssueStatus{get; set;}
        public String debitIssueStatus{get; set;}
        public List<ReportBillingItemWrapper> listBilling{get; set;}
        public ReportShipmentItemWrapper(){
            invoiceIssueStatus ='';
            debitIssueStatus = '';
            wkId = '';
            shipmentNo ='';
            jobID = '';
            shipmentId ='';
            saleAccountedDate = null;
            noHBL = '';
            noMBL = '';
            dateETD = null;
            dateETA = null;
            dueDateOfPayment = null;
            dueDateOfPaymentText = '';
            quantity = 0;
            debit = 0; 
            debitUSD = 0;
            credit = 0;
            creditUSD = 0;
            balance = 0;
            balanceUSD = 0;
            listBilling = new List<ReportBillingItemWrapper>();
        }
        
    }
    
    public Class ReportBillingItemWrapper{
        public String noBill{get;set;}
        public String billingId{get;set;}
        public Date saleAccountedDateInvoicing{get; set;}
        public String pricingName{get;set;}
        public String invoiceToName{get; set;}
        public String invoiceToId{get; set;}
        public String paymentToName{get; set;}
        public String paymentToId{get; set;}
        public String description{get;set;}
        public Decimal chargeUnitTotal{get;set;}

        public String shipmentOrderId{get; set;}
        public Decimal debit{get; set;}
        public Decimal debitUSD{get; set;}
        public Decimal credit{get; set;}
        public Decimal creditUSD{get; set;}
        public Decimal balance{get; set;}
        public Decimal balanceUSD{get; set;}
        public Date dueDateOfPayment{get; set;}
        public String dueDateOfPaymentText{get; set;}
        public String advancePayment{get;set;}
        public String outboundInvoiceNo{get; set;}
        public String inboundInvoiceNo{get; set;}
        public ReportBillingItemWrapper(){
            debit = 0; 
            debitUSD = 0;
            credit = 0;
            creditUSD = 0;
            balance = 0;
            balanceUSD = 0;
            shipmentOrderId ='';
            billingId = '';
            dueDateOfPayment = null;
            dueDateOfPaymentText ='';
        }
        public ReportBillingItemWrapper(AnkenMeisai__c bill, String customerId, String arglanguage, String currencyType){
            List<String> advancePaymentTypes = new List<String>();
            if(bill.ADVANCE_PAYMENT_ON_BEHALF_OF__c){
                advancePaymentTypes.add('On-behalf-of Customer');
            }
            if(bill.AdvancePaymentOnBehalfOfOurCompany__c){
                advancePaymentTypes.add('On-behalf-of Our Company');
            }
            if(!bill.ADVANCE_PAYMENT_ON_BEHALF_OF__c && !bill.AdvancePaymentOnBehalfOfOurCompany__c){
                advancePaymentTypes.add('No');
            }
            advancePayment = String.join(advancePaymentTypes, ', ');
            debit = 0; 
            debitUSD = 0;
            credit = 0;
            creditUSD = 0;
            balance = 0;
            balanceUSD = 0;
            noBill = bill.Name;
            billingId = bill.Id;
            saleAccountedDateInvoicing = bill.SalesAccountedDateInvoicing__c;
            pricingName = arglanguage == 'vi'? bill.InsatuyouSyohin__c : bill.InsatuyouSyohinEng__c;
            invoiceToName = bill.Seikyusaki__r.Name;
            invoiceToId = bill.Seikyusaki__c;
            paymentToName = bill.PaymentTo__r.Name;
            paymentToId = bill.PaymentTo__c;
            description = bill.Description__c;
            chargeUnitTotal = bill.Suryo__c;
            shipmentOrderId = bill.Anken__c;
            outboundInvoiceNo = bill.OutboundVATInvNo__c;
            inboundInvoiceNo = bill.InboundVATInvNo__c;
            credit = 0;
            creditUSD = 0;
            debit = 0;
            debitUSD = 0;
            dueDateOfPayment =null;
            dueDateOfPayment = bill.Anken__r.DeadlineForPaymentOfInvoices__c;
            
            if(customerId == bill.Seikyusaki__c){
                if(siteCustomSetting.Local_Currency__c == bill.curr__c){
                    debit = bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
                } else{
                    debitUSD = bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
                }
            }
            if(customerId == bill.PaymentTo__c){
                if(siteCustomSetting.Local_Currency__c == bill.CurrencyBuying__c){
                    credit = bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
                } else{
                    creditUSD = bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
                }
            }
            balance = debit - credit;
            balanceUSD = debitUSD - creditUSD;
        }
    }
}