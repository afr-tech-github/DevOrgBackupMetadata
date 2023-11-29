({
	doInit : function(component, event, helper) {
		console.log(component.get('v.recordId'));
        // set list Cargo
		var listCargo = null;
        if(listCargo == null)
            listCargo=[];
        listCargo.push({productId:"", quantity:0});
        // set list Parent
        var listParent = component.get('v.listParent');
        if(listParent == null)
            listParent=[];
        listParent.push({listCargo:listCargo, quantity:0});
        component.set("v.listParent", listParent);
	},
	removeCargo : function(component, event, helper) {
		console.log("removeCargo");
		var recordName = event.getSource().get("v.name");
		var arrIndex = recordName.split("_");
		console.log("recordName:" + recordName);
		var listParent = component.get('v.listParent');
		listParent[arrIndex[0]].listCargo.splice(arrIndex[1], 1);
		component.set("v.listParent", listParent);
	},
	addCargo : function(component, event, helper) {
		console.log("addCargo");
		var recordIndex = event.getSource().get("v.name");
		var listParent = component.get('v.listParent');
		listParent[recordIndex].listCargo.push({productId:"", quantity:0});
		component.set("v.listParent", listParent);
	},
	addParent : function(component, event, helper) {
		console.log("addParent");
		var listCargo=[];
        listCargo.push({productId:"", quantity:0});
		var listParent = component.get('v.listParent');
		listParent.push({listCargo:listCargo, quantity:0});
		component.set("v.listParent", listParent);
	},
	removeParent : function(component, event, helper) {
		console.log("removeParent");
		var listParent = component.get('v.listParent');
		var parentIndex = event.getSource().get("v.name");
		console.log("parentIndex:" + parentIndex);
		listParent.splice(parentIndex, 1);
		component.set("v.listParent", listParent);
	},
    saveCargo : function(component, event, helper){
        var listParent = component.get('v.listParent');
        console.log(listParent);
        var jsonString = JSON.stringify(listParent[0].listCargo);
        helper.invokeActionAsync(component, helper, 'c.createCargo', { jsonStr: jsonString, recId: component.get('v.recordId')  })
			.then($A.getCallback(function(result) {
				try {
                    console.log("result#####");
					console.log(result);
					$A.get("e.force:showToast").setParams({ message: 'Cargo added successfully', type: "info" }).fire();
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