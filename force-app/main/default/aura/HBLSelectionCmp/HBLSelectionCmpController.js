/* eslint-disable capitalized-comments */
({
    doInit: function (component, event, helper) {

        var action = component.get("c.isAutoCheckedCreateAttachment");
        action.setParams({
            "id": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response state: ' + state);
                component.set('v.isCreateAttachment', response.getReturnValue());
                component.set('v.isNumber', true);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleGenerate: function (component, event, helper) {
        var isCreateAttachment = component.get("v.isCreateAttachment");
        var isCreateNumber = component.get("v.isNumber");
        var recordId = component.get("v.recordId");
        var billing = component.get("v.billing");
        var customer = component.get("v.customer");

        // if (isCreateAttachment) {
        //     helper.createAttachment(component, event);
        // }

        // eslint-disable-next-line no-console
        console.log("billing: " + billing + ", iscreate: " + isCreateAttachment + ", id: " + recordId + ", customer: " + customer);
        var url =
            "/apex/clofor_com_cfs__PrintHBL?id=" + recordId;

        url += "&billing=" + billing;
        url += "&customer=" + customer;
        url += "&isCreateAttachment=" + isCreateAttachment;
        url += "&isNumber=" + isCreateNumber;
        var urlEvent = $A.get("e.force:navigateToURL");

        // eslint-disable-next-line no-console
        console.log("url: " + url);
        urlEvent.setParams({
            url: url
        });
        urlEvent.fire();
    }
});