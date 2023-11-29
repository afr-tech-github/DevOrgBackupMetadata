({
	doInit: function(component, event, helper) {
        var action = component.get('c.getDataInit');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var dataInit = response.getReturnValue();
                var invoiceType = JSON.parse(dataInit.invoiceType);
                var bankType = JSON.parse(dataInit.bankType);
                component.set("v.invoiceTypeOptions", invoiceType);
                component.set("v.bankTypeOptions", bankType);
                component.find("cbInvoiceType").set("v.value", invoiceType[0].value);
                component.find("cbBankType").set("v.value", bankType[0].value);
                component.set("v.reportName", dataInit.reportName);
                component.set("v.theme", dataInit.theme);
            } else {
            	component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	},
    doGenerate: function(component, event, helper){
        component.set('v.isSuccess', false);
        component.set('v.message', '');
        
        var recordId = component.get("v.recordId");
        var invoiceType = component.find("cbInvoiceType").get("v.value");
        var bankType = component.find("cbBankType").get("v.value");
        var reportName = component.get("v.reportName");

        var pageReport = 'clofor_com_cfs__VATInvoiceExcel';
        if (reportName != null && reportName.length > 0) {
            pageReport = reportName;
        }
        
        var url = '/apex/' + pageReport +'?invoiceId=' + recordId;
        url += '&invoiceType=' + invoiceType;
        url += '&bankType=' + bankType;
        window.open(url, '_blank');
    },
    doClose: function(component, event, helper) {
        if (component.get("v.theme") == 'Theme3') {
            window.close();
        } else {
            var btnClose = $A.get("e.force:closeQuickAction");
            btnClose.fire(); 
        }        
    }
})