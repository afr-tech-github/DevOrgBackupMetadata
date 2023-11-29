/**
 * Provide service to synchronize Exchange Rate from pre-defined Exchange Rate to H B/L SHIPMENT, H B/L - SELLING BUYING,
 * and M B/L BUYING
 * 
 * These services are exposed as webservice so they can be invoked from buttons attached to H B/L - SHIPMENT and 
 * M B/L - SHIPMENT details pages.
 * 
 */
global with sharing class ExchangeRateSynchronizationService {
    webservice static void syncHBLShipmentAndSellingBuyings(String shipmentId) {
        if (!PermissionValidationUtil.isEditableHBL()) {
            return;
        }

        shipmentId = StringUtils.escapeSingleQuotes(shipmentId);
        List<MgmtMaster__c> masterExchangeRates = loadMasterExchangeRates();
        CustomObject1__c shipment = loadShipment(shipmentId);

        if (shipment != null) {
            Account customer = findAccount(shipment.Field1__c);

            if (customer != null) {
                List<SObject> toBeUpdated = new List<SObject>();
                if (shipment.ExchangeRate__c == null || shipment.ExchangeRate__c == 0) {
                    applyExchangeRateToShipment(shipment, masterExchangeRates, customer);
                    toBeUpdated.add(shipment);
                }

                Date lookupDate = shipment.PrintDate__c;
                if (lookupDate != null) {
                    List<AnkenMeisai__c> meisais = shipment.Anken__r;
                    Boolean isQuotation = ObjectClassificationUtils.isQuotationHBL(shipment);

                    for (AnkenMeisai__c meisai : meisais) {
                        applyExchangeRateToHBLSellingBuying(masterExchangeRates, meisai, shipment.Custom__c, lookupDate,
                                meisai.Seikyusaki__r, meisai.PaymentTo__r, isQuotation);
                        toBeUpdated.add(meisai);
                    }
                }
                
                FlsService.doUpdate(toBeUpdated);
            }
        }
    }

    webservice static void syncMBLBuyings(String masterShipmentId) {
        if (!PermissionValidationUtil.isEditableMBLBuying()) {
            return;
        }

        masterShipmentId = StringUtils.escapeSingleQuotes(masterShipmentId);
        List<MgmtMaster__c> masterExchangeRates = loadMasterExchangeRates();
        MasterAnken__c mbl = loadMBLBuyingByMasterShipment(masterShipmentId);

        if (mbl != null) {
            Date lookupDate = null;

            if (ObjectClassificationUtils.isImportMBL(mbl.Master_Record_Type__c)) {
                lookupDate = mbl.META__c;
            } else if (ObjectClassificationUtils.isExportMBL(mbl.Master_Record_Type__c)) {
                lookupDate = mbl.METD__c;
            }

            if (lookupDate != null) {
                List<SObject> toBeUpdated = applyExchangeRateToMBLBuyings(mbl.MasterAnken__r, lookupDate, masterExchangeRates);

                if (toBeUpdated.size() > 0) {
                    FlsService.doUpdate(toBeUpdated);
                }
            }
        }
    }

    public static List<MasterAnkenMeisai__c> applyExchangeRateToMBLBuyings(List<MasterAnkenMeisai__c> mblBuyings, Date lookupDate,
            List<MgmtMaster__c> masterExchangeRates) {
        for (MasterAnkenMeisai__c mblBuying : mblBuyings) {
            if (mblBuying.MTariff__r.Supplier__r != null) {
                applyExchangeRateToMBLBuyings(mblBuying, lookupDate, mblBuying.MTariff__r.Supplier__r, masterExchangeRates);
            }
        }

        return mblBuyings;
    }

    public static void applyExchangeRateToMBLBuyings(MasterAnkenMeisai__c mblBuying, Date lookupDate,
            Account provider, List<MgmtMaster__c> masterExchangeRates) {
        if ((mblBuying.KawaseBay__c == null || mblBuying.KawaseBay__c == 0) && (mblBuying.KawaseSel__c == null || mblBuying.KawaseSel__c == 0)) {
            String primaryExRateCurrency = provider.Primary_Exchange_Rate_Currency__c;
            String secondaryExRateCurrency = provider.Secondary_Exchange_Rate_Currency__c;
            String businessRelationship = provider.Business_Relationship__c;

            if (ObjectClassificationUtils.isPartner(provider.Custom_Type__c)) {
                if (!StringUtils.isEmpty(primaryExRateCurrency) || !StringUtils.isEmpty(secondaryExRateCurrency)) {
                    MgmtMaster__c masterExRate = findExchangeRate(masterExchangeRates, lookupDate, primaryExRateCurrency,
                            secondaryExRateCurrency);
                    mblBuying.KawaseBay__c = null;

                    if (masterExRate != null) {
                        Non_Standard_Exchange_Rate__c nonExRate = findNonExchangeRate(mblBuying.SERVICE_PROVIDER_VENDOR_ID__c,
                                masterExRate, false);
                        if (nonExRate != null) {
                            mblBuying.KawaseBay__c = nonExRate.Buying_Ex_Rate_From_Partner__c;
                        } else {
                            mblBuying.KawaseBay__c = masterExRate.Mgmt_Exrate_BuyingfromPartner__c;
                        }
                    }
                }
            }
        }
    }

    public static void applyExchangeRateToShipment(CustomObject1__c shipment, List<MgmtMaster__c> masterExchangeRates, Account customer) {
        MgmtMaster__c masterExchangeRate = null;
        String primaryExRateCurrency = customer.Primary_Exchange_Rate_Currency__c;
        String secondaryExRateCurrency = customer.Secondary_Exchange_Rate_Currency__c;
        Boolean isQuotation = ObjectClassificationUtils.isQuotationHBL(shipment);

        masterExchangeRate = findExchangeRate(masterExchangeRates, shipment.PrintDate__c, primaryExRateCurrency, secondaryExRateCurrency);
        shipment.ExchangeRate__c = null;
        if (masterExchangeRate != null) {
            shipment.Exchange_Currency__c = masterExchangeRate.Mgmt_Exrate_fromto__c.left(3);
            Boolean isCustomer = (isQuotation ? null : Constants.CUSTOMER_RELATIONSHIP.equalsIgnoreCase(customer.Business_Relationship__c));
            Non_Standard_Exchange_Rate__c nonExRate = findNonExchangeRate(shipment.Field1__c, masterExchangeRate, isCustomer);

            if (nonExRate != null) {
                shipment.ExchangeRate__c = nonExRate.Selling_Ex_Rate_To_Customer__c;
            } else {
                if (shipment.Custom__c == null || PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO.equalsIgnoreCase(shipment.Custom__c)) {
                    shipment.ExchangeRate__c = masterExchangeRate.Mgmt_Exrate_FowardingtoDomesticCustomer__c;
                } else if (PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(shipment.Custom__c)) {
                    shipment.ExchangeRate__c = masterExchangeRate.Mgmt_Exrate_CCtoDomesticCustomer__c;
                }
            }
        }
    }

    public static void applyExchangeRateToHBLSellingBuying(List<MgmtMaster__c> masterExchangeRates, AnkenMeisai__c meisai, String clearanceOption, Date lookupDate,
            Account customer, Account partner, Boolean isQuotation) {
        if ((meisai.KawaseBay__c == null || meisai.KawaseBay__c == 0) && (meisai.KawaseSel__c == null || meisai.KawaseSel__c == 0)) {
            meisai.KawaseBay__c = null;
            meisai.KawaseSel__c = null;

            if (customer != null) {
                Decimal sellingExchangeRate = getExchangeRateForCustomer(masterExchangeRates, customer, lookupDate, clearanceOption, isQuotation);

                if (sellingExchangeRate != null) {
                    // meisai.KawaseSel__c = sellingExchangeRate;
                }
            }

            if (partner != null) {
                Decimal buyingExchangeRate = getExchangeRateForPartner(masterExchangeRates, partner, lookupDate, isQuotation);

                if (buyingExchangeRate != null) {
                    // meisai.KawaseBay__c = buyingExchangeRate;
                }
            }
        }
    }

    public static void applyExchangeRateToKickback(List<MgmtMaster__c> masterExchangeRates, Kickback__c kickback,
            Date lookupDate, Account customer) {
        if (kickback.ExchangeRate__c == null || kickback.ExchangeRate__c == 0) {
            kickback.ExchangeRate__c = null;

            if (customer != null) {
                Decimal sellingExchangeRate = getExchangeRateForCustomer(masterExchangeRates, customer, lookupDate, null, false);

                if (sellingExchangeRate != null) {
                    kickback.ExchangeRate__c = sellingExchangeRate;
                }
            }

        }
    }

    private static Decimal getExchangeRateForPartner(List<MgmtMaster__c> masterExchangeRates, Account partner,
            Date lookupDate, Boolean isQuotation) {
        String primaryExRateCurrency = partner.Primary_Exchange_Rate_Currency__c;
        String secondaryExRateCurrency = partner.Secondary_Exchange_Rate_Currency__c;
        MgmtMaster__c exchangeRate = findExchangeRate(masterExchangeRates, lookupDate, primaryExRateCurrency, secondaryExRateCurrency);
        Boolean isCustomer = (isQuotation ? null : Constants.CUSTOMER_RELATIONSHIP.equalsIgnoreCase(partner.Business_Relationship__c));
        Decimal buyingExchangeRate = null;

        if (exchangeRate != null) {
            Non_Standard_Exchange_Rate__c buyExRate = findNonExchangeRate(partner.Id, exchangeRate, isCustomer);
            if (buyExRate != null) {
                buyingExchangeRate = buyExRate.Buying_Ex_Rate_From_Partner__c;
            } else {
                if (ObjectClassificationUtils.isOverseaCustomerOrPartner(partner.Custom_Type__c)) {
                    buyingExchangeRate = exchangeRate.Mgmt_Exrate_BuyingfromPartner__c;
                }
            }
        }

        return buyingExchangeRate;
    }

    private static Decimal getExchangeRateForCustomer(List<MgmtMaster__c> masterExchangeRates, Account customer,
            Date lookupDate, String clearanceServiceOption, Boolean isQuotation) {
        String primaryExRateCurrency = customer.Primary_Exchange_Rate_Currency__c;
        String secondaryExRateCurrency = customer.Secondary_Exchange_Rate_Currency__c;
        MgmtMaster__c exchangeRate = findExchangeRate(masterExchangeRates, lookupDate, primaryExRateCurrency, secondaryExRateCurrency);
        Boolean isCustomer = (isQuotation ? null : Constants.CUSTOMER_RELATIONSHIP.equalsIgnoreCase(customer.Business_Relationship__c));
        Decimal sellingExchangeRate = null;

        if (exchangeRate != null) {
            Non_Standard_Exchange_Rate__c sellExRate = null;

            if (ObjectClassificationUtils.isOverseaCustomerOrPartner(customer.Custom_Type__c)) {
                sellExRate = findNonExchangeRate(customer.Id, exchangeRate, isCustomer);

                if (sellExRate != null) {
                    sellingExchangeRate = sellExRate.Selling_Ex_Rate_To_Partner__c;
                } else {
                    sellingExchangeRate = exchangeRate.Mgmt_Exrate_SellingtoPartner__c;
                }
            } else if (ObjectClassificationUtils.isDomesticCustomerOrPartner(customer.Custom_Type__c)) {
                sellExRate = findNonExchangeRate(customer.Id, exchangeRate, isCustomer);

                if (sellExRate != null) {
                    sellingExchangeRate = sellExRate.Selling_Ex_Rate_To_Customer__c;
                } else {
                    if (clearanceServiceOption == null || PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO.equalsIgnoreCase(clearanceServiceOption)) {
                        sellingExchangeRate = exchangeRate.Mgmt_Exrate_FowardingtoDomesticCustomer__c;
                    } else if (PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(clearanceServiceOption)) {
                        sellingExchangeRate = exchangeRate.Mgmt_Exrate_CCtoDomesticCustomer__c;
                    }
                }
            }
        }

        return sellingExchangeRate;
    }

    public static List<MgmtMaster__c> loadMasterExchangeRates() {
        List<MgmtMaster__c> masterExchangeRates = new List<MgmtMaster__c>();

        if (PermissionValidationUtil.isAccessibleExchangeRate()) {
            masterExchangeRates = [
                    SELECT Id, Mgmt_Exrate_FowardingtoDomesticCustomer__c,
                            Mgmt_Exrate_Start_Date__c, Mgmt_Exrate_End_Date__c, Mgmt_Exrate_SellingtoPartner__c,
                            Mgmt_Exrate_BuyingfromPartner__c, Mgmt_Exrate_CCtoDomesticCustomer__c, Mgmt_Exrate_fromto__c, (
                            SELECT Id, CUSTOMER__c, PARTNER__c, Buying_Ex_Rate_From_Partner__c,
                                    Selling_Ex_Rate_To_Customer__c, Selling_Ex_Rate_To_Partner__c
                            FROM Non_Standard_Exchange_Rate__r
                            ORDER BY Id
                    )
                    FROM MgmtMaster__c
                    WHERE (Mgmt_Exrate_Validity__c = True)
            ];
        }

        return masterExchangeRates;
    }

    private static MgmtMaster__c findExchangeRate(List<MgmtMaster__c> masterExchangeRates, Date lookupDate, String primaryExRateCurrency, String secondaryExRateCurrency) {
        MgmtMaster__c validExRate = null;

        if (masterExchangeRates != null && masterExchangeRates.size() > 0) {
            for (MgmtMaster__c exRate : masterExchangeRates) {
                if (exRate.Mgmt_Exrate_Start_Date__c <= lookupDate && exRate.Mgmt_Exrate_End_Date__c >= lookupDate) {
                    if (exRate.Mgmt_Exrate_fromto__c.equals(primaryExRateCurrency)) {
                        validExRate = exRate;
                        break;
                    } else if (exRate.Mgmt_Exrate_fromto__c.equals(secondaryExRateCurrency)) {
                        validExRate = exRate;
                    }
                }
            }
        }

        return validExRate;
    }

    private static Non_Standard_Exchange_Rate__c findNonExchangeRate(String accountId, MgmtMaster__c masterExRate, Boolean isCustomer) {
        if (masterExRate.Non_Standard_Exchange_Rate__r == null) {
            return null;
        }

        List<Non_Standard_Exchange_Rate__c> nonExRates = masterExRate.Non_Standard_Exchange_Rate__r;
        Non_Standard_Exchange_Rate__c assignedNonExRate = null;

        if (nonExRates != null && !nonExRates.isEmpty()) {
            for (Non_Standard_Exchange_Rate__c nonExRate : nonExRates) {
                if (isCustomer == null) {
                    if ((nonExRate.CUSTOMER__c != null && nonExRate.CUSTOMER__c == accountId)
                            || (nonExRate.PARTNER__c != null && nonExRate.PARTNER__c == accountId)) {
                        assignedNonExRate = nonExRate;
                        break;
                    }
                } else if (isCustomer) {
                    if (nonExRate.CUSTOMER__c != null && nonExRate.CUSTOMER__c == accountId) {
                        assignedNonExRate = nonExRate;
                        break;
                    }
                } else {
                    if (nonExRate.PARTNER__c != null && nonExRate.PARTNER__c == accountId) {
                        assignedNonExRate = nonExRate;
                        break;
                    }
                }
            }
        }

        return assignedNonExRate;
    }

    private static CustomObject1__c loadShipment(String shipmentId) {
        CustomObject1__c shipment = null;

        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort()
                && PermissionValidationUtil.isAccessibleHBL()) {
            shipment = [
                    SELECT Id, ExchangeRate__c, Custom__c, Field1__c,
                            POD__r.Country_Name__c, POL__r.Country_Name__c, RecordTypeId, ETA__c, ETD__c, PrintDate__c, (
                            SELECT Id, Seikyusaki__c, KawaseSel__c, PaymentTo__c, KawaseBay__c,
                                    Seikyusaki__r.Custom_Type__c, Seikyusaki__r.Primary_Exchange_Rate_Currency__c, Seikyusaki__r.Business_Relationship__c,
                                    Seikyusaki__r.Secondary_Exchange_Rate_Currency__c, PaymentTo__r.Custom_Type__c, PaymentTo__r.Business_Relationship__c,
                                    PaymentTo__r.Primary_Exchange_Rate_Currency__c, PaymentTo__r.Secondary_Exchange_Rate_Currency__c
                            FROM Anken__r
                    )
                    FROM CustomObject1__c
                    WHERE Id = :shipmentId
            ];
        }

        return shipment;
    }

    private static Account findAccount(String accountId) {
        if (PermissionValidationUtil.isAccessibleAccount()) {
            return [
                    SELECT Id, Primary_Exchange_Rate_Currency__c, Secondary_Exchange_Rate_Currency__c, Business_Relationship__c, Custom_Type__c
                    FROM Account
                    WHERE Id = :accountId
            ];
        }

        return null;
    }

    private static MasterAnken__c loadMBLBuyingByMasterShipment(String mblShipmentId) {
        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleMBL()
                && PermissionValidationUtil.isAccessibleMBLBuying() && PermissionValidationUtil.isAccessibleServiceMaster()) {
            MasterAnken__c mbl = [
                    SELECT Id, MPartner__c, METD__c, META__c, Master_Record_Type__c, (
                            SELECT Id, KawaseBay__c, KawaseSel__c, SERVICE_PROVIDER_VENDOR_ID__c,
                                    MTariff__r.Supplier__r.Primary_Exchange_Rate_Currency__c,
                                    MTariff__r.Supplier__r.Secondary_Exchange_Rate_Currency__c,
                                    MTariff__r.Supplier__r.Business_Relationship__c,
                                    MTariff__r.Supplier__r.Custom_Type__c
                            FROM MasterAnken__r
                    )
                    FROM MasterAnken__c
                    WHERE Id = :mblShipmentId
            ];
            return mbl;
        }
        return null;
    }
}