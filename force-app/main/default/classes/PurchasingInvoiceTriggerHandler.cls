/**
 * Created by khanhpham on 5/28/17.
 */

public with sharing class PurchasingInvoiceTriggerHandler extends AbstractTriggerHandler {
    private Map<Id, CASH_BOOK__c> toBeUpdatedCashBookMap = new Map<Id, CASH_BOOK__c>();
    private Map<Id, List<CASH_BOOK__c>> cashBooksByPIMap = new Map<Id, List<CASH_BOOK__c>>();

    public override void bulkAfter() {
        loadReferences(Trigger.new);
    }

    public override void bulkBefore() {
        if (Trigger.isDelete) {
            loadReferences(Trigger.old);
        }
    }

    public override void beforeInsert(SObject so) {
        PurchasingInvoice__c purchasingInvoice = (PurchasingInvoice__c) so;

        calculateLocalAmount(purchasingInvoice);
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        PurchasingInvoice__c purchasingInvoice = (PurchasingInvoice__c) so;

        calculateLocalAmount(purchasingInvoice);
    }

    public override void afterUpdate(SObject oldSo, SObject so) {
        PurchasingInvoice__c oldPurchasingInvoice = (PurchasingInvoice__c) oldSo;
        PurchasingInvoice__c purchasingInvoice = (PurchasingInvoice__c) so;
        List<CASH_BOOK__c> cashBookList = cashBooksByPIMap.get(purchasingInvoice.Id);

        if (cashBookList != null && !cashBookList.isEmpty()) {
            for (CASH_BOOK__c cashBook : cashBookList) {
                if (!Util.isCashOut(cashBook)) continue;

                Boolean hasChanged = false;
                if(oldPurchasingInvoice.UnpaidBalanceLocal__c != purchasingInvoice.UnpaidBalanceLocal__c){
                    if(cashBook.TotalAmount__c == null){
                        cashBook.TotalAmount__c = 0;
                    }
                    cashBook.TotalAmount__c -= oldPurchasingInvoice.UnpaidBalanceLocal__c;
                    cashBook.TotalAmount__c += purchasingInvoice.UnpaidBalanceLocal__c;
                    hasChanged = true;
                }
                if(oldPurchasingInvoice.UnpaidBalance__c != purchasingInvoice.UnpaidBalance__c){
                    if(cashBook.TotalAmountOfCashOutUSD__c == null){
                        cashBook.TotalAmountOfCashOutUSD__c = 0;
                    }
                    cashBook.TotalAmountOfCashOutUSD__c -= oldPurchasingInvoice.UnpaidBalance__c;
                    cashBook.TotalAmountOfCashOutUSD__c += purchasingInvoice.UnpaidBalance__c;
                    hasChanged = true;
                }

                /* if (cashBook.TotalAmount__c != null && oldPurchasingInvoice.AmountIncludedTaxLocal__c != null) {
                    cashBook.TotalAmount__c -= oldPurchasingInvoice.AmountIncludedTaxLocal__c;
                    hasChanged = true;
                }

                if (cashBook.TotalAmount__c != null && purchasingInvoice.AmountIncludedTaxLocal__c != null) {
                    cashBook.TotalAmount__c += purchasingInvoice.AmountIncludedTaxLocal__c;
                    hasChanged = true;
                } else if (purchasingInvoice.AmountIncludedTaxLocal__c != null) {
                    cashBook.TotalAmount__c = purchasingInvoice.AmountIncludedTaxLocal__c;
                    hasChanged = true;
                }*/

                if (hasChanged && !toBeUpdatedCashBookMap.containsKey(cashBook.Id)) {
                    toBeUpdatedCashBookMap.put(cashBook.Id, cashBook);
                }
            }
        }
    }

    public override void beforeDelete(SObject so) {
        PurchasingInvoice__c purchasingInvoice = (PurchasingInvoice__c) so;
        List<CASH_BOOK__c> cashBookList = cashBooksByPIMap.get(purchasingInvoice.Id);

        if (cashBookList != null && !cashBookList.isEmpty()) {
            for (CASH_BOOK__c cashBook : cashBookList) {
                if (!Util.isCashOut(cashBook)) continue;

                //if (cashBook.TotalAmount__c != null && purchasingInvoice.AmountIncludedTaxLocal__c != null) {
                //    cashBook.TotalAmount__c -= purchasingInvoice.AmountIncludedTaxLocal__c;

                if(cashBook.TotalAmount__c == null){
                    cashBook.TotalAmount__c = 0;
                }
                cashBook.TotalAmount__c -= purchasingInvoice.UnpaidBalanceLocal__c;
                
                if(cashBook.TotalAmountOfCashOutUSD__c == null){
                    cashBook.TotalAmountOfCashOutUSD__c = 0;
                }
                cashBook.TotalAmountOfCashOutUSD__c -= purchasingInvoice.UnpaidBalance__c;
                if (!toBeUpdatedCashBookMap.containsKey(cashBook.Id)) {
                    toBeUpdatedCashBookMap.put(cashBook.Id, cashBook);
                }
                //}
            }
        }
    }

    private void loadReferences(List<PurchasingInvoice__c> invoices) {
        Set<Id> piIds = new Set<Id>();

        if (invoices != null && !invoices.isEmpty()) {
            for (PurchasingInvoice__c invoice : invoices) {
                piIds.add(invoice.Id);
            }
        }

        List<ConnectPurchasingInvoiceCash__c> piCashList = [
                SELECT PurchasingInvoice__c, Cashbook__c
                FROM ConnectPurchasingInvoiceCash__c
                WHERE PurchasingInvoice__c IN :piIds
        ];

        Map<Id, List<Id>> cashBookToPIList = new Map<Id, List<Id>>();
        for (ConnectPurchasingInvoiceCash__c pic : piCashList) {
            if (cashBookToPIList.containsKey(pic.Cashbook__c)) {
                cashBookToPIList.get(pic.Cashbook__c).add(pic.PurchasingInvoice__c);
            } else {
                List<Id> piIdList = new List<Id>();
                piIdList.add(pic.PurchasingInvoice__c);
                cashBookToPIList.put(pic.Cashbook__c, piIdList);
            }
        }

        // load cash book
        if (!cashBookToPIList.keySet().isEmpty()) {
            List<CASH_BOOK__c> cashBookList = [SELECT Id, 
                                                    TotalAmountCashIn__c, 
                                                    TotalAmount__c,
                                                    TotalAmountOfCashOutUSD__c,
                                                    TotalAmountOfCashInUSD__c, 
                                                    RecordTypeId FROM CASH_BOOK__c WHERE Id IN :cashBookToPIList.keySet()];

            for (CASH_BOOK__c cashBook : cashBookList) {
                List<Id> piIdList = cashBookToPIList.get(cashBook.Id);

                if (!piIdList.isEmpty()) {
                    for (Id piId : piIdList) {
                        if (cashBooksByPIMap.containsKey(piId)) {
                            cashBooksByPIMap.get(piId).add(cashBook);
                        } else {
                            List<CASH_BOOK__c> piCashBookList = new List<CASH_BOOK__c>();
                            piCashBookList.add(cashBook);
                            cashBooksByPIMap.put(piId, piCashBookList);
                        }
                    }
                }
            }
        }
    }

    private void calculateLocalAmount(PurchasingInvoice__c purchasingInvoice) {
        if (NumbericUtils.isNonZero(purchasingInvoice.ExchangeRate__c)
                && NumbericUtils.isNonZero(purchasingInvoice.UnitPrice__c)
                && NumbericUtils.isBlank(purchasingInvoice.UnitPriceLocal__c)) {
            purchasingInvoice.UnitPriceLocal__c = purchasingInvoice.ExchangeRate__c * purchasingInvoice.UnitPrice__c;
        }

        if (NumbericUtils.isNonZero(purchasingInvoice.ExchangeRate__c)
                && NumbericUtils.isNonZero(purchasingInvoice.PaidAmount__c)
                && NumbericUtils.isBlank(purchasingInvoice.PaidAmountLocal__c)) {
            purchasingInvoice.PaidAmountLocal__c = purchasingInvoice.ExchangeRate__c * purchasingInvoice.PaidAmount__c;
        }
    }
}