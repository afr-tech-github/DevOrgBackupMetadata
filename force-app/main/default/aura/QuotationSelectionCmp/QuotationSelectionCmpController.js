({
	doInit : function(component, event, helper) {
		 var languageOptions = [
            { label: "Tiếng Việt", value: "vi"},
            { label: "English", value: "en", selected: "true" },
            { label: "日本語", value: "ja" },
            { label: "中文", value: "zh" },
            { label: "한국어", value: "kr" }
        ];
        component.set("v.languageOptions", languageOptions);
        var action = component.get("c.checkContainerTypeNumber");
        var recordId = component.get("v.recordId");
        //var isTax = component.get("v.isTax");
        //var isAmount = component.get("v.isAmount");
        //var isSum = component.get("v.isSum");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                //debugger;
                if(component.isValid() && state === "SUCCESS") {
                   component.set("v.msg", response.getReturnValue());
                    
                } else {
                    console.log('Problem getting RelatedRecordList, response state: ' + state);
                }
        });
        $A.enqueueAction(action);
	},
	handleGenerate : function(component, event, helper){
        var isCreateAttachment = component.get("v.isCreateAttachment");

        var recordId = component.get("v.recordId");
        // var language = component.get("v.language");
        var language = 'ja';
        var isTax = component.get("v.isTax")
        var isAmount = component.get("v.isAmount");
        var isSum = component.get("v.isSum");
        if(isCreateAttachment){
            helper.createAttachment(component, event);
        }
        
        var url = '/apex/clofor_com_cfs__page_QuotationReportPdf?quoteId=' + recordId;
        // var url = '/apex/clofor_com_cfs__page_QuotationReportMultiCurrencyPdf?quoteId=' + recordId;
        url += '&language=' + language;
        url += '&isTax=' + isTax;
        url += '&isAmount=' + isAmount;
        url += '&isSum=' + isSum;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})