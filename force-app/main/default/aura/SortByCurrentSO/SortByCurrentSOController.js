({
    doInit: function (component, event, helper){
    }
	/*doInit : function(component, event, helper) {
		component.set("v.shipmentId", component.get("v.recordId"));
        var action = component.get('c.getListAnkenMeisaiByShipment');
        action.setParams({
            "shipmentID": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var lstAnken = response.getReturnValue();
            console.log(lstAnken);
            if (component.isValid() && state === "SUCCESS" && lstAnken != '') {
                component.set("v.listAnken", lstAnken);
                component.find("chkAll").set("v.value", false);
            }
        });
        $A.enqueueAction(action);
	},
    selectAll : function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var lstRecord = component.get("v.listAnken");
        for(var i = 0; i < lstRecord.length; i++){
            if(selectedHeaderCheck == true){
                //component.set("v.isChecked", true);
                lstRecord[i].isCheck = true;
            }else{
                //component.set("v.isChecked", false);
                lstRecord[i].isCheck = false;
            }
        }
        component.set("v.listAnken", lstRecord);
        if(selectedHeaderCheck == true){
            component.set("v.isChecked", true);
        }
    },
    handleChangeCheckbox : function(component, event, helper){
        var lstRecord = component.get("v.listAnken");
        var count = 0;
        for(var i = 0; i < lstRecord.length; i++){
            if(lstRecord[i].isCheck){
                count++;
            }
        }
        if(count > 0){
            component.set("v.isChecked", true);
            //alert("OK" + count);
        }
    },
    apply : function(component, event, helper){
        var strFieldName = event.getParam("strFieldName");
        var strValue = event.getParam("strValue");
        var strLable = event.getParam("strLable");
        var lstRecord = component.get("v.listAnken");
        
        for(var i = 0; i < lstRecord.length; i++){
            if(lstRecord[i].isCheck){
                // Service Name
                if(strFieldName == "clofor_com_cfs__Tariff__c"){
                    lstRecord[i].anken.clofor_com_cfs__Tariff__c = strValue;
                    lstRecord[i].anken.clofor_com_cfs__Tariff__r.Name = strLable;
                }
                // Bill Name at Print(Local)
                else if(strFieldName == "clofor_com_cfs__InsatuyouSyohin__c"){
                    lstRecord[i].anken.clofor_com_cfs__InsatuyouSyohin__c = strValue;
                }
                // Invoice to
                else if(strFieldName == "clofor_com_cfs__Seikyusaki__c"){
                    lstRecord[i].anken.clofor_com_cfs__Seikyusaki__c = strValue;
                    lstRecord[i].anken.clofor_com_cfs__Seikyusaki__r.Name = strLable;
                }
                // Charge Quantity
                else if(strFieldName == "clofor_com_cfs__Suryo__c"){
                    lstRecord[i].anken.clofor_com_cfs__Suryo__c = strValue;
                }
                // Charge Unit(Override)
                else if(strFieldName == "clofor_com_cfs__ChargeUnit__c"){
                    lstRecord[i].anken.clofor_com_cfs__ChargeUnit__c = strValue;
                }
                // Container Size(Override)
                else if(strFieldName == "clofor_com_cfs__ContainerSize__c"){
                    lstRecord[i].anken.clofor_com_cfs__ContainerSize__c = strValue;
                }
                // Currency-Selling
                else if(strFieldName == "clofor_com_cfs__curr__c"){
                    lstRecord[i].anken.clofor_com_cfs__curr__c = strValue;
                }
                // Unit Price of Selling(Local)
                else if(strFieldName == "clofor_com_cfs__SellTankaJPY__c"){
                    lstRecord[i].anken.clofor_com_cfs__SellTankaJPY__c = strValue;
                }
                // Unit Price of Selling(FCY)
                else if(strFieldName == "clofor_com_cfs__SellTankaUSD__c"){
                    lstRecord[i].anken.clofor_com_cfs__SellTankaUSD__c = strValue;
                }
                // Tax Rate-Selling(%)
                else if(strFieldName == "clofor_com_cfs__TaxInitial__c"){
                    lstRecord[i].anken.clofor_com_cfs__TaxInitial__c = strValue;
                }
                // Exchange Rate-Selling(Debit)
                else if(strFieldName == "clofor_com_cfs__KawaseSel__c"){
                    lstRecord[i].anken.clofor_com_cfs__KawaseSel__c = strValue;
                }
                // Currency Conversion for Selling
                else if(strFieldName == "clofor_com_cfs__CurrencyConversionSelling__c"){
                    lstRecord[i].anken.clofor_com_cfs__CurrencyConversionSelling__c = strValue;
                }
            }
        }
        component.set("v.listAnken", lstRecord);
    },
    viewRecord : function(component, event, helper){
        var navEvent = $A.get("e.force:navigateToSObject");
        //var idx = event.target.getAttribute('data-index');
        //var anken = component.get("v.listAnken")[idx];
        var idx = event.target.id;
        if(navEvent){
            navEvent.setParams({
            	recordId: idx,
            	slideDevName: "detail"
            });
            navEvent.fire();
        }
    },
    calculateWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            //parent element traversing to get the TH
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            console.log('final tag Name'+parObj.tagName);
            //to get the position from the left for storing the position from where user started to drag
            var mouseStart=event.clientX; 
            component.set("v.mouseStart",mouseStart);
            component.set("v.oldWidth",parObj.offsetWidth);
    },
    setNewWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            //parent element traversing to get the TH
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = component.get("v.oldWidth");
            //To calculate the new width of the column
            var newWidth = event.clientX - parseFloat(mouseStart) + parseFloat(oldWidth);
            parObj.style.width = newWidth + 'px';//assign new width to column
    },
    handleMenuSelect : function(component, event, helper) {
        var selectedMenu = event.getParam("ankenParam");
        if(selectedMenu.includes('Edit')){
            var ankenId = selectedMenu.replace('Edit', '');
            var navEvent = $A.get("e.force:editRecord");
            if(navEvent){
                navEvent.setParams({
                    "recordId" : ankenId
                });
                navEvent.fire();
            }
        }
        else if(selectedMenu.includes('Delete')){
            var ankenId = selectedMenu.replace('Delete', '');
            var action = component.get('c.deleteAnkenMeisai');
            action.setParams({
                "ankenId": ankenId,
                "shipmentID": component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var lstAnken = response.getReturnValue();
                console.log(lstAnken);
                if (component.isValid() && state === "SUCCESS" && lstAnken != '') {
                    
                    //$A.get("e.force:closeQuickAction").fire();
                    //var toastEvent = $A.get("e.force:showToast");
                    //toastEvent.setParams({
                    //    "title": "Success!",
                    //    "message": "Delete successfully.",
                    //    "type": 'success'
                    //});
                    //toastEvent.fire();
                    
                    component.set("v.listAnken", lstAnken);
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action); 
        }
    },
    //cancel : function(component,event,helper){
    //    $A.get('e.force:refreshView').fire(); 
    //},
    Save : function(component,event,helper){
        component.set('v.loaded', true);
        console.log(component.get("v.listAnken"));
        var action = component.get('c.saveListAnken');
        action.setParams({
            "lstAnken": component.get("v.listAnken")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var lstAnken = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS" && lstAnken != '') {
                component.set("v.listAnken", lstAnken);
                component.set("v.showSaveCancelBtn",false);
                //alert('Updated...');
                component.set('v.loaded', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'success',
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                
            }
        });
        $A.en*/
})