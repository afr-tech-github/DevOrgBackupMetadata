public with sharing class WorkOrderServiceTriggerHelper {
    public static void autoPopulateFields(List<WorkOrderService__c> listNew, Map<Id, WorkOrderService__c> mapOld) {
        Set<Id> setLocator = new Set<Id>();
        List<WorkOrderService__c> listUpdateFromLocator = new List<WorkOrderService__c>();
        for (WorkOrderService__c item : listNew) {
            //default values
            item.InitialQuantity__c = item.InitialQuantity__c == null ? 0 : item.InitialQuantity__c;
            item.PlannedQuantity__c = item.PlannedQuantity__c == null ? 0 : item.PlannedQuantity__c;
            item.MissingQuantity__c = item.MissingQuantity__c == null ? 0 : item.MissingQuantity__c;

            if (item.Locator__c != null && item.Warehouse__c == null) {
                setLocator.add(item.Locator__c);
                listUpdateFromLocator.add(item);
            }
            if (item.InitialQuantity__c == 0) {
                item.InitialQuantity__c = item.PlannedQuantity__c;
            }
            item.MissingQuantity__c = item.PlannedQuantity__c - item.InitialQuantity__c;

            if (item.Status__c == 'Completed' && item.ActualEndTime__c == null) {
                item.ActualEndTime__c = System.now();
            }
        }
        Map<Id, Locator__c> mapLocator = new Map<Id, Locator__c>([SELECT WarehouseId__c FROM Locator__c WHERE Id IN :setLocator]);
        for (WorkOrderService__c item : listUpdateFromLocator) {
            item.Warehouse__c = mapLocator.get(item.Locator__c).WarehouseId__c;
        }
    }

    public static void generateStockAndUpdateCargoLifeCycle(List<WorkOrderService__c> listNew, Map<Id, WorkOrderService__c> mapOld) {
        Set<Id> setIdToGenStock = new Set<Id>();
        Set<Id> setIdToUpdateCargo = new Set<Id>();

        for (WorkOrderService__c item : listNew) {
            if (item.Status__c != 'Completed' || mapOld.get(item.Id).Status__c == item.Status__c) {
                return;
            }

            if (item.RecordTypeId == Constants.RecordTypeId_Wos_Picking || item.RecordTypeId == Constants.RecordTypeId_Wos_PutAway) {
                setIdToGenStock.add(item.Id);
                setIdToUpdateCargo.add(item.Id);
            } else if (item.RecordTypeId == Constants.RecordTypeId_Wos_OutboundDispatch) {
                setIdToUpdateCargo.add(item.Id);
            }
        }
        
        if (!setIdToGenStock.isEmpty()) {
            genStockAndUpdateCount(setIdToGenStock);
        }
        
        if (!setIdToUpdateCargo.isEmpty()) {
            updateCargoStatus(setIdToUpdateCargo);
        }
    }

    @future
    private static void genStockAndUpdateCount(Set<Id> setWosIds) {
        List<WosLineItem__c> listWosLineToGenStock = [
            SELECT Id, Locator__c
                , Locator__r.WarehouseID__c
                , WorkOrderService__r.RecordTypeId, WorkOrderService__r.WorkOrder__r.Customer__c
                , Cargo__r.ExpiredDate__c, Cargo__r.ManufacturedDate__c, Cargo__r.Product__c, Cargo__r.QuantityCal__c
            FROM WosLineItem__c
            WHERE WorkOrderService__c IN :setWosIds
                AND CargoStatus__c = 'Completed'
        ];

        if (listWosLineToGenStock.isEmpty()) {
            return;
        }

        List<Stock__c> listStock = new List<Stock__c>();
        Map<String, Integer> invLogStockIn = new Map<String, Integer>();
        Map<String, Integer> invLogStockOut = new Map<String, Integer>();
        for(WosLineItem__c item: listWosLineToGenStock) {
            String invLogCid = item.Locator__r.WarehouseID__c + '-' + item.Cargo__r.Product__c;
            if (item.WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_Picking) {
                invLogStockOut.put(invLogCid, (invLogStockOut.containsKey(invLogCid) ? invLogStockOut.get(invLogCid) : 0) + Integer.valueOf(item.Cargo__r.QuantityCal__c));
            } else if (item.WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_PutAway){
                invLogStockIn.put(invLogCid, (invLogStockIn.containsKey(invLogCid) ? invLogStockIn.get(invLogCid) : 0) + Integer.valueOf(item.Cargo__r.QuantityCal__c));
            }

            listStock.add(new Stock__c(
                Customer__c = item.WorkOrderService__r.WorkOrder__r.Customer__c,
                ExpiredDate__c = item.Cargo__r.ExpiredDate__c,
                ManufacturedDate__c = item.Cargo__r.ManufacturedDate__c,
                ProductID__c = item.Cargo__r.Product__c,
                Quantity__c = item.Cargo__r.QuantityCal__c,
                StockDate__c = System.today(),
                StockCountStartDate__c = System.today(),
                StockLocator__c = item.Locator__c,
                StockStatus__c = 'Completed',
                WOSLineID__c = item.Id,
                WorkOrderServiceID__c = item.WorkOrderService__r.Id,
                RecordTypeId = item.WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_Picking ? Constants.RecordTypeId_Stock_StockOut : Constants.RecordTypeId_Stock_StockIn
            ));
        }
        
        FlsService.doInsert(listStock);

        //UPDATE INVENTORY LOG
        List<InventoryLog__c> listInvLog = [SELECT Id, CompoundId__c, StockInQuantity__c, StockOutQuantity__c FROM InventoryLog__c WHERE CompoundId__c IN :invLogStockIn.keySet()  OR CompoundId__c IN :invLogStockOut.keySet()];
        for (InventoryLog__c item : listInvLog) {
            item.StockInQuantity__c = (item.StockInQuantity__c == null ? 0 : item.StockInQuantity__c) + (invLogStockIn.containsKey(item.CompoundId__c) ? invLogStockIn.get(item.CompoundId__c) : 0);
            item.StockOutQuantity__c = (item.StockOutQuantity__c == null ? 0 : item.StockOutQuantity__c) + (invLogStockOut.containsKey(item.CompoundId__c) ? invLogStockOut.get(item.CompoundId__c) : 0);
        }
        
        if (!listInvLog.isEmpty()) {
		    FlsService.doUpdate(listInvLog);
        }
    }
    
    @future
    private static void updateCargoStatus(Set<Id> setWosIds) {
        List<Cargo__c> listCargoes = [SELECT Id, CargoLifeCycle__c, LastWosLineItem__r.WorkOrderService__r.RecordTypeId, LastWosLineItem__r.WorkOrderService__r.ActualEndTime__c FROM Cargo__c WHERE LastWosLineItem__r.WorkOrderService__c IN :setWosIds];
        
        if (listCargoes.isEmpty()) {
            return;
        }

        Set<String> listExcludedStatuses = new Set<String> { 'Damaged', 'Missing' };

        for (Cargo__c item : listCargoes) {
            if (item.LastWosLineItem__r.WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_PutAway) {
                item.InboundDate__c = item.LastWosLineItem__r.WorkOrderService__r.ActualEndTime__c;
                item.InboundDate__c = item.InboundDate__c == null ? System.now() : item.InboundDate__c;

                if (!listExcludedStatuses.contains(item.CargoLifeCycle__c)) {
                    item.CargoLifeCycle__c = 'For sales';
                }
            } else if (item.LastWosLineItem__r.WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_OutboundDispatch) {
                item.OutboundDate__c = item.LastWosLineItem__r.WorkOrderService__r.ActualEndTime__c;
                item.OutboundDate__c = item.OutboundDate__c == null ? System.now() : item.OutboundDate__c;
                
                if (!listExcludedStatuses.contains(item.CargoLifeCycle__c)) {
                    item.CargoLifeCycle__c = 'No longer exists';
                }
            }
        }

		FlsService.doUpdate(listCargoes);
    }
}