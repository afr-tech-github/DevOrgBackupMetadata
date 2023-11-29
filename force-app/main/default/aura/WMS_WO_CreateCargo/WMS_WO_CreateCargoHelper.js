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

	loadDestinations: function (c, h) {
		var workOrder = c.get('v.entWorkOrder');
		var woProducts = c.get('v.listWoProducts');
		var mapDestinations = {};

		if (workOrder.clofor_com_cfs__WorkOrderService__r != null && workOrder.clofor_com_cfs__WorkOrderService__r.length > 0) {
			workOrder.clofor_com_cfs__WorkOrderService__r.forEach(function (wos) {
				if (wos.clofor_com_cfs__DestinationWarehouse__c != null) {
					mapDestinations[wos.clofor_com_cfs__DestinationWarehouse__c] = wos.clofor_com_cfs__DestinationWarehouse__r;
				}
				if (wos.clofor_com_cfs__Warehouse__c != null) {
					mapDestinations[wos.clofor_com_cfs__Warehouse__c] = wos.clofor_com_cfs__Warehouse__r;
				}
			});
		}

		if (Object.keys(mapDestinations).length > 1) {// has destinations, then remove origin
			delete mapDestinations[workOrder.clofor_com_cfs__WarehouseID__c];
		}

		c.set('v.listDestinations', Object.keys(mapDestinations).map(function (key) {
			var item = {
				destinationId: key,
				destination: mapDestinations[key],
				cargos: [{
					weight: 0,
					cargoQty: 1
				}]
			};
			if (key === workOrder.clofor_com_cfs__WarehouseID__c && woProducts && woProducts.length > 0) {
				item.cargos = woProducts.map(function (x) {
					return {
						productId: x.clofor_com_cfs__ProductID__c,
						unit: x.clofor_com_cfs__ProductID__r.clofor_com_cfs__UnitType__c,
						product: {
							BillingType__c: x.clofor_com_cfs__ProductID__r.clofor_com_cfs__BillingType__c
						},
						cargoQty: x.clofor_com_cfs__Quantity__c || 1,
						weight: x.clofor_com_cfs__NETWeightKG__c || 0
					}
				});
			}
			return item;
		}));
	}
})