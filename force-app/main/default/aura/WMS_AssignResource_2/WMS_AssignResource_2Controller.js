({
	getValueListOrderService : function(component, event) { 
        var listIdOrderServiceOfOrigin = event.getParam("evWorkOrderOriginIdList");
        console.log('---------get param----------');
        console.log(listIdOrderServiceOfOrigin);
        component.set("v.evListOrderServiceOfOriginID", listIdOrderServiceOfOrigin); 
    },
    getListDesOrder : function(component, event) { 
        //Get the event listWorkOrderSevice attribute
        var listIdOrderServiceOfDes = event.getParam("evWorkOrderDesIdList"); 
        //Set the handler attributes based on event data 
        component.set("v.evListOrderServiceOfDesID", listIdOrderServiceOfDes);   
    },
    addWorker: function (c, e) {
        c.find('WMSCONNECTWORKER').addWorker(e.getParam('arguments').workerId);
    },
    RegisterConnectWorker : function(component, event, helper) { 
        //Get the event message attribute
        var listWorkOrderService = component.get("v.evListOrderService");
        var listIdWorkOrderServiceOfOrigin = component.get("v.evListOrderServiceOfOriginID");
        var listIdWorkOrderServiceOfDes = component.get("v.evListOrderServiceOfDesID");
       

        // get info input for update work order service
		var componentAll = component.find('WMSALL');
        var recWorkOrderService = componentAll.get('v.recOrderService');
        //console.log(recWorkOrderService.clofor_com_cfs__Status__c);
        
        // get list connect worker
        var componentConnectWorker = component.find('WMSCONNECTWORKER');
        var listConnectWorker = componentConnectWorker.get('v.connectWorkerList');
        //console.log(listConnectWorker[0].clofor_com_cfs__WorkRole__c);
        var recIdWorkOrder = component.get("v.recordId");
		var listAllIdWorkOrderService = [];
		if(typeof listIdWorkOrderServiceOfDes != "undefined" && listIdWorkOrderServiceOfDes.length > 0){
            for (var i = 0; i < listIdWorkOrderServiceOfDes.length; i++) {
            	listAllIdWorkOrderService.push(listIdWorkOrderServiceOfDes[i]);
            }
        }
        if(typeof listIdWorkOrderServiceOfOrigin != "undefined" && listIdWorkOrderServiceOfOrigin.length > 0){
            for (var i = 0; i < listIdWorkOrderServiceOfOrigin.length; i++) {
            	listAllIdWorkOrderService.push(listIdWorkOrderServiceOfOrigin[i]);
            }
        } 
        // print data beforce excute
        console.log('-----print data beforce excute----');
        console.log('-------------------');
        console.log('-------------------');
        console.log('-----listAllIdWorkOrderService----');
        console.log(listAllIdWorkOrderService);
        
        console.log('-----listConnectWorker----');
        console.log(listConnectWorker);
        
        console.log('-----recWorkOrderService----');
        //console.log(recWorkOrderService.clofor_com_cfs__Locator__c);
        console.log(recWorkOrderService.clofor_com_cfs__Status__c);
        
        console.log('-----print recIdWorkOrder----');
        console.log(recIdWorkOrder);
        console.log('-----print data beforce excute end----');
        
        var action = component.get("c.createConnectWorker");
        action.setParams({ "lstIdWorkOrderService"   : listAllIdWorkOrderService
                           , "lstConnectWorker"      : listConnectWorker
                           , "updateInfor"           : recWorkOrderService
                           , "strIdWorkOrder"        : recIdWorkOrder});
        action.setCallback(this, function(response) {
        	//store state of response
        	var state = response.getState();
            var result = response.getReturnValue();
            if(result == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: 'Assign worker and update info work order service success',
                    duration:' 1000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
        		toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: result,
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 15000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            console.log('@@@@@@@@@@@@@');
            console.log(result);
        });
        $A.enqueueAction(action);
		
    },  
    reInit : function(component, event, helper) {
        // refresh component origin after update
        var cpOrigin = component.find('origin');
        cpOrigin.reInit();
        
        // set default value for checkbox all
        var cpListDetail = cpOrigin.find('detail');
		if(typeof cpListDetail.find('box3') != "undefined"){
			cpListDetail.find('box3').set("v.value", false);
		}
     	
        
        // refresh component origin after update
        var cpDes = component.find('Destination');
        cpDes.reInit();
	
        // set default value for checkbox all
        var cpListDetailDes = cpDes.find('detail');
		if(typeof cpListDetailDes.find('box3') != "undefined"){
			cpListDetailDes.find('box3').set("v.value", false);
		}
     	
        // init event
        // Get the event using event name. 
        var appEvent = $A.get("e.c:WMS_RegisterConnectWorkerEvent");
        appEvent.fire();
        // Get the event using event name. 
        var appEventDes = $A.get("e.c:WMS_WorkOderDesEvent");
        // Set event attribute value
        appEventDes.fire();
        
        // reInit section Connect Worker
        var newListWorker = component.get("v.newListConnectWorker");  
        var cpConnectWorker = component.find('WMSCONNECTWORKER');
        cpConnectWorker.set("v.connectWorkerList", newListWorker);
        
        // reInit section Work Order Service
        var reNewWos = component.get("v.reNewOrderService");
        var cpAll = component.find('WMSALL');
        cpAll.set("v.recOrderService", reNewWos);
    }
})