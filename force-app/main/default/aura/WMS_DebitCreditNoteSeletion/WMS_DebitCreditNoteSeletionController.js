({
	doInit : function(component, event, helper) {
        helper.initialization(component, event);
	},
    onchangeLanguage : function(component, event, helper) {
        // change language // change printtype option list
        //re-call init display
        //var language = component.get("v.language");
        helper.initialization(component, event);
    },
    onchangePrintType : function(component, event, helper){
        helper.initialization(component, event);
    },
    onchangeCustomer : function(component, event, helper) {
        component.set("v.custommerId",component.find('customerSelect').get('v.value'));
    },

    handleGenerate : function(component, event, helper){
        var isCreateAttachment = component.get("v.isCreateAttachment");

        var recordId = component.get("v.recordId");
        var customerId = component.get("v.custommerId");
        var printType = component.get("v.printType");
        var language = component.get("v.language");
        if(isCreateAttachment){
            helper.createAttachment(component, event);
        }
        
        var url = '/apex/clofor_com_cfs__WMS_DebitCreditPDF?workOrderId=' + recordId;
        url += '&customerId=' + customerId;
        url += '&printType=' + printType;
        url += '&language=' + language;
        debugger;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})