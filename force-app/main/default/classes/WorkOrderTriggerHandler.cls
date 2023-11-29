public with sharing class WorkOrderTriggerHandler extends AbstractTriggerHandler {

    public override String getHandlerName() {
        return 'WorkOrderTriggerHandler';
    }

	public override void bulkAfterUpdate() {
		//this.updateWorkOrderProductFinalQuantity();
	}

	private void updateWoProdFinalQty() {
		Map<Id, WorkOrder__c> oldMap = (Map<Id, WorkOrder__c>)Trigger.OldMap;
		Set<Id> setWoIds = new Set<Id>();

		//filter for work order that has been updated to "Completed"
		for (WorkOrder__c item : (List<WorkOrder__c>)Trigger.New) {
			if (item.PurchasingOrderID__c != null && item.WorkOrderStatus__c == 'Completed' && oldMap.get(item.Id).WorkOrderStatus__c != item.WorkOrderStatus__c) {
				setWoIds.add(item.Id);
			}
		}

		List<WorkOrder__c> listWo = [
			SELECT Id, 
				(SELECT Id, ProductID__c FROM CONNECT_WORK_ORDER_PRODUCT__r),
				(SELECT Id FROM WorkOrderService__r WHERE Status__c = 'Completed' AND ActualEndTime__c != null ORDER BY ActualEndTime__c DESC)
			FROM WorkOrder__c
			WHERE Id IN :setWoIds
		];

		//filter for work order with child WorkOrder+Product and completed WOS with last ActualEndTime__c
		Set<Id> setWosIds = new Set<Id>();

		for (Integer i = listWo.size() - 1; i >= 0; i--) {
			if (listWo[i].CONNECT_WORK_ORDER_PRODUCT__r.isEmpty() || listWo[i].WorkOrderService__r.isEmpty()) {
				listWo.remove(i);
			}
			else {
				setWosIds.add(listWo[i].WorkOrderService__r[0].Id);
			}
		}

		//get final quantity count per product per wos
		Map<Id, Map<Id, Integer>> grouped = new Map<Id, Map<Id, Integer>>();
		for (AggregateResult item : [
			SELECT WorkOrderService__r.WorkOrder__c WoId, Cargo__r.Product__c ProductId, COUNT(Id) Qty
			FROM WosLineItem__c
			WHERE WorkOrderService__c IN :setWosIds
				AND Cargo__r.Product__c != null
				AND CargoStatus__c = 'Completed'
			GROUP BY WorkOrderService__r.WorkOrder__c, Cargo__r.Product__c
		]) 
		{
			Id woId = (Id)item.get('WoId');
			Id prodId = (Id)item.get('ProductId');
			if (!grouped.containsKey(woId)) {
				grouped.put(woId, new Map<Id, Integer>{ prodId => (Integer)item.get('Qty') });
			}
			else if (!grouped.get(woId).containsKey(prodId)) {
				grouped.get(woId).put(prodId, (Integer)item.get('Qty'));
			}
			else {
				grouped.get(woId).put(prodId, grouped.get(woId).get(prodId) + (Integer)item.get('Qty'));
			}
		}

		List<SObject> listToUpdate = new List<SObject>();
		for(WorkOrder__c wo : listWo) {
			for (ConnectWOProduct__c item : wo.CONNECT_WORK_ORDER_PRODUCT__r) {
				if (grouped.containsKey(wo.Id) && grouped.get(wo.Id).containsKey(item.ProductID__c)) {
					item.FinalQuantity__c = grouped.get(wo.Id).get(item.ProductID__c);
				}
			}
		}

		FlsService.doUpdate(listToUpdate);
	}
}