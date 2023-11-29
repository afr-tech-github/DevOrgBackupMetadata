({
	 addRow: function(component, event, helper) {
        helper.addAccountRecord(component);
    },
    
    addWorker: function (c, e, h) {
        h.addAccountRecord(c, e.getParam('arguments').workerId);
    },
	
	doInit: function(component, event, helper) {
        helper.getWorker(component);
        helper.getWorkerRole(component); 
    },
     
    removeRow: function(component, event, helper) {
        //Get the connect Worker list
        var connectWorkerList = component.get("v.connectWorkerList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        connectWorkerList.splice(index, 1);
        component.set("v.connectWorkerList", connectWorkerList);
    }
})