/**
 * Created by khanhpham on 5/28/17.
 */

public with sharing class POCashTriggerHandler extends AbstractTriggerHandler {
    private static Map<String, CASH_BOOK__c> cashBookMap = new Map<String, CASH_BOOK__c>();
    private static Map<String, PurchasingInvoice__c> invoiceMap = new Map<String, PurchasingInvoice__c>();
    private static Map<String, CASH_BOOK__c> toBeUpdatedcashBookMap = new Map<String, CASH_BOOK__c>();

    public override void bulkAfter() {
        if (Trigger.isDelete) {
            loadReferences(Trigger.old);
        } else {
            loadReferences(Trigger.new);
        }
    }

    public override void afterInsert(SObject so) {
        ConnectPurchasingInvoiceCash__c poCash = (ConnectPurchasingInvoiceCash__c) so;

        updateCashBookTotalAmount(poCash);
    }

    public override void afterDelete(SObject so) {
        ConnectPurchasingInvoiceCash__c poCash = (ConnectPurchasingInvoiceCash__c) so;

        updateCashBookTotalAmount(poCash);
    }

    private void updateCashBookTotalAmount(ConnectPurchasingInvoiceCash__c link) {
        CASH_BOOK__c cashBook = cashBookMap.get(link.Cashbook__c);
        PurchasingInvoice__c invoice = invoiceMap.get(link.PurchasingInvoice__c);

        if (cashBook != null && invoice != null && Util.isCashOut(cashBook)) {
            if (Trigger.isInsert) {
                if (cashBook.TotalAmount__c == null) {
                    cashBook.TotalAmount__c = invoice.UnpaidBalanceLocal__c;
                } else {
                    cashBook.TotalAmount__c += (invoice.UnpaidBalanceLocal__c != null ? invoice.UnpaidBalanceLocal__c : 0);
                }
            } else if (Trigger.isDelete) {
                if (cashBook.TotalAmount__c != null && invoice.UnpaidBalanceLocal__c != null) {
                    cashBook.TotalAmount__c -= invoice.UnpaidBalanceLocal__c;
                }
            }
            toBeUpdatedcashBookMap.put(cashBook.Id, cashBook);
        }
    }

    private void loadReferences(List<ConnectPurchasingInvoiceCash__c> links) {
        Set<Id> cashBookIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();

        for (ConnectPurchasingInvoiceCash__c link : links) {
            cashBookIds.add(link.Cashbook__c);
            invoiceIds.add(link.PurchasingInvoice__c);
        }

        cashBookMap = new Map<String, CASH_BOOK__c>([SELECT Id, TotalAmount__c, RecordTypeId FROM CASH_BOOK__c WHERE Id IN :cashBookIds]);
        invoiceMap = new Map<String, PurchasingInvoice__c>([SELECT Id, UnpaidBalanceLocal__c FROM PurchasingInvoice__c WHERE Id IN :invoiceIds]);
    }
}