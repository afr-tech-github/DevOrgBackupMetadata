@RestResource(urlMapping='/api/Cargo')
global with sharing class SendCargoAPI {
    @HttpGet
    global static String doGetCargo() {
        try{
            Date processDate = System.today();
            if (RestContext.request.params.containsKey('processdate')) {
                processDate = Date.parse(RestContext.request.params.get('processdate'));
            }
            return new SendCargoApiService().execute(processDate);
        } catch(Exception ex){
            // Create error
            clofor_com_cfs__Call_Out_Error__c error = CreateData.createError('CARGO API');
            error.clofor_com_cfs__Error_Content__c 	= ex.getMessage();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getLineNumber();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getStackTraceString();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getTypeName();
		    FlsService.doUpsert(error);
            return 'Error';
        }
    }

    public class SendCargoApiService {
        public String execute(Date processDate) {
            List<Map<String, Object>> response = new List<Map<String, Object>>();
            for(WorkOrder__c wo :[                
                SELECT Id, Name, SalesOrderId__c, WarehouseId__r.Name, WarehouseId__r.FacilityName__c, DestinationWarehouse__r.FacilityName__c, DestinationWarehouse__r.Name, (
                    SELECT Id, FinalQuantity__c, FinalNetWeight__c,
                        ProductID__c, ProductID__r.Name, ProductID__r.ProductName__c, ProductID__r.UnitType__c, ProductID__r.BillingType__c, ProductID__r.WeightUnit__c
                    FROM CONNECT_WORK_ORDER_PRODUCT__r
                    WHERE ProductID__r.BillingType__c != NULL 
                        AND ( 
                            (ProductID__r.BillingType__c = 'Unit' AND FinalQuantity__c != NULL) OR 
                            (ProductID__r.BillingType__c = 'Weight' AND FinalNetWeight__c != NULL AND ProductID__r.WeightUnit__c != NULL )
                        )
                )
                FROM WorkOrder__c
                WHERE SalesOrderId__c != NULL
                    AND RecordType.DeveloperName = 'Transfer'
                    AND ActualDate__c = :processDate
            ]) {
                if (wo.CONNECT_WORK_ORDER_PRODUCT__r.isEmpty()) {
                    continue;
                }
                List<Map<String, Object>> products = new List<Map<String, Object>>();
			    for (ConnectWOProduct__c item : wo.CONNECT_WORK_ORDER_PRODUCT__r) {
                    Decimal weight = Util.ConvertWeightToBaseUnit(item.ProductID__r.WeightUnit__c, item.FinalNetWeight__c);
                    products.add(new Map<String, Object> {
                        'ProPricingId' => item.ProductID__r.Name,
                        'ProductUnitType' => item.ProductID__r.UnitType__c,
                        'ProductTotalQuantityPerUnit' => item.ProductID__r.BillingType__c == 'Unit' ? item.FinalQuantity__c : weight,
                        'ProductName' => item.ProductID__r.ProductName__c,
                        'ProductNetWeight' => weight
                    });
                }
                response.add(new Map<String, Object> {
                    'Warehouse' => new Map<String, Object> {
                        'WorkOrderName' => wo.Name,
                        'FacilityName' => wo.DestinationWarehouse__r.FacilityName__c,
                        'DestinationWarehouseName' => wo.DestinationWarehouse__r.Name
                    },
                    'Product' => products
                });
            }
            return JSON.serialize(response);
        }
    }

    /*
	@HttpGet
    global static String doGetCargo() {
        try{
            Date currentDate = System.today();
            List<clofor_com_cfs__Cargo__c> lstCargo = new List<clofor_com_cfs__Cargo__c>();
            lstCargo = [SELECT Id 
                       			,clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.clofor_com_cfs__DestinationWarehouse__r.clofor_com_cfs__FacilityName__c
                                ,clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.clofor_com_cfs__DestinationWarehouse__r.Name
                                ,clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.Name
                                ,clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderService__r.Name
                                ,clofor_com_cfs__Product__r.Name
                                ,clofor_com_cfs__Product__r.clofor_com_cfs__QuantityPerUnit__c
                                ,clofor_com_cfs__Product__r.clofor_com_cfs__ProductName__c
                                ,clofor_com_cfs__Product__r.clofor_com_cfs__UnitType__c
                                ,clofor_com_cfs__Product__r.clofor_com_cfs__GrossWeight__c
                        		,clofor_com_cfs__Product__r.clofor_com_cfs__NETWeightGram__c
                                ,clofor_com_cfs__ManufacturedDate__c
                                ,clofor_com_cfs__ExpiredDate__c
                        		,clofor_com_cfs__Product__c
                        		,clofor_com_cfs__LastWosLineItem__c
                        		,clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderService__c
                       FROM clofor_com_cfs__Cargo__c
                       WHERE clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderService__r.clofor_com_cfs__Status__c = 'Completed'
                       AND clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__CargoStatus__c = 'Completed'
                       AND clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderService__r.RecordType.DeveloperName = 'TransferDispatch'
                       AND clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.clofor_com_cfs__ActualDate__c =: currentDate];
        	Map<String, JsonObject> mapJson = new Map<String, JsonObject>();
            for(clofor_com_cfs__Cargo__c cargo : lstCargo){
                String strKey = '';
                strKey += cargo.clofor_com_cfs__Product__c;
                strKey += cargo.clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderService__c;
                if(mapJson.containsKey(strKey)){
                    if(cargo.clofor_com_cfs__Product__r.clofor_com_cfs__QuantityPerUnit__c != null){
                        mapJson.get(strKey).ProductTotalQuantityPerUnit += cargo.clofor_com_cfs__Product__r.clofor_com_cfs__QuantityPerUnit__c;
                    }
                    if(cargo.clofor_com_cfs__Product__r.clofor_com_cfs__NETWeightGram__c != null){
                        mapJson.get(strKey).ProductNetWeight += cargo.clofor_com_cfs__Product__r.clofor_com_cfs__NETWeightGram__c;
                    }
                }else{
                   mapJson.put(strKey, new JsonObject(cargo));
                }
            }
            
            Map<String, jsonDataIntergrate> mapDataIntegration = new Map<String, jsonDataIntergrate>();
            for(JsonObject jsObject : mapJson.values()){
                JsonProduct  jsPro = new JsonProduct(jsObject);
                if(mapDataIntegration.containsKey(jsObject.WorkOrderServiceName)){
                    mapDataIntegration.get(jsObject.WorkOrderServiceName).Product.add(jsPro);
                }else{
                    jsonDataIntergrate jsData = new jsonDataIntergrate(jsObject);
                    jsData.Product.add(jsPro);
                    mapDataIntegration.put(jsObject.WorkOrderServiceName, jsData);
                }
            }
            return System.JSON.serialize(mapDataIntegration.values());
        }catch(Exception ex){
            // Create error
            clofor_com_cfs__Call_Out_Error__c error = CreateData.createError('CARGO API');
            error.clofor_com_cfs__Error_Content__c 	= ex.getMessage();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getLineNumber();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getStackTraceString();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getTypeName();
            upsert error;
            return 'Error';
        }
    }
    Private class JsonObject{
		Private String  FacilityName{get; set;}
        Private String  DestinationWarehouseName{get; set;}
        Private String  WorkOrderName{get; set;}
		Private String  WorkOrderServiceName{get; set;}
		Private String  ProPricingId{get; set;}
      	Private Decimal ProductTotalQuantityPerUnit{get; set;}
        Private String  ProductName{get; set;}
        Private String  ProductUnitType{get; set;}
        Private Decimal ProductGrossWeight{get; set;}
        Private Decimal ProductNetWeight{get; set;}
        Private Date  	CargoManufacturedDate{get; set;}
        Private Date  	CargoExpiredDate{get; set;}
        private JsonObject(clofor_com_cfs__Cargo__c recCargo){
           	FacilityName					= recCargo.clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.clofor_com_cfs__DestinationWarehouse__r.clofor_com_cfs__FacilityName__c ;
            DestinationWarehouseName		= recCargo.clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.clofor_com_cfs__DestinationWarehouse__r.Name ;
            WorkOrderName					= recCargo.clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderID__r.Name ;
            WorkOrderServiceName			= recCargo.clofor_com_cfs__LastWosLineItem__r.clofor_com_cfs__WorkOrderService__r.Name;
            ProPricingId					= recCargo.clofor_com_cfs__Product__r.Name;
            ProductTotalQuantityPerUnit		= recCargo.clofor_com_cfs__Product__r.clofor_com_cfs__QuantityPerUnit__c;
            ProductName						= recCargo.clofor_com_cfs__Product__r.clofor_com_cfs__ProductName__c;
            ProductUnitType					= recCargo.clofor_com_cfs__Product__r.clofor_com_cfs__UnitType__c;
            ProductGrossWeight				= recCargo.clofor_com_cfs__Product__r.clofor_com_cfs__GrossWeight__c;
            CargoManufacturedDate			= recCargo.clofor_com_cfs__ManufacturedDate__c;
            CargoExpiredDate				= recCargo.clofor_com_cfs__ExpiredDate__c;
            ProductNetWeight 				= recCargo.clofor_com_cfs__Product__r.clofor_com_cfs__NETWeightGram__c;
		}
	}
    Private class JsonProduct{
        Private String ProPricingId{get; set;}
        Private String ProductName{get; set;}
        Private String ProductUnitType{get; set;}
        Private Decimal ProductTotalQuantityPerUnit{get; set;}
        // Private Decimal ProductGrossWeight{get; set;}
        Private Decimal ProductNetWeight{get; set;}
        //Private Date 	CargoManufacturedDate{get; set;}
        //Private Date 	CargoExpiredDate{get; set;}
        Private JsonProduct(JsonObject js){
            proPricingId 				= js.proPricingId;
        	ProductName					= js.ProductName;
        	ProductUnitType				= js.ProductUnitType;
            ProductTotalQuantityPerUnit	= js.ProductTotalQuantityPerUnit;
            //ProductGrossWeight		= js.ProductGrossWeight;
        	ProductNetWeight			= js.ProductNetWeight;
        	//CargoManufacturedDate		= js.CargoManufacturedDate;
            //CargoExpiredDate			= js.CargoExpiredDate;
        }
    }
    
    Private class jsonWarehouse{
        Private String  FacilityName{get; set;}
        Private String  DestinationWarehouseName{get; set;}
        Private String  WorkOrderName{get; set;}
        Private String  WorkOrderServiceName{get; set;}
        Private jsonWarehouse(JsonObject js){
            FacilityName 				= js.FacilityName;
        	DestinationWarehouseName 	= js.DestinationWarehouseName;
            WorkOrderName 				= js.WorkOrderName;
        	WorkOrderServiceName 		= js.WorkOrderServiceName;
        }
    }
    
    Private class jsonDataIntergrate{
        Private jsonWarehouse Warehouse{get; set;}
        Private List<JsonProduct> Product{get; set;}
        Private jsonDataIntergrate(JsonObject js){
            Warehouse = new jsonWarehouse(js);
            Product = new List<JsonProduct>();
        }
    }
    */
}