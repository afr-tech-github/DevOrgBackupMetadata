public with sharing class AddMultipleBillController {
    @AuraEnabled
    public static void saveBillList(List<clofor_com_cfs__AnkenMeisai__c> billList,Id shipmentId) 
	{   
        clofor_com_cfs__Site_Custom_Settings__c custom = [SELECT clofor_com_cfs__FCY_Currency__c,clofor_com_cfs__Local_Currency__c FROM clofor_com_cfs__Site_Custom_Settings__c ];
        for(clofor_com_cfs__AnkenMeisai__c bill: billList){
            bill.clofor_com_cfs__Anken__c = shipmentId;
            if(bill.clofor_com_cfs__curr__c == custom.clofor_com_cfs__FCY_Currency__c){
                bill.clofor_com_cfs__SellTankaUSD__c = bill.clofor_com_cfs__SellTankaJPY__c;
                bill.clofor_com_cfs__SellTankaJPY__c = null;
                // bill.clofor_com_cfs__AmountSellingUSDAdjustment__c = bill.clofor_com_cfs__AmountSellingLocalAdjustment__c;
                // bill.clofor_com_cfs__AmountSellingLocalAdjustment__c = null;
            }else if(bill.clofor_com_cfs__curr__c == custom.clofor_com_cfs__Local_Currency__c){
                bill.clofor_com_cfs__SellTankaJPY__c = bill.clofor_com_cfs__SellTankaJPY__c;
                // bill.clofor_com_cfs__AmountSellingLocalAdjustment__c = bill.clofor_com_cfs__AmountSellingLocalAdjustment__c;
            }else {
                bill.clofor_com_cfs__UnitPriceofSelling3rdCurrency__c = bill.clofor_com_cfs__SellTankaJPY__c;
                bill.clofor_com_cfs__SellTankaJPY__c = null;
                // bill.clofor_com_cfs__AmountSellingInclTax3rdCurrencyAdjust__c = bill.clofor_com_cfs__AmountSellingLocalAdjustment__c;
                // bill.clofor_com_cfs__AmountSellingLocalAdjustment__c = null;
            }

            if(bill.clofor_com_cfs__CurrencyBuying__c == custom.clofor_com_cfs__FCY_Currency__c){
                bill.clofor_com_cfs__BuyTankaUSD__c = bill.clofor_com_cfs__BuyTankaJPY__c;
                bill.clofor_com_cfs__BuyTankaJPY__c = null;
                // bill.clofor_com_cfs__AmountBuyingUSDAdjustment__c = bill.clofor_com_cfs__AmountBuyingLocalAdjustment__c;
                // bill.clofor_com_cfs__AmountBuyingLocalAdjustment__c = null;
            }else if(bill.clofor_com_cfs__CurrencyBuying__c == custom.clofor_com_cfs__Local_Currency__c){
                bill.clofor_com_cfs__BuyTankaJPY__c = bill.clofor_com_cfs__BuyTankaJPY__c;
                // bill.clofor_com_cfs__AmountBuyingLocalAdjustment__c = bill.clofor_com_cfs__AmountBuyingLocalAdjustment__c;
            }else {
                bill.clofor_com_cfs__UnitPriceofSelling3rdCurrency__c = bill.clofor_com_cfs__SellTankaJPY__c;
                bill.clofor_com_cfs__SellTankaJPY__c = null;
                // bill.clofor_com_cfs__AmountBuyingInclTax3rdCurrencyAdjust__c = bill.clofor_com_cfs__AmountBuyingLocalAdjustment__c;
                // bill.clofor_com_cfs__AmountBuyingLocalAdjustment__c = null;

            }        
        }
        
        // System.debug('accList1:' + accList);     
        Insert billList;
        // System.debug('accList2:' + accList);
    }
    
}