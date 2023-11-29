({
	onInit : function(c, e, h) {
		h.invokeActionAsync(c, h, 'c.getInfo', { recordId: c.get('v.recordId') })
			.then($A.getCallback(function(result) {
				c.set('v.entWorkOrder', result.workOrder);
				c.set('v.listWoProducts', result.woProducts);
				result.picklistUnit.unshift({ label: 'Choose a cargo type...', value: null});
				c.set('v.picklistUnit', result.picklistUnit);
				/*
				var mapRecordTypes = {};
				result.serviceRecordTypes.forEach(function (item) { mapRecordTypes[item.DeveloperName] = item; });
				c.set('v.mapRecordTypes', mapRecordTypes);
				*/
				try {
					h.loadDestinations(c, h);
				}
				catch(ex) {
					console.error(ex);
				}
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
		
		h.invokeActionAsync(c, h, 'c.getWoProductsByWoId', { recordId: c.get('v.recordId') })
			.then(function(result) {
				c.set('v.listWoProducts', result);
			})
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},
	doRemoveCargo : function(component, event, helper) {
		console.log("removeCargo");
		var recordName = event.getSource().get("v.name");
		var arrIndex = recordName.split("_");
		console.log("recordName:" + recordName);
		var listParent = component.get('v.listDestinations');
		listParent[arrIndex[0]].cargos.splice(arrIndex[1], 1);
		component.set("v.listDestinations", listParent);
	},
	doAddCargo : function(component, event, helper) {
		console.log("addCargo");
		var recordIndex = event.getSource().get("v.name");
		var listParent = component.get('v.listDestinations');
		listParent[recordIndex].cargos.push({ cargoQty:1, weight:0 });
		component.set("v.listDestinations", listParent);
	},
	handleProductChange: function (c, e, h) {
		var [destIdx, cargoIdx] = e.getParam('ref').split("_");
		var listParent = c.get('v.listDestinations');
		var cargo = listParent[destIdx].cargos[cargoIdx];
		cargo.productId = e.getParam('value');
		if (!cargo.productId) {
			cargo.product = cargo.unit = null;
			cargo.weight = 0;
			cargo.cargoQty = 1;
		} else {
			cargo.product = e.getParam('record');
			cargo.unit = cargo.product.UnitType__c;
			var woProduct = (c.get('v.listWoProducts') || []).find(x => x.clofor_com_cfs__ProductID__c === e.getParam('value'));
			if (woProduct) {
				cargo.weight = woProduct.clofor_com_cfs__NETWeightKG__c;
				cargo.cargoQty = woProduct.clofor_com_cfs__Quantity__c;
			}
		}
		c.set('v.listDestinations', listParent);
	},
	doSave: function (c,e,h) {
		h.invokeActionAsync(c, h, 'c.saveCargos', { recordId: c.get('v.recordId'), payload: JSON.stringify(c.get('v.listDestinations')) })
			.then(function(result) {
				console.log('saveCargos completed');
				$A.get('e.force:refreshView').fire();
			})
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	}
})