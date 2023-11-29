public with sharing class POCashTriggerHelper {
    public static void onAfterInsert(List<ConnectPurchasingInvoiceCash__c> purchasingCashNews){
        //Set<Id> cashBookIdSet = new Set<Id>();
        //for(ConnectPurchasingInvoiceCash__c link : purchasingCashNews){
        //  cashBookIdSet.add(link.Cashbook__c);
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = getCashBookById(cashBookIdSet);

        //for(ConnectPurchasingInvoiceCash__c link : purchasingCashNews ){
        //  if(cashBooksMap.containsKey(link.Cashbook__c)){
        //      // local cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmount__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmount__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmount__c += link.UnpaidBalancePurchasingLocal__c;
                
        //      // usd cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c += link.UnpaidBalancePurchasingUSD__c;
                
        //  }
        //}
        //try{
        //  update cashBooksMap.values();
        //  }catch(Exception ex){
        //      System.debug('########Error#####' + ex.getMessage());
        //  }

    }

    

    public static void onBeforeDelete(List<ConnectPurchasingInvoiceCash__c> purchasingCashOlds){

        //Set<Id> cashBookIdSet = new Set<Id>();
        //for(ConnectPurchasingInvoiceCash__c link : purchasingCashOlds){
        //  cashBookIdSet.add(link.Cashbook__c);
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = getCashBookById(cashBookIdSet);

        //for(ConnectPurchasingInvoiceCash__c link : purchasingCashOlds ){
        //  if(cashBooksMap.containsKey(link.Cashbook__c)){

        //      // local cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmount__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmount__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmount__c -= link.UnpaidBalancePurchasingLocal__c;
                
        //      // usd cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c -= link.UnpaidBalancePurchasingUSD__c;
            
        //  }
        //}
        //try{
        //  update cashBooksMap.values();
        //  }catch(Exception ex){
        //      System.debug('########Error#####' + ex.getMessage());
        //  }
    }

    //private static Map<Id, CASH_BOOK__c> getCashBookById(Set<Id> cashBookIdSet){

        
    //  Map<Id, CASH_BOOK__c> cashBooksMap = new Map<Id, clofor_com_cfs__CASH_BOOK__c>([SELECT Id, 
    //                                                          TotalAmountCashIn__c, 
    //                                                          TotalAmount__c,
    //                                                          TotalAmountOfCashOutUSD__c,
    //                                                          TotalAmountOfCashInUSD__c,
    //                                                          RecordTypeId
    //                                                      FROM CASH_BOOK__c
    //                                                      WHERE Id IN: cashBookIdSet]);
    //  return cashBooksMap;


    //}
}