({
    getColumns: function() {
        var columns = [{ 'label': 'PRODUCT', 'fieldAPI': 'Product__c' },
            { 'label': 'CARGO NAME', 'fieldAPI': 'Name' },
            { 'label': 'INBOUND DATE', 'fieldAPI': 'InboundDate__c' },
            { 'label': 'LAST LOCATOR ID', 'fieldAPI': 'LastLocator__c' },
            { 'label': 'LAST LOCATOR CODE', 'fieldAPI': 'LastLocatorCode__c' },
            { 'label': 'LAST WOS LINE ITEM', 'fieldAPI': 'LastWosLineItem__c' },
            { 'label': 'QR DISPLAY SUMMARY', 'fieldAPI': 'Summary__c' },
            { 'label': 'CARGO LIFE CYCLE', 'fieldAPI': 'CargoLifeCycle__c' },
            { 'label': 'CARGO TYPE', 'fieldAPI': 'CargoType__c' },
            { 'label': 'QUANTITY', 'fieldAPI': 'Quantity__c' },
            { 'label': 'QUANTITY IN UNIT', 'fieldAPI': 'QuantityInUnit__c' },
            { 'label': 'ACCEPTED QUANTITY IN UNIT', 'fieldAPI': 'AcceptedQuantityInUnit__c' },
            { 'label': 'QUANTITY PER UNIT', 'fieldAPI': 'QuantityPerUnit__c' },
            { 'label': 'MANUFACTURED DATE', 'fieldAPI': 'ManufacturedDate__c' },
            { 'label': 'EXPIRED DATE', 'fieldAPI': 'ExpiredDate__c' },
        ];
        return columns;
    },
    getCargos:function(component, event){
        var action = component.get("c.getData");
        action.setParams({
            'workOrderProductId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //component.set("v.options", response.getReturnValue());
                if (response.getReturnValue()) {
                    component.set("v.listCargo", response.getReturnValue().cargos);
                    if (response.getReturnValue().requiredQuantity) {
                        component.set("v.maxRowSelect", response.getReturnValue().requiredQuantity);
                    } else {
                        component.set("v.maxRowSelect", 0);
                    }
                }

            }
        });
        $A.enqueueAction(action);              
    },
    getFieldLabels: function() {
        var fields = new Map([
                      	['Id', 'Id'],
                        ['Name', 'Cargo Name'],
                        ['Product__c', 'Product'],
                        ['InboundDate__c', 'Inbound Date'],
                        ['ExpiredDate__c', 'Expired Date'],
                        ['AcceptedQuantityInUnit__c', 'Accepted Quantity In Unit'],
                        ['AgingDaysTillExpire__c', 'Aging Days Till Expire'],
                        ['CargoLifeCycle__c', 'Cargo Life Cycle'],
                        ['CargoType__c', 'Cargo Type'],
                        ['ExpireDateSKUNumber__c', 'Expire Date SKU Number'],
                        ['InventoryType__c', 'Inventory Type'],
                        ['ItemNumber__c', 'Item Number'],
                        ['LastWosLineItem__c', 'Last Wos Line Item'],
                        ['LastLocatorCode__c', 'Last Locator Code'],
                        ['LastLocator__c', 'Last Locator'],
                        ['LastWORecordType__c', 'Last WO Record Type'],
                        ['LastWOSRecordType__c', 'Last WOS Record Type'],
                        ['LastWOS__c', 'Last WOS'],
                        ['LastWosLineItem__c', 'Last Wos Line Item'],
                        ['LotNumber__c', 'Lot Number'],
                        ['LotQuantity__c', 'Lot Quantity'],
                        ['ManufacturedDate__c', 'Manufactured Date'],
                        ['MissingQuantityinUnit__c', 'Missing Quantity in Unit'],
                        ['PartNumber__c', 'Part Number'],
                        ['PlannedWeight__c', 'Planned Weight'],
                        ['PlannedWeightCal__c', 'Planned Weight Cal'],
                        ['ProductDetails__c', 'Product Details'],
                        ['ProductSKUNumber__c', 'Product SKU Number'],
                        ['QrCodeImage__c', 'Qr Code Image'],
                        ['ManufacturedDate__c', 'Manufactured Date'],
                        ['Quantity__c', 'Quantity'],
                        ['QuantityInUnit__c', 'Quantity In Unit'],
                        ['QuantityPerUnit__c', 'Quantity Per Unit'],
                        ['QuantityVarianceinUnit__c', 'Quantity Variancein Unit'],
                        ['Summary__c', 'Summary']
                    ]);
        return fields;
    },
})