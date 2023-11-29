public class MassUpdateBillingController {
    @AuraEnabled
    public static String getRecordTypeId(){
        //TODO: Need to clarify which spefic developer name record here
        return [SELECT Id,SobjectType FROM RecordType WHERE SobjectType = 'clofor_com_cfs__AnkenMeisai__c' AND DeveloperName = 'Selling_Buyging_Standard'].Id;
    }
    
	@AuraEnabled
    public static String getDescribeSobjectResult(){
		DescribeSobjectResult objResult = Schema.SObjectType.clofor_com_cfs__AnkenMeisai__c;
        return objResult.isCreateable() + '_' + objResult.isUpdateable() + '_' + objResult.isAccessible() + '_' + objResult.isDeletable();
    }
	@AuraEnabled
    public static List<clofor_com_cfs__AnkenMeisai__c> getAllBillings(String shipmentId, Boolean isSelling){
        // if(isSelling){
            // return [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            // WHERE clofor_com_cfs__Anken__c = :shipmentId 
            // AND ((clofor_com_cfs__SellTankaUSD__c != 0 AND clofor_com_cfs__SellTankaUSD__c != null)
            // OR (clofor_com_cfs__SellTankaJPY__c != 0 AND clofor_com_cfs__SellTankaJPY__c != null))
            // ORDER BY Name];
        // }
        // return [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            // WHERE clofor_com_cfs__Anken__c = :shipmentId 
            // AND ((clofor_com_cfs__BuyTankaUSD__c != 0 AND clofor_com_cfs__BuyTankaUSD__c != null)
            // OR (clofor_com_cfs__BuyTankaJPY__c != 0 AND clofor_com_cfs__BuyTankaJPY__c != null))
            // ORDER BY Name];
            // if(isSelling){
                // return [Select id FROM clofor_com_cfs__AnkenMeisai__c 
                // WHERE clofor_com_cfs__Anken__c = :shipmentId 
                // ORDER BY clofor_com_cfs__SellTankaJPY__c DESC, clofor_com_cfs__SellTankaUSD__c DESC, Name];
            // }
            // return [Select id FROM clofor_com_cfs__AnkenMeisai__c 
                // WHERE clofor_com_cfs__Anken__c = :shipmentId 
                // ORDER BY clofor_com_cfs__BuyTankaJPY__c DESC, clofor_com_cfs__BuyTankaUSD__c DESC, Name];
        
        List<clofor_com_cfs__AnkenMeisai__c> getBilling = new List<clofor_com_cfs__AnkenMeisai__c>();
        if(isSelling){
            getBilling = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__SellTankaUSD__c != 0 AND clofor_com_cfs__SellTankaUSD__c != null)
            OR (clofor_com_cfs__SellTankaJPY__c != 0 AND clofor_com_cfs__SellTankaJPY__c != null))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        } else {
            getBilling = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
                WHERE clofor_com_cfs__Anken__c = :shipmentId 
                AND ((clofor_com_cfs__BuyTankaUSD__c != 0 AND clofor_com_cfs__BuyTankaUSD__c != null)
                OR (clofor_com_cfs__BuyTankaJPY__c != 0 AND clofor_com_cfs__BuyTankaJPY__c != null))
                ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        }
        List<clofor_com_cfs__AnkenMeisai__c> getBilling1 = new List<clofor_com_cfs__AnkenMeisai__c>();
        if(isSelling){
            getBilling1 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__SellTankaUSD__c = 0)
            AND (clofor_com_cfs__SellTankaJPY__c = 0))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        } else{
            getBilling1 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__BuyTankaUSD__c = 0)
            AND (clofor_com_cfs__BuyTankaJPY__c = 0))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        }
        List<clofor_com_cfs__AnkenMeisai__c> getBilling2 = new List<clofor_com_cfs__AnkenMeisai__c>();
        if(isSelling){
            getBilling2 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__SellTankaUSD__c = 0)
            AND (clofor_com_cfs__SellTankaJPY__c = null))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        } else{
            getBilling2 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__BuyTankaUSD__c = 0)
            AND (clofor_com_cfs__BuyTankaJPY__c = null))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        }
        List<clofor_com_cfs__AnkenMeisai__c> getBilling3 = new List<clofor_com_cfs__AnkenMeisai__c>();
        if(isSelling){
            getBilling3 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__SellTankaUSD__c = null)
            AND (clofor_com_cfs__SellTankaJPY__c = 0))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        } else{
            getBilling3 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__BuyTankaUSD__c = null)
            AND (clofor_com_cfs__BuyTankaJPY__c = 0))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        }
        List<clofor_com_cfs__AnkenMeisai__c> getBilling4 = new List<clofor_com_cfs__AnkenMeisai__c>();
        if(isSelling){
            getBilling4 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__SellTankaUSD__c = null)
            AND (clofor_com_cfs__SellTankaJPY__c = null))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        } else{
            getBilling4 = Security.stripInaccessible(AccessType.READABLE, [Select id FROM clofor_com_cfs__AnkenMeisai__c 
            WHERE clofor_com_cfs__Anken__c = :shipmentId 
            AND ((clofor_com_cfs__BuyTankaUSD__c = null)
            AND (clofor_com_cfs__BuyTankaJPY__c = null))
            ORDER BY clofor_com_cfs__SeikyuBangou__c]).getRecords();
        }
        System.debug('123:' +shipmentId );
        getBilling.addAll(getBilling1);
        getBilling.addAll(getBilling2);
        getBilling.addAll(getBilling3);
        getBilling.addAll(getBilling4);
        return getBilling;
    }

	@AuraEnabled
    public static Boolean deleteBilling(String id){
        try {
            List<clofor_com_cfs__AnkenMeisai__c> billings = [Select Id FROM clofor_com_cfs__AnkenMeisai__c WHERE Id = :id];
            if(billings.size() == 0)
                return false;
            delete billings;
            return true;
        } catch (DmlException e) {
            throw e;
        }
    }
//     @AuraEnabled
//     public static Boolean cloneQuoteline2(String id){
//         try {
//             List<clofor_com_cfs__AnkenMeisai__c> quotelines = [Select Id,
//             clofor_com_cfs__SeikyuBangou__c,
//                 clofor_com_cfs__Tariff__c,
//                 clofor_com_cfs__InsatuyouSyohinEng__c,
//                 clofor_com_cfs__Seikyusaki__c,
//                 clofor_com_cfs__PaymentTo__c,
//                 clofor_com_cfs__Suryo__c,
//                 clofor_com_cfs__ChargeUnitInPrint__c,
//                 clofor_com_cfs__ChargeUnit__c,
//                 clofor_com_cfs__ContainerSize__c,
//                 clofor_com_cfs__PrintFlag__c,

//                 clofor_com_cfs__curr__c,
//                 clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c,
//                 clofor_com_cfs__SellTankaJPY__c,
//                 clofor_com_cfs__SellTankaUSD__c,
//                 clofor_com_cfs__UnitPriceofBuying3rdCurrency__c,
//                 clofor_com_cfs__TaxInitial__c,
//                 clofor_com_cfs__ExchangeRateID__c,
//                 clofor_com_cfs__KawaseSel__c,
//                 clofor_com_cfs__CurrencyConversionSelling__c,
//                 clofor_com_cfs__VATrateselling__c,
                                
//                 clofor_com_cfs__CurrencyBuying__c,
//                 clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c,
//                 clofor_com_cfs__BuyTankaJPY__c,
//                 clofor_com_cfs__BuyTankaUSD__c,
               
//                 clofor_com_cfs__BuyTaxInitial__c,
//                 clofor_com_cfs__KawaseBay__c,
//                 clofor_com_cfs__CurrencyConversionBuying__c,
//                 clofor_com_cfs__VATratebuying__c
//             FROM clofor_com_cfs__AnkenMeisai__c WHERE Id = :id];
//     // String quote = '';
//     List<clofor_com_cfs__AnkenMeisai__c> lstIn = new List<clofor_com_cfs__AnkenMeisai__c>();
//             if(quotelines.size() == 0)
//                 return false;
                
                
//                  for(clofor_com_cfs__AnkenMeisai__c ql : quotelines){
//                     clofor_com_cfs__AnkenMeisai__c ql11 = ql.clone(false);
//                     System.debug('ql11 :'+ql11);
//                 //    quote = ql.QuoteID__c;
//                 lstIn.add(ql11);
//                  }
//                  insert lstIn;
//                  System.debug('lstIn :'+lstIn);
                 
// //                  List<QuoteLine__c> quotelines3 = [Select Id,QuoteID__c FROM clofor_com_cfs__QuoteLine__c WHERE QuoteID__c = :quote];
// // System.debug('quotelines3 :'+quotelines3.size());
//             // QuoteLine__c ql11 = new QuoteLine__c(QuoteID__c = quote);
//             // insert ql11;
//             return true;
            
//         } catch (DmlException e) {
//             throw e;
//         }
//     }

	@AuraEnabled
    public static String updateBillings(String jsonRecords, Boolean isSelling, Boolean isBuying, Boolean isVATRateSelling, Boolean isExchangeRateIDDebitCredit, Boolean isCurrencyConversionForSelling, Boolean isExchangeRateSellingDebit, Boolean isVATRateBuying, Boolean isExchangeRateBuyingCredit, Boolean isCurrencyConversionForBuying, Boolean isAdvancePaymentonbehalfofOurCompany ){
		List<clofor_com_cfs__AnkenMeisai__c> records = (List<clofor_com_cfs__AnkenMeisai__c>) JSON.deserialize(jsonRecords, List<clofor_com_cfs__AnkenMeisai__c>.class);
        System.debug('debug1 :'+records);
        Set<Id> ids = (new Map<Id,SObject>(records)).keySet();
        System.debug('idddd :'+ids);
        List<clofor_com_cfs__AnkenMeisai__c>  billings = [SELECT Id,Name,clofor_com_cfs__SeikyuBangou__c,clofor_com_cfs__Tariff__c,clofor_com_cfs__Seikyusaki__c,clofor_com_cfs__PaymentTo__c,
        clofor_com_cfs__Suryo__c,clofor_com_cfs__ChargeUnitInPrint__c,clofor_com_cfs__ChargeUnit__c,clofor_com_cfs__ContainerSize__c,clofor_com_cfs__PrintFlag__c,clofor_com_cfs__curr__c,clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c,
        clofor_com_cfs__SellTankaJPY__c,clofor_com_cfs__SellTankaUSD__c,clofor_com_cfs__UnitPriceofSelling3rdCurrency__c,clofor_com_cfs__TaxInitial__c,clofor_com_cfs__VATrateselling__c,
        clofor_com_cfs__ExchangeRateID__c,clofor_com_cfs__KawaseSel__c,clofor_com_cfs__FxrateSelling3rdCurrencyFCY__c,clofor_com_cfs__FxrateSelling3rdCurrencyLocal__c,clofor_com_cfs__CurrencyConversionSelling__c,clofor_com_cfs__CurrencyBuying__c,
        clofor_com_cfs__InsatuyouSyohinEng__c,clofor_com_cfs__BuyTankaJPY__c,clofor_com_cfs__BuyTankaUSD__c,clofor_com_cfs__UnitPriceofBuying3rdCurrency__c,clofor_com_cfs__BuyTaxInitial__c,clofor_com_cfs__VATratebuying__c,clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c,
        clofor_com_cfs__AmountBuyingIncTaxLocalInput__c,clofor_com_cfs__AmountBuyingIncTaxFCYInput__c,clofor_com_cfs__KawaseBay__c,clofor_com_cfs__FxrateBuying3rdCurrencyFCY__c,clofor_com_cfs__FxrateBuying3rdCurrencyLocal__c,clofor_com_cfs__CurrencyConversionBuying__c
        FROM clofor_com_cfs__AnkenMeisai__c 
        WHERE Id in :ids
        ORDER BY clofor_com_cfs__SeikyuBangou__c];
        System.debug('debug2 :'+billings);

        
        List<clofor_com_cfs__AnkenMeisai__c> itemsIdsToRemove = new List<clofor_com_cfs__AnkenMeisai__c>();
        
        for(Integer i  = 0; i < records.size(); i++){
            clofor_com_cfs__AnkenMeisai__c r = records[i];
            
    
                if(billings[i].Id == r.Id){
                    if(billings[i].clofor_com_cfs__SeikyuBangou__c != r.clofor_com_cfs__SeikyuBangou__c ||
                    billings[i].clofor_com_cfs__Tariff__c != r.clofor_com_cfs__Tariff__c ||
                    billings[i].clofor_com_cfs__InsatuyouSyohinEng__c != r.clofor_com_cfs__InsatuyouSyohinEng__c ||
                    billings[i].clofor_com_cfs__Seikyusaki__c != r.clofor_com_cfs__Seikyusaki__c ||
                    billings[i].clofor_com_cfs__PaymentTo__c != r.clofor_com_cfs__PaymentTo__c ||
                    billings[i].clofor_com_cfs__Suryo__c != r.clofor_com_cfs__Suryo__c ||
                    billings[i].clofor_com_cfs__ChargeUnitInPrint__c != r.clofor_com_cfs__ChargeUnitInPrint__c ||
                    billings[i].clofor_com_cfs__ChargeUnit__c != r.clofor_com_cfs__ChargeUnit__c ||
                    billings[i].clofor_com_cfs__ContainerSize__c != r.clofor_com_cfs__ContainerSize__c ||
                    billings[i].clofor_com_cfs__PrintFlag__c != r.clofor_com_cfs__PrintFlag__c ||
                    billings[i].clofor_com_cfs__curr__c != r.clofor_com_cfs__curr__c ||
                    billings[i].clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c != r.clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c ||
                    billings[i].clofor_com_cfs__SellTankaJPY__c != r.clofor_com_cfs__SellTankaJPY__c ||
                    billings[i].clofor_com_cfs__SellTankaUSD__c != r.clofor_com_cfs__SellTankaUSD__c ||
                    billings[i].clofor_com_cfs__UnitPriceofBuying3rdCurrency__c != r.clofor_com_cfs__UnitPriceofBuying3rdCurrency__c ||
                    billings[i].clofor_com_cfs__TaxInitial__c != r.clofor_com_cfs__TaxInitial__c ||
                    billings[i].clofor_com_cfs__ExchangeRateID__c != r.clofor_com_cfs__ExchangeRateID__c ||
                    billings[i].clofor_com_cfs__KawaseSel__c != r.clofor_com_cfs__KawaseSel__c ||
                    billings[i].clofor_com_cfs__CurrencyConversionSelling__c != r.clofor_com_cfs__CurrencyConversionSelling__c ||
                    billings[i].clofor_com_cfs__VATrateselling__c != r.clofor_com_cfs__VATrateselling__c ||
                    billings[i].clofor_com_cfs__CurrencyBuying__c != r.clofor_com_cfs__CurrencyBuying__c ||
                        billings[i].clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c != r.clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c ||
                        billings[i].clofor_com_cfs__BuyTankaJPY__c != r.clofor_com_cfs__BuyTankaJPY__c ||
                        billings[i].clofor_com_cfs__BuyTankaUSD__c != r.clofor_com_cfs__BuyTankaUSD__c ||
                        billings[i].clofor_com_cfs__UnitPriceofBuying3rdCurrency__c != r.clofor_com_cfs__UnitPriceofBuying3rdCurrency__c ||
                        billings[i].clofor_com_cfs__BuyTaxInitial__c != r.clofor_com_cfs__BuyTaxInitial__c ||
                        billings[i].clofor_com_cfs__KawaseBay__c != r.clofor_com_cfs__KawaseBay__c ||
                        billings[i].clofor_com_cfs__CurrencyConversionBuying__c != r.clofor_com_cfs__CurrencyConversionBuying__c ||
                        billings[i].clofor_com_cfs__VATratebuying__c != r.clofor_com_cfs__VATratebuying__c
                    ){
                        itemsIdsToRemove.add(r);
                    }
                    
                
            }
           
           
        }
        
        System.debug('debug3  :'+itemsIdsToRemove.size());
        // for(Integer i  = 0; i < records.size(); i++){
        //     clofor_com_cfs__AnkenMeisai__c r = records[i];
        //     for(Integer j  = 0; j < billings.size(); j++){
        //         if(billings[j].Id == r.Id){
        // 			System.debug('r.Id: ' + r.Id);
        //             billings[j].clofor_com_cfs__SeikyuBangou__c = r.clofor_com_cfs__SeikyuBangou__c;
        //             billings[j].clofor_com_cfs__Tariff__c = r.clofor_com_cfs__Tariff__c;
        //             billings[j].clofor_com_cfs__InsatuyouSyohinEng__c = r.clofor_com_cfs__InsatuyouSyohinEng__c;
        //             billings[j].clofor_com_cfs__Seikyusaki__c = r.clofor_com_cfs__Seikyusaki__c;
        //             billings[j].clofor_com_cfs__PaymentTo__c = r.clofor_com_cfs__PaymentTo__c;
        //             billings[j].clofor_com_cfs__Suryo__c = r.clofor_com_cfs__Suryo__c;
        //             billings[j].clofor_com_cfs__ChargeUnitInPrint__c = r.clofor_com_cfs__ChargeUnitInPrint__c;
        //             billings[j].clofor_com_cfs__ChargeUnit__c = r.clofor_com_cfs__ChargeUnit__c;
        //             billings[j].clofor_com_cfs__ContainerSize__c = r.clofor_com_cfs__ContainerSize__c;
        //             billings[j].clofor_com_cfs__PrintFlag__c = r.clofor_com_cfs__PrintFlag__c;
        //             if(isSelling){
        //                 billings[j].clofor_com_cfs__curr__c = r.clofor_com_cfs__curr__c;
        //                 billings[j].clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c = r.clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c;
        //                 billings[j].clofor_com_cfs__SellTankaJPY__c = r.clofor_com_cfs__SellTankaJPY__c;
        //                 billings[j].clofor_com_cfs__SellTankaUSD__c = r.clofor_com_cfs__SellTankaUSD__c;
        //                 billings[j].clofor_com_cfs__UnitPriceofBuying3rdCurrency__c = r.clofor_com_cfs__UnitPriceofBuying3rdCurrency__c;
        //                 billings[j].clofor_com_cfs__TaxInitial__c = r.clofor_com_cfs__TaxInitial__c;
        //                 billings[j].clofor_com_cfs__ExchangeRateID__c = r.clofor_com_cfs__ExchangeRateID__c;
        //                 billings[j].clofor_com_cfs__KawaseSel__c = r.clofor_com_cfs__KawaseSel__c;
        //                 billings[j].clofor_com_cfs__CurrencyConversionSelling__c = r.clofor_com_cfs__CurrencyConversionSelling__c;
        //                 billings[j].clofor_com_cfs__VATrateselling__c = r.clofor_com_cfs__VATrateselling__c;
        //             } else {
        //                 billings[j].clofor_com_cfs__CurrencyBuying__c = r.clofor_com_cfs__CurrencyBuying__c;
        //                 billings[j].clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c = r.clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c;
        //                 billings[j].clofor_com_cfs__BuyTankaJPY__c = r.clofor_com_cfs__BuyTankaJPY__c;
        //                 billings[j].clofor_com_cfs__BuyTankaUSD__c = r.clofor_com_cfs__BuyTankaUSD__c;
        //                 billings[j].clofor_com_cfs__UnitPriceofBuying3rdCurrency__c = r.clofor_com_cfs__UnitPriceofBuying3rdCurrency__c;
        //                 billings[j].clofor_com_cfs__BuyTaxInitial__c = r.clofor_com_cfs__BuyTaxInitial__c;
        //                 billings[j].clofor_com_cfs__KawaseBay__c = r.clofor_com_cfs__KawaseBay__c;
        //                 billings[j].clofor_com_cfs__CurrencyConversionBuying__c = r.clofor_com_cfs__CurrencyConversionBuying__c;
        //                 billings[j].clofor_com_cfs__VATratebuying__c = r.clofor_com_cfs__VATratebuying__c;
        //             }

        //             // if(isVATRateSelling && isSelling){
        //             //     billings[j].clofor_com_cfs__VATrateselling__c = r.clofor_com_cfs__VATrateselling__c;
        //             // }
        //             // else if(isExchangeRateIDDebitCredit && isSelling){
        //             //     billings[j].clofor_com_cfs__ExchangeRateID__c = r.clofor_com_cfs__ExchangeRateID__c;
        //             // }
        //             // else if(isCurrencyConversionForSelling && isSelling){
        //             //     billings[j].clofor_com_cfs__CurrencyConversionSelling__c = r.clofor_com_cfs__CurrencyConversionSelling__c;
        //             // }
        //             // else if(isExchangeRateSellingDebit && isSelling){
        //             //     billings[j].clofor_com_cfs__KawaseSel__c = r.clofor_com_cfs__KawaseSel__c;
        //             // }
        //             // else if(isVATRateBuying && isBuying){
        //             //     billings[j].clofor_com_cfs__VATratebuying__c = r.clofor_com_cfs__VATratebuying__c;
        //             // }
        //             // else if(isExchangeRateBuyingCredit && isBuying){
        //             //     billings[j].clofor_com_cfs__KawaseBay__c = r.clofor_com_cfs__KawaseBay__c;
        //             // }
        //             // else if(isCurrencyConversionForBuying && isBuying){
        //             //     billings[j].clofor_com_cfs__CurrencyConversionBuying__c = r.clofor_com_cfs__CurrencyConversionBuying__c;
        //             // }
        //             // else if(isAdvancePaymentonbehalfofOurCompany && isBuying){
        //             //     billings[j].clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c = r.clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c;
        //             // }
        //             // System.debug('r.clofor_com_cfs__Unit__c ' + r.Id + r.clofor_com_cfs__Unit__c);
        //             break;
        //         }
        //     }
        // }
        try {
        	update itemsIdsToRemove;
        	return JSON.serialize(itemsIdsToRemove);
        }
        catch (Exception e) {
   			// System.debug('The following exception has occurred: ' + e.getMessage());
            // return 'The following exception has occurred: ' + e.getMessage();
            throw new DmlException(e.getMessage());
        }
    }
}