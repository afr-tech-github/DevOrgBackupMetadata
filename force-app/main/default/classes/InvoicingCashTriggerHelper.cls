public with sharing class InvoicingCashTriggerHelper {
    public  static void onAfterInsert(List<ConnectInvoicingAndCash__c> invoiceCashs){
        /*Set<Id> cashBookIdSet = new Set<Id>();
        for(ConnectInvoicingAndCash__c link : invoiceCashs){
            cashBookIdSet.add(link.Cashbook__c);
        }

        Map<Id, CASH_BOOK__c> cashBooksMap = getCashBookById(cashBookIdSet);

        for(ConnectInvoicingAndCash__c link : invoiceCashs){
            if(cashBooksMap.containsKey(link.Cashbook__c)){

                
                // local cash out amount
                if(cashBooksMap.get(link.Cashbook__c).TotalAmount__c == null){
                    cashBooksMap.get(link.Cashbook__c).TotalAmount__c = 0;
                }

                cashBooksMap.get(link.Cashbook__c).TotalAmount__c += link.UnpaidBuyingAmountLocal__c;
                
                // usd cash out amount
                if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c == null){
                    cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c = 0;
                }
                system.debug('######cashBooksMap.get(link.Cashbook__c).TotalAmount__c' + cashBooksMap.get(link.Cashbook__c).TotalAmount__c);

                cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c += link.UnpaidBuyingAmountUSD__c;
                
            
                // local cash in amount
                if(cashBooksMap.get(link.Cashbook__c).TotalAmountCashIn__c == null){
                    cashBooksMap.get(link.Cashbook__c).TotalAmountCashIn__c = 0;
                }

                cashBooksMap.get(link.Cashbook__c).TotalAmountCashIn__c += link.UnreceiveSellingAmountLocal__c;
                

                // usd cash in amount
                if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashInUSD__c == null){
                    cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashInUSD__c = 0;
                }

                cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashInUSD__c += link.UnreceiveSellingAmountUSD__c;
                    
                
            }

        }
        try{
            update cashBooksMap.values();
            }catch(Exception ex){
                System.debug('########Error#####' + ex.getMessage());
            }*/
        

    }


    public static void onBeforeDelete(List<ConnectInvoicingAndCash__c> invoiceCashs){

        //Set<Id> cashBookIdSet = new Set<Id>();
        //for(ConnectInvoicingAndCash__c link : invoiceCashs){
        //  cashBookIdSet.add(link.Cashbook__c);
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = getCashBookById(cashBookIdSet);

        //for(ConnectInvoicingAndCash__c link : invoiceCashs){
        //  if(cashBooksMap.containsKey(link.Cashbook__c)){
        //      // local cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmount__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmount__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmount__c -= link.UnpaidBuyingAmountLocal__c;
                
        //      // usd cash out amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashOutUSD__c -= link.UnpaidBuyingAmountUSD__c;
                
            

        //      // local cash in amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountCashIn__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountCashIn__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountCashIn__c -= link.UnreceiveSellingAmountLocal__c;
                

        //      // usd cash in amount
        //      if(cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashInUSD__c == null){
        //          cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashInUSD__c = 0;
        //      }

        //      cashBooksMap.get(link.Cashbook__c).TotalAmountOfCashInUSD__c -= link.UnreceiveSellingAmountUSD__c;
                    
                
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