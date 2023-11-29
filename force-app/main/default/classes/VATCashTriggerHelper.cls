public with sharing class VATCashTriggerHelper {
    public static void connectBillToCash(List<VATCash__c> newVATCashs) {
        Set<Id> vatIds = new Set<Id>();
		Set<Id> cashIds = new Set<Id>();
		Map<String, Set<String>> cashByVATMap = new Map<String, Set<String>>();
		for(VATCash__c vatCash : newVATCashs){
			cashIds.add(vatCash.CashID__c);
			vatIds.add(vatCash.VATInvoiceID__c);
			if(cashByVATMap.containsKey(vatCash.VATInvoiceID__c)){ 
				cashByVATMap.get(vatCash.VATInvoiceID__c).add(vatCash.CashID__c);
			}else{
				cashByVATMap.put(vatCash.VATInvoiceID__c, new Set<String>{vatCash.CashID__c});
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
		// get bill combined to Cash
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

		Set<String> billVATs = new Set<String>();

		List<ConnectInvoicingAndCash__c> billCashNews = new List<ConnectInvoicingAndCash__c>();
		for(INVOICING_VAT__c billVAT: listBillVAT){
			String key = (String)billVAT.INVOICING__c + (String)billVAT.VAT_INVOICE__c;
			if(!billVATs.contains(key)){
				billVATs.add(key);
				for(String cashId : cashByVATMap.get(billVAT.VAT_INVOICE__c)){
					if(!mapBillsByCash.containsKey(cashId) 
						|| (mapBillsByCash.containsKey(cashId) && !mapBillsByCash.get(cashId).contains(billVAT.INVOICING__c)) ){

						ConnectInvoicingAndCash__c billBank = new ConnectInvoicingAndCash__c(
							Cashbook__c = cashId,
							Invoicing__c = billVAT.INVOICING__c);
						billCashNews.add(billBank);
						if(mapBillsByCash.containsKey(cashId)){
							mapBillsByCash.get(cashId).add(billVAT.INVOICING__c);
						}else{
							mapBillsByCash.put(cashId, new Set<String>{billVAT.INVOICING__c});
						}
					}
					
				}
            }
        }
        try{
			FlsService.doInsert(billCashNews);
		}catch(Exception ex){
			newVATCashs[0].addError(ex.getMessage());
		}
    }
}