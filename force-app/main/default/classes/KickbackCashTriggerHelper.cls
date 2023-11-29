public with sharing class KickbackCashTriggerHelper {
    
    public static void onAfterInsert(List<ConnectKickabckCash__c> kickbackCashNews){
        //Set<Id> cashBookIdSet = new Set<Id>();
        //for(ConnectKickabckCash__c link : kickbackCashNews){
        //  cashBookIdSet.add(link.Cashbook__c);
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = getCashBookById(cashBookIdSet);

        //for(ConnectKickabckCash__c link : kickbackCashNews ){
        //  if(cashBooksMap.containsKey(link.Cashbook__c)){

        //      // local cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmount__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmount__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmount__c += link.UnpaidBalanceKickbackLocal__c;
                
        //      // usd cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c += link.UnpaidBalanceKickbackUSD__c;
                
        //  }
        //}
        //try{
        //  update cashBooksMap.values();
        //  }catch(Exception ex){
        //      System.debug('########Error#####' + ex.getMessage());
        //  }

    }

    

    public static void onBeforeDelete(List<ConnectKickabckCash__c> kickbackCashOlds){

        //Set<Id> cashBookIdSet = new Set<Id>();
        //for(ConnectKickabckCash__c link : kickbackCashOlds){
        //  cashBookIdSet.add(link.Cashbook__c);
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = getCashBookById(cashBookIdSet);

        //for(ConnectKickabckCash__c link : kickbackCashOlds ){
        //  if(cashBooksMap.containsKey(link.Cashbook__c)){

        //      // local cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmount__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmount__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmount__c -= link.UnpaidBalanceKickbackLocal__c;
                
        //      // usd cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c -= link.UnpaidBalanceKickbackUSD__c;
            
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