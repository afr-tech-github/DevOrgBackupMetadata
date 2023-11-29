({
    addRow: function(component, event, helper) {
        //get the account List from component  
        var billList = component.get("v.billList");
        //Add New Account Record
        billList.push({
            'sobjectType': 'clofor_com_cfs__AnkenMeisai__c',
            'clofor_com_cfs__Tariff__c': '',
            'clofor_com_cfs__Suryo__c': '',
            'clofor_com_cfs__ChargeUnit__c': '',
            'clofor_com_cfs__Description__c': '', 
            'clofor_com_cfs__Seikyusaki__c': '', 
            'clofor_com_cfs__SellTankaJPY__c': '', 
            // 'clofor_com_cfs__SellTankaUSD__c': '',
            'clofor_com_cfs__curr__c': '', 
            'clofor_com_cfs__TaxInitial__c': '', 
            'clofor_com_cfs__PaymentTo__c': '', 
            'clofor_com_cfs__BuyTankaJPY__c': '', 
            'clofor_com_cfs__CurrencyBuying__c': '', 
            'clofor_com_cfs__BuyTaxInitial__c': '', 
            
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
            var con = component.get("v.recordId");
            var action = component.get("c.saveBillList");
            action.setParams({
                "billList": component.get("v.billList"),
                "shipmentId": component.get("v.recordId"),
            });

            console.log('action:' + JSON.stringify(action));
            console.log('action:' + JSON.stringify(con));

            action.setCallback(this, function(response) {
                //get response status 
                var state = response.getState();
                if (state === "SUCCESS") {
                    //set empty account list
                    component.set("v.billList", []);
                  $A.util.toggleClass(spinner, "slds-hide");
                    alert('Bill saved successfully');
                }
            }); 
            console.log('action:' + JSON.stringify(action));
            $A.enqueueAction(action);
            // $A.util.toggleClass(spinner, "slds-hide");

       }
    },
    handleOnSuccess : function(cmp, event, helper) {
        // helper.onToggleSpinner(cmp);
        cmp.set('v.billList', cmp.get('v.billList'));
        // var record = event.getParam("response");
        // helper.createComponent(cmp, {Id: record.id}, false);
        // cmp.set('v.showForm', false);
        // cmp.set('v.showForm', true);
    },
    onToggleSpinner: function(cmp){
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})