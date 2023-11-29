public with sharing class WMS_WO_CombineService {
	@AuraEnabled
	public static Object getInfo(String recordId, String warehouseId) {//only 1 of recordId or warehouseId can have value, if both provided, warehouseId is ignored
		try{
			Map<String, Object> response = new Map<String, Object>();
			String destinationId = null;
			if (!String.isBlank(recordId)) {
				WorkOrder__c wo = [
					SELECT
						RecordType.Name, RecordType.DeveloperName,
						WarehouseID__c, WarehouseID__r.Name, WarehouseID__r.FacilityName__c,
						DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c,
						(
							SELECT Id, VASServiceType__c, VASRequirement__c, ServiceStage__c, RecordTypeId,
								Warehouse__c, Warehouse__r.Name, Warehouse__r.FacilityName__c,
								DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c
							FROM WorkOrderService__r
						),
						(
							SELECT Id
							FROM CombinedWos__r
						)
					FROM WorkOrder__c
					WHERE Id = :recordId
				];
				response.put('workOrder', wo);
				warehouseId = wo.WarehouseID__c;
				destinationId = wo.DestinationWarehouse__c;
			}

			response.put('recordTypeId', Schema.sObjectType.WorkOrder__c.getRecordTypeInfosByDeveloperName().get('CombinedTransfer').getRecordTypeId());
			response.put('listServices', database.query(
				' SELECT Id, ' +
				' 	Warehouse__c, ' +
				'	DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c, ' +
				'	WorkOrder__c, WorkOrder__r.RecordType.Name, WorkOrder__r.Customer__c, WorkOrder__r.Customer__r.Name, WorkOrder__r.Name, ' +
				'	CombinedWorkOrder__c ' +
				'FROM WorkOrderService__c ' +
				'WHERE Status__c IN (\'Created\',\'Planned\',\'Scheduled\') ' +
				'	AND Warehouse__c = :warehouseId ' +
				//(String.isBlank(recordId) ? ' AND CombinedWorkOrder__c = null ' : ' AND CombinedWorkOrder__c = :recordId') +
				(String.isBlank(destinationId) ? ' AND DestinationWarehouse__c != null ' : ' AND DestinationWarehouse__c = :destinationId') +
				'	AND WorkOrder__c != null ' +
				'	AND WorkOrder__r.RecordType.DeveloperName != \'CombinedTransfer\''
			));

			return response;
		}
		catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static void combineService(String recordId, List<String> payload) {
		WorkOrder__c wo = [
			SELECT (
				SELECT Id
				FROM WorkOrderService__r
			)
			FROM WorkOrder__c
			WHERE Id = :recordId
		];

		List<WorkOrderService__c> listWos = [
			SELECT (
				SELECT Cargo__c
				FROM WosLineItem__r
			)
			FROM WorkOrderService__c
			WHERE Id IN :payload
		];

		for (WorkOrderService__c item: listWos) {
			item.CombinedWorkOrder__c = recordId;
		}
		FlsService.doUpdate(listWos);

		List<WosLineItem__c> listWosLineItems = new List<WosLineItem__c>();
		for (WorkOrderService__c targetWos : wo.WorkOrderService__r) {
			for (WorkOrderService__c sourceWos : listWos) {
				for (WosLineItem__c wosLi : sourceWos.WosLineItem__r) {
					listWosLineItems.add(new WosLineItem__c(
						Cargo__c = wosLi.Cargo__c,
						WorkOrderService__c = targetWos.Id,
						CargoStatus__c = 'Planned'
					));
				}
			}
		}

		FlsService.doInsert(listWosLineItems);
	}
}