public with sharing class WorkOrderService  {
	@AuraEnabled
    public static Map<String, String > getTranslationMap(){
        String langCode = UserInfo.getLanguage();
        Map<String, Object> translate = TranslationService.getByLanguage(langCode.substringBefore('_'));
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('wms_wo_syncwwoproduct')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
	@AuraEnabled
	public static void sync_WoProd_Po(List<Id> setWoIds, Boolean directionToWo) {
		//get list work order with linked purchase order
		List<WorkOrder__c> listWo = [
			SELECT Id, PurchasingOrderID__c, (SELECT Id, ProductID__c, FinalQuantity__c, FinalNetWeight__c FROM CONNECT_WORK_ORDER_PRODUCT__r)
			FROM WorkOrder__c
			WHERE PurchasingOrderID__c != null
				AND Id IN :setWoIds
		];

		//extract purchase order ID and get list
		Set<Id> setPoIds = new Set<Id>();
		for(WorkOrder__c item : listWo) {
			setPoIds.add(item.PurchasingOrderID__c);
		}

		Map<Id, GoodsPurchasingOrder__c> mapPo = new Map<Id, GoodsPurchasingOrder__c>([
			SELECT Id, (SELECT Id, ProductId__c, PlanQuantity__c, ProductId__r.WeightUnit__c, ProductId__r.BuyingWeightUnit__c, TotalNetWeight__c FROM GoodsPOProduct__r) 
			FROM GoodsPurchasingOrder__c
			WHERE Id IN :setPoIds
		]);

		//loop through list work order
		List<GoodsPOProduct__c> listPoProdToUpsert = new List<GoodsPOProduct__c>();
		List<ConnectWOProduct__c> listWoProdToUpsert = new List<ConnectWOProduct__c>();
		for (WorkOrder__c wo : listWo) {
			//if purchase order doesn't have linked po+product record then skip
			if (!mapPo.containsKey(wo.PurchasingOrderID__c) || mapPo.get(wo.PurchasingOrderID__c).GoodsPOProduct__r.isEmpty()) {
				continue;
			}
			Map<Id, ConnectWOProduct__c> mapWoProd = getMapWoProd(wo.CONNECT_WORK_ORDER_PRODUCT__r);
			for (GoodsPOProduct__c poProd : mapPo.get(wo.PurchasingOrderID__c).GoodsPOProduct__r) {
				//if syncing from PO to WO, then if wo+product already exists for the same product, then just change quantity or whatever, otherwise create new record
				if (directionToWo) {
					ConnectWOProduct__c woProd = mapWoProd.containsKey(poProd.ProductId__c) 
						? mapWoProd.get(poProd.ProductId__c) 
						: new ConnectWOProduct__c(
							WorkOrderID__c = wo.Id, 
							ProductId__c = poProd.ProductId__c
						);
					woProd.Quantity__c = poProd.PlanQuantity__c;
                    woProd.NetWeightKg__c = Util.ConvertWeightToUnit(poProd.ProductId__r.BuyingWeightUnit__c, poProd.ProductId__r.WeightUnit__c, poProd.TotalNetWeight__c);
					listWoProdToUpsert.add(woProd);
				}
				//if syncing from WO to PO, then find the matching WO+Product and sync final quantity to PO+Product
				else if (mapWoProd.containsKey(poProd.ProductId__c)){
					ConnectWOProduct__c woProd = mapWoProd.get(poProd.ProductId__c);
					poProd.FinalQuantity__c = woProd.FinalQuantity__c;
					poProd.FinalNetWeight__c = Util.ConvertWeightToUnit(poProd.ProductId__r.WeightUnit__c, poProd.ProductId__r.BuyingWeightUnit__c, woProd.FinalNetWeight__c);
					listPoProdToUpsert.add(poProd);
				}
			}
		}

		FlsService.doUpsert(listWoProdToUpsert);
		FlsService.doUpsert(listPoProdToUpsert);
	}

	@AuraEnabled
	public static void sync_WoProd_So(List<Id> setWoIds, Boolean directionToWo) {
		//get list work order with linked purchase order
		List<WorkOrder__c> listWo = [
			SELECT Id, SalesOrderId__c, (SELECT Id, ProductID__c, FinalQuantity__c, FinalNetWeight__c  FROM CONNECT_WORK_ORDER_PRODUCT__r)
			FROM WorkOrder__c
			WHERE SalesOrderId__c != null
				AND Id IN :setWoIds
		];

		//extract purchase order ID and get list
		Set<Id> setSoIds = new Set<Id>();
		for(WorkOrder__c item : listWo) {
			setSoIds.add(item.SalesOrderId__c);
		}

		Map<Id, SALES_ORDER__c> mapSo = new Map<Id, SALES_ORDER__c>([
			SELECT Id, (SELECT Id, ProductId__c, PlannedQuantity__c, TotalNetWeight__c FROM GoodsSalesOrderID__r) 
			FROM SALES_ORDER__c
			WHERE Id IN :setSoIds
		]);

		//loop through list work order
		List<SalesOrderProduct__c> listSoProdToUpsert = new List<SalesOrderProduct__c>();
		List<ConnectWOProduct__c> listWoProdToUpsert = new List<ConnectWOProduct__c>();
		for (WorkOrder__c wo : listWo) {
			//if sale order doesn't have linked po+product record then skip
			if (!mapSo.containsKey(wo.SalesOrderId__c) || mapSo.get(wo.SalesOrderId__c).GoodsSalesOrderID__r.isEmpty()) {
				continue;
			}
			//if wo+product already exists for the same product, then just change quantity or whatever, otherwise create new record
			Map<Id, ConnectWOProduct__c> mapWoProd = getMapWoProd(wo.CONNECT_WORK_ORDER_PRODUCT__r);
			for (SalesOrderProduct__c soProd : mapSo.get(wo.SalesOrderId__c).GoodsSalesOrderID__r) {
				//if syncing from SO to WO, then if wo+product already exists for the same product, then just change quantity or whatever, otherwise create new record
				if (directionToWo) {
					ConnectWOProduct__c woProd = mapWoProd.containsKey(soProd.ProductId__c) 
						? mapWoProd.get(soProd.ProductId__c) 
						: new ConnectWOProduct__c(
							WorkOrderID__c = wo.Id, 
							ProductId__c = soProd.ProductId__c
						);
					woProd.Quantity__c = soProd.PlannedQuantity__c;
                    woProd.NetWeightKg__c = soProd.TotalNetWeight__c;
					listWoProdToUpsert.add(woProd);
				}
				//if syncing from WO to SO, then find the matching WO+Product and sync final quantity to SO+Product
				else if (mapWoProd.containsKey(soProd.ProductId__c)){
					ConnectWOProduct__c woProd = mapWoProd.get(soProd.ProductId__c);
					soProd.FinalQuantity__c = woProd.FinalQuantity__c;
					soProd.FinalNetWeight__c = woProd.FinalNetWeight__c;
					listSoProdToUpsert.add(soProd);
				}
			}
		}
		
		FlsService.doUpsert(listWoProdToUpsert);
		FlsService.doUpsert(listSoProdToUpsert);
	}

	private static Map<Id, ConnectWOProduct__c> getMapWoProd(List<ConnectWOProduct__c> listWoProd) {
		Map<Id, ConnectWOProduct__c> mapWoProd = new Map<Id, ConnectWOProduct__c>();
		for (ConnectWOProduct__c item : listWoProd) {
			mapWoProd.put(item.ProductId__c, item);
		}
		return mapWoProd;
	}


	@AuraEnabled
	public static void updateWoProdFinalQtyFromWos(List<Id> setWoIds) {
		List<WorkOrder__c> listWo = [
			SELECT Id, 
				(SELECT Id, ProductID__c, ProductID__r.WeightUnit__c FROM CONNECT_WORK_ORDER_PRODUCT__r),
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
		//Map<Id, Map<Id, Integer>> grouped = new Map<Id, Map<Id, Integer>>();
		Map<Id, Map<Id, AggregateResult>> grouped = new Map<Id, Map<Id, AggregateResult>>();
		for (AggregateResult item : [
			SELECT WorkOrderService__r.WorkOrder__c WoId, Cargo__r.Product__c ProductId, COUNT(Id) Qty, SUM(Cargo__r.WeightCal__c) Weight
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
				//grouped.put(woId, new Map<Id, Integer>{ prodId => (Integer)item.get('Qty') });
				grouped.put(woId, new Map<Id, AggregateResult>{ prodId => item });
			}
			else {
				grouped.get(woId).put(prodId, item);
			}
		}

		List<SObject> listToUpdate = new List<SObject>();
		for(WorkOrder__c wo : listWo) {
			for (ConnectWOProduct__c item : wo.CONNECT_WORK_ORDER_PRODUCT__r) {
				if (grouped.containsKey(wo.Id) && grouped.get(wo.Id).containsKey(item.ProductID__c)) {
					item.FinalQuantity__c = (Integer)grouped.get(wo.Id).get(item.ProductID__c).get('Qty');
					item.FinalNetWeight__c = Util.ConvertWeightFromBaseUnit(item.ProductID__r.WeightUnit__c, (Decimal)grouped.get(wo.Id).get(item.ProductID__c).get('Weight'));
					listToUpdate.add(item);
				}
			}
		}

		FlsService.doUpdate(listToUpdate);
	}
}