({
    init: function(component, event, helper) {
        var action = component.get("c.getInitData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.options", response.getReturnValue().cargoLifeCycles);
                component.set("v.translations", response.getReturnValue().translations);
                if (response.getReturnValue()) {
                    component.set("v.selectedValue", response.getReturnValue().cargoLifeCycles[0].value);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleLoad: function(component, event, helper) {},
    doSearch: function(component, event, helper) {
        //debugger;
        var goodSOs = component.find("goodsSOList").get("v.value");
        var workOrders = component.find("workOrderList").get("v.value");

        component.set("v.goodSOs", goodSOs);
        component.set("v.workOrders", workOrders);
        //setTimeout(function() {
        component.find("productSearch").submit();
        //}, 2000);
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();

        component.set("v.isViewingDetailProduct", false);
        component.set("v.isLoading", true);

        var expiredDate = component.find("expiredDate").get("v.value");
        //var cargoLifeCycle = component.find("cargoLifeCycle").get("v.value");
        var cargoLifeCycle = component.get("v.selectedValue");
        var fields = event.getParam("fields");
        var goodSOs = component.find("goodsSOList").get("v.value");
        var workOrders = component.find("workOrderList").get("v.value");
        var locators = component.find("locatorList").get("v.value");
        var warehouses = component.find("warehouseList").get("v.value");
        var skuNumber = component.find("skuNumber").get("v.value");
        var action = component.get("c.getProducts");
        action.setParams({
            "product": fields,
            "goodsSO": goodSOs,
            "workOrders": workOrders,
            "locators": locators,
            "warehouses": warehouses,
            "expiredDate": expiredDate,
            "skuNumber": skuNumber,
            "cargoLifeCycle": cargoLifeCycle
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //debugger;
            if (component.isValid() && state === "SUCCESS") {
                //console.log('response state: ' + response.getReturnValue()[0].product.clofor_com_cfs__ProductName__c);
                //component.set("v.listResultIterator", response.getReturnValue());
                component.set("v.listResultSearch", response.getReturnValue());
                var totalRecords = component.get("v.listResultSearch").length;
                var pageSize = component.get("v.pageSize");
                component.set("v.totalRecords", totalRecords);
                // set star as 0
                component.set("v.startPage", 0);

                component.set("v.endPage", pageSize - 1);
                var totalPages = Math.ceil(totalRecords / pageSize);
                component.set("v.totalPages", totalPages);
                component.set("v.currentPage", 1);
                var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (totalRecords > i)
                        PaginationList.push(response.getReturnValue()[i]);
                }
                component.set('v.listResultIterator', PaginationList);
                component.set('v.isSending', false);
                component.set("v.isInit", false);
                component.set("v.isLoading", false);

            } else {
                console.log('Problem getting RelatedRecordList, response state: ' + state);
                component.set("v.isInit", false);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    backtoProductList: function(component, event, helper) {
        component.set("v.isViewingDetailProduct", false);
    },
    viewDetailProduct: function(component, event, helper) {
        var product = event.target.getAttribute("id");
        var productAtrributes = product.split('_');
        component.set("v.idProductViewing", productAtrributes[0]);
        component.set("v.productNameViewing", productAtrributes[1]);
        component.set("v.isViewingDetailProduct", true);
        var currentList = component.get("v.listResultIterator");
        var listLocator;
        var currentProductWapper;
        for (var i = 0; i < currentList.length; i++) {
            if (currentList[i].product.Id == productAtrributes[0]) {
                listLocator = currentList[i].listLocator;
                currentProductWapper = currentList[i];
                break;
            }

        }
        debugger;
        console.log('listLocator : ' + listLocator);
        component.set("v.listLocatorViewing", listLocator);

        component.set("v.currentStockPage", 1);
        component.set("v.startStockPage", 0);
        component.set("v.totalStockRecords", listLocator.length);
        var pageSize = component.get("v.pageStockSize");
        var totalRecords = component.get("v.totalStockRecords");
        var totalPages = Math.ceil(totalRecords / pageSize);
        component.set("v.totalStockPages", totalPages);
        component.set("v.endStockPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (totalRecords > i)
                PaginationList.push(listLocator[i]);
        }
        debugger;
        component.set('v.listLocatorIterator', PaginationList);
        component.set("v.currentProductWapper", currentProductWapper);


    },
    expandSectionProductDetail: function(component, event, helper) {
        if (component.get("v.isSectionDetailProductOpen")) {
            component.set("v.isSectionDetailProductOpen", false);

        } else {
            component.set("v.isSectionDetailProductOpen", true);
        }
    },
    expandSectionSearch: function(component, event, helper) {
        if (component.get("v.isSectionSearchOpen")) {
            component.set("v.isSectionSearchOpen", false);

        } else {
            component.set("v.isSectionSearchOpen", true);
        }
    },

    expandSectionLocatatorList: function(component, event, helper) {
        if (component.get("v.isSectionLocatorOpen")) {
            component.set("v.isSectionLocatorOpen", false);

        } else {
            component.set("v.isSectionLocatorOpen", true);
        }
    },
    expandSectionResult: function(component, event, helper) {
        if (component.get("v.isSectionResultOpen")) {
            component.set("v.isSectionResultOpen", false);

        } else {
            component.set("v.isSectionResultOpen", true);
        }
    },
    next: function(component, event) {
        component.set("v.currentPage", component.get("v.currentPage") + 1);
        var sObjectList = component.get("v.listResultSearch");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        var length = end + pageSize + 1
        for (var i = end + 1; i < length; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            }

        }
        start = end + 1;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.listResultIterator', Paginationlist);
    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    previous: function(component, event) {
        component.set("v.currentPage", component.get("v.currentPage") - 1);
        debugger;
        var sObjectList = component.get("v.listResultSearch");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.listResultIterator', Paginationlist);
    },

    nextStock: function(component, event) {
        component.set("v.currentStockPage", component.get("v.currentStockPage") + 1);
        var sObjectList = component.get("v.listLocatorViewing");
        var end = component.get("v.endStockPage");
        var start = component.get("v.startStockPage");
        var pageSize = component.get("v.pageStockSize");
        var Paginationlist = [];
        var counter = 0;
        var length = end + pageSize + 1
        for (var i = end + 1; i < length; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            }

        }
        start = end + 1;
        end = end + counter;
        component.set("v.startStockPage", start);
        component.set("v.endStockPage", end);
        component.set('v.listLocatorIterator', Paginationlist);
    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    previousStock: function(component, event) {
        component.set("v.currentStockPage", component.get("v.currentStockPage") - 1);
        debugger;
        var sObjectList = component.get("v.listLocatorViewing");
        var end = component.get("v.endStockPage");
        var start = component.get("v.startStockPage");
        var pageSize = component.get("v.pageStockSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startStockPage", start);
        component.set("v.endStockPage", end);
        component.set('v.listLocatorIterator', Paginationlist);
    },
    onChangePageSize: function(component, event) {
        var pageSize = component.find('select').get('v.value');
        component.set("v.pageSize", pageSize);
        var sObjectList = component.get("v.listResultSearch");
        component.set("v.currentPage", 1);
        component.set("v.startPage", 0);
        var totalRecords = component.get("v.totalRecords");
        var totalPages = Math.ceil(totalRecords / pageSize);
        component.set("v.totalPages", totalPages);
        component.set("v.endPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (totalRecords > i)
                PaginationList.push(sObjectList[i]);
        }
        component.set('v.listResultIterator', PaginationList);

    },
    onChangeStockPageSize: function(component, event) {
        var pageSize = component.find('selectStock').get('v.value');
        component.set("v.pageStockSize", pageSize);
        var sObjectList = component.get("v.listLocatorViewing");
        component.set("v.currentStockPage", 1);
        component.set("v.startStockPage", 0);
        var totalRecords = component.get("v.totalStockRecords");
        var totalPages = Math.ceil(totalRecords / pageSize);
        component.set("v.totalStockPages", totalPages);
        component.set("v.endStockPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (totalRecords > i)
                PaginationList.push(sObjectList[i]);
        }
        component.set('v.listLocatorIterator', PaginationList);

    }
})