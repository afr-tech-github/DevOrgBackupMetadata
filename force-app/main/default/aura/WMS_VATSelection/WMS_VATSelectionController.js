({
	doInit : function(component, event, helper) {
        helper.initialization(component, event);
	},
	onchangeInvoiceType : function(component, event, helper) {
        helper.initialization(component, event);
	},
	onchangeLanguage : function(component, event, helper) {
        // change language // change printtype option list
        //re-call init display
        //var language = component.get("v.language");
        helper.initialization(component, event);
    },
    handleGenerate : function(component, event, helper){
        var isCreateAttachment = component.get("v.isCreateAttachment");

        var recordId = component.get("v.recordId");
        var invoiceType = component.get("v.invoiceType");
        var groupingType = component.get("v.groupingType");
        var language = component.get("v.language");
        var currencyType = component.get("v.currencyType");
        
        if(isCreateAttachment){
            helper.createAttachment(component, event);
        }
        
        var url = '/apex/clofor_com_cfs__WMS_VATInvoicePDF?invoiceId=' + recordId;
        if(invoiceType.indexOf('DEBIT') !== -1){
            url = '/apex/clofor_com_cfs__WMS_VATInvoiceDebitPDF?invoiceId=' + recordId;
        }else{
            url = '/apex/clofor_com_cfs__WMS_VATInvoicePDF?invoiceId=' + recordId;
        }
        url += '&invoiceType=' + invoiceType;
        url += '&groupingType=' + groupingType;
        url += '&currencyType=' + currencyType;
        url += '&language=' + language;
        debugger;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})