public with sharing class VATPayReqTriggerHelper {
	public static void connectSOANDBillToTransactionPlan( List<VATPayReq__c> listTransactionPlan){
		Set<Id> vatIds = new Set<Id>();
		Set<Id> planIds = new Set<Id>();
		Map<String, Set<String>> trxPlabByVATMap = new Map<String, Set<String>>();
		for(VATPayReq__c payRequest : listTransactionPlan){
			planIds.add(payRequest.PaymentRequestID__c);
			vatIds.add(payRequest.VATInvoiceID__c);
			if(trxPlabByVATMap.containsKey(payRequest.VATInvoiceID__c)){
				trxPlabByVATMap.get(payRequest.VATInvoiceID__c).add(payRequest.PaymentRequestID__c);
			}else{
				trxPlabByVATMap.put(payRequest.VATInvoiceID__c, new Set<String>{payRequest.PaymentRequestID__c});
			}
		}

		// get all bill combined to VAT
		List<INVOICING_VAT__c> listBillVAT = [SELECT Id, VAT_INVOICE__c, INVOICING__c
													FROM INVOICING_VAT__c 
		
													WHERE VAT_INVOICE__c IN: vatIds ];
		Set<Id> billIds = new Set<Id>();
		for(INVOICING_VAT__c billVAT: listBillVAT){
			billIds.add(billVAT.INVOICING__c);
		}
		// get bill combined to planed
		List<FMSBillPayReq__c> listBillPlan = [SELECT Id, PaymentRequestID__c, FMSBillID__c
													FROM FMSBillPayReq__c 
		
													WHERE PaymentRequestID__c IN: planIds
													AND  FMSBillID__c IN: billIds];
		Map<String, Set<String>> mapBillsByPlan = new Map<String, Set<String>>();
		for(FMSBillPayReq__c billPlan : listBillPlan){
			if(mapBillsByPlan.containsKey(billPlan.PaymentRequestID__c)){
				mapBillsByPlan.get(billPlan.PaymentRequestID__c).add(billPlan.FMSBillID__c);
			}else{
				mapBillsByPlan.put(billPlan.PaymentRequestID__c, new Set<String>{billPlan.FMSBillID__c});
			}
		}

		Set<String> billVATs = new Set<String>();
		Set<String> shipmentOrderVATs = new Set<String>();

		List<FMSBillPayReq__c> billTransactionPlans = new List<FMSBillPayReq__c>();

		for(INVOICING_VAT__c billVAT: listBillVAT){
			String key = (String)billVAT.INVOICING__c + (String)billVAT.VAT_INVOICE__c;
			if(!billVATs.contains(key)){
				billVATs.add(key);
				for(String trxPlan : trxPlabByVATMap.get(billVAT.VAT_INVOICE__c)){
					if(!mapBillsByPlan.containsKey(trxPlan) 
						|| (mapBillsByPlan.containsKey(trxPlan) && !mapBillsByPlan.get(trxPlan).contains(billVAT.INVOICING__c)) ){

						FMSBillPayReq__c billTrxPlan = new FMSBillPayReq__c(
							PaymentRequestID__c = trxPlan,
							FMSBillID__c = billVAT.INVOICING__c);
						billTransactionPlans.add(billTrxPlan);
						if(mapBillsByPlan.containsKey(trxPlan)){
							mapBillsByPlan.get(trxPlan).add(billVAT.INVOICING__c);
						}else{
							mapBillsByPlan.put(trxPlan, new Set<String>{billVAT.INVOICING__c});
						}
					}
					
				}
				
			}
			/*String keyShipment = billVAT.INVOICING__r.Anken__c + billVAT.VAT_INVOICE__c;
			if(!shipmentOrderVATs.contains(keyShipment)){
				shipmentOrderVATs.add(keyShipment);
				for(String trxPlan : trxPlabByVATMap.get(billVAT.VAT_INVOICE__c)){
					FMSBillPayReq__c billTrxPlan = new FMSBillPayReq__c(
						PaymentRequestID__c = trxPlan,
						FMSBillID__c = billVAT.INVOICING__c
					);
					billTransactionPlans.add(billTrxPlan);
				}
			}*/
		}
		try{
			FlsService.doInsert(billTransactionPlans);
		}catch(Exception ex){
			listTransactionPlan[0].addError(ex.getMessage());
		}
		// get all S/O Combined to VAT
	}
}