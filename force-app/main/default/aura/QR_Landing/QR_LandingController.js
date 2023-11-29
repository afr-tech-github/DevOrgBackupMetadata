({
	onInit : function(c, e, h) {
	},
	
    onLookupChange : function(c, e, h) {
        c.set(e.getParam('ref'), e.getParam('value'));
	},

    onRender : function(c, e, h) {
        if (c.get('v.step') != 2) {
			return;
		}
		if (c.get('v.scanMode') == 'cargo') {
			if (c.find('step2-cargo').getElement().value) {
				return;
			}
			c.find('step2-cargo').focus();
		}
		else {
			if (c.find('step2-product').getElement().value) {
				return;
			}
			c.find('step2-product').focus();
		}
	},

	doGetTasks : function(c, e, h) {
		var valid = true;
		var workerId = c.get('v.workerId');
		var locatorId = c.get('v.locatorId');
		var locatorCode = c.get('v.locatorCode');
		if (workerId == null || workerId == '') {
			c.find('step0-worker').showError();
			valid = false;
		}
		if (locatorId == null || locatorId == '') {
			c.find('step0-facility').showError();
			valid = false;
		}
		// if (locatorCode == null || locatorCode == '') {
		// 	c.find('step0-facility').showError();
		// 	valid = false;
		// }

		if (!valid) {
			return;
		}

		//f (c.get('v.listAllTasks') == null) {
			h.invokeActionAsync(c, h, 'c.getTasks', { workerId: c.get('v.workerId'), locatorId: c.get('v.locatorId'), locatorCode: c.get('v.locatorCode') })
				.then($A.getCallback(function(result) {
					var tasks = {
						'receiving': {
							'name': 'receiving',
							'label': 'Receiving',
							'cargoStatuses': ['Completed','Not Coming','Missing','Damaged'],
							'records': []
						},
						'valueaddedservice': {
							'name': 'vas',
							'label': 'VAS',
							'cargoStatuses': ['Completed','Damaged'],
							'records': []
						},
						'putaway': {
							'name': 'putaway',
							'label': 'Put away',
							'cargoStatuses': ['Completed','Damaged'],
							'records': []
						},
						'picking': {
							'name': 'picking',
							'label': 'Picking',
							'cargoStatuses': ['Completed','Damaged'],
							'records': []
						},
						'dispatch': {
							'name': 'dispatch',
							'label': 'Dispatch',
							'cargoStatuses': ['Completed','Damaged'],
							'records': []
						}
					}

					Object.keys(tasks).forEach(function (key) {
						tasks[key].filterWo = tasks[key].filterPo = tasks[key].filterSo = '';
						tasks[key].records = tasks[key].filteredRecords = result.filter(function (task) { return task.RecordType.DeveloperName.toLowerCase().indexOf(key) > -1; });
						tasks[key].listWo = [{ label: 'All', value: ''}].concat(tasks[key].records.reduce(function (arr, item) { 
							arr.push({ label: item.clofor_com_cfs__WorkOrder__r.Name, value: item.clofor_com_cfs__WorkOrder__c });
							return arr;
						}, []).sort(function (x, y) { return x > y ? 1 : x == y ? 0 : -1}));
						tasks[key].listPo = [{ label: 'All', value: ''}].concat(tasks[key].records.reduce(function (arr, item) { 
							if (item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__r) {
								arr.push({ label: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__r.Name, value: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__c });
							}
							return arr;
						}, []).sort(function (x, y) { return x > y ? 1 : x == y ? 0 : -1}));
						tasks[key].listSo = [{ label: 'All', value: ''}].concat(tasks[key].records.reduce(function (arr, item) { 
							if (item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderID__r) {
								arr.push({ label: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderID__r.Name, value: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderID__c });
							}
							return arr;
						}, []).sort(function (x, y) { return x > y ? 1 : x == y ? 0 : -1}));
					});

					c.set('v.listAllTasks', tasks);
					h.showTasks(c, h);
				}))
				.catch(function(ex) {
					console.log(ex);
					$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
				});
		// }
		// else {
		// 	h.showTasks(c, h);
		// }
	},

	handleWosFilter: function (c, e, h) {
		var serviceName = e.getSource().get('v.name');
		var serviceGroups = c.get('v.listTasks');
		var serviceGroup = serviceGroups.find(function (item) { return item.name == serviceName});
		console.log(serviceGroup.filterWo, serviceGroup.filterPo, serviceGroup.filterSo);

		serviceGroup.filteredRecords = serviceGroup.records.filter(function (item) {
			return (serviceGroup.filterWo == '' || item.clofor_com_cfs__WorkOrder__c == serviceGroup.filterWo)
				&& (serviceGroup.filterPo == '' || item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__c == serviceGroup.filterPo)
				&& (serviceGroup.filterSo == '' || item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderId__c == serviceGroup.filterSo);
		});

		c.set('v.listTasks', serviceGroups);
	},

	doStartService: function (c, e, h) {
		var selectedItem = e.currentTarget;
    	var recordId = selectedItem.dataset.recordid;
		console.log(recordId);
		c.set("v.wosId",recordId);
		c.set('v.selectedService', null);
        h.clearCargoForm(c, h);

		h.invokeActionAsync(c, h, 'c.startTaskV2', { recordId: e.currentTarget.dataset.recordid})
			.then($A.getCallback(function(result) {
				try {
					//process task
					c.set('v.step', 2);
					c.set('v.selectedService', result.service);
					c.set('v.lineItems', result.service.clofor_com_cfs__WosLineItem__r == null ? [] : result.service.clofor_com_cfs__WosLineItem__r);
					c.set('v.plannedProducts', result.plannedProducts);
					c.set('v.productUnitOptions', result.picklistUnit);
					h.groupScannedCargo(c, h); 
					 
					//forceFocus();
					
					//process related services
					var groupedWos = {};
					result.relatedServices.forEach(function (wos) {
						var destWarehouse = wos.clofor_com_cfs__DestinationWarehouse__c != null ? wos.clofor_com_cfs__DestinationWarehouse__r : wos.clofor_com_cfs__Warehouse__r;

						if (groupedWos[destWarehouse.Id] == null) {
							groupedWos[destWarehouse.Id] = {
								destinationId: destWarehouse.Id,
								destination: destWarehouse,
								isSelected: false,
								records: []
							}
						}

						wos.isSelected = false;
						groupedWos[destWarehouse.Id].records.push(wos);
					});
					var listRelatedServices = Object.keys(groupedWos).map(function (key) { return groupedWos[key]; });
					if (listRelatedServices.length > 0) {
						listRelatedServices[0].isSelected = true;
						c.set('v.listRelatedServices', listRelatedServices);
					}
				}
				catch (ex) {
					console.error(ex);
				}
			}))
			.catch(function(ex) {
				console.log(ex);
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},

	doBack: function (c, e, h) {
		c.set('v.step', c.get('v.step') - 1);
	},

	doFinalize: function (c, e, h) {
		var remaining = c.get('v.selectedService').clofor_com_cfs__InitialQuantity__c - c.get('v.lineItems').length;

		if (remaining > 0) {
			if (!confirm('There are ' + remaining + ' cargo' + (remaining > 1 ? 'es' : '') + ' still need to be scanned. Are you sure you want to finalise?'))
				return;
		}
		if (!confirm('Finalizing this task will prevent any further action. Continue?')) {
			return;
		}
		var relatedServiceIds = [];
		c.get('v.listRelatedServices').forEach(function (dest) {
			relatedServiceIds = relatedServiceIds.concat(dest.records.filter(function (wos) { return wos.isSelected; }).map(function (wos) { return wos.Id; }));
		});
		h.invokeActionAsync(c, h, 'c.finalizeTask', { 
				recordId: c.get('v.selectedService').Id,
				relatedServiceIds: relatedServiceIds
			})
			.then($A.getCallback(function(result) {
				$A.get("e.force:showToast").setParams({
				    message: 'Task "' + c.get('v.selectedService').Name + '" finalized',
				    type: "success"
				}).fire();
				$A.get('e.force:refreshView').fire();
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},

	doSelectDest: function (c, e, h) {
		var listRelatedServices = c.get('v.listRelatedServices');
		console.log(e);
		listRelatedServices.forEach(function (dest) {
			dest.isSelected = dest.destinationId == e.target.dataset.destinationid;
		});
			
		c.set('v.listRelatedServices', listRelatedServices);
	},
	
    onCargoQr_Scan: function (c, e, h) {
		c.set(e.getParam('ref'), e.getParam('value'));
		if (c.get('v.ckbAutoScan') && c.get('v.cargoId') != null) {
			h.processCargo(c, h);
		}
	},
	
    onProductQr_Scan: function (c, e, h) {
		var value = c.find('step2-product').getElement().value;
		console.log(value);
		c.set("v.NameProduct",value);
		if(value == '' || value == null){
			c.set("v.NameUnit",null);
		}
        c.set(e.getParam('ref'), e.getParam('value'));
		c.set('v.isWeightUnit', false);
        h.resetUnit(c, h);
		var record = e.getParam('record');
		if (c.get('v.productId') == null) {
			c.set('v.mapCargoWeight', []);
		}
		else if (!c.get('v.plannedProducts').some(x => x.clofor_com_cfs__ProductID__r.Id === record.Id) || c.get('v.productMaxQuantity') === 0) {
			$A.get("e.force:showToast").setParams({ message: 'Product not in list or maximum quantity exceeded.', type: "error" }).fire();
			setTimeout(() => { 
				c.set('v.productId', null); 
				c.set('v.mapCargoWeight', []); 
			}, 0);
		}
		else if (record && record.BillingType__c == 'Weight') {
			c.set('v.isWeightUnit', true);
			c.set('v.productUnit', record.WeightUnit__c);
			h.getWeightBasedCargoes(c, h);
		}
    },
    
    // onUnit_Change: function (c, e, h) {
	// 	c.set('v.isWeightUnit', ['Kg','g','Ton'].includes(c.get('v.productUnit')));
	// 	h.resetUnit(c, h);
	// 	if (c.get('v.productId') == null) {
	// 		c.set('v.mapCargoWeight', []);
	// 	}
	// 	else if (c.get('v.isWeightUnit')) {
	// 		h.getWeightBasedCargoes(c, h);
	// 	}
	// },

    handleSelectCargoWeight: function (c, e, h) {
		c.set('v.productQuantity', c.get('v.mapCargoWeight').find(x => x.value == c.get('v.plannedWeight')).quantity);
    },

	handleProcessCargo: function (c, e, h) {
        h.processCargo(c, h);
	},

	handleClearForm: function (c, e, h) {
		h.clearCargoForm(c, h);
		setTimeout(() => { c.find('step2-product').focus(); }, 0)
	},

	onCargoStatus_Change: function (c, e, h) {
		var recordId = e.getSource().get('v.name');
		var ents = c.get('v.lineItems');
		var ent = ents.filter(function (x) { return x.Id = recordId })[0];
		ent.clofor_com_cfs__CargoStatus__c = e.getSource().get('v.value');
		c.set('v.lineItems', ents);

		h.invokeActionAsync(c, h, 'c.updateRecord', {
				record: ent,
			})
			.then($A.getCallback(function(result) {
				$A.get("e.force:showToast").setParams({ message: 'Cargo status udpated', type: "success" }).fire();
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},
	getValueFromLwc : function(component, event, helper) {
		var wosId = component.get("v.wosId");
		console.log(wosId);
		var getIdProduct = component.find('step2-product').getElement().value;
		console.log(getIdProduct);
		component.set("v.inputValue",event.getParam('value'));
		var value = component.get("v.inputValue");
		console.log(value);
		var action = component.get("c.getQrCode");
		action.setParams({
			productId: component.find('step2-product').getElement().value,
			valueCode: value,
			wosId: wosId
		})
		action.setCallback(this,function (response){
			var state = response.getState();
			// if(state === "SUCCESS") {
				var res = response.getReturnValue();
				component.set("v.NameUnit",res);
				console.log(res);
			// }
		})
		$A.enqueueAction(action);
	}
})