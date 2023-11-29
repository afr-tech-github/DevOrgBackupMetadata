public with sharing class ProfitSheetController {
    private static List<String> invoicingFields = new List<String>();
    private static List<String> forwardingFields = new List<String>();
    private static final Integer FIRST_PAGE_SIZE = 9;
    private static final Integer SUBSEQUENCE_PAGE_SIZE = 17;

    private String shipmentId;
    public transient CustomObject1__c shipment { get; private set; }
    public transient List<AnkenMeisai__c> invoicingList { get; private set; }
    public transient Map<String, String> translations { get; private set; }
    public transient Set<String> referenceNumberToNameList { get; private set; }
    public transient List<ProfitRatioSummaryWrapper> profitRatioSummaryList { get; private set; }
    public transient RevenueCostSummaryWrapper renvenueCostSummary { get; private set; }
    public transient List<ReferenceLineWrapper> referenceLines { get; private set; }
    public transient List<InvoicingListWrapper> invoicingListWrappers { get; private set; }
    public Integer numberOfPages { get; private set; }

    public ProfitSheetController() {
        getParameters();
        initializeTranslation();

        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()
                && PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort()
                && PermissionValidationUtil.isAccessibleServiceMaster() && PermissionValidationUtil.isAccessibleWarehouse()) {

        }

        retrieveShipmentWithInvoicingRecords(shipmentId);
        buildReferenceLineWrapper();
        numberOfPages = invoicingListWrappers.size();
    }

    private void getParameters() {
        shipmentId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
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

    private void retrieveShipmentWithInvoicingRecords(String shipmentId) {
        referenceNumberToNameList = new Set<String>();
        profitRatioSummaryList = new List<ProfitRatioSummaryWrapper>();
        renvenueCostSummary = new RevenueCostSummaryWrapper();
        invoicingListWrappers = new List<InvoicingListWrapper>();

        final String query = 'SELECT ' + String.join(forwardingFields, ',') +
                ', (SELECT ' + String.join(invoicingFields, ',') + ' FROM Anken__r) ' +
                ' FROM CustomObject1__c WHERE Id = \'' + shipmentId + '\'';
        shipment = Database.query(query);
        if (shipment != null && shipment.Anken__r != null && !shipment.Anken__r.isEmpty()) {
            invoicingList = shipment.Anken__r;
            Map<String, ProfitRatioSummaryWrapper> profitRatioMap = new Map<String, ProfitRatioSummaryWrapper>();

            Integer recordCount = 0;
            Boolean firstPage = true;
            Integer pageNo = 0;
            InvoicingListWrapper invoicingListWrapper = null;

            for (AnkenMeisai__c invoicing : invoicingList) {
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
                invoicingListWrapper.addInvoicing(invoicing);

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

                Decimal sellingAmount = Util.calculateSellingAmount(invoicing);
                Decimal sellingAmountInclTax = Util.calculateSellingInTaxAmount(invoicing);
                Decimal buyingAmount = Util.calculateBuyingAmount(invoicing);
                Decimal buyingAmountInclTax = Util.calculateBuyingInTaxAmount(invoicing);

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
                //renvenueCostSummary.totalRevenueInclTax += sellingAmountInclTax;//invoicing.SellInTaxAmountJPY__c;
                renvenueCostSummary.totalRevenueInclTax = renvenueCostSummary.totalRevenue +  renvenueCostSummary.totalRevenueTax;
                renvenueCostSummary.totalCost += buyingAmount;//invoicing.BuyAmountJPN__c;
                renvenueCostSummary.totalCostUSD += invoicing.BuyAmountUSD__c;
                renvenueCostSummary.totalCostTax += invoicing.BuyTaxNum__c;
                //renvenueCostSummary.totalCostInclTax += buyingAmountInclTax;//invoicing.BuyInTaxAmountJPY__c;
                renvenueCostSummary.totalCostInclTax = renvenueCostSummary.totalCost + renvenueCostSummary.totalCostTax;
                renvenueCostSummary.totalProfit += invoicing.Ararigaku__c;
                renvenueCostSummary.totalProfitUSD += invoicing.PROFIT_USD__c;
            }

            profitRatioSummaryList = profitRatioMap.values();
            if (!profitRatioSummaryList.isEmpty()) {
                ProfitRatioSummaryWrapper profitRatio = new ProfitRatioSummaryWrapper();
                profitRatio.referenceNumber = 'TOTAL';

                for (ProfitRatioSummaryWrapper pr : profitRatioSummaryList) {
                    profitRatio.sumOfSellingAmount += pr.sumOfSellingAmount;
                    profitRatio.sumOfSellingAmountUSD += pr.sumOfSellingAmountUSD;
                    profitRatio.sumOfBuyingAmount += pr.sumOfBuyingAmount;
                    profitRatio.sumOfBuyingAmountUSD += pr.sumOfBuyingAmountUSD;
                    profitRatio.sumOfSellingInclTaxAmount += pr.sumOfSellingInclTaxAmount;
                    profitRatio.sumOfSellingInclTaxAmountUSD += pr.sumOfSellingInclTaxAmountUSD;
                    profitRatio.sumOfBuyingInclTaxAmount += pr.sumOfBuyingInclTaxAmount;
                    profitRatio.sumOfBuyingInclTaxAmountUSD += pr.sumOfBuyingInclTaxAmountUSD;
                }

                profitRatioSummaryList.add(profitRatio);
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

        invoicingFields.add('Id');
        invoicingFields.add('InsatuyouSyohinEng__c');
        invoicingFields.add('InsatuyouSyohin__c');
        invoicingFields.add('Suryo__c');
        invoicingFields.add('Tariff__r.UNIT__c');
        invoicingFields.add('KawaseSel__c');
        invoicingFields.add('SellAmountUSD__c');
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
        invoicingFields.add('BuyTankaJPY__c');
        invoicingFields.add('SellTankaJPY__c');
        invoicingFields.add('Cost_Allocation_Margin__c');
        invoicingFields.add('TAX_ADJUSTMENT__c');
        invoicingFields.add('TAX_ADJUSTMENTSELL__c');
    }
}