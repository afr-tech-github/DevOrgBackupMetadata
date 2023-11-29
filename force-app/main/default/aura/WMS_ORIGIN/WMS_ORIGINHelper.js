({
	getWorkOrderList: function(component) {
        var action = component.get('c.getWorkOrderService');
        var recIdWorkOrder = component.get('v.recordId');
        action.setParams({ "strTab" : 'ORIGIN'
                         ,  "recIdWorkOder" : recIdWorkOrder});
        
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
         component.set('v.WorkOrderList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
   }
})