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
                        if (reject)
                            reject(response.getError()[0].message);
                        else
                            console.log(response.getError()[0].message);
                        return;
                    }

                    if (resolve) {
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

	getInfo: function (c, h) {
		h.invokeActionAsync(c, h, 'c.getInfo', { recordId: c.get('v.recordId'), warehouseId: c.get('v.warehouseId') })
			.then($A.getCallback(function(result) {
				console.log(result);
				c.set('v.entWorkOrder', result.workOrder);
				c.set('v.recordTypeId', result.recordTypeId);

				try {
					var groupedWos = {};
					result.listServices.forEach(function (wos) {
						if (groupedWos[wos.clofor_com_cfs__DestinationWarehouse__c] == null) {
							groupedWos[wos.clofor_com_cfs__DestinationWarehouse__c] = [];
						}
						wos.isSelected = wos.isDisabled = result.workOrder != null && wos.clofor_com_cfs__CombinedWorkOrder__c == result.workOrder.Id;
						groupedWos[wos.clofor_com_cfs__DestinationWarehouse__c].push(wos);
					});
					c.set('v.listDestinations', Object.keys(groupedWos).map(function (key) {
						return {
							destinationId: key,
							destination: groupedWos[key][0].clofor_com_cfs__DestinationWarehouse__r,
							records: groupedWos[key]
						}
					}));
				}
				catch(ex) {
					console.error(ex);
				}
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	}


})