({
    doInit: function(component, event, helper) {
        var action = component.get("c.getUserLanguage");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //debugger;
            component.set("v.isCopying", false);
            if (component.isValid() && state === "SUCCESS") {
                var lang = response.getReturnValue();
                component.set("v.language", response.getReturnValue());
                if ('ja' === lang) {
                    component.set("v.confirmMessage", '案件と請求明細をコピーしますか？');
                    //informMsg = 'コピーが完了しました。確認してください。';
                } else if ('vi' === lang) {
                    //informMsg = 'Copy HBL SHIPMENT đã hoàn tất.';
                    component.set("v.confirmMessage", 'Bạn có muốn copy HBL SHIPMENT này không?');
                } else {
                    //informMsg = 'Copying HBL SHIPMENT completed successfully.';
                    component.set("v.confirmMessage", 'Do you want to copy HBL SHIPMENT?');
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleCopyData: function(component, event, helper) {
        var action = component.get('c.init_lingtning');
        component.set("v.isCopying", true);
        action.setParams({
            "oppoid": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //debugger;
            component.set("v.isCopying", false);
            if (component.isValid() && state === "SUCCESS") {

                var message;
                var lang = component.get("v.language");
                if ('ja' === lang) {

                    message = 'コピーが完了しました。確認してください。';
                } else if ('vi' === lang) {
                    message = 'Copy HBL SHIPMENT đã hoàn tất.';
                } else {
                    message = 'Copying HBL SHIPMENT completed successfully.';
                }

                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": message,
                    "type": 'success'
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
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})