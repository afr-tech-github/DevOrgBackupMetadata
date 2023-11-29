({
	onInit : function(c, e, h) {

		h.invokeActionAsync(c, h, 'c.getInfo', { recordId: c.get('v.recordId') })
			.then($A.getCallback(function(result) {
				c.set('v.entWorkOrder', result.workOrder);
				c.set('v.picklistVas', result.picklistVas);

				var mapRecordTypes = {};
				result.serviceRecordTypes.forEach(function (item) { mapRecordTypes[item.DeveloperName] = item; });
				c.set('v.mapRecordTypes', mapRecordTypes);

				try {
					h.createTemplates(c, h);
					h.createServices(c, h);
				}
				catch(ex) {
					console.error(ex);
				}
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},
	doAddDestination: function (c,e,h) {
		h.createDestServices(c,h);
	},
	doSave: function (c,e,h) {
		try {
			var entWorkOrder = c.get('v.entWorkOrder');
			var listServices = c.get('v.listServices');
			var listDestServices = c.get('v.listDestServices');
			var mapRecordTypes = c.get('v.mapRecordTypes');
			var listToDelete = [];
			var listToUpsert = [];
			var stage = 1;
			listServices.forEach(function (item) {
				if (item.isSelected) {
					item.record.clofor_com_cfs__Order__c = stage++;
					listToUpsert.push(item.record);
				}
				else {
					if (item.recordRecordTypeId == mapRecordTypes.ValueAddedService.Id) {
						item.record.clofor_com_cfs__VASServiceType__c = item.record.clofor_com_cfs__VASServiceType__c.join(';');
					}
					if (item.record.Id != null ) {
						listToDelete.push(item.record.Id);
					}
				}
			});
			listDestServices.forEach(function (dest) {
				if (dest.destinationId == null) {
					return;
				}
				var destStage = stage;
				dest.services.forEach(function (item) {
					if (item.isSelected) {
						item.record.clofor_com_cfs__Order__c = destStage++;
						if (item.isDestination) {
							item.record.clofor_com_cfs__Warehouse__c = dest.destinationId;
						}
						else {
							item.record.clofor_com_cfs__DestinationWarehouse__c = dest.destinationId;
						}
						listToUpsert.push(item.record);
					}
					else {
						if (item.recordRecordTypeId == mapRecordTypes.ValueAddedService.Id) {
							item.record.clofor_com_cfs__VASServiceType__c = item.record.clofor_com_cfs__VASServiceType__c.join(';');
						}
						if (item.record.Id != null ) {
							listToDelete.push(item.record.Id);
						}
					}
				});
			});
			console.log(listToUpsert);
			console.log(listToDelete);

			h.invokeActionAsync(c, h, 'c.deleteServices', { listServiceIds: listToDelete })
				.then(function(result) {
					console.log('deleteServices completed');
					return h.invokeActionAsync(c, h, 'c.saveServices', { workOrderId: entWorkOrder.Id, listServices: listToUpsert });
				})
				.then(function(result) {
					console.log('saveServices completed');

					$A.get('e.force:refreshView').fire();
				})
				.catch(function(ex) {
					$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
				});
		}
		catch (ex) {
			console.log(ex);
		}
	}
})