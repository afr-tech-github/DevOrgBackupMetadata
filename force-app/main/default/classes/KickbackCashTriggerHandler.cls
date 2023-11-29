/**
 * Created by khanhpham on 12/27/17.
 */

public with sharing class KickbackCashTriggerHandler extends AbstractTriggerHandler {
    private static Map<String, CASH_BOOK__c> cashBookMap = new Map<String, CASH_BOOK__c>();
    private static Map<String, Kickback__c> kickbackMap = new Map<String, Kickback__c>();
    private static Map<String, CASH_BOOK__c> toBeUpdatedcashBookMap = new Map<String, CASH_BOOK__c>();

    public override void bulkAfter() {
        if (Trigger.isDelete) {
            loadReferences(Trigger.old);
        } else {
            loadReferences(Trigger.new);
        }
    }

    public override void afterInsert(SObject so) {
        ConnectKickabckCash__c kickabckCash = (ConnectKickabckCash__c) so;

        updateCashBookTotalAmount(kickabckCash);
    }

    public override void afterDelete(SObject so) {
        ConnectKickabckCash__c kickabckCash = (ConnectKickabckCash__c) so;

        updateCashBookTotalAmount(kickabckCash);
    }

    // public override void andFinally() {
    //     if (toBeUpdatedcashBookMap.values().size() > 0) {
    //     }
    // }

    private void updateCashBookTotalAmount(ConnectKickabckCash__c link) {
        CASH_BOOK__c cashBook = cashBookMap.get(link.Cashbook__c);

        if (Util.isCashOut(cashBook)) {
            Kickback__c kickback = kickbackMap.get(link.KickbackID__c);

            if (cashBook != null && kickback != null) {
                if (Trigger.isInsert) {
                    if (cashBook.TotalAmount__c == null) {
                        cashBook.TotalAmount__c = kickback.UnpaidBalance__c;
                    } else {
                        cashBook.TotalAmount__c += (kickback.UnpaidBalance__c != null ? kickback.UnpaidBalance__c : 0);
                    }
                } else if (Trigger.isDelete) {
                    if (cashBook.TotalAmount__c != null && kickback.UnpaidBalance__c != null) {
                        cashBook.TotalAmount__c -= kickback.UnpaidBalance__c;
                    }
                }
                toBeUpdatedcashBookMap.put(cashBook.Id, cashBook);
            }
        }
    }

    private void loadReferences(List<ConnectKickabckCash__c> links) {
        Set<Id> cashBookIds = new Set<Id>();
        Set<Id> kickbackIds = new Set<Id>();

        for (ConnectKickabckCash__c link : links) {
            cashBookIds.add(link.Cashbook__c);
            kickbackIds.add(link.KickbackID__c);
        }

        cashBookMap = new Map<String, CASH_BOOK__c>([SELECT Id, TotalAmount__c, RecordTypeId FROM CASH_BOOK__c WHERE Id IN :cashBookIds]);
        kickbackMap = new Map<String, Kickback__c>([SELECT Id, UnpaidBalance__c FROM Kickback__c WHERE Id IN :kickbackIds]);
    }
}