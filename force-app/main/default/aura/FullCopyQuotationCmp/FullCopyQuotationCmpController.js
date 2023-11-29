({
	handleCopyData : function(component, event, helper) {
		var action = component.get('c.cloneFull');
		component.set("v.isCopying", true);
        action.setParams({
            "quoteIdSource" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
            	//debugger;
            	component.set("v.isCopying", false);
                if(component.isValid() && state === "SUCCESS") {

                   
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
				    toastEvent.setParams({
				        "title": "Success!",
				        "message": "The record has been copied successfully.",
				        "type" : 'success'
				    });
				    toastEvent.fire();
				    var navEvt = $A.get("e.force:navigateToSObject");
				    navEvt.setParams({
				      "recordId": response.getReturnValue()
				    });
				    navEvt.fire();
                    
                } else {
                	var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
				        "title": "Error!",
				        "message": "Copying the record has been failed.",
				        "type": "error"
				    });
				    toastEvent.fire();
                }
        });
        $A.enqueueAction(action);
	},
	handleCancel : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})