public with sharing class WoCargoTriggerHandler {
    public static void autoPopulateFields(List<WO_Cargo__c> listNew) {
        Set<Id> setCargoIds = new Set<Id>();
        Set<Id> setWoIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();

        for (WO_Cargo__c item : listNew) {
            setWoIds.add(item.WorkOrder__c);
            setCargoIds.add(item.Cargo__c);
        }

        Map<Id, Cargo__c> mapCargo = new Map<Id, Cargo__c>([SELECT Id, Product__c FROM Cargo__c WHERE Id IN :setCargoIds]);
        for (Cargo__c item : mapCargo.values()) {
            setProductIds.add(item.Product__c);
        }

        List<ConnectWOProduct__c> listWoProducts = [SELECT 
            Id, ProductId__c, ProductId__r.Name, WorkOrderID__c, WorkOrderID__r.Name 
            FROM ConnectWOProduct__c 
            WHERE ProductId__c IN :setProductIds 
                AND WorkOrderID__c IN :setWoIds
        ];

        for (WO_Cargo__c item : listNew) {
            for (ConnectWOProduct__c woProd : listWoProducts) {
                if (item.WorkOrder__c == woProd.WorkOrderId__c && mapCargo.containsKey(item.Cargo__c) && mapCargo.get(item.Cargo__c).Product__c == woProd.ProductId__c) {
                    item.WO_Product__c = woProd.Id;
                    break;
                }
            }
            if (item.WO_Product__c == null) {
                item.WO_Product__c.addError('Cannot find any WO+Product record that link the provided Work Order and Cargo\'s product.');
            }
        }
    }
}