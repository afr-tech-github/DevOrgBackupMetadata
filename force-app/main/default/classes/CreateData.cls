public class CreateData {
 	// Create Map RecordType
	public static Map<String, String> getMapRecordType(){
		Map<String, String> mapRecordType = new Map<String, String>();
		List<RecordType> lstRecordType = [ SELECT    Id
													, DeveloperName 
											FROM RecordType 
											WHERE SObjectType = 'clofor_com_cfs__Stock__c'
											OR SObjectType = 'clofor_com_cfs__WorkOrderService__c'
											OR SObjectType = 'clofor_com_cfs__WorkOrder__c'
											OR SObjectType = 'clofor_com_cfs__GoodsPurchasingOrder__c'];
		for(RecordType rt : lstRecordType){
			mapRecordType.put(rt.DeveloperName, rt.Id);
		}
        return mapRecordType;
	 }
	
	// Create Work Order
	public static clofor_com_cfs__WorkOrder__c createWorkOder(String recordTypeId
														, String strAccountName
														, String strOriginWarehouseID
														, String strDestinationWarehouseID
														, Decimal numQuantity){
		clofor_com_cfs__WorkOrder__c itemWorkOrder = new clofor_com_cfs__WorkOrder__c();
		
		itemWorkOrder.RecordTypeId = recordTypeId;
		itemWorkOrder.clofor_com_cfs__Customer__c = strAccountName;	
		itemWorkOrder.clofor_com_cfs__WarehouseID__c = strOriginWarehouseID;
		if(String.isNotBlank(strDestinationWarehouseID)){
			itemWorkOrder.clofor_com_cfs__DestinationWarehouse__c = strDestinationWarehouseID;
		}
		itemWorkOrder.clofor_com_cfs__Quantity__c = numQuantity;
        itemWorkOrder.clofor_com_cfs__ScheduleDate__c 			=  Date.today().addDays(1);
        itemWorkOrder.clofor_com_cfs__DataUpdateMethod__c 		=  'Automatic';
        itemWorkOrder.clofor_com_cfs__DataPull__c				=  'Data Pull From Sales Order';
		return itemWorkOrder;
		
	}
	
	// create Sales Order
	public static clofor_com_cfs__SALES_ORDER__c createSalesOrder(String recordTypeId
															, String strOrderIntExtType
															, String strContractID
															, Decimal numQuantity){
		clofor_com_cfs__SALES_ORDER__c itemSalesOrder = new clofor_com_cfs__SALES_ORDER__c();
		itemSalesOrder.clofor_com_cfs__OrderIntExtType__c 		= recordTypeId;
		itemSalesOrder.clofor_com_cfs__CustomerCompanyName__c	= strOrderIntExtType;
		itemSalesOrder.clofor_com_cfs__ContractID__c			= strContractID;
		itemSalesOrder.clofor_com_cfs__Quantity__c 				= numQuantity;
		itemSalesOrder.clofor_com_cfs__DataUpdateMethod__c 		= '';
        itemSalesOrder.clofor_com_cfs__DataPull__c 				= '';
        Date currentDate = Date.today();                                                        
		if(recordTypeId == 'External'){
			itemSalesOrder.clofor_com_cfs__OrderDate__c				=  currentDate;
			itemSalesOrder.clofor_com_cfs__DeliveryTargetDate__c	=  currentDate;
			itemSalesOrder.clofor_com_cfs__ActualDeliveryDate__c	=  currentDate;
		}else{
			itemSalesOrder.clofor_com_cfs__OrderIntExtType__c				= 'Internal';
			itemSalesOrder.clofor_com_cfs__OrderDate__c						= currentDate.addDays(1);
			itemSalesOrder.clofor_com_cfs__DeliveryTargetDate__c			= currentDate.addDays(1);
		}
        

		
		return itemSalesOrder; 
	}
	
	// Create GoodsPOProduct
	public static clofor_com_cfs__GoodsPOProduct__c createGoodsPOProduct(String strGooPOId
																	, String strProductId
																	, Decimal numQuantity){
		clofor_com_cfs__GoodsPOProduct__c itemGPOProduct = new clofor_com_cfs__GoodsPOProduct__c();
		itemGPOProduct.clofor_com_cfs__GoodsPOID__c = strGooPOId;
		itemGPOProduct.clofor_com_cfs__ProductID__c = strProductId;
		itemGPOProduct.clofor_com_cfs__Quantity__c  = numQuantity;
		
		return itemGPOProduct;
	}
	
	// Create Stock    
	public static clofor_com_cfs__Stock__c createStock(String recordTypeId
												, String strStockWarehouseId
												, String strProductId
												, Decimal numQuantity
												, String strStockStatus){
		clofor_com_cfs__Stock__c itemStock = new clofor_com_cfs__Stock__c();
		itemStock.RecordTypeId 							= recordTypeId;			
		itemStock.clofor_com_cfs__StockWarehouseID__c 	= strStockWarehouseId;
		itemStock.clofor_com_cfs__ProductID__c 			= strProductId;
		itemStock.clofor_com_cfs__Quantity__c 			= numQuantity;
		itemStock.StockStatus__c 						= String.isNotBlank(strStockStatus)? strStockStatus : '';
		return itemStock;
	}
	
	// Create Sales Order Product
	public static clofor_com_cfs__SalesOrderProduct__c createSalesOrderProduct(String strGoodSalesOrderId
																		, String strProductId
																		, Decimal numQuantity){
		clofor_com_cfs__SalesOrderProduct__c itemSalesOrderProduct 	= new clofor_com_cfs__SalesOrderProduct__c();
		itemSalesOrderProduct.clofor_com_cfs__GoodSalesOrderID__c 	= strGoodSalesOrderId;
		itemSalesOrderProduct.clofor_com_cfs__ProductID__c 			= strProductId;
		itemSalesOrderProduct.clofor_com_cfs__Quantity__c 			= numQuantity;
		return itemSalesOrderProduct;
	}
	
	// Create Connect WO Product
	public static clofor_com_cfs__ConnectWOProduct__c createConnectWOProduct(String strWorkOrderId
                                                                       , String strProductId
                                                                       , Decimal numQuantity){
		clofor_com_cfs__ConnectWOProduct__c itemConnectPro 	= new clofor_com_cfs__ConnectWOProduct__c();
		itemConnectPro.clofor_com_cfs__WorkOrderID__c 		= strWorkOrderId;
		itemConnectPro.clofor_com_cfs__ProductID__c 		= strProductId;
		itemConnectPro.clofor_com_cfs__Quantity__c 			= numQuantity;
		return itemConnectPro;
	}
	
	// Create Work Order Service
	public static clofor_com_cfs__WorkOrderService__c createWorkOrderService(String recordTypeId
																		, String strWorkOrder
																		, String strWarehouse
																		, Decimal numInitialQuantity
																		, Decimal numFinalQuantity
																		, String strDestinationWarehouse
																		, Decimal numPlannedQuantity){
		clofor_com_cfs__WorkOrderService__c itemWorkOrderService = new clofor_com_cfs__WorkOrderService__c();
		itemWorkOrderService.RecordTypeId 				= recordTypeId; 
		itemWorkOrderService.WorkOrder__c 				= strWorkOrder;
		itemWorkOrderService.Warehouse__c 				= strWarehouse;
		itemWorkOrderService.InitialQuantity__c 		= numInitialQuantity;
		itemWorkOrderService.FinalQuantity__c 			= numFinalQuantity;
		itemWorkOrderService.DestinationWarehouse__c 	= String.isNotBlank(strDestinationWarehouse) ? strDestinationWarehouse : '';
		itemWorkOrderService.PlannedQuantity__c 		= numPlannedQuantity != null ? numPlannedQuantity : null;
		return itemWorkOrderService;
	}
    
    // Create Connect WO Product
	public static clofor_com_cfs__Call_Out_Error__c createError(String strAPIName){
		List<clofor_com_cfs__Call_Out_Error__c> lstError = new List<clofor_com_cfs__Call_Out_Error__c>();
        lstError = [SELECT Id
                     		, clofor_com_cfs__Status__c
                     		, clofor_com_cfs__Error_Content__c
                     		, clofor_com_cfs__Call_Date__c
                     		, clofor_com_cfs__API_Name__c
                     FROM clofor_com_cfs__Call_Out_Error__c 
                     WHERE clofor_com_cfs__API_Name__c =: strAPIName LIMIT 1];
        if(!lstError.isEmpty()){
           lstError.get(0).clofor_com_cfs__Call_Date__c 		= Datetime.now();
           return  lstError.get(0);
        }
        clofor_com_cfs__Call_Out_Error__c itemError = new clofor_com_cfs__Call_Out_Error__c();
		itemError.clofor_com_cfs__Status__c 		= 'NG';
		itemError.clofor_com_cfs__Error_Content__c 	= '';
		itemError.clofor_com_cfs__Call_Date__c 		= Datetime.now();
        itemError.clofor_com_cfs__API_Name__c 		= strAPIName;
		return itemError;
	}
    
    // get account 
    public static List<Account> getAccByPhone(Set<String> setPhone){
        List<Account> listAccount = new List<Account>();
        listAccount = [SELECT Id
                    					 , Name
                    					 , Phone 
                    			   FROM Account 
                    			   WHERE Phone IN :setPhone];
       return listAccount;
    }
    
    // get Account default
     public static String getAccByName(){
         List<Account> accVendor = [SELECT Id, clofor_com_cfs__EnglishCompanyName__c FROM Account WHERE clofor_com_cfs__EnglishCompanyName__c =: ConnectToAPI.Config.get('const_account') LIMIT 1];
         return accVendor.isEmpty() ? '' : accVendor.get(0).Id;
     }

	 // get Account default
     public static List<Account> getAccByListName(Set<String> setNameAcc){
         List<Account> accDestinationWarehouse = [SELECT Id, clofor_com_cfs__EnglishCompanyName__c FROM Account WHERE clofor_com_cfs__EnglishCompanyName__c =: setNameAcc];
         return accDestinationWarehouse;
     }
    
    
     // get Facility default
     public static String getFacilityByName(){
         List<Facility__c> listFac = [SELECT Id FROM Facility__c WHERE clofor_com_cfs__FacExternalID__c =: ConnectToAPI.Config.get('const_facility') LIMIT 1];
         return listFac.isEmpty() ? '' : listFac.get(0).Id;
     }
    
    // get Contract default
     public static String getContractByName(){
         List<Contract__c> listContract = [SELECT Id, Name FROM clofor_com_cfs__Contract__c WHERE clofor_com_cfs__ContractName__c =: ConnectToAPI.Config.get('const_contract') LIMIT 1];
         return listContract.isEmpty() ? '' : listContract.get(0).Id;
     }
    
    // get Facility from json
    public static List<clofor_com_cfs__Facility__c> getFacilityByFormJson(Set<String> setWarehouse, Set<String> setWarehouseDestination){
         List<clofor_com_cfs__Facility__c> lstFAC = new List<clofor_com_cfs__Facility__c>();
     	 lstFAC = [ SELECT Id, Name, clofor_com_cfs__FacilityName__c, clofor_com_cfs__FacExternalID__c 
                                                           FROM clofor_com_cfs__Facility__c 
                                                           WHERE Name IN :setWarehouse OR clofor_com_cfs__FacExternalID__c IN:setWarehouseDestination];
         return lstFAC;
     }
    
    // get Facility from json
    public static List<clofor_com_cfs__PRODUCT__c> getProductFormJson(Set<String> setProduct){
        List<clofor_com_cfs__PRODUCT__c> lstPRO = new List<clofor_com_cfs__PRODUCT__c>();
		lstPRO = [ SELECT Id, Name, clofor_com_cfs__ProductName__c 
                                                           FROM clofor_com_cfs__PRODUCT__c 
                                                           WHERE Name IN :setProduct ];
        return lstPRO;
    }
    
    // get work order by Id
    public static List<clofor_com_cfs__WorkOrder__c> getWorkOrderById(Set<Id> setId){
         List<clofor_com_cfs__WorkOrder__c> listWorkOrder = new List<clofor_com_cfs__WorkOrder__c>();
         listWorkOrder = [SELECT Id, clofor_com_cfs__WarehouseID__r.Name, clofor_com_cfs__DestinationWarehouse__r.Name,  clofor_com_cfs__DestinationWarehouse__r.clofor_com_cfs__FacExternalID__c  FROM clofor_com_cfs__WorkOrder__c WHERE Id IN :setId];
         return listWorkOrder;
    }
    
    // get truck name.
	private string getStruckName(){
		List<clofor_com_cfs__Facility__c> facilityList = new List<clofor_com_cfs__Facility__c>();
		facilityList = [SELECT clofor_com_cfs__FacilityName__c FROM clofor_com_cfs__Facility__c WHERE clofor_com_cfs__FacilityType__c = 'Mobile Warehouse'];
		return 	facilityList.isEmpty() ? '' : facilityList.get(0).clofor_com_cfs__FacilityName__c;
    }	
}