public with sharing class PaymentReportLocalController {

    public String fowarding { get; set; }

    public String AnkenList { get; set; }
    public CustomObject1__c forwarding                {get; private set;} 
    public List<InvoicingPageWrapper> pageWrapperList {get; private set;}
    public Map<String, String> translations           {get; private set;}
    
    public String forwardingId                 {get; private set;} 
    public Boolean AppearFlag                  {get; private set;} 
    public Boolean showQuotationTotal          {get; private set;}
    public Boolean DebitReportFlag             {get; private set;}
    public Boolean filterByVATInvoiceTo        {get; private set;}
    public String paymentMethods               {get; private set;}
    public Integer totalPages                  {get; private set;}
    public Decimal vatPercentage               {get; private set;}
    public String reportedCustomerName         {get; private set;}
    public String reportedCustomerAddress      {get; private set;}
    public String reportedCustomerTelFax       {get; private set;}
    public Decimal balanceAmountUSD            {get; private set;}
    public Decimal sellingExchangeRate         {get; private set;}
    public Decimal buyingExchangeRate          {get; private set;}
    public String balanceAmountText            {get; private set;}

    public String debitUnitCostFormat          {get; private set;}
    public String debitUnitCostUSDFormat       {get; private set;}
    public String debitAmountFormat            {get; private set;}
    public String debitAmountUSDFormat         {get; private set;}
    public String debitTaxFormat               {get; private set;}
    public String debitTaxUSDFormat            {get; private set;}
    public String debitTaxPercentageFormat     {get; private set;}
    public String creditUnitCostFormat         {get; private set;}
    public String creditUnitCostUSDFormat      {get; private set;}
    public String creditAmountFormat           {get; private set;}
    public String creditAmountUSDFormat        {get; private set;}
    public String creditTaxFormat              {get; private set;}
    public String creditTaxUSDFormat           {get; private set;}
    public String creditTaxPercentageFormat    {get; private set;}
    public String balanceAmountFormat          {get; private set;}
    public String totalDebitAmountFormat       {get; private set;}
    public String totalCreditAmountFormat      {get; private set;}
    public String sellingExchangeRateFormat    {get; private set;}
    public String buyingExchangeRateFormat     {get; private set;}

    public Integer debitUnitCostScale          {get; private set;}
    public Integer debitUnitCostUSDScale       {get; private set;}
    public Integer debitAmountScale            {get; private set;}
    public Integer debitAmountUSDScale         {get; private set;}
    public Integer debitTaxScale               {get; private set;}
    public Integer debitTaxUSDScale            {get; private set;}
    public Integer debitTaxPercentageScale     {get; private set;}
    public Integer creditUnitCostScale         {get; private set;}
    public Integer creditUnitCostUSDScale      {get; private set;}
    public Integer creditAmountScale           {get; private set;}
    public Integer creditAmountUSDScale        {get; private set;}
    public Integer creditTaxScale              {get; private set;}
    public Integer creditTaxUSDScale           {get; private set;}
    public Integer creditTaxPercentageScale    {get; private set;}
    public Integer sellingExchangeRateScale    {get; private set;}
    public Integer buyingExchangeRateScale    {get; private set;}
    
    private String reportName;
    private String language;
    private String customerId;
    private static List<String> invoicingFields = new List<String>();
    private static List<String> forwardingFields = new List<String>();
    private List<AnkenMeisai__c> invoicingList {get; private set;}
    private Decimal debitUnitCostDefaultValue;
    private Decimal debitUnitCostUSDDefaultValue;
    private Decimal debitAmountDefaultValue;
    private Decimal debitAmountUSDDefaultValue;
    private Decimal debitTaxDefaultValue;
    private Decimal debitTaxUSDDefaultValue;
    private Decimal debitTaxPercentageDefaultValue;
    private Decimal creditUnitCostDefaultValue;
    private Decimal creditUnitCostUSDDefaultValue;
    private Decimal creditAmountDefaultValue;
    private Decimal creditAmountUSDDefaultValue;
    private Decimal creditTaxDefaultValue;
    private Decimal creditTaxUSDDefaultValue;
    private Decimal creditTaxPercentageDefaultValue;
    
    public PaymentReportLocalController() {

        debitUnitCostFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaJPY__c');
        debitUnitCostUSDFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaUSD__c');
    	debitAmountFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
    	debitAmountUSDFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
    	debitTaxFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum__c');
    	debitTaxUSDFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum_USD__c');
    	debitTaxPercentageFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__TaxInitial__c');
    	creditUnitCostFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTankaJPY__c');
    	creditUnitCostUSDFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTankaUSD__c');
    	creditAmountFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyAmountJPN__c');
    	creditAmountUSDFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyAmountUSD__c');
    	creditTaxFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTaxNum__c');
    	creditTaxUSDFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum_USD__c');
   		creditTaxPercentageFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTaxInitial__c');
        sellingExchangeRateFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__KawaseSel__c');
        buyingExchangeRateFormat = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__KawaseBay__c');

        totalDebitAmountFormat = debitAmountFormat.length() > debitTaxFormat.length() ? debitAmountFormat: debitTaxFormat;
        totalCreditAmountFormat = creditAmountFormat.length() > creditTaxFormat.length() ? creditAmountFormat : creditTaxFormat;
        balanceAmountFormat = totalDebitAmountFormat.length() > totalCreditAmountFormat.length() ? totalDebitAmountFormat: totalCreditAmountFormat;

        debitUnitCostDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaJPY__c');
        debitUnitCostUSDDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaUSD__c');
    	debitAmountDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
    	debitAmountUSDDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
    	debitTaxDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum__c');
    	debitTaxUSDDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum_USD__c');
    	debitTaxPercentageDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__TaxInitial__c');
    	creditUnitCostDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTankaJPY__c');
    	creditUnitCostUSDDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTankaUSD__c');
    	creditAmountDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyAmountJPN__c');
    	creditAmountUSDDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyAmountUSD__c');
    	creditTaxDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTaxNum__c');
    	creditTaxUSDDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum_USD__c');
   		creditTaxPercentageDefaultValue = setDefaultValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTaxInitial__c');

        debitUnitCostScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaJPY__c');
        debitUnitCostUSDScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaUSD__c');
        debitAmountScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        debitAmountUSDScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        debitTaxScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum__c');
        debitTaxUSDScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum_USD__c');
        debitTaxPercentageScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__TaxInitial__c');
        creditUnitCostScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTankaJPY__c');
        creditUnitCostUSDScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTankaUSD__c');
        creditAmountScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyAmountJPN__c');
        creditAmountUSDScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyAmountUSD__c');
        creditTaxScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTaxNum__c');
        creditTaxUSDScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTaxNum_USD__c');
        creditTaxPercentageScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__BuyTaxInitial__c');
        sellingExchangeRateScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__KawaseSel__c');
        buyingExchangeRateScale = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__KawaseBay__c');

        GetURLPram();
        
        if (Constants.IV_DEBIT_NOTE.equalsIgnoreCase(reportName)) {
            DebitReportFlag = true;
        } else {
            DebitReportFlag = false;
        }
        
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying() 
            && PermissionValidationUtil.isAccessibleUser() && PermissionValidationUtil.isAccessibleAccount() 
            && PermissionValidationUtil.isAccessiblePort() && PermissionValidationUtil.isAccessibleServiceMaster()) {
                findForwarding();
                if(forwarding != null) {
                    GetAnkenMeisai();
                    determineVAT();
                } else {
                    buildPageWrappers();
                }
                
            }
        if(forwarding != null) {
            initializeTranslation();
            translatePaymentMethod(forwarding);
        }
        
    }
    
    private Decimal setDefaultValue(String sObjectName, String sObjectFieldName) {
        Integer scaleNum = ((SObject)(Type.forName('Schema.'+sObjectName).newInstance())).getSObjectType().getDescribe().fields.getMap().get(sObjectFieldName).getDescribe().getScale();
    	switch on scaleNum {
    		when 1 {
        		return 0.0;
    		}	
    		when 2 {
        		return 0.00;
    		}
    		when 3 {
        		return 0.000;
    		}
            when 4 {
        		return 0.0000;
    		}
    		when else {	
        		return 0;
    		}
		}
    }

    private Integer setScaleValue(String sObjectName, String sObjectFieldName) {
        return ((SObject)(Type.forName('Schema.'+sObjectName).newInstance())).getSObjectType().getDescribe().fields.getMap().get(sObjectFieldName).getDescribe().getScale();
    }

    private String setFormatValue(String sObjectName, String sObjectFieldName) {
        Integer scaleNum = ((SObject)(Type.forName('Schema.'+sObjectName).newInstance())).getSObjectType().getDescribe().fields.getMap().get(sObjectFieldName).getDescribe().getScale();
    	switch on scaleNum {
            when 0 {
        		return'{0,number,###,###,###,##0}';
    		}	
    		when 1 {
        		return'{0,number,###,###,###,##0.0}';
    		}	
    		when 2 {
        		return '{0,number,###,###,###,##0.00}';
    		}
    		when 3 {
        		return '{0,number,###,###,###,##0.000}';
    		}
            when 4 {
        		return '{0,number,###,###,###,##0.0000}';
    		}
            when 5 {
        		return '{0,number,###,###,###,##0.00000}';
    		}
    		when else {	
        		return '{0,number,###,###,###,##0.000}';
    		}
		}
    }
    
    private void determineVAT() {
        vatPercentage = 0;
        if (invoicingList != null && invoicingList.size() > 0) {
            for (AnkenMeisai__c m : invoicingList) {
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
        forwardingId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
        reportName = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_REPORT_NAME));
        language = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_LANGUAGE));
        customerId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CUSTOMER_ID));
        system.debug('forwardingId: '+forwardingId);
        system.debug('customerId: '+customerId);
        
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
    
    private void findForwarding() {
        try{
            final String query = 'SELECT ' + String.join(forwardingFields, ',') + ' FROM CustomObject1__c WHERE Id = \'' 
                + StringUtils.escapeSingleQuotes(forwardingId) + '\'';
            forwarding = Database.query(query);
        } catch(Exception error) {
            system.debug('Error: ' +error);
        }
        
    }

    private void GetAnkenMeisai() {
        try{
            String consolidationRTId = RecordTypeUtil.getRecordTypeIdByDeveloperName(AnkenMeisai__c.SObjectType, Constants.SELLING_BUYING_CONSOLIDATION_RT);
            String selectClause = 'SELECT ' + String.join(invoicingFields, ',');
            String fromClause = ' FROM AnkenMeisai__c ';
            String whereClause = ' WHERE Anken__c = \'' + forwarding.id 
                + '\' AND PrintFlag__c = true';
            if(consolidationRTId != null){
                whereClause +=' AND RecordTypeId != \'' + consolidationRTId + '\'';
            }
            String orderByClause = ' ORDER BY SeikyuBangou__c NULLS LAST, CreatedDate';
            whereClause += buildFilter();
            String soql = selectClause + fromClause + whereClause + orderByClause;
            
            system.debug('soql: '+soql);
            system.debug('soql: '+fromClause + whereClause + orderByClause);

            invoicingList = Database.query(soql);
            
              
        } catch(Exception error) {
            system.debug('Error: ' +error);
        }
        buildPageWrappers();
        
    }
    
    private void buildPageWrappers() {
        pageWrapperList = new List<InvoicingPageWrapper>();
        InvoicingPageWrapper pageWrapper = new InvoicingPageWrapper();        
        Integer pageNo = 0;
        Integer count = 0;
        Integer countToSeparatePage = 0;
        Decimal pageAmountOfSelling = 0;
        Decimal pageAmountOfSellingUSD = 0;
        Decimal pageAmountOfTaxSelling = 0; 
        Decimal pageAmountOfTaxSellingUSD = 0;
        Decimal pageAmountOfBuying = 0;
        Decimal pageAmountOfBuyingUSD = 0;
        Decimal pageAmountOfTaxBuying = 0;
        Decimal pageAmountOfTaxBuyingUSD = 0;
        balanceAmountUSD = 0;

        if (invoicingList == null || invoicingList.isEmpty()) {
            pageWrapperList.add(pageWrapper);
            pageWrapper.pageNo = 1;
        } else {
            for(AnkenMeisai__c invoicing :invoicingList){        
                count++;
                countToSeparatePage++;
                InvoiceWrapper invoiceWrapper = new InvoiceWrapper();
                //invoiceWrapper.index = invoicing.SeikyuBangou__c;
                invoiceWrapper.index = count;
                invoiceWrapper.description = invoicing.InsatuyouSyohinEng__c;
                invoiceWrapper.curr = invoicing.curr__c;
                invoiceWrapper.unit = translateUnit(invoicing);
                invoiceWrapper.unitContainerSize = invoicing.ContainerSizeFormula__c;
                invoiceWrapper.unitChargeFormula = invoicing.ChargeUnitFormula__c;
                invoiceWrapper.unitCharge = invoicing.wkSuryo__c;
                invoiceWrapper.containerSize = invoicing.Tariff__r.ContainerSize__c;
                invoiceWrapper.productTax = invoicing.ProductTax__c;
                
                invoiceWrapper.debitUnitCost = debitUnitCostDefaultValue;
            	invoiceWrapper.debitUnitCostUSD = debitUnitCostUSDDefaultValue;
            	invoiceWrapper.debitAmount = debitAmountDefaultValue;
            	invoiceWrapper.debitAmountUSD = debitAmountUSDDefaultValue;
            	invoiceWrapper.debitTax = debitTaxDefaultValue;
            	invoiceWrapper.debitTaxUSD = debitTaxUSDDefaultValue;
            	invoiceWrapper.debitTaxPercentage = debitTaxPercentageDefaultValue;
            	invoiceWrapper.creditUnitCost = creditUnitCostDefaultValue;
            	invoiceWrapper.creditUnitCostUSD = creditUnitCostUSDDefaultValue;
            	invoiceWrapper.creditAmount = creditAmountDefaultValue;
            	invoiceWrapper.creditAmountUSD = creditAmountUSDDefaultValue;
            	invoiceWrapper.creditTax = creditTaxDefaultValue;
            	invoiceWrapper.creditTaxUSD = creditTaxUSDDefaultValue;
            	invoiceWrapper.creditTaxPercentage = creditTaxPercentageDefaultValue;
                
                if (isDebit(invoicing)) {
                    if (StringUtils.isEmpty(reportedCustomerName)) {
                        reportedCustomerName = invoicing.Seikyusaki__r.EnglishCompanyName__c;
                    }
                    if (StringUtils.isEmpty(reportedCustomerAddress)) {
                        reportedCustomerAddress = invoicing.Seikyusaki__r.EnglishAddress__c;
                    }
                    if (sellingExchangeRate == null) {
                        if(!String.isBlank(String.valueOf(invoicing.KawaseSel__c))){
                            sellingExchangeRate = invoicing.KawaseSel__c;
                        	sellingExchangeRate = sellingExchangeRate.setScale(sellingExchangeRateScale, System.RoundingMode.HALF_UP);
                        }
                    }
                    List<String> telFax = new List<String>();
                    if(!String.isBlank(invoicing.Seikyusaki__r.Phone)){
                        telFax.add(invoicing.Seikyusaki__r.Phone);
                    }
                    if(!String.isBlank(invoicing.Seikyusaki__r.Fax)){
                        telFax.add(invoicing.Seikyusaki__r.Fax);
                    }
                    reportedCustomerTelFax = String.join(telFax, ' & ');

                    invoiceWrapper.debitUnitCost = invoicing.SellTankaJPY__c;
                    //invoiceWrapper.debitUnitCost = invoiceWrapper.debitUnitCost.setScale(debitUnitCostScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitUnitCost))){
                        invoiceWrapper.debitUnitCost = invoiceWrapper.debitUnitCost.setScale(debitUnitCostScale, System.RoundingMode.HALF_UP);
                    }
                    invoiceWrapper.debitUnitCostUSD = invoicing.SellTankaUSD__c;
                    //invoiceWrapper.debitUnitCostUSD = invoiceWrapper.debitUnitCostUSD.setScale(debitUnitCostUSDScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitUnitCostUSD))){
                        invoiceWrapper.debitUnitCostUSD = invoiceWrapper.debitUnitCostUSD.setScale(debitUnitCostUSDScale, System.RoundingMode.HALF_UP);
                    }
                    
                    invoiceWrapper.debitAmount = invoicing.SellAmountJPN__c;
                    //invoiceWrapper.debitAmount = invoiceWrapper.debitAmount.setScale(debitAmountScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitAmount))){
                        invoiceWrapper.debitAmount = invoiceWrapper.debitAmount.setScale(debitAmountScale, System.RoundingMode.HALF_UP);
                    }
                    
                    invoiceWrapper.debitAmountUSD = invoicing.SellAmountUSD__c;
                    //invoiceWrapper.debitAmountUSD = invoiceWrapper.debitAmountUSD.setScale(debitAmountUSDScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitAmountUSD))){
                        invoiceWrapper.debitAmountUSD = invoiceWrapper.debitAmountUSD.setScale(debitAmountUSDScale, System.RoundingMode.HALF_UP);
                    }
                    
                    invoiceWrapper.debitTax = invoicing.SellTaxNum__c;
                    //invoiceWrapper.debitTax = invoiceWrapper.debitTax.setScale(debitTaxScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitTax))){
                        invoiceWrapper.debitTax = invoiceWrapper.debitTax.setScale(debitTaxScale, System.RoundingMode.HALF_UP);
                    }
                    
                    invoiceWrapper.debitTaxUSD = invoicing.SellTaxNum_USD__c;
                    //invoiceWrapper.debitTaxUSD = invoiceWrapper.debitTaxUSD.setScale(debitTaxUSDScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitTaxUSD))){
                        invoiceWrapper.debitTaxUSD = invoiceWrapper.debitTaxUSD.setScale(debitTaxUSDScale, System.RoundingMode.HALF_UP);
                    }
                    
                    invoiceWrapper.debitTaxPercentage = invoicing.TaxInitial__c;
                    //invoiceWrapper.debitTaxPercentage = invoiceWrapper.debitTaxPercentage.setScale(debitTaxPercentageScale, System.RoundingMode.HALF_UP);
                    if(!String.isBlank(String.valueOf(invoiceWrapper.debitTaxPercentage))){
                        invoiceWrapper.debitTaxPercentage = invoiceWrapper.debitTaxPercentage.setScale(debitTaxPercentageScale, System.RoundingMode.HALF_UP);
                    }

                    pageAmountOfSelling += invoicing.SellAmountJPN__c;
                    pageAmountOfSellingUSD += invoicing.SellAmountUSD__c;
                    pageAmountOfTaxSelling += invoicing.SellTaxNum__c;
                    pageAmountOfTaxSellingUSD += invoicing.SellTaxNum_USD__c;
                }
                
                if (isCredit(invoicing)) {
                    if (StringUtils.isEmpty(reportedCustomerName)) {
                        reportedCustomerName = invoicing.PaymentTo__r.EnglishCompanyName__c;
                        
                    }
                    if (StringUtils.isEmpty(reportedCustomerAddress)) {
                        reportedCustomerAddress = invoicing.PaymentTo__r.EnglishAddress__c;
                    }
                    
                    if (buyingExchangeRate == null) {
                        buyingExchangeRate = invoicing.KawaseBay__c;
                        buyingExchangeRate = buyingExchangeRate.setScale(buyingExchangeRateScale, System.RoundingMode.HALF_UP);
                    }
                    List<String> telFax = new List<String>();
                    if(!String.isBlank(invoicing.PaymentTo__r.Phone)){
                        telFax.add(invoicing.PaymentTo__r.Phone);
                    }
                    if(!String.isBlank(invoicing.PaymentTo__r.Fax)){
                        telFax.add(invoicing.PaymentTo__r.Fax);
                    }
                    reportedCustomerTelFax = String.join(telFax, ' & ');

                    invoiceWrapper.creditUnitCost = invoicing.BuyTankaJPY__c;
                    invoiceWrapper.creditUnitCost = invoiceWrapper.creditUnitCost.setScale(creditUnitCostScale, System.RoundingMode.HALF_UP);
                    invoiceWrapper.creditUnitCostUSD = invoicing.BuyTankaUSD__c;
                    invoiceWrapper.creditUnitCostUSD = invoiceWrapper.creditUnitCostUSD.setScale(creditUnitCostUSDScale, System.RoundingMode.HALF_UP);
                    invoiceWrapper.creditAmount = invoicing.BuyAmountJPN__c;
                    invoiceWrapper.creditAmount = invoiceWrapper.creditAmount.setScale(creditAmountScale, System.RoundingMode.HALF_UP);
                    invoiceWrapper.creditAmountUSD = invoicing.BuyAmountUSD__c;
                    invoiceWrapper.creditAmountUSD = invoiceWrapper.creditAmountUSD.setScale(creditAmountUSDScale, System.RoundingMode.HALF_UP);
                    invoiceWrapper.creditTax = invoicing.BuyTaxNum__c;
                    invoiceWrapper.creditTax = invoiceWrapper.creditTax.setScale(creditTaxScale, System.RoundingMode.HALF_UP);
                    invoiceWrapper.creditTaxUSD = invoicing.BuyTaxNum_USD__c;
                    invoiceWrapper.creditTaxUSD = invoiceWrapper.creditTaxUSD.setScale(creditTaxUSDScale, System.RoundingMode.HALF_UP);
                    invoiceWrapper.creditTaxPercentage = invoicing.BuyTaxInitial__c;
                    invoiceWrapper.creditTaxPercentage = invoiceWrapper.creditTaxPercentage.setScale(creditTaxPercentageScale, System.RoundingMode.HALF_UP);

                    pageAmountOfBuying += invoicing.BuyAmountJPN__c;
                    pageAmountOfBuyingUSD += invoicing.BuyAmountUSD__c;
                    pageAmountOfTaxBuying += invoicing.BuyTaxNum__c;
                    pageAmountOfTaxBuyingUSD += invoicing.BuyTaxNum_USD__c;
                }
                
                pageWrapper.invoicingList.add(invoiceWrapper);
                
                if( Math.mod(countToSeparatePage,17) == 0 || countToSeparatePage == invoicingList.size()){
                    count =0;
                    pageNo++;
                    pageWrapper.pageNo = pageNo;
                    
                    pageWrapper.pageAmountOfSelling = pageAmountOfSelling;
                    pageWrapper.pageAmountOfTaxSelling = pageAmountOfTaxSelling;
                    pageWrapper.pageAmountOfSellingUSD = pageAmountOfSellingUSD;
                    pageWrapper.pageAmountOfTaxSellingUSD = pageAmountOfTaxSellingUSD;
                    pageWrapper.subTotalSellingAmount = pageAmountOfSelling + pageAmountOfTaxSelling;
                    pageWrapper.subTotalSellingAmountUSD = pageAmountOfSellingUSD + pageAmountOfTaxSellingUSD;
                    
                    pageWrapper.pageAmountOfBuying = pageAmountOfBuying;
                    pageWrapper.pageAmountOfTaxBuying = pageAmountOfTaxBuying;
                    pageWrapper.pageAmountOfBuyingUSD = pageAmountOfBuyingUSD;
                    pageWrapper.pageAmountOfTaxBuyingUSD = pageAmountOfTaxBuyingUSD;
                    pageWrapper.subTotalBuyingAmount = pageAmountOfBuying + pageAmountOfTaxBuying;
                    //pageWrapper.subTotalBuyingAmountUSD = pageAmountOfBuyingUSD + pageAmountOfTaxBuyingUSD;
                    pageWrapper.subTotalBuyingAmountUSD = pageAmountOfBuyingUSD + pageAmountOfTaxBuyingUSD;
                    
                    balanceAmountUSD = pageWrapper.subTotalSellingAmountUSD - pageWrapper.subTotalBuyingAmountUSD;
                    
                    pageWrapperList.add(pageWrapper);                    
                    pageWrapper = new InvoicingPageWrapper();  
                }            
            }
        }

        pageAmountOfSellingUSD = pageAmountOfSellingUSD;

        if (balanceAmountUSD != null) {
            balanceAmountUSD = balanceAmountUSD;
            balanceAmountText = NumbericUtils.readUSDAmount(balanceAmountUSD);
        }

        totalPages = pageWrapperList.size();
    }
    private String translateUnit(AnkenMeisai__c invoicing){
        String unit = invoicing.ChargeUnitFormula__c;
        if(invoicing.ChargeUnitFormula__c =='本'){
                unit = 'Unit';
            } 
        if(invoicing.ChargeUnitFormula__c =='コンテナ' || invoicing.ChargeUnitFormula__c =='Container'){
            unit = invoicing.ContainerSizeFormula__c;
            if(String.isBlank(unit)){
                unit = 'Container';
            }
        }
        if(invoicing.ChargeUnitFormula__c =='件'){
            unit = 'Case';
        }
        return unit;
    }
    private String buildFilter() {
        // String debitFilter = ' (Seikyusaki__r.Business_Relationship__c = \'' + Constants.PARTNER_RELATIONSHIP + '\'';
        // debitFilter += ' AND Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';
        String debitFilter = '(Seikyusaki__r.Custom_Type__c != \'当社社内利用\'';
        debitFilter += ' AND SellAmountUSD__c > 0';
        debitFilter += ' AND Seikyusaki__r.Id = \'' + customerId + '\')';
        
        // String creditFilter = ' (PaymentTo__r.Business_Relationship__c = \'' + Constants.PARTNER_RELATIONSHIP + '\'';
        // creditFilter += ' AND PaymentTo__r.Custom_Type__c != \'当社社内利用\'';
        String creditFilter = '(PaymentTo__r.Custom_Type__c != \'当社社内利用\'';
        creditFilter += ' AND BuyAmountUSD__c > 0';
        creditFilter += ' AND PaymentTo__r.Id = \'' + customerId + '\')';
        
        String filter = ' AND (' + debitFilter + ' OR ' + creditFilter + ')';
        
        return filter;
    }
    
    private Boolean isDebit(AnkenMeisai__c invoicing) {
        System.debug(' customerId.equalsIgnoreCase(invoicing.Seikyusaki__r.Id): '+( customerId.equalsIgnoreCase(invoicing.Seikyusaki__r.Id)));
        System.debug(' customerId: '+( customerId));
        System.debug(' (invoicing.Seikyusaki__r.Id): '+( (invoicing.Seikyusaki__r.Id)));
        return (!PicklistReference.INTERNAL_TYPE.equalsIgnoreCase(invoicing.Seikyusaki__r.Custom_Type__c)
               && invoicing.SellAmountUSD__c > 0
               && customerId.equalsIgnoreCase(invoicing.Seikyusaki__r.Id));
    }
    
    private Boolean isCredit(AnkenMeisai__c invoicing) {
        return (!PicklistReference.INTERNAL_TYPE.equalsIgnoreCase(invoicing.PaymentTo__r.Custom_Type__c)
               && invoicing.BuyAmountUSD__c > 0
               && customerId.equalsIgnoreCase(invoicing.PaymentTo__r.Id));
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
    
    public class InvoicingPageWrapper {
        public List<InvoiceWrapper> invoicingList      { get; set; }
        public Integer pageNo                          { get; set; }
        public Decimal pageAmountOfSelling             { get; set; }
        public Decimal pageAmountOfSellingUSD          { get; set; }
        public Decimal pageAmountOfTaxSelling          { get; set; }
        public Decimal pageAmountOfTaxSellingUSD       { get; set; }
        public Decimal subTotalSellingAmount           { get; set; }
        public Decimal subTotalSellingAmountUSD        { get; set; }
        
        public Decimal pageAmountOfBuying             { get; set; }
        public Decimal pageAmountOfBuyingUSD          { get; set; }
        public Decimal pageAmountOfTaxBuying          { get; set; }
        public Decimal pageAmountOfTaxBuyingUSD       { get; set; }
        public Decimal subTotalBuyingAmount           { get; set; }
        public Decimal subTotalBuyingAmountUSD        { get; set; }
        
        public InvoicingPageWrapper(){
            invoicingList = new List<InvoiceWrapper>();
            pageAmountOfSelling             = 0;
            pageAmountOfSellingUSD          = 0;
            pageAmountOfTaxSelling          = 0;
            pageAmountOfTaxSellingUSD       = 0;
            subTotalSellingAmount           = 0;
            subTotalSellingAmountUSD        = 0;
            
            pageAmountOfBuying             = 0;
            pageAmountOfBuyingUSD          = 0;
            pageAmountOfTaxBuying          = 0;
            pageAmountOfTaxBuyingUSD       = 0;
            subTotalBuyingAmount           = 0;
            subTotalBuyingAmountUSD        = 0;
        }
    }
    
    public class InvoiceWrapper {
        public String unitContainerSize{get;set;}
        public Decimal index {get; set;}
        public String description {get; set;}
        public String curr {get; set;}
        public String unit {get; set;}
        public String unitChargeFormula{get;set;}
        public String unitCharge {get; set;}
        public String containerSize {get; set;}
        public String productTax {get; set;}
        public Decimal debitUnitCost {get; set;}
        public Decimal debitUnitCostUSD {get; set;}
        public Decimal debitAmount {get; set;}
        public Decimal debitAmountUSD {get; set;}
        public Decimal debitTax {get; set;}
        public Decimal debitTaxUSD {get; set;}
        public String debitTaxType {get; set;}
        public Decimal debitTaxPercentage {get; set;}
        public Decimal creditUnitCost {get; set;}
        public Decimal creditUnitCostUSD {get; set;}
        public Decimal creditAmount {get; set;}
        public Decimal creditAmountUSD {get; set;}
        public Decimal creditTax {get; set;}
        public Decimal creditTaxUSD {get; set;}
        public String creditTaxType {get; set;}
        public Decimal creditTaxPercentage {get; set;}
        
        public InvoiceWrapper() {
            debitUnitCost = 0;
            debitUnitCostUSD = 0;
            debitAmount = 0;
            debitAmountUSD = 0;
            debitTax = 0;
            debitTaxUSD = 0;
            debitTaxPercentage = 0;
            creditUnitCost = 0;
            creditUnitCostUSD = 0;
            creditAmount = 0;
            creditAmountUSD = 0;
            creditTax = 0;
            creditTaxUSD = 0;
            creditTaxPercentage = 0;
        }
    }

    static {
        invoicingFields.add('Id');
        invoicingFields.add('Name');
        invoicingFields.add('Anken__c');
        invoicingFields.add('SeikyuBangou__c');
        invoicingFields.add('InsatuyouSyohin__c');
        invoicingFields.add('SellTankaJPY__c');
        invoicingFields.add('SellTankaUSD__c');
        invoicingFields.add('BuyTankaJPY__c');
        invoicingFields.add('BuyTankaUSD__c');
        invoicingFields.add('Tariff__r.UNIT__c');
        invoicingFields.add('ChargeUnitInPrint__c');
        invoicingFields.add('ChargeUnitFormula__c');
        invoicingFields.add('ContainerSizeFormula__c');
        invoicingFields.add('Tariff__r.TAX__c');
        invoicingFields.add('Tariff__r.ContainerSize__c');
        invoicingFields.add('Suryo__c');
        invoicingFields.add('wkSuryo__c');
        invoicingFields.add('SellAmountJPN__c');
        invoicingFields.add('SellAmountUSD__c');
        invoicingFields.add('BuyAmountJPN__c');
        invoicingFields.add('BuyAmountUSD__c');
        invoicingFields.add('SellTaxNum__c');
        invoicingFields.add('BuyTaxNum__c');
        invoicingFields.add('curr__c');
        invoicingFields.add('ProductTax__c');
        invoicingFields.add('wkTaxFlag__c');
        invoicingFields.add('Bikou__c');
        invoicingFields.add('PartnerProduct__c');
        invoicingFields.add('Seikyusaki__r.Name');
        invoicingFields.add('Seikyusaki__r.EnglishCompanyName__c');
        invoicingFields.add('Seikyusaki__r.REGISTERATION_NO_FORM__c');
        invoicingFields.add('Seikyusaki__r.REGISTRATION_NO_SERIAL__c');
        invoicingFields.add('Seikyusaki__r.TAX_CODE__c');
        invoicingFields.add('Seikyusaki__r.Bank1__c');        
        invoicingFields.add('Seikyusaki__r.EnglishAddress__c ');
        invoicingFields.add('Seikyusaki__r.BillingStreet'); 
        invoicingFields.add('Seikyusaki__r.BillingCity'); 
        invoicingFields.add('Seikyusaki__r.BillingState'); 
        invoicingFields.add('Seikyusaki__r.BillingCountry'); 
        invoicingFields.add('Seikyusaki__r.Payment_Method__c');
        invoicingFields.add('Seikyusaki__r.Phone'); 
        invoicingFields.add('Seikyusaki__r.Fax');
        invoicingFields.add('VAT_INVOICE_TO__r.Name');
        invoicingFields.add('VAT_INVOICE_TO__r.EnglishCompanyName__c');
        invoicingFields.add('VAT_INVOICE_TO__r.REGISTERATION_NO_FORM__c');
        invoicingFields.add('VAT_INVOICE_TO__r.REGISTRATION_NO_SERIAL__c');
        invoicingFields.add('VAT_INVOICE_TO__r.TAX_CODE__c');
        invoicingFields.add('VAT_INVOICE_TO__r.Bank1__c');        
        invoicingFields.add('VAT_INVOICE_TO__r.EnglishAddress__c ');
        invoicingFields.add('VAT_INVOICE_TO__r.BillingStreet'); 
        invoicingFields.add('VAT_INVOICE_TO__r.BillingCity'); 
        invoicingFields.add('VAT_INVOICE_TO__r.BillingState'); 
        invoicingFields.add('VAT_INVOICE_TO__r.BillingCountry'); 
        invoicingFields.add('VAT_INVOICE_TO__r.Payment_Method__c');
        invoicingFields.add('PaymentTo__r.Name');
        invoicingFields.add('PaymentTo__r.EnglishCompanyName__c');
        invoicingFields.add('PaymentTo__r.REGISTERATION_NO_FORM__c');
        invoicingFields.add('PaymentTo__r.REGISTRATION_NO_SERIAL__c');
        invoicingFields.add('PaymentTo__r.TAX_CODE__c');
        invoicingFields.add('PaymentTo__r.Bank1__c');        
        invoicingFields.add('PaymentTo__r.EnglishAddress__c');
        invoicingFields.add('InsatuyouSyohinEng__c');
        invoicingFields.add('Tariff__r.EngTani__c');
        invoicingFields.add('PrintFlag__c');
        invoicingFields.add('TaxInitial__c');
        invoicingFields.add('KawaseSel__c');
        invoicingFields.add('KawaseBay__c'); 
        invoicingFields.add('SellTaxNum_USD__c');
        invoicingFields.add('BuyTaxInitial__c');
        invoicingFields.add('BuyTaxNum_USD__c');
        invoicingFields.add('BuyInTaxAmountUSD__c');
        invoicingFields.add('Seikyusaki__r.Business_Relationship__c');
        invoicingFields.add('PaymentTo__r.Business_Relationship__c');
        invoicingFields.add('Seikyusaki__r.Custom_Type__c');
        invoicingFields.add('PaymentTo__r.Custom_Type__c');
        invoicingFields.add('PaymentTo__r.Phone'); 
        invoicingFields.add('PaymentTo__r.Fax');
        forwardingFields.add('ID');
        forwardingFields.add('Name');
        forwardingFields.add('WkInitial__c');
        forwardingFields.add('ID__c');
        forwardingFields.add('PersonInCharge__c');
        //forwardingFields.add('InChargeOfQuotation__c');
        forwardingFields.add('CustmerInCharge__r.name');
        forwardingFields.add('QuotationCheck__c');
        forwardingFields.add('ExpiryDate__c');
        forwardingFields.add('BUYING__c');
        forwardingFields.add('ExchangeRate__c');
        forwardingFields.add('Item__c');
        forwardingFields.add('weight__c');
        forwardingFields.add('CBM__c');
        forwardingFields.add('POL__r.City_Name__c');
        forwardingFields.add('POD__r.City_Name__c');
        forwardingFields.add('POL__r.Name');
        forwardingFields.add('POD__r.Name');
        forwardingFields.add('QuoationDescription__c');
        forwardingFields.add('carton__c');
        forwardingFields.add('CarrierType__c');
        forwardingFields.add('ReimbursementCondition__c');
        forwardingFields.add('QuotationPrintDate__c');
        forwardingFields.add('QuotationVer__c');
        forwardingFields.add('HBL__c');
        forwardingFields.add('HAWB__c');
        forwardingFields.add('Vessle__c');
        forwardingFields.add('FlightNo__c');
        forwardingFields.add('Voy_No__c');                
        forwardingFields.add('ETD__c');
        forwardingFields.add('ETA__c');
        forwardingFields.add('DeadlineForPaymentOfInvoices__c');
        forwardingFields.add('DateOfSending__c');
        forwardingFields.add('ExpanseCondition__c');
        forwardingFields.add('TranporationType__c');
        forwardingFields.add('SeikyusyoRemark__c');
        forwardingFields.add('InvoicePrintDate__c');
        forwardingFields.add('DeadlineForPaymentOfExpense__c');
        forwardingFields.add('PrintDate__c');
        forwardingFields.add('QuotationPaymentCondition__c');
        forwardingFields.add('CREATEDDATE');
        forwardingFields.add('Field1__r.name');
        forwardingFields.add('Field1__r.EnglishCompanyName__c');
        forwardingFields.add('Field1__r.REGISTERATION_NO_FORM__c ');
        forwardingFields.add('Field1__r.REGISTRATION_NO_SERIAL__c');
        forwardingFields.add('Field1__r.TAX_CODE__c');
        forwardingFields.add('Field1__r.EnglishAddress__c');
        forwardingFields.add('Field1__r.Bank1__c');
        forwardingFields.add('Field1__r.Bank2__c');
        forwardingFields.add('Field1__r.Bank3__c');
        forwardingFields.add('Field1__r.Bank4__c');
        forwardingFields.add('Field1__r.Bank5__c');
        forwardingFields.add('Field1__r.Bank6__c');
        forwardingFields.add('Field1__r.BillingStreet');
        forwardingFields.add('Field1__r.BillingCity');
        forwardingFields.add('Field1__r.BillingState');
        forwardingFields.add('Field1__r.BillingCountry');
        forwardingFields.add('Field1__r.Payment_Method__c');
        forwardingFields.add('DebitNote_duedate__c');
        forwardingFields.add('chargable_weight__c');
        forwardingFields.add('RecordType.DeveloperName');
        forwardingFields.add('Master_B_L__c');
        forwardingFields.add('MAWB__c');
        forwardingFields.add('Cnee__r.Name');
        forwardingFields.add('Container__c');
        forwardingFields.add('ContainerNumber__c');
        forwardingFields.add('Container2__c');
        forwardingFields.add('ContainerNumber2__c');
        forwardingFields.add('Container3__c');                       
        forwardingFields.add('ContainerNumber3__c');                 
        forwardingFields.add('Container4__c');                      
        forwardingFields.add('ContainerNumber4__c');                            
        forwardingFields.add('Break_Bulk_Agent__r.Name');
        forwardingFields.add('Mail_Merge_Foreign_Bank1__c');
        forwardingFields.add('Mail_Merge_Foreign_Bank2__c');
        forwardingFields.add('Exchange_Currency__c');
        forwardingFields.add('DebitCreditRemark__c');
        forwardingFields.add('TERMS_OF_PAYMENT__c');
        forwardingFields.add('UnitType__c');
        forwardingFields.add('JobRequestID__c');
        forwardingFields.add('REFNO__c');
    }
}