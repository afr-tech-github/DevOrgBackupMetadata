public with sharing class WosLineItemTriggerHelper {
    public static void autoPopulateFields(List<WosLineItem__c> listNew, Map<Id, WosLineItem__c> mapOld) {
        Set<Id> setFrom = new Set<Id>();
        List<WosLineItem__c> listProcess = new List<WosLineItem__c>();
        for (WosLineItem__c item : listNew) {
            if (item.WorkOrderService__c != null && (mapOld == null || mapOld.get(item.Id).WorkOrderService__c != item.WorkOrderService__c)) {
                setFrom.add(item.WorkOrderService__c);
                listProcess.add(item);
            }
        }
        if (setFrom.isEmpty()) {
            return;
        }
        Map<Id, WorkOrderService__c> mapFrom = new Map<Id, WorkOrderService__c>([SELECT WorkOrder__c FROM WorkOrderService__c WHERE Id IN :setFrom]);
        for (WosLineItem__c item : listProcess) {
            item.WorkOrderID__c = mapFrom.get(item.WorkOrderService__c).WorkOrder__c;
        }
    }

    public static void linkWoCargo(List<WosLineItem__c> listNew) {
        Set<Id> setCargoIds = new Set<Id>();
        Set<Id> setWosIds = new Set<Id>();

        for (WosLineItem__c item : listNew) {
            setWosIds.add(item.WorkOrderService__c);
            setCargoIds.add(item.Cargo__c);
        }

        Set<Id> setWoIds = new Set<Id>();
        Map<Id, WorkOrderService__c> mapWos = new Map<Id, WorkOrderService__c>([SELECT WorkOrder__c FROM WorkOrderService__c WHERE Id IN :setWosIds]);
        for (WorkOrderService__c item : mapWos.values()) {
            setWoIds.add(item.WorkOrder__c);
        }

        List<WO_Cargo__c> listWoCargo = [
            SELECT Id, WorkOrder__c, Cargo__c
            FROM WO_Cargo__c 
            WHERE Cargo__c IN :setCargoIds 
                AND WorkOrder__c IN :setWoIds
        ];

        for (WosLineItem__c item : listNew) {
            for (WO_Cargo__c woCargo : listWoCargo) {
                if (woCargo.WorkOrder__c == mapWos.get(item.WorkOrderService__c).WorkOrder__c && woCargo.Cargo__c == item.Cargo__c) {
                    item.WO_Cargo__c = woCargo.Id;
                    break;
                }
            }
            // [27/08/2019] enforce rule causing problem with all existing processes, so commented out.
            // if (item.WO_Cargo__c == null) {
            //     item.WO_Cargo__c.addError('Cannot find any WO+Cargo record that link the provided Work Order and Cargo.');
            // }
        }
    }

    public static void updateDamagedCargoes(List<WosLineItem__c> listNew, Map<Id, WosLineItem__c> mapOld) {
        List<Cargo__c> listCargoesToUpdate = new List<Cargo__c>();

        for (WosLineItem__c item : listNew) {
            if (
                item.IsCargoScanned__c == true && (item.CargoStatus__c == 'Damaged' || item.CargoStatus__c == 'Missing')
                && (
                    mapOld == null || item.IsCargoScanned__c != mapOld.get(item.Id).IsCargoScanned__c || item.CargoStatus__c != mapOld.get(item.Id).CargoStatus__c
                )
            ) {
                listCargoesToUpdate.add(new Cargo__c(Id = item.Cargo__c, CargoLifeCycle__c = item.CargoStatus__c));
            }
        }

        if (!listCargoesToUpdate.isEmpty()) {
            FlsService.doUpdate(listCargoesToUpdate);
        }
    }
}