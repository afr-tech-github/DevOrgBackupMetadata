public with sharing class WMS_QrService {
    /**
    *@author Tan Phan
    *@date 10/08/2019
    *@description retrieve list of WO Service recordtypes
    */
    @AuraEnabled
    public static List<Map<String, String>> getWosRecordTypes(Id workerId, Id locatorId) { 
		List<Map<String, String>> picklist = new List<Map<String, String>>();

		for (RecordType item : [SELECT Name, DeveloperName FROM RecordType WHERE SObjectType = 'clofor_com_cfs__WorkOrderService__c']) {
			picklist.add(new Map<String, String>{ 'label' => item.Name, 'value' => item.DeveloperName });
		}

		return picklist;
	}

    /**
    *@author Tan Phan
    *@date 28/08/2018
    *@description retrieve list of work order ready for work sessions
    */
    @AuraEnabled
    public static Object getTasks(Id workerId, Id locatorId) {
        Set<String> processStatuses = new Set<String>{ 'Resource Assigned', 'On Progress', 'Rescheduled' };

        return [
            SELECT Id
                , Name
                , RecordType.DeveloperName
				, WorkOrder__r.PurchasingOrderID__c, WorkOrder__r.PurchasingOrderID__r.Name
				, WorkOrder__r.SalesOrderId__c, WorkOrder__r.SalesOrderId__r.Name
                , WorkOrder__c, WorkOrder__r.Name
                , Status__c
                , ScheduledStartTime__c
                , ScheduledEndTime__c
                , ActualStartTime__c
                , ActualEndTime__c
            FROM WorkOrderService__c
            WHERE
                Id IN (SELECT WorkOrderService__c FROM ConnectWOSWorker__c WHERE Worker__c = :workerId)
                AND Locator__c = :locatorId
                AND Status__c IN :processStatuses
				AND WorkOrder__c != null
                AND CombinedWorkOrder__c = null
			ORDER BY Name
        ];
    }

	@AuraEnabled
    public static Object startTaskV2(Id recordId) {
		try {
            WorkOrderService__c service = [
                SELECT Id, Name, Status__c, ScheduledStartTime__c, ActualStartTime__c, ActualEndTime__c, RecordType.DeveloperName, InitialQuantity__c, WorkOrder__c,
                    (
                        SELECT Id, Name, CreatedDate, Cargo__r.Name, Cargo__r.ProductDetails__c, IsCargoScanned__c, CargoStatus__c, Cargo__r.Product__r.Summary__c, Cargo__r.Product__r.Name
                        FROM WosLineItem__r
                        WHERE IsCargoScanned__c = true
                        ORDER BY CreatedDate DESC
                    )
                FROM WorkOrderService__c
                WHERE Id = :recordId
            ];

            service.Status__c = 'On Progress';
            if (service.ActualStartTime__c == null) {
                service.ActualStartTime__c = DateTime.now();
            }
			FlsService.doUpdate(service);

			List<Map<String, String>> picklistUnit = new List<Map<String, String>>();

			for (PicklistEntry item : Product__c.WeightUnit__c.getDescribe().getPicklistValues()) {
				picklistUnit.add(new Map<String, String>{ 'label' => item.Label, 'value' => item.Value });
			}

            return new Map<String, Object>{
				'service' => service,
				'relatedServices' => [
					SELECT Id, Name, Status__c, ScheduledStartTime__c, ActualStartTime__c, ActualEndTime__c, RecordType.Name, RecordType.DeveloperName, DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c, Warehouse__c, Warehouse__r.Name, Warehouse__r.FacilityName__c
					FROM WorkOrderService__c
					WHERE WorkOrder__c = :service.WorkOrder__c AND Id != :recordId
				],
				'plannedProducts' => [
					SELECT Id, Quantity__c, ProductID__c, ProductId__r.Name
					FROM ConnectWOProduct__c
					WHERE WorkOrderID__c = :service.WorkOrder__c
				],
				'picklistUnit' => picklistUnit
			};
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
        }
    }

    /**
    *@author Tan Phan
    *@date 23/08/2018
    *@description mark the receiving record as started
    */
    @AuraEnabled
    public static Object startTask(Id wosId) {
        try {
            WorkOrderService__c ent = [
                SELECT Id, Name, ActualStartTime__c, ActualEndTime__c, RecordType.DeveloperName, InitialQuantity__c,
                    (
                        SELECT Id, Name, CreatedDate, Cargo__r.Name, Cargo__r.ProductDetails__c, IsCargoScanned__c, CargoStatus__c, Cargo__r.Product__r.Summary__c
                        FROM WosLineItem__r
                        WHERE IsCargoScanned__c = true
                        ORDER BY CreatedDate DESC
                    )
                FROM WorkOrderService__c
                WHERE Id = :wosId
            ];

            ent.Status__c = 'On Progress';
            if (ent.ActualStartTime__c == null) {
                ent.ActualStartTime__c = DateTime.now();
            }
			FlsService.doUpdate(ent);

            return ent;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
        }
    }

	/**
    *@author Tan Phan
    *@date 23/03/2019
    *@description get the rest of the WOS in the same W/O
    */
    @AuraEnabled
    public static Object getRelatedServices(Id recordId) {
		WorkOrderService__c service = [SELECT Id, WorkOrder__c FROM WorkOrderService__c WHERE Id = :recordId];
        return [
            SELECT Id, Name, Status__c, ScheduledStartTime__c, ActualStartTime__c, ActualEndTime__c, RecordType.Name, RecordType.DeveloperName, DestinationWarehouse__c, DestinationWarehouse__r.Name, DestinationWarehouse__r.FacilityName__c, Warehouse__c, Warehouse__r.Name, Warehouse__r.FacilityName__c
            FROM WorkOrderService__c
            WHERE WorkOrder__c = :service.WorkOrder__c AND Id != :recordId
        ];
    }

    @AuraEnabled
	public static Map<Decimal, List<Id>> getWeightBasedCargoes(Id serviceId, Id productId, Id locatorId) {
		try {
			WorkOrderService__c service = [SELECT Id, WorkOrder__c, WorkOrder__r.RecordType.DeveloperName, Warehouse__c, RecordType.DeveloperName FROM WorkOrderService__c WHERE Id = :serviceId];
			List<Cargo__c> temp = new List<Cargo__c>();
			if (service.RecordType.DeveloperName == 'Picking') {
				temp.addAll([
					SELECT PlannedWeight__c
					FROM Cargo__c
					WHERE LastWosLineItem__r.Locator__c = :locatorId AND LastWosLineItem__r.CargoStatus__c = 'Completed' AND Product__c = :productId AND Product__r.BillingType__c = 'Weight' AND PlannedWeight__c > 0
				]);
			}
			else {
				for(WosLineItem__c item : [
					SELECT Cargo__r.PlannedWeight__c
					FROM WosLineItem__c
					WHERE WorkOrderService__c = :serviceId AND Cargo__r.Product__c = :productId AND IsCargoScanned__c != true AND Cargo__r.Product__r.BillingType__c = 'Weight'  AND Cargo__r.PlannedWeight__c > 0
				]) {
					temp.add(item.Cargo__r);
				}
			}

			Map<Decimal, List<Id>> response = new Map<Decimal, List<Id>>();
			for (Cargo__c item: temp) {
				if (response.containsKey(item.PlannedWeight__c)) {
					response.get(item.PlannedWeight__c).add(item.Id);
				}
				else {
					response.put(item.PlannedWeight__c, new List<Id> { item.Id });
				}
			}
			return response;
		} catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage());
		}
	}

	private static List<Id> processCargo_getCargoes(WorkOrderService__c service, ProcessCargoRequest req) {
		List<Id> cargoes = new List<Id>();
		//if product QR code is scanned
		if (!String.isBlank(req.ProductId)) {
			//if unrestricted picking, then that means no cargo associated to wos yet. need to check cargos in the same locator, up to requested quantity
			if (service.RecordType.DeveloperName == 'Picking' && service.IsRestricted__c != true) {
				cargoes.addAll(new Map<Id, Cargo__c>([
					SELECT Id 
					FROM Cargo__c 
					WHERE 
						LastWosLineItem__r.WorkOrderService__c != :service.Id
						AND LastWosLineItem__r.WorkOrderService__r.RecordType.DeveloperName = 'Putaway'
						AND LastWosLineItem__r.Locator__c = :req.LocatorId 
						AND LastWosLineItem__r.CargoStatus__c = 'Completed' 
						AND Product__c = :req.ProductId 
						AND (Product__r.BillingType__c = 'Unit' OR PlannedWeight__c = :req.PlannedWeight)
					LIMIT :req.ProductQuantity]
				).keySet());
			}
			//else get cargo associated to WOS that is not scanned yet, up to requested quantity
			else {
				for(WosLineItem__c wosLine : ([
					SELECT Id, Cargo__c 
					FROM WosLineItem__c 
					WHERE WorkOrderService__c = :req.ServiceId 
						AND Cargo__r.Product__c = :req.ProductId 
						AND IsCargoScanned__c != true 
						AND (
							WorkOrderService__r.RecordType.DeveloperName != 'Picking' 
							OR (
								Cargo__r.LastWosLineItem__r.WorkOrderService__r.RecordType.DeveloperName = 'Putaway'
								AND Cargo__r.LastWosLineItem__r.Locator__c = :req.LocatorId 
								AND Cargo__r.LastWosLineItem__r.CargoStatus__c = 'Completed' 
							)
						)
						AND (Cargo__r.Product__r.BillingType__c = 'Unit' OR Cargo__r.PlannedWeight__c = :req.PlannedWeight)
					LIMIT :req.ProductQuantity]
				)) {
					cargoes.add(wosLine.Cargo__c);
				}
			}
			//if found quantity is less than requested quantity, throw an error
			if (cargoes.size() < req.ProductQuantity) {
				throw new ApplicationException('Not enough product in stock, requested ' + req.ProductQuantity + ' available ' + cargoes.size());
			}
		}
		//if cargo QR code is scanned
		else if (!String.isBlank(req.CargoId)) {
			List<Cargo__c> temp = [SELECT Id FROM Cargo__c WHERE Id = :req.CargoId];
			if (temp.isEmpty()) {
				throw new ApplicationException('Invalid Cargo QR code. Cargo not found for ' + req.CargoId);
			}

			if (service.RecordType.DeveloperName != 'Picking' && service.IsRestricted__c == true) {
				for(WosLineItem__c wosLine : ([
					SELECT Id, Cargo__c 
					FROM WosLineItem__c 
					WHERE WorkOrderService__c = :req.ServiceId 
						AND Cargo__c = :temp[0].Id
						AND IsCargoScanned__c != true 
				])) {
					cargoes.add(wosLine.Cargo__c);
				}
			}
			else {
				cargoes.add(temp[0].Id);
			}

			if (cargoes.isEmpty()) {
				throw new ApplicationException('Cargo not linked');
			}
		}

		return cargoes;
	}

	public class ProcessCargoRequest {
		@AuraEnabled
		public Id ServiceId { get; set; }
		@AuraEnabled
		public String CargoId { get; set; }
		@AuraEnabled
		public String ProductId { get; set; }
		@AuraEnabled
		public Integer ProductQuantity { get; set; }
		@AuraEnabled
		public Decimal Weight { get; set; }
		@AuraEnabled
		public Decimal PlannedWeight { get; set; }
		@AuraEnabled
		public String Status { get; set; }
		@AuraEnabled
		public Id WorkerId { get; set; }
		@AuraEnabled
		public Id LocatorId { get; set; }
		@AuraEnabled
		public List<Id> ProcessServiceIds { get; set; }
		@AuraEnabled
		public List<Id> AddToServiceIds { get; set; }
		@AuraEnabled
		public Date ExpireDate { get; set; }
		@AuraEnabled
		public String LotNumber { get; set; }

	}

    /**
    *@author Tan Phan
    *@date 09/09/2018
    *@description process cargo
    *@param processServiceIds mark cargo as scan for multiple services
    *@param addToServiceIds add cargo to multiple services, used for picking process where cargo is not linked to the rest of the services until first scanning
    */
    @AuraEnabled
    public static List<WosLineItem__c> processCargo(
		Id ServiceId
		, String CargoId
		, String ProductId
		, Integer ProductQuantity
		, Decimal Weight
		, Decimal PlannedWeight
		, String status
		, Id WorkerId
		, Id LocatorId
		, Date ExpireDate
		, String LotNumber
		, List<Id> ProcessServiceIds
		, List<Id> AddToServiceIds
	) {
			ProcessCargoRequest req = new ProcessCargoRequest();
			req.ServiceId = ServiceId;
			req.CargoId = CargoId;
			req.ProductId = ProductId;
			req.ProductQuantity = ProductQuantity;
			req.Weight = Weight;
			req.PlannedWeight = PlannedWeight;
			req.Status = status;
			req.WorkerId = WorkerId;
			req.LocatorId = LocatorId;
			req.ProcessServiceIds = ProcessServiceIds;
			req.AddToServiceIds = AddToServiceIds;
			req.ExpireDate = ExpireDate;
			req.LotNumber = LotNumber;

			return processCargo_internal(req);
	}

    @TestVisible
    private static List<WosLineItem__c> processCargo_internal(WMS_QrService.ProcessCargoRequest req) {
		WorkOrderService__c service = [
			SELECT Id, WorkOrder__c, WorkOrder__r.RecordType.DeveloperName, Warehouse__c, RecordType.DeveloperName, IsRestricted__c
			FROM WorkOrderService__c 
			WHERE Id = :req.ServiceId
		];
		List<Id> cargoIds = processCargo_getCargoes(service, req); 

		String serviceType = service.RecordType.DeveloperName.toLowerCase();

		List<SObject> listToInsert = new List<SObject>();
		List<SObject> listToUpdate = new List<SObject>();

		//if PICKING, then insert line for the picking and the rest of the services, since this is the starting point, and it's not efficient to specify cargo when planning.
		if (serviceType.contains('picking')) {
			if ([SELECT COUNT() FROM WosLineItem__c WHERE Cargo__c IN :cargoIds AND WorkOrderService__c = :req.ServiceId AND IsCargoScanned__c = true] > 0) {
				throw new ApplicationException('The cargo has already been scanned for this service.');
			}
			//unrestricted picking, worker can pick cargoes from anywhere
			if (!service.IsRestricted__c) {
				for(Id cargoId : cargoIds) {
					listToInsert.add(new WosLineItem__c (
						WorkOrderService__c = service.Id,
						Worker__c = req.WorkerId,
						Locator__c = req.LocatorId,
						Cargo__c = cargoId,
						IsCargoScanned__c = true,
						CargoStatus__c = req.Status,
						ScanTime__c = DateTime.now()
						
					));
				} 
			}

			req.AddToServiceIds = req.AddToServiceIds == null ? new List<Id>() : req.AddToServiceIds;
			for (WorkOrderService__c wos : [
				SELECT Id, DestinationWarehouse__c, Warehouse__c  
				FROM WorkOrderService__c 
				WHERE Id != :service.Id 
					AND WorkOrder__c = :service.WorkOrder__c
					AND (
						Id IN :req.AddToServiceIds 
						OR (Warehouse__c = :service.Warehouse__c AND DestinationWarehouse__c = NULL)
					)
			]) {
				for(Id cargoId : cargoIds) {
					WosLineItem__c newWosLi = new WosLineItem__c (
						WorkOrderService__c = wos.Id,
						Cargo__c = cargoId,
						CargoStatus__c = 'Planned'
					);
					listToInsert.add(newWosLi);
				}
			}
		}
		//if combined dispatch, then update the source dispatches
		else if (service.RecordType.DeveloperName == 'TransferDispatch' && service.WorkOrder__r.RecordType.DeveloperName == 'CombinedTransfer') {
			listToUpdate.addAll([SELECT Id FROM WosLineItem__c WHERE WorkOrderService__r.CombinedWorkOrder__c = :service.WorkOrder__c AND Cargo__c IN :cargoIds]);
		}
		//if combined receiving, then update the source receiving
		else if (service.RecordType.DeveloperName == 'TransferReceiving' && service.WorkOrder__r.RecordType.DeveloperName == 'CombinedTransfer') {
			listToUpdate.addAll([
				SELECT Id
				FROM WosLineItem__c
				WHERE
					WorkOrderService__r.RecordType.DeveloperName = 'TransferReceiving'
					AND WorkOrderService__r.CombinedWorkOrder__c = :service.WorkOrder__c
					AND Cargo__c IN :cargoIds
			]);
		}

		FlsService.doInsert(listToInsert);
		List<WosLineItem__c> response = [SELECT Id, IsCargoScanned__c FROM WosLineItem__c WHERE Cargo__c IN :cargoIds AND WorkOrderService__c = :req.ServiceId];
		listToUpdate.addAll(response);

		for (WosLineItem__c item : (List<WosLineItem__c>)listToUpdate) {
			item.Worker__c = req.WorkerId;
			item.Locator__c = req.LocatorId;
			item.IsCargoScanned__c = true;
			item.CargoStatus__c = req.Status;
			item.ScanTime__c = DateTime.now();
		}
			
		FlsService.doUpdate(listToUpdate);
		listToUpdate.clear();

		//if processing multiple services together
		if (req.ProcessServiceIds != null && !req.ProcessServiceIds.isEmpty()) {
			for (WorkOrderService__c wos : [
				SELECT Id, Locator__c, DestinationWarehouse__c, Warehouse__c, Status__c, ActualStartTime__c , RecordType.DeveloperName, WorkOrder__r.RecordType.DeveloperName
				FROM WorkOrderService__c
				WHERE Id IN :req.ProcessServiceIds
			]) {
				//listToUpdate.addAll(wos.WosLineItem__r);
				//if express cargo, then this list of service to process will at best contain a single combined receiving. hence the following query run only once.
				if (wos.RecordType.DeveloperName == 'TransferReceiving' && wos.WorkOrder__r.RecordType.DeveloperName == 'CombinedTransfer') {
					listToUpdate.addAll([
						SELECT Id
						FROM WosLineItem__c
						WHERE
							WorkOrderService__r.RecordType.DeveloperName = 'TransferReceiving'
							AND WorkOrderService__r.CombinedWorkOrder__c = :service.WorkOrder__c
							AND Cargo__c IN :cargoIds
					]);
				}
			}
			listToUpdate.addAll([
				SELECT Id, WorkOrderService__r.Locator__c
				FROM WosLineItem__c
				WHERE Cargo__c IN :cargoIds
					AND WorkOrderService__c IN :req.ProcessServiceIds
			]);
				
			for(WosLineItem__c item : (List<WosLineItem__c>)listToUpdate) {
				item.Worker__c = req.WorkerId;
				item.Locator__c = item.WorkOrderService__r.Locator__c == null ? req.LocatorId : item.WorkOrderService__r.Locator__c;
				item.IsCargoScanned__c = true;
				item.CargoStatus__c = req.Status;
				item.ScanTime__c = DateTime.now();
				item.Cargo__r.LotNumber__c = req.LotNumber;
			}
		}

		//update current / last known locator of cargo. if dispatched, update to null. :service.Id OR Id IN :req.ProcessServiceIds
		WorkOrderService__c lastService = [SELECT Id FROM WorkOrderService__c WHERE WorkOrder__c = :service.WorkOrder__c AND (ID = :service.Id OR Id IN :req.ProcessServiceIds) ORDER BY Order__c DESC NULLS LAST, CreatedDate DESC LIMIT 1];
		for (WosLineItem__c item : [SELECT Id, Cargo__r.Product__r.BillingType__c, Cargo__r.LastWosLineItem__c, Cargo__r.PlannedWeight__c FROM WosLineItem__c WHERE WorkOrderService__c = :lastService.Id AND Cargo__c IN :cargoIds]) {
			listToUpdate.add(new Cargo__c (
				Id = item.Cargo__r.Id,
				LastWosLineItem__c = item.Id,
				Weight__c = (item.Cargo__r.Product__r.BillingType__c == 'Weight' && req.Weight != null && req.Weight > 0) ? req.Weight : item.Cargo__r.PlannedWeight__c,
				ExpiredDate__c = req.ExpireDate,
				clofor_com_cfs__LotNumber__c = req.LotNumber
			));
		}
		FlsService.doUpdate(listToUpdate);

		return [
			SELECT Id, Name, CreatedDate, Cargo__r.Name, Cargo__r.Product__c, Cargo__r.Product__r.Summary__c, IsCargoScanned__c, Cargo__r.Weight__c
			FROM WosLineItem__c
			WHERE Id IN :(new Map<Id, WosLineItem__c>(response).keySet())
		];
    }

    /**
    *@author Tan Phan
    *@date 23/08/2018
    *@description main purpose is for updating cargo, however can use for anything
    */
    @AuraEnabled
    public static void updateRecord(SObject record) {
        try {
			FlsService.doUpdate(record);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
        }
    }
    /**

    *@author Tan Phan
    *@date 23/08/2018
    *@description mark the service record as completed
    */
    @AuraEnabled
    public static void finalizeTask(Id recordId, List<Id> relatedServiceIds) {
        try {
            WorkOrderService__c service = [SELECT Id, FinalQuantityRollUp__c, DamagedQuantityRollUp__c, Warehouse__c, WorkOrder__c, WorkOrder__r.RecordType.DeveloperName, RecordType.DeveloperName FROM WorkOrderService__c WHERE Id = :recordId];
            List<WorkOrderService__c> listToUpdate = new List<WorkOrderService__c>{ service };

            //if combined dispatch, then update the source dispatches
            if (service.RecordType.DeveloperName == 'TransferDispatch' && service.WorkOrder__r.RecordType.DeveloperName == 'CombinedTransfer') {
                listToUpdate.addAll([SELECT Id, FinalQuantityRollUp__c, DamagedQuantityRollUp__c FROM WorkOrderService__c WHERE CombinedWorkOrder__c = :service.WorkOrder__c]);
            }
            //if combined receiving, then update the source receivings
            if (service.RecordType.DeveloperName == 'TransferReceiving' && service.WorkOrder__r.RecordType.DeveloperName == 'CombinedTransfer') {
                Set<Id> setWoIds = new Set<Id>();
                for (WorkOrderService__c item : [SELECT WorkOrder__c, FinalQuantityRollUp__c, DamagedQuantityRollUp__c FROM WorkOrderService__c WHERE CombinedWorkOrder__c = :service.WorkOrder__c]) {
                    setWoIds.add(item.WorkOrder__c);
                }
                listToUpdate.addAll([
                    SELECT Id
                    FROM WorkOrderService__c
                    WHERE
                        RecordType.DeveloperName = 'TransferReceiving'
                        AND Warehouse__c = :service.Warehouse__c
                        AND WorkOrder__c IN :setWoIds
                ]);
            }
			//if processing multiple services together
			if (relatedServiceIds != null && !relatedServiceIds.isEmpty()) {
                listToUpdate.addAll([SELECT Id, FinalQuantityRollUp__c, DamagedQuantityRollUp__c FROM WorkOrderService__c WHERE Id IN :relatedServiceIds]);
			}

            for (WorkOrderService__c item : listToUpdate) {
                item.Status__c = 'Completed';
                item.ActualEndTime__c = DateTime.now();
                item.FinalQuantity__c = item.FinalQuantityRollUp__c;
                item.DamagedQuantity__c = item.DamagedQuantityRollUp__c;
			}
			
			FlsService.doUpdate(listToUpdate);
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
        }
    }
	
    /*
    *@author Tan Phan
    *@date	18/08/2019	get the list of WO+Product related to a WO of a WOS ID
    */
    @AuraEnabled
    public static Object getWoProductsByWosId(Id wosId) {
		return [
			SELECT 
				Id, Quantity__c, NETWeightKG__c
				, ProductID__c
				, ProductID__r.Name
				, ProductID__r.ProductName__c
				, ProductID__r.Summary__c
			FROM ConnectWOProduct__c
			WHERE WorkOrderID__c IN (SELECT WorkOrder__c FROM WorkOrderService__c WHERE Id = :wosId)
		];
	}
    /*
    *@author Tan Phan
    *@date	18/08/2019	get the list of WO+Cargo related to a WO of a WOS ID
    */
    @AuraEnabled
    public static Object getWoCargoesByWosId(Id wosId) {
		List<WO_Cargo__c> listWoCargoes = new List<WO_Cargo__c>();
		for (WO_Cargo__c item : [
			SELECT Id
				, Cargo__c
				, Cargo__r.Name
				, Cargo__r.Product__c
				, Cargo__r.Summary__c
				, Cargo__r.LotQuantity__c
				, Cargo__r.Weight__c
				, Cargo__r.Product__r.BillingType__c
				, Cargo__r.Product__r.WeightUnit__c
				, (SELECT Id FROM WosLineItems__r WHERE WorkOrderService__c = :wosId AND IsCargoScanned__c = true)
			FROM WO_Cargo__c
			WHERE WorkOrder__c IN (SELECT WorkOrder__c FROM WorkOrderService__c WHERE Id = :wosId)
		]) {
			//only return wo+cargo records that are not yet link to the WOS, or already linked but not yet scanned
			if (item.WosLineItems__r.isEmpty()) {
				listWoCargoes.add(item);
			}
		}

		return listWoCargoes;
	}

    /*
    *@author Tan Phan
    *@date	19/08/2019	
    */
    @AuraEnabled
    public static Object createWoProduct(Id wosId, Id productId) {
		try {
			WorkOrderService__c wos = [SELECT WorkOrder__c FROM WorkOrderService__c WHERE Id = :wosId LIMIT 1];
			List<ConnectWOProduct__c> listExisting = [SELECT Id FROM ConnectWOProduct__c WHERE WorkOrderID__c = :wos.WorkOrder__c AND ProductID__c = :productId];

			if (listExisting.size() > 0) {
				return listExisting[0];
			}

			ConnectWOProduct__c record = new ConnectWOProduct__c(WorkOrderID__c = wos.WorkOrder__c, ProductID__c = productId);
			FlsService.doInsert(record);

			return (ConnectWOProduct__c)[
				SELECT 
					Id, Quantity__c, NETWeightKG__c
					, ProductID__c
					, ProductID__r.Name
					, ProductID__r.ProductName__c
					, ProductID__r.Summary__c
				FROM ConnectWOProduct__c
				WHERE Id = :record.Id 
				LIMIT 1
			];
		} catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
		}
	}

    /*
    *@author Tan Phan
    *@date	20/08/2019	
    */
    @AuraEnabled
    public static Object createCargo(Id wosId, Id productId) {
		try {
			WorkOrderService__c wos = [SELECT WorkOrder__c FROM WorkOrderService__c WHERE Id = :wosId LIMIT 1];
			List<ConnectWOProduct__c> listExisting = [SELECT Id FROM ConnectWOProduct__c WHERE WorkOrderID__c = :wos.WorkOrder__c AND ProductID__c = :productId];

			Cargo__c cargo = new Cargo__c(Product__c = productId);
			FlsService.doInsert(cargo);

			WO_Cargo__c record = new WO_Cargo__c(WorkOrder__c = wos.WorkOrder__c, Cargo__c = cargo.Id);
			FlsService.doInsert(record);

			return (WO_Cargo__c)[
				SELECT Id
					, Cargo__c
					, Cargo__r.Name
					, Cargo__r.Product__c
					, Cargo__r.Summary__c
					, Cargo__r.LotQuantity__c
					, Cargo__r.Weight__c
					, (SELECT Id FROM WosLineItems__r WHERE IsCargoScanned__c = false)
				FROM WO_Cargo__c
				WHERE Id = :record.Id 
				LIMIT 1
			];
		} catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
		}
	}
	
    /*
    *@author Tan Phan
    *@date	20/08/2019	
    */
    @AuraEnabled
    public static Object getCargoDetails(Id wosId, Id cargoId) {
		try {
			WorkOrderService__c wos = [SELECT WorkOrder__c, RecordType.DeveloperName FROM WorkOrderService__c WHERE Id = :wosId LIMIT 1];
			Cargo__c cargo = [
				SELECT Id, LotQuantity__c, Weight__c, ExpiredDate__c, CargoTroubleNote__c
					, Product__c
					, Product__r.BillingType__c
					, Product__r.WeightUnit__c
				FROM Cargo__c 
				WHERE Id = :cargoId 
			];

			if (wos.RecordType.DeveloperName.endsWith('Receiving')) {
				getCargoDetails_Receiving(cargo, wos);
			}

			return cargo;
		} catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ex.getStackTraceString());
		}
	}

	private static Cargo__c getCargoDetails_Receiving(Cargo__c cargo, WorkOrderService__c wos) {
		//if cargo already has quantity/weight updated, then leave as is
		if (cargo.LotQuantity__c > 0  || cargo.Weight__c > 0) {
			return cargo;
		}

		//find all other cargoes linked to same WOS and calculate quantity from WO+Product quantity
		ConnectWOProduct__c woProd = [
			SELECT Id, Quantity__c, NETWeightKG__c
				, (SELECT Cargo__r.LotQuantity__c, Cargo__r.Weight__c FROM WO_Cargoes__r WHERE Cargo__c != :cargo.Id)
			FROM ConnectWOProduct__c
			WHERE WorkOrderID__c = :wos.WorkOrder__c AND ProductId__c = :cargo.Product__c
		];

		cargo.LotQuantity__c = woProd.Quantity__c == null ? 0 : woProd.Quantity__c;
		cargo.Weight__c = woProd.NETWeightKG__c == null ? 0 : woProd.NETWeightKG__c;

		for (WO_Cargo__c item : woProd.WO_Cargoes__r) {
			cargo.LotQuantity__c -= item.Cargo__r.LotQuantity__c == null ? 0 : item.Cargo__r.LotQuantity__c;
			cargo.Weight__c -= item.Cargo__r.Weight__c == null ? 0 : item.Cargo__r.Weight__c;
		}

		cargo.LotQuantity__c = Math.max(0, cargo.LotQuantity__c);
		cargo.Weight__c = Math.max(0, cargo.Weight__c);

		return cargo;
	}

	/*
    * @author Tan Phan
    * @date	21/08/2019
	* @param cargo
	* @param wosLineItem The WOS line item contain cargo status, cargo ID and WOS ID.
    */
    @AuraEnabled
    public static void processCargoV2(Cargo__c cargo, WosLineItem__c wosLineItem, List<Id> optionalWosIds) {
		List<WosLineItem__c> existingWosLineItems = [SELECT Id, WorkOrderService__c FROM WosLineItem__c WHERE WorkOrderService__c = :wosLineItem.WorkOrderService__c AND Cargo__c = :cargo.Id];

		if (!existingWosLineItems.isEmpty()) {
			wosLineItem.Id = existingWosLineItems[0].Id;
		}
		wosLineItem.ScanTime__c = DateTime.now();
		wosLineItem.IsCargoScanned__c = true;

		FlsService.doUpsert(cargo);
		FlsService.doUpsert(wosLineItem);

		if (optionalWosIds != null && !optionalWosIds.isEmpty()) {
			processCargoV2_ProcessOptionalWos(wosLineItem, optionalWosIds);
		}
	}

	private static void processCargoV2_ProcessOptionalWos(WosLineItem__c wosLineItem, List<Id> optionalWosIds) {
		List<WorkOrderService__c> listWos = [SELECT Id, Locator__c FROM WorkOrderService__c WHERE Id IN :optionalWosIds];
		Map<Id, WosLineItem__c> existingWosLineItems = new Map<Id, WosLineItem__c>();

		for(WosLineItem__c item : [SELECT Id, WorkOrderService__c FROM WosLineItem__c WHERE WorkOrderService__c IN :optionalWosIds AND Cargo__c = :wosLineItem.Cargo__c]) {
			existingWosLineItems.put(item.WorkOrderService__c, item);
		}

		List<WosLineItem__c> listWosLineITems = new List<WosLineItem__c>();

		for (WorkOrderService__c wos : listWos) {
			WosLineItem__c wosli = wosLineItem.clone(false, false, false, false); 
			wosli.Id = existingWosLineItems.containsKey(wos.Id) ? existingWosLineItems.get(wos.Id).Id : null;
			wosli.WorkOrderService__c = wos.Id;
			wosli.Locator__c = wos.Locator__c == null ? wosli.WorkOrderService__c : wos.Locator__c;
			listWosLineITems.add(wosli);
		}

		FlsService.doUpsert(listWosLineITems);
	}
	@AuraEnabled
    public static String getQrCode(String productId, String valueCode, String wosId ) {
		System.debug('1234:' + wosId);
		String unitResult = '';
		String unitLevel = '';
		clofor_com_cfs__PRODUCT__c product = [SELECT Id,clofor_com_cfs__UnitLevel1__c,clofor_com_cfs__UnitLevel2__c,clofor_com_cfs__ProductCodeLevel1__c,clofor_com_cfs__ProductCodeLevel2__c from clofor_com_cfs__PRODUCT__c where Id =: productId];
		if(product.clofor_com_cfs__ProductCodeLevel1__c == valueCode){
			unitResult = product.clofor_com_cfs__UnitLevel1__c;
			unitLevel = 'Level 1';
		}else if(product.clofor_com_cfs__ProductCodeLevel2__c == valueCode){
			unitResult = product.clofor_com_cfs__UnitLevel2__c;
			unitLevel = 'Level 2';
		}
		System.debug('1234:'+unitResult);
		String wos = [SELECT clofor_com_cfs__WorkOrder__c from clofor_com_cfs__WorkOrderService__c where Id=: wosId].clofor_com_cfs__WorkOrder__c;
		String productLevel = [select clofor_com_cfs__Product__c from clofor_com_cfs__ConnectWOProduct__c where clofor_com_cfs__WorkOrderID__c =:wos and clofor_com_cfs__ProductID__c =: productId ].clofor_com_cfs__Product__c;
		System.debug('1234:' + productLevel);
		return (unitResult != '' && unitLevel != '') ? unitLevel + ' : ' + unitResult : productLevel;
	}
}