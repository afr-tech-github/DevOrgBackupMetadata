({
	initialization : function(component, event) {
        var actionTranslate = component.get("c.getTranslationMap");
        actionTranslate.setCallback(this, function(response) {
        var state = response.getState();
            //debugger;
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.generalTranslation", response.getReturnValue());
            } else {
                console.log('Problem getting RelatedRecordList, response state: ' + state);
            }
        });
        $A.enqueueAction(actionTranslate);
        
		var action = component.get("c.initDisplay");
        console.log('###recordId##' + component.get("v.recordId"))
        action.setParams({
            "workorderId" : component.get("v.recordId"),
            "printType" : component.get("v.printType"),
            "language" : component.get("v.language"),
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
            	//debugger;
                if(component.isValid() && state === "SUCCESS") {
                   
                    component.set("v.selectedDisplay", response.getReturnValue());
                    component.set("v.language", response.getReturnValue().language);
                    if(response.getReturnValue().customerOptions.length > 0){
                        component.set("v.custommerId", response.getReturnValue().customerOptions[0].value);
                        console.log('###customerId###' + response.getReturnValue().customerOptions[0].value);
                    }
                    
                } else {
                    console.log('Problem getting RelatedRecordList, response state: ' + state);
                }
        });
        $A.enqueueAction(action);
	},
    createAttachment : function(component, event) {
        var recordId = component.get("v.recordId");
        var customerId = component.get("v.custommerId");
        var printType = component.get("v.printType");
        var language = component.get("v.language");
        
        var action = component.get("c.createAttatchment");
        console.log('###recordId##' + component.get("v.recordId"))
        action.setParams({
            "recordId" : recordId,
            "customerId" : customerId,
            "printType" : printType,
            "language" : language,
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                //debugger;
                if(component.isValid() && state === "SUCCESS") {
                   console.log('response state: ' + state);
                    
                } else {
                    console.log('Problem getting RelatedRecordList, response state: ' + state);
                }
        });
        $A.enqueueAction(action);
    }
})