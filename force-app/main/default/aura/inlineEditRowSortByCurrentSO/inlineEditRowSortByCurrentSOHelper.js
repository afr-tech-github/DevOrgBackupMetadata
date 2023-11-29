({
    closeEditMode: function(component, cmpEdit){
        var lstCmp = [];
        // Bill Name at Print(Local)
        lstCmp.push("billNameEditMode");
        // Service Name
        lstCmp.push("serviceNameEditMode");
        // Invoice to
        lstCmp.push("invoiceToEditMode");
        // Charge Quantity
        lstCmp.push("chargeQuantityEditMode");
        // Charge Unit(Override)
        lstCmp.push("chargeUnitEditMode");
        // Container Size(Override)
        lstCmp.push("conSizeEditMode");
        // Currency-Selling
        lstCmp.push("currSellingEditMode");
        // Unit Price of Selling(Local)
        lstCmp.push("unitLocalEditMode");
        // Unit Price of Selling(FCY)
        lstCmp.push("unitFCYEditMode");
        // Tax Rate-Selling(%)
        lstCmp.push("taxSellingEditMode");
        // Exchange Rate-Selling(Debit)
        lstCmp.push("exDebitEditMode");
        // Currency Conversion for Selling
        lstCmp.push("currConSellingEditMode");
        // Invoice S/B Display No
        lstCmp.push("invSBDisplayNoEditMode");
        // Payment to-Buying
        lstCmp.push("paymentToBuyingEditMode");
        
        for(var i = 0; i < lstCmp.length; i++){
            if(lstCmp[i] == cmpEdit){
                //alert(lstCmp[i] + "__" +cmpEdit);
                component.set("v." + lstCmp[i], true);
            }
            else{
                component.set("v." + lstCmp[i], false);
            }
        }
        //$A.get('e.force:refreshView').fire();
    }
})