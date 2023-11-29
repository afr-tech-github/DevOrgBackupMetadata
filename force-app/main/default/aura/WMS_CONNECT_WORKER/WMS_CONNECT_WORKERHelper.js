({
	 addAccountRecord: function(component, workerId) {
        //get the account List from component  
        var workerList = component.get("v.connectWorkerList");
        console.log(workerList, workerId);
        if (workerList.some(x => x.clofor_com_cfs__Worker__c === workerId)) {
            return;
        }
        //Add New  Record
        workerList.push({
            'sobjectType': 'clofor_com_cfs__ConnectWOSWorker__c',
            'clofor_com_cfs__Worker__c': workerId,
            'clofor_com_cfs__WorkRole__c': 'Operator'
        });
        component.set("v.connectWorkerList", workerList);
    },
    getWorkerRole: function(component){
        var action = component.get("c.getWorkerRole");
        var attribute = "v.WorkerRoleList";
        var inputReturnRole = component.find("workerRole");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(attribute, response.getReturnValue());
                /*window.setTimeout(
                    $A.getCallback( function() {
                        inputReturnRole.set("v.value", "Operator");
                    }),3000
                );*/
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    getWorker: function(component){
        var action = component.get("c.getWorker");
        var attribute = "v.WorkerList";
        var inputReturnRole = component.find("workerList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(attribute, response.getReturnValue().map(x => ({ value: x.Id, label: `${x.Name} | ${x.clofor_com_cfs__FULL_NAME__c}` })));
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})