({
	// For select all Checkboxes 
    selectAll: function(component, event, helper) {
		//get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
         // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
         // return the List of all checkboxs element 
         var getAllId = component.find("boxPack");
         // If the local ID is unique[in single record case], find() returns the component. not array   
         if(! Array.isArray(getAllId)){
             if(selectedHeaderCheck == true){ 
                 component.find("boxPack").set("v.value", true);
             }else{
                 component.find("boxPack").set("v.value", false);
             }
         }else{
             if (selectedHeaderCheck == true) {
                 for (var i = 0; i < getAllId.length; i++) {
                     component.find("boxPack")[i].set("v.value", true);
                 }
             } else {
                 for (var i = 0; i < getAllId.length; i++) {
                     component.find("boxPack")[i].set("v.value", false);
                 }
             } 
         }
        var listWorkOrderId = [];
        if(! Array.isArray(getAllId)){
            var valId  = component.find("boxPack").get("v.text");
            listWorkOrderId.push(valId);
        }else{
            for (var i = 0; i < getAllId.length; i++) {
                var selectVaule = component.find("boxPack")[i].get("v.value");
                if(selectVaule == true){
                    var valId  = component.find("boxPack")[i].get("v.text");
                    listWorkOrderId.push(valId);
                }
            }
        }
        console.log(listWorkOrderId);
        // get data for tab origin
        var tabName = component.get("v.nameTab");
        console.log('----excute in component list detail----' + tabName);
        if(tabName == "ORIGIN"){
             // Get list Work Order Service
            var listWorkOrderService = component.get("v.WorkOrderList");
            // Get the event using event name. 
            var appEvent = $A.get("e.c:WMS_RegisterConnectWorkerEvent");
            // Set event attribute value
           // appEvent.setParams({"evWorkOrderList" : listWorkOrderService}); 
            appEvent.setParams({"evWorkOrderOriginIdList" : listWorkOrderId});
            appEvent.fire();
        }else{// get data from destination
             // Get list Work Order Service
            var listWorkOrderService = component.get("v.WorkOrderList");
            // Get the event using event name. 
            var appEventDes = $A.get("e.c:WMS_WorkOderDesEvent");
            // Set event attribute value
            appEventDes.setParams({"evWorkOrderDesIdList" : listWorkOrderId}); 
        	appEventDes.fire();
        }
       console.log('----excute in component list detail End----');
     },
    // For count the selected checkboxes. 
    checkboxSelect: function(component, event, helper) {
        var listWorkOrderId = [];
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.value"); 
        if (selectedRec == false) {
            component.find("box3").set("v.value", false);
        }
        var getAllId = component.find("boxPack");
        if(! Array.isArray(getAllId)){
            var valId  = component.find("boxPack").get("v.text");
            listWorkOrderId.push(valId);
        }else{
            for (var i = 0; i < getAllId.length; i++) {
                var selectVaule = component.find("boxPack")[i].get("v.value");
                if(selectVaule == true){
                    var valId  = component.find("boxPack")[i].get("v.text");
                    listWorkOrderId.push(valId);
                }
            }
        }
        console.log('----excute in component list detail select one ----');
        console.log(listWorkOrderId);
        console.log('----excute in component list detail select one End----');
        
       var tabName = component.get("v.nameTab");
       if(tabName == "ORIGIN"){
             // Get list Work Order Service
            var listWorkOrderService = component.get("v.WorkOrderList");
            // Get the event using event name. 
            var appEvent = $A.get("e.c:WMS_RegisterConnectWorkerEvent");
            // Set event attribute value
           // appEvent.setParams({"evWorkOrderList" : listWorkOrderService}); 
            appEvent.setParams({"evWorkOrderOriginIdList" : listWorkOrderId});
            appEvent.fire();
        }else{// get data from destination
             // Get list Work Order Service
            var listWorkOrderService = component.get("v.WorkOrderList");
            // Get the event using event name. 
            var appEventDes = $A.get("e.c:WMS_WorkOderDesEvent");
            // Set event attribute value
            appEventDes.setParams({"evWorkOrderDesIdList" : listWorkOrderId}); 
        	appEventDes.fire();
        }
     }
})