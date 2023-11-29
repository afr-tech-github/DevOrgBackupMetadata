public with sharing class StockTriggerHelper {
	/*
	   Method Name: calculateLocatorWhenDeleteStock
	   prarams: list of delete stock
	   Description: re-Calculate Actual and Current Occupied Capacity of Locator
	   Author: Nga Do
	 */
	public static void calculateOccupiedCapacity(List<Stock__c> newStocks, Map<Id, Stock__c> oldStock){
	}
	public static void calculateLocatorWhenDeleteStock(List<clofor_com_cfs__Stock__c > oldStocks){
		RecordType stockInRecId = getRecIdByName('StockIN', 'clofor_com_cfs__Stock__c');
		RecordType stockOutRecId = getRecIdByName('StockOut', 'clofor_com_cfs__Stock__c');
		Set<Id> idLocators = new Set<Id>();
		for(Stock__c stock: oldStocks) {
			idLocators.add(stock.StockLocator__c);
		}
		Map<Id, LOCATOR__c> mapLocators = new Map<Id, LOCATOR__c>([SELECT
		                                                           Id,
		                                                           ActualOccupiedCapacityCBM__c,
		                                                           ActualOccupiedCapacityKG__c,
		                                                           CurrentOccupiedCapacityCBM__c,
		                                                           CurrentOccupiedCapacityKG__c
		                                                           FROM LOCATOR__c
		                                                           WHERE Id IN: idLocators]);
		for(Stock__c stock: oldStocks) {
			if(!mapLocators.containsKey(stock.StockLocator__c)) {
				continue;
			}

			if(stockInRecId != null &&
			   stockInRecId.Id == stock.RecordTypeId &&
			   stock.StockStatus__c != 'Cancelled') {
				if(stock.Measurement__c != null) {
					if(mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c == null) {
						mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c = 0;
					}
					mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c -= stock.Measurement__c;
				}
				if(stock.GrossWeight__c != null) {
					if(mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c == null) {
						mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c = 0;
					}
					mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c -= stock.GrossWeight__c;
				}
				if(stock.StockStatus__c == 'Completed') {
					if(stock.Measurement__c != null) {
						if(mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c == null) {
							mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c = 0;
						}
						mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c -= stock.Measurement__c;
					}
					if(stock.GrossWeight__c != null) {
						if(mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c == null) {
							mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c = 0;
						}
						mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c -= stock.GrossWeight__c;
					}
				}
			}

			if(stockOutRecId != null &&
			   stockOutRecId.Id == stock.RecordTypeId &&
			   stock.StockStatus__c != 'Cancelled') {
				if(stock.Measurement__c != null) {
					if(mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c == null) {
						mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c = 0;
					}
					mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c += stock.Measurement__c;
				}
				if(stock.GrossWeight__c != null) {
					if(mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c == null) {
						mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c = 0;
					}
					mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c += stock.GrossWeight__c;
				}
				if(stock.StockStatus__c == 'Completed') {
					if(stock.Measurement__c != null) {
						if(mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c == null) {
							mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c = 0;
						}
						mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c += stock.Measurement__c;
					}
					if(stock.GrossWeight__c != null) {
						if(mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c == null) {
							mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c = 0;
						}
						mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c += stock.GrossWeight__c;
					}
				}
			}

			if(mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c < 0) {
				mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityCBM__c = 0;
			}
			if(mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c < 0) {
				mapLocators.get(stock.StockLocator__c).ActualOccupiedCapacityKG__c = 0;
			}
			if(mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c < 0) {
				mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityKG__c = 0;
			}
			if(mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c < 0) {
				mapLocators.get(stock.StockLocator__c).CurrentOccupiedCapacityCBM__c = 0;
			}
		}
		try{
			FlsService.doUpdate(mapLocators.values());
		}catch(Exception ex) {
			oldStocks[0].addError(ex.getMessage());
		}
	}
	private Static RecordType getRecIdByName(String nameRec, String objectName){
		List<RecordType> recRecs = [SELECT Id FROM RecordType WHERE DeveloperName =: nameRec AND SobjectType =: objectName Limit 1];

		if(!recRecs.isEmpty()) {
			return recRecs[0];
		}

		return null;
	}

	public static void rollUpStockInAndOut(List<Stock__c> listNew, Map<Id, Stock__c> mapOld){
        Set<Id> setProductIds = new Set<Id>();
		List<Stock__c> listStock = new List<Stock__c>();
		for (Stock__c item : listNew) {
			if (item.StockStatus__c == 'Completed' && (mapOld == null || mapOld.get(item.Id).StockStatus__c != 'Completed')) {
				listStock.add(item);
				setProductIds.add(item.ProductId__c);
			}
		}
        if (setProductIds.isEmpty()) {
            return;
        }
        Map<Id, Product__c> mapProducts = new Map<Id, Product__c> ([SELECT Id, BillingType__c, RollupStockOut__c, RollupStockIn__c FROM Product__c WHERE Id IN : setProductIds]);

        for(Stock__c item : listStock) {
            Product__c prod = mapProducts.get(item.ProductId__c);
            Decimal amount = prod.BillingType__c == 'Unit' ? item.Quantity__c : item.NetWeight__c;
            amount = amount == null ? 0 : amount;

            if (item.RecordTypeId == Constants.RecordTypeId_Stock_StockIn) {
                prod.RollupStockIn__c = prod.RollupStockIn__c == null ? amount : (prod.RollupStockIn__c + amount);
            }
            else if (item.RecordTypeId == Constants.RecordTypeId_Stock_StockOut) {
                prod.RollupStockOut__c = prod.RollupStockOut__c == null ? amount : (prod.RollupStockOut__c + amount);
            }
        }
		FlsService.doUpdate(mapProducts.values());
	}


	public static void setRecordTypeIdByWosLine(List<Stock__c> listNew) {
		Set<Id> setWosLineId = new Set<Id>();
		List<Stock__c>  listStock= new List<Stock__c>();
		for (Stock__c item : (List<Stock__c>)Trigger.new) {
			if (item.WOSLineID__c != null) {
				listStock.add(item);
				setWosLineId.add(item.WOSLineID__c);
			}
		}

		Map<Id, WosLineItem__c> mapWosLines = new Map<Id, WosLineItem__c>([
			SELECT WorkOrderService__r.RecordTypeId
			FROM WosLineItem__c
			WHERE Id IN: setWosLineId
		]);

		for (Stock__c item : listStock) {
			if (mapWosLines.get(item.WOSLineID__c).WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_Picking) {
				item.RecordTypeId = Constants.RecordTypeId_Stock_StockOut;
			}
			else if (mapWosLines.get(item.WOSLineID__c).WorkOrderService__r.RecordTypeId == Constants.RecordTypeId_Wos_PutAway) {
				item.RecordTypeId = Constants.RecordTypeId_Stock_StockIn;
			}
		}
	}

	public static void autoPopulateFields(List<Stock__c> listNew, Map<Id, Stock__c> mapOld) {
		autoPopulateFields_fromWorkOrder(listNew, mapOld);
		autoPopulateFields_fromProduct(listNew, mapOld);
		autoPopulateFields_fromWos(listNew, mapOld);
		autoPopulateFields_fromLocator(listNew, mapOld);
	}	

	private static void autoPopulateFields_fromWorkOrder(List<Stock__c> listNew, Map<Id, Stock__c> mapOld) {
		Set<Id> setWorkOrder = new Set<Id>();
		List<Stock__c> fromWorkOrder = new List<Stock__c>();
		for (Stock__c item : listNew) {
			if (item.RecordTypeId != Constants.RecordTypeId_Stock_StockIn) {
				continue;
			}
			if ((item.WorkOrderId__c != null && item.DataUpdateMethod__c == 'Automatic' && item.DataPull__c == 'Data Pull From Work Order')
				&& (mapOld == null || 
					mapOld.get(item.Id).WorkOrderId__c != item.WorkOrderId__c ||
					mapOld.get(item.Id).DataUpdateMethod__c != item.DataUpdateMethod__c ||
					mapOld.get(item.Id).DataPull__c != item.DataPull__c
				)
			) {
				setWorkOrder.add(item.WorkOrderId__c);
				fromWorkOrder.add(item);
			}
		}
        if (setWorkOrder.isEmpty()) {
            return;
        }
		Map<Id, WorkOrder__c> mapWorkOrder = new Map<Id, WorkOrder__c>([SELECT Id, Customer__c, ProductId__c, PurchasingOrderId__c, Quantity__c, WarehouseId__c, UnitType__c FROM WorkOrder__c WHERE Id IN :setWorkOrder]);
		for (Stock__c item : fromWorkOrder) {
			WorkOrder__c workOrder = mapWorkOrder.get(item.WorkOrderId__c);
			item.Customer__c = workOrder.Customer__c;
			item.ProductId__c = workOrder.ProductId__c;
			item.PurchasingOrderId__c = workOrder.PurchasingOrderId__c;
			item.Quantity__c = workOrder.Quantity__c;
			item.StockWarehouseID__c = workOrder.WarehouseId__c;
			item.UnitType__c = workOrder.UnitType__c;
		}
	}
	
	private static void autoPopulateFields_fromProduct(List<Stock__c> listNew, Map<Id, Stock__c> mapOld) {
		Set<Id> setProduct = new Set<Id>();
		List<Stock__c> fromProduct  = new List<Stock__c>();
		for (Stock__c item : listNew) {
			if (item.RecordTypeId != Constants.RecordTypeId_Stock_StockIn) {
				continue;
			}
			if (item.ProductId__c != null && (mapOld == null || mapOld.get(item.Id).ProductId__c != item.ProductId__c)) {
				setProduct.add(item.ProductId__c);
				fromProduct.add(item);
			}
		}
        if (setProduct.isEmpty()) {
            return;
        }
		Map<Id, Product__c> mapProduct = new Map<Id, Product__c>([SELECT Id, GoodOwner__c, GrossWeight__c, Measurement__c, NetWeight__c, ProductName__c FROM Product__c WHERE Id IN :setProduct]);
		for (Stock__c item : fromProduct) {
			Product__c product = mapProduct.get(item.ProductId__c);
			item.GoodsOwner__c = product.GoodOwner__c;
			item.GrossWeight__c = product.GrossWeight__c;
			item.Measurement__c = product.Measurement__c;
			item.NetWeight__c = product.NetWeight__c;
			item.ProductName__c = product.ProductName__c;
		}
	}
	
	private static void autoPopulateFields_fromWos(List<Stock__c> listNew, Map<Id, Stock__c> mapOld) {
		Set<Id> setWos = new Set<Id>();
		List<Stock__c> fromWos = new List<Stock__c>();
		for (Stock__c item : listNew) {
			if (item.RecordTypeId != Constants.RecordTypeId_Stock_StockIn) {
				continue;
			}
			if ((item.WorkOrderServiceId__c != null && item.DataUpdateMethod__c == 'Automatic' && item.DataPull__c == 'Data Pull From WORK ORDER SERVICE')
				&& (mapOld == null || 
					mapOld.get(item.Id).WorkOrderServiceId__c != item.WorkOrderServiceId__c ||
					mapOld.get(item.Id).DataUpdateMethod__c != item.DataUpdateMethod__c ||
					mapOld.get(item.Id).DataPull__c != item.DataPull__c
				)
			) {
				setWos.add(item.WorkOrderServiceId__c);
				fromWos.add(item);
			}
		}
        if (setWos.isEmpty()) {
            return;
        }
		Map<Id, WorkOrderService__c> mapWos = new Map<Id, WorkOrderService__c>([SELECT Id, GrossWeightKg__c, Measurement__c, NetWeightKg__c, Locator__c FROM WorkOrderService__c WHERE Id IN :setWos]);
		for (Stock__c item : fromWos) {
			WorkOrderService__c wos = mapWos.get(item.WorkOrderServiceId__c);
			item.GrossWeight__c = wos.GrossWeightKg__c;
			item.Measurement__c = wos.Measurement__c;
			item.NetWeight__c = wos.NetWeightKg__c;
			item.StockLocator__c = wos.Locator__c;
		}
	}
	
	private static void autoPopulateFields_fromLocator(List<Stock__c> listNew, Map<Id, Stock__c> mapOld) {
		Set<Id> setLocator = new Set<Id>();
		List<Stock__c> fromLocator = new List<Stock__c>();
		for (Stock__c item : listNew) {
			if (item.StockLocator__c != null && (mapOld == null || mapOld.get(item.Id).StockLocator__c != item.StockLocator__c)) {
				setLocator.add(item.StockLocator__c);
				fromLocator.add(item);
			}
		}
        if (setLocator.isEmpty()) {
            return;
        }
		Map<Id, Locator__c> mapLocator = new Map<Id, Locator__c>([SELECT Id, WarehouseId__c FROM Locator__c WHERE Id IN :setLocator]);
		for (Stock__c item : fromLocator) {
			Locator__c locator = mapLocator.get(item.StockLocator__c);
			item.StockWarehouseID__c = locator.WarehouseId__c;
		}
	}
}