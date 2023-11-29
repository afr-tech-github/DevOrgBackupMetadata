public class CashPaymentAutoProcesingHandler  {
    // inint
    public CashPaymentAutoProcesingHandler(){}
    
    // after Update process
    public static  void cashPaymentAuto(Map<Id, clofor_com_cfs__CASH_BOOK__c> cashBookMap){
       Set<Id> setIdBill = new Set<Id>();
       List<clofor_com_cfs__ConnectInvoicingAndCash__c> lstConnectInvoicingAndCash = new List<clofor_com_cfs__ConnectInvoicingAndCash__c>();
       for(clofor_com_cfs__ConnectInvoicingAndCash__c invoi : [SELECT clofor_com_cfs__Invoicing__c
                                                               		 , clofor_com_cfs__Cashbook__r.clofor_com_cfs__StartAutomaticProcessing__c
                                                                FROM clofor_com_cfs__ConnectInvoicingAndCash__c 
                                                                WHERE clofor_com_cfs__Cashbook__c IN :cashBookMap.keySet()]){
                                                                    if(invoi.clofor_com_cfs__Cashbook__r.clofor_com_cfs__StartAutomaticProcessing__c){
                                                                        setIdBill.add(invoi.clofor_com_cfs__Invoicing__c);
                                                                    }
          
            
       }
        List<clofor_com_cfs__AnkenMeisai__c> lstAnkenMeisai = new List<clofor_com_cfs__AnkenMeisai__c>();
        lstAnkenMeisai = [SELECT id, clofor_com_cfs__BuyInTaxAmountJPY__c
                          , clofor_com_cfs__Siharaigaku__c
                          FROM clofor_com_cfs__AnkenMeisai__c
                          WHERE Id In :setIdBill];
        for(clofor_com_cfs__AnkenMeisai__c am : lstAnkenMeisai){
            am.clofor_com_cfs__Siharaigaku__c = am.clofor_com_cfs__BuyInTaxAmountJPY__c;
        }
        FlsService.doUpdate(lstAnkenMeisai);
        //  System.debug(lstAnkenMeisai);
    }
}