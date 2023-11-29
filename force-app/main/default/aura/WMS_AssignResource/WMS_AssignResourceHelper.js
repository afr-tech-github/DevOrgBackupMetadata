({
	invokeActionAsync : function(c, h, actionName, params) {
		return new Promise($A.getCallback(function(resolve, reject) {
            try {
				c.set('v.isLoading', true);
                var action = c.get(actionName);
				if (params != null) {
	                action.setParams(params);
				}
                action.setCallback(this, function (response) {
					c.set('v.isLoading', false);
                    if (response.getState() !== "SUCCESS") {
                        if (reject)
                            reject(response.getError()[0].message);
                        else
                            console.log(response.getError()[0].message);
                        return;
                    }

                    if (resolve) {
						console.log(response.getReturnValue());
						resolve(response.getReturnValue());
					}
                });

                $A.enqueueAction(action);
            }
            catch (e) {
                console.log(e);
            }
        }));
	},
    createListWOS: function(c, h){
        var workOrder = c.get('v.entWorkOrder');
        var origWosRecords = [];
        
        if (workOrder.clofor_com_cfs__WorkOrderService__r != null && workOrder.clofor_com_cfs__WorkOrderService__r.length > 0){
            var groupedDestWos = {};
            workOrder.clofor_com_cfs__WorkOrderService__r.forEach(function (wos){
                if (wos.clofor_com_cfs__DestinationWarehouse__c == null && wos.clofor_com_cfs__Warehouse__c == workOrder.clofor_com_cfs__WarehouseID__c) {
					origWosRecords.push(wos);
				}
				/*else {
					var destWarehouseId = wos.clofor_com_cfs__DestinationWarehouse__c != null ? wos.clofor_com_cfs__DestinationWarehouse__c : wos.clofor_com_cfs__Warehouse__c;
					if (groupedDestWos[destWarehouseId] == null) {
						groupedDestWos[destWarehouseId] = [];
					}
					groupedDestWos[destWarehouseId].push(wos);
				}*/
                if (origWosRecords.length > 0) {
                    c.set('v.hasOrigWos', true);
                    c.set('v.origWosRecords', origWosRecords);
                }
                else{
                    c.set('v.hasOrigWos', false);
                }
            });
        }
    },
    createTemplateMassive: function(c){
        c.set('v.wosMassive', {
            isSelected: false, 
            lstWorker: '',
            record: {
                sobjectType: 'clofor_com_cfs__WorkOrderService__c'
            }
                
        });
    }
})