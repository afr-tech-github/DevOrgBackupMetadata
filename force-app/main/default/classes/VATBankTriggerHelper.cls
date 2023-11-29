public with sharing class VATBankTriggerHelper {
    public static void connectBillToBank(List<VATBank__c> newVATBanks) {
        Set<Id> vatIds = new Set<Id>();
		Set<Id> bankIds = new Set<Id>();
		Map<String, Set<String>> bankByVATMap = new Map<String, Set<String>>();
		for(VATBank__c vatBank : newVATBanks){
			bankIds.add(vatBank.BankID__c);
			vatIds.add(vatBank.VATInvoiceID__c);
			if(bankByVATMap.containsKey(vatBank.VATInvoiceID__c)){ 
				bankByVATMap.get(vatBank.VATInvoiceID__c).add(vatBank.BankID__c);
			}else{
				bankByVATMap.put(vatBank.VATInvoiceID__c, new Set<String>{vatBank.BankID__c});
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

		Set<String> billVATs = new Set<String>();

		List<CloFMSBillBank__c> billBankNews = new List<CloFMSBillBank__c>();
		for(INVOICING_VAT__c billVAT: listBillVAT){
			String key = (String)billVAT.INVOICING__c + (String)billVAT.VAT_INVOICE__c;
			if(!billVATs.contains(key)){
				billVATs.add(key);
				for(String bankId : bankByVATMap.get(billVAT.VAT_INVOICE__c)){
					if(!mapBillsByBank.containsKey(bankId) 
						|| (mapBillsByBank.containsKey(bankId) && !mapBillsByBank.get(bankId).contains(billVAT.INVOICING__c)) ){

						CloFMSBillBank__c billBank = new CloFMSBillBank__c(
							BankTransactionID__c = bankId,
							CloFMSBillID__c = billVAT.INVOICING__c);
						billBankNews.add(billBank);
						if(mapBillsByBank.containsKey(bankId)){
							mapBillsByBank.get(bankId).add(billVAT.INVOICING__c);
						}else{
							mapBillsByBank.put(bankId, new Set<String>{billVAT.INVOICING__c});
						}
					}
					
				}
            }
        }
        try{
			FlsService.doInsert(billBankNews);
		}catch(Exception ex){
			newVATBanks[0].addError(ex.getMessage());
		}
				
    }
}