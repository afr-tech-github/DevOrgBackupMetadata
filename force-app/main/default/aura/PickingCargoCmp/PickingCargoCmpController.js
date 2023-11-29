({
    doInit: function(component, event, helper) {
        var columns = helper.getColumns();
        component.set("v.columns", columns);
        var action = component.get("c.getData");

        action.setParams({
            'workOrderProductId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //component.set("v.options", response.getReturnValue());
                if (response.getReturnValue()) {
                    component.set("v.listCargo", response.getReturnValue().cargos);
                    if (response.getReturnValue().requiredQuantity) {
                        component.set("v.maxRowSelect", response.getReturnValue().requiredQuantity);
                    } else {
                        component.set("v.maxRowSelect", 0);
                    }
                    var fields = helper.getFieldLabels();
                    component.set("v.sortedBy", response.getReturnValue().sortedBy);
                    component.set("v.sortedByLabel", fields.get(response.getReturnValue().sortedBy));
                    
                    component.set("v.sortedDirection", response.getReturnValue().sortedDirection);
                    if (response.getReturnValue().wop.clofor_com_cfs__ProductID__r.clofor_com_cfs__InventoryType__c) {

                        component.set("v.inventoryType", response.getReturnValue().wop.clofor_com_cfs__ProductID__r.clofor_com_cfs__InventoryType__c);
                    }
                }

            }
        });
        $A.enqueueAction(action);
    },
    handleSelectAll: function(component, event, helper) {
        var checkboxAll = component.find("selectAll").get("v.checked");
        var checkboxes = component.find("cargoSelect");
        var maxRow = component.get("v.maxRowSelect");
        if (maxRow > checkboxes.length) {
            maxRow = checkboxes.length;
        }
        for (var i = 0; i < maxRow; i++) {
            checkboxes[i].set("v.checked", checkboxAll);
        }
    },
    handlePickingCargo: function(component, event, helper) {
        var checkboxes = component.find("cargoSelect");
        var selectedCargos = [];
        var cargoIds = [];
        
        for (var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].get("v.checked")) {
                var checkboxId = checkboxes[i].get("v.id");
                var idCargo = checkboxId.split("-")[0];
                selectedCargos.push(idCargo);
            }
        }
        if (selectedCargos.length == 0) {
            alert("Please pick 1 cargo at least.");
            return;
        }
        if (selectedCargos.length > component.get("v.maxRowSelect")) {
            alert("Picked cargos number is greater than required number: " + component.get("v.maxRowSelect"));
            return;
        }
        console.log(selectedCargos);
        var action = component.get("c.pickCargos");
        action.setParams({
            'workOrderProductId': component.get("v.recordId"),
            'cargoIdList': selectedCargos,
            'sortedBy': component.get("v.sortedBy"),
            'sortedDirection': component.get("v.sortedDirection")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                
                if (result) {
                    if (result.error) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": response.getReturnValue().error
                        });
                        toastEvent.fire();
                    } else {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Cargos has been picked successfully!"
                        });
                        toastEvent.fire();
                        component.set("v.listCargo", response.getReturnValue().cargos);
                        if (response.getReturnValue().requiredQuantity) {
                            component.set("v.maxRowSelect", response.getReturnValue().requiredQuantity);
                        } else {
                            component.set("v.maxRowSelect", 0);
                        }
                    }
                }

            }
        });
        $A.enqueueAction(action);
    },
    calculateWidth: function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        while (parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        console.log('final tag Name' + parObj.tagName);
        var mouseStart = event.clientX;
        component.set("v.mouseStart", mouseStart);
        component.set("v.oldWidth", parObj.offsetWidth);
    },
    setNewWidth: function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        while (parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart = component.get("v.mouseStart");
        var oldWidth = component.get("v.oldWidth");
        var newWidth = event.clientX - parseFloat(mouseStart) + parseFloat(oldWidth);
        parObj.style.width = newWidth + 'px';
    },
    reOrder: function(component, event, helper) {
		var fieldApi = event.currentTarget.id;
        var sortedDirection = component.get("v.sortedDirection");
        var sortedBy = component.get("v.sortedBy");
        if(fieldApi ==='Product__c' || fieldApi=='Summary__c'){
            return;
        }
        if(sortedBy != fieldApi){
            sortedDirection = 'DESC';
        }
        if(sortedBy == fieldApi){
            if(sortedDirection == 'DESC'){
                sortedDirection = 'ASC';
            }else{
                sortedDirection = 'DESC';
            };
        }
        var action = component.get("c.getData");

        action.setParams({
            'workOrderProductId': component.get("v.recordId"),
            'sortedBy':fieldApi,
            'sortedDirection':sortedDirection
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //component.set("v.options", response.getReturnValue());
                if (response.getReturnValue()) {
                    component.set("v.listCargo", response.getReturnValue().cargos);
                    if (response.getReturnValue().requiredQuantity) {
                        component.set("v.maxRowSelect", response.getReturnValue().requiredQuantity);
                    } else {
                        component.set("v.maxRowSelect", 0);
                    }
                    var fields = helper.getFieldLabels();
                    component.set("v.sortedBy", response.getReturnValue().sortedBy);
                    component.set("v.sortedByLabel", fields.get(response.getReturnValue().sortedBy));
                    
                    component.set("v.sortedDirection", response.getReturnValue().sortedDirection);
                }

            }
        });
        $A.enqueueAction(action);
        
    }
})