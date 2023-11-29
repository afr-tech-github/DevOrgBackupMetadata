public with sharing class GoodsSearchLightningController {
    @AuraEnabled
    public static InitiatelWrapper getInitData(){
        InitiatelWrapper result = new InitiatelWrapper();
        result.translations = getTranslationMap();
        result.cargoLifeCycles = getListCargoLifeCycle();
        return result;
    }
    
    private static List<OptionWrapper> getListCargoLifeCycle(){
        List<OptionWrapper> options = new List<OptionWrapper>();
        Schema.DescribeFieldResult fieldResult = Cargo__c.CargoLifeCycle__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(new OptionWrapper(f.getLabel(), f.getValue()));
        }
        if(!options.isEmpty()){
            options[0].isSelected = true;
        }
        return options;
    }
    private static Map<String,String> getTranslationMap(){
        String langCode = UserInfo.getLanguage();
        Map<String, Object> translate = TranslationService.getByLanguage(langCode.substringBefore('_'));
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('search_engine') || key.contains('unit_translation')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
    
    @AuraEnabled
    public static List<ProductWapper> getProducts(PRODUCT__c product, String goodsSO, String workOrders, 
                                                  				String locators, String warehouses, String expiredDate, String skuNumber, String cargoLifeCycle){
        List<String> goodsSONameList = new List<String>();
        List<String> workOrderNameList = new List<String>();
        List<String> locatorList = new List<String>();
        List<String>  warehouseList = new List<String>();
        if(!String.isBlank(goodsSO)){
            goodsSONameList = goodsSO.split(';');
        }
        if(!String.isBlank(workOrders)){
            workOrderNameList = workOrders.split(';');
        }
        if(!String.isBlank(locators)){
            locatorList = locators.split(';');
        }
        if(!String.isBlank(warehouses)){
            warehouseList = warehouses.split(';');
        }
        Set<Id> productIdSet = new Set<Id>();
        Map<Id, Map<Id,SalesOrderProduct__c>> gsProductMap = getGSProductMap(goodsSONameList, workOrderNameList);
        if(goodsSONameList.isEmpty() && !workOrderNameList.isEmpty()){
            List<ConnectWOProduct__c> listWP = [SELECT Id, WorkOrderID__c, ProductID__c, WorkOrderID__r.SalesOrderID__c,WorkOrderID__r.SalesOrderID__r.Name
                                                FROM ConnectWOProduct__c 
                                                WHERE WorkOrderID__c IN: workOrderNameList];
            for(ConnectWOProduct__c wp : listWP){
                productIdSet.add(wp.ProductID__c);
            }
            
        }else {
            productIdSet = gsProductMap.keySet();
        }
        
        List<ProductWapper> result = new List<ProductWapper>();
        String strQuery = buildQueryStock(product, productIdSet, goodsSONameList, 
                                          	workOrderNameList, locatorList, warehouseList, 
                                          	expiredDate, skuNumber, cargoLifeCycle);

        List<Stock__c> stocks = Database.query(strQuery);
        //LocatorWapper locator = new LocatorWapper();
        //ProductWapper prtWapper = new ProductWapper();
       // String nextlocatorId;
        //Date expiredDateNext;
        //Date iboundDateNext;
       // String nextProductId;
        //Integer countStock = 0;
        Map<Id, LocatorWapper> stockHaveNoLocator = new Map<Id, LocatorWapper>();

        Set<Id> productIds = new Set<Id>();
        Set<String> cargoProductMap = new Set<String>();
        Map<String,ProductWapper> productMap = new Map<String,ProductWapper>();
        String previousproductId = '';
        String previousLocatorId = '';
        String finalProduct = '';
        String finalLocator = '';
        for(Stock__c objStock : stocks){
            String key = objStock.ProductID__c + objStock.CargoID__c;
            if(!cargoProductMap.contains(key)){
                
                cargoProductMap.add(key);
                ProductWapper prtWapperNew;
                if(!productMap.containsKey(objStock.ProductID__c)){
                    if(productMap.containsKey(previousproductId)){
                        productMap.get(previousproductId).totalProductMeasurement =  productMap.get(previousproductId).totalProductMeasurement.setScale(3);
                        productMap.get(previousproductId).totalProductGrossWeight =  productMap.get(previousproductId).totalProductGrossWeight.setScale(3);
                        productMap.get(previousproductId).totalProductMeasurementIncludePlan =  productMap.get(previousproductId).totalProductMeasurementIncludePlan.setScale(3);
                        productMap.get(previousproductId).totalProductGrossWeightIncludePlan =  productMap.get(previousproductId).totalProductGrossWeightIncludePlan.setScale(3);
                        //productMap.get(previousproductId).listLocatorSize =  productMap.get(previousproductId).listLocator.size() + 1;
                    }
                    prtWapperNew = new ProductWapper();
                    prtWapperNew.product.Id = objStock.ProductID__c;
                    prtWapperNew.productName = objStock.ProductID__r.Name;
                    prtWapperNew = new ProductWapper();
                    prtWapperNew.product.Id = objStock.ProductID__c;
                    prtWapperNew.productName = objStock.ProductID__r.Name;
                    if(gsProductMap.containsKey(objStock.ProductID__c)){
                        for(SalesOrderProduct__c sop : gsProductMap.get(objStock.ProductID__c).values()){
                            ProductWapper.SOPWrapper so = new ProductWapper.SOPWrapper();
                            so.SOName = sop.GoodSalesOrderID__r.Name;					
                            so.SOId = sop.GoodSalesOrderID__c;
                            so.requiredNumber = sop.Quantity__c;
                            prtWapperNew.listSOPWrapper.add(so);
                        }
                        
                    }
                    if(!String.isBlank(objStock.ProductID__r.GoodOwner__c)){
                        prtWapperNew.goodsOwnerName = objStock.ProductID__r.GoodOwner__r.Name;
                    }
                    if(!String.isBlank(objStock.ProductID__r.Buyer__c)){
                        prtWapperNew.buyerName = objStock.ProductID__r.Buyer__r.Name;
                    }
                    
                    prtWapperNew.product.ProductName__c = objStock.ProductID__r.ProductName__c;
                    prtWapperNew.product.GoodOwner__c = objStock.ProductID__r.GoodOwner__c;
                    prtWapperNew.product.Manufacturer__c = objStock.ProductID__r.Manufacturer__c;
                    prtWapperNew.product.SKUNumber__c = objStock.ProductID__r.SKUNumber__c;
                    prtWapperNew.product.Buyer__c = objStock.ProductID__r.Buyer__c;
                    prtWapperNew.product.SerialNumber__c = objStock.ProductID__r.SerialNumber__c;
                    prtWapperNew.product.Measurement__c = objStock.ProductID__r.Measurement__c;
                    prtWapperNew.product.NETWeight__c = objStock.ProductID__r.NETWeight__c;
                    prtWapperNew.product.GrossWeight__c = objStock.ProductID__r.GrossWeight__c;
                    
                }else{
                    previousproductId = objStock.ProductID__c;
                    prtWapperNew = productMap.get(objStock.ProductID__c);
                }
                LocatorWapper locatorNew;
                if(!prtWapperNew.locatorMap.containsKey(objStock.StockLocator__c)){

                    if(prtWapperNew.locatorMap.containsKey(previousLocatorId)){
                        prtWapperNew.locatorMap.get(previousLocatorId).remainQuantity = prtWapperNew.locatorMap.get(previousLocatorId).remainQuantity > 0 ? prtWapperNew.locatorMap.get(previousLocatorId).remainQuantity : 0;
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurement = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurement > 0 ? prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurement : 0;
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeight = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeight > 0 ? prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeight : 0;
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurementIncludePlan = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurementIncludePlan > 0 ? prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurementIncludePlan : 0;
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeightIncludePlan = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeightIncludePlan > 0 ? prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeightIncludePlan : 0;

                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurement = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurement.setScale(3);
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeight = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeight.setScale(3);
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurementIncludePlan = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorMeasurementIncludePlan.setScale(3);
                        prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeightIncludePlan = prtWapperNew.locatorMap.get(previousLocatorId).totalLocatorGrossWeightIncludePlan.setScale(3);
                    }
                    locatorNew = new LocatorWapper();
                    locatorNew.remainQuantity = 0;
                    locatorNew.locatorId = objStock.StockLocator__c;
                    locatorNew.locatorCode = objStock.StockLocator__r.LocatorCode__c;
                    locatorNew.locatorName = objStock.StockLocator__r.Name;
                    locatorNew.warehouseId = objStock.StockLocator__r.WarehouseID__c;
                    locatorNew.warehouseName = objStock.StockLocator__r.WarehouseID__r.Name;
                    locatorNew.productName = objStock.ProductID__r.Name;
                    locatorNew.listStock = new List<Stock__c>();
                    
                }else{
                    previousLocatorId = objStock.StockLocator__c;
                    locatorNew = prtWapperNew.locatorMap.get(objStock.StockLocator__c);
                }
                
                locatorNew.listStock.add(objStock);
                
                if(objStock.RecordType.DeveloperName == 'StockIn'
                   && objStock.StockStatus__c == 'Completed'){
                    locatorNew.totalLocatorMeasurement += objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    locatorNew.totalLocatorGrossWeight += objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    prtWapperNew.totalProductMeasurement +=   objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    prtWapperNew.totalProductGrossWeight += objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    locatorNew.totalLocatorMeasurementIncludePlan += objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    prtWapperNew.totalProductMeasurementIncludePlan += objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    locatorNew.totalLocatorGrossWeightIncludePlan += objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    prtWapperNew.totalProductGrossWeightIncludePlan += objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;

                    locatorNew.remainQuantity += objStock.Quantity__c == null? 0 : (Integer)objStock.Quantity__c;
                    prtWapperNew.remainQuantityProduct += objStock.Quantity__c == null? 0 : (Integer)objStock.Quantity__c;

                }
                if(objStock.RecordType.DeveloperName == 'StockOut'
                   && objStock.StockStatus__c == 'Completed'){ 
                       
                    locatorNew.totalLocatorMeasurement -= objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    locatorNew.totalLocatorGrossWeight -= objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    locatorNew.totalLocatorMeasurementIncludePlan -= objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    prtWapperNew.totalProductMeasurementIncludePlan -= objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    locatorNew.totalLocatorGrossWeightIncludePlan -= objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    prtWapperNew.totalProductGrossWeightIncludePlan -= objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;   
                    locatorNew.remainQuantity -= objStock.Quantity__c == null? 0 : (Integer)objStock.Quantity__c;
                    prtWapperNew.remainQuantityProduct -= objStock.Quantity__c == null? 0 : (Integer)objStock.Quantity__c;
                    prtWapperNew.totalProductMeasurement -=   objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    prtWapperNew.totalProductGrossWeight -= objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;

                }
                if(objStock.RecordType.DeveloperName == 'StockIn'
                   && objStock.StockStatus__c == 'Planning'){
                    locatorNew.totalLocatorMeasurementIncludePlan += objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    prtWapperNew.totalProductMeasurementIncludePlan += objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    locatorNew.totalLocatorGrossWeightIncludePlan += objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    prtWapperNew.totalProductGrossWeightIncludePlan += objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                   }
                if(objStock.RecordType.DeveloperName == 'StockOut'
                   && objStock.StockStatus__c == 'Planning'){
                    locatorNew.totalLocatorMeasurementIncludePlan -= objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    prtWapperNew.totalProductMeasurementIncludePlan -= objStock.Measurement__c == null? 0: objStock.Measurement__c;
                    locatorNew.totalLocatorGrossWeightIncludePlan -= objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                    prtWapperNew.totalProductGrossWeightIncludePlan -= objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
                }
                locatorNew.listStocksize = locatorNew.listStock.size() + 1;

                prtWapperNew.locatorMap.put(objStock.StockLocator__c, locatorNew);
                finalProduct = objStock.ProductID__c;
                finalLocator = objStock.StockLocator__c;
                prtWapperNew.listLocatorSize = prtWapperNew.locatorMap.values().size() + 1;
                prtWapperNew.listLocator = prtWapperNew.locatorMap.values();
                productMap.put(objStock.ProductID__c,prtWapperNew);
            }

            LocatorWapper finalLocatorObject = productMap.get(finalProduct).locatorMap.get(finalLocator);
            finalLocatorObject.remainQuantity = finalLocatorObject.remainQuantity > 0 ? finalLocatorObject.remainQuantity : 0;
            finalLocatorObject.totalLocatorMeasurement = finalLocatorObject.totalLocatorMeasurement > 0 ? finalLocatorObject.totalLocatorMeasurement : 0;
            finalLocatorObject.totalLocatorGrossWeight = finalLocatorObject.totalLocatorGrossWeight > 0 ? finalLocatorObject.totalLocatorGrossWeight : 0;
            finalLocatorObject.totalLocatorMeasurementIncludePlan = finalLocatorObject.totalLocatorMeasurementIncludePlan > 0 ? finalLocatorObject.totalLocatorMeasurementIncludePlan : 0;
            finalLocatorObject.totalLocatorGrossWeightIncludePlan = finalLocatorObject.totalLocatorGrossWeightIncludePlan > 0 ? finalLocatorObject.totalLocatorGrossWeightIncludePlan : 0;

            finalLocatorObject.totalLocatorMeasurement = finalLocatorObject.totalLocatorMeasurement.setScale(3);
            finalLocatorObject.totalLocatorGrossWeight = finalLocatorObject.totalLocatorGrossWeight.setScale(3);
            finalLocatorObject.totalLocatorMeasurementIncludePlan = finalLocatorObject.totalLocatorMeasurementIncludePlan.setScale(3);
            finalLocatorObject.totalLocatorGrossWeightIncludePlan = finalLocatorObject.totalLocatorGrossWeightIncludePlan.setScale(3);
            
            productMap.get(finalProduct).locatorMap.put(finalLocator, finalLocatorObject);
            productMap.get(finalProduct).listLocator = productMap.get(finalProduct).locatorMap.values();
            productMap.get(finalProduct).listLocatorSize = productMap.get(finalProduct).locatorMap.values().size() + 1;
            productMap.get(finalProduct).totalProductMeasurement =  productMap.get(finalProduct).totalProductMeasurement.setScale(3);
            productMap.get(finalProduct).totalProductGrossWeight =  productMap.get(finalProduct).totalProductGrossWeight.setScale(3);
            productMap.get(finalProduct).totalProductMeasurementIncludePlan =  productMap.get(finalProduct).totalProductMeasurementIncludePlan.setScale(3);
            productMap.get(finalProduct).totalProductGrossWeightIncludePlan =  productMap.get(finalProduct).totalProductGrossWeightIncludePlan.setScale(3);
        }
        result.addAll(productMap.values());
        return result;
    }
    
    private static String buildQueryProduct(PRODUCT__c objectProductSearch, Set<Id> productIds, Set<Id> productIdSet, 
                                            List<String> goodsSONameList, List<String> workOrderNameList){
                                                String strQuery = '';
                                                String strSelect = '';
                                                String strCondition = '';
                                                strSelect = 'SELECT '
                                                    + 'Id, '
                                                    + 'Name, '
                                                    + 'ProductName__c, '
                                                    + 'GoodOwner__c, '
                                                    + 'GoodOwner__r.Name, '
                                                    + 'Manufacturer__c, '
                                                    + 'SKUNumber__c, '
                                                    + 'Buyer__c, '
                                                    + 'Buyer__r.Name, '
                                                    + 'SerialNumber__c, '
                                                    + 'Measurement__c, '
                                                    + 'NETWeight__c, '
                                                    + 'GrossWeight__c, '
                                                    + 'RollupStockIn__c, '
                                                    + 'RollupStockOut__c '
                                                    + 'FROM PRODUCT__c ';
                                                
                                                if(!String.isBlank(objectProductSearch.ProductName__c)){
                                                    strCondition = strCondition + ' AND ProductName__c like \'%' + objectProductSearch.ProductName__c + '%\'';
                                                }
                                                
                                                if(objectProductSearch.GoodOwner__c != null){
                                                    strCondition = strCondition + ' AND GoodOwner__c = \'' + objectProductSearch.GoodOwner__c + '\'';
                                                }
                                                if(objectProductSearch.Buyer__c != null){
                                                    strCondition = strCondition + ' AND Buyer__c = \'' + objectProductSearch.Buyer__c + '\'';
                                                }
                                                if(objectProductSearch.Manufacturer__c != null){
                                                    strCondition = strCondition + ' AND Manufacturer__c = \'' + objectProductSearch.Manufacturer__c + '\'';
                                                } 
                                                if(!String.isBlank(objectProductSearch.SKUNumber__c )){
                                                    strCondition = strCondition + ' AND SKUNumber__c like \'%' + objectProductSearch.SKUNumber__c + '%\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.SerialNumber__c)){
                                                    strCondition = strCondition + ' AND SerialNumber__c like \'%' + objectProductSearch.SerialNumber__c + '%\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.ItemNumber__c)){
                                                    strCondition = strCondition + ' AND ItemNumber__c like \'%' + objectProductSearch.ItemNumber__c + '%\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.LOTNumber__c)){
                                                    strCondition = strCondition + ' AND LOTNumber__c like \'%' + objectProductSearch.LOTNumber__c + '%\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.InventoryType__c)){
                                                    strCondition = strCondition + ' AND InventoryType__c = \'' + objectProductSearch.InventoryType__c + '\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.PartNumber__c)){
                                                    strCondition = strCondition + ' AND PartNumber__c like \'%' + objectProductSearch.PartNumber__c + '%\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.FastSlowClassification__c)){
                                                    strCondition = strCondition + ' AND FastSlowClassification__c = \'' + objectProductSearch.FastSlowClassification__c + '\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.ItemType__c)){
                                                    strCondition = strCondition + ' AND ItemType__c = \'' + objectProductSearch.ItemType__c + '\'';
                                                }
                                                if(!String.isBlank(objectProductSearch.DangerousClassification__c)){ 
                                                    if( objectProductSearch.DangerousClassification__c == 'No Dangerous Goods'){
                                                        strCondition = strCondition + ' AND (DangerousClassification__c = \'' + objectProductSearch.DangerousClassification__c + '\' OR DangerousClassification__c = null)';
                                                    }else{
                                                        strCondition = strCondition + ' AND DangerousClassification__c = \'' + objectProductSearch.DangerousClassification__c + '\'';
                                                    }
                                                    
                                                }
                                                if(objectProductSearch.HSCode__c != null){
                                                    strCondition = strCondition + ' AND HSCode__c = \'' + objectProductSearch.HSCode__c + '\'';
                                                }
                                                if(objectProductSearch.SKU__c != null){
                                                    strCondition = strCondition + ' AND SKU__c = \'' + objectProductSearch.SKU__c + '\'';
                                                }
                                                strCondition  = strCondition + 'AND Id NOT IN: productIds';
                                                
                                                if(!goodsSONameList.isEmpty() || !workOrderNameList.isEmpty()){
                                                    strCondition += ' AND Id IN: productIdSet';
                                                }
                                                if(strCondition != ''){
                                                    strCondition = strCondition.replaceFirst('AND', 'WHERE');
                                                }
                                                strQuery = strSelect + strCondition;
                                                return strQuery;
                                                
                                            }
    private static Map<Id, Map<Id,SalesOrderProduct__c>> getGSProductMap(List<String> goodSONames, List<String> workOrderName){
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> goodSONameSet = new Set<Id>();
        Map<Id, Map<Id,SalesOrderProduct__c>> mapresult = new Map<Id, Map<Id,SalesOrderProduct__c>>();
        if(!workOrderName.isEmpty()){
            List<ConnectWOProduct__c> listWP = [SELECT Id, WorkOrderID__c, ProductID__c, WorkOrderID__r.SalesOrderID__c,WorkOrderID__r.SalesOrderID__r.Name
                                                FROM ConnectWOProduct__c 
                                                WHERE WorkOrderID__c IN: workOrderName];
            for(ConnectWOProduct__c wp: listWP){
                if(productIdSet.contains(wp.ProductID__c)){
                    productIdSet.add(wp.ProductID__c);
                }
                if(!String.isBlank(wp.WorkOrderID__r.SalesOrderID__c)){
                    //goodSONames.add(WorkOrderID__r.SalesOrderID__r.Name);
                    goodSONameSet.add(wp.WorkOrderID__r.SalesOrderID__r.Name);
                }
            }
            
        }
        if(!goodSONames.isEmpty()){
            List<String> finalGoodSOName = new List<String>();
            if(!workOrderName.isEmpty()){
                for(String gsoName : goodSONames){
                    if(goodSONameSet.contains(gsoName)){
                        finalGoodSOName.add(gsoName);
                    }
                }
            }else {
                finalGoodSOName.addAll(goodSONames);
            }
            
            List<SalesOrderProduct__c> listSGP = [SELECT Id, ProductID__c, GoodSalesOrderID__c, GoodSalesOrderID__r.Name,
                                                  Quantity__c
                                                  FROM SalesOrderProduct__c WHERE GoodSalesOrderID__c IN: finalGoodSOName];

            for(SalesOrderProduct__c sgp : listSGP){
                Decimal quantity = sgp.Quantity__c == null? 0: sgp.Quantity__c;
                if(mapresult.containsKey(sgp.ProductID__c)){
                    //mapresult.get(sgp.ProductID__c).add(sgp);
                    if(mapresult.get(sgp.ProductID__c).containsKey(sgp.GoodSalesOrderID__c)){
                        mapresult.get(sgp.ProductID__c).get(sgp.GoodSalesOrderID__c).Quantity__c = mapresult.get(sgp.ProductID__c).get(sgp.GoodSalesOrderID__c).Quantity__c == null? 0 : mapresult.get(sgp.ProductID__c).get(sgp.GoodSalesOrderID__c).Quantity__c;
                        mapresult.get(sgp.ProductID__c).get(sgp.GoodSalesOrderID__c).Quantity__c += quantity;
                    }else{
                        mapresult.get(sgp.ProductID__c).put(sgp.GoodSalesOrderID__c, sgp);
                    }
                }else{
                    mapresult.put(sgp.ProductID__c, new Map<Id,SalesOrderProduct__c>{sgp.GoodSalesOrderID__c => sgp});
                }
            }
        }
        
        return mapresult;
    }
    
    private static String buildQueryStock(PRODUCT__c objectProductSearch, Set<Id> productIdSet, 
                                          List<String> goodsSONameList, List<String>  workOrderNameList,
                                          List<String> locatorList, List<String> warehouseList,
                                          String expiredDate, String skuNumber, String cargoLifeCycle){
                                              String strQuery = '';
                                              String strSelect = '';
                                              String strCondition = '';
                                              strSelect = 'SELECT '
                                                  + 'Id, Name, RecordType.Name, '
                                                  + 'ProductID__r.Name, '
                                                  + 'ProductID__r.ProductName__c, '
                                                  + 'ProductID__r.GoodOwner__c, '
                                                  + 'ProductID__r.GoodOwner__r.Name, '
                                                  + 'ProductID__r.Manufacturer__c, '
                                                  + 'ProductID__r.SKUNumber__c, '
                                                  + 'ProductID__r.Buyer__c, '
                                                  + 'ProductID__r.Buyer__r.Name, '
                                                  + 'ProductID__r.SerialNumber__c, '
                                                  + 'ProductID__r.Measurement__c, '
                                                  + 'ProductID__r.NETWeight__c, '
                                                  + 'ProductID__r.GrossWeight__c, '
                                                  + 'ProductID__r.RollupStockIn__c, '
                                                  + 'ProductID__r.RollupStockOut__c, '
                                                  + 'ExpireDateSKUNumber__c,'
                                                  + 'StockLocator__c, '
                                                  + 'StockLocator__r.Name, '
                                                  + 'StockLocator__r.LocatorCode__c, '
                                                  + 'StockLocator__r.WarehouseID__c, '
                                                  + 'StockLocator__r.WarehouseID__r.Name, '
                                                  + 'StockStatus__c, '
                                                  + 'RecordTypeId, '
                                                  +' ExpireDateCargo__c,'
                                                  + ' WOSLineID__c,'
                                                  + ' WOSLineID__r.Cargo__r.ExpiredDate__c,'
                                                  +' StockDate__c,'
                                                  + 'RecordType.DeveloperName, '
                                                  + 'Measurement__c, '
                                                  + 'GrossWeight__c,'
                                                  + 'Quantity__c ,'
                                                  + 'CargoID__c, '
                                                  + 'CargoName__c '
                                                  + 'FROM Stock__c ';
                                              if(!String.isBlank(expiredDate)){
                                              	strCondition += ' AND ExpireDateSKUNumber__c  = \'' + expiredDate + '\'';
                                              }
                                              if(!String.isBlank(cargoLifeCycle)){
                                              	strCondition += ' AND CargoLifeCycle__c  = \'' + cargoLifeCycle + '\'';
                                              }
                                              if(!locatorList.isEmpty()){
                                                  strCondition += ' AND StockLocator__c IN: locatorList';
                                              } 
                                              if(!warehouseList.isEmpty()){
                                                  strCondition += ' AND StockLocator__r.WarehouseID__c IN: warehouseList';
                                              } 
                                              if(!goodsSONameList.isEmpty() || !workOrderNameList.isEmpty()){
                                                  strCondition += ' AND ProductID__c IN: productIdSet';
                                              }
                                              if(!String.isBlank(objectProductSearch.ProductName__c)){
                                                  strCondition = strCondition + ' AND ProductID__r.ProductName__c like \'%' + objectProductSearch.ProductName__c + '%\'';
                                              }
                                              
                                              if(objectProductSearch.GoodOwner__c != null){
                                                  strCondition = strCondition + ' AND ProductID__r.GoodOwner__c = \'' + objectProductSearch.GoodOwner__c + '\'';
                                              }
                                              if(objectProductSearch.Buyer__c != null){
                                                  strCondition = strCondition + ' AND ProductID__r.Buyer__c = \'' + objectProductSearch.Buyer__c + '\'';
                                              }
                                              if(objectProductSearch.Manufacturer__c != null){
                                                  strCondition = strCondition + ' AND ProductID__r.Manufacturer__c = \'' + objectProductSearch.Manufacturer__c + '\'';
                                              } 
                                              if(!String.isBlank(skuNumber)){
                                                  strCondition = strCondition + ' AND ProductSKUNumber__c like \'%' + skuNumber + '%\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.SerialNumber__c)){
                                                  strCondition = strCondition + ' AND SerialNumber__c like \'%' + objectProductSearch.SerialNumber__c + '%\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.ItemNumber__c)){
                                                  strCondition = strCondition + ' AND ItemNumberFormula__c like \'%' + objectProductSearch.ItemNumber__c + '%\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.LOTNumber__c)){
                                                  strCondition = strCondition + ' AND LotNumberFormula__c like \'%' + objectProductSearch.LOTNumber__c + '%\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.InventoryType__c)){
                                                  strCondition = strCondition + ' AND ProductID__r.InventoryType__c = \'' + objectProductSearch.InventoryType__c + '\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.PartNumber__c)){
                                                  strCondition = strCondition + ' AND PartNumberFormula__c like \'%' + objectProductSearch.PartNumber__c + '%\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.FastSlowClassification__c)){
                                                  strCondition = strCondition + ' AND ProductID__r.FastSlowClassification__c = \'' + objectProductSearch.FastSlowClassification__c + '\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.ItemType__c)){
                                                  strCondition = strCondition + ' AND ProductID__r.ItemType__c = \'' + objectProductSearch.ItemType__c + '\'';
                                              }
                                              if(!String.isBlank(objectProductSearch.DangerousClassification__c)){ 
                                                  if( objectProductSearch.DangerousClassification__c == 'No Dangerous Goods'){  
                                                      strCondition = strCondition + ' AND (ProductID__r.DangerousClassification__c = \'' + objectProductSearch.DangerousClassification__c + '\' OR ProductID__r.DangerousClassification__c = null)';
                                                  }else{
                                                      strCondition = strCondition + ' AND ProductID__r.DangerousClassification__c = \'' + objectProductSearch.DangerousClassification__c + '\'';
                                                  }
                                                  
                                              }
                                              if(objectProductSearch.HSCode__c != null){
                                                  strCondition = strCondition + ' AND ProductID__r.HSCode__c = \'' + objectProductSearch.HSCode__c + '\'';
                                              }
                                              if(objectProductSearch.SKU__c != null){
                                                  strCondition = strCondition + ' AND ProductID__r.SKU__c = \'' + objectProductSearch.SKU__c + '\'';
                                              }
                                              
                                              strCondition = strCondition + ' AND (StockStatus__c = \'Completed\' OR StockStatus__c = \'Planning\')';
                                              strCondition = strCondition + ' AND ProductID__c != null';
                                              //strCondition =+ 'AND RecordTypeId.Name = \'StockIn \'';
                                              //strCondition = strCondition + ' Order by ProductID__c, CargoID__c, StockDate__c desc,StockLocator__c,ExpireDateCargo__c NULLS FIRST';
                                              strCondition = strCondition + ' Order by ProductID__c, CargoID__c, StockDate__c desc,RecordTypeId asc, StockLocator__c,ExpireDateCargo__c NULLS FIRST ';
                                              
                                              if(strCondition != ''){
                                                  strCondition = strCondition.replaceFirst('AND', 'WHERE');
                                              }
                                              strQuery = strSelect + strCondition + 'Limit 7500';
                                              return strQuery;
                                          }
    public class OptionWrapper{
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public string value{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}
       public OptionWrapper (String label, String value){
           this.label = label;
           this.value = value;
           this.isSelected = false;
       }
    }

    public class InitiatelWrapper{
        @AuraEnabled
        public Map<string,String> translations{get;set;}
        @AuraEnabled
        public List<OptionWrapper> cargoLifeCycles{get;set;}
       public InitiatelWrapper (){
           this.translations = new Map<string,String>();
           this.cargoLifeCycles = new List<OptionWrapper>();
       }
    }
    
}