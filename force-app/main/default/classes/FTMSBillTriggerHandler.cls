public class FTMSBillTriggerHandler {
        public static void deleteFTMSBill(Map<Id, clofor_com_cfs__AnkenMeisai__c> mapFTMSBill){
            Set<Id> billSet = mapFTMSBill.keySet();
            List<clofor_com_cfs__AnkenMeisai__c> lstBill = [Select Id, clofor_com_cfs__InboundVATInvNo__c, clofor_com_cfs__OutboundVATInvNo__c From clofor_com_cfs__AnkenMeisai__c Where Id =: billSet];
            For(clofor_com_cfs__AnkenMeisai__c bill : lstBill){
                if(bill.clofor_com_cfs__InboundVATInvNo__c != Null || bill.clofor_com_cfs__OutboundVATInvNo__c != Null){
                    mapFTMSBill.get(bill.Id).addError('Cannot be deleted because VAT output and VAT input have been entered');
                }
            }
        }
}