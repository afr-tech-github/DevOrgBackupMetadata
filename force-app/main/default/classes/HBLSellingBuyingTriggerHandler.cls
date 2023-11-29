public with sharing class HBLSellingBuyingTriggerHandler extends AbstractTriggerHandler {
    private static List<MgmtMaster__c> exchangeRates = new List<MgmtMaster__c>();
    private Map<Id, CustomObject1__c> mapShipments = new Map<Id, CustomObject1__c>();
    private Map<Id, Account> mapAccounts = new Map<Id, Account>();
    private Map<Id, MasterAnkenMeisai__c> mblBuyings = new Map<Id, MasterAnkenMeisai__c>();
    private Map<Id, TariffMaster__c> serviceMasters = new Map<Id, TariffMaster__c>();
    private TaxRatioService taxRatioService;
    private static TranslationService translationService;
    private static Map<Id, Decimal> nextHBLSBIndexPerHBL = new Map<Id, Decimal>();
    private Map<Id, CASH_BOOK__c> toBeUpdatedCashBookMap = new Map<Id, CASH_BOOK__c>();
    private Map<Id, List<CASH_BOOK__c>> cashBookByInvoicingMap = new Map<Id, List<CASH_BOOK__c>>();

    private static Site_Custom_Settings__c versionUnnitPrice;

    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());

        versionUnnitPrice = Site_Custom_Settings__c.getOrgDefaults();
    }

    static {
        exchangeRates = ExchangeRateSynchronizationService.loadMasterExchangeRates();
    }

    public override String getHandlerName() {
        return 'HBLSellingBuyingTriggerHandler';
    }

    public override void bulkAfter() {
        loadReferences(Trigger.new);
    }

    public override void bulkBefore() {
        if (Trigger.isDelete) {
            loadReferences(Trigger.old);
        } else {
            loadReferenceData(Trigger.new);
            taxRatioService = new TaxRatioService();
        }
    }

    public override void beforeInsert(SObject so) {
        AnkenMeisai__c meisai = (AnkenMeisai__c) so;

        if (!validateCurrency(meisai)) {
            return;
        }

        CustomObject1__c shipment = mapShipments.get(meisai.Anken__c);
        if (shipment != null && shipment.DeadlineForPaymentOfInvoices__c != null) {
            meisai.DUE_DATE_OF_PAYMENT_EXCLUDE_TAX__c = (shipment.DeadlineForPaymentOfInvoices__c.daysBetween(System.today()));
        }

        if (meisai.Seikyusaki__c != null) {
            meisai.Invoice_Destination_Type__c = mapAccounts.get(meisai.Seikyusaki__c).Custom_Type__c;

        }

        syncExchangeRate(meisai, shipment);
        setUpMasterShipmentLinks(meisai);
        //syncTaxRatio(meisai, shipment);
        syncTaxRatio(meisai);
        setUncollectedChargeReminderSentFlag(meisai);
        updateAccountingInfo(meisai, true);
        setChargeUnit(meisai);
        updateSellingBuyingPayment(meisai);
        updateServiceNameAtPrint(meisai);

        if(!versionUnnitPrice.SwitchToNewUnitPriceCalculation__c){
            updateUnitPrice(meisai); 
        }
       
        updateConfirmedAccounting(meisai);
        assignDisplayIndex(meisai);
    }

    private void assignDisplayIndex(AnkenMeisai__c meisai) {
        /*
            do not set Display Index if record type is Cost Consolidation
         */
        String recordType = RecordTypeUtil.getRecordTypeIdByDeveloperName(AnkenMeisai__c.SObjectType, Constants.SELLING_BUYING_CONSOLIDATION_RT);
        if (meisai.RecordTypeId != null && meisai.RecordTypeId.equals(recordType)) {
            return;
        }

        String shipmentId = meisai.Anken__c;
        Decimal currentIndex = nextHBLSBIndexPerHBL.get(shipmentId);
        currentIndex = (currentIndex == null ? 0 : currentIndex);

        if (meisai.SeikyuBangou__c == null) {
            if (currentIndex != null) {
                meisai.SeikyuBangou__c = ++currentIndex;
            } else {
                currentIndex = 1;
                meisai.SeikyuBangou__c = currentIndex;
            }
        } else {
            if (meisai.SeikyuBangou__c > currentIndex + 1) {
                currentIndex = meisai.SeikyuBangou__c;
            }
        }
        nextHBLSBIndexPerHBL.put(shipmentId, currentIndex);
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        AnkenMeisai__c meisai = (AnkenMeisai__c) so;

        if (!validateCurrency(meisai)) {
            return;
        }

        CustomObject1__c shipment = mapShipments.get(meisai.Anken__c);
        //syncTaxRatio(meisai, shipment);
        syncTaxRatio(meisai);

        if (meisai.Seikyusaki__c != null) {
            meisai.Invoice_Destination_Type__c = mapAccounts.get(meisai.Seikyusaki__c).Custom_Type__c;
        }
        setUpMasterShipmentLinks(meisai);
        setUncollectedChargeReminderSentFlag(meisai);

        
        if(!versionUnnitPrice.SwitchToNewUnitPriceCalculation__c){
            updateUnitPrice(meisai); 
        }
        updateAccountingInfo(meisai, false);
        updateSellingBuyingPayment(meisai);
        updateServiceNameAtPrint(meisai);
        updateConfirmedAccounting(meisai);
    }

    public override void afterUpdate(SObject oldSo, SObject so) {
        AnkenMeisai__c oldInvoicing = (AnkenMeisai__c) oldSo;
        AnkenMeisai__c invoicing = (AnkenMeisai__c) so;
        List<CASH_BOOK__c> cashBookList = cashBookByInvoicingMap.get(invoicing.Id);

        if (cashBookList != null && !cashBookList.isEmpty()) {
            for (CASH_BOOK__c cashBook : cashBookList) {
                Boolean hasChanged = false;
                if(oldInvoicing.BuyDifferentiation__c != invoicing.BuyDifferentiation__c){
                    if(cashBook.TotalAmount__c == null){
                        cashBook.TotalAmount__c = 0;
                    }
                    cashBook.TotalAmount__c -= oldInvoicing.BuyDifferentiation__c;
                    cashBook.TotalAmount__c += invoicing.BuyDifferentiation__c;
                    hasChanged = true;
                }

                if(oldInvoicing.UNPAID_BALANCE_OF_BUYING_USD__c != invoicing.UNPAID_BALANCE_OF_BUYING_USD__c){
                    if(cashBook.TotalAmountOfCashOutUSD__c == null){
                        cashBook.TotalAmountOfCashOutUSD__c = 0;
                    }
                    cashBook.TotalAmountOfCashOutUSD__c -= oldInvoicing.UNPAID_BALANCE_OF_BUYING_USD__c;
                    cashBook.TotalAmountOfCashOutUSD__c += invoicing.UNPAID_BALANCE_OF_BUYING_USD__c;
                    hasChanged = true;
                }

                if(oldInvoicing.SellDifferentiation__c != invoicing.SellDifferentiation__c){
                    if(cashBook.TotalAmountCashIn__c == null){
                        cashBook.TotalAmountCashIn__c = 0;
                    }
                    cashBook.TotalAmountCashIn__c -= oldInvoicing.SellDifferentiation__c;
                    cashBook.TotalAmountCashIn__c += invoicing.SellDifferentiation__c;
                    hasChanged = true;
                }

                if(oldInvoicing.UNPAID_BALANCE_OF_SELLING_USD__c != invoicing.UNPAID_BALANCE_OF_SELLING_USD__c){
                    if(cashBook.TotalAmountOfCashInUSD__c == null){
                        cashBook.TotalAmountOfCashInUSD__c = 0;
                    }
                    cashBook.TotalAmountOfCashInUSD__c -= oldInvoicing.UNPAID_BALANCE_OF_SELLING_USD__c;
                    cashBook.TotalAmountOfCashInUSD__c += invoicing.UNPAID_BALANCE_OF_SELLING_USD__c;
                    hasChanged = true;
                }

                //if (Util.isCashOut(cashBook)) {
                //    if (cashBook.TotalAmount__c != null && oldInvoicing.BuyInTaxAmountJPY__c != null) {
                //        cashBook.TotalAmount__c -= oldInvoicing.BuyInTaxAmountJPY__c;
                //        hasChanged = true;
                //    }

                //    if (cashBook.TotalAmount__c != null && invoicing.BuyInTaxAmountJPY__c != null) {
                //        cashBook.TotalAmount__c += invoicing.BuyInTaxAmountJPY__c;
                //        hasChanged = true;
                //    } else if (invoicing.BuyInTaxAmountJPY__c != null) {
                //        cashBook.TotalAmount__c = invoicing.BuyInTaxAmountJPY__c;
                //        hasChanged = true;
                //    }
                //} else {
                //    if (cashBook.TotalAmount__c != null && oldInvoicing.SellInTaxAmountJPY__c != null) {
                //        cashBook.TotalAmount__c -= oldInvoicing.SellInTaxAmountJPY__c;
                //        hasChanged = true;
                //    }

                //    if (cashBook.TotalAmount__c != null && invoicing.SellInTaxAmountJPY__c != null) {
                //        cashBook.TotalAmount__c += invoicing.SellInTaxAmountJPY__c;
                //        hasChanged = true;
                //    } else if (invoicing.SellInTaxAmountJPY__c != null) {
                //        cashBook.TotalAmount__c = invoicing.SellInTaxAmountJPY__c;
                //        hasChanged = true;
                //    }
                //}

                if (hasChanged && !toBeUpdatedCashBookMap.containsKey(cashBook.Id)) {
                    toBeUpdatedCashBookMap.put(cashBook.Id, cashBook);
                }
            }
        }
    }

    public override void beforeDelete(SObject so) {
        AnkenMeisai__c invoicing = (AnkenMeisai__c) so;
        List<CASH_BOOK__c> cashBookList = cashBookByInvoicingMap.get(invoicing.Id);

        if (cashBookList != null && !cashBookList.isEmpty()) {
            for (CASH_BOOK__c cashBook : cashBookList) {
                Boolean hasChanged = true;

                if(cashBook.TotalAmount__c == null){
                    cashBook.TotalAmount__c = 0;
                }
                cashBook.TotalAmount__c -= invoicing.BuyDifferentiation__c;
                

                if(cashBook.TotalAmountOfCashOutUSD__c == null){
                    cashBook.TotalAmountOfCashOutUSD__c = 0;
                }
                cashBook.TotalAmountOfCashOutUSD__c -= invoicing.UNPAID_BALANCE_OF_BUYING_USD__c;
                

                if(cashBook.TotalAmountCashIn__c == null){
                    cashBook.TotalAmountCashIn__c = 0;
                }
                cashBook.TotalAmountCashIn__c -= invoicing.SellDifferentiation__c;
            

                if(cashBook.TotalAmountOfCashInUSD__c == null){
                    cashBook.TotalAmountOfCashInUSD__c = 0;
                }
                cashBook.TotalAmountOfCashInUSD__c -= invoicing.UNPAID_BALANCE_OF_SELLING_USD__c;
                
                
                /*if (Util.isCashOut(cashBook)) {
                    if (cashBook.TotalAmount__c != null && invoicing.BuyInTaxAmountJPY__c != null) {
                        cashBook.TotalAmount__c -= invoicing.BuyInTaxAmountJPY__c;
                        hasChanged = true;
                    }
                } else {
                    if (cashBook.TotalAmount__c != null && invoicing.SellInTaxAmountJPY__c != null) {
                        cashBook.TotalAmount__c -= invoicing.SellInTaxAmountJPY__c;
                        hasChanged = true;
                    }
                }*/

                if (hasChanged && !toBeUpdatedCashBookMap.containsKey(cashBook.Id)) {
                    toBeUpdatedCashBookMap.put(cashBook.Id, cashBook);
                }
            }
        }
    }

    // public override void andFinally() {
    //     if (!toBeUpdatedCashBookMap.isEmpty()) {
    //     }
    // }

    private void syncExchangeRate(AnkenMeisai__c meisai, CustomObject1__c shipment) {
        if(shipment != null){

        Boolean isQuotation = ObjectClassificationUtils.isQuotationHBL(shipment);
        ExchangeRateSynchronizationService.applyExchangeRateToHBLSellingBuying(exchangeRates, meisai, shipment.Custom__c,
                shipment.PrintDate__c, mapAccounts.get(meisai.Seikyusaki__c),
                mapAccounts.get(meisai.PaymentTo__c), isQuotation);
                        
        }
    }

    private void syncTaxRatio(AnkenMeisai__c meisai, CustomObject1__c shipment) {
        String invoiceToCurrency = (mapAccounts.get(meisai.Seikyusaki__c) != null ? mapAccounts.get(meisai.Seikyusaki__c).Currency__c : null);
        String paymentToCurrency = (mapAccounts.get(meisai.PaymentTo__c) != null ? mapAccounts.get(meisai.PaymentTo__c).Currency__c : null);

        taxRatioService.populateHBLTaxRatio(meisai, shipment, invoiceToCurrency, paymentToCurrency);
    }

    private void syncTaxRatio(AnkenMeisai__c meisai){
        String invoiceToCurrency = (mapAccounts.get(meisai.Seikyusaki__c) != null ? mapAccounts.get(meisai.Seikyusaki__c).Currency__c : null);
        String paymentToCurrency = (mapAccounts.get(meisai.PaymentTo__c) != null ? mapAccounts.get(meisai.PaymentTo__c).Currency__c : null);

        if(meisai.SalesAccountedDateInvoicing__c != null){
            taxRatioService.populateHBLTaxRatio(meisai, invoiceToCurrency, paymentToCurrency);
        }
    }

    private void setUncollectedChargeReminderSentFlag(AnkenMeisai__c meisai) {
        if (meisai.LastModifiedDate == null) {
            meisai.Uncollected_Charge_Reminder_Sent__c = false;
        } else {
            Date lastModifiedDate = Date.newInstance(meisai.LastModifiedDate.year(), meisai.LastModifiedDate.month(), meisai.LastModifiedDate.day());

            if (meisai.Last_Sent_Uncollected_Charge_Reminder__c == null) {
                meisai.Uncollected_Charge_Reminder_Sent__c = false;
            } else if (meisai.Last_Sent_Uncollected_Charge_Reminder__c.daysBetween(lastModifiedDate) > 0) {
                meisai.Uncollected_Charge_Reminder_Sent__c = false;
            } else {
                meisai.Uncollected_Charge_Reminder_Sent__c = true;
            }
        }
    }


    /**
     * Logic to calculate the unit price:
     * 1: Take manual input including 0
     * 2. If NULL, calculate from the other value with exchange rate including exchange rate is 0
     * 3. Take from Pricing
     */
         
   private void updateUnitPrice(AnkenMeisai__c meisai) {
       TariffMaster__c serviceMaster = serviceMasters.get(meisai.Tariff__c);

        // For BUYING
        if (!StringUtils.isEmpty(meisai.Cost_Allocation_Catetory__c) && meisai.AM_MasterMeisaiID__c != null) {
            meisai.BuyTankaJPY__c = (meisai.BuyTankaJPY__c != null) ? meisai.BuyTankaJPY__c : meisai.AM_BuyInAfter_allocation__c;
            meisai.BuyTankaUSD__c = (meisai.BuyTankaUSD__c != null) ? meisai.BuyTankaUSD__c : meisai.AM_BuyInAfter_allocation_USD__c;
        } else {
            if (meisai.KawaseBay__c == null) {
                meisai.BuyTankaJPY__c = (meisai.BuyTankaJPY__c != null) ? meisai.BuyTankaJPY__c : (serviceMaster != null?serviceMaster.BuyKingaku__c :null);
                meisai.BuyTankaUSD__c = (meisai.BuyTankaUSD__c != null) ? meisai.BuyTankaUSD__c : (serviceMaster != null?serviceMaster.BuyAmountUSD__c :null);
            } else {
                if (NumbericUtils.isNonZero(meisai.BuyTankaUSD__c)) {
                    meisai.BuyTankaJPY__c = (meisai.BuyTankaJPY__c != null) ? meisai.BuyTankaJPY__c : meisai.BuyTankaUSD__c * meisai.KawaseBay__c;
                } else if (NumbericUtils.isNonZero(meisai.BuyTankaJPY__c)) {
                    meisai.BuyTankaUSD__c = (meisai.BuyTankaUSD__c != null || meisai.KawaseBay__c == 0) ? meisai.BuyTankaUSD__c : meisai.BuyTankaJPY__c / meisai.KawaseBay__c;
                } else if (NumbericUtils.isNonZero(serviceMaster.BuyAmountUSD__c)) {
                    meisai.BuyTankaUSD__c = (meisai.BuyTankaUSD__c != null) ? meisai.BuyTankaUSD__c : (serviceMaster != null?serviceMaster.BuyAmountUSD__c :null);
                    meisai.BuyTankaJPY__c = (meisai.BuyTankaJPY__c != null) ? meisai.BuyTankaJPY__c : meisai.BuyTankaUSD__c * meisai.KawaseBay__c;
                } else if (NumbericUtils.isNonZero(serviceMaster.BuyKingaku__c)) {
                    meisai.BuyTankaJPY__c = (meisai.BuyTankaJPY__c != null) ? meisai.BuyTankaJPY__c : (serviceMaster != null?serviceMaster.BuyKingaku__c :null);
                    meisai.BuyTankaUSD__c = (meisai.BuyTankaUSD__c != null || meisai.KawaseBay__c == 0) ? meisai.BuyTankaUSD__c : meisai.BuyTankaJPY__c / meisai.KawaseBay__c;
                }
            }
        }

        // For SELLING
        if (meisai.KawaseSel__c == null) {
            meisai.SellTankaJPY__c = (meisai.SellTankaJPY__c != null) ? meisai.SellTankaJPY__c : (serviceMaster != null?serviceMaster.SellKingakuJPY__c :null);
            meisai.SellTankaUSD__c = (meisai.SellTankaUSD__c != null) ? meisai.SellTankaUSD__c : (serviceMaster != null?serviceMaster.SellAmountUSD__c :null);
        } else {
            if (NumbericUtils.isNonZero(meisai.SellTankaUSD__c)) {
                meisai.SellTankaJPY__c = (meisai.SellTankaJPY__c != null) ? meisai.SellTankaJPY__c : meisai.SellTankaUSD__c * meisai.KawaseSel__c;
            } else if (NumbericUtils.isNonZero(meisai.SellTankaJPY__c)) {
                meisai.SellTankaUSD__c = (meisai.SellTankaUSD__c != null || meisai.KawaseSel__c == 0) ? meisai.SellTankaUSD__c : meisai.SellTankaJPY__c / meisai.KawaseSel__c;
            } else if (NumbericUtils.isNonZero(serviceMaster.SellAmountUSD__c)) {
                meisai.SellTankaUSD__c = (meisai.SellTankaUSD__c != null) ? meisai.SellTankaUSD__c : (serviceMaster != null?serviceMaster.SellAmountUSD__c :null);
                meisai.SellTankaJPY__c = (meisai.SellTankaJPY__c != null) ? meisai.SellTankaJPY__c : meisai.SellTankaUSD__c * meisai.KawaseSel__c;
            } else if (NumbericUtils.isNonZero(serviceMaster.SellKingakuJPY__c)) {
                meisai.SellTankaJPY__c = (meisai.SellTankaJPY__c != null) ? meisai.SellTankaJPY__c : (serviceMaster != null?serviceMaster.SellKingakuJPY__c :null);
                meisai.SellTankaUSD__c = (meisai.SellTankaUSD__c != null || meisai.KawaseSel__c == 0) ? meisai.SellTankaUSD__c : meisai.SellTankaJPY__c / meisai.KawaseSel__c;
           }
        }
    }


    private void loadReferenceData(List<AnkenMeisai__c> meisais) {
        Set<Id> shipmentIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> mblIds = new Set<Id>();
        Set<Id> serviceMasterIds = new Set<Id>();

        for (AnkenMeisai__c meisai : meisais) {
            shipmentIds.add(meisai.Anken__c);
            accountIds.add(meisai.PaymentTo__c);
            accountIds.add(meisai.Seikyusaki__c);
            serviceMasterIds.add(meisai.Tariff__c);
        }

        // Load HBL-SHIPMENTs
        mapShipments = new Map<Id, CustomObject1__c>([
                SELECT Id, SalesAccountedDate__c, Custom__c, MasterAnkenName__c,
                        ContainerNumber__c, Container__c, ContainerNumber2__c, Container2__c,
                        ContainerNumber3__c, Container3__c, ContainerNumber4__c, Container4__c,
                        DeadlineForPaymentOfInvoices__c, POD__r.Country_Name__c,
                        POL__r.Country_Name__c, RecordTypeId,
                        CBM_Non_Zero__c, Gross_Weight_RTON__c, ETA__c, ETD__c, PrintDate__c, (SELECT SeikyuBangou__c FROM Anken__r Order By SeikyuBangou__c DESC LIMIT 1)
                FROM CustomObject1__c
                WHERE Id IN :shipmentIds
        ]);

        // Build the map of last INVOICING index per FORWARDING
        for (String shipmentId : mapShipments.keySet()) {
            List<AnkenMeisai__c> hblsbs = mapShipments.get(shipmentId).Anken__r;
            if (hblsbs != null && !hblsbs.isEmpty()) {
                nextHBLSBIndexPerHBL.put(shipmentId, hblsbs.get(0).SeikyuBangou__c);
            }
        }

        // Load Invoice To and Payment To (Account)
        mapAccounts = new Map<Id, Account>([
                SELECT Id, Custom_Type__c, Currency__c, Business_Relationship__c,
                        Primary_Exchange_Rate_Currency__c, Secondary_Exchange_Rate_Currency__c
                FROM Account
                WHERE Id IN :accountIds
        ]);

        // Load MBL BUYING
        for (CustomObject1__c shipment : mapShipments.values()) {
            mblIds.add(shipment.MasterAnkenName__c);
        }
        mblBuyings = new Map<Id, MasterAnkenMeisai__c>([
                SELECT Id, Cost_Allocation_Catetory__c, MasterAnken__c
                FROM MasterAnkenMeisai__c
                WHERE MasterAnken__c IN :mblIds
        ]);

        serviceMasters = new Map<Id, TariffMaster__c>([
                SELECT Id, Unit__c, Subcategory__c, ContainerSize__c,
                        SellAmountUSD__c, SellKingakuJPY__c, EngPrintProduct__c, PrintProduct__c,
                        BuyKingaku__c, BuyAmountUSD__c
                FROM TariffMaster__c
                WHERE Id IN :serviceMasterIds
        ]);
    }

    private void updateAccountingInfo(AnkenMeisai__c meisai, boolean newRecord) {
        CustomObject1__c shipment = mapShipments.get(meisai.Anken__c);

        // Reset fields
        if (newRecord) {
            meisai.buying_debit_category_accouting__c = null;
            meisai.buying_credit_category_accouting__c = null;
            meisai.buying_credit_tax_type_accounting__c = null;
            meisai.buying_debit_tax_type_accounting__c = null;
            meisai.selling_debit_category_accouting__c = null;
            meisai.selling_credit_category_accouting__c = null;
            meisai.Selling_debit_tax_type_accounting__c = null;
            meisai.Selling_credit_tax_type_accounting__c = null;
        }

        // Populate values for fields
        if (shipment != null && PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO.equalsIgnoreCase(shipment.Custom__c)) {
            if (meisai.BuyInTaxAmountJPY__c != 0 && meisai.SiharaiKakuninzumi__c == true) {
                meisai.buying_credit_tax_type_accounting__c = PicklistReference.BUYING_TAX_CAT_CREDIT_OUT_OF_SCOPE;

                if (newRecord) {
                    meisai.buying_debit_category_accouting__c = PicklistReference.BUYING_DEBIT_COSTS;
                    meisai.buying_credit_category_accouting__c = PicklistReference.BUYING_CREDIT_ORDINARY_ACCOUNT;
                }

                if (PicklistReference.PRODUCT_TAX.equalsIgnoreCase(meisai.ProductTax__c) || PicklistReference.DUAL_PRODUCT_TAX.equalsIgnoreCase(meisai.ProductTax__c)) {
                    meisai.buying_debit_tax_type_accounting__c = PicklistReference.BUYING_TAX_CAT_DEBIT_COSTS_INCLUDED;
                } else if (PicklistReference.PRODUCT_FREE_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.DUAL_PRODUCT_FREE_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.PRODUCT_NON_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.DUAL_PRODUCT_NON_TAX.equalsIgnoreCase(meisai.ProductTax__c)) {
                    meisai.buying_debit_tax_type_accounting__c = PicklistReference.BUYING_TAX_CAT_DEBIT_OUT_OF_SCOPE;
                }
            }
			System.debug('11 :'+meisai.SellInTaxAmountJPY__c);
            System.debug('22 :'+meisai.NyukinKakuninzumi__c);
            if (meisai.SellInTaxAmountJPY__c != 0 && meisai.NyukinKakuninzumi__c == true) {
                meisai.Selling_debit_tax_type_accounting__c = PicklistReference.SELLING_TAX_CAT_DEBIT_OUT_SCOPE;

                if (newRecord) {
                    meisai.selling_debit_category_accouting__c = PicklistReference.SELLING_DEBIT_ORDINARY_ACCOUNT;
                    meisai.selling_credit_category_accouting__c = PicklistReference.SELLING_CREDIT_SALES;
                }

                if (PicklistReference.PRODUCT_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.DUAL_PRODUCT_TAX.equalsIgnoreCase(meisai.ProductTax__c)) {
                    meisai.Selling_credit_tax_type_accounting__c = PicklistReference.SELLING_TAX_CAT_CREDIT_COSTS_INCLUDED;
                } else if (PicklistReference.PRODUCT_FREE_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.DUAL_PRODUCT_FREE_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.PRODUCT_NON_TAX.equalsIgnoreCase(meisai.ProductTax__c)
                        || PicklistReference.DUAL_PRODUCT_NON_TAX.equalsIgnoreCase(meisai.ProductTax__c)) {
                    meisai.Selling_credit_tax_type_accounting__c = PicklistReference.SELLING_TAX_CAT_CREDIT_EXPORT_SALES;
                }
            }
        }
    }

    private void setUpMasterShipmentLinks(AnkenMeisai__c meisai) {
        CustomObject1__c shipment = mapShipments.get(meisai.Anken__c);
        String costCategory = meisai.Cost_Allocation_Catetory__c;
        if(shipment != null && shipment.MasterAnkenName__c != null){
            meisai.AM_MasterID__c = shipment.MasterAnkenName__c;
        }
        
        meisai.AM_MasterMeisaiID__c = null;

        if (shipment != null && shipment.MasterAnkenName__c != null && !StringUtils.isEmpty(costCategory)) {
            for (MasterAnkenMeisai__c mam : mblBuyings.values()) {
                if (costCategory.equalsIgnoreCase(mam.Cost_Allocation_Catetory__c)
                        && shipment.MasterAnkenName__c == mam.MasterAnken__c) {
                    meisai.AM_MasterMeisaiID__c = mam.Id;
                }
            }
        }
    }
    
    /**
     * Set the Quantity (Suryo__c) for HBL SB based on its Service Master service provider
     * and HBL Container Quantity.
     * This is applied for FCL service and on creation only
     */
    private void setChargeUnit(AnkenMeisai__c meisai) {
        TariffMaster__c serviceMaster = serviceMasters.get(meisai.Tariff__c);

        if (serviceMaster != null && PicklistReference.UNIT_CONTAINER.equals(serviceMaster.UNIT__c)
                && (PicklistReference.SEARCH_ENGINE_FCL_EXPORT.equals(meisai.SerchSyubetu__c)
                || PicklistReference.SEARCH_ENGINE_FCL_IMPORT.equals(meisai.SerchSyubetu__c))) {
            meisai.Suryo__c = 1;
            CustomObject1__c shipment = mapShipments.get(meisai.Anken__c);

            if (!StringUtils.isEmpty(serviceMaster.ContainerSize__c)) {
                if (serviceMaster.ContainerSize__c.equals(shipment.Container__c)) {
                    meisai.Suryo__c = shipment.ContainerNumber__c;
                } else if (serviceMaster.ContainerSize__c.equals(shipment.Container2__c)) {
                    meisai.Suryo__c = shipment.ContainerNumber2__c;
                } else if (serviceMaster.ContainerSize__c.equals(shipment.Container3__c)) {
                    meisai.Suryo__c = shipment.ContainerNumber3__c;
                } else if (serviceMaster.ContainerSize__c.equals(shipment.Container4__c)) {
                    meisai.Suryo__c = shipment.ContainerNumber4__c;
                }
            }
        } else if (serviceMaster != null && PicklistReference.UNIT_RTON.equals(serviceMaster.UNIT__c)) {
            meisai.Suryo__c = 1;
            CustomObject1__c shipment = mapShipments.get(meisai.Anken__c);

            if (shipment.CBM_Non_Zero__c > 1 || shipment.Gross_Weight_RTON__c > 1) {
                if (shipment.CBM_Non_Zero__c > shipment.Gross_Weight_RTON__c) {
                    meisai.Suryo__c = shipment.CBM_Non_Zero__c;
                } else {
                    meisai.Suryo__c = shipment.Gross_Weight_RTON__c;
                }
            }
        }
    }

    private void updateSellingBuyingPayment(AnkenMeisai__c meisai) {
        System.debug('UPdateTRigger?');
        if (meisai.NyukinKakuninzumi__c == true) {
            if (meisai.Nyukingaku__c == null || meisai.Nyukingaku__c == 0) {
                meisai.Nyukingaku__c = meisai.SellInTaxAmountJPY__c;
            }

            if (meisai.AMOUNT_PAID_SELLING_USD__c == null || meisai.AMOUNT_PAID_SELLING_USD__c == 0) {
                meisai.AMOUNT_PAID_SELLING_USD__c = meisai.SellAmountUSD__c;
            }
        }

        if (meisai.SiharaiKakuninzumi__c == true) {
            if (meisai.Siharaigaku__c == null || meisai.Siharaigaku__c == 0) {
                meisai.Siharaigaku__c = meisai.BuyInTaxAmountJPY__c;
            }

            if (meisai.AMOUNT_PAID_BUYING_USD__c == null || meisai.AMOUNT_PAID_BUYING_USD__c == 0) {
                meisai.AMOUNT_PAID_BUYING_USD__c = meisai.BuyAmountUSD__c;
            }
        }
    }

    private void updateServiceNameAtPrint(AnkenMeisai__c meisai) {
        TariffMaster__c serviceMaster = serviceMasters.get(meisai.Tariff__c);

        if (serviceMaster != null && StringUtils.isEmpty(meisai.InsatuyouSyohinEng__c)) {
            meisai.InsatuyouSyohinEng__c = serviceMaster.EngPrintProduct__c;
        }

        if (serviceMaster != null && StringUtils.isEmpty(meisai.InsatuyouSyohin__c)) {
            meisai.InsatuyouSyohin__c = serviceMaster.PrintProduct__c;
        }
    }

    private boolean validateCurrency(AnkenMeisai__c meisai) {
        boolean result = true;
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();

        // if (!meisai.curr__c.equalsIgnoreCase(setting.Local_Currency__c) && !meisai.curr__c.equalsIgnoreCase(PicklistReference.CURRENCY_USD)) {
            // result = false;

            // if (PicklistReference.CURRENCY_USD.equals(setting.Local_Currency__c)) {
                // meisai.addError(translationService.getTranslation(Constants.UNAVAILABLE_CURRENCY));
            // } else {
                // meisai.addError(translationService.getTranslation(Constants.UNAVAILABLE_CURRENCY) + ', ' + setting.Local_Currency__c);
            // }
        // }
        return result;
    }

    private void updateConfirmedAccounting(AnkenMeisai__c meisai) {
        if (meisai.NyukinKakuninzumi__c == true) {
            meisai.AMOUNT_PAID_SELLING_USD__c = meisai.SellInTaxAmount_USD__c;
        }

        if (meisai.SiharaiKakuninzumi__c == true) {
            meisai.AMOUNT_PAID_BUYING_USD__c = meisai.BuyInTaxAmountUSD__c;
        }
    }

    private void loadReferences(List<AnkenMeisai__c> invoices) {
        Set<Id> invIds = new Set<Id>();

        if (invoices != null && !invoices.isEmpty()) {
            for (AnkenMeisai__c invoice : invoices) {
                invIds.add(invoice.Id);
            }
        }

        List<ConnectInvoicingAndCash__c> invCashList = [
                SELECT Invoicing__c, Cashbook__c
                FROM ConnectInvoicingAndCash__c
                WHERE Invoicing__c IN :invIds
        ];

        Map<Id, List<Id>> cashBookToINVList = new Map<Id, List<Id>>();
        for (ConnectInvoicingAndCash__c inv : invCashList) {
            if (cashBookToINVList.containsKey(inv.Cashbook__c)) {
                cashBookToINVList.get(inv.Cashbook__c).add(inv.Invoicing__c);
            } else {
                List<Id> invIdList = new List<Id>();
                invIdList.add(inv.Invoicing__c);
                cashBookToINVList.put(inv.Cashbook__c, invIdList);
            }
        }

        // load cash book
        if (!cashBookToINVList.keySet().isEmpty()) {
            List<CASH_BOOK__c> cashBookList = [SELECT Id, 
                                                    TotalAmountCashIn__c, 
                                                    TotalAmount__c,
                                                    TotalAmountOfCashOutUSD__c,
                                                    TotalAmountOfCashInUSD__c, 
                                                    RecordTypeId 
                                                    FROM CASH_BOOK__c WHERE Id IN :cashBookToINVList.keySet()];

            for (CASH_BOOK__c cashBook : cashBookList) {
                List<Id> invIdList = cashBookToINVList.get(cashBook.Id);

                if (!invIdList.isEmpty()) {
                    for (Id invId : invIdList) {
                        if (cashBookByInvoicingMap.containsKey(invId)) {
                            cashBookByInvoicingMap.get(invId).add(cashBook);
                        } else {
                            List<CASH_BOOK__c> invCashBookList = new List<CASH_BOOK__c>();
                            invCashBookList.add(cashBook);
                            cashBookByInvoicingMap.put(invId, invCashBookList);
                        }
                    }
                }
            }
        }
    }
}