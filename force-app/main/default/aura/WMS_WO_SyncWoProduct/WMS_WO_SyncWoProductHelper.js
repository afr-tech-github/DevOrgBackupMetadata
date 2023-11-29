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
    }
})