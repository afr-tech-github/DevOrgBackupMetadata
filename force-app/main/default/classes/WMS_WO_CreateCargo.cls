public with sharing class WMS_WO_CreateCargo {
	@AuraEnabled
	public static Object getInfo(Id recordId) {
		List<Map<String, String>> picklistUnit = new List<Map<String, String>>();

		for (PicklistEntry item : Cargo__c.CargoType__c.getDescribe().getPicklistValues()) {
			picklistUnit.add(new Map<String, String>{ 'label' => item.Label, 'value' => item.Value });
		}

		return new Map<String, Object> {
			'workOrder' => (WorkOrder__c)[
				SELECT
					RecordType.Name, RecordType.DeveloperName,
					WarehouseID__c, WarehouseID__r.Name, WarehouseID__r.FacilityName__c,
					DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c,
					(
						SELECT Id, VASServiceType__c, VASRequirement__c, ServiceStage__c, RecordTypeId,
							Warehouse__c, Warehouse__r.Name, Warehouse__r.FacilityName__c,
							DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c
						FROM WorkOrderService__r
					)
				FROM WorkOrder__c
				WHERE Id = :recordId
			],
			'woProducts' => [
				SELECT Id, ProductID__c, NETWeightKG__c, Quantity__c, ShippingTypeAtWarehouse__c, ProductID__r.UnitType__c, ProductID__r.BillingType__c
				FROM ConnectWOProduct__c 
				WHERE WorkOrderID__c = :recordId
			],
			/*'serviceRecordTypes' => [
				SELECT Id, Name, DeveloperName
				FROM RecordType
				WHERE SobjectType = 'clofor_com_cfs__WorkOrderService__c'
			], */
			'picklistUnit' => picklistUnit
		};
	}

	@AuraEnabled
	public static void saveCargos(Id recordId, String payload) {
		DestinationWrapper[] request = (DestinationWrapper[])JSON.deserialize(payload, DestinationWrapper[].class);
		List<Cargo__c> listCargos = new List<SObject>();
		WorkOrder__c wo = [
			SELECT
				RecordType.Name, RecordType.DeveloperName, WarehouseID__c, DestinationWarehouse__c,
				(
					SELECT Id, VASServiceType__c, VASRequirement__c, ServiceStage__c, RecordTypeId, Warehouse__c, DestinationWarehouse__c
					FROM WorkOrderService__r
				)
			FROM WorkOrder__c
			WHERE Id = :recordId
			LIMIT 1
		];

		//Group services into origin and destination services
		//Also group destination services by destination
		List<WorkOrderService__c> origServices = new List<WorkOrderService__c>();
		Map<Id, List<WorkOrderService__c>> destServices = new Map<Id, List<WorkOrderService__c>>();

		for (WorkOrderService__c wos : wo.WorkOrderService__r) {
			if (wos.Warehouse__c  == wo.WarehouseId__c && wos.DestinationWarehouse__c == null) {
				origServices.add(wos);
			}
			else {
				String destinationId = wos.DestinationWarehouse__c == null ? wos.Warehouse__c : wos.DestinationWarehouse__c;
				if (!destServices.containsKey(destinationId)) {
					destServices.put(destinationId, new List<WorkOrderService__c>{ wos });
				}
				else {
					destServices.get(destinationId).add(wos);
				}
			}
		}

		//loop through request then insert cargo
		for (DestinationWrapper dest : request) {
			for (CargoWrapper item : dest.Cargos) {
				item.Records = new Cargo__c[]{};
				for (Integer i = 0; i < item.CargoQty; i++) {
					Cargo__c record = new Cargo__c(
						Product__c = item.ProductId,
						PlannedWeight__c = item.Weight,
						CargoType__c = item.Unit
					);
					listCargos.add(record);
					item.Records.add(record);
				}
			}
		}
        FlsService.doInsert(listCargos);

		List<WosLineItem__c> listWosLineItems = new List<WosLineItem__c>();

		//insert origin service, all cargos will be linked to all orgin services
		for(WorkOrderService__c wos : origServices) {
			for (Cargo__c cargo : listCargos) {
				listWosLineItems.add(new WosLineItem__c(
					Cargo__c = cargo.Id,
					WorkOrderService__c = wos.Id
				));
			}
		}

		//insert destination services, only cargos belong to the same destination will be linked to aforementioned services
		for (DestinationWrapper dest : request) {
			if (dest.DestinationId == wo.WarehouseID__c || !destServices.containsKey(dest.DestinationId)) {
				continue;
			}

			for(WorkOrderService__c wos : destServices.get(dest.DestinationId)) {
				for (CargoWrapper item : dest.Cargos) {
					for (Cargo__c cargo : item.Records) {
						listWosLineItems.add(new WosLineItem__c(
							Cargo__c = cargo.Id,
							WorkOrderService__c = wos.Id,
							CargoStatus__c = 'Planned'
						));
					}
				}
			}
		}

        FlsService.doInsert(listWosLineItems);
	}

	public class DestinationWrapper {
		public String DestinationId { get; set; }
		public CargoWrapper[] Cargos { get; set; }
	}

	public class CargoWrapper {
		public String ProductId { get; set; }
		public Integer ProductQty { get; set; }
		public Integer CargoQty { get; set; }
		public Decimal Weight { get; set; }
		public String Unit { get; set; }
		public String CargoType { get; set; }
		public Cargo__c[] Records { get; set; }
	}
}