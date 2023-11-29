global with sharing class TruckMarketSchedulable implements Schedulable, Database.AllowsCallouts { 
	final static String STR_ENDPOINT_TRUCK = 'https://api.3ffood.com/closcm/truck/orders';
    final static String STR_ENDPOINT_TRUCK_DEV = 'http://apidev.3ffood.com/closcm/all/orders'; // for test
    final static String STR_AUTH_PARAMETER_URL = 'truck_name={0}&uid={1}&&sid={2}';
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */
    global void execute() {
        System.enqueueJob(new CalloutAsync());
    }
	global void execute(SchedulableContext ctx) { // SchedulableContext sc
        System.enqueueJob(new CalloutAsync());
	}

    public class CalloutAsync implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            try {
                Object result = new ConnectToAPI().initGet(ConnectToAPI.Config.get('api_order')).invoke();
                TruckMarketWrapper.TruckMarketResponse apiResponse = new TruckMarketApiV2.TruckMarketApiService().execute(JSON.serialize(result));
                if (!apiResponse.status) {
                    throw new CustomException(apiResponse.errMessage);
                }
            } catch (Exception ex) {
                FlsService.doInsert(new Call_Out_Error__c(API_Name__c = ConnectToAPI.Config.get('api_order'), Error_Content__c = ex.getMessage()));
            }
        }
    }

    // create data.
    private  String ProcessInsertProductPerTruck(String bodyRequest){
        Set<String> setWarehouse 									= new Set<String>();
		Set<String> setWarehouseDestination 						= new Set<String>();
		Set<String> setWarehouseDestinationName 					= new Set<String>();
        Set<String> setProduct 										= new Set<String>();
        Set<String> setAccount 										= new Set<String>();
        Map<String, Decimal> mapTotalSold 							= new Map<String, Decimal>();
        Map<String, Decimal> mapTotalOrder 							= new Map<String, Decimal>();
        Map<String, Decimal> mapPerProSold 							= new Map<String, Decimal>();
        Map<String, Decimal> mapPerProOrder 						= new Map<String, Decimal>();
        Map<String, Decimal> mapPerProAndCus 						= new Map<String, Decimal>();
        Map<String, Decimal> mapTotalSoldByCus 						= new Map<String, Decimal>();
        Map<String, Decimal> mapProSold 							= new Map<String, Decimal>();
        Map<String, Decimal> mapProSoldByOrigin 					= new Map<String, Decimal>();
        Map<String, Decimal> mapProPerTruck 						= new Map<String, Decimal>();
        List<clofor_com_cfs__WorkOrder__c> lstWOOutbound 			= new List<clofor_com_cfs__WorkOrder__c>();
		clofor_com_cfs__WorkOrder__c workOrderOutbound 				= new clofor_com_cfs__WorkOrder__c();
		Map<String, clofor_com_cfs__WorkOrder__c> mapWOOutbound 	= new Map<String, clofor_com_cfs__WorkOrder__c>();
		clofor_com_cfs__WorkOrder__c workOrderInbound 				= new clofor_com_cfs__WorkOrder__c();
		List<clofor_com_cfs__WorkOrder__c> lstWOTransfer 			= new List<clofor_com_cfs__WorkOrder__c>();
		clofor_com_cfs__WorkOrder__c workOrderTransfer 				= new clofor_com_cfs__WorkOrder__c();
		Map<String, clofor_com_cfs__WorkOrder__c> mapWOTransfer 	= new Map<String, clofor_com_cfs__WorkOrder__c>();		
		clofor_com_cfs__SALES_ORDER__c  salesTransfer 				= new clofor_com_cfs__SALES_ORDER__c();
		Map<String, clofor_com_cfs__SALES_ORDER__c> mapTotalByDesWH = new Map<String, clofor_com_cfs__SALES_ORDER__c>();
		SALES_ORDER__c salesExternal 								= new SALES_ORDER__c();
		Map<String, SALES_ORDER__c> mapSOExternal 					= new Map<String, SALES_ORDER__c>();
		clofor_com_cfs__GoodsPurchasingOrder__c goodPO 				= new clofor_com_cfs__GoodsPurchasingOrder__c();
		Map<String, Decimal> mapProByWH 							= new Map<String, Decimal>();
		TruckMarketWrapper.TruckMarketResponse response 			= new TruckMarketWrapper.TruckMarketResponse();
		
		// TRANSFER
		clofor_com_cfs__SalesOrderProduct__c goodSO 				= new clofor_com_cfs__SalesOrderProduct__c();
		Map<String, clofor_com_cfs__SalesOrderProduct__c> mapGoodSO = new Map<String, clofor_com_cfs__SalesOrderProduct__c>();
		clofor_com_cfs__ConnectWOProduct__c woProTransfer 			= new clofor_com_cfs__ConnectWOProduct__c();
		List<clofor_com_cfs__ConnectWOProduct__c> lstWOProTransfer 	= new List<clofor_com_cfs__ConnectWOProduct__c>();
		clofor_com_cfs__Stock__c stockOut 							= new clofor_com_cfs__Stock__c();
		List<clofor_com_cfs__Stock__c> lstStockOut 					= new List<clofor_com_cfs__Stock__c>();
		Stock__c stockIn 											= new Stock__c();
		List<Stock__c> lstStockIn 									= new List<Stock__c>();
		clofor_com_cfs__ConnectWOProduct__c woProOut 				= new clofor_com_cfs__ConnectWOProduct__c();
		List<clofor_com_cfs__ConnectWOProduct__c> lstWOProOut 		= new List<clofor_com_cfs__ConnectWOProduct__c>();
		clofor_com_cfs__WorkOrderService__c WOSOutDispatch 			= new clofor_com_cfs__WorkOrderService__c();
		Map<String, clofor_com_cfs__WorkOrderService__c> mapWOSOutDispatch = new Map<String, clofor_com_cfs__WorkOrderService__c>();
		WorkOrderService__c WOSTransferPicking 						= new WorkOrderService__c();
		WorkOrderService__c WOSTransferPutaway 						= new WorkOrderService__c();
		List<WorkOrderService__c> lstWOSTransfer 					= new List<WorkOrderService__c>();
		SalesOrderProduct__c goodSOExternal 						= new SalesOrderProduct__c();
		List<SalesOrderProduct__c> lstGoodSOExternal 				= new List<SalesOrderProduct__c>();
		
		// INBOUND
		clofor_com_cfs__GoodsPOProduct__c goodsPOProduct 			= new clofor_com_cfs__GoodsPOProduct__c();
		List<GoodsPOProduct__c> lstGoodPOProduct 					= new List<GoodsPOProduct__c>();
		List<clofor_com_cfs__Stock__c> lstStockInbound 				= new List<clofor_com_cfs__Stock__c>();
		clofor_com_cfs__Stock__c stockInbound 						= new clofor_com_cfs__Stock__c();
		clofor_com_cfs__Call_Out_Error__c error 					= new clofor_com_cfs__Call_Out_Error__c();		
		
		Decimal decTotalInbound 				= 0;
		Decimal decTotalOutbound 				= 0;
        Decimal totalProductSoldForTruck 		= 0;
        Decimal totalProductOrderForTruck 		= 0;
        Decimal decAmountPerProPerTruckSold 	= 0;
        Decimal decAmountPerProPerTruckOrder 	= 0;
        Decimal totalByCus 						= 0;
        String EMPTY 							= ''; 
		      
        Savepoint sp = Database.setSavepoint();
		String  OriginWarehouseID = '';
        try{
            TruckMarketWrapper truckWrapper = TruckMarketWrapper.parse(bodyRequest);
            if(truckWrapper != null && truckWrapper.Warehouses != null){               
				// get map record type
				Map<String, String> mapRecordType = CreateData.getMapRecordType();
                for(TruckMarketWrapper.Warehouse warehouse : truckWrapper.Warehouses){
                    response.totalOriginWarehouse++;
                    setWarehouse.add(warehouse.OriginWarehouseID);
					OriginWarehouseID = warehouse.OriginWarehouseID;
                    //setAccount.add(warehouse.AccountName);
                    for(TruckMarketWrapper.Destination des : warehouse.Destinations){
						setWarehouseDestination.add(des.DestinationWarehouseID);
                        //setWarehouse.add(des.DestinationWarehouseID);
						setWarehouseDestinationName.add(des.DestinationWarehouseName.toUpperCase());
                        totalProductOrderForTruck = 0;

                        for(TruckMarketWrapper.Product pro : des.ProductOrder){
                            setProduct.add(pro.ProductID);
                            totalProductOrderForTruck += pro.Amount;
                            mapPerProOrder.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID + '_' + pro.ProductID, 
                                                pro.Amount);
                        }

                        mapTotalOrder.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID, totalProductOrderForTruck);

                        totalProductSoldForTruck = 0;

                        for(TruckMarketWrapper.Customer cus : des.Customers){
                            //setAccount.add(cus.AccountName);
							setAccount.add(cus.Mobile);
                            totalByCus = 0;
                            for(TruckMarketWrapper.Product proSold : cus.ProductSold){
                                setProduct.add(proSold.ProductID);

                                totalProductSoldForTruck += proSold.Amount;
                                totalByCus += proSold.Amount;

                                mapPerProAndCus.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID + '_' + cus.AccountID + '_' + proSold.ProductID, 
                                                    proSold.Amount);

                                String key = warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID + '_' + proSold.ProductID;
                                if(!mapProPerTruck.containsKey(key)){
                                    mapProPerTruck.put(key, 0);
                                }
                                mapProPerTruck.put(key, mapProPerTruck.get(key) + proSold.Amount);
                                if(mapProSold.containsKey(proSold.ProductID) == false){
                                    mapProSold.put(proSold.ProductID,  proSold.Amount);
                                }else{
									mapProSold.put(proSold.ProductID, mapProSold.get(proSold.ProductID) + proSold.Amount);
								}
                                if(!mapProSoldByOrigin.containsKey(warehouse.OriginWarehouseID + '_' + proSold.ProductID)){
                                    mapProSoldByOrigin.put(warehouse.OriginWarehouseID + '_' + proSold.ProductID, 0);
                                }
                                mapProSoldByOrigin.put(warehouse.OriginWarehouseID + '_' + proSold.ProductID, 
                                                        mapProSoldByOrigin.get(warehouse.OriginWarehouseID + '_' + proSold.ProductID) + proSold.Amount);
                            }

                            mapTotalSoldByCus.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID + '_' + cus.AccountID, totalByCus);
                        }

                        mapTotalSold.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID, totalProductSoldForTruck);
                    }
                    
                }
                // Create error
                error = CreateData.createError('TRUCK MARKER API');
                error.clofor_com_cfs__Error_Content__c = EMPTY;

				// get map account by DestinationWarehouseName
				Map<String, String> mapAccountByDestinationWarehouseName = new Map<String, String>();
				for(Account acc : CreateData.getAccByListName(setWarehouseDestinationName)){
					mapAccountByDestinationWarehouseName.put(acc.clofor_com_cfs__EnglishCompanyName__c, acc.Id);
				}


				//  Check exits DestinationWarehouse account 
				if(mapAccountByDestinationWarehouseName.isEmpty()){
					error.clofor_com_cfs__Error_Content__c 	= 'Account of Destination warehouse is not exist. Please check again';
                    FlsService.doInsert(error);
                    return '';
				}
				// Check exits account default
                if(String.isEmpty(CreateData.getAccByName())){
                    error.clofor_com_cfs__Error_Content__c 	= 'Not find Account for Vendor';
                    FlsService.doInsert(error);
                    return '';
                }
                
                // Create map Account from Database
                Map<String, String> mapAccount = new Map<String, String>();
                for(Account acc : CreateData.getAccByPhone(setAccount)){
                   mapAccount.put(acc.Phone, acc.Id);
                }
                
                // Check exist Account from Database
                if(mapAccount.isEmpty()){
                    error.clofor_com_cfs__Error_Content__c 	= 'AccountName is not exist. Please check AccountName';
                    FlsService.doInsert(error);
                    return '';
                }

                // Check exits Facility default
                if(String.isBlank(CreateData.getFacilityByName())){
                    error.clofor_com_cfs__Error_Content__c 	= 'FAC Vendor is not exist. Please check FAC Vendor';
                    FlsService.doInsert(error);
                    return '';
                }
                
                // Check exits Contract default
                if(String.isBlank(CreateData.getContractByName())){
                    error.clofor_com_cfs__Error_Content__c 	= 'ContractID is not exist. Please check ContractID';
                    FlsService.doInsert(error);
                    return '';
                }
                
                // Create map Warshouse from Database
                Map<String, String> mapTruckDB = new Map<String, String>();
				Map<String, String> mapTruckDBByExternalId = new Map<String, String>();
                for(clofor_com_cfs__Facility__c fac : CreateData.getFacilityByFormJson(setWarehouse, setWarehouseDestination)){
                    mapTruckDB.put(fac.Name, fac.Id);
					mapTruckDBByExternalId.put(fac.clofor_com_cfs__FacExternalID__c, fac.Id);
                }
				
				// Check exits Warshouse from Database
                if(mapTruckDB.isEmpty()){
                    error.clofor_com_cfs__Error_Content__c 	= 'Warehouse is not exist. Please check Warehouse';
                    FlsService.doInsert(error);
                    return '';
                } 
                
                // Create map product form Database.
                Map<String, String> mapProductDB = new Map<String, String>();
                for(clofor_com_cfs__PRODUCT__c pro : CreateData.getProductFormJson(setProduct)){
                    mapProductDB.put(pro.Name, pro.Id);
                }
                

                // WorkOrder
                for(TruckMarketWrapper.Warehouse warehouse : truckWrapper.Warehouses){ 
                    for(TruckMarketWrapper.Destination des : warehouse.Destinations){
                        /*for(TruckMarketWrapper.Customer cus : des.Customers){	
							// Sales Order External
                            salesExternal = new SALES_ORDER__c();
							salesExternal = CreateData.createSalesOrder('External'
																 , mapAccount.get(cus.Mobile)
																 , CreateData.getContractByName()
																 , mapTotalSoldByCus.get(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID + '_' + cus.AccountID));
                            mapSOExternal.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID + '_' + cus.AccountID, salesExternal);
							
                        }*/

						if(!des.ProductOrder.isEmpty()){
							// Sales Order Internal
							salesTransfer = new clofor_com_cfs__SALES_ORDER__c();
							salesTransfer = CreateData.createSalesOrder('Internal'
																  , mapAccountByDestinationWarehouseName.get(des.DestinationWarehouseName.toUpperCase())
																  , CreateData.getContractByName()
																  , mapTotalOrder.get(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID));
							mapTotalByDesWH.put(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID, salesTransfer);
						
						
						
							// Work order transfer
							workOrderTransfer = new clofor_com_cfs__WorkOrder__c();
							workOrderTransfer = CreateData.createWorkOder(mapRecordType.get('Transfer')
																	, CreateData.getAccByName()
																	, CreateData.getFacilityByName()
																	, mapTruckDBByExternalId.get(des.DestinationWarehouseID)
																	, mapTotalOrder.get(warehouse.OriginWarehouseID + '_' + des.DestinationWarehouseID));
							lstWOTransfer.add(workOrderTransfer);
						}
                    }

                }
				
                // Create Goods Purchasing Order
                goodPO.RecordTypeId 										= mapRecordType.get('StandardGoodsPurchasingOrder');
                goodPO.clofor_com_cfs__Quantity__c 							= decTotalInbound;
                goodPO.clofor_com_cfs__OrderIntExtType__c 					= 'Internal';
                goodPO.clofor_com_cfs__DestinationWarehouseID__c 			= CreateData.getFacilityByName();
                goodPO.clofor_com_cfs__DeliveryTargetDateToWarehouse__c 	= Date.today().addDays(7);
                if(!lstWOTransfer.isEmpty() && mapTotalByDesWH.size() > 0 ){ // && mapSOExternal.size() > 0
                    FlsService.doInsert(lstWOTransfer);
                    //insert mapSOExternal.values();
                    FlsService.doInsert(mapTotalByDesWH.values());
                    FlsService.doInsert(goodPO);
                    
                    Set<Id> setIdTransfer = (new Map<Id,clofor_com_cfs__WorkOrder__c>(lstWOTransfer)).keySet();
					for(clofor_com_cfs__WorkOrder__c wo : CreateData.getWorkOrderById(setIdTransfer)){
                        mapWOTransfer.put(OriginWarehouseID  + '_' + wo.clofor_com_cfs__DestinationWarehouse__r.clofor_com_cfs__FacExternalID__c , wo);                            
                    }
                    
                }else{
                    error.clofor_com_cfs__Error_Content__c 	= 'Can not create Work Order';
                    FlsService.doInsert(error);
                    return '';
                }

                for(String item : mapProSold.keySet()){
                    goodsPOProduct = new clofor_com_cfs__GoodsPOProduct__c();
					goodsPOProduct = CreateData.createGoodsPOProduct(goodPO.Id, mapProductDB.get(item), mapProSold.get(item));
                    lstGoodPOProduct.add(goodsPOProduct);
                }
				
                for(String item : mapProSoldByOrigin.keySet()){
                    List<String> lstKey = new List<String>();
                    lstKey = item.split('_');
                    stockInbound = new clofor_com_cfs__Stock__c();
					stockInbound = CreateData.createStock(mapRecordType.get('StockIn')
													, mapTruckDB.get(lstKey[0])
													, mapProductDB.get(lstKey[1])
													, mapProSoldByOrigin.get(item)
													, '');                                               
                    lstStockInbound.add(stockInbound);
                }
                if(!lstStockInbound.isEmpty()){
                   // insert lstStockInbound;
				}
                if(!lstGoodPOProduct.isEmpty()){
                    FlsService.doInsert(lstGoodPOProduct);
                }
           
                for(String key : mapPerProOrder.keySet()){
                    List<String> lstKey = new List<String>();
                    lstKey = key.split('_');
					// create Sales Order Product External
                    goodSOExternal = new clofor_com_cfs__SalesOrderProduct__c();
					goodSOExternal = CreateData.createSalesOrderProduct(mapTotalByDesWH.get(lstKey[0] + '_' + lstKey[1]).Id
																	  , mapProductDB.get(lstKey[2])
																	  , mapPerProOrder.get(key));
                    lstGoodSOExternal.add(goodSOExternal);

                }

                FlsService.doInsert(lstGoodSOExternal);

				Integer i = 0;

                for(String key : mapPerProOrder.keySet()){
					i++;
                    List<String> lstKey = new List<String>();
                    lstKey = key.split('_');
					String strKey = lstKey[0] + '_' + lstKey[1];
					String strKeyZero = lstKey[0];
					String strKeyOne = lstKey[1];
					String strKeyTwo = lstKey[2];
					
					// create Sales Order Product
                    goodSO = new clofor_com_cfs__SalesOrderProduct__c();
					goodSO = CreateData.createSalesOrderProduct(mapTotalByDesWH.get(strKey).Id
														  , mapProductDB.get(strKeyTwo)
														  , mapPerProOrder.get(key));
                    mapGoodSO.put(key, goodSO);
					// Create Connect WO Product Transfer
                    woProTransfer = new clofor_com_cfs__ConnectWOProduct__c();
					woProTransfer = CreateData.createConnectWOProduct(mapWOTransfer.get(strKey).Id
																, mapProductDB.get(strKeyTwo)
																, mapPerProOrder.get(key));
                    lstWOProTransfer.add(woProTransfer);

                    //OUTBOUND
					Decimal numQuantity = mapProPerTruck.containsKey(key) == false ? 0 : mapProPerTruck.get(key);
                    stockOut = new clofor_com_cfs__Stock__c();
					stockOut = CreateData.createStock( mapRecordType.get('StockOut')
												, mapTruckDB.get(strKeyOne)
												, mapProductDB.get(strKeyTwo)
												, numQuantity
												, 'Completed');
                    
                    lstStockOut.add(stockOut);
                    
                    //INBOUND
                    stockIn = new Stock__c();
					stockIn = CreateData.createStock( mapRecordType.get('StockIn')
												, mapTruckDB.get(strKeyZero)
												, mapProductDB.get(strKeyTwo)
												, mapPerProOrder.get(key)
												, 'Planning');
                    lstStockIn.add(stockIn);
					
                    if(!mapWOSOutDispatch.containsKey(strKey)){
						
						// Work Order Picking
						WOSTransferPicking = new WorkOrderService__c();
						WOSTransferPicking = CreateData.createWorkOrderService(mapRecordType.get('Picking')
																		 , mapWOTransfer.get(strKey).Id
																		 , mapTruckDB.get(strKeyZero)
																		 , mapTotalOrder.get(strKey)
																		 , mapTotalOrder.get(strKey)
																		 , mapTruckDBByExternalId.get(strKeyOne)
																		 , mapTotalSold.get(strKey));
						lstWOSTransfer.add(WOSTransferPicking);
                        
						// Work Order Putaway
						WOSTransferPutaway = new WorkOrderService__c();
						WOSTransferPutaway = CreateData.createWorkOrderService(mapRecordType.get('Putaway')
																		 , mapWOTransfer.get(strKey).Id
																		 , mapTruckDB.get(strKeyZero)
																		 , mapTotalOrder.get(strKey)
																		 , mapTotalOrder.get(strKey)
																		 , mapTruckDBByExternalId.get(strKeyOne)
																		 , mapTotalSold.get(strKey));
                        lstWOSTransfer.add(WOSTransferPutaway);
                    }
 
                }
				if(!lstWOProTransfer.isEmpty()){
                    FlsService.doInsert(lstWOProTransfer);
				}
                if( !mapGoodSO.isEmpty() && !lstStockOut.isEmpty() && !lstWOProOut.isEmpty() 
					&& !mapWOSOutDispatch.isEmpty() && !lstStockIn.isEmpty() && !lstWOSTransfer.isEmpty()){
                    FlsService.doInsert(mapGoodSO.values());
                    FlsService.doInsert(lstStockOut);
                    FlsService.doInsert(lstStockIn);
                    FlsService.doInsert(lstWOProOut);
                    FlsService.doInsert(mapWOSOutDispatch.values());
                    FlsService.doInsert(lstWOSTransfer);
                }
                if(String.isBlank(error.clofor_com_cfs__Error_Content__c)){
                 	error.clofor_com_cfs__Status__c 		= 'OK';   
                }
                FlsService.doInsert(error);
            }
        }
        catch(Exception ex){
            error.clofor_com_cfs__Error_Content__c 	= ex.getMessage();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getLineNumber();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getStackTraceString();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getTypeName();
            FlsService.doInsert(error);
            return '';
        }
        return '';
    }
}