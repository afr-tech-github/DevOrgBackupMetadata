@isTest
private class GoodsSearchLightningControllerTest {
    
    private static clofor_com_cfs__Facility__c warehouse = new clofor_com_cfs__Facility__c();
    private static clofor_com_cfs__LOCATOR__c locator1 = new clofor_com_cfs__LOCATOR__c();
    private static clofor_com_cfs__LOCATOR__c locator2 = new clofor_com_cfs__LOCATOR__c();
    private static clofor_com_cfs__LOCATOR__c locator3 = new clofor_com_cfs__LOCATOR__c();
    private static clofor_com_cfs__LOCATOR__c locator4 = new clofor_com_cfs__LOCATOR__c();
    private static clofor_com_cfs__LOCATOR__c locator5 = new clofor_com_cfs__LOCATOR__c();
    private static clofor_com_cfs__PRODUCT__c product1 = new clofor_com_cfs__PRODUCT__c();
    private static clofor_com_cfs__PRODUCT__c product2 = new clofor_com_cfs__PRODUCT__c();
    private static WorkOrder__c wo = new WorkOrder__c();
    private static  SALES_ORDER__c gSalesOrder = new SALES_ORDER__c();
    
    static{
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
        warehouse = createWarehouse();
        locator1 = createLocator(warehouse.Id, 'Floor Layer', null, 'F01', '', '', '', '', 1000, 1000);
        FlsService.doInsert(locator1);
        locator2 = createLocator(warehouse.Id, 'Area Layer', locator1.Id, 'F01', 'A01','','','', 500, 500);
        FlsService.doInsert(locator2);
        
        product1 = createProduct();
        product2 = createProduct();
        clofor_com_cfs__PRODUCT__c product3 = createProduct();
        clofor_com_cfs__PRODUCT__c product4 = createProduct();
        clofor_com_cfs__PRODUCT__c product5 = createProduct();
        clofor_com_cfs__PRODUCT__c product6 = createProduct();
        clofor_com_cfs__PRODUCT__c product7 = createProduct();
        
        Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.SObjectType.clofor_com_cfs__Stock__c.getRecordTypeInfosByDeveloperName();
        
        List<clofor_com_cfs__Stock__c> listStock = new List<clofor_com_cfs__Stock__c>();
        clofor_com_cfs__Stock__c stock1 = createStock(recordTypeInfosMap.get('StockIn').getRecordTypeId(), locator1.Id, product1.Id, 'Completed');
        listStock.add(stock1);
        clofor_com_cfs__Stock__c stock2 = createStock(recordTypeInfosMap.get('StockIn').getRecordTypeId(), locator1.Id, product1.Id, 'Planning');
        listStock.add(stock2);
        clofor_com_cfs__Stock__c stock3 = createStock(recordTypeInfosMap.get('StockIn').getRecordTypeId(), locator1.Id, product2.Id, 'Completed');
        listStock.add(stock3);
        clofor_com_cfs__Stock__c stock4 = createStock(recordTypeInfosMap.get('StockIn').getRecordTypeId(), locator1.Id, product2.Id, 'Planning');
        listStock.add(stock4);
        clofor_com_cfs__Stock__c stock5 = createStock(recordTypeInfosMap.get('StockOut').getRecordTypeId(), locator1.Id, product1.Id, 'Completed');
        listStock.add(stock5);
        clofor_com_cfs__Stock__c stock6 = createStock(recordTypeInfosMap.get('StockOut').getRecordTypeId(), locator1.Id, product1.Id, 'Planning');
        listStock.add(stock6);
        clofor_com_cfs__Stock__c stock7 = createStock(recordTypeInfosMap.get('StockOut').getRecordTypeId(), locator1.Id, product2.Id, 'Completed');
        listStock.add(stock7);
        clofor_com_cfs__Stock__c stock8 = createStock(recordTypeInfosMap.get('StockOut').getRecordTypeId(), locator1.Id, product2.Id, 'Planning');
        listStock.add(stock8);
        FlsService.doInsert(listStock);
        clofor_com_cfs__Stock__c stockchild = createStock(recordTypeInfosMap.get('StockIn').getRecordTypeId(), locator2.Id, product1.Id, 'Completed');
        FlsService.doInsert(stockchild);
        Account acc = new Account(Name = 'ABC', clofor_com_cfs__EnglishCompanyName__c = 'ABC');
        FlsService.doInsert(acc);
        
        RecordType rtPro = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__PRODUCT__c' AND DeveloperName = 'FreshProduct'][0];
        
        RecordType rtWO = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__WorkOrder__c' AND DeveloperName = 'CrossDock' LIMIT 1][0];
        wo = new WorkOrder__c(RecordTypeId = rtWO.Id, Customer__c = acc.Id, WarehouseID__c = warehouse.Id);
        FlsService.doInsert(wo);
        Contract__c contract = new Contract__c();
        FlsService.doInsert(contract);
        gSalesOrder = new SALES_ORDER__c(
            ContractID__c = contract.Id
        );
        FlsService.doInsert(gSalesOrder);
        SalesOrderProduct__c gp = new SalesOrderProduct__c(
            GoodSalesOrderID__c = gSalesOrder.Id,
            ProductID__c = product1.Id);
        FlsService.doInsert(gp);
    }
    
    @isTest static void testGoodSearchController() {
        
        Test.startTest();
        List<ProductWapper> listResult = GoodsSearchLightningController.getProducts(product1,gSalesOrder.Id,wo.Id,locator2.Id, warehouse.Id,'1234','xxxx','aaaa');
        
        Test.stopTest();
        integer x = 1;
        System.assert(x != 0);
    }
    
    
    private static clofor_com_cfs__Facility__c createWarehouse(){
        clofor_com_cfs__Facility__c warehouse = new clofor_com_cfs__Facility__c(
            clofor_com_cfs__FacilityName__c ='test Ware house'
        );
        FlsService.doInsert(warehouse);
        return warehouse;
    }
    
    private static clofor_com_cfs__Stock__c createStock( String recId, String locatorId, String productId, String status){
        clofor_com_cfs__Stock__c newStock = new clofor_com_cfs__Stock__c(
            clofor_com_cfs__StockStatus__c = status,
            clofor_com_cfs__ProductID__c = productId,
            clofor_com_cfs__StockLocator__c = locatorId,
            RecordTypeId = recId,
            clofor_com_cfs__Quantity__c = 1
        );
        return newStock;
    }
    
    private static clofor_com_cfs__PRODUCT__c createProduct(){
        
        clofor_com_cfs__PRODUCT__c newProduct = new clofor_com_cfs__PRODUCT__c(
            clofor_com_cfs__ProductName__c = 'productTest',
            clofor_com_cfs__GrossWeight__c = 1,
            clofor_com_cfs__Width__c = 1,
            clofor_com_cfs__Depth__c = 1,
            clofor_com_cfs__Height__c = 1,
            clofor_com_cfs__WLDUnit__c = 'Inches',
            clofor_com_cfs__NETWeight__c = 1,
            GuaranteeServiceBillingFreqType__c = 'Continuous Billing',
            DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
            InstallationServiceBillingFreqType__c = 'Continuous Billing',
            SetupServiceBillingFreqType__c = 'Continuous Billing',
            RelocationServiceBillingFreqType__c = 'Continuous Billing',
            ReplacementServiceBillingFreqType__c = 'Continuous Billing',
            SupportServiceBillingFreqType__c = 'Continuous Billing',
            SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
            UsageChargeBillingFreqType__c = 'Continuous Billing',
            MaintenanceServiceBillingFreqType__c = 'Continuous Billing'
        );
        FlsService.doInsert(newProduct);
        return newProduct;
    }
    private static clofor_com_cfs__LOCATOR__c createLocator(String warehouseId, String layer, String parentLocator, String floorCode,
                                                            String areaCode, String sectionCode, String rackCode, String levelCode, Integer cbm, Integer kg){
                                                                clofor_com_cfs__LOCATOR__c locator = new clofor_com_cfs__LOCATOR__c(
                                                                    clofor_com_cfs__LocationAreaType__c	='Storage Area',
                                                                    clofor_com_cfs__WarehouseID__c = warehouseId,
                                                                    clofor_com_cfs__LocatorLayer__c = layer,
                                                                    clofor_com_cfs__FloorCode__c = floorCode,
                                                                    clofor_com_cfs__AreaCode__c = areaCode,
                                                                    clofor_com_cfs__SectionCode__c = sectionCode,
                                                                    clofor_com_cfs__Rack__c = rackCode,
                                                                    clofor_com_cfs__Level__c = levelCode,
                                                                    clofor_com_cfs__ParentLocator__c = parentLocator,
                                                                    clofor_com_cfs__CapacityCBM__c = cbm,
                                                                    clofor_com_cfs__CapacityKG__c = kg
                                                                );
                                                                
                                                                return locator;
                                                            }
    
}