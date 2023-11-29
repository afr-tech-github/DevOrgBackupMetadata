({
    doinit : function(component, event, helper) {
		console.log("run");
        // var cb = component.find("check").get("v.value");
        //get the account List from component  
        var billList = component.get("v.billList");
        // component.set('v.showMassUpdateRow', true);

        //Add New Account Record
        
        billList.push({
            'sobjectType': 'clofor_com_cfs__QuoteLine__c',
            'clofor_com_cfs__ServicePricingID__c': '',
            'clofor_com_cfs__Print__c': true,
            'clofor_com_cfs__Quantity__c': '',
            'clofor_com_cfs__ChargeUnit__c': '',
            'clofor_com_cfs__ContainerType__c': '', 
            'clofor_com_cfs__CurrencySelling__c': '', 
            'clofor_com_cfs__SellingListPriceLocal__c': '', 
            'clofor_com_cfs__SellingListPriceUSD__c': '', 
            'clofor_com_cfs__TaxRate__c': '', 
            'clofor_com_cfs__Remarks__c': '', 
            
        });
        component.set("v.billList", billList);

        
        console.log('billList:' + JSON.stringify(billList));

	},

    addRow: function(component, event, helper) {
        console.log("run");
        // var cb = component.find("check").get("v.value");
        //get the account List from component  
        var billList = component.get("v.billList");
        // component.set('v.showMassUpdateRow', true);

        //Add New Account Record
        
        billList.push({
            'sobjectType': 'clofor_com_cfs__QuoteLine__c',
            'clofor_com_cfs__ServicePricingID__c': '',
            'clofor_com_cfs__Print__c': true,
            'clofor_com_cfs__Quantity__c': '',
            'clofor_com_cfs__ChargeUnit__c': '',
            'clofor_com_cfs__ContainerType__c': '', 
            'clofor_com_cfs__CurrencySelling__c': '', 
            'clofor_com_cfs__SellingListPriceLocal__c': '', 
            'clofor_com_cfs__SellingListPriceUSD__c': '', 
            'clofor_com_cfs__TaxRate__c': '', 
            'clofor_com_cfs__Remarks__c': '', 
            
        });
        component.set("v.billList", billList);

        
        console.log('billList:' + JSON.stringify(billList));

    },
    
    removeRecord: function(component, event, helper) {
        //Get the account list
        var billList = component.get("v.billList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        //Remove single record from account list
        billList.splice(index, 1);
        //Set modified account list
        component.set("v.billList", billList);
    },
    	
    saveBills: function(component, event, helper) {      
        if (helper.validateAccountRecords(component, event)) {
            //Call Apex method and pass account list as a parameters
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");

            var action = component.get("c.saveQuoteLineList");
            action.setParams({
                "quoteLineList": component.get("v.billList"),
                "quoteId": component.get("v.recordId"),
            });
            console.log('action:' + JSON.stringify(action));

            action.setCallback(this, function(response) {
                //get response status 
                var state = response.getState();
                if (state === "SUCCESS") {
                    //set empty account list
                    component.set("v.billList", []);
                  $A.util.toggleClass(spinner, "slds-hide");
                    alert('Quote Line saved successfully');
                }
            }); 
            console.log('action:' + JSON.stringify(action));
            $A.enqueueAction(action);
            // $A.util.toggleClass(spinner, "slds-hide");

       }
    },
    onToggleSpinner: function(cmp){
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})