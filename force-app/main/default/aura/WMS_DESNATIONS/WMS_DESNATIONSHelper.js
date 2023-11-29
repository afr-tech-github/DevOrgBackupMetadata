({
	getWorkOrderList: function(component) {
        var recIdWorkOrder = component.get('v.recordId');
        console.log("--DES--" + recIdWorkOrder);
        var action = component.get('c.getWorkOrderService');
        action.setParams({ "strTab" : 'DESNATIONS',
                           "recIdWorkOder" : recIdWorkOrder});
        //action.setParams({ "recIdWorkOder" : recIdWorkOrder });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
         component.set('v.WorkOrderList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
   }
})