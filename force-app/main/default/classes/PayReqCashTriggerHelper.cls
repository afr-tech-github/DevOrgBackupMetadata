public with sharing class PayReqCashTriggerHelper {
    public static void connectBillToCash(List<PayReqCash__c> payReqCashNews) {
        Set<Id> paymentRequestIds = new Set<Id>();
		Set<Id> cashIds = new Set<Id>();
		Map<String, Set<String>> cashByPaymentRquestMap = new Map<String, Set<String>>();
		for(PayReqCash__c payReqCash : payReqCashNews){
			cashIds.add(payReqCash.CashID__c);
			paymentRequestIds.add(payReqCash.PaymentRequestID__c);
			if(cashByPaymentRquestMap.containsKey(payReqCash.PaymentRequestID__c)){
				cashByPaymentRquestMap.get(payReqCash.PaymentRequestID__c).add(payReqCash.CashID__c);
			}else{
				cashByPaymentRquestMap.put(payReqCash.PaymentRequestID__c, new Set<String>{payReqCash.CashID__c});
			}
		}

		// get all bill combined to Plan
		List<FMSBillPayReq__c> listBillPaymentRequest = [SELECT Id, PaymentRequestID__c, FMSBillID__c
													FROM FMSBillPayReq__c 
		
													WHERE PaymentRequestID__c IN: paymentRequestIds ];
		Set<Id> billIds = new Set<Id>();
		for(FMSBillPayReq__c billPayReq: listBillPaymentRequest){
			billIds.add(billPayReq.FMSBillID__c);
		}
		// get bill combined to planed
		List<ConnectInvoicingAndCash__c> listBillCash = [SELECT Id, Cashbook__c, Invoicing__c
													FROM ConnectInvoicingAndCash__c 
		
													WHERE Cashbook__c IN: cashIds
													AND  Invoicing__c IN: billIds];
		Map<String, Set<String>> mapBillsByCash = new Map<String, Set<String>>();
		for(ConnectInvoicingAndCash__c billCash : listBillCash){
			if(mapBillsByCash.containsKey(billCash.Cashbook__c)){
				mapBillsByCash.get(billCash.Cashbook__c).add(billCash.Invoicing__c);
			}else{
				mapBillsByCash.put(billCash.Cashbook__c, new Set<String>{billCash.Invoicing__c});
			}
		}

		Set<String> billPayReqs = new Set<String>();

		List<ConnectInvoicingAndCash__c> billCashNews = new List<ConnectInvoicingAndCash__c>();

		for(FMSBillPayReq__c billPayReq: listBillPaymentRequest){
			String key = (String)billPayReq.FMSBillID__c + (String)billPayReq.PaymentRequestID__c;
			if(!billPayReqs.contains(key)){
				billPayReqs.add(key);
				for(String cashId : cashByPaymentRquestMap.get(billPayReq.PaymentRequestID__c)){
					if(!mapBillsByCash.containsKey(cashId) 
						|| (mapBillsByCash.containsKey(cashId) && !mapBillsByCash.get(cashId).contains(billPayReq.FMSBillID__c)) ){

						ConnectInvoicingAndCash__c billCash = new ConnectInvoicingAndCash__c(
							Cashbook__c = cashId,
							Invoicing__c = billPayReq.FMSBillID__c);
						billCashNews.add(billCash);
						if(mapBillsByCash.containsKey(cashId)){
							mapBillsByCash.get(cashId).add(billPayReq.FMSBillID__c);
						}else{
							mapBillsByCash.put(cashId, new Set<String>{billPayReq.FMSBillID__c});
						}
					}
					
				}
            }
        }
        try{
        	FlsService.doInsert(billCashNews);
		}catch(Exception ex){
			payReqCashNews[0].addError(ex.getMessage());
		}
    }
}