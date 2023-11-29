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

	showTasks: function(c, h) {
		var listAllTasks = c.get('v.listAllTasks');
		var taskType = c.get('v.taskType');
		var listTasks = [];
		if (taskType == 'all') {
			listTasks.push(listAllTasks['receiving']);
			listTasks.push(listAllTasks['valueaddedservice']);
			listTasks.push(listAllTasks['putaway']);
			listTasks.push(listAllTasks['picking']);
			listTasks.push(listAllTasks['dispatch']);
		}
		else if (listAllTasks.hasOwnProperty(taskType)){
			listTasks.push(listAllTasks[taskType]);
		} 
		c.set('v.listTasks', listTasks);
		c.set('v.step', 1);
	},
	 
	groupScannedCargo: function (c, h) {
		var lineItems = c.get('v.lineItems');
		var plannedProducts = c.get('v.plannedProducts');
		var items = [];
		if (lineItems && lineItems.length > 0) { 
			var grouped = c.get('v.lineItems').reduce(function (x, item) { 
				console.log(item);
				var key = item.clofor_com_cfs__Cargo__r.clofor_com_cfs__Product__c;
				var plannedProduct = plannedProducts.find(function (p) { return p.clofor_com_cfs__ProductID__c == key});
				console.log(plannedProduct);
				x[key] = x[key] || {
					product: item.clofor_com_cfs__Cargo__r.clofor_com_cfs__Product__r,
					count: 0,
					planned: (plannedProduct != null && plannedProduct.clofor_com_cfs__Quantity__c != null) ? plannedProduct.clofor_com_cfs__Quantity__c : 0
				};
				x[key].count++; 
				return x;
			}, {});
			items = Object.keys(grouped).map(function (key) { return grouped[key] });
		}
		c.set('v.groupedCargoes', {
			total: plannedProducts.reduce((x, y) => x + (y.clofor_com_cfs__Quantity__c || 0), 0),
			items: items
		});
	},
	 
	getRemainQty: function (c, productName) {
		var plannedprod = c.get('v.plannedProducts').find(function (p) { return p.clofor_com_cfs__ProductID__r.Id == productName; });
		var scannedProd = c.get('v.groupedCargoes').items.find(function (p) { return p.product.Id == productName; });

		var plannedQty = (plannedprod && plannedprod.clofor_com_cfs__Quantity__c) ? plannedprod.clofor_com_cfs__Quantity__c : 0;
		var scannedQty = scannedProd ? scannedProd.count : 0;

		return Math.max(0, plannedQty - scannedQty);
    },
    
    processCargo: function (c, h) {
		if (c.get('v.scanMode') === 'product' && !c.get('v.isWeightUnit') && c.get('v.productQuantity') > c.get('v.productMaxQuantity')) {
			return;
		}

		var processServiceIds = []; 
        var addToServiceIds = [];
        var scanMode = c.get('v.scanMode');

		var listRelatedServices = c.get('v.listRelatedServices');
		listRelatedServices.forEach(function (dest) {
			processServiceIds = processServiceIds.concat(dest.records.filter(function (wos) { return wos.isSelected; }).map(function (wos) { return wos.Id; }));
			if (dest.isSelected) {
				addToServiceIds = dest.records.map(function (wos) { return wos.Id; });
			}
		}); 
		h.invokeActionAsync(c, h, 'c.processCargo', {
				ServiceId: c.get('v.selectedService').Id,
				CargoId: scanMode == 'cargo' ? c.get('v.cargoId') : null,
				ProductId: scanMode == 'product' ? c.get('v.productId') : null,
                ProductQuantity: c.get('v.productQuantity'),
                Weight: c.get('v.weight'),
                PlannedWeight: c.get('v.plannedWeight'),
				LocatorId: ['Putaway','Picking'].includes(c.get('v.selectedService').RecordType.DeveloperName) ? (c.get('v.putawayLocatorId') || c.get('v.locatorId')) : c.get('v.locatorId'),
				LocatorCode: ['Putaway','Picking'].includes(c.get('v.selectedService').RecordType.DeveloperName) ? (c.get('v.putawayLocatorCode') || c.get('v.locatorCode')) : c.get('v.locatorCode'),
				WorkerId: c.get('v.workerId'),
				ProcessServiceIds: processServiceIds,
				AddToServiceIds: addToServiceIds,
				ExpireDate: c.get('v.expireDate'),
				LotNumber: c.get('v.lotNumber'),
				status: c.get('v.cargoStatus')
			})
			.then($A.getCallback(function(result) {
				if (c.get('v.scanMode') == 'cargo' || !c.get('v.isWeightUnit')) {
					h.clearCargoForm(c, h);
				} else {
					var mapCargoWeight = c.get('v.mapCargoWeight');
					var idx = mapCargoWeight.findIndex(x=> x.value == c.get('v.plannedWeight'));
					mapCargoWeight[idx].quantity -= c.get('v.productQuantity');
					if (mapCargoWeight[idx].quantity == 0) {
						mapCargoWeight.splice(idx, 1);
						c.set('v.plannedWeight', 0);
						c.set('v.productQuantity', 1);
					}
					else {
						mapCargoWeight[idx].label = `${mapCargoWeight[idx].value}${c.get('v.productUnit')} (Avail:${mapCargoWeight[idx].quantity})`;
						c.set('v.productQuantity', mapCargoWeight[idx].quantity);
					}
					c.set('v.mapCargoWeight', mapCargoWeight);
					c.set('v.weight', 0);
				}
				c.set('v.lineItems', c.get('v.lineItems').concat(result));

				h.groupScannedCargo(c, h);
                
				$A.get("e.force:showToast").setParams({
				    message: 'Cargo scanned successfully',
				    type: "success"
				}).fire();
			}))
			.catch(function(ex) {
                console.error(ex);
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
    },

    clearCargoForm: function (c, h) {
        c.set('v.cargoStatus', 'Completed');
        c.set('v.cargoId', null);
        c.set('v.productId', null);
        c.set('v.productQuantity', 1);
        c.set('v.plannedWeight', 0);
        c.set('v.weight', 0);
        c.set('v.productUnit', null);
		c.set('v.mapCargoWeight', []);
    },
     
    resetUnit: function (c, h) {
        if(c.get('v.isWeightUnit')) {
            c.set('v.productQuantity', 1);
        }
        else {
			let remainQty = h.getRemainQty(c, c.get('v.productId'));
            c.set('v.productQuantity', remainQty);
            c.set('v.productMaxQuantity', remainQty);
        }
        c.set('v.plannedWeight', 0);
        c.set('v.weight', 0);
	},
	
	getWeightBasedCargoes: function (c, h) {
		h.invokeActionAsync(c, h, 'c.getWeightBasedCargoes', {
			serviceId: c.get('v.selectedService').Id,
			productId: c.get('v.scanMode') == 'product' ? c.get('v.productId') : null,
			locatorId: ['Putaway','Picking'].includes(c.get('v.selectedService').RecordType.DeveloperName) ? c.get('v.putawayLocatorId') : c.get('v.locatorId'),
			locatorCode: ['Putaway','Picking'].includes(c.get('v.selectedService').RecordType.DeveloperName) ? c.get('v.putawayLocatorCode') : c.get('v.locatorCode'),
		})
		.then($A.getCallback(function(result) {
			c.set('v.mapCargoWeight', Object.keys(result).map(x => ({
				label: `${x}${c.get('v.productUnit')} (Avail:${result[x].length})`,
				value: x,
				quantity: result[x].length
			})));
			console.log(c.get('v.mapCargoWeight'));
		}))
		.catch(function(ex) {
			console.error(ex);
		});
	}
})