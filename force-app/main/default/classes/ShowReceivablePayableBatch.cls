global with sharing class ShowReceivablePayableBatch implements Database.Batchable<sObject>, Database.Stateful {
    private List<String> ankenMeisaiIdUpdateList {get; set;}
    private clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiInput {get; set;}
    private Boolean isShowReceivable {get; set;}

    global ShowReceivablePayableBatch(List<String> ankenMeisaiIdList, clofor_com_cfs__AnkenMeisai__c objAnkenMeisai, Boolean isShowReceivable) {
        this.ankenMeisaiIdUpdateList = ankenMeisaiIdList;
        this.objAnkenMeisaiInput = objAnkenMeisai;
        this.isShowReceivable = isShowReceivable;
    }

    global List<clofor_com_cfs__AnkenMeisai__c> start(Database.BatchableContext bc) {
        List<clofor_com_cfs__AnkenMeisai__c> ankenMeisaiUpdateList = new List<clofor_com_cfs__AnkenMeisai__c>();
        if (!ankenMeisaiIdUpdateList.isEmpty()) {
            for(String meisaiIdUpdate : this.ankenMeisaiIdUpdateList) {
                ankenMeisaiUpdateList.add(this.createanKenMeisaiUpdate(meisaiIdUpdate, this.objAnkenMeisaiInput, this.isShowReceivable));					
            }
        }
        return ankenMeisaiUpdateList;
	}

    global void execute(Database.BatchableContext bc, List<clofor_com_cfs__AnkenMeisai__c> ankenMeisaiUpdateList) {
        Savepoint sp;
        try {
			if (!ankenMeisaiUpdateList.isEmpty()) {
				sp = Database.setSavepoint();
				FlsService.doupdate(ankenMeisaiUpdateList);
			}
		} catch (Exception ex) {
            if (sp != null) {
				Database.rollback(sp);
			}

		}    
    }

    global void finish(Database.BatchableContext bc) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string[] to = new string[] { UserInfo.getUserEmail() };
           
            email.setToAddresses(to);
            email.setSubject('ShowReceivablePayablBatch');
            String msg = 'Process done. <br/><br/>';
            email.setHtmlBody(msg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });      
        } catch (Exception ex) {

        }
    }

    private clofor_com_cfs__AnkenMeisai__c createanKenMeisaiUpdate(String meisaiIdUpdate
                                                                    ,clofor_com_cfs__AnkenMeisai__c objAnkenMeisai
                                                                    ,Boolean isReceivable) {
        clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiUpdate = new clofor_com_cfs__AnkenMeisai__c();
        objAnkenMeisaiUpdate.Id = meisaiIdUpdate;

        if (isReceivable) {
            objAnkenMeisaiUpdate.clofor_com_cfs__NyukinKakuninzumi__c = objAnkenMeisai.clofor_com_cfs__NyukinKakuninzumi__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__Payer__c = objAnkenMeisai.clofor_com_cfs__Payer__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__BANKTRANSITTYPE__c = objAnkenMeisai.clofor_com_cfs__BANKTRANSITTYPE__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__ReceiptanceDate_del__c = objAnkenMeisai.clofor_com_cfs__ReceiptanceDate_del__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__BankAccountForReceiving__c = objAnkenMeisai.clofor_com_cfs__BankAccountForReceiving__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__SellDetail__c = objAnkenMeisai.clofor_com_cfs__SellDetail__c;
        } else {
            objAnkenMeisaiUpdate.clofor_com_cfs__SiharaiKakuninzumi__c = objAnkenMeisai.clofor_com_cfs__SiharaiKakuninzumi__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__actual_payer__c = objAnkenMeisai.clofor_com_cfs__actual_payer__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__payment_category__c = objAnkenMeisai.clofor_com_cfs__payment_category__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__PaymentDate__c = objAnkenMeisai.clofor_com_cfs__PaymentDate__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__BankAccountForPayment__c = objAnkenMeisai.clofor_com_cfs__BankAccountForPayment__c;
            objAnkenMeisaiUpdate.clofor_com_cfs__BuyDetail__c = objAnkenMeisai.clofor_com_cfs__BuyDetail__c;
        }
        
        return objAnkenMeisaiUpdate;
    }
}