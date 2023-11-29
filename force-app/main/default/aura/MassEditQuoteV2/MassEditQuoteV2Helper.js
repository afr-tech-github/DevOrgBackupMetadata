({
    initData: function (cmp) {
        var thisHelper = this;
        var cloneCmp = cmp;
        var getAllQuoteLines = cmp.get("c.getAllQuoteLines");
        getAllQuoteLines.setParams({ quoteId: cmp.get("v.recordId")});
        getAllQuoteLines.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = JSON.parse(JSON.stringify(response.getReturnValue())) || [];
                var cmpParam = [];
                console.log("From server list quote line: ", res);
                cmp.set('v.numberOfDisplayRecord', res.length);
                for (var i = 0; i < res.length; i++) {
                    const quoteLine = res[i], isFirstRecord = i == 0;
                    window.setTimeout(
                        $A.getCallback(function () {
                            thisHelper.createComponent(cloneCmp, quoteLine, isFirstRecord);
                        }), i * 100
                    );
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors);
            }
        });
        $A.enqueueAction(getAllQuoteLines);
    },
	createComponent : function(cloneCmp, quoteLine, isFirstRecord) {
        var isRoute = cloneCmp.get('v.isRoute');

		$A.createComponent(
            "c:MassEditQuoteItemV2", 
            { id: quoteLine.Id, 'aura:id': 'massEditQuoteItemV2',isRoute, isFirstRecord, parent: cloneCmp},
             (massEditQuoteItemV2, status, errorMessage) => {
                 if (status === "SUCCESS") {
                     var body = cloneCmp.get("v.body");
                     body.push(massEditQuoteItemV2);
                     cloneCmp.set("v.body", body);
            	}
                     else if (status === "INCOMPLETE") {
                     console.log("No response from server or client is offline.")
                }
             	else if (status === "ERROR") {
                	console.log("Error: " + errorMessage);
                }
            }
        );
	},
    onToggleSelect: function(cmp, isSelected){
        var cmps = cmp.find('massEditQuoteItemV2'), formattedCmps = [];
        var allRecords = [];
        
        if(!cmps) return;
        if ($A.util.isArray(cmps)) {
            formattedCmps = cmps;
        } else {
            formattedCmps = [cmps];
        }
        for(var i=0; i < formattedCmps.length; i++){
            console.log(formattedCmps[i].get('v.id'), ' ', formattedCmps[i].get('v.isShow'));
            formattedCmps[i].onToggleSelect(isSelected);
        }
    },
    onToggleMultiCurrency: function(cmp, isMultiCurrency){
        var cmps = cmp.find('massEditQuoteItemV2'), formattedCmps = [];
        var allRecords = [];
        
        if(!cmps) return;
        if ($A.util.isArray(cmps)) {
            formattedCmps = cmps;
        } else {
            formattedCmps = [cmps];
        }
        for(var i=0; i < formattedCmps.length; i++){
            formattedCmps[i].onToggleMultiCurrency(isMultiCurrency);
        }
    },
    onToggleRoute: function(cmp, isRoute){
        var cmps = cmp.find('massEditQuoteItemV2'), formattedCmps = [];
        var allRecords = [];
        console.log('1234:' + isRoute);
        if(!cmps) return;
        if ($A.util.isArray(cmps)) {
            formattedCmps = cmps;
        } else {
            formattedCmps = [cmps];
        }
        for(var i=0; i < formattedCmps.length; i++){
            formattedCmps[i].onToggleRoute(isRoute);
        }
        console.log('1234:' + isRoute);
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
    onRefresh1: function (cmp, event, helper) { 
        var cmps = cmp.find('massEditQuoteItemV2');
        if ($A.util.isArray(cmps)) {
            for (var i = 0; i < cmps.length; i++) {
                console.log('Zzzzzzz');
                cmps[i].set('v.isShow', false);
            }
            
        } else {
            cmps.set('v.isShow', false);
        }
        console.log('jjjjjjjj');
        cmp.set('v.isShowTable', false);
        cmp.set('v.body', []);
        cmp.set('v.isShowTable', true);

        var thisHelper = this;
        var cloneCmp = cmp;
        var getAllQuoteLines = cmp.get("c.getAllQuoteLines1");
        getAllQuoteLines.setParams({ quoteId: cmp.get("v.recordId")});
        getAllQuoteLines.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = JSON.parse(JSON.stringify(response.getReturnValue())) || [];
                console.log('Jsonnnn'+response.getReturnValue());
        
                console.log("From server list quote line: ", res);
                cmp.set('v.numberOfDisplayRecord', res.length);
                
                for (var i = 0; i < res.length; i++) {
                    const quoteLine = res[i], isFirstRecord = i == 0;
                    window.setTimeout(
                        $A.getCallback(function () {
                            thisHelper.createComponent(cloneCmp, quoteLine, isFirstRecord);
                        }), i * 100
                    );
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors);
            }
        });
        
        $A.enqueueAction(getAllQuoteLines);
      
    },
	onToggleSpinner: function(cmp){
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})