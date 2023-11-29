/**
 * This service will set the Tax Ratio for HBL SELLING/BUYING and MBL BUYING.
 * The selected Tax Ratio is based on the matched currency of Tax Ratio and subject to calculate tax ration 
 * and whether ETA/ETD within valid period of a Tax Ratio.
 * For HBL SELLING/BUYING, the subject is Invoice To/Payment To-Buying.
 * For MBL BUYING, the subject is SERVICE MASTER -> SERVICE PROVIDER VENDOR
 */
public with sharing class TaxRatioService {
    private static List<Tax_Ratio__c> taxRatios = new List<Tax_Ratio__c>();
    private static Boolean taxRatioLoaded = false;

    public void populateHBLTaxRatio(AnkenMeisai__c meisai, CustomObject1__c hbl, String invoiceToCurrency, String paymentToCurrency) {
        if (PicklistReference.PRODUCT_TAX.equals(meisai.ProductTax__c) || PicklistReference.DUAL_PRODUCT_TAX.equals(meisai.ProductTax__c)) {
            Boolean isImportHBL = ObjectClassificationUtils.isImportHBL(hbl);
            Boolean isExportHBL = ObjectClassificationUtils.isExportHBL(hbl);
            Boolean isCrossBoarder = ObjectClassificationUtils.isCrossBoarder(hbl);
            Boolean isDomestic = ObjectClassificationUtils.isDomesticTransportation(hbl);

            if ((isImportHBL && hbl.ETA__c != null) || ((isExportHBL || isCrossBoarder || isDomestic) && hbl.ETD__c != null)) {
                loadTaxRatios();
                Date lookupDate = hbl.ETA__c;

                if (isExportHBL || isCrossBoarder || isDomestic) {
                    lookupDate = hbl.ETD__c;
                }
                populateHBLSellingTaxRatio(meisai, lookupDate, invoiceToCurrency);
                populateHBLBuyingTaxRatio(meisai, lookupDate, paymentToCurrency);
            }
        }
    }

     public void populateHBLTaxRatio(AnkenMeisai__c meisai, String invoiceToCurrency, String paymentToCurrency) {

        if (PicklistReference.PRODUCT_TAX.equals(meisai.ProductTax__c) || PicklistReference.DUAL_PRODUCT_TAX.equals(meisai.ProductTax__c)) {
            loadTaxRatios();
            populateHBLSellingTaxRatio(meisai, meisai.SalesAccountedDateInvoicing__c, invoiceToCurrency);
            populateHBLBuyingTaxRatio(meisai, meisai.SalesAccountedDateInvoicing__c, paymentToCurrency);
        }
    }

    public void populateMBLTaxRatio(MasterAnkenMeisai__c ankenMeisai, MasterAnken__c mbl, String paymentToCurrency) {
        if (PicklistReference.PRODUCT_TAX.equals(ankenMeisai.ProductTax__c) || PicklistReference.DUAL_PRODUCT_TAX.equals(ankenMeisai.ProductTax__c)) {
            boolean isImportMBL = ObjectClassificationUtils.isImportMBL(mbl.Master_Record_Type__c);
            boolean isExportMBL = ObjectClassificationUtils.isExportMBL(mbl.Master_Record_Type__c);

            if ((isImportMBL && mbl.META__c != null) || (isExportMBL && mbl.METD__c != null)) {
                loadTaxRatios();
                Date lookupDate = mbl.META__c;

                if (isExportMBL) {
                    lookupDate = mbl.METD__c;
                }

                populateMBLBuyingTaxRatio(ankenMeisai, lookupDate, paymentToCurrency);
            }
        }
    }

    private void populateHBLSellingTaxRatio(AnkenMeisai__c meisai, Date lookupDate, String invoiceToCurrency) {
        if (!StringUtils.isEmpty(invoiceToCurrency)) {
            Tax_Ratio__c sellingTaxRatio = findTaxRatio(invoiceToCurrency, lookupDate);
            if (sellingTaxRatio != null && (meisai.TaxInitial__c == null)) {
                meisai.TaxInitial__c = sellingTaxRatio.Selling_Tax_Ratio__c;
            }
        }
    }

    private void populateHBLBuyingTaxRatio(AnkenMeisai__c meisai, Date lookupDate, String paymentToCurrency) {
        if (!StringUtils.isEmpty(paymentToCurrency)) {
            Tax_Ratio__c buyingTaxRatio = findTaxRatio(paymentToCurrency, lookupDate);
            if (buyingTaxRatio != null && (meisai.BuyTaxInitial__c == null)) {
                meisai.BuyTaxInitial__c = buyingTaxRatio.Buying_Tax_Ratio__c;
            }
        }
    }

    private void populateMBLBuyingTaxRatio(MasterAnkenMeisai__c ankenMeisai, Date lookupDate, String paymentToCurrency) {
        if (!StringUtils.isEmpty(paymentToCurrency)) {
            Tax_Ratio__c buyingTaxRatio = findTaxRatio(paymentToCurrency, lookupDate);
            if (buyingTaxRatio != null && (ankenMeisai.BuyTaxInitial__c == null || ankenMeisai.BuyTaxInitial__c == 0)) {
                ankenMeisai.BuyTaxInitial__c = buyingTaxRatio.Buying_Tax_Ratio__c;
            }
        }
    }

    private Tax_Ratio__c findTaxRatio(String clientCurrency, Date lookupDate) {
        if (taxRatios != null && !taxRatios.isEmpty()) {
            for (Tax_Ratio__c taxRatio : taxRatios) {
                if (clientCurrency.equalsIgnoreCase(taxRatio.Currency__c) && taxRatio.Start_Date__c <= lookupDate
                        && taxRatio.End_Date__c >= lookupDate) {
                    return taxRatio;
                }
            }
        }

        return null;
    }

    private void loadTaxRatios() {
        if (!taxRatioLoaded) {
            if (PermissionValidationUtil.isAccessibleTaxRatio()) {
                taxRatios = [
                        SELECT Buying_Tax_Ratio__c, Selling_Tax_Ratio__c, Start_Date__c, End_Date__c, Currency__c
                        FROM Tax_Ratio__c
                        WHERE Active__c = true
                ];

                taxRatioLoaded = true;
            }
        }
    }
}