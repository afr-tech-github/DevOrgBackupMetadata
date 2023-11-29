@isTest
private class ProductTriggerHelperTest {
    
    private static clofor_com_cfs__Facility__c warehouse = new clofor_com_cfs__Facility__c();
    private static clofor_com_cfs__LOCATOR__c locator1 = new clofor_com_cfs__LOCATOR__c();
    private static clofor_com_cfs__PRODUCT__c product1 = new clofor_com_cfs__PRODUCT__c();
    
    
    static{
        warehouse = createWarehouse();
        locator1 = createLocator(warehouse.Id, 'Floor Layer', null, 'F01', '', '', '', '', 1000, 1000);
        FlsService.doInsert(locator1);
        
        product1 = createProduct();
        
        Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.SObjectType.clofor_com_cfs__Stock__c.getRecordTypeInfosByDeveloperName();
        
        List<clofor_com_cfs__Stock__c> listStock = new List<clofor_com_cfs__Stock__c>();
        clofor_com_cfs__Stock__c stock1 = createStock(recordTypeInfosMap.get('StockIn').getRecordTypeId(), locator1.Id, product1.Id, 'Completed');
        listStock.add(stock1);
        clofor_com_cfs__Stock__c stock2 = createStock(recordTypeInfosMap.get('StockOut').getRecordTypeId(), locator1.Id, product1.Id, 'Completed');
        listStock.add(stock2);
        FlsService.doInsert(listStock);
    }
    @isTest static void rollUpStockInAndOutNumberMethodTest() {
        // Implement test code
        Test.startTest();
        product1.RollupStockOut__c = 0;
        product1.RollupStockIn__c = 0;
        FlsService.doUpdate(product1);
        System.assert(product1 != null);
        Test.stopTest();
    }
    
    @isTest static void test_method_one() {
        // Implement test code
        Test.startTest();
        PRODUCT__c product = createProduct();
        System.assert(product != null);
        Test.stopTest();
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
            MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
            GuaranteeServiceBillingFreqType__c = 'Continuous Billing',
            DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
            InstallationServiceBillingFreqType__c = 'Continuous Billing',
            SetupServiceBillingFreqType__c = 'Continuous Billing',
            RelocationServiceBillingFreqType__c = 'Continuous Billing',
            ReplacementServiceBillingFreqType__c = 'Continuous Billing',
            SupportServiceBillingFreqType__c = 'Continuous Billing',
            SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
            UsageChargeBillingFreqType__c = 'Continuous Billing'
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