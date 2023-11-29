@RestResource(urlMapping='/truckmarket/v2')
global with sharing class TruckMarketApiV2 {
	@HttpPOST
    global static string insertProductPerTruck() {
        return JSON.serialize(new TruckMarketApiService().execute(RestContext.request.requestBody.tostring()));
    }

    public class TruckMarketApiService {
        Integer counter { get; set; }
        String apiTime { get; set; }
        Contract__c contractVendor { get; set; }
        Map<String, Schema.RecordTypeInfo> mapRtWo { get; set; }
        Map<String, Schema.RecordTypeInfo> mapRtWos { get; set; }

        public TruckMarketApiService() {
            this.apiTime        = String.valueOf(System.now().getTime());
            this.counter        = 0;
            this.contractVendor = getVendorContract();
            this.mapRtWo        = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByDeveloperName();
            this.mapRtWos       = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName();
        }

        public TruckMarketWrapper.TruckMarketResponse execute(String bodyRequest) {
            TruckMarketWrapper.TruckMarketResponse response = new TruckMarketWrapper.TruckMarketResponse();
            Savepoint sp = Database.setSavepoint();
            try{
                TruckMarketWrapper truckWrapper = TruckMarketWrapper.parse(bodyRequest);
                if (truckWrapper.Warehouses == null) {
                    throw new CustomException('Invalid request. Empty request body.');
                }

                this.transformToSfData(truckWrapper);

                List<SObject> listToInsert        = new List<SObject>();
                List<SObject> listToInsert_Po     = new List<SObject>();
                List<SObject> listToInsert_PoProd = new List<SObject>();
                List<SObject> listToInsert_So     = new List<SObject>();
                List<SObject> listToInsert_SoProd = new List<SObject>();
                List<SObject> listToInsert_Wo     = new List<SObject>();
                List<SObject> listToInsert_WoProd = new List<SObject>();
                List<SObject> listToInsert_Wos    = new List<SObject>();

                List<String>  listWosTypeForPo = new String[] { 'InboundReceiving','Putaway' };
                List<String>  listWosTypeForSo = new String[] { 'Picking','TransferDispatch','TransferReceiving','Putaway' };
                
                Integer loopVar_Counter = 0;
                for(TruckMarketWrapper.Warehouse warehouse : truckWrapper.Warehouses){ 
                    //DONE - insert PO
                    GoodsPurchasingOrder__c poRef = new GoodsPurchasingOrder__c(External_Id__c = this.newExtId());
                    listToInsert_Po.add(new GoodsPurchasingOrder__c(
                        External_Id__c        = poRef.External_Id__c,
                        Supplier__c           = warehouse.SfAccount.Id,
                        ContractID__c         = contractVendor.Id,
                        Quantity__c           = warehouse.Sum_Quantity,
                        WeightUnit__c         = 'Kg',
                        RecommendNetWeight__c = Util.convertWeightFromBaseUnit('Kg', warehouse.Sum_Weight)
                    ));

                    //DONE - insert WO Inbound linked to PO
                    WorkOrder__c woRef_Inbound = new WorkOrder__c(External_Id__c = this.newExtId());
                    listToInsert_Wo.add(new WorkOrder__c(
                        PurchasingOrderID__r = poRef,
                        External_Id__c       = woRef_Inbound.External_Id__c,
                        RecordTypeId         = mapRTWO.get('Inbound').getRecordTypeId(),
                        Customer__c          = warehouse.SfAccount.Id,
                        WarehouseID__c       = warehouse.SfWarehouse.Id,
                        Quantity__c          = warehouse.Sum_Quantity,
                        WeightUnit__c        = 'Kg',
                        NETWeight__c         = Util.convertWeightFromBaseUnit('Kg', warehouse.Sum_Weight)
                    ));

                    //DONE - insert WOS Receiving/Putaway
                    loopVar_Counter = 0;
                    for (String wosType : listWosTypeForPo){
                        listToInsert_Wos.add(new WorkOrderService__c(
                            RecordTypeId       = mapRTWOS.get(wosType).getRecordTypeId(),
                            WorkOrder__r       = woRef_Inbound,
                            Warehouse__c       = warehouse.SfWarehouse.Id,
                            PlannedQuantity__c = warehouse.Sum_Quantity,
                            InitialQuantity__c = warehouse.Sum_Quantity,
                            Order__c           = loopVar_Counter++
                        ));
                    }

                    for(TruckMarketWrapper.Product product : warehouse.Sum_Products){
                        //DONE - insert PO Products
                        listToInsert_PoProd.add(new GoodsPOProduct__c(
                            GoodsPOID__r          = poRef,
                            ProductID__c          = product.SfProduct.Id,
                            Quantity__c           = product.Sum_Quantity,
                            RecommendNetWeight__c = Util.convertWeightFromBaseUnit(product.SfProduct.BuyingWeightUnit__c, product.Sum_Weight)
                        ));

                        //DONE - insert WO Inbound Products
                        listToInsert_WoProd.add(new ConnectWOProduct__c(
                            WorkOrderID__r = woRef_Inbound,
                            ProductID__c   = product.SfProduct.Id,
                            Quantity__c    = product.Sum_Quantity,
                            NETWeightKG__c = Util.convertWeightFromBaseUnit(product.SfProduct.BuyingWeightUnit__c, product.Sum_Weight)
                        ));
                    }

                    for(TruckMarketWrapper.Destination destination : warehouse.Destinations){
                        //DONE - insert SO
                        SALES_ORDER__c soRef = new SALES_ORDER__c(External_Id__c = this.newExtId());
                        listToInsert_So.add(new SALES_ORDER__c(
                            External_Id__c         = soRef.External_Id__c,
                            OrderIntExtType__c     = 'Internal',
                            CustomerCompanyName__c = warehouse.SfAccount.Id,
                            ContractID__c          = contractVendor.Id,
                            Quantity__c            = destination.Sum_Quantity
                        ));

                        //DONE - insert WO Transfer linked to SO
                        WorkOrder__c woRef_Transfer = new WorkOrder__c(External_Id__c = this.newExtId());
                        listToInsert_Wo.add(new WorkOrder__c(
                            SalesOrderId__r         = soRef,
                            External_Id__c          = woRef_Transfer.External_Id__c,
                            RecordTypeId            = mapRTWO.get('Transfer').getRecordTypeId(),
                            Customer__c             = warehouse.SfAccount.Id,
                            WarehouseID__c          = warehouse.SfWarehouse.Id,
                            DestinationWarehouse__c = destination.sfWarehouse.Id,
                            Quantity__c             = destination.Sum_Quantity
                        ));

                        //DONE - insert WOS Picking / Transfer Dispatch / Transfer Receiving / Putaway
                        loopVar_Counter = 0;
                        for (String wosType : listWosTypeForSo){
                            listToInsert_Wos.add(new WorkOrderService__c(
                                RecordTypeId            = mapRTWOS.get(wosType).getRecordTypeId(),
                                WorkOrder__r            = woRef_Transfer,
                                Warehouse__c            = (wosType == 'Picking' || wosType == 'TransferDispatch') ? warehouse.SfWarehouse.Id : destination.SfWarehouse.Id,
                                DestinationWarehouse__c = (wosType == 'TransferDispatch') ? destination.SfWarehouse.Id : null,
                                PlannedQuantity__c      = destination.Sum_Quantity,
                                InitialQuantity__c      = destination.Sum_Quantity,
                                Order__c                = loopVar_Counter++
                            ));
                        }

                        for(TruckMarketWrapper.Product product : destination.ProductOrder){
                            //DONE - insert SO Products
                            listToInsert_SoProd.add(new SalesOrderProduct__c(
                                GoodSalesOrderID__r   = soRef,
                                ProductID__c          = product.SfProduct.Id,
                                Quantity__c           = product.Sum_Quantity,
                                RecommendNetWeight__c = Util.convertWeightFromBaseUnit(product.SfProduct.WeightUnit__c, product.Sum_Weight)
                            ));

                            //DONE - insert WO Transfer Products
                            listToInsert_WoProd.add(new ConnectWOProduct__c(
                                WorkOrderID__r = woRef_Transfer,
                                ProductID__c   = product.SfProduct.Id,
                                Quantity__c    = product.Sum_Quantity,
                                NETWeightKG__c = Util.convertWeightFromBaseUnit(product.SfProduct.WeightUnit__c, product.Sum_Weight)
                            ));
                        }
                    }
                }

                //concatenate all lists at the end to ensure records of the same sobject type are together in the insert
                listToInsert.addAll(listToInsert_Po);
                listToInsert.addAll(listToInsert_So);
                listToInsert.addAll(listToInsert_Wo);
                listToInsert.addAll(listToInsert_Wos);

                //insert the PO/SO/WO+Product separately since too many chunks in each list
                FlsService.doInsert(listToInsert);
                FlsService.doInsert(listToInsert_PoProd);
                FlsService.doInsert(listToInsert_SoProd);
                FlsService.doInsert(listToInsert_WoProd);

                response.status = true;
            }
            catch(Exception ex){
                response.status = false;
                response.errMessage = ex.getMessage() + ex.getTypeName() + ex.getStackTraceString();
                Database.rollback(sp);
            }

            return response;
        }
        
        void transformToSfData(TruckMarketWrapper source) {
            Set<String> setAccount   = new Set<String>();
            Set<String> setTruckDB   = new Set<String>();
            Set<String> setProductDB = new Set<String>();
            
            //extract record names
            for(TruckMarketWrapper.Warehouse warehouse : source.Warehouses){
                setTruckDB.add(warehouse.OriginWarehouseID);
                setAccount.add(warehouse.AccountName);

                for(TruckMarketWrapper.Destination des : warehouse.Destinations){
                    setTruckDB.add(des.DestinationWarehouseID);
                    for(TruckMarketWrapper.Product pro : des.ProductOrder){
                        setProductDB.add(pro.ProductID);
                    }
                    /*
                    for(TruckMarketWrapper.Customer cus : des.Customers){
                        setAccount.add(cus.AccountName);
                        
                        for(TruckMarketWrapper.Product pro : cus.ProductSold){
                            setProductDB.add(pro.ProductID);
                        }
                    }
                    */
                }
            }

            Map<String, Account> mapAccount      = new Map<String, Account>();
            Map<String, Facility__c> mapTruckDB  = new Map<String, Facility__c>();
            Map<String, Product__c> mapProductDB = new Map<String, Product__c>();

            //get map of records based on above names
            for(Account acc : [SELECT Id, Name, EnglishCompanyName__c FROM Account WHERE EnglishCompanyName__c IN :setAccount]){
                mapAccount.put(acc.EnglishCompanyName__c, acc);
            }
            for(Facility__c fac : [ SELECT Id, FacExternalID__c FROM Facility__c WHERE FacExternalID__c IN :setTruckDB ]){
                mapTruckDB.put(fac.FacExternalID__c, fac);
            }
            for(PRODUCT__c pro : [ SELECT Id, Name, ProductName__c, WeightUnit__c, BillingType__c, BuyingWeightUnit__c FROM PRODUCT__c WHERE Name IN :setProductDB ]){
                mapProductDB.put(pro.Name, pro);
            }

            //check any key misses value
            setAccount.removeAll(mapAccount.keySet());
            if (!setAccount.isEmpty()) {
                throw new CustomException('AccountName (' + String.join(new List<String>(setAccount), ', ') + ') does not exist');
            }
            setTruckDB.removeAll(mapTruckDB.keySet());
            if (!setTruckDB.isEmpty()) {
                throw new CustomException('Warehouse (' + String.join(new List<String>(setTruckDB), ', ') + ') does not exist');
            }
            setProductDB.removeAll(mapProductDB.keySet());
            if (!setProductDB.isEmpty()) {
                throw new CustomException('Product (' + String.join(new List<String>(setProductDB), ', ') + ') does not exist');
            }

            //populate salesforce record to request body structure and aggregate product quantity/weight along the way
            for(TruckMarketWrapper.Warehouse warehouse : source.Warehouses){
                warehouse.Sum_Quantity = warehouse.Sum_Weight = 0;
                warehouse.Sum_Products = new List<TruckMarketWrapper.Product>();
                warehouse.SfWarehouse = mapTruckDB.get(warehouse.OriginWarehouseID);
                warehouse.SfAccount = mapAccount.get(warehouse.AccountName);

                //generate list of products order per warehouse, this is not available in request body
                Map<String, TruckMarketWrapper.Product> mapProducts = new Map<String, TruckMarketWrapper.Product>();

                for(TruckMarketWrapper.Destination destination : warehouse.Destinations){
                    destination.Sum_Quantity = destination.Sum_Weight = 0;
                    destination.SfWarehouse = mapTruckDB.get(destination.DestinationWarehouseID);
                    for(TruckMarketWrapper.Product product : destination.ProductOrder){
                        product.SfProduct = mapProductDB.get(product.ProductID);

                        if (mapProductDB.get(product.ProductID).BillingType__c == 'Unit') {
                            product.Sum_Quantity = product.Amount;
                            product.Sum_Weight   = 0;
                        }
                        else {
                            product.Sum_Quantity = 1;
                            product.Sum_Weight   = product.Amount;
                        }
                        //rollup to destination
                        destination.Sum_Quantity += product.Sum_Quantity;
                        destination.Sum_Weight   += product.Sum_Weight;

                        //roll up to warehouse but grouped by product
                        TruckMarketWrapper.Product rollUpProduct = mapProducts.get(product.ProductID);
                        if (rollUpProduct == null) {
                            rollUpProduct = new TruckMarketWrapper.Product();
                            rollUpProduct.SfProduct = product.SfProduct;
                            rollUpProduct.Sum_Quantity = rollUpProduct.Sum_Weight = 0;
                            mapProducts.put(product.ProductID, rollUpProduct);
                        }
                        rollUpProduct.Sum_Quantity += product.Sum_Quantity;
                        rollUpProduct.Sum_Weight   += product.Sum_Weight;
                    }
                    //rollup to warehouse
                    warehouse.Sum_Quantity += destination.Sum_Quantity;
                    warehouse.Sum_Weight   += destination.Sum_Weight;

                    //customer selling data
                    /*
                    for(TruckMarketWrapper.Customer customer : destination.Customers){
                        customer.Sum_Quantity = customer.Sum_Weight = 0;
                        customer.SfAccount = mapAccount.get(customer.AccountName);
                        for(TruckMarketWrapper.Product product : customer.ProductSold){
                            product.SfProduct = mapProductDB.get(product.ProductID);

                            if (mapProductDB.get(product.ProductID).BillingType__c == 'Unit') {
                                product.Sum_Quantity = product.Amount;
                                product.Sum_Weight   = 0;
                            }
                            else {
                                product.Sum_Quantity = 1;
                                product.Sum_Weight   = product.Amount;
                            }
                            customer.Sum_Quantity += product.Sum_Quantity;
                            customer.Sum_Weight   += product.Sum_Weight;
                        }
                    }
                    */
                }

                warehouse.Sum_Products = mapProducts.values();
            }
        }

        String newExtId() {
            return this.apiTime + this.counter++;
        }

        Contract__c getVendorContract() {
            try {
                return Test.isRunningTest() 
                    ? [SELECT Id, Name FROM Contract__c LIMIT 1]
                    : [SELECT Id, Name FROM Contract__c WHERE Name =: ConnectToAPI.Config.get('const_contract') LIMIT 1];
            } 
            catch (QueryException ex) {
                throw new CustomException('Cannot find vender Contract');
            }
        }
    }
}