({
	invokeActionAsync : function(c, h, actionName, params) {
		return new Promise($A.getCallback(function(resolve, reject) {
            try {
				c.set('v.isLoading', true);
                var action = c.get(actionName);
				if (params != null) {
	                action.setParams(params);
				}
                action.setCallback(this, function (response) {
					c.set('v.isLoading', false);
                    if (response.getState() !== "SUCCESS") {
						console.log(response.getError()[0].message);
                        if (reject)
                            reject(response.getError()[0].message);
                        else
                            console.log(response.getError()[0].message);
                        return;
                    }

                    if (resolve) {
						console.log(response.getReturnValue());
						resolve(response.getReturnValue());
					}
                });

                $A.enqueueAction(action);
            }
            catch (e) {
                console.log(e);
            }
        }));
	},

	createTemplates: function (c) {
		var mapRecordTypes = c.get('v.mapRecordTypes');
		c.set('v.tmplOrig', {
			'Inbound': [
				{ order: 0, stage: 'Inbound-InboundReceiving', label: 'Receiving', recordType: mapRecordTypes['InboundReceiving'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'Inbound-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'Inbound-Putaway', label: 'Put Away', recordType: mapRecordTypes['Putaway'], isSelected: true, isRequired: false }
			],
			'Outbound': [
				{ order: 0, stage: 'Outbound-Picking', label: 'Picking', recordType: mapRecordTypes['Picking'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'Outbound-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'Outbound-OutboundDispatch', label: 'Dispatch', recordType: mapRecordTypes['OutboundDispatch'], isSelected: true, isRequired: true }
			],
			'Transfer': [
				{ order: 0, stage: 'Transfer-Picking', label: 'Picking', recordType: mapRecordTypes['Picking'], isSelected: true, isRequired: false },
				{ order: 1, stage: 'Transfer-ValueAddedService', label: 'VAS - Origin', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
			],
			'CrossDock': [
				{ order: 0, stage: 'CrossDock-InboundReceiving', label: 'Receiving', recordType: mapRecordTypes['InboundReceiving'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'CrossDock-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'CrossDock-OutboundDispatch', label: 'Dispatch', recordType: mapRecordTypes['OutboundDispatch'], isSelected: true, isRequired: true }
			],
			'ExpressCargoTransfer': [
				{ order: 0, stage: 'ExpressCargoTransfer-InboundReceiving', label: 'Receiving - Origin', recordType: mapRecordTypes['InboundReceiving'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'ExpressCargoTransfer-ValueAddedService', label: 'VAS - Origin', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
			],
			'CombinedTransfer': [
				{ order: 0, stage: 'CombinedTransfer-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: true, isRequired: false },
			],
			'ReturnFromCustomer': [
				{ order: 0, stage: 'Inbound-InboundReceiving', label: 'Receiving', recordType: mapRecordTypes['InboundReceiving'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'Inbound-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'Inbound-Putaway', label: 'Put Away', recordType: mapRecordTypes['Putaway'], isSelected: true, isRequired: false }
			],
			'ReturnToVendor': [
				{ order: 0, stage: 'Outbound-Picking', label: 'Picking', recordType: mapRecordTypes['Picking'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'Outbound-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'Outbound-OutboundDispatch', label: 'Dispatch', recordType: mapRecordTypes['OutboundDispatch'], isSelected: true, isRequired: true }
			],
			'Disposal': [
				{ order: 0, stage: 'Outbound-Picking', label: 'Picking', recordType: mapRecordTypes['Picking'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'Outbound-ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'Outbound-OutboundDispatch', label: 'Dispatch', recordType: mapRecordTypes['OutboundDispatch'], isSelected: true, isRequired: true }
			],
			'Relocation': [
				{ order: 0, stage: 'Picking', label: 'Picking', recordType: mapRecordTypes['Picking'], isSelected: true, isRequired: true },
				{ order: 1, stage: 'ValueAddedService', label: 'Value Added Service', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false },
				{ order: 2, stage: 'Putaway', label: 'Putaway', recordType: mapRecordTypes['Putaway'], isSelected: true, isRequired: true }
			]
		});

		c.set('v.tmplDest', {
			'ExpressCargoTransfer': [
				{ order: 2, stage: 'ExpressCargoTransfer-TransferDispatch', label: 'Dispatch - Origin', recordType: mapRecordTypes['TransferDispatch'], isSelected: true, isRequired: true, isDestination: false },
				{ order: 3, stage: 'ExpressCargoTransfer-TransferReceiving', label: 'Receiving - Destination', recordType: mapRecordTypes['TransferReceiving'], isSelected: true, isRequired: true, isDestination: true },
				{ order: 4, stage: 'ExpressCargoTransfer-ValueAddedService-2', label: 'VAS - Destination', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false, isDestination: true },
				{ order: 5, stage: 'ExpressCargoTransfer-OutboundDispatch', label: 'Dispatch - Destination', recordType: mapRecordTypes['OutboundDispatch'], isSelected: true, isRequired: false, isDestination: true }
			],
			'CombinedTransfer': [
				{ order: 1, stage: 'CombinedTransfer-TransferDispatch', label: 'Dispatch - Origin', recordType: mapRecordTypes['TransferDispatch'], isSelected: true, isRequired: true, isDestination: false },
				{ order: 2, stage: 'CombinedTransfer-TransferReceiving', label: 'Receiving - Destination', recordType: mapRecordTypes['TransferReceiving'], isSelected: true, isRequired: true, isDestination: true },
				{ order: 3, stage: 'CombinedTransfer-ValueAddedService-2', label: 'VAS - Destination', recordType: mapRecordTypes['ValueAddedService'], isSelected: true, isRequired: false, isDestination: true },
			],
			'Transfer': [
				{ order: 2, stage: 'Transfer-TransferDispatch', label: 'Dispatch - Origin', recordType: mapRecordTypes['TransferDispatch'], isSelected: true, isRequired: true, isDestination: false },
				{ order: 3, stage: 'Transfer-TransferReceiving', label: 'Receiving - Destination', recordType: mapRecordTypes['TransferReceiving'], isSelected: true, isRequired: false, isDestination: true },
				{ order: 4, stage: 'Transfer-ValueAddedService-2', label: 'VAS - Destination', recordType: mapRecordTypes['ValueAddedService'], isSelected: false, isRequired: false, isDestination: true },
				{ order: 5, stage: 'Transfer-Putaway', label: 'Put Away', recordType: mapRecordTypes['Putaway'], isSelected: true, isRequired: false, isDestination: true }
			]
		});
	},

	createServices: function (c, h) {
		var workOrder = c.get('v.entWorkOrder');
		var tmplOrig = c.get('v.tmplOrig');
		var tmplDest = c.get('v.tmplDest');
		var origWosRecords = [];
		var destWosRecords = [];
		var destWosWrappers = [];

		if (workOrder.clofor_com_cfs__WorkOrderService__r != null && workOrder.clofor_com_cfs__WorkOrderService__r.length > 0) {
			var groupedDestWos = {};
			workOrder.clofor_com_cfs__WorkOrderService__r.forEach(function (wos) {
				if (wos.clofor_com_cfs__DestinationWarehouse__c == null && wos.clofor_com_cfs__Warehouse__c == workOrder.clofor_com_cfs__WarehouseID__c) {
					origWosRecords.push(wos);
				}
				else {
					var destWarehouseId = wos.clofor_com_cfs__DestinationWarehouse__c != null ? wos.clofor_com_cfs__DestinationWarehouse__c : wos.clofor_com_cfs__Warehouse__c;
					if (groupedDestWos[destWarehouseId] == null) {
						groupedDestWos[destWarehouseId] = [];
					}
					groupedDestWos[destWarehouseId].push(wos);
				}
			});
			Object.keys(groupedDestWos).forEach(function (key) {
				destWosRecords.push({
					destinationId: key,
					records: groupedDestWos[key]
				});
			});
		}

		c.set('v.listServices', h.matchServicesToTemplates(tmplOrig[workOrder.RecordType.DeveloperName], origWosRecords, workOrder.clofor_com_cfs__WarehouseID__c));

		if (destWosRecords.length > 0) {
			destWosRecords.forEach(function (destWos) {
				destWosWrappers.push({
					destinationId: destWos.destinationId,
					services: h.matchServicesToTemplates(tmplDest[workOrder.RecordType.DeveloperName], destWos.records, workOrder.clofor_com_cfs__WarehouseID__c, destWos.destinationId)
				});
			});

			c.set('v.listDestServices', destWosWrappers);
		}
		else if (workOrder.clofor_com_cfs__DestinationWarehouse__c != null){
			h.createDestServices(c, h, workOrder.clofor_com_cfs__DestinationWarehouse__c);
		}
		c.set('v.hasDestination', tmplDest[workOrder.RecordType.DeveloperName] != null);
	},

	createDestServices: function (c,h, destinationId) {
		var workOrder = c.get('v.entWorkOrder');
		var tmplDest = c.get('v.tmplDest');
		var destWosWrappers = c.get('v.listDestServices');

		if (tmplDest[workOrder.RecordType.DeveloperName] == null) {
			return;
		}

		destWosWrappers.push({
			destinationId: destinationId,
			services: h.matchServicesToTemplates(tmplDest[workOrder.RecordType.DeveloperName], [], workOrder.clofor_com_cfs__WarehouseID__c, null)
		});

		c.set('v.listDestServices', destWosWrappers);
	},

	matchServicesToTemplates: function (templates, services, warehouseId, destinationId) {
		var result = [];

		templates.forEach(function (item) {
			var matches = services.filter(function (wos) { return wos.clofor_com_cfs__ServiceStage__c == item.stage; });

			if (matches.length == 0) {
				result.push({
					label: item.label,
					record: {
						sobjectType: 'clofor_com_cfs__WorkOrderService__c',
						RecordTypeId: item.recordType.Id,
						clofor_com_cfs__Order__c: item.order,
						clofor_com_cfs__ServiceStage__c: item.stage,
						clofor_com_cfs__Warehouse__c: item.isDestination == true ? destinationId : warehouseId,
						clofor_com_cfs__DestinationWarehouse__c: item.isDestination == true ? null : destinationId
					},
					isSelected: item.isSelected,
					isRequired: item.isRequired,
					isDestination: item.isDestination == true,
				});
			}
			else {
				var record = matches[0];
				if (record.clofor_com_cfs__VASServiceType__c != null) {
					record.clofor_com_cfs__VASServiceType__c = record.clofor_com_cfs__VASServiceType__c.split(';');
				}
				result.push({
					label: item.label,
					record: record,
					isSelected: true,
					isRequired: item.isRequired,
					isDestination: item.isDestination == true,
				});
			}
		});

		return result;
	}

})