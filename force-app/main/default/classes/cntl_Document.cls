public with sharing class cntl_Document {

    public String getTotalAmountText() {
        return totalAmountText_Wording;
    }

    public CustomObject1__c AnkenList {get;set;}    //案件格納リスト
    public List<AnkenMeisai__c> ItemList {get;set;} //案件明細格納リスト         
    public User TantosyaUser {get;set;} //案件担当者リスト
    public User MitumoriUser {get;set;} //見積担当者リスト
    public List<WrapperAnkenMeisai> WrapdisplayitemList {get;set;}
    public Integer displayListSize {get;set;}
    public Decimal Syokei   {get;set;} //小計
    public Decimal SyokeiUSD   {get;set;}
    public Decimal Syohizei {get;set;} //消費税
    public Decimal SyohizeiUSD {get;set;}
    public Decimal totalBuyAmountJPY   {get;set;}
    public Decimal totalBuyAmountUSD   {get;set;}
    public Decimal totalBuyTax {get;set;}
    public List<string> AnkenBikou  {get;set;} //見積用備考
    public List<string> SeikyuBikou {get;set;} //請求用備考
    public String paymentMethods {get; private set;}
    public String viTotalAmountText {get; private set;}
    public String viTotalLocalAmountText {get; private set;}
    public String totalAmountText_Wording {get; private set;}
    public String totalAmountText_Wording_VND {get; private set;}
    public String localCurr {get; set;}
    public String grandTotalUSDInJPWording{get;set;}


    public Decimal vatPercentage {get; private set;}
    public Decimal sumAmountOfTaxBuyingUSD {get; private set;}
    public Decimal sumAmountOfTaxBuying {get; private set;}
    public Decimal sumAmountBuyingIncludingTax {get; private set;}

    public Decimal totalCreditBalance {get; private set;}
    public Decimal totalLocalCreditBalance {get; private set;}
    public String totalCreditBalanceText {get; private set;}
    public Decimal totalLocalDebitBalance {get; private set;}
    public Decimal totalDebitBalance {get; private set;}
    public String totalDebitBalanceText {get; private set;}

    public string AnkenID;     //URLパラメータの案件ID格納
    public Boolean AppearFlag {get;private set;} 
    public Boolean showQuotationTotal {get; private set;}
    public Boolean DebitReportFlag {get; private set;}
    private String reportName;
    private String language;
    private String customerId;
    private String curr;
    public Boolean filterByVATInvoiceTo {get; private set;}
    private static List<String> meisaiFieldsToQuery = new List<String>();
    static {
        meisaiFieldsToQuery.add('Id');
        meisaiFieldsToQuery.add('Name');
        meisaiFieldsToQuery.add('Anken__c');
        meisaiFieldsToQuery.add('SeikyuBangou__c');
        meisaiFieldsToQuery.add('InsatuyouSyohin__c');
        meisaiFieldsToQuery.add('SellTankaJPY__c');
        meisaiFieldsToQuery.add('SellTankaUSD__c');
        meisaiFieldsToQuery.add('BuyTankaJPY__c');
        meisaiFieldsToQuery.add('BuyTankaUSD__c');
        meisaiFieldsToQuery.add('Tariff__r.UNIT__c');
        
        /* start add unit fields in bill to query*/
        meisaiFieldsToQuery.add('ChargeUnitInPrint__c');
        meisaiFieldsToQuery.add('ChargeUnitFormula__c');
        meisaiFieldsToQuery.add('ContainerSizeFormula__c');
        /** end add unit fields in bill to query */
        meisaiFieldsToQuery.add('Tariff__r.TAX__c');
        meisaiFieldsToQuery.add('Tariff__r.ContainerSize__c');
        meisaiFieldsToQuery.add('Suryo__c');
        meisaiFieldsToQuery.add('wkSuryo__c');
        meisaiFieldsToQuery.add('SellAmountJPN__c');
        meisaiFieldsToQuery.add('SellAmountUSD__c');
        meisaiFieldsToQuery.add('BuyAmountJPN__c');
        meisaiFieldsToQuery.add('BuyAmountUSD__c');
        meisaiFieldsToQuery.add('SellTaxNum__c');
        meisaiFieldsToQuery.add('BuyTaxNum__c');
        meisaiFieldsToQuery.add('curr__c');
        meisaiFieldsToQuery.add('ProductTax__c');
        meisaiFieldsToQuery.add('wkTaxFlag__c');
        meisaiFieldsToQuery.add('Bikou__c');
        meisaiFieldsToQuery.add('PartnerProduct__c');
        meisaiFieldsToQuery.add('Seikyusaki__r.Name');
        meisaiFieldsToQuery.add('Seikyusaki__r.EnglishCompanyName__c');
        meisaiFieldsToQuery.add('Seikyusaki__r.REGISTERATION_NO_FORM__c');
        meisaiFieldsToQuery.add('Seikyusaki__r.REGISTRATION_NO_SERIAL__c');
        meisaiFieldsToQuery.add('Seikyusaki__r.TAX_CODE__c');
        meisaiFieldsToQuery.add('Seikyusaki__r.Bank1__c');        
        meisaiFieldsToQuery.add('Seikyusaki__r.EnglishAddress__c ');
        meisaiFieldsToQuery.add('Seikyusaki__r.BillingStreet'); 
        meisaiFieldsToQuery.add('Seikyusaki__r.BillingCity'); 
        meisaiFieldsToQuery.add('Seikyusaki__r.BillingState'); 
        meisaiFieldsToQuery.add('Seikyusaki__r.BillingCountry'); 
        meisaiFieldsToQuery.add('Seikyusaki__r.Payment_Method__c');
        meisaiFieldsToQuery.add('Seikyusaki__r.Phone'); 
        meisaiFieldsToQuery.add('Seikyusaki__r.Fax');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.Name');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.EnglishCompanyName__c');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.REGISTERATION_NO_FORM__c');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.REGISTRATION_NO_SERIAL__c');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.TAX_CODE__c');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.Bank1__c');        
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.EnglishAddress__c ');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.BillingStreet'); 
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.BillingCity'); 
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.BillingState'); 
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.BillingCountry'); 
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.Payment_Method__c');
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.Phone'); 
        meisaiFieldsToQuery.add('VAT_INVOICE_TO__r.Fax');
        meisaiFieldsToQuery.add('PaymentTo__r.Name');
        meisaiFieldsToQuery.add('PaymentTo__r.EnglishCompanyName__c');
        meisaiFieldsToQuery.add('PaymentTo__r.REGISTERATION_NO_FORM__c');
        meisaiFieldsToQuery.add('PaymentTo__r.REGISTRATION_NO_SERIAL__c');
        meisaiFieldsToQuery.add('PaymentTo__r.TAX_CODE__c');
        meisaiFieldsToQuery.add('PaymentTo__r.Bank1__c');        
        meisaiFieldsToQuery.add('PaymentTo__r.EnglishAddress__c');
        meisaiFieldsToQuery.add('PaymentTo__r.Phone');        
        meisaiFieldsToQuery.add('PaymentTo__r.Fax');
        meisaiFieldsToQuery.add('InsatuyouSyohinEng__c');
        meisaiFieldsToQuery.add('Tariff__r.EngTani__c');
        meisaiFieldsToQuery.add('PrintFlag__c');
        meisaiFieldsToQuery.add('TaxInitial__c');
        meisaiFieldsToQuery.add('KawaseSel__c');
        meisaiFieldsToQuery.add('KawaseBay__c'); 
        meisaiFieldsToQuery.add('SellTaxNum_USD__c');
        meisaiFieldsToQuery.add('BuyTaxInitial__c');
        meisaiFieldsToQuery.add('BuyTaxNum_USD__c');
        meisaiFieldsToQuery.add('BuyInTaxAmountUSD__c');
        meisaiFieldsToQuery.add('Description__c');
    }
    
    public Map<String, String> translations {get; private set;}
    
    public cntl_Document() {
        List<Site_Custom_Settings__c> lstSiteCustomSettings = [Select Local_Currency__c, Id from Site_Custom_Settings__c limit 1];
        if(lstSiteCustomSettings.size()>0){
            Site_Custom_Settings__c sct = lstSiteCustomSettings[0];
            localCurr = sct.Local_Currency__c;
        }
        GetURLPram();
        
        if (Constants.IV_DEBIT_NOTE.equalsIgnoreCase(reportName)
            || Constants.IV_INVOICE.equalsIgnoreCase(reportName)) {
            DebitReportFlag = true;
        } else {
            DebitReportFlag = false;
        }
        
        // if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying() 
                // && PermissionValidationUtil.isAccessibleUser() && PermissionValidationUtil.isAccessibleAccount() 
                // && PermissionValidationUtil.isAccessiblePort() && PermissionValidationUtil.isAccessibleServiceMaster()) {
        // if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying() 
                // && PermissionValidationUtil.isAccessibleUser() && PermissionValidationUtil.isAccessibleAccount() ) {
            // GetAnkenList();
            // GetAnkenMeisai();
            // determineVAT();
        // }
        GetAnkenList();
        GetAnkenMeisai();
        determineVAT();

        initializeTranslation();
        translatePaymentMethod(AnkenList);
        calculateTotalBalance();
        String filename = '';
        if(AnkenList.RecordType.Name == 'Ocean Export' || AnkenList.RecordType.Name == 'Ocean Import'){
            filename = AnkenList.Name + '_CREDIT NOTE_' + AnkenList.HBL__c + '.pdf';
        }
        if(AnkenList.RecordType.Name == 'Air Export' || AnkenList.RecordType.Name == 'Air Import'){
            filename = AnkenList.Name + '_CREDIT NOTE_' + AnkenList.HAWB__c + '.pdf';
        }
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=\"'+filename+'\"');
        // convert total amount number to words (Vietnamese only)
        System.debug('la :'+language);
        System.debug('curr :'+curr);
        if(language == 'vi'){ 
            
            if(curr == 'LOCAL'){
                if(localCurr == 'VND'){
                    totalAmountText_Wording =  NumbericUtils.convertNumberToText(DebitReportFlag? totalLocalDebitBalance: totalLocalCreditBalance, 'VND');
                }else if(localCurr == 'JPY'){
                    if(DebitReportFlag == true){
                        totalAmountText_Wording = JPYNumberToWords.convert(totalLocalDebitBalance);
                    }else{
                        totalAmountText_Wording = JPYNumberToWords.convert(totalLocalCreditBalance);
                    }
                }
            }else{

                totalDebitBalance = totalDebitBalance.setScale(2, RoundingMode.HALF_UP);
                totalCreditBalance = totalCreditBalance.setScale(2, RoundingMode.HALF_UP);
                totalAmountText_Wording =  NumbericUtils.readUSDAmountInVN(DebitReportFlag? totalDebitBalance: totalCreditBalance);
            }
            totalAmountText_Wording_VND = NumbericUtils.convertNumberToText(DebitReportFlag? totalLocalDebitBalance: totalLocalCreditBalance, 'VND');
        }else{
            if(curr == 'LOCAL'){
                if(localCurr == 'VND'){
                    totalAmountText_Wording =  NumbericUtils.readVNDAmountInEn(DebitReportFlag? totalLocalDebitBalance: totalLocalCreditBalance);
                }else if(localCurr == 'JPY'){
                    if(DebitReportFlag == true){
                        totalAmountText_Wording = JPYNumberToWords.convert(totalLocalDebitBalance);
                    }else{
                        totalAmountText_Wording = JPYNumberToWords.convert(totalLocalCreditBalance);
                    }
                }
            }else{
                totalDebitBalance = totalDebitBalance.setScale(2, RoundingMode.HALF_UP);
                totalCreditBalance = totalCreditBalance.setScale(2, RoundingMode.HALF_UP);
                totalAmountText_Wording =  NumbericUtils.readUSDAmountInEn(DebitReportFlag? totalDebitBalance: totalCreditBalance);
            }
            totalAmountText_Wording_VND = NumbericUtils.readVNDAmountInEn(DebitReportFlag? totalLocalDebitBalance: totalLocalCreditBalance);
        }
    }

    private void calculateTotalBalance() {
        totalCreditBalance = totalBuyAmountUSD + sumAmountOfTaxBuyingUSD;
        totalLocalCreditBalance = totalBuyAmountJPY + sumAmountOfTaxBuying;
        if (totalDebitBalance != null) {
            totalCreditBalanceText = NumbericUtils.readUSDAmount(totalCreditBalance);
        }

        totalDebitBalance = SyokeiUSD + SyohizeiUSD;
        totalLocalDebitBalance = Syokei + Syohizei;
        if (totalDebitBalance != null) {
            totalDebitBalanceText = NumbericUtils.readUSDAmount(totalDebitBalance);
        }
        viTotalAmountText = NumbericUtils.convertNumberToText(totalLocalDebitBalance, 'VND').toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
    }

    public String getDateFormat() {
        return DateTimeUtils.getDateFormat();
    }

    private void determineVAT() {
        vatPercentage = 0;
        if (ItemList != null && ItemList.size() > 0) {
            for (AnkenMeisai__c m : ItemList) {
                if (m.TaxInitial__c != null && m.TaxInitial__c > 0) {
                    vatPercentage = m.TaxInitial__c;
                    break;
                }
            }
        }
    }
    
    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('Invoice', language);
        translations = translationService.getTranslations();
    }
    
    private void GetURLPram() {
        AnkenID = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
        reportName = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_REPORT_NAME));
        language = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_LANGUAGE));
        customerId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CUSTOMER_ID));
        curr = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CURRENCY));

        try {
            AppearFlag = Boolean.valueOf(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CHECK_FLAG));
        } catch (Exception e) {
            AppearFlag = true;
        }
        try {
            showQuotationTotal = Boolean.valueOf(ApexPages.currentPage().getParameters().get(Constants.REQUEST_QUOTATION_FLAG));
        } catch (Exception e) {
            showQuotationTotal = true;
        }
        
        try {
            AppearFlag = Boolean.valueOf(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CHECK_FLAG));
        } catch (Exception e) {
            AppearFlag = true;
        }
        
        try {
            filterByVATInvoiceTo = Boolean.valueOf(ApexPages.currentPage().getParameters().get(Constants.REQUEST_VAT_FLAG));
        } catch (Exception e) {
            filterByVATInvoiceTo = false;
        }
    }
    
    private void GetAnkenList() {
        AnkenList = [    
            SELECT
                ID,                        //salesforceID
                Name,                      //salesforceレコード名
                WkInitial__c,              //頭文字
                ID__c,                     //ID(案件名+αのカスタム数式項目)
                PersonInCharge__c,         //案件担当者
                //InChargeOfQuotation__c,    //見積担当者
                CustmerInCharge__r.name,   //取引先責任者名
                QuotationCheck__c,         //見積書出力☑
                ExpiryDate__c,             //有効期限
                BUYING__c,                 //為替レート(Buying)
                ExchangeRate__c,           //為替レート(Selling)
                Item__c,                   //商品(ITEM)
                weight__c,                 //重量(WEIGHT)
                CBM__c,                    //体積(CBM)
                POL__r.City_Name__c,                    //出港地(POL)
                POD__r.City_Name__c,                    //入港地(POD)
                POL__r.Name,                    //出港地(POL)
                POD__r.Name,                    //入港地(POD)            
                QuoationDescription__c,    //見積内容
                carton__c,                 //個数(QUANTITY)
                CarrierType__c,            //運送タイプ
                ReimbursementCondition__c, //立替支払条件
                QuotationPrintDate__c,     //見積書発行日
                QuotationVer__c,           //見積バージョン
                HBL__c,                    //ハウスB/L番号
                HAWB__c,                   //ハウスB/L番号(空)
                Vessle__c,                 //船・便名
                FlightNo__c,               //飛行機番号
                Voy_No__c,                 //Voy No                
                ETD__c,                    //出港日(ETD)
                ETA__c,                    //入港日(ETA)
                DeadlineForPaymentOfInvoices__c, //見積書お支払期限
                DateOfSending__c,          //請求書発行日
                ExpanseCondition__c,       //諸請求支払条件
                TranporationType__c,       //輸送タイプ
                SeikyusyoRemark__c,        //請求書備考
                InvoicePrintDate__c,       //請求書発行日
                DeadlineForPaymentOfExpense__c, //立替支払期限
                MitumoriKakuninsya__c,          //見積_確認者
                MitumoriSyouninsya__c,          //見積_承認者
                MitumoriSinseisya__c,           //見積_申請者
                MitumoriKakuninsyaENG__c,       //見積_確認者（英語）
                MitumoriSyouninsyaENG__c,       //見積_承認者（英語）
                MitumoriSinseisyaENG__c,        //見積_申請者(英語)
                PrintDate__c,
                QuotationPaymentCondition__c,
                CREATEDDATE,
                Field1__r.name,             //取引先名
                Field1__r.EnglishCompanyName__c,
                Field1__r.REGISTERATION_NO_FORM__c ,
                Field1__r.REGISTRATION_NO_SERIAL__c,
                Field1__r.TAX_CODE__c,
                Field1__r.EnglishAddress__c,
                Field1__r.Bank1__c,
                Field1__r.Bank2__c,
                Field1__r.Bank3__c,
                Field1__r.Bank4__c,
                Field1__r.Bank5__c,
                Field1__r.Bank6__c,
                Field1__r.BillingStreet,
                Field1__r.BillingCity,
                Field1__r.BillingState,
                Field1__r.BillingCountry,
                Field1__r.Payment_Method__c,
                DebitNote_duedate__c,
                chargable_weight__c,
                RecordType.DeveloperName,
                MAWB__c,
                Cnee__r.Name,
                Container__c,                       //コンテナタイプ            
                ContainerNumber__c,                 //コンテナサイズ１
                Container2__c,                      //コンテナタイプ2
                ContainerNumber2__c,                //コンテナサイズ２
                Container3__c,                       
                ContainerNumber3__c,                 
                Container4__c,                      
                ContainerNumber4__c,                            
                //Break_Bulk_Agent__r.Name,
                Mail_Merge_Foreign_Bank1__c,
                Mail_Merge_Foreign_Bank2__c,
                Exchange_Currency__c,
                DebitCreditRemark__c,
                TERMS_OF_PAYMENT__c,
                Master_B_L__c,
                UnitType__c,
                CustomsClearanceDeclarationNo__c,        //20181023added
                JobRequestID__c,                        //20181208 added by kwon             
                REFNO__c,                        //20191030 added by Thong
                RecordType.Name
                
            FROM
                CustomObject1__c //案件
            WHERE
                ID = :AnkenID    //ボタンを押した案件データを抽出
            LIMIT
                1                //1件のみ
        ];
        
        if (AnkenList.CREATEDDATE < Datetime.newInstance(2013, 11, 07, 10, 00, 00)){
            AnkenList.QuotationCheck__c = true;
        }

        if(AnkenList.PersonInCharge__c != null){
            TantosyaUser = [
                SELECT
                    ID,
                    Name,
                    Email,
                    NameEng__c
                FROM
                    User
               WHERE
                    ID = :AnkenList.PersonInCharge__c
                LIMIT
                    1    
            ];
        }
        
        /*if(AnkenList.InChargeOfQuotation__c != null){  
            MitumoriUser = [
                SELECT
                    ID,
                    Name,
                    Email,
                    NameEng__c
                FROM
                    User
               //WHERE
                    //ID = :AnkenList.InChargeOfQuotation__c
                LIMIT
                    1    
            ];
        }*/
        
        if(AnkenList.QuoationDescription__c != null){
            AnkenBikou = new List<string>();
            AnkenBikou = AnkenList.QuoationDescription__c.split('\r\n',0); //改行コードで区切った文字列をリストに格納
        }

        if(AnkenList.SeikyusyoRemark__c != null){
            SeikyuBikou = new List<string>();
            SeikyuBikou = AnkenList.SeikyusyoRemark__c.split('\r\n',0); //改行コードで区切った文字列をリストに格納
        }
    }

    private void GetAnkenMeisai() {
        String consolidationRTId = RecordTypeUtil.getRecordTypeIdByDeveloperName(AnkenMeisai__c.SObjectType, Constants.SELLING_BUYING_CONSOLIDATION_RT);
        String selectClause = 'SELECT ' + String.join(meisaiFieldsToQuery, ',');
        String fromClause = ' FROM AnkenMeisai__c ';
        String whereClause = ' WHERE Anken__c = \'' + AnkenList.id 
                            + '\' AND PrintFlag__c = true AND RecordType.DeveloperName != \'' + Constants.SELLING_BUYING_CONSOLIDATION_RT + '\'';
        String orderByClause = ' ORDER BY SeikyuBangou__c NULLS LAST, CreatedDate';
        
        if (Constants.IV_CREDIT_NOTE.equalsIgnoreCase(reportName)) {
            whereClause += buildCreditNoteFilter();
        } else if (Constants.IV_BB_INVOICE.equalsIgnoreCase(reportName)) {
            whereClause += buildBBInvoiceFilter();
            whereClause += buildLocalInvoiceFilter();
        } else if (Constants.IV_DEBIT_NOTE.equalsIgnoreCase(reportName)) {
            whereClause += buildDebitNoteFilter();
        } else if (Constants.IV_INVOICE.equalsIgnoreCase(reportName) 
                   || Constants.IV_FREIGHT_MEMO.equalsIgnoreCase(reportName)) {
            whereClause += buildLocalInvoiceFilter();
        } else if (Constants.IV_QUOTATION.equalsIgnoreCase(reportName)) {
            whereClause += buildQuotationFilter();
        } else if (Constants.IV_DUTY_PAYMENT.equalsIgnoreCase(reportName)) {
            whereClause += buildDutyPaymentFilter();
        } else if (Constants.IV_INVOICE_WITH_TAX.equalsIgnoreCase(reportName)) {
            whereClause += buildInvoiceWithTaxFilter();
        } else if (Constants.IV_INVOICE_WITHOUT_TAX.equalsIgnoreCase(reportName)) {
            whereClause += buildInvoiceWithoutTaxFilter();
        }
        
        String soql = selectClause + fromClause + whereClause + orderByClause;
        itemList = Database.query(soql);

        buildMeisaiWrapper();
    }
    
    public List<AnkenMeisai__c> getListDisplay(){
        List<AnkenMeisai__c> results = itemList;
        if(results.size() < 15){
            for(Integer i = 0; i< 10; i++){
                results.add(new AnkenMeisai__c());
            }
        }
        return results;
    }
    private void buildMeisaiWrapper() {
        List<WrapperAnkenMeisai> wkWrapAnkenMeisaiList = new List<WrapperAnkenMeisai>();
        WrapperAnkenMeisai       wkWrapAnkenMeisai     = new WrapperAnkenMeisai();        
        Integer PageNo  = 0; //ページ番号
        Integer LoopCnt = 0; //ループ回数
        Syokei    = 0; //金額
        SyokeiUSD = 0;
        Syohizei  = 0; //消費税  
        SyohizeiUSD = 0;
        totalBuyAmountJPY = 0;
        totalBuyAmountUSD = 0;
        totalBuyTax = 0;
        sumAmountOfTaxBuyingUSD = 0;
        sumAmountOfTaxBuying = 0;
        sumAmountBuyingIncludingTax = 0;

        
        String pageName = String.isBlank(ApexPages.currentPage().getUrl()) ? '' : ApexPages.currentPage().getUrl().replaceAll('\\?.*', '').replaceAll('/apex/', '');
        Set<String> pagesWithPageSize14 = new Set<String>{
            'clofor_com_cfs__page_InvoiceENGJPY',
            'clofor_com_cfs__page_InvoiceENGVND',
            'clofor_com_cfs__page_InvoiceENGVND_Official',
            'clofor_com_cfs__proforma_invoice_USD',
            'clofor_com_cfs__page_VietnameOfficialInvoiceENTemplate',
            'clofor_com_cfs__page_FreightMemoVI',
            'clofor_com_cfs__page_InvoiceVI',
            'clofor_com_cfs__VietnameOfficialDebitENTemplate',
            'clofor_com_cfs__page_CreditDebitNoteENG',
            'clofor_com_cfs__page_CreditDebitNoteLOCAL'
        };
        Integer pageSize = pagesWithPageSize14.contains(pageName) ? 14 : Constants.PAGE_SIZE;
        
        if (itemList == null || itemList.isEmpty()) {
            wkWrapAnkenMeisaiList.add(wkWrapAnkenMeisai);
            wkWrapAnkenMeisai.gyoNo = 1;
        } else {
            for(AnkenMeisai__c temp :itemList){        
                LoopCnt++;
                Syokei    += (temp.SellAmountJPN__c != null ? temp.SellAmountJPN__c : 0);
                SyokeiUSD += (temp.SellAmountUSD__c != null ? temp.SellAmountUSD__c : 0);
                Syohizei  += (temp.SellTaxNum__c != null ? temp.SellTaxNum__c : 0);
                SyohizeiUSD  += (temp.SellTaxNum_USD__c != null ? temp.SellTaxNum_USD__c : 0);
                totalBuyAmountJPY += (temp.BuyAmountJPN__c != null ?temp.BuyAmountJPN__c : 0);
                totalBuyAmountUSD += (temp.BuyAmountUSD__c != null ?temp.BuyAmountUSD__c : 0);
                totalBuyTax += (temp.BuyTaxNum__c != null ?temp.BuyTaxNum__c : 0);
                sumAmountOfTaxBuyingUSD  += (temp.BuyTaxNum_USD__c != null ? temp.BuyTaxNum_USD__c : 0);
                sumAmountOfTaxBuying  += (temp.BuyTaxNum__c != null ? temp.BuyTaxNum__c : 0);
                sumAmountBuyingIncludingTax  += (temp.BuyInTaxAmountUSD__c != null ? temp.BuyInTaxAmountUSD__c : 0);
                
                wkWrapAnkenMeisai.objectList.add(temp);
                
                if( Math.mod(Loopcnt,pageSize) == 0 || LoopCnt == itemList.size()){
                    PageNo++;
                    wkWrapAnkenMeisai.gyoNo         = PageNo;
                    wkWrapAnkenMeisai.pageSyokei    = Syokei;
                    wkWrapAnkenMeisai.pageSyohizei  = Syohizei;
                    wkWrapAnkenMeisai.pageSyokeiUSD = SyokeiUSD;
                    wkWrapAnkenMeisai.pageSyohizeiUSD  = SyohizeiUSD;
                    wkWrapAnkenMeisai.subTotalBuyAmountUSD = totalBuyAmountUSD;
                    wkWrapAnkenMeisai.subTotalBuyAmount = totalBuyAmountJPY;
                    if(wkWrapAnkenMeisai.objectList.size() < 10){
                        if(pageName == 'clofor_com_cfs__proforma_invoice_USD'){
                            for(Integer i = 0; i< 10; i++){
                                AnkenMeisai__c newItem = new AnkenMeisai__c();
                                if(i==0){
                                    String description = 'S' + AnkenList.WkInitial__c + AnkenList.Name + '-' + AnkenList.QuotationVer__c;
                                    newItem.InsatuyouSyohinEng__c = description;
                                }
                                wkWrapAnkenMeisai.objectList.add(newItem);
                            }
                        }
                        
                    }
                    wkWrapAnkenMeisaiList.add(wkWrapAnkenMeisai);
                    
                    wkWrapAnkenMeisai = new WrapperAnkenMeisai();              
                }            
            }
        }


        SyokeiUSD = SyokeiUSD.setScale(2, System.RoundingMode.HALF_UP);
        SyohizeiUSD = SyohizeiUSD.setScale(2, System.RoundingMode.HALF_UP);


        Syokei = Syokei.setScale(0, System.RoundingMode.HALF_UP);
        Syohizei =Syohizei.setScale(0, System.RoundingMode.HALF_UP);

        WrapdisplayitemList = wkWrapAnkenMeisaiList;
        displayListSize = WrapdisplayitemList.size();
    }

    private String buildBBInvoiceFilter() {
        String filter = '';

        if (!StringUtils.isEmpty(customerId)) {
            filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';
        }
        
        return filter;
    }
    
    private String buildCreditNoteFilter() {
        /*String filter = ' AND (PaymentTo__r.Business_Relationship__c = \'' + Constants.PARTNER_RELATIONSHIP + '\' ' +
                ' OR PaymentTo__r.Business_Relationship__c = \'' + Constants.VENDOR_RELATIONSHIP + '\')';
        */
        String filter = '';
        filter += ' AND PaymentTo__r.Custom_Type__c != \'当社社内利用\'';

        if (Constants.CURRENCY_USD.equalsIgnoreCase(curr)) {
            filter += ' AND BuyAmountUSD__c > 0';
        } else {
            filter += ' AND BuyAmountJPN__c > 0';
        }
        
        if (!StringUtils.isEmpty(customerId)) {
            filter += ' AND PaymentTo__c = \'' + customerId + '\'';
        }
        
        return filter;
    }
    
    private String buildDebitNoteFilter() {
        String filter = ' AND (Seikyusaki__r.Business_Relationship__c = \'' + Constants.PARTNER_RELATIONSHIP + '\' ' +
                ' OR Seikyusaki__r.Business_Relationship__c = \'' + Constants.VENDOR_RELATIONSHIP + '\')';
        filter += ' AND Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';

        if (Constants.CURRENCY_USD.equalsIgnoreCase(curr)) {
            filter += ' AND SellAmountUSD__c > 0';
        } else {
            filter += ' AND SellAmountJPN__c > 0';
        }

        if (!StringUtils.isEmpty(customerId)) {
            filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';
        }
        
        return filter;
    }
    
    private String buildLocalInvoiceFilter() {
        String filter = ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        filter += ' AND Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';
        
        if (!StringUtils.isEmpty(customerId)) {
            if (filterByVATInvoiceTo) {
                filter += ' AND VAT_INVOICE_TO__r.Id = \'' + customerId + '\'';    
            } else {
                filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';    
            }
        }
        
        return filter;
    }
    
    private String buildQuotationFilter() {
        String filter = '';
        
        if (!StringUtils.isEmpty(customerId)) {
            filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';
        }
        
        return filter;
    }
    
    private String buildDutyPaymentFilter() {
        String filter = ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        filter += ' AND Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';
        filter += ' AND Selling_Tatekae__c = true AND Anken__r.DeadlineForPaymentOfExpense__c != null';
        
        if (!StringUtils.isEmpty(customerId)) {
            filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';
        }

        return filter;
    }
    
    private String buildInvoiceWithTaxFilter() {
        String filter = ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        filter += ' AND Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';
        //filter += ' AND TaxInitial__c > 0';
        
        if (!StringUtils.isEmpty(customerId)) {
            if (filterByVATInvoiceTo) {
                filter += ' AND VAT_INVOICE_TO__r.Id = \'' + customerId + '\'';    
            } else {
                filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';    
            }
        }
        
        return filter;
    }
    
    private String buildInvoiceWithoutTaxFilter() {
        String filter = ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        filter += ' AND Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';
        //filter += ' AND (TaxInitial__c = null OR TaxInitial__c = 0)';
        
        if (!StringUtils.isEmpty(customerId)) {
            if (filterByVATInvoiceTo) {
                filter += ' AND VAT_INVOICE_TO__r.Id = \'' + customerId + '\'';    
            } else {
                filter += ' AND Seikyusaki__r.Id = \'' + customerId + '\'';    
            }
        }
        return filter;
    }
    
    private void translatePaymentMethod(CustomObject1__c hbl) {
        if (!StringUtils.isEmpty(hbl.Field1__r.Payment_Method__c)) {
            String[] pms = hbl.Field1__r.Payment_Method__c.split(';');
            paymentMethods = '';      

            for (String pm : pms) {
                paymentMethods += (translations.containsKey(pm) ? translations.get(pm) : '') + ';';
            }
            
            if (!StringUtils.isEmpty(paymentMethods)) {
                paymentMethods = paymentMethods.substring(0, paymentMethods.length() - 1);
            }
        }
    }
    
    public class WrapperAnkenMeisai {
        public List<AnkenMeisai__c> objectList { get; set; }
        
        public integer gyoNo         { get; set; }
        public Decimal pageSyokei    { get; set; }
        public Decimal pageSyohizei  { get; set; }
        public Decimal pageSyokeiUSD    { get; set; }
        public Decimal pageSyohizeiUSD  { get; set; }
        public Decimal subTotalBuyAmountUSD { get; set; }
        public Decimal subTotalBuyAmount { get; set; }

        public WrapperAnkenMeisai(){
            objectList = new List<AnkenMeisai__c>();
        }
    }
}