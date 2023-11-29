({
    validateAccountRecords: function(component, event) {
        //Validate all account records
        var isValid = true;
        var billList = component.get("v.billList");
        // for (var i = 0; i < billList.length; i++) {
        //     if (billList[i].Name == '') {
        //         isValid = false;
        //         alert('Account Name cannot be blank on '+(i + 1)+' row number');
        //     }
        // }
        if(billList.length == 0){
            alert('Null');
            isValid = false;
        }
        return isValid;
    },
    
})