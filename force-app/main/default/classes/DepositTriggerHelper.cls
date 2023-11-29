public with sharing class DepositTriggerHelper {
    public static void onAfterUpdate(Map<Id, Deposit__c> depositsNewMap, Map<Id, Deposit__c> depositsOldMap){

        //List<DepositCash__c> depositCash = [SELECT Id, Cash__c, Deposit__c FROM DepositCash__c WHERE Deposit__c IN: depositsNewMap.keySet()];

        //Set<Id> cashIdSet = new Set<Id>();
        //Map<Id, List<Id>> idCashbyDepositMap = new Map<Id, List<Id>>();

        //for(DepositCash__c link : depositCash){
        //  cashIdSet.add(link.Cash__c);
        //  if(idCashbyDepositMap.containsKey(link.Deposit__c)){
        //      idCashbyDepositMap.get(link.Deposit__c).add(link.Cash__c);
        //  }else{
        //      idCashbyDepositMap.put(link.Deposit__c, new List<Id>{link.Cash__c});
        //  }
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = new Map<Id, clofor_com_cfs__CASH_BOOK__c>([SELECT Id, 
        //                                                      TotalAmountCashIn__c, 
        //                                                      TotalAmount__c,
        //                                                      TotalAmountOfCashOutUSD__c,
        //                                                      TotalAmountOfCashInUSD__c,
        //                                                      RecordTypeId
        //                                                  FROM CASH_BOOK__c
        //                                                  WHERE Id IN: cashIdSet]);
        
        //for(Deposit__c deposit : depositsNewMap.values()){
        //  if(!idCashbyDepositMap.containsKey(deposit.Id)){
        //      continue;
        //  }

        //  for(Id cashId : idCashbyDepositMap.get(deposit.Id)){
        //      if(deposit.AmountPaidToVendorLocal__c != depositsOldMap.get(deposit.Id).AmountPaidToVendorLocal__c){
                    
        //          if(cashBooksMap.get(cashId).TotalAmount__c == null){
        //              cashBooksMap.get(cashId).TotalAmount__c = 0;
        //          }
        //          cashBooksMap.get(cashId).TotalAmount__c -= depositsOldMap.get(deposit.Id).AmountPaidToVendorLocal__c != null? depositsOldMap.get(deposit.Id).AmountPaidToVendorLocal__c : 0;
        //          cashBooksMap.get(cashId).TotalAmount__c += deposit.AmountPaidToVendorLocal__c != null? deposit.AmountPaidToVendorLocal__c :0;
        //      }
        //      if(deposit.AmountPaidToVendor__c != depositsOldMap.get(deposit.Id).AmountPaidToVendor__c){
                    
        //          if(cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c == null){
        //              cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c = 0;
        //          }
        //          cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c -= depositsOldMap.get(deposit.Id).AmountPaidToVendor__c != null? depositsOldMap.get(deposit.Id).AmountPaidToVendor__c :0;
        //          cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c += deposit.AmountPaidToVendor__c != null? deposit.AmountPaidToVendor__c :0;
        //      }
        //      if(deposit.AmountReceivedFromCustomerLocal__c != depositsOldMap.get(deposit.Id).AmountReceivedFromCustomerLocal__c){
                    
        //          if(cashBooksMap.get(cashId).TotalAmountCashIn__c == null){
        //              cashBooksMap.get(cashId).TotalAmountCashIn__c = 0;
        //          }
        //          cashBooksMap.get(cashId).TotalAmountCashIn__c -= depositsOldMap.get(deposit.Id).AmountReceivedFromCustomerLocal__c != null? depositsOldMap.get(deposit.Id).AmountReceivedFromCustomerLocal__c :0;
        //          cashBooksMap.get(cashId).TotalAmountCashIn__c += deposit.AmountReceivedFromCustomerLocal__c != null? deposit.AmountReceivedFromCustomerLocal__c :0;
        //      }
        //      if(deposit.AmountReceivedFromCustomerUSD__c != depositsOldMap.get(deposit.Id).AmountReceivedFromCustomerUSD__c){
                    
        //          if(cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c == null){
        //              cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c = 0;
        //          }
        //          cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c -= depositsOldMap.get(deposit.Id).AmountReceivedFromCustomerUSD__c != null? depositsOldMap.get(deposit.Id).AmountReceivedFromCustomerUSD__c :0;
        //          cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c += deposit.AmountReceivedFromCustomerUSD__c != null? deposit.AmountReceivedFromCustomerUSD__c :0;
        //      }

        //  }
        //}
        //try{
        //  system.debug('#####cashBooksMap' + cashBooksMap.values());
        //  update cashBooksMap.values();
        //  }catch(Exception ex){
        //      System.debug('########Error#####' + ex.getMessage());
        //}
    }

    public static void onBeforeDelete(Map<Id, Deposit__c> depositsOldMap){

        //List<DepositCash__c> depositCash = [SELECT Id, Cash__c, Deposit__c FROM DepositCash__c WHERE Deposit__c IN: depositsOldMap.keySet()];

        //Set<Id> cashIdSet = new Set<Id>();
        //Map<Id, List<Id>> idCashbyDepositMap = new Map<Id, List<Id>>();

        //for(DepositCash__c link : depositCash){
        //  cashIdSet.add(link.Cash__c);
        //  if(idCashbyDepositMap.containsKey(link.Deposit__c)){
        //      idCashbyDepositMap.get(link.Deposit__c).add(link.Cash__c);
        //  }else{
        //      idCashbyDepositMap.put(link.Deposit__c, new List<Id>{link.Cash__c});
        //  }
        //}

        //Map<Id, CASH_BOOK__c> cashBooksMap = new Map<Id, clofor_com_cfs__CASH_BOOK__c>([SELECT Id, 
        //                                                      TotalAmountCashIn__c, 
        //                                                      TotalAmount__c,
        //                                                      TotalAmountOfCashOutUSD__c,
        //                                                      TotalAmountOfCashInUSD__c,
        //                                                      RecordTypeId
        //                                                  FROM CASH_BOOK__c
        //                                                  WHERE Id IN: cashIdSet]);
        
        //for(Deposit__c deposit : depositsOldMap.values()){
        //  if(!idCashbyDepositMap.containsKey(deposit.Id)){
        //      continue;
        //  }

        //  for(Id cashId : idCashbyDepositMap.get(deposit.Id)){
                
        //      if(cashBooksMap.get(cashId).TotalAmount__c == null){
        //          cashBooksMap.get(cashId).TotalAmount__c = 0;
        //      }
        //      cashBooksMap.get(cashId).TotalAmount__c -= deposit.AmountPaidToVendorLocal__c != null? deposit.AmountPaidToVendorLocal__c : 0;
        //      if(cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c == null){
        //          cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c = 0;
        //      }
        //      cashBooksMap.get(cashId).TotalAmountOfCashOutUSD__c -= deposit.AmountPaidToVendor__c != null? deposit.AmountPaidToVendor__c : 0;
                
        //      if(cashBooksMap.get(cashId).TotalAmountCashIn__c == null){
        //          cashBooksMap.get(cashId).TotalAmountCashIn__c = 0;
        //      }
        //      cashBooksMap.get(cashId).TotalAmountCashIn__c -= deposit.AmountReceivedFromCustomerLocal__c != null? deposit.AmountReceivedFromCustomerLocal__c : 0;
                
        //      if(cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c == null){
        //          cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c = 0;
        //      }
        //      cashBooksMap.get(cashId).TotalAmountOfCashInUSD__c -= deposit.AmountReceivedFromCustomerUSD__c!= null? deposit.AmountReceivedFromCustomerUSD__c : 0;
        //  }
        //}
        //try{
        //  system.debug('#####cashBooksMap' + cashBooksMap.values());
        //  update cashBooksMap.values();
        //  }catch(Exception ex){
        //      System.debug('########Error#####' + ex.getMessage());
        //}
    }

}