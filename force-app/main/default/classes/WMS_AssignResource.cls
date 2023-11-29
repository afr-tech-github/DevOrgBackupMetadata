public with sharing class WMS_AssignResource {

    @AuraEnabled
    public static Object getInfo(Id recordId){
        List<Map<String, String>> picklistStatus = new List<Map<String, String>>();

		for (PicklistEntry item : clofor_com_cfs__WorkOrderService__c.clofor_com_cfs__Status__c.getDescribe().getPicklistValues()) {
			picklistStatus.add(new Map<String, String>{ 'label' => item.Label, 'value' => item.Value });
		}
        
        List<Map<String, String>> picklistWorker = new List<Map<String, String>>();
        for(WORKER__c worker : [ SELECT Id, Name FROM WORKER__c Limit 50000]){
            picklistWorker.add(new Map<String, String>{'label' => worker.Name, 'value' => worker.Id});
        }
        
        return new Map<String, Object>{
            'workOrder' => (WorkOrder__c)[
				SELECT
					RecordType.Name, RecordType.DeveloperName, WarehouseId__c, DestinationWarehouse__c,
					(
						SELECT Id, Warehouse__c, DestinationWarehouse__c, VASServiceType__c, VASRequirement__c, 
                        		ServiceStage__c, RecordTypeId, ScheduledStartTime__c, ScheduledEndTime__c 
                        FROM WorkOrderService__r
					)
				FROM WorkOrder__c
				WHERE Id = :recordId
			],
            'workOrderServices' => [
                SELECT Id, Warehouse__c, DestinationWarehouse__c, VASServiceType__c, VASRequirement__c, 
                        		ServiceStage__c, RecordTypeId, ScheduledStartTime__c, ScheduledEndTime__c 
                FROM WorkOrderService__c 
            	WHERE WorkOrder__c = :recordId ],
            'serviceRecordTypes' => [
				SELECT Id, Name, DeveloperName
				FROM RecordType
				WHERE SobjectType = 'clofor_com_cfs__WorkOrderService__c'
			],
        	'picklistStatus' => picklistStatus,
            'picklistWorker' => picklistWorker
        };
    }
    
	@AuraEnabled
    public static String getWorkOrderWarehouseId(Id recordId){
        return [SELECT WarehouseId__c FROM WorkOrder__c WHERE Id = :recordId].WarehouseId__c;
    }
	@AuraEnabled
    public static List<Map<String, String>> getWorkerRole(){
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = clofor_com_cfs__ConnectWOSWorker__c.clofor_com_cfs__WorkRole__c.getDescribe();
        List<Schema.PicklistEntry> role = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry value: role) {
            options.add(new Map<String, String>{ 'label' => value.getLabel(), 'value' => value.getValue() });
        }
        return options;
    }
    
    @AuraEnabled
    public static List<clofor_com_cfs__WORKER__c> getWorker(){
        List<clofor_com_cfs__WORKER__c> listWorker = new List<clofor_com_cfs__WORKER__c>();
        listWorker = [SELECT Id, Name, FULL_NAME__c FROM clofor_com_cfs__WORKER__c Limit 50000];
        return listWorker;
    }
    @AuraEnabled
    public static List<Map<String, String>> getWorkOrderStatus(){
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = clofor_com_cfs__WorkOrderService__c.clofor_com_cfs__Status__c.getDescribe();
        List<Schema.PicklistEntry> role = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry value: role) {
            options.add(new Map<String, String>{ 'label' => value.getLabel(), 'value' => value.getValue() });
        }
        return options;
    }
    
	/*

	*/
	@AuraEnabled
    public static List <clofor_com_cfs__WorkOrderService__c> getWorkOrderService(String strTab, String recIdWorkOder) {
        WorkOrder__c wo = [SELECT WarehouseId__c FROM WorkOrder__c WHERE Id = :recIdWorkOder];
        List <clofor_com_cfs__WorkOrderService__c> lstOrderService = new List <clofor_com_cfs__WorkOrderService__c>();
        if(strTab == 'ORIGIN'){
            lstOrderService =  [SELECT Name
                                		, clofor_com_cfs__ScheduledStartTime__c
                                		, clofor_com_cfs__ScheduledEndTime__c
                                        , clofor_com_cfs__Status__c
                                        , clofor_com_cfs__FinalQuantityRollUp__c
                                        , RecordType.DeveloperName
                                FROM clofor_com_cfs__WorkOrderService__c
                                WHERE clofor_com_cfs__WorkOrder__c =:recIdWorkOder
                                    AND Warehouse__c = :wo.WarehouseId__c
                                    AND clofor_com_cfs__DestinationWarehouse__c = NULL];
        }else if(strTab == 'DESNATIONS'){
             lstOrderService =  [SELECT Id
                                 		, Name
                                 		, clofor_com_cfs__ScheduledStartTime__c
                                		, clofor_com_cfs__ScheduledEndTime__c
                                        , clofor_com_cfs__Status__c
                                        , clofor_com_cfs__FinalQuantityRollUp__c
                                        , RecordType.DeveloperName
                                FROM clofor_com_cfs__WorkOrderService__c
                                WHERE clofor_com_cfs__WorkOrder__c =:recIdWorkOder
                                    AND (clofor_com_cfs__DestinationWarehouse__c != NULL OR Warehouse__c != :wo.WarehouseId__c)];
        }
        return lstOrderService;
    }

    @AuraEnabled
    public static String createConnectWorker(  List<String> lstIdWorkOrderService
                                                       , List<clofor_com_cfs__ConnectWOSWorker__c> lstConnectWorker
                                                       , clofor_com_cfs__WorkOrderService__c updateInfor
                                                       , String strIdWorkOrder){
       // List Connect Worker 
       List<clofor_com_cfs__ConnectWOSWorker__c> lstConnectWorkerForInsert = new List<clofor_com_cfs__ConnectWOSWorker__c>();
       List<clofor_com_cfs__WorkOrderService__c> lstWorkOrderServiceUpdate = new List<clofor_com_cfs__WorkOrderService__c>();
       lstWorkOrderServiceUpdate = [SELECT Id
                                    		, clofor_com_cfs__Locator__c
                                    		, clofor_com_cfs__Status__c
                                    		, clofor_com_cfs__ScheduledStartTime__c
                                   			, clofor_com_cfs__ScheduledEndTime__c
                                   FROM clofor_com_cfs__WorkOrderService__c
                                   WHERE Id IN :lstIdWorkOrderService ];
       if(lstIdWorkOrderService.isEmpty() && (!String.isBlank(updateInfor.clofor_com_cfs__Locator__c)
          || !String.isBlank(updateInfor.clofor_com_cfs__Status__c)
          || updateInfor.clofor_com_cfs__ScheduledStartTime__c != null
          || updateInfor.clofor_com_cfs__ScheduledEndTime__c != null)){
             lstWorkOrderServiceUpdate = [SELECT Id
                                    		, clofor_com_cfs__Locator__c
                                    		, clofor_com_cfs__Status__c
                                    		, clofor_com_cfs__ScheduledStartTime__c
                                   			, clofor_com_cfs__ScheduledEndTime__c
                                   FROM clofor_com_cfs__WorkOrderService__c
                                   WHERE clofor_com_cfs__WorkOrder__c =:strIdWorkOrder ];                                                  
       }                                                  
       for(clofor_com_cfs__WorkOrderService__c wos : lstWorkOrderServiceUpdate){
           if(!String.isBlank(updateInfor.clofor_com_cfs__Locator__c)){
               wos.clofor_com_cfs__Locator__c = updateInfor.clofor_com_cfs__Locator__c;
           }
           if(!String.isBlank(updateInfor.clofor_com_cfs__Status__c)){
               wos.clofor_com_cfs__Status__c = updateInfor.clofor_com_cfs__Status__c;
           }
           
           if(updateInfor.clofor_com_cfs__ScheduledStartTime__c != null){
               wos.clofor_com_cfs__ScheduledStartTime__c = updateInfor.clofor_com_cfs__ScheduledStartTime__c;
           }
           if(updateInfor.clofor_com_cfs__ScheduledEndTime__c != null){
               wos.clofor_com_cfs__ScheduledEndTime__c = updateInfor.clofor_com_cfs__ScheduledEndTime__c;
           }
           for(clofor_com_cfs__ConnectWOSWorker__c connectWoker : lstConnectWorker){
               clofor_com_cfs__ConnectWOSWorker__c wk = new clofor_com_cfs__ConnectWOSWorker__c();
               wk.clofor_com_cfs__WorkOrderService__c = wos.Id;
               wk.clofor_com_cfs__Worker__c  = connectWoker.clofor_com_cfs__Worker__c;
               wk.clofor_com_cfs__WorkRole__c  = connectWoker.clofor_com_cfs__WorkRole__c;
               lstConnectWorkerForInsert.add(wk);
           }
        }
        String oErrorMsg = '';
        try{
            if(!lstWorkOrderServiceUpdate.isEmpty()){
                FlsService.doUpdate(lstWorkOrderServiceUpdate);
            }
            if(!lstConnectWorkerForInsert.isEmpty()){
                FlsService.doUpsert(lstConnectWorkerForInsert);
            }
        }catch(Exception ex){
            oErrorMsg = ex.getStackTraceString() + ': ' + ex.getMessage();
        }
        return oErrorMsg;
    }
}