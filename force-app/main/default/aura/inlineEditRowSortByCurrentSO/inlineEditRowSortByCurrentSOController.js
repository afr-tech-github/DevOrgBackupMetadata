({
    doInit: function(component, event, helper){
        //helper.fetchPickListVal(component, 'clofor_com_cfs__ChargeUnit__c', 'chargeUnitPicklistOpts');
        //helper.fetchPickListVal(component, 'clofor_com_cfs__ContainerSize__c', 'conSizePicklistOpts');
        //helper.fetchPickListVal(component, 'clofor_com_cfs__curr__c', 'currSellingPicklistOpts');
        //helper.fetchPickListVal(component, 'clofor_com_cfs__CurrencyConversionSelling__c', 'currConSellingPicklistOpts');
    	
        //var selectedHeaderCheck = component.get("v.isChecked");
        //component.find("chkEdit").set("v.value", selectedHeaderCheck);
        
    },
    viewRecord: function(component, event, helper) {
        var navEvent = $A.get("e.force:navigateToSObject");
        var idx = event.target.id;
        if (navEvent) {
            navEvent.setParams({
                recordId: idx,
                slideDevName: "detail"
            });
            navEvent.fire();
        }
    },
    handleMenuSelectRecord: function(component, event, helper) {
        //var selectedMenu = event.detail.menuItem.get("v.value");
        var cmpEvent = component.getEvent("handleMenuSelectEvent");
        cmpEvent.setParams({ "ankenParam": event.detail.menuItem.get("v.value") });
        cmpEvent.fire();
    },
    handleChangeCheckbox: function(component, event, helper) {
        var cmpEvent = component.getEvent("handleChangeCheckboxEvent");
        cmpEvent.fire();
    },
    cancelEdit: function(component, event, helper) {
        helper.closeEditMode(component, "");
    },
    // Bill Name at Print(Local)
    inlineEditBillName: function(component, event, helper) {
        helper.closeEditMode(component, "billNameEditMode");
        setTimeout(function() {
            component.find("inputBillName").focus();
        }, 100);
    },
    closeBillNameBox: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        if(chkEdit == false){
            component.set("v.billNameEditMode", false);
        } 
    },
    onBillNameChange: function(component, event, helper) {
        component.set("v.showSaveCancelBtn", true);
    },
    applyBillName: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__InsatuyouSyohin__c",
                "strValue": component.find("inputBillName").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Service Name
    inlineEditServiceName: function(component, event, helper) {
        //component.set("v.serviceNameEditMode", true);
        helper.closeEditMode(component, "serviceNameEditMode");
        component.find("serviceId").set("v.value", 
                                        component.get('v.record.anken.clofor_com_cfs__Tariff__c'));
    },
    handleSelectedEvent: function(component, event, helper) {
        //var selectedId = event.getParam("selectedId");
        //alert(component.find("serviceId").get("v.valueLabel"));
        var serviceNameEditMode = component.get("v.serviceNameEditMode");
        var isCheckedItem = component.get("v.record.isCheck");
        if(serviceNameEditMode && isCheckedItem == false){
            component.set("v.record.anken.clofor_com_cfs__Tariff__c", component.find("serviceId").get("v.value"));
        	component.set("v.record.anken.clofor_com_cfs__Tariff__r.Name", component.find("serviceId").get("v.valueLabel"));
        	component.set("v.serviceNameEditMode", false);
        }
        
        var invoiceToEditMode = component.get("v.invoiceToEditMode");
        if(invoiceToEditMode && isCheckedItem == false){
            component.set("v.record.anken.clofor_com_cfs__Seikyusaki__c", 
                          component.find("invoiceId").get("v.value"));
        	component.set("v.record.anken.clofor_com_cfs__Seikyusaki__r.Name", 
                          component.find("invoiceId").get("v.valueLabel"));
        	component.set("v.invoiceToEditMode", false);
        }
        component.set("v.showSaveCancelBtn", true);
    },
    applyServiceName: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit == false){
            component.set("v.record.anken.clofor_com_cfs__Tariff__c", 
                          component.find("serviceId").get("v.value"));
        	component.set("v.record.anken.clofor_com_cfs__Tariff__r.Name", 
                          component.find("serviceId").get("v.valueLabel"));
        }
        else{
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__Tariff__c",
                "strValue":component.find("serviceId").get("v.value"),
                "strLable":component.find("serviceId").get("v.valueLabel")
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Invoice to
    inlineEditInvoiceTo: function(component, event, helper) {
        //component.set("v.invoiceToEditMode", true);
        helper.closeEditMode(component, "invoiceToEditMode");
        component.find("invoiceId").set("v.value", 
                                        component.get('v.record.anken.clofor_com_cfs__Seikyusaki__c'));
    },
    applyInvoiceTo: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit == false){
            component.set("v.record.anken.clofor_com_cfs__Seikyusaki__c", 
                          component.find("invoiceId").get("v.value"));
        	component.set("v.record.anken.clofor_com_cfs__Seikyusaki__r.Name", 
                          component.find("invoiceId").get("v.valueLabel"));
        }
        else{
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__Seikyusaki__c",
                "strValue":component.find("invoiceId").get("v.value"),
                "strLable":component.find("invoiceId").get("v.valueLabel")
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Charge Quantity
    inlineEditChargeQuantity: function(component, event, helper) {
        //component.set("v.chargeQuantityEditMode", true);
        helper.closeEditMode(component, "chargeQuantityEditMode");
        setTimeout(function() {
            component.find("inputChargeQuantity").focus();
        }, 100);
    },
    closeChargeQuantityBox: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        if(chkEdit == false){
            component.set("v.chargeQuantityEditMode", false);
        } 
    },
    onChargeQuantityChange: function(component, event, helper) {
        component.set("v.showSaveCancelBtn", true);
    },
    applyChargeQuantity: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__Suryo__c",
                "strValue": component.find("inputChargeQuantity").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Charge Unit(Override)
    inlineEditChargeUnit: function(component, event, helper) {
        helper.closeEditMode(component, "chargeUnitEditMode");
        component.find("inputChargeUnit").set("v.value", 
                                             component.get("v.record.anken.clofor_com_cfs__ChargeUnit__c"));
        
    },
    onChargeUnitChange: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        component.set("v.record.anken.clofor_com_cfs__ChargeUnit__c", 
                      	component.find("inputChargeUnit").get("v.value"));
        if(chkEdit == false){          
        	component.set("v.chargeUnitEditMode", false);
        	component.set("v.showSaveCancelBtn", true);
        }
    },
    applyChargeUnit: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__ChargeUnit__c",
                "strValue": component.find("inputChargeUnit").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        else{
            
            component.set("v.record.anken.clofor_com_cfs__ChargeUnit__c", 
                      	component.find("inputChargeUnit").get("v.value"));
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Container Size(Override)
    inlineEditConSize: function(component, event, helper) {
        helper.closeEditMode(component, "conSizeEditMode");
        component.find("inputConSize").set("v.value", 
                                             component.get("v.record.anken.clofor_com_cfs__ContainerSize__c"));
    },
    onConSizeChange: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        component.set("v.record.anken.clofor_com_cfs__ContainerSize__c", 
                      component.find("inputConSize").get("v.value"));
        if(chkEdit == false){          
        	component.set("v.conSizeEditMode", false);
        	component.set("v.showSaveCancelBtn", true);
        }
    },
    applyConSize: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__ContainerSize__c",
                "strValue": component.find("inputConSize").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        else{
            component.set("v.record.anken.clofor_com_cfs__ContainerSize__c", 
                      	component.find("inputConSize").get("v.value"));
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Currency-Selling
    inlineEditCurrSelling: function(component, event, helper) {
        helper.closeEditMode(component, "currSellingEditMode");
        component.find("inputCurrSelling").set("v.value", 
                                             component.get("v.record.anken.clofor_com_cfs__curr__c"));
    },
    onCurrSellingChange: function(component, event, helper) { 
        var chkEdit = component.get("v.record.isCheck");
        component.set("v.record.anken.clofor_com_cfs__curr__c", 
                      component.find("inputCurrSelling").get("v.value"));
        if(chkEdit == false){          
        	component.set("v.currSellingEditMode", false);
        	component.set("v.showSaveCancelBtn", true);
        }
    },
    applyCurrSelling: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__curr__c",
                "strValue": component.find("inputCurrSelling").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        else{
            component.set("v.record.anken.clofor_com_cfs__curr__c", 
                      	component.find("inputCurrSelling").get("v.value"));
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Unit Price of Selling(Local)
    inlineEditUnitLocal: function(component, event, helper) {
        helper.closeEditMode(component, "unitLocalEditMode");
        setTimeout(function() {
            component.find("inputUnitLocal").focus();
        }, 100);
    },
    closeUnitLocalBox: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        if(chkEdit == false){
            component.set("v.unitLocalEditMode", false);
        } 
    },
    onUnitLocalChange: function(component, event, helper) {
        component.set("v.showSaveCancelBtn", true);
    },
    applyUnitLocal: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__SellTankaJPY__c",
                "strValue": component.find("inputUnitLocal").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Unit Price of Selling(FCY)
    inlineEditUnitFCY: function(component, event, helper) {
        //component.set("v.unitFCYEditMode", true);
        helper.closeEditMode(component, "unitFCYEditMode");
        setTimeout(function() {
            component.find("inputUnitFCY").focus();
        }, 100);
    },
    closeUnitFCYBox: function(component, event, helper) { 
        var chkEdit = component.get("v.record.isCheck");
        if(chkEdit == false){
            component.set("v.unitFCYEditMode", false);
        } 
    },
    onUnitFCYChange: function(component, event, helper) {
        component.set("v.showSaveCancelBtn", true);
    },
    applyUnitFCY: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__SellTankaUSD__c",
                "strValue": component.find("inputUnitFCY").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Tax Rate-Selling(%)
    inlineEditTaxSelling: function(component, event, helper) {
        helper.closeEditMode(component, "taxSellingEditMode");
        setTimeout(function() {
            component.find("inputTaxSelling").focus();
        }, 100);
    },
    closeTaxSellingBox: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        if(chkEdit == false){
            component.set("v.taxSellingEditMode", false);
        } 
    },
    onTaxSellingChange: function(component, event, helper) {
        component.set("v.showSaveCancelBtn", true);
    },
    applyTaxSelling: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__TaxInitial__c",
                "strValue": component.find("inputTaxSelling").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Exchange Rate-Selling(Debit)
    inlineEditExDebit: function(component, event, helper) {
        helper.closeEditMode(component, "exDebitEditMode");
        setTimeout(function() {
            component.find("inputExDebit").focus();
        }, 100);
    },
    closeExDebitBox: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        if(chkEdit == false){
            component.set("v.exDebitEditMode", false);
        } 
    },
    onExDebitChange: function(component, event, helper) {
        component.set("v.showSaveCancelBtn", true);
    },
    applyExDebit: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__KawaseSel__c",
                "strValue": component.find("inputExDebit").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Currency Conversion for Selling
    inlineEditCurrConSelling: function(component, event, helper) {
        helper.closeEditMode(component, "currConSellingEditMode");
        component.find("inputCurrConSelling").set("v.value", 
                                             component.get("v.record.anken.clofor_com_cfs__CurrencyConversionSelling__c"));
    },
    onCurrConSellingChange: function(component, event, helper) {
        var chkEdit = component.get("v.record.isCheck");
        component.set("v.record.anken.clofor_com_cfs__CurrencyConversionSelling__c", 
                      component.find("inputCurrConSelling").get("v.value"));
        if(chkEdit == false){          
        	component.set("v.currConSellingEditMode", false);
        	component.set("v.showSaveCancelBtn", true);
        }
    },
    applyCurrConSelling: function(component, event, helper){
        var chkEdit = component.find("chkApply").get("v.value");
        if(chkEdit){
            var cmpEvent = component.getEvent("handleApplyEvent");
        	cmpEvent.setParams({ 
                "strFieldName": "clofor_com_cfs__CurrencyConversionSelling__c",
                "strValue": component.find("inputCurrConSelling").get("v.value"),
                "strLable": ""
            });
        	cmpEvent.fire();
        }
        else{
            component.set("v.record.anken.clofor_com_cfs__CurrencyConversionSelling__c", 
                      	component.find("inputCurrConSelling").get("v.value"));
        }
        component.set("v.showSaveCancelBtn", true);
        helper.closeEditMode(component, "");
    },
    // Invoice S/B Display No
    // Payment to-Buying
    inlineEditPaymentToBuyingEditMode: function(component, event, helper){
        helper.closeEditMode(component, "paymentToBuyingEditMode");
        component.find("inputPaymentToBuying").set("v.value",
            component.get("v.record.anken.clofor_com_cfs__PaymentTo__c"));
    },
    onPaymentToBuyingChange: function (component, event, helper){

    },
    applyPaymentToBuying: function (component, event, helper){

    }
})