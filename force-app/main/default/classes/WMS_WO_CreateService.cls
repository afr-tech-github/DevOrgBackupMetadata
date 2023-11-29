public with sharing class WMS_WO_CreateService {

	@AuraEnabled
	public static Object getInfo(Id recordId) {
		List<Map<String, String>> picklistVas = new List<Map<String, String>>();

		for (PicklistEntry item : clofor_com_cfs__WorkOrderService__c.clofor_com_cfs__VASServiceType__c.getDescribe().getPicklistValues()) {
			picklistVas.add(new Map<String, String>{ 'label' => item.Label, 'value' => item.Value });
		}

        // Thao start
        List<Map<String, String>> picklistWorker = new List<Map<String, String>>();
        for(ConnectWOSWorker__c worker : [ SELECT Id, Worker__r.Name, Worker__r.EMPLOYEE_ID__c, Worker__r.FULL_NAME__c, Name FROM ConnectWOSWorker__c ]){
            picklistWorker.add(new Map<String, String>{'label' => worker.Worker__r.Name, 'value' => worker.Id});
        }
        // Thao end

		return new Map<String, Object> {
			'workOrder' => (WorkOrder__c)[
				SELECT
					RecordType.Name, RecordType.DeveloperName, WarehouseId__c, DestinationWarehouse__c, 
					(
						SELECT Id, Warehouse__c, DestinationWarehouse__c, VASServiceType__c, VASRequirement__c, Status__c, ServiceStage__c, RecordTypeId FROM WorkOrderService__r
					)
				FROM WorkOrder__c
				WHERE Id = :recordId
			],
			'serviceRecordTypes' => [
				SELECT Id, Name, DeveloperName
				FROM RecordType
				WHERE SobjectType = 'clofor_com_cfs__WorkOrderService__c'
			],
			'picklistVas' => picklistVas,
            'picklistWorker' => picklistWorker
		};
	}

	@AuraEnabled
	public static void deleteServices(List<Id> listServiceIds) {
		try {
			FlsService.doDelete([SELECT Id FROM WorkOrderService__c WHERE Id IN :listServiceIds]);
		}
		catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static void saveServices(Id workOrderId, List<WorkOrderService__c> listServices) {
		try {
			WorkOrder__c wo = [
				SELECT Id, WarehouseId__c, DestinationWarehouse__c
				FROM WorkOrder__c
				WHERE Id = :workOrderId
				LIMIT 1
			];
			List<WorkOrderService__c> listToInsert = new List<WorkOrderService__c>();
			List<WorkOrderService__c> listToUpdate = new List<WorkOrderService__c>();

			for (WorkOrderService__c item : listServices) {
				item.WorkOrder__c = wo.id;
				if (item.Id != null) {
					listToUpdate.add(item);
				}
				else {
					listToInsert.add(item);
				}
			}
			
		    FlsService.doInsert(listToInsert);
		    FlsService.doUpdate(listToUpdate);
		}
		catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
		}
	}
}