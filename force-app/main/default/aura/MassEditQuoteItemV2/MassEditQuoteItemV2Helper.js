({
	findFieldCmps : function(cmp) {
        var cmps = cmp.find('field'), formattedCmps = [];
        
        if(!cmps) return {};
        if ($A.util.isArray(cmps)) {
            formattedCmps = cmps;
        } else {
            formattedCmps = [cmps];
        }
        return formattedCmps;
	},
    onSave: function(cmp, changedFields){
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        var cmps = cmp.find('massEditQuoteItemV2'), formattedCmps = [];
        var allRecords = [];
        
        if(!cmps) return;
        if ($A.util.isArray(cmps)) {
            // formattedCmps = cmps;
            for (var i = 0; i < cmps.length; i++) {
                cmps[i].get('v.isShow') && formattedCmps.push(cmps[i]);
            }
        } else {
            // formattedCmps = [cmps];
            cmps.get('v.isShow') && (formattedCmps = [cmps]);
        }       

        for(var i=0; i < formattedCmps.length; i++){
            var record = JSON.parse(JSON.stringify(formattedCmps[i].getFields()));
            if(changedFields){
                for(var j = 0; j < changedFields.length; j++){
                    var fieldName = changedFields[j].key;
                    var value = changedFields[j].value;
                    fieldName && record.isSelected && (record[fieldName] = value);
                }
            }
            allRecords.push(record);
        }
        console.log(allRecords);
        
        var action = cmp.get("c.updateQuoteLines");
		action.setParams({ jsonRecords: JSON.stringify(allRecords) });

		action.setCallback(this, function (response) {
            // if(changedFields) {
                // for(var i=0; i < formattedCmps.length; i++){
                    // var record = JSON.parse(JSON.stringify(formattedCmps[i].getFields()));
                    // record.isSelected && formattedCmps[i].updateFields(changedFields);
                // }
            // }
			// var state = response.getState();
        	// $A.util.toggleClass(spinner, "slds-hide");
			// if (state === "SUCCESS") {
			// }
			// else if (state === "ERROR") {
				// var errors = response.getError();
				// console.log("Error message: " + errors);
			// }
            var state = response.getState();
            $A.util.toggleClass(spinner, "slds-hide");
            if (state === "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response.getReturnValue())));
                if (changedFields) {
                    for (var i = 0; i < formattedCmps.length; i++) {
                        var record = JSON.parse(JSON.stringify(formattedCmps[i].getFields()));
                        record.isSelected && formattedCmps[i].updateFields(changedFields);
                    }
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error", errors);
                var message = "";
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }
                } else {
                    message = "Unknown error";
                }
                console.log("message", message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    message
                });
                toastEvent.fire();
            }
		});
		$A.enqueueAction(action);
    },
    onRefresh: function(cmp, event, helper) {
        var cloneCmp = cmp;
        cloneCmp.set('v.isShow', false);
        window.setTimeout(
            $A.getCallback(function () {
                console.log('refresh...');
                cloneCmp.set('v.isShow', true);
            }), 5000
        );
    },
	onToggleSpinner: function(cmp){
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})