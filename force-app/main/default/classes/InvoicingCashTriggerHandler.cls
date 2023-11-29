/**
 * Created by khanhpham on 5/28/17.
 */

public with sharing class InvoicingCashTriggerHandler extends AbstractTriggerHandler {
    private static Map<String, CASH_BOOK__c> cashBookMap = new Map<String, CASH_BOOK__c>();
    private static Map<String, AnkenMeisai__c> invoiceMap = new Map<String, AnkenMeisai__c>();
    private static Map<String, CASH_BOOK__c> toBeUpdatedcashBookMap = new Map<String, CASH_BOOK__c>();

    public override void bulkAfter() {
        if (Trigger.isDelete) {
            loadReferences(Trigger.old);
        } else {
            loadReferences(Trigger.new);
        }
    }

    public override void afterInsert(SObject so) {
        ConnectInvoicingAndCash__c poCash = (ConnectInvoicingAndCash__c) so;

        updateCashBookTotalAmount(poCash);
    }

    public override void afterDelete(SObject so) {
        ConnectInvoicingAndCash__c poCash = (ConnectInvoicingAndCash__c) so;

        updateCashBookTotalAmount(poCash);
    }

    // public override void andFinally() {
    //     if (toBeUpdatedcashBookMap.values().size() > 0) {
    //     }
    // }

    private void updateCashBookTotalAmount(ConnectInvoicingAndCash__c link) {
        CASH_BOOK__c cashBook = cashBookMap.get(link.Cashbook__c);
        AnkenMeisai__c invoice = invoiceMap.get(link.Invoicing__c);

        if (cashBook != null && invoice != null) {
            if (Trigger.isInsert) {
                if (Util.isCashOut(cashBook)) {
                    if (cashBook.TotalAmount__c == null) {
                        cashBook.TotalAmount__c = invoice.BuyDifferentiation__c;
                    } else {
                        cashBook.TotalAmount__c += (invoice.BuyDifferentiation__c != null ? invoice.BuyDifferentiation__c : 0);
                    }
                } else {
                    if (cashBook.TotalAmount__c == null) {
                        cashBook.TotalAmount__c = invoice.SellDifferentiation__c;
                    } else {
                        cashBook.TotalAmount__c += (invoice.SellDifferentiation__c != null ? invoice.SellDifferentiation__c : 0);
                    }
                }
            } else if (Trigger.isDelete) {
                if (Util.isCashOut(cashBook)) {
                    if (cashBook.TotalAmount__c != null && invoice.BuyDifferentiation__c != null) {
                        cashBook.TotalAmount__c -= invoice.BuyDifferentiation__c;
                    }
                } else {
                    if (cashBook.TotalAmount__c != null && invoice.SellDifferentiation__c != null) {
                        cashBook.TotalAmount__c -= invoice.SellDifferentiation__c;
                    }
                }
            }

            toBeUpdatedcashBookMap.put(cashBook.Id, cashBook);
        }
    }

    private void loadReferences(List<ConnectInvoicingAndCash__c> links) {
        Set<Id> cashBookIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();

        for (ConnectInvoicingAndCash__c link : links) {
            cashBookIds.add(link.Cashbook__c);
            invoiceIds.add(link.Invoicing__c);
        }

        cashBookMap = new Map<String, CASH_BOOK__c>([SELECT Id, TotalAmount__c, RecordTypeId FROM CASH_BOOK__c WHERE Id IN :cashBookIds]);
        invoiceMap = new Map<String, AnkenMeisai__c>([SELECT Id, BuyDifferentiation__c, SellDifferentiation__c FROM AnkenMeisai__c WHERE Id IN :invoiceIds]);
    }
}