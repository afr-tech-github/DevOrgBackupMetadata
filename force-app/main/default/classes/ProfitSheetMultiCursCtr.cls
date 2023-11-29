public with sharing class ProfitSheetMultiCursCtr {
    public CustomObject1__c ship{get; set;}
    private static List<String> invoicingFields = new List<String>();
    private static List<String> forwardingFields = new List<String>();
    private static final Integer FIRST_PAGE_SIZE = 9;
    private static final Integer SUBSEQUENCE_PAGE_SIZE = 17;
    private String shipmentId;
    public transient CustomObject1__c shipment { get; private set; }
    public transient List<AnkenMeisai__c> invoicingList { get; private set; }
    public transient List<AnkenMeisai__c> customerList{get; private set;}
    public transient List<AnkenMeisai__c> ourCompanyList{get; private set;}
    public transient Map<String, String> translations { get; private set; }
    public transient Set<String> referenceNumberToNameList { get; private set; }
    public transient List<ProfitRatioSummaryWrapper> profitRatioSummaryList { get; private set; }
    public transient RevenueCostSummaryWrapper renvenueCostSummary { get; private set; }
    public transient List<ReferenceLineWrapper> referenceLines { get; private set; }
    public transient List<InvoicingListWrapper> invoicingListWrappers { get; private set; }
    public transient string settingFCYCurrency {get; private set;}
    public transient string settingLocalCurrency {get; private set;}
    public Integer numberOfPages { get; private set; }
    public transient Set<String> setCurrs { get; private set; }
    public transient Set<String> setCurrencyBuyings { get; private set; }
    public Decimal setCurrsSize {get; set;}
    public Decimal setCurrencyBuyingsSize {get; set;}
    public transient Map<String, Decimal> currsMap { get; private set; }
    public transient Map<String, Decimal> currencyBuyingsMap { get; private set; }
    public transient Set<String> setBehalfCurrs { get; private set; }
    public transient Set<String> setBehalfCurrencyBuyings { get; private set; }
    public Decimal setBehalfCurrsSize {get; set;}
    public Decimal setBehalfCurrencyBuyingsSize {get; set;}
    public transient Map<String, Decimal> behalfCurrsMap { get; private set; }
    public transient Map<String, Decimal> behalfCurrencyBuyingsMap { get; private set; }
    public transient Map<String, Decimal> behalfAccCurrsMap { get; private set; }
    public transient Map<String, Decimal> behalfAccCurrencyBuyingsMap { get; private set; }
    public Boolean isBreakAll {get; set;}
    public Boolean isBreakCompany {get; set;}
    public Boolean isBreakCustomer {get; set;}
    public Boolean isBreakKickback {get; set;}
    public Boolean isBreakOverhead {get; set;}
    public Boolean isOnBehalfCustomer {get; set;}
    public Boolean isOnBehalfCompany {get; set;}
    public Boolean isKickback {get; set;}
    public Decimal percentRevenue {get; set;}
    public Decimal percentProfit {get; set;}
    public Decimal overcostRevenue {get; set;}
    public Decimal overcostCost {get; set;}
    public Decimal overcostProfit {get; set;}
    public Decimal percentProfixWithoutTax {get; set;}
    public Decimal percentProfixWithTax {get; set;}
    public Decimal onBehalfOfPerProfixWithoutTax {get; set;}
    public Decimal onBehalfOfPerProfixWithTax {get; set;}
    public Decimal billingProfixWithoutTax {get; set;}
    public Decimal billingProfixWithTax {get; set;}
    public transient List<Kickback__c> lstKickbackDetail {get; set;}
    public transient RevenueCostSummaryWrapper subSumCustomer {get; set;}
    public transient RevenueCostSummaryWrapper subSumCompany {get; set;}
    public transient RevenueCostSummaryWrapper subSumCustomerAndCompany {get; set;}
    public transient RevenueCostSummaryWrapper subSumBehaftAll {get; set;}
    public transient RevenueCostSummaryWrapper subSumKickback {get; set;}
    public transient RevenueCostSummaryWrapper accSumBehaftCustomer {get; set;}
    public transient RevenueCostSummaryWrapper accSumCompany {get; set;}
    public transient RevenueCostSummaryWrapper accSumCustomerAndCompany {get; set;}
    public transient RevenueCostSummaryWrapper accSumKickback {get; set;}
    public transient RevenueCostSummaryWrapper accSumOverheadcost {get; set;}
    public transient RevenueCostSummaryWrapper subSumOverheadCost {get; set;}
    public transient Set<String> kickBackCurrSet { get; private set; }
    public transient Map<String, Decimal> kickBackCurrValueReMap { get; private set; }
    public transient Map<String, Decimal> kickBackCurrValueCoMap { get; private set; }
    public Decimal kickBackCurrSetSize {get; set;}
    public String userName{get;set;}
    public String today{get;set;}
    public String shipId;
    public String leftfooter {get; set;}

    public ProfitSheetMultiCursCtr() {
        isBreakAll = false;
        isBreakCompany = false;
        isBreakCustomer = false;
        isBreakKickback = false;
        isBreakOverhead = false;
        subSumCustomer = new RevenueCostSummaryWrapper();
        subSumCompany = new RevenueCostSummaryWrapper();
        subSumCustomerAndCompany = new RevenueCostSummaryWrapper();
        subSumBehaftAll = new RevenueCostSummaryWrapper();
        subSumKickback = new RevenueCostSummaryWrapper();
        accSumBehaftCustomer = new RevenueCostSummaryWrapper();
        accSumCompany = new RevenueCostSummaryWrapper();
        accSumCustomerAndCompany = new RevenueCostSummaryWrapper();
        accSumKickback = new RevenueCostSummaryWrapper();
        accSumOverheadcost = new RevenueCostSummaryWrapper();
        subSumOverheadCost = new RevenueCostSummaryWrapper();
        isOnBehalfCustomer = false;
        isOnBehalfCompany = false;
        isKickback = false;
        percentRevenue = 0;
        percentProfit = 0;
        overcostRevenue = 0;
        overcostCost = 0;
        overcostProfit = 0;
        onBehalfOfPerProfixWithoutTax = 0;
        onBehalfOfPerProfixWithTax = 0;
        percentProfixWithoutTax = 0;
        percentProfixWithTax = 0;
        billingProfixWithoutTax = 0;
        billingProfixWithTax = 0;
        shipId = ApexPages.currentPage().getParameters().get('id');
        ship = getShipment(shipId);
        System.debug('kkkkkk :'+shipId);
        Datetime now = Datetime.now();
        String convertDate = now.format('HH:mm:ss dd/MM/yyyy');
        leftfooter = String.join(new List<String>{ship.LastModifiedBy.Name,convertDate}, ' - ');
        lstKickbackDetail = new List<Kickback__c>();
        customerList = new List<AnkenMeisai__c>();
        ourCompanyList = new List<AnkenMeisai__c>();
        setCurrs = new Set<String>();
        setCurrencyBuyings = new Set<String>();
        currsMap =  new Map<String, Decimal>();
        currencyBuyingsMap =  new Map<String, Decimal>();
        setBehalfCurrs = new Set<String>();
        setBehalfCurrencyBuyings = new Set<String>();
        behalfCurrsMap = new Map<String, Decimal>();
        behalfCurrencyBuyingsMap = new Map<String, Decimal>();
        behalfAccCurrsMap = new Map<String, Decimal>();
        behalfAccCurrencyBuyingsMap = new Map<String, Decimal>();
        kickBackCurrSet = new Set<String>();
        kickBackCurrValueReMap = new Map<String, Decimal>();
        kickBackCurrValueCoMap = new Map<String, Decimal>();
        userName = UserInfo.getName();
        today =  DateTime.now().format('yyyy/MM/dd hh:mm:ss');
        getParameters();
        initializeTranslation();
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()
                && PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort()
                && PermissionValidationUtil.isAccessibleServiceMaster() && PermissionValidationUtil.isAccessibleWarehouse()) {
        }
        retrieveShipmentWithInvoicingRecords(shipmentId);
        buildReferenceLineWrapper();
        numberOfPages = invoicingListWrappers.size();
        if(isKickback){
            lstKickbackDetail = getKickbackByShipment(shipmentId);
        }
        for(Kickback__c kick : lstKickbackDetail){
            subSumKickback.totalCostUSD += kick.TotalKickbackAmountUSD__c;
            subSumKickback.totalCost += kick.TotalKickbackAmount__c;
            subSumKickback.totalCostTax = 0;
            subSumKickback.totalCostInclTax += kick.TotalKickbackAmount__c;
            subSumKickback.totalProfit += kick.TotalKickbackAmount__c;
            subSumKickback.totalProfitUSD += kick.TotalKickbackAmountUSD__c;
        }
        subSumKickback.totalProfitUSD = 0 - subSumKickback.totalProfitUSD;
        subSumKickback.totalProfit = 0 - subSumKickback.totalProfit;        
        if(isOnBehalfCustomer){
            accSumBehaftCustomer.totalRevenue = (subSumBehaftAll.totalRevenue + subSumCustomer.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalRevenueUSD = (subSumBehaftAll.totalRevenueUSD + subSumCustomer.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalRevenueTax = (subSumBehaftAll.totalRevenueTax + subSumCustomer.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalRevenueInclTax = (subSumBehaftAll.totalRevenueInclTax + subSumCustomer.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCostUSD = (subSumBehaftAll.totalCostUSD + subSumCustomer.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCost = (subSumBehaftAll.totalCost + subSumCustomer.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCostTax = (subSumBehaftAll.totalCostTax + subSumCustomer.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCostInclTax = (subSumBehaftAll.totalCostInclTax + subSumCustomer.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalProfit = (subSumBehaftAll.totalProfit + subSumCustomer.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalProfitUSD = (subSumBehaftAll.totalProfitUSD + subSumCustomer.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        }
        else{
            accSumBehaftCustomer.totalRevenue = (subSumBehaftAll.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalRevenueUSD = (subSumBehaftAll.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalRevenueTax = (subSumBehaftAll.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalRevenueInclTax = (subSumBehaftAll.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCostUSD = (subSumBehaftAll.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCost = (subSumBehaftAll.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCostTax = (subSumBehaftAll.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalCostInclTax = (subSumBehaftAll.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalProfit = (subSumBehaftAll.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumBehaftCustomer.totalProfitUSD = (subSumBehaftAll.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        }
        
        if(isOnBehalfCompany){
            accSumCompany.totalRevenue = (accSumBehaftCustomer.totalRevenue + subSumCompany.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalRevenueUSD = (accSumBehaftCustomer.totalRevenueUSD + subSumCompany.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalRevenueTax = (accSumBehaftCustomer.totalRevenueTax + subSumCompany.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalRevenueInclTax = (accSumBehaftCustomer.totalRevenueInclTax + subSumCompany.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            
            accSumCompany.totalCostUSD = (accSumBehaftCustomer.totalCostUSD + subSumCompany.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalCost = (accSumBehaftCustomer.totalCost + subSumCompany.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalCostTax = (accSumBehaftCustomer.totalCostTax + subSumCompany.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalCostInclTax = (accSumBehaftCustomer.totalCostInclTax + subSumCompany.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalProfit = (accSumBehaftCustomer.totalProfit + subSumCompany.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalProfitUSD = (accSumBehaftCustomer.totalProfitUSD + subSumCompany.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        }
        else{
            accSumCompany.totalRevenue = (accSumBehaftCustomer.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalRevenueUSD = (accSumBehaftCustomer.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalRevenueTax = (accSumBehaftCustomer.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalRevenueInclTax = (accSumBehaftCustomer.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            
            accSumCompany.totalCostUSD = (accSumBehaftCustomer.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalCost = (accSumBehaftCustomer.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalCostTax = (accSumBehaftCustomer.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalCostInclTax = (accSumBehaftCustomer.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalProfit = (accSumBehaftCustomer.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumCompany.totalProfitUSD = (accSumBehaftCustomer.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        }
        
        if(isOnBehalfCustomer || isOnBehalfCompany){
            accSumCustomerAndCompany.totalRevenue = (subSumBehaftAll.totalRevenue + subSumCustomerAndCompany.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalRevenueUSD = (subSumBehaftAll.totalRevenueUSD + subSumCustomerAndCompany.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalRevenueTax = (subSumBehaftAll.totalRevenueTax + subSumCustomerAndCompany.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalRevenueInclTax = (subSumBehaftAll.totalRevenueInclTax + subSumCustomerAndCompany.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            
            accSumCustomerAndCompany.totalCostUSD = (subSumBehaftAll.totalCostUSD + subSumCustomerAndCompany.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalCost = (subSumBehaftAll.totalCost + subSumCustomerAndCompany.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalCostTax = (subSumBehaftAll.totalCostTax + subSumCustomerAndCompany.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalCostInclTax = (subSumBehaftAll.totalCostInclTax + subSumCustomerAndCompany.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalProfit = (subSumBehaftAll.totalProfit + subSumCustomerAndCompany.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalProfitUSD = (subSumBehaftAll.totalProfitUSD + subSumCustomerAndCompany.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        } else {
            accSumCustomerAndCompany.totalRevenue = subSumBehaftAll.totalRevenue.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalRevenueUSD = subSumBehaftAll.totalRevenueUSD.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalRevenueTax = subSumBehaftAll.totalRevenueTax.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalRevenueInclTax = subSumBehaftAll.totalRevenueInclTax.setScale(2, RoundingMode.HALF_UP);
            
            accSumCustomerAndCompany.totalCostUSD = subSumBehaftAll.totalCostUSD.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalCost = subSumBehaftAll.totalCost.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalCostTax = subSumBehaftAll.totalCostTax.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalCostInclTax = subSumBehaftAll.totalCostInclTax.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalProfit = subSumBehaftAll.totalProfit.setScale(2, RoundingMode.HALF_UP);
            accSumCustomerAndCompany.totalProfitUSD = subSumBehaftAll.totalProfitUSD.setScale(2, RoundingMode.HALF_UP);
        }

        if(isKickback){
            accSumKickback.totalRevenue = (accSumCustomerAndCompany.totalRevenue + subSumKickback.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalRevenueUSD = (accSumCustomerAndCompany.totalRevenueUSD + subSumKickback.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalRevenueTax = (accSumCustomerAndCompany.totalRevenueTax + subSumKickback.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalRevenueInclTax = (accSumCustomerAndCompany.totalRevenueInclTax + subSumKickback.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            
            accSumKickback.totalCostUSD = (accSumCustomerAndCompany.totalCostUSD + subSumKickback.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalCost = (accSumCustomerAndCompany.totalCost + subSumKickback.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalCostTax = (accSumCustomerAndCompany.totalCostTax + subSumKickback.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalCostInclTax = (accSumCustomerAndCompany.totalCostInclTax + subSumKickback.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalProfit = (accSumCustomerAndCompany.totalProfit + subSumKickback.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalProfitUSD = (accSumCustomerAndCompany.totalProfitUSD + subSumKickback.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        }
        else{
            accSumKickback.totalRevenue = (accSumCustomerAndCompany.totalRevenue).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalRevenueUSD = (accSumCustomerAndCompany.totalRevenueUSD).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalRevenueTax = (accSumCustomerAndCompany.totalRevenueTax).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalRevenueInclTax = (accSumCustomerAndCompany.totalRevenueInclTax).setScale(2, RoundingMode.HALF_UP);
            
            accSumKickback.totalCostUSD = (accSumCustomerAndCompany.totalCostUSD).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalCost = (accSumCustomerAndCompany.totalCost).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalCostTax = (accSumCustomerAndCompany.totalCostTax).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalCostInclTax = (accSumCustomerAndCompany.totalCostInclTax).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalProfit = (accSumCustomerAndCompany.totalProfit).setScale(2, RoundingMode.HALF_UP);
            accSumKickback.totalProfitUSD = (accSumCustomerAndCompany.totalProfitUSD).setScale(2, RoundingMode.HALF_UP);
        }
        
        if(percentRevenue != 0){
           overcostRevenue = (accSumKickback.totalRevenue*percentRevenue).setScale(2, RoundingMode.HALF_UP);
        }
            
        if(percentProfit != 0){
           overcostCost = (accSumKickback.totalCost*percentProfit).setScale(2, RoundingMode.HALF_UP);
           overcostProfit = 0 - overcostCost;
        } 
        accSumOverheadcost.totalRevenue = accSumKickback.totalRevenue;
        accSumOverheadcost.totalRevenueUSD = accSumKickback.totalRevenueUSD;
        accSumOverheadcost.totalRevenueTax = accSumKickback.totalRevenueTax;
        accSumOverheadcost.totalRevenueInclTax = accSumKickback.totalRevenueInclTax;
        accSumOverheadcost.totalCostUSD = accSumKickback.totalCostUSD;
        accSumOverheadcost.totalCost = accSumKickback.totalCost;
        accSumOverheadcost.totalCostTax = accSumKickback.totalCostTax;
        accSumOverheadcost.totalCostInclTax = accSumKickback.totalCostInclTax;
        accSumOverheadcost.totalProfitUSD = accSumKickback.totalProfitUSD;
        if(percentRevenue != 0){
            subSumOverheadCost.totalProfit = overcostRevenue;
        }
        if(percentProfit!= 0){
            subSumOverheadCost.totalProfit = overcostProfit ;
        }
        
        if(overcostRevenue != 0){
            accSumOverheadcost.totalProfit = accSumKickback.totalProfit - overcostRevenue;
            if(overcostRevenue < 0){
                accSumOverheadcost.totalProfit = accSumKickback.totalProfit + overcostRevenue;
            }
            else{
                accSumOverheadcost.totalProfit = accSumKickback.totalProfit - overcostRevenue;
            }
        }
        if(overcostProfit != 0){
            if(overcostProfit < 0){
                accSumOverheadcost.totalProfit = accSumKickback.totalProfit + overcostProfit;
            }
            else{
                accSumOverheadcost.totalProfit = accSumKickback.totalProfit - overcostProfit;
            }
        }
        if(overcostProfit == 0 && overcostRevenue == 0){
            accSumOverheadcost.totalProfit = accSumKickback.totalProfit;
        }
        
        if(isOnBehalfCustomer){
            if(Math.mod(customerList.size() - FIRST_PAGE_SIZE, SUBSEQUENCE_PAGE_SIZE) > SUBSEQUENCE_PAGE_SIZE - 4){
                isBreakCustomer = true;
            }
        }
        
        if(isOnBehalfCompany){
            if(Math.mod(ourCompanyList.size() - FIRST_PAGE_SIZE, SUBSEQUENCE_PAGE_SIZE) > SUBSEQUENCE_PAGE_SIZE - 4){
                isBreakCompany = true;
            }
        }
        
        if(isKickback){
            if(Math.mod(lstKickbackDetail.size() - FIRST_PAGE_SIZE, SUBSEQUENCE_PAGE_SIZE) > SUBSEQUENCE_PAGE_SIZE - 4){
                isBreakKickback = true;
            }
        }
                
        if(accSumOverheadcost.totalRevenue != 0){
            percentProfixWithoutTax = (accSumOverheadcost.totalProfit*100/accSumOverheadcost.totalRevenue ).setScale(2, RoundingMode.HALF_UP);
        }
        if(accSumOverheadcost.totalRevenueInclTax != 0){
			percentProfixWithTax = ((accSumOverheadcost.totalRevenueInclTax - accSumOverheadcost.totalCostInclTax)*100/accSumOverheadcost.totalRevenueInclTax ).setScale(2, RoundingMode.HALF_UP);
        }

        if(subSumCustomerAndCompany.totalRevenue != 0){
            onBehalfOfPerProfixWithoutTax = (subSumCustomerAndCompany.totalProfit*100/subSumCustomerAndCompany.totalRevenue ).setScale(2, RoundingMode.HALF_UP);
        }
        if(subSumCustomerAndCompany.totalRevenueInclTax != 0){
			onBehalfOfPerProfixWithTax = ((subSumCustomerAndCompany.totalRevenueInclTax - subSumCustomerAndCompany.totalCostInclTax)*100/subSumCustomerAndCompany.totalRevenueInclTax ).setScale(2, RoundingMode.HALF_UP);
        }
        
        if(subSumBehaftAll.totalRevenue != 0){
            billingProfixWithoutTax = (subSumBehaftAll.totalProfit*100/subSumBehaftAll.totalRevenue ).setScale(2, RoundingMode.HALF_UP);
        }
        if(subSumBehaftAll.totalRevenueInclTax != 0){
			billingProfixWithTax = ((subSumBehaftAll.totalRevenueInclTax - subSumBehaftAll.totalCostInclTax)*100/subSumBehaftAll.totalRevenueInclTax ).setScale(2, RoundingMode.HALF_UP);
        }
  
    }

    private List<Kickback__c> getKickbackByShipment(String sid){
        List<Kickback__c> lstKickback = new List<Kickback__c>();
        lstKickback = [ SELECT Id, KickbackName__c, ExchangeRate__c, ChargeUnit__c, ChargeType__c, 
                                KickbackTo__r.Reference_Number__c, TotalKickbackAmountUSD__c, TotalKickbackAmount__c 
                      FROM Kickback__c 
                      WHERE ShipmentOrder__c = :sid];
        return lstKickback;
    }

    private void getParameters() {
        shipmentId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
        isOnBehalfCustomer = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isOnBehalfCustomer'));
        isOnBehalfCompany = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isOnBehalfOurCompany'));
        isKickback = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isKickback'));
        String strRe = String.valueOf(ApexPages.currentPage().getParameters().get('percentRevenue'));
        String strPro = String.valueOf(ApexPages.currentPage().getParameters().get('percentProfit'));
        
        if(!String.isBlank(strRe)){
            percentRevenue = Decimal.valueOf(strRe)/100;
        }
        else{
            percentRevenue = 0;
        }
        
        if(!String.isBlank(strPro)){
            percentProfit = Decimal.valueOf(strPro)/100;
        }
        else{
            percentProfit = 0;
        }  
    }
    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('Invoice', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    private void buildReferenceLineWrapper() {
        Integer count = 0;
        ReferenceLineWrapper ref = null;
        referenceLines = new List<ReferenceLineWrapper>();
        for (String refName : referenceNumberToNameList) {
            if(refName == 'null: null') {
                continue;
            }
            if (Math.mod(count, 2) == 0) {
                ref = new ReferenceLineWrapper();
                ref.firstReference = refName;
                referenceLines.add(ref);
            } else {
                ref.secondReference = refName;
            }
            count++;
        }
    }

    private static CustomObject1__c getShipment(String shipId){
        CustomObject1__c ship = [SELECT Id, Name, LastModifiedBy.Name
                            FROM CustomObject1__c WHERE Id =: shipId];


        return ship;

    }

    private void retrieveShipmentWithInvoicingRecords(String shipmentId) {
        referenceNumberToNameList = new Set<String>();
        profitRatioSummaryList = new List<ProfitRatioSummaryWrapper>();
        renvenueCostSummary = new RevenueCostSummaryWrapper();
        invoicingListWrappers = new List<InvoicingListWrapper>();
        final String query = 'SELECT ' + String.join(forwardingFields, ',') +
                ', (SELECT ' + String.join(invoicingFields, ',') + ' FROM Anken__r) ' +
                ' FROM CustomObject1__c WHERE Id = \'' + shipmentId + '\'';
        shipment = Database.query(query);
        system.debug('shipmentId:' + shipmentId);
        system.debug('soql:' + query);
        system.debug('>>> Length of anken__r: ' + shipment.Anken__r.size());
        for(AnkenMeisai__c am: shipment.Anken__r) {
            system.debug('>>> Check curr: '+am.curr__c);
        }
        if (shipment != null && shipment.Anken__r != null && !shipment.Anken__r.isEmpty()) {
            invoicingList = shipment.Anken__r;
            Map<String, ProfitRatioSummaryWrapper> profitRatioMap = new Map<String, ProfitRatioSummaryWrapper>();

            Integer recordCount = 0;
            Boolean firstPage = true;
            Integer pageNo = 0;
            InvoicingListWrapper invoicingListWrapper = null;
            
            if(invoicingList.size() >= 7 && invoicingList.size() <= FIRST_PAGE_SIZE){
                isBreakAll = true;
            }
            if(invoicingList.size() > FIRST_PAGE_SIZE && Math.mod(invoicingList.size() - FIRST_PAGE_SIZE, SUBSEQUENCE_PAGE_SIZE) > SUBSEQUENCE_PAGE_SIZE - 2){
                isBreakAll = true;
            }
            Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();
            system.debug('setting:' + setting.FCY_Currency__c);
            system.debug('setting:' + setting.Local_Currency__c);
            settingFCYCurrency =setting.FCY_Currency__c;
            settingLocalCurrency = setting.Local_Currency__c;
            for (AnkenMeisai__c invoicing : invoicingList) {
                kickBackCurrSet.add(invoicing.curr__c);
                Decimal sellingAmount = Util.calculateSellingAmount(invoicing);
                Decimal sellingAmountInclTax = Util.calculateSellingInTaxAmount(invoicing);
                Decimal buyingAmount = Util.calculateBuyingAmount(invoicing);
                Decimal buyingAmountInclTax = Util.calculateBuyingInTaxAmount(invoicing);
                
                if(!(isOnBehalfCustomer && invoicing.ADVANCE_PAYMENT_ON_BEHALF_OF__c) && !(isOnBehalfCompany && invoicing.AdvancePaymentOnBehalfOfOurCompany__c)){
                    subSumBehaftAll.totalRevenue += invoicing.SellAmountJPN__c;
                    subSumBehaftAll.totalRevenueUSD += invoicing.SellAmountUSD__c;
                    subSumBehaftAll.totalRevenueTax += invoicing.SellTaxNum__c;
                    subSumBehaftAll.totalRevenueInclTax += invoicing.SellInTaxAmountJPY__c;
                    subSumBehaftAll.totalCostUSD += invoicing.BuyAmountUSD__c;
                    subSumBehaftAll.totalCost += invoicing.BuyAmountJPN__c;
                    subSumBehaftAll.totalCostTax += invoicing.BuyTaxNum__c;
                    subSumBehaftAll.totalCostInclTax += invoicing.BuyInTaxAmountJPY__c;
                    subSumBehaftAll.totalProfit += invoicing.Ararigaku__c;
                    subSumBehaftAll.totalProfitUSD += invoicing.PROFIT_USD__c;
                   }
                
                if(isOnBehalfCustomer && invoicing.ADVANCE_PAYMENT_ON_BEHALF_OF__c){
                    customerList.add(invoicing);
                    subSumCustomer.totalRevenue += sellingAmount;
                    subSumCustomer.totalRevenueUSD += invoicing.SellAmountUSD__c;
                    subSumCustomer.totalRevenueTax += invoicing.SellTaxNum__c;
                    subSumCustomer.totalRevenueInclTax = subSumCustomer.totalRevenue + subSumCustomer.totalRevenueTax;
                    subSumCustomer.totalCostUSD = 0;
                    subSumCustomer.totalCost = 0;
                    subSumCustomer.totalCostTax = 0;
                    subSumCustomer.totalCostInclTax = 0;
                    subSumCustomer.totalProfit = 0;
                    subSumCustomer.totalProfitUSD = 0;
                    if(setting?.Local_Currency__c != invoicing.curr__c && invoicing.curr__c != null) {
                        setBehalfCurrs.add(invoicing.curr__c);
                    }
                    if(setting?.Local_Currency__c != invoicing.CurrencyBuying__c && invoicing.CurrencyBuying__c != null) {
                        setBehalfCurrencyBuyings.add(invoicing.CurrencyBuying__c);
                    }
                }
                else if(isOnBehalfCompany && invoicing.AdvancePaymentOnBehalfOfOurCompany__c){
                    ourCompanyList.add(invoicing);
                    subSumCompany.totalRevenue = 0;
                    subSumCompany.totalRevenueUSD = 0;
                    subSumCompany.totalRevenueTax = 0;
                    subSumCompany.totalRevenueInclTax = 0;
                    subSumCompany.totalCostUSD += invoicing.BuyAmountUSD__c;
                    subSumCompany.totalCost += buyingAmount;
                    subSumCompany.totalCostTax += invoicing.BuyTaxNum__c;
                    subSumCompany.totalCostInclTax = subSumCompany.totalCost + subSumCompany.totalCostTax;
                    subSumCompany.totalProfit += invoicing.Ararigaku__c;
                    subSumCompany.totalProfitUSD += invoicing.PROFIT_USD__c;
                    if(setting?.Local_Currency__c != invoicing.curr__c && invoicing.curr__c != null) {
                        setBehalfCurrs.add(invoicing.curr__c);
                    }
                    if(setting?.Local_Currency__c != invoicing.CurrencyBuying__c && invoicing.CurrencyBuying__c != null) {
                        setBehalfCurrencyBuyings.add(invoicing.CurrencyBuying__c);
                    }
                }

                if((isOnBehalfCustomer && invoicing.ADVANCE_PAYMENT_ON_BEHALF_OF__c) || (isOnBehalfCompany && invoicing.AdvancePaymentOnBehalfOfOurCompany__c)){
                    subSumCustomerAndCompany.totalRevenue += sellingAmount;
                    subSumCustomerAndCompany.totalRevenueUSD += invoicing.SellAmountUSD__c;
                    subSumCustomerAndCompany.totalRevenueTax += invoicing.SellTaxNum__c;
                    subSumCustomerAndCompany.totalRevenueInclTax = subSumCustomerAndCompany.totalRevenue + subSumCustomerAndCompany.totalRevenueTax;
                    subSumCustomerAndCompany.totalCostUSD += invoicing.BuyAmountUSD__c;
                    subSumCustomerAndCompany.totalCost += buyingAmount;
                    subSumCustomerAndCompany.totalCostTax += invoicing.BuyTaxNum__c;
                    subSumCustomerAndCompany.totalCostInclTax = subSumCustomerAndCompany.totalCost + subSumCustomerAndCompany.totalCostTax;
                    subSumCustomerAndCompany.totalProfit += invoicing.Ararigaku__c;
                    subSumCustomerAndCompany.totalProfitUSD += invoicing.PROFIT_USD__c;
                }

                recordCount++;
                if (Math.mod(recordCount, SUBSEQUENCE_PAGE_SIZE) == 0 || (firstPage && recordCount > FIRST_PAGE_SIZE) || invoicingListWrapper == null) {
                    if (firstPage && recordCount > FIRST_PAGE_SIZE) {
                        firstPage = false;
                        recordCount = SUBSEQUENCE_PAGE_SIZE;
                    }
                    pageNo++;
                    invoicingListWrapper = new InvoicingListWrapper(pageNo);
                    invoicingListWrappers.add(invoicingListWrapper);
                }
                if(!(isOnBehalfCustomer && invoicing.ADVANCE_PAYMENT_ON_BEHALF_OF__c) && !(isOnBehalfCompany && invoicing.AdvancePaymentOnBehalfOfOurCompany__c)){
                    invoicingListWrapper.addInvoicing(invoicing);
                    //TODO:
                    if(setting?.Local_Currency__c != invoicing.curr__c && invoicing.curr__c != null) {
                        setCurrs.add(invoicing.curr__c);
                    }
                    if(setting?.Local_Currency__c != invoicing.CurrencyBuying__c && invoicing.CurrencyBuying__c != null) {
                        setCurrencyBuyings.add(invoicing.CurrencyBuying__c);
                    }
                }

                referenceNumberToNameList.add(invoicing.Seikyusaki__r.Reference_Number__c + ': ' + invoicing.Seikyusaki__r.Name);
                referenceNumberToNameList.add(invoicing.PaymentTo__r.Reference_Number__c + ': ' + invoicing.PaymentTo__r.Name);

                ProfitRatioSummaryWrapper profitRatio = null;
                if (profitRatioMap.containsKey(invoicing.Seikyusaki__r.Id)) {
                    profitRatio = profitRatioMap.get(invoicing.Seikyusaki__r.Id);
                } else {
                    profitRatio = new ProfitRatioSummaryWrapper();
                    profitRatio.partnerId = invoicing.Seikyusaki__r.Id;
                    profitRatio.referenceNumber = invoicing.Seikyusaki__r.Reference_Number__c;
                    profitRatioMap.put(invoicing.Seikyusaki__r.Id, profitRatio);
                }

                profitRatio.sumOfSellingAmount += sellingAmount;//invoicing.SellAmountJPN__c;
                profitRatio.sumOfSellingAmountUSD += invoicing.SellAmountUSD__c;
                profitRatio.sumOfBuyingAmount += buyingAmount;//invoicing.BuyAmountJPN__c;
                profitRatio.sumOfBuyingAmountUSD += invoicing.BuyAmountUSD__c;
                profitRatio.sumOfSellingInclTaxAmount += sellingAmountInclTax;//invoicing.SellInTaxAmountJPY__c;
                profitRatio.sumOfSellingInclTaxAmountUSD += invoicing.SellInTaxAmount_USD__c;
                profitRatio.sumOfBuyingInclTaxAmount += buyingAmountInclTax;//invoicing.BuyInTaxAmountJPY__c;
                profitRatio.sumOfBuyingInclTaxAmountUSD += invoicing.BuyInTaxAmountUSD__c;

                renvenueCostSummary.totalRevenue += sellingAmount;//invoicing.SellAmountJPN__c;
                renvenueCostSummary.totalRevenueUSD += invoicing.SellAmountUSD__c;
                renvenueCostSummary.totalRevenueTax += invoicing.SellTaxNum__c;
                renvenueCostSummary.totalRevenueInclTax = renvenueCostSummary.totalRevenue + renvenueCostSummary.totalRevenueTax;
                renvenueCostSummary.totalCost += buyingAmount;//invoicing.BuyAmountJPN__c;
                renvenueCostSummary.totalCostUSD += invoicing.BuyAmountUSD__c;
                renvenueCostSummary.totalCostTax += invoicing.BuyTaxNum__c;
                renvenueCostSummary.totalCostInclTax = renvenueCostSummary.totalCost + renvenueCostSummary.totalCostTax;//invoicing.BuyInTaxAmountJPY__c;
                renvenueCostSummary.totalProfit += invoicing.Ararigaku__c;
                renvenueCostSummary.totalProfitUSD += invoicing.PROFIT_USD__c;
            }
            // Set value for size of sets
            setCurrsSize = setCurrs.size();
            system.debug('setCurrs:' + setCurrs);
            setCurrencyBuyingsSize = setCurrencyBuyings.size();
            // Set value for map
            for(String curr: setCurrs) {
                currsMap.put(curr, 0);
            }
            System.debug('ccccccccc :'+currsMap);
            for(String currBuying: setCurrencyBuyings) {
                currencyBuyingsMap.put(currBuying, 0);
            }

            //Set value for size of Behalf sets
            setBehalfCurrsSize = setBehalfCurrs.size();
            System.debug('ggggg :'+setBehalfCurrs);
            setBehalfCurrencyBuyingsSize = setBehalfCurrencyBuyings.size();
            // Set value for Behalf Maps
            for(String curr: setBehalfCurrs) {
                behalfCurrsMap.put(curr, 0);
                behalfAccCurrsMap.put(curr, 0);
            }
            System.debug('dddddddd :'+behalfCurrsMap);
            System.debug('eeeeeeee :'+behalfAccCurrsMap);
            for(String currBuying: setBehalfCurrencyBuyings) {
                behalfCurrencyBuyingsMap.put(currBuying, 0);
                behalfAccCurrencyBuyingsMap.put(currBuying, 0);
            }

            for (AnkenMeisai__c invoicing : invoicingList) {
                if(!(isOnBehalfCustomer && invoicing.ADVANCE_PAYMENT_ON_BEHALF_OF__c) && !(isOnBehalfCompany && invoicing.AdvancePaymentOnBehalfOfOurCompany__c)){
                    if(setting?.Local_Currency__c != invoicing.curr__c && invoicing.curr__c != null && invoicing.UnitPriceofSelling3rdCurrency__c != null) {
                        currsMap.put(invoicing.curr__c, currsMap.get(invoicing.curr__c) + invoicing.UnitPriceofSelling3rdCurrency__c);
                    }
                    if(setting?.Local_Currency__c != invoicing.CurrencyBuying__c && invoicing.CurrencyBuying__c != null && invoicing.UnitPriceofBuying3rdCurrency__c != null) {
                        currencyBuyingsMap.put(invoicing.CurrencyBuying__c, currencyBuyingsMap.get(invoicing.CurrencyBuying__c) + invoicing.UnitPriceofBuying3rdCurrency__c);
                    }
                }
                if((isOnBehalfCustomer && invoicing.ADVANCE_PAYMENT_ON_BEHALF_OF__c) || (isOnBehalfCompany && invoicing.AdvancePaymentOnBehalfOfOurCompany__c)){
                    if(setting?.Local_Currency__c != invoicing.curr__c && invoicing.curr__c != null  && invoicing.UnitPriceofSelling3rdCurrency__c != null) {
                        behalfCurrsMap.put(invoicing.curr__c, behalfCurrsMap.get(invoicing.curr__c) + invoicing.UnitPriceofSelling3rdCurrency__c);
                    }
                    if(setting?.Local_Currency__c != invoicing.CurrencyBuying__c && invoicing.CurrencyBuying__c != null && invoicing.UnitPriceofBuying3rdCurrency__c != null) {
                        behalfCurrencyBuyingsMap.put(invoicing.CurrencyBuying__c, behalfCurrencyBuyingsMap.get(invoicing.CurrencyBuying__c) + invoicing.UnitPriceofBuying3rdCurrency__c);
                    }
                }
            }
            // Set values for Accumulated Behalf 
            for(String curr: setBehalfCurrs) {
                if(currsMap.get(curr) != null) {
                    behalfAccCurrsMap.put(curr, behalfCurrsMap.get(curr) + currsMap.get(curr));
                }
            }
            for(String currBuying: setBehalfCurrencyBuyings) {
                if(currencyBuyingsMap.get(currBuying) != null) {
                    behalfAccCurrencyBuyingsMap.put(currBuying, currencyBuyingsMap.get(currBuying) + behalfCurrencyBuyingsMap.get(currBuying));
                }
            }
            profitRatioSummaryList = profitRatioMap.values();
            kickBackCurrSetSize = kickBackCurrSet.size();
            for (String curr : kickBackCurrSet) {
                kickBackCurrValueReMap.put(curr, 0);
                kickBackCurrValueCoMap.put(curr, 0);
            }
            for (AnkenMeisai__c invoicing : invoicingList) {
                if(invoicing.curr__c != null) {
                    kickBackCurrValueReMap.put(invoicing.curr__c, kickBackCurrValueReMap.get(invoicing.curr__c) + invoicing.AmountofTaxSelling3rdCurrency__c);
                	kickBackCurrValueCoMap.put(invoicing.curr__c, kickBackCurrValueCoMap.get(invoicing.curr__c) + invoicing.AmountofTaxBuying3rdCurrency__c);
                }
                
            }
        }
    }

    /**
        Capture the summary for REVENUE and COST.
        This is the total line in the detailed invoicing list.
     */
    class RevenueCostSummaryWrapper {
        public Decimal totalRevenue { get; set; }
        public Decimal totalRevenueUSD { get; set; }
        public Decimal totalRevenueTax { get; set; }
        public Decimal totalRevenueInclTax { get; set; }
        public Decimal totalCost { get; set; }
        public Decimal totalCostUSD { get; set; }
        public Decimal totalCostTax { get; set; }
        public Decimal totalCostInclTax { get; set; }
        public Decimal totalProfit { get; set; }
        public Decimal totalProfitUSD { get; set; }

        public RevenueCostSummaryWrapper() {
            totalRevenue = 0;
            totalRevenueUSD = 0;
            totalRevenueTax = 0;
            totalRevenueInclTax = 0;
            totalCost = 0;
            totalCostUSD = 0;
            totalCostTax = 0;
            totalCostInclTax = 0;
            totalProfit = 0;
            totalProfitUSD = 0;
        }
    }

    /**
        Capture the profit ratio for each partner (INVOICE TO)
     */
    class ProfitRatioSummaryWrapper {
        public String partnerId { get; set; }
        public String referenceNumber { get; set; }
        public Decimal sumOfSellingAmount { get; set; }
        public Decimal sumOfSellingAmountUSD { get; set; }
        public Decimal sumOfBuyingAmount { get; set; }
        public Decimal sumOfBuyingAmountUSD { get; set; }
        public Decimal sumOfSellingInclTaxAmount { get; set; }
        public Decimal sumOfSellingInclTaxAmountUSD { get; set; }
        public Decimal sumOfBuyingInclTaxAmount { get; set; }
        public Decimal sumOfBuyingInclTaxAmountUSD { get; set; }

        public ProfitRatioSummaryWrapper() {
            sumOfSellingAmount = 0;
            sumOfSellingAmountUSD = 0;
            sumOfBuyingAmount = 0;
            sumOfBuyingAmountUSD = 0;
            sumOfSellingInclTaxAmount = 0;
            sumOfSellingInclTaxAmountUSD = 0;
            sumOfBuyingInclTaxAmount = 0;
            sumOfBuyingInclTaxAmountUSD = 0;
        }

        public Decimal getProfitRatio() {
            if (sumOfSellingAmount != 0) {
                return 100 * (sumOfSellingAmount - sumOfBuyingAmount) / sumOfSellingAmount;
            }
            return 0;
        }

        public Decimal getProfitRatioInclTax() {
            if (sumOfSellingInclTaxAmount != 0) {
                return 100 * (sumOfSellingInclTaxAmount - sumOfBuyingInclTaxAmount) / sumOfSellingInclTaxAmount;
            }
            return 0;
        }

        public Decimal getProfitRatioUSD() {
            if (sumOfSellingAmountUSD != 0) {
                return 100 * (sumOfSellingAmountUSD - sumOfBuyingAmountUSD) / sumOfSellingAmountUSD;
            }
            return 0;
        }

        public Decimal getProfitRatioInclTaxUSD() {
            if (sumOfSellingInclTaxAmountUSD != 0) {
                return 100 * (sumOfSellingInclTaxAmountUSD - sumOfBuyingInclTaxAmountUSD) / sumOfSellingInclTaxAmountUSD;
            }
            return 0;
        }
    }

    class ReferenceLineWrapper {
        public String firstReference { get; set; }
        public String secondReference { get; set; }
    }

    class InvoicingListWrapper {
        public Integer pageNo { get; private set; }
        public List<AnkenMeisai__c> invoicingList { get; private set; }

        public InvoicingListWrapper(Integer pageNo) {
            this.pageNo = pageNo;
            invoicingList = new List<AnkenMeisai__c>();
        }

        public void addInvoicing(AnkenMeisai__c invoicing) {
            this.invoicingList.add(invoicing);
        }
    }


    static {
        forwardingFields.add('ID');
        forwardingFields.add('Name');
        forwardingFields.add('PrintDate__c');
        forwardingFields.add('WkInitial__c');
        forwardingFields.add('JobRequestID__c');
        forwardingFields.add('REFNO__c');
        forwardingFields.add('QuotationVer__c');
        forwardingFields.add('PersonInCharge__r.Name');
        forwardingFields.add('Cnee__r.EnglishCompanyName__c');
        forwardingFields.add('Cnee__r.EnglishAddress__c');
        forwardingFields.add('VESSEL_FLIGHT__c');
        forwardingFields.add('Voy_No__c');
        forwardingFields.add('HBL_Number_SEA_AIR__c');
        forwardingFields.add('MBL_Number_SEA_AIR__c');
        forwardingFields.add('shipper__r.EnglishCompanyName__c');
        forwardingFields.add('shipper__r.EnglishAddress__c');
        forwardingFields.add('POL__r.Name');
        forwardingFields.add('POL__r.Country_Name__c');
        forwardingFields.add('POD__r.Name');
        forwardingFields.add('POD__r.Country_Name__c');
        forwardingFields.add('Place_of_Delivery__r.Name');
        forwardingFields.add('Place_of_Delivery__r.Country_Name__c');
        forwardingFields.add('ETA__c');
        forwardingFields.add('ETD__c');
        forwardingFields.add('SalesAccountedDate__c');
        forwardingFields.add('Item__c');
        forwardingFields.add('carton__c');
        forwardingFields.add('UnitType__c');
        forwardingFields.add('weight__c');
        forwardingFields.add('CBM__c');
        forwardingFields.add('Container__c');
        forwardingFields.add('ContainerNumber__c');
        forwardingFields.add('Container2__c');
        forwardingFields.add('ContainerNumber2__c');
        forwardingFields.add('Container3__c');
        forwardingFields.add('ContainerNumber3__c');
        forwardingFields.add('Container4__c');
        forwardingFields.add('ContainerNumber4__c');
        forwardingFields.add('SellInTaxAmountJPY_sum__c');
        forwardingFields.add('BuyInTaxAmountJPY_sum__c');
        forwardingFields.add('RecordTypeId');

        invoicingFields.add('Id');
        invoicingFields.add('InsatuyouSyohinEng__c');
        invoicingFields.add('InsatuyouSyohin__c');
        invoicingFields.add('Suryo__c');
        invoicingFields.add('Tariff__r.UNIT__c');
        invoicingFields.add('KawaseSel__c');
        invoicingFields.add('SellAmountUSD__c');
        invoicingFields.add('UnitPriceofSelling3rdCurrency__c');
        invoicingFields.add('FxrateSelling3rdCurrencyFCY__c');   // CT  
        invoicingFields.add('FxrateSelling3rdCurrencyLocal__c'); // CT        
        invoicingFields.add('UnitPriceofBuying3rdCurrency__c');
        invoicingFields.add('FxrateBuying3rdCurrencyFCY__c');    // CT
        invoicingFields.add('FxrateBuying3rdCurrencyLocal__c');  // CT      
        invoicingFields.add('SellAmountJPN__c');
        invoicingFields.add('TaxInitial__c');
        invoicingFields.add('SellTaxNum__c');
        invoicingFields.add('SellInTaxAmountJPY__c');
        invoicingFields.add('PaymentTo__r.Name');
        invoicingFields.add('KawaseBay__c');
        invoicingFields.add('BuyAmountUSD__c');
        invoicingFields.add('BuyAmountJPN__c');
        invoicingFields.add('BuyTaxInitial__c');
        invoicingFields.add('BuyTaxNum__c');
        invoicingFields.add('BuyInTaxAmountJPY__c');
        invoicingFields.add('PROFIT_USD__c');
        invoicingFields.add('Ararigaku__c');
        invoicingFields.add('PaymentTo__r.Reference_Number__c');
        invoicingFields.add('SellInTaxAmount_USD__c');
        invoicingFields.add('BuyInTaxAmountUSD__c');
        invoicingFields.add('Seikyusaki__r.Name');
        invoicingFields.add('Seikyusaki__r.Reference_Number__c');
        invoicingFields.add('curr__c');
        invoicingFields.add('CurrencyBuying__c');
        invoicingFields.add('BuyTankaJPY__c');
        invoicingFields.add('SellTankaJPY__c');
        invoicingFields.add('Cost_Allocation_Margin__c');
        invoicingFields.add('TAX_ADJUSTMENT__c');
        invoicingFields.add('TAX_ADJUSTMENTSELL__c');
        invoicingFields.add('ADVANCE_PAYMENT_ON_BEHALF_OF__c');
        invoicingFields.add('AdvancePaymentOnBehalfOfOurCompany__c');
        invoicingFields.add('ChargeUnitInPrint__c');
        invoicingFields.add('AmountofTaxSelling3rdCurrency__c');
        invoicingFields.add('AmountofTaxBuying3rdCurrency__c');
        invoicingFields.add('SellTankaUSD__c');
    }
}