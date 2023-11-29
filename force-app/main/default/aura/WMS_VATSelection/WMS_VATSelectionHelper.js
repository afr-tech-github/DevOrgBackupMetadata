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
            "invoiceId" : component.get("v.recordId"),
            "invoiceType" : component.get("v.invoiceType"),
            "language" : component.get("v.language"),
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
            	//debugger;
                if(component.isValid() && state === "SUCCESS") {
                   
                    component.set("v.selectedDisplay", response.getReturnValue());
                    var a = component.get("v.selectedDisplay");
                    debugger;
                    component.set("v.language", response.getReturnValue().language);
                    /*if(response.getReturnValue().customerOptions.length > 0){
                        component.set("v.custommerId", response.getReturnValue().customerOptions[0].value);
                        console.log('###customerId###' + response.getReturnValue().customerOptions[0].value);
                    }*/
                    
                } else {
                    console.log('Problem getting RelatedRecordList, response state: ' + state);
                }
        });
        $A.enqueueAction(action);
	},
    createAttachment : function(component, event) {
        var recordId = component.get("v.recordId");
        var invoiceType = component.get("v.invoiceType");
        var currencyType = component.get("v.currencyType");
        var language = component.get("v.language");
        var groupingType = component.get("v.groupingType");
        
        var action = component.get("c.createAttatchment");
        console.log('###recordId##' + component.get("v.recordId"))
        action.setParams({
            "recordId" : recordId,
            "invoiceType" : invoiceType,
            "currencyType" : currencyType,
            "language" : language,
            "groupingType" : groupingType
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