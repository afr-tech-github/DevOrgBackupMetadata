/**
 * Created by khanhpham on 12/14/17.
 */

public with sharing class KickbackTriggerHandler extends AbstractTriggerHandler {
    private static List<MgmtMaster__c> exchangeRates = new List<MgmtMaster__c>();
    private Map<Id, Account> accountMap = new Map<Id, Account>();
    private Map<Id, CustomObject1__c> shipmentOrderMap = new Map<Id, CustomObject1__c>();
    private Map<Id, CASH_BOOK__c> toBeUpdatedCashBookMap = new Map<Id, CASH_BOOK__c>();
    private Map<Id, List<CASH_BOOK__c>> cashBooksByKickbackMap = new Map<Id, List<CASH_BOOK__c>>();

    static {
        exchangeRates = ExchangeRateSynchronizationService.loadMasterExchangeRates();
    }

    public override String getHandlerName() {
        return 'KickbackTriggerHandler';
    }

    public override void bulkBefore() {
        if (Trigger.isInsert) {
            loadReferences(Trigger.new);
        } else if (Trigger.isUpdate) {
            loadCashConnector(Trigger.new);
        } else if (Trigger.isDelete) {
            loadCashConnector(Trigger.old);
        }
    }

    public override void beforeInsert(SObject so) {
        Kickback__c kickback = (Kickback__c) so;
        syncExchangeRate(kickback);
        updateLocalUnitPrice(kickback);
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        Kickback__c oldKickback = (Kickback__c) oldSo;
        Kickback__c kickback = (Kickback__c) so;
        confirmPaymentSettlement(kickback);
        updateLocalUnitPrice(kickback);
        //updateConnectedCashAmount(oldKickback, kickback);
    }
    public override void afterUpdate(SObject oldSo, SObject so) {
        Kickback__c oldKickback = (Kickback__c) oldSo;
        Kickback__c kickback = (Kickback__c) so;
        updateConnectedCashAmount(oldKickback, kickback);
    }

    public override void beforeDelete(SObject so) {
        Kickback__c kickback = (Kickback__c) so;
        List<CASH_BOOK__c> cashBookList = cashBooksByKickbackMap.get(kickback.Id);

        if (cashBookList != null && !cashBookList.isEmpty()) {
            for (CASH_BOOK__c cashBook : cashBookList) {
                if (!Util.isCashOut(cashBook)) continue;

                /*if (cashBook.TotalAmount__c != null && kickback.TotalKickbackAmount__c != null) {
                    cashBook.TotalAmount__c -= kickback.TotalKickbackAmount__c;*/
                if(cashBook.TotalAmount__c == null){
                        cashBook.TotalAmount__c = 0;
                }
                cashBook.TotalAmount__c -= kickback.UnpaidBalance__c;

                if(cashBook.TotalAmountOfCashOutUSD__c == null){
                        cashBook.TotalAmountOfCashOutUSD__c = 0;
                }
                cashBook.TotalAmountOfCashOutUSD__c -= kickback.UnpaidBalanceUSD__c;

                if (!toBeUpdatedCashBookMap.containsKey(cashBook.Id)) {
                    toBeUpdatedCashBookMap.put(cashBook.Id, cashBook);
                }
                /*}*/
            }
        }
    }

    private void updateConnectedCashAmount(Kickback__c oldKickback, Kickback__c kickback) {
        List<CASH_BOOK__c> cashBookList = cashBooksByKickbackMap.get(kickback.Id);

        if (cashBookList != null && !cashBookList.isEmpty()) {
            for (CASH_BOOK__c cashBook : cashBookList) {
                if (!Util.isCashOut(cashBook)) continue;

                Boolean hasChanged = false;

                if(oldKickback.UnpaidBalance__c != kickback.UnpaidBalance__c){
                    if(cashBook.TotalAmount__c == null){
                        cashBook.TotalAmount__c = 0;
                    }
                    cashBook.TotalAmount__c -= oldKickback.UnpaidBalance__c;
                    cashBook.TotalAmount__c += kickback.UnpaidBalance__c;
                    hasChanged =true;
                }
                if(oldKickback.UnpaidBalanceUSD__c != kickback.UnpaidBalanceUSD__c){
                    if(cashBook.TotalAmountOfCashOutUSD__c == null){
                        cashBook.TotalAmountOfCashOutUSD__c = 0;
                    }
                    cashBook.TotalAmountOfCashOutUSD__c -= oldKickback.UnpaidBalanceUSD__c;
                    cashBook.TotalAmountOfCashOutUSD__c += kickback.UnpaidBalanceUSD__c;
                    hasChanged =true;
                }

                /*if (cashBook.TotalAmount__c != null && oldKickback.TotalKickbackAmount__c != null) {
                    cashBook.TotalAmount__c -= oldKickback.TotalKickbackAmount__c;
                    hasChanged = true;
                }

                if (cashBook.TotalAmount__c != null && kickback.TotalKickbackAmount__c != null) {
                    cashBook.TotalAmount__c += kickback.TotalKickbackAmount__c;
                    hasChanged = true;
                } else if (kickback.TotalKickbackAmount__c != null) {
                    cashBook.TotalAmount__c = kickback.TotalKickbackAmount__c;
                    hasChanged = true;
                }*/

                if (hasChanged && !toBeUpdatedCashBookMap.containsKey(cashBook.Id)) {
                    toBeUpdatedCashBookMap.put(cashBook.Id, cashBook);
                }
            }
        }
    }

    private void updateLocalUnitPrice(Kickback__c kickback) {
        if ((kickback.UnitPrice__c == 0 || kickback.UnitPrice__c == null) && kickback.UnitPriceUSD__c != null && kickback.ExchangeRate__c != null) {
            kickback.UnitPrice__c = kickback.UnitPriceUSD__c * kickback.ExchangeRate__c;
        }
    }

    private void syncExchangeRate(Kickback__c kickback) {
        CustomObject1__c shipmentOrder = shipmentOrderMap.get(kickback.ShipmentOrder__c);

        if (shipmentOrder != null) {
            Date lookupDate = shipmentOrder.PrintDate__c;

            ExchangeRateSynchronizationService.applyExchangeRateToKickback(exchangeRates, kickback,
                    lookupDate, accountMap.get(kickback.KickbackTo__c));
        }
    }

    private void confirmPaymentSettlement(Kickback__c kickback) {
        if (kickback.PaymentConfirmed__c == true) {
            kickback.PaymentSettledDate__c = System.today();
            kickback.PaidAmount__c = kickback.TotalKickbackAmount__c;
            kickback.PaidAmountUSD__c = kickback.TotalKickbackAmountUSD__c;
        }
    }

    private void loadReferences(List<Kickback__c> kickbacks) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> shipmentOrderIds = new Set<Id>();

        for (Kickback__c kickback : kickbacks) {
            accountIds.add(kickback.KickbackTo__c);
            shipmentOrderIds.add(kickback.ShipmentOrder__c);
        }

        accountMap = new Map<Id, Account>([
                SELECT Id, Custom_Type__c, Currency__c, Business_Relationship__c,
                        Primary_Exchange_Rate_Currency__c, Secondary_Exchange_Rate_Currency__c
                FROM Account
                WHERE Id IN :accountIds
        ]);

        shipmentOrderMap = new Map<Id, CustomObject1__c>([SELECT Id, PrintDate__c FROM CustomObject1__c WHERE Id IN :shipmentOrderIds]);
    }
    
    private void loadCashConnector(List<Kickback__c> kickbacks) {
        Set<Id> kickbackIds = new Set<Id>();

        if (kickbacks != null && !kickbacks.isEmpty()) {
            for (Kickback__c kickback : kickbacks) {
                kickbackIds.add(kickback.Id);
            }
        }

        List<ConnectKickabckCash__c> kickbackCashList = [
                SELECT KickbackID__c, Cashbook__c
                FROM ConnectKickabckCash__c
                WHERE KickbackID__c IN :kickbackIds
        ];

        Map<Id, List<Id>> cashBookToKickbackList = new Map<Id, List<Id>>();
        for (ConnectKickabckCash__c pic : kickbackCashList) {
            if (cashBookToKickbackList.containsKey(pic.Cashbook__c)) {
                cashBookToKickbackList.get(pic.Cashbook__c).add(pic.KickbackID__c);
            } else {
                List<Id> kickbackIdList = new List<Id>();
                kickbackIdList.add(pic.KickbackID__c);
                cashBookToKickbackList.put(pic.Cashbook__c, kickbackIdList);
            }
        }

        // load cash book
        if (!cashBookToKickbackList.keySet().isEmpty()) {
            List<CASH_BOOK__c> cashBookList = [SELECT Id,  
                                                    TotalAmountCashIn__c, 
                                                    TotalAmount__c,
                                                    TotalAmountOfCashOutUSD__c,
                                                    TotalAmountOfCashInUSD__c, 
                                                    RecordTypeId FROM CASH_BOOK__c WHERE Id IN :cashBookToKickbackList.keySet()];

            for (CASH_BOOK__c cashBook : cashBookList) {
                List<Id> kickbackIdList = cashBookToKickbackList.get(cashBook.Id);

                if (!kickbackIdList.isEmpty()) {
                    for (Id piId : kickbackIdList) {
                        if (cashBooksByKickbackMap.containsKey(piId)) {
                            cashBooksByKickbackMap.get(piId).add(cashBook);
                        } else {
                            List<CASH_BOOK__c> kickbackCashBookList = new List<CASH_BOOK__c>();
                            kickbackCashBookList.add(cashBook);
                            cashBooksByKickbackMap.put(piId, kickbackCashBookList);
                        }
                    }
                }
            }
        }
    }
}