public with sharing class PayReqBankTriggerHelper {
    public static void connectBillToBank(List<PayReqBank__c> payReqBankNews) {
        Set<Id> paymentRequestIds = new Set<Id>();
		Set<Id> bankIds = new Set<Id>();
		Map<String, Set<String>> bankByPaymentRquestMap = new Map<String, Set<String>>();
		for(PayReqBank__c payReqBank : payReqBankNews){
			bankIds.add(payReqBank.BankID__c);
			paymentRequestIds.add(payReqBank.PaymentRequestID__c);
			if(bankByPaymentRquestMap.containsKey(payReqBank.PaymentRequestID__c)){
				bankByPaymentRquestMap.get(payReqBank.PaymentRequestID__c).add(payReqBank.BankID__c);
			}else{
				bankByPaymentRquestMap.put(payReqBank.PaymentRequestID__c, new Set<String>{payReqBank.BankID__c});
			}
		}

		// get all bill combined to VAT
		List<FMSBillPayReq__c> listBillPaymentRequest = [SELECT Id, PaymentRequestID__c, FMSBillID__c
													FROM FMSBillPayReq__c 
		
													WHERE PaymentRequestID__c IN: paymentRequestIds ];
		Set<Id> billIds = new Set<Id>();
		for(FMSBillPayReq__c billPayReq: listBillPaymentRequest){
			billIds.add(billPayReq.FMSBillID__c);
		}
		// get bill combined to planed
		List<CloFMSBillBank__c> listBillBank = [SELECT Id, BankTransactionID__c, CloFMSBillID__c
													FROM CloFMSBillBank__c 
		
													WHERE BankTransactionID__c IN: bankIds
													AND  CloFMSBillID__c IN: billIds];
		Map<String, Set<String>> mapBillsByBank = new Map<String, Set<String>>();
		for(CloFMSBillBank__c billBank : listBillBank){
			if(mapBillsByBank.containsKey(billBank.BankTransactionID__c)){
				mapBillsByBank.get(billBank.BankTransactionID__c).add(billBank.CloFMSBillID__c);
			}else{
				mapBillsByBank.put(billBank.BankTransactionID__c, new Set<String>{billBank.CloFMSBillID__c});
			}
		}

		Set<String> billPayReqs = new Set<String>();

		List<CloFMSBillBank__c> billBankNews = new List<CloFMSBillBank__c>();

		for(FMSBillPayReq__c billPayReq: listBillPaymentRequest){
			String key = (String)billPayReq.FMSBillID__c + (String)billPayReq.PaymentRequestID__c;
			if(!billPayReqs.contains(key)){
				billPayReqs.add(key);
				for(String bankId : bankByPaymentRquestMap.get(billPayReq.PaymentRequestID__c)){
					if(!mapBillsByBank.containsKey(bankId) 
						|| (mapBillsByBank.containsKey(bankId) && !mapBillsByBank.get(bankId).contains(billPayReq.FMSBillID__c)) ){

						CloFMSBillBank__c billBank = new CloFMSBillBank__c(
							BankTransactionID__c = bankId,
							CloFMSBillID__c = billPayReq.FMSBillID__c);
						billBankNews.add(billBank);
						if(mapBillsByBank.containsKey(bankId)){
							mapBillsByBank.get(bankId).add(billPayReq.FMSBillID__c);
						}else{
							mapBillsByBank.put(bankId, new Set<String>{billPayReq.FMSBillID__c});
						}
					}
					
				}
            }
        }
        try{
        	FlsService.doInsert(billBankNews);
		}catch(Exception ex){
			payReqBankNews[0].addError(ex.getMessage());
		}
    }
}