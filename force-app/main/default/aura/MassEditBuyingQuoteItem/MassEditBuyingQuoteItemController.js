({
	init: function(cmp, event, helper) {
		var isFirstRecord = cmp.get('v.isFirstRecord');
        isFirstRecord && cmp.set('v.recordLabelClass', 'slds-form-element__label');
        isFirstRecord && cmp.set('v.fieldLabels', cmp.get('v.parent').get('v.fieldLabels'));
	},
    updateFields: function(cmp, event, helper) {
        var isSelected = cmp.get('v.isSelected');
        if(isSelected){
            isSelected && console.log('update this record: ' + cmp.get('v.id'));
            var params = event.getParam('arguments');
        	var fieldData = JSON.parse(JSON.stringify(params.fields));
        	var fieldNames = fieldData.map(x => x.key);
	        var fieldCmps = helper.findFieldCmps(cmp);
        
            for(var i=0; i < fieldCmps.length; i++){
                var fieldName = fieldCmps[i].get('v.fieldName');
                if(fieldNames.includes(fieldName)){
                    var value = fieldData.find(x => x.key == fieldName).value;
                    fieldCmps[i].set('v.value', value);
                    // break;
                }
            }
        }
	},
    getFields: function(cmp, event, helper) {
        var id = cmp.get('v.id'), isSelected = cmp.get('v.isSelected'), obj = { Id: id, isSelected};
        var fieldCmps = helper.findFieldCmps(cmp);
        
        for(var i=0; i < fieldCmps.length; i++){
            var value = fieldCmps[i].get('v.value');
            var fieldName = fieldCmps[i].get('v.fieldName');
            obj[fieldName] = value;
        }
        return obj;
	},
    refresh: function(cmp, event, helper) {
        var cloneCmp = cmp;
        cloneCmp.set('v.isShow', false);
        window.setTimeout(
            $A.getCallback(function () {
                console.log('refresh...');
                cloneCmp.set('v.isShow', true);
            }), 5000
        );
    },
    onToggleSelect: function(cmp, event, helper){
        var params = event.getParam('arguments');
        cmp.set('v.isSelected', params.isSelected);
    },
    onToggleMultiCurrency: function(cmp, event, helper){
        var params = event.getParam('arguments');
        cmp.set('v.isMultiCurrency', params.isMultiCurrency);
    },
    onSave: function(cmp, event, helper){
        helper.onToggleSpinner(cmp);
    },
    onSubmit: function (cmp, event, helper) {
        helper.onToggleSpinner(cmp);
        event.preventDefault();
        var fields = event.getParam('fields');
        console.log('fields: ', JSON.parse(JSON.stringify(fields)));
        // fields.Street = '32 Prince Street';
        cmp.find('recordEditForm').submit(fields);
    },
    onLoad: function (cmp, event, helper) {
        console.log("onRecordLoad...", cmp.get('v.id'));
        if (!cmp.get("v.firstTimeRecordLoad")) return;
        var fields = event.getParam("recordUi").record.fields;
        var fieldCmps = helper.findFieldCmps(cmp);
        for (var i = 0; i < fieldCmps.length; i++) {
            var fieldName = fieldCmps[i].get('v.fieldName');
            // fieldCmps[i].set('v.value', buyTankaLocal);
        }
    },
    onSuccess: function(cmp, event, helper){
        helper.onToggleSpinner(cmp);
    },
    onError: function(cmp, event, helper){
        helper.onToggleSpinner(cmp);
    },
    onClone: function (cmp, event, helper) {
        
        var isSelected = cmp.get('v.isSelected');
        console.log('isSelected: ',isSelected);
        console.log('cmp: ',cmp);
        if(!isSelected){
            console.log('if isSelected: ',isSelected);
        	var msg = 'Are you sure you want to clone this item?';
        	if (!confirm(msg)) {
            	return;
        	} else {
            	helper.onToggleSpinner(cmp);
            	var cloneQuoteline = cmp.get("c.cloneQuoteline1");
                
            	cloneQuoteline.setParams({ id: cmp.get('v.id') });
            	cloneQuoteline.setCallback(this, function (response) {
                	var state = response.getState();
                	if (state === "SUCCESS") {
                    	var res = JSON.parse(JSON.stringify(response.getReturnValue())) || false;
                        console.log('res :'+res);

                    	if (res) {
                            
                        	cmp.set('v.isShow', true);
                        	var parent = cmp.get('v.parent');
                            
                        	parent.onClone(cmp, event, helper);

                    	}
                	}
                	else if (state === "ERROR") {
                    	var errors = response.getError();
                    	console.log("Error message: " + JSON.stringify(errors));
                	}


            	});
                
            	$A.enqueueAction(cloneQuoteline);

                
        	}

            console.log('cloneQuoteline :'+cloneQuoteline);
        }

        
    },
    onDelete: function (cmp, event, helper) {
        console.log('onDelete');
        var isSelected = cmp.get('v.isSelected');
        console.log('isSelected: ',isSelected);
        if(!isSelected){
            console.log('if isSelected: ',isSelected);
        	var msg = 'Are you sure you want to delete this item?';
        	if (!confirm(msg)) {
            	return;
        	} else {
            	helper.onToggleSpinner(cmp);
            	var deleteQuoteline = cmp.get("c.deleteQuoteline");
            	deleteQuoteline.setParams({ id: cmp.get('v.id') });
            	deleteQuoteline.setCallback(this, function (response) {
                	var state = response.getState();
                	if (state === "SUCCESS") {
                    	var res = JSON.parse(JSON.stringify(response.getReturnValue())) || false;
                    	if (res) {
                        	cmp.set('v.isShow', false);
                        	var parent = cmp.get('v.parent');
                        	parent.onDelete();
                    	}
                	}
                	else if (state === "ERROR") {
                    	var errors = response.getError();
                    	console.log("Error message: " + JSON.stringify(errors));
                	}
                	helper.onToggleSpinner(cmp);
            	});
            	$A.enqueueAction(deleteQuoteline);
        	}
        }
    },
})