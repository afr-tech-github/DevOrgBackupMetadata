public with sharing class SOAReportNewController_Clone {
    public String reportType {get;set;}
    public String language  {get;set;}
    public String searchCondition {get;set;}
    public Date fromDate {get;set;}
    public Date toDate {get;set;}
    public String sFromDate { get; set; }
    public String sToDate { get; set; }
    public String currencyType{ get; set;}
    public List<String> selectedCurrTypes { get; set;}
    public Set<String> currTypeToDisplay { get; set;}
    // all curr in queried billings
    public Set<String> existedCurrs { get; set;}
    public Set<String> curPicklistValues { get; set;}
    public String localCur {get; set;}
    public String fcyCur {get; set;}
    public String accountType{get; set;}
    public String businessRelationship{get; set;}
    public String accountId{get; set;}
    public List<String> getAccountFirst{get; set;}
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
	private static Site_Custom_Settings__c siteCustomSetting = Site_Custom_Settings__c.getInstance();
    private static Set<String> selectFields = new Set<String>();
    private static Set<String> excludeAnKenRecordTypes = new Set<String>();
    private static Set<String> excludeStatuses = new Set<String>();
    private static Map<String, String> reportTypeBusinessRelationship = new Map<String, String>();
    private static Map<String, List<AnkenMeisai__c>> billingByClientMap = new Map<String, List<AnkenMeisai__c>>();
    public Boolean showJobId{get;set;}
    public Boolean showWKID{get;set;}
    public Boolean isInvoicing {get;set;}
    public String stringDebitNo {get;set;}
    public String stringCreditNo {get;set;}
    public String stringCreditDate {get;set;}
    public integer titleColspan {get; set;}

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
        selectFields.add('DebitNo__c');
        selectFields.add('CreditNo__c');
        selectFields.add('CreditIssueDate__c');
        selectFields.add('UnreceivedBalance3rdCurrency__c');
        selectFields.add('UnpaidBalance3rdCurrency__c');
    }

    public SOAReportNewController_Clone() {
        advancePaymentType = 'All';
        //language = UserInfo.getLanguage();
        language = 'en_US';
        reportType = 'partner_report_type';
        accountType = 'partner';
        bankType = 'local1';
        isDisplayDetail = false;
        businessRelationship = Constants.PARTNER_RELATIONSHIP;
        showJobId = false;
        showWKID = false;
        isInvoicing = false;
        selectedCurrTypes = new List<String>();
        currTypeToDisplay = new Set<String>();
        existedCurrs = new Set<String>();
        localCur = siteCustomSetting.Local_Currency__c;
        fcyCur = siteCustomSetting.FCY_Currency__c;
        system.debug('localCur: ' + localCur + ' fcyCur: ' + fcyCur);
        getAccountFirst = new List<String>();
        stringCreditNo = '';
        stringCreditDate = '';
        
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
        System.debug('accountId :'+accountId);
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
            String currPick = ApexPages.currentPage().getParameters().get('currPick');
            if(!String.isBlank(currPick)){
                selectedCurrTypes = currPick.split(', ');
            }
            System.debug('curr: '+ selectedCurrTypes);
            report = new ReportWrapper();
            curPicklistValues = new Set<String>();
            List<SelectOption> currencies = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = AnkenMeisai__c.curr__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry entry : ple) {
                curPicklistValues.add(entry.getValue());
            }
            System.debug('123'+ curPicklistValues);
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
        currencyType = 'Both';
        bankType = 'local1';
        report = new ReportWrapper();
        accountId = getAccountFirst.get(0);
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
        searchConditions.add(new SelectOption('INVOICING', 'INVOICING DATE'));
        
        return searchConditions;
    }
    public List<SelectOption> getCurrencies(){
        curPicklistValues = new Set<String>();
        List<SelectOption> currencies = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = AnkenMeisai__c.curr__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : ple) {
            curPicklistValues.add(entry.getValue());
            currencies.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        system.debug('curPicklistValues: ' + curPicklistValues);
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
                    getAccountFirst.add(result.Seikyusaki__c);
                   accounts.add(new SelectOption(result.Seikyusaki__c, result.Seikyusaki__r.Name));
                   accountIds.add(result.Seikyusaki__c);
               }
            else if(!String.isBlank(result.PaymentTo__c)
                    && !accountIds.contains(result.PaymentTo__c)
                    && !result.SiharaiKakuninzumi__c
                    && result.PaymentTo__r.Business_Relationship__c == businessRelationship){
                        getAccountFirst.add(result.Seikyusaki__c);
                        accounts.add(new SelectOption(result.PaymentTo__c, result.PaymentTo__r.Name));
                        accountIds.add(result.PaymentTo__c);
                    }
        }
        message = '';
        if(accounts.size() == 0){
            message = 'There is no result';
        }

        return accounts;
    }

    public void generateReport(){
        System.debug('1314');
        existedCurrs = new Set<String>();
        currTypeToDisplay = new Set<String>();
        displayReportTable = true;
        report = new ReportWrapper();

        System.debug('21342354');
        report.amountWrapper = initMapAmountWrapper(curPicklistValues);
        System.debug('2134232344');
        onChangeDateFrom();
        onChangeDateTo();
        String strQuery = buildQueryClient(accountId);
        try{
            Account client = [Select Id, Name, EnglishCompanyName__c, Business_Relationship__c, clofor_com_cfs__TAX_CODE__c, clofor_com_cfs__EnglishAddress__c,
                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id =: accountId];
            stringDebitNo = '';
            stringCreditNo = '';
            stringCreditDate = '';
            Map<String, AmountWrapper> mapReportAmountWrapper = new Map<String, AmountWrapper>();
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
            system.debug('query: ' + strQuery);
            system.debug('billings: ' + billings);

            Set<String>  ankenIdSet = new Set<String>();
            ReportShipmentItemWrapper shipmentItem = new ReportShipmentItemWrapper();
            Map<String, AmountWrapper> mapShipmentItemAW = new Map<String, AmountWrapper>();
            Integer counter = 0;
            for(AnkenMeisai__c billing : billings){
            existedCurrs.add(billing.curr__c);
            existedCurrs.add(billing.CurrencyBuying__c);
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
            // if(!checkDisplayWhenNull(accountId, billing, siteCustomSetting, currencyType)){
            //    continue;
            // }

            ReportBillingItemWrapper billingItem = new ReportBillingItemWrapper(billing, accountId, language, currencyType, localCur, fcyCur, curPicklistValues);
            Set<String> validCurrTypes = getValidCurrTypesInBilling(billingItem.amountWrapper, selectedCurrTypes);
            if(validCurrTypes.size() == 0){
            continue;
            }
            currTypeToDisplay.addAll(validCurrTypes);

            if(!ankenIdSet.contains(billing.Anken__c)){
            ankenIdSet.add(billing.Anken__c);
            if(counter > 0){
                report.billingTotal += shipmentItem.quantity;

                shipmentItem.amountWrapper = mapShipmentItemAW;
                for(String c: mapShipmentItemAW.keySet()){
                    AmountWrapper shipmentItemAW = mapShipmentItemAW.get(c);
                    system.debug('shipmentItemAW: ' + c + ' ' + shipmentItemAW);
                    if(shipmentItemAW != null){
                        AmountWrapper reportAW = mapReportAmountWrapper.get(c);
                        reportAW = reportAW != null ? reportAW : new AmountWrapper();
                        reportAW.debit += shipmentItemAW.debit;
                        reportAW.credit += shipmentItemAW.credit;
                        reportAW.balance += shipmentItemAW.debit - shipmentItemAW.credit;
                        mapReportAmountWrapper.put(c, reportAW);
                    }
                }

                if (shipmentItem.dueDateOfPayment <> null){
                    report.dueDateOfPaymentText += shipmentItem.dueDateOfPayment;
                }
                report.listShipment.add(shipmentItem);
                if(report.dueDateOfPayment == null || report.dueDateOfPayment < shipmentItem.dueDateOfPayment){
                    report.dueDateOfPayment = shipmentItem.dueDateOfPayment;
                }
            }
            counter ++;
            shipmentItem = new ReportShipmentItemWrapper();
            mapShipmentItemAW =  new Map<String, AmountWrapper>();
            shipmentItem.wkId = billing.Anken__r.Name;
            shipmentItem.shipmentId = billing.Anken__c;
            shipmentItem.shipmentNo = billing.Anken__r.ID__c;
            shipmentItem.jobID = billing.Anken__r.JobRequestID__c;

            isInvoicing = searchCondition.equals('INVOICING');
            if (searchCondition.equals('INVOICING')) {
                shipmentItem.saleAccountedDate = billing.SalesAccountedDateInvoicing__c;
            } else {
                shipmentItem.saleAccountedDate = billing.Anken__r.SalesAccountedDate__c;
            }
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
            if (billingItem.debitNo != null && billingItem.debitNo != ''){
                if (!shipmentItem.debitNo.contains(billing.DebitNo__c)){
                    shipmentItem.debitNo += billingItem.debitNo + ', ';
                }
            }
            if (billingItem.creditNo != null && billingItem.creditNo != ''){
                if (!shipmentItem.creditNo.contains(billing.CreditNo__c)){
                    shipmentItem.creditNo += billingItem.creditNo + ', ';
                }
            }
            if (billingItem.creditIssueDate != null && billingItem.creditIssueDate != ''){
                datetime creditDate= billing.CreditIssueDate__c;
                if (!shipmentItem.creditIssueDate.contains(creditDate.format('dd/MM/YYYY'))){
                    shipmentItem.creditIssueDate += billingItem.creditIssueDate + ', ';
                }
            }

            Map<String, AmountWrapper> mapBillingItemAW = billingItem.amountWrapper;
            for(String c: mapBillingItemAW.keySet()){
                AmountWrapper billingItemAW = mapBillingItemAW.get(c);
                system.debug('billingItemAW: ' + c + ' ' + billingItemAW);
                if(billingItemAW != null){
                    AmountWrapper shipmentItemAW = mapShipmentItemAW.get(c);
                    shipmentItemAW = shipmentItemAW != null ? shipmentItemAW : new AmountWrapper();
                    shipmentItemAW.debit += billingItemAW.debit;
                    shipmentItemAW.credit += billingItemAW.credit;
                    shipmentItemAW.balance += billingItemAW.debit - billingItemAW.credit;
                    mapShipmentItemAW.put(c, shipmentItemAW);
                }
            }
            }
            }
            system.debug('existedCurrs: ' + existedCurrs);
            existedCurrs.remove(null);
            titleColspan = existedCurrs.size() * 3 + 11;
            system.debug('existedCurrs: ' + existedCurrs);

            if(ankenIdSet.size() > 0){
            report.billingTotal += shipmentItem.quantity;
            shipmentItem.amountWrapper = mapShipmentItemAW;
            for(String c: mapShipmentItemAW.keySet()){
            AmountWrapper shipmentItemAW = mapShipmentItemAW.get(c);
            system.debug('shipmentItemAW: ' + c + ' ' + shipmentItemAW);
            if(shipmentItemAW != null){
                AmountWrapper reportAW = mapReportAmountWrapper.get(c);
                reportAW = reportAW != null ? reportAW : new AmountWrapper();
                reportAW.debit += shipmentItemAW.debit;
                reportAW.credit += shipmentItemAW.credit;
                reportAW.balance += shipmentItemAW.debit - shipmentItemAW.credit;
                mapReportAmountWrapper.put(c, reportAW);
            }
            }

            // dummy dueDateOfPayment for report
            report.dueDateOfPaymentText += shipmentItem.dueDateOfPayment;

            report.listShipment.add(shipmentItem);
            report.amountWrapper = mapReportAmountWrapper;
            system.debug('stringDebitNo :'+ stringDebitNo);
            for (ReportShipmentItemWrapper ship : report.listShipment){
            system.debug('ship.amountWrapper: '+ ship.amountWrapper);
            stringDebitNo += ship.debitNo;
            ship.debitNo = ship.debitNo.removeEnd(', ');
            stringCreditNo += ship.creditNo;
            ship.creditNo = ship.creditNo.removeEnd(', ');
            stringCreditDate += ship.creditIssueDate;
            ship.creditIssueDate = ship.creditIssueDate.removeEnd(', ');
            }
            }

            system.debug('report.amountWrapper: '+ report.amountWrapper);
            system.debug('currTypeToDisplay: '+ currTypeToDisplay);
        } catch(QueryException e){
        }
        
    }
    
    public Map<String, AmountWrapper> initMapAmountWrapper(Set<String> curPicklistValues){
        Map<String, AmountWrapper> mapAmountWrapper = new Map<String, AmountWrapper>();
        for(String c: curPicklistValues){
            mapAmountWrapper.put(c, new AmountWrapper());
        }
        return mapAmountWrapper;
    }

    public Set<String> getValidCurrTypesInBilling(Map<String, AmountWrapper> mapAmountWrapper, List<String> existedCurrs){
        Set<String> validCurrTypes = new Set<String>();
        for(String c: existedCurrs){
            AmountWrapper aw = mapAmountWrapper.get(c);
            if(aw.debit != 0 || aw.credit != 0 || aw.balance != 0){
                validCurrTypes.add(c);
            }
        }
        return validCurrTypes;
    }
    
    private Boolean checkDisplayWhenNull(String customerId, AnkenMeisai__c bill, Site_Custom_Settings__c siteCustomSetting, String currencyType){
        Decimal debit = 0;
        Decimal debitUSD = 0;
        Decimal credit = 0;
        Decimal creditUSD = 0;
        Boolean isDisplay = true;
        if(customerId == bill.Seikyusaki__c){   
            if(siteCustomSetting.Local_Currency__c == bill.curr__c && bill.curr__c <> 'USD' && (currencyType == 'VND' || currencyType == 'Both')){
                debit = bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
            } else
            if(currencyType == 'All VND' || currencyType == 'All Both' || currencyType == 'All USD'){
                debit = bill.SellDifferentiation__c == null ? 0 : bill.SellDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
            }
            if(bill.curr__c == 'USD' && (currencyType == 'USD' || currencyType == 'Both')){
                debitUSD = bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
        	} else
            if(currencyType == 'All USD' || currencyType == 'All Both'|| currencyType == 'All VND'){
                debitUSD = bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_SELLING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
            }
        }
        if(customerId == bill.PaymentTo__c){
            if(siteCustomSetting.Local_Currency__c == bill.clofor_com_cfs__CurrencyBuying__c && bill.CurrencyBuying__c <> 'USD' && (currencyType == 'VND' || currencyType == 'Both')){
                credit = bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
            } else
            if(currencyType == 'All VND' || currencyType == 'All Both' || currencyType == 'All USD'){
                credit = bill.BuyDifferentiation__c == null ? 0 : bill.BuyDifferentiation__c.setScale(2, System.RoundingMode.HALF_UP);
            }
            if(bill.CurrencyBuying__c == 'USD' && (currencyType == 'USD' || currencyType == 'Both')){
                creditUSD = bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
        	} else
            if(currencyType == 'All USD' || currencyType == 'All Both'|| currencyType == 'All VND'){
                creditUSD = bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : bill.UNPAID_BALANCE_OF_BUYING_USD__c.setScale(2, System.RoundingMode.HALF_UP);
            }
        }
        
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
        System.debug('fromDate :'+fromDate);
        accountList = getAccountList();

    }
    public void onChangeDateTo(){
        if(!String.isBlank(sToDate)){
            toDate = DateTimeUtils.parseDate(sToDate, '/');
        }
        else{
            toDate = null;
        }
        System.debug('toDate :'+toDate);
        accountList = getAccountList();
    }

    private String buildQueryClient(String customerId){
        excludeAnKenRecordTypes = getExcludeAnKenRecordTypes();
        excludeStatuses = getExcludeStatuses();
        String selectStr = 'SELECT ' + String.join(new List<String>(selectFields), ',');
        String fromStr = ' FROM AnkenMeisai__c';
        String whereStr = ' AND Anken__r.RecordType.DeveloperName NOT IN: excludeAnKenRecordTypes';
        
        whereStr += ' AND Anken__r.Status__c NOT IN: excludeStatuses';
        
        if(selectedCurrTypes != null && selectedCurrTypes.size() > 0){
            whereStr += ' AND (curr__c IN :selectedCurrTypes OR CurrencyBuying__c IN : selectedCurrTypes) ';
        }

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
                    filter = ' AND ((';
                    if(customerId != null){
                        filter += 'PaymentTo__c = \'' + String.escapeSingleQuotes(customerId) + '\' AND ';
                    }
                    filter += ' SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate) + ')';
                    filter += ' OR (';
                    if(customerId != null){
                        filter += ' Seikyusaki__c = \'' + String.escapeSingleQuotes(customerId) + '\' AND ';
                    }
                    filter += ' CreditIssueDate__c >= ' + String.valueOf(fromDate) + ' AND CreditIssueDate__c <= ' + String.valueOf(toDate) + '))';
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
                filter = '  AND (( ';
                if(customerId != null){
                    filter += 'PaymentTo__c = \'' + String.escapeSingleQuotes(customerId) + '\' AND ';
                }
                filter += ' SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ')';
                filter += ' OR ( ';
                if(customerId != null){
                    filter += ' Seikyusaki__c = \'' + String.escapeSingleQuotes(customerId) + '\' AND ';
                }
                filter += ' CreditIssueDate__c >= ' + String.valueOf(fromDate) + '))';
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
                filter = '  AND (( ';
                if(customerId != null){
                    filter += 'PaymentTo__c = \'' + String.escapeSingleQuotes(customerId) + '\' AND ';
                }
                filter += ' SalesAccountedDateInvoicing__c >= ' + String.valueOf(toDate) + ')';
                filter += ' OR ( ';
                if(customerId != null){
                    filter += ' Seikyusaki__c = \'' + String.escapeSingleQuotes(customerId) + '\' AND ';
                }
                filter += ' CreditIssueDate__c >= ' + String.valueOf(toDate) + '))';
            }
            period = 'To ' + toDate;
        }
        whereStr += filter;
        if(!String.isBlank(customerId)){
            whereStr += ' AND ( Seikyusaki__c =\'' + String.escapeSingleQuotes(customerId) + '\' OR PaymentTo__c =\'' + String.escapeSingleQuotes(customerId) + '\') ';
            if(reportType == 'partner_report_type' || reportType == 'customer_credit_debit_report_type' || reportType == 'vender_report_type'){
                whereStr += ' AND ( (( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false)';
                whereStr += ' OR (( BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false))';
            }
            if(reportType == 'custommer_report_type'){
                whereStr += ' AND ( ( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false )';
            }
        }else{
            whereStr += ' AND ( Seikyusaki__r.Business_Relationship__c =\'' + String.escapeSingleQuotes(businessRelationship) + '\' OR PaymentTo__r.Business_Relationship__c =\'' + String.escapeSingleQuotes(businessRelationship) + '\') ';
            whereStr += ' AND ( (( SellDifferentiation__c > 0 OR UNPAID_BALANCE_OF_SELLING_USD__c > 0) AND NyukinKakuninzumi__c = false)';
            whereStr += ' OR (( BuyDifferentiation__c > 0 OR UNPAID_BALANCE_OF_BUYING_USD__c > 0) AND SiharaiKakuninzumi__c = false))';
        }
        if(ankenIdList.size() > 0){
            whereStr += ' AND Anken__c IN : ankenIdList';
        }
        whereStr = whereStr.replaceFirst('AND', 'WHERE');
        System.debug('THAO where ' + whereStr);
        return selectStr + fromStr + whereStr + ' ORDER BY Anken__c,Seikyusaki__c  LIMIT 10000';
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
        public Map<String, AmountWrapper> amountWrapper {get; set;}
        public ReportWrapper(){
            dueDateOfPayment = null;
            dueDateOfPaymentText = '';
            clientType = '';
            clientId = '';
            clientName = '';
            taxCode = '';
            address = '';
            debit = debitUSD = credit = creditUSD = balance = balanceUSD = billingTotal = 0;
            listShipment = new List<ReportShipmentItemWrapper>();
            amountWrapper = new Map<String, AmountWrapper>();
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
        public String debitNo {get;set;}
        public String creditNo {get;set;}
        public String creditIssueDate {get;set;}
        public List<ReportBillingItemWrapper> listBilling{get; set;}
        public Map<String, AmountWrapper> amountWrapper {get; set;}
        public ReportShipmentItemWrapper(){
            creditNo = '';
            creditIssueDate = '';
            invoiceIssueStatus ='';
            debitIssueStatus = '';
            debitNo = wkId = shipmentNo = jobID = shipmentId = noHBL = noMBL = '';
            saleAccountedDate = null;
            dateETD = null;
            dateETA = null;
            dueDateOfPayment = null;
            dueDateOfPaymentText = '';
            quantity = 0;
            debit = debitUSD = credit = creditUSD = balance = balanceUSD = 0;
            amountWrapper = new Map<String, AmountWrapper>();
            listBilling = new List<ReportBillingItemWrapper>();
        }
    }

    public class AmountWrapper{
        public Decimal debit{get; set;}
        public Decimal credit{get; set;}
        public Decimal balance{get; set;}

        public AmountWrapper(){
            debit = credit = balance = 0;
        }
        public AmountWrapper(Decimal debit, Decimal credit, Decimal balance){
            this.debit = debit;
            this.credit = credit;
            this.balance = balance;
        }
    }
    
    public Class ReportBillingItemWrapper{
        public String noBill{get;set;}
        public String billingId{get;set;}
        public Date saleAccountedDateInvoicing{get; set;}
        public String debitNo{get;set;}
        public String creditNo{get;set;}
        public String creditIssueDate{get;set;}
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
        public String curr{get; set;}
        public String currBuying{get; set;}
        public Map<String, AmountWrapper> amountWrapper {get; set;}
        public ReportBillingItemWrapper(){
            debit = debitUSD = credit = creditUSD = balance = balanceUSD= 0;
            shipmentOrderId = billingId ='';
            dueDateOfPayment = null;
            dueDateOfPaymentText ='';
            curr = currBuying = '';
            amountWrapper = new Map<String, AmountWrapper>();
        }
        public ReportBillingItemWrapper(AnkenMeisai__c bill, String customerId, String arglanguage, String currencyType, String localCur, String fcyCur, Set<String> curPicklistValues){
            amountWrapper = new Map<String, AmountWrapper>();
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
            debit = debitUSD = credit = creditUSD = balance = balanceUSD = 0;
            noBill = bill.Name;
            billingId = bill.Id;
            curr = bill.curr__c;
            currBuying = bill.CurrencyBuying__c;
            saleAccountedDateInvoicing = bill.SalesAccountedDateInvoicing__c;
            if (bill.DebitNo__c != null && bill.DebitNo__c != '')
            debitNo = bill.DebitNo__c;
            if (bill.CreditNo__c != null && bill.CreditNo__c != '')
            creditNo = bill.CreditNo__c;
            if (bill.CreditIssueDate__c != null){
                Datetime creditDate = bill.CreditIssueDate__c;
                creditIssueDate = creditDate.format('dd/MM/YYYY');
            }
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
            dueDateOfPayment =null;
            dueDateOfPayment = bill.Anken__r.DeadlineForPaymentOfInvoices__c;

            if(curr == localCur && currBuying == localCur){
                amountWrapper.put(curr, new AmountWrapper(bill.SellDifferentiation__c, bill.BuyDifferentiation__c, bill.SellDifferentiation__c - bill.BuyDifferentiation__c));
            }else if(curr == localCur) {
                amountWrapper.put(curr, new AmountWrapper(bill.SellDifferentiation__c, 0, bill.SellDifferentiation__c));
            }else if(currBuying == localCur) {
                amountWrapper.put(currBuying, new AmountWrapper(0, bill.BuyDifferentiation__c, - bill.BuyDifferentiation__c));
            }

            if(curr == fcyCur && currBuying == fcyCur){
                amountWrapper.put(curr, new AmountWrapper(bill.UNPAID_BALANCE_OF_SELLING_USD__c, bill.UNPAID_BALANCE_OF_BUYING_USD__c, bill.UNPAID_BALANCE_OF_SELLING_USD__c - bill.UNPAID_BALANCE_OF_BUYING_USD__c));
            }else if(curr == fcyCur) {
                amountWrapper.put(curr, new AmountWrapper(bill.UNPAID_BALANCE_OF_SELLING_USD__c, 0, bill.UNPAID_BALANCE_OF_SELLING_USD__c));
            }else if(currBuying == fcyCur) {
                amountWrapper.put(currBuying, new AmountWrapper(0, bill.UNPAID_BALANCE_OF_BUYING_USD__c, - bill.UNPAID_BALANCE_OF_BUYING_USD__c));
            }

            if(curr != null && curr == currBuying && curr != localCur && curr != fcyCur){
                amountWrapper.put(curr, new AmountWrapper(bill.UnreceivedBalance3rdCurrency__c, bill.UnpaidBalance3rdCurrency__c, bill.UnreceivedBalance3rdCurrency__c - bill.UnpaidBalance3rdCurrency__c));
            }else if(curr != null && curr != localCur && curr != fcyCur) {
                amountWrapper.put(curr, new AmountWrapper(bill.UnreceivedBalance3rdCurrency__c, 0, bill.UnreceivedBalance3rdCurrency__c));
            }else if(currBuying != null && currBuying != localCur && currBuying != fcyCur) {
                amountWrapper.put(currBuying, new AmountWrapper(0, bill.UnpaidBalance3rdCurrency__c, - bill.UnpaidBalance3rdCurrency__c));
            }

            for(String c: curPicklistValues){
                AmountWrapper aw = amountWrapper.get(c);
                if(aw == null) {
                    amountWrapper.put(c, new AmountWrapper());
                } else{
                    if((bill.Seikyusaki__c == null || bill.Seikyusaki__c != customerId) && aw.debit != 0){
                        aw.debit = 0;
                        aw.balance = - aw.credit;
                    }
                    if((bill.PaymentTo__c == null || bill.PaymentTo__c != customerId) && aw.credit != 0){
                        aw.credit = 0;
                        aw.balance = aw.debit;
                    }
                }
            }
        }
    }
}