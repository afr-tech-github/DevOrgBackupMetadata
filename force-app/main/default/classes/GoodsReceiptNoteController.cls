public with sharing class GoodsReceiptNoteController {
    public Site_Custom_Settings__c siteSetting {get; set;}
    public WorkOrder__c wo {get; set;}
    public WorkOrderService__c wos {get; set;}
    public Map<String, Node> mapNode {get; set;}
    public Total total {get; set;}
    List<ConnectWOProduct__c> workOrderProductList {get; set;}
    private String prmWOSID {get; set;}
    private String woId {get; set;}
    public Map<String, String> translations{get; set;}
    public GoodsReceiptNoteController(){
        translations = new Map<String, String>();
		translations = getTranslationMap();
        mapNode = new Map<String, Node>();
        total = new Total();
        workOrderProductList = new List<ConnectWOProduct__c>();
        siteSetting = Site_Custom_Settings__c.getOrgDefaults();
        prmWOSID = ApexPages.currentPage().getParameters().get('id');
        wos = getWorkOrderService(prmWOSID);
        if(!String.isBlank(wos.WorkOrder__c)){
            woId = wos.WorkOrder__c;
        }
        if(!String.isBlank(woId)){
            initData();
        }
        
    }
    public Map<String,String> getTranslationMap(){
        String langCode = UserInfo.getLanguage();
        Map<String, Object> translate = TranslationService.getByLanguage(langCode.substringBefore('_'));
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('summary_note') || key.contains('unit_translation')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
    private void initData(){
        
        workOrderProductList = getConnectWOProduct();
        Map<String, Decimal> mapPlanQuantityProduct= new Map<String, Decimal>();
        for(ConnectWOProduct__c wop : workOrderProductList){
            Decimal quantity = wop.Quantity__c == null? 0:wop.Quantity__c;
            if(mapPlanQuantityProduct.containsKey(wop.ProductID__c)){
                Decimal currentQuantity = mapPlanQuantityProduct.get(wop.ProductID__c) + quantity;
                mapPlanQuantityProduct.put(wop.ProductID__c, currentQuantity);
            }else {
                mapPlanQuantityProduct.put(wop.ProductID__c, quantity);
            }
        }
        List<WOSLineItem__c> lstWOSLine = getAllWOSLineByWOS(prmWOSID);
        Node node = new Node();
        for(WOSLineItem__c line : lstWOSLine){
            if(!mapNode.containsKey(line.Cargo__r.Product__c)){
                node = new Node();
                // if(!siteSetting.SwitchToInternalBarCodePhoto__c){
                //     node.ProductQRImage = line.Cargo__r.Product__r.QR_Image__c;
                // }else{
                //     if(line.Cargo__r.Product__r.CodeImageType__c != 'Barcode'){
                //         node.ProductQRImage = line.Cargo__r.Product__r.QRCodeImage__c;
                //     }else {
                //         node.ProductQRImage = line.Cargo__r.Product__r.BarCodeImage__c;
                //     }
                // }
                //; 
                node.ProductQRImage = line.Cargo__r.Product__r.QR_Image__c;
                node.ProductId = line.Cargo__r.Product__c;
                node.CodeImageType = line.Cargo__r.Product__r.CodeImageType__c;
                node.Product = line.Cargo__r.Product__r.Name;
                node.ProductBarcode = line.Cargo__r.Product__r.QR_Code__c;
                node.ProductName = line.Cargo__r.Product__r.ProductName__c;
                node.Type = line.Cargo__r.Product__r.UnitType__c;
                node.PlanQuantity = mapPlanQuantityProduct.containsKey(line.Cargo__r.Product__c)? mapPlanQuantityProduct.get(line.Cargo__r.Product__c):0;
                node.NetWeight = line.Cargo__r.Product__r.NETWeight__c != null ? line.Cargo__r.Product__r.NETWeight__c : 0;
                node.GrossWeight = line.Cargo__r.Product__r.GrossWeight__c != null ? line.Cargo__r.Product__r.GrossWeight__c : 0;
                node.Measurement = line.Cargo__r.Product__r.Measurement__c != null ? line.Cargo__r.Product__r.Measurement__c : 0;
                mapNode.put(line.Cargo__r.Product__c, node);
            }else {
                mapNode.get(line.Cargo__r.Product__c).NetWeight += (line.Cargo__r.Product__r.NETWeight__c != null ? line.Cargo__r.Product__r.NETWeight__c : 0);
                mapNode.get(line.Cargo__r.Product__c).GrossWeight += (line.Cargo__r.Product__r.GrossWeight__c != null ? line.Cargo__r.Product__r.GrossWeight__c : 0);
                mapNode.get(line.Cargo__r.Product__c).Measurement += (line.Cargo__r.Product__r.Measurement__c != null ? line.Cargo__r.Product__r.Measurement__c : 0);
            }
        }
        
        for(Node item : mapNode.values()){
            total.totalPlanQuantity += item.PlanQuantity;
            total.totalNetWeight += (item.NetWeight != null ? item.NetWeight : 0);
            total.totalGrossWeight += (item.GrossWeight != null ? item.GrossWeight : 0);
            total.totalMeasurement += (item.Measurement != null ? item.Measurement : 0);
        }
    }
    private List<ConnectWOProduct__c> getConnectWOProduct(){
        List<ConnectWOProduct__c> WOProducts = [SELECT Id, ProductID__c, Quantity__c 
                                                FROM ConnectWOProduct__c
                                                WHERE WorkOrderID__c =: woId];
        return WOProducts;
        
    }
    private WorkOrderService__c getWorkOrderService(String strId){
        List<WorkOrderService__c> lstWOS = new List<WorkOrderService__c>();
        
        lstWOS = [ SELECT Id, Name, WorkOrder__c, WorkOrder__r.Name, WorkOrder__r.WarehouseID__c, WorkOrder__r.WarehouseID__r.Address__c, WorkOrder__r.WarehouseID__r.Name, WorkOrder__r.WarehouseID__r.FacilityName__c, 
                        WorkOrder__r.PurchasingOrderID__r.POQRLabel__c,WorkOrder__r.PurchasingOrderID__c,  Locator__c, Locator__r.Name, Locator__r.LocatorCode__c,
                        WorkOrder__r.PurchasingOrderID__r.PurchasingOrderNumber__c, WorkOrder__r.PurchasingOrderID__r.CreatedBy.Name,WorkOrder__r.PurchasingOrderID__r.CreatedBy.Email,
                 		WorkOrder__r.PurchasingOrderID__r.GoodsPurchasingOrderDate__c, WorkOrder__r.PurchasingOrderID__r.Name, WorkOrder__r.PurchasingOrderID__r.Supplier__r.AccountNumber, 
                 		WorkOrder__r.PurchasingOrderID__r.CSCDType__c, WorkOrder__r.PurchasingOrderID__r.Supplier__r.Name, WorkOrder__r.PurchasingOrderID__r.Supplier__r.EnglishAddress__c, 
                        WorkOrder__r.PurchasingOrderID__r.Supplier__r.Phone,WorkOrder__r.PurchasingOrderID__r.DeliveryTargetDateToWarehouse__c,
                        WorkOrder__r.LastModifiedBy.Name, WorkOrder__r.LastModifiedBy.Email 
                	FROM WorkOrderService__c
                	WHERE Id =: strId];
        
        if(!lstWOS.isEmpty()){
            return lstWOS.get(0);
        }
        return new WorkOrderService__c();
    }
    public Billing__c getBill(){
        List<Billing__c> bills = [SELECT ID, WorkOrderServiceID__c, PaymentTo__c, PaymentTo__r.Name,
                                    PaymentTo__r.BillingStreet, PaymentTo__r.BillingState, PaymentTo__r.BillingCity, 
                                    PaymentTo__r.BillingCountry, PaymentTo__r.BillingPostalCode, PaymentTo__r.Phone
                                    FROM Billing__c WHERE WorkOrderServiceID__c =: prmWOSID];
        if(!bills.isEmpty()){
            return bills[0];
        }
        return new Billing__c();
    }
    private List<WOSLineItem__c> getAllWOSLineByWOS(String strWOId){
        List<WOSLineItem__c> lstWOSLine = new List<WOSLineItem__c>();
        lstWOSLine = [ SELECT Id, WorkOrderService__r.WorkOrder__c,Cargo__r.Product__r.QR_Code__c, WorkOrderService__c, Cargo__r.Product__c, Cargo__r.Product__r.Name, Cargo__r.Product__r.ProductName__c, Cargo__r.ProductDetails__c,
                      			WorkOrderService__r.TypeUnit__c, Cargo__r.Product__r.QuantityPerUnit__c, WorkOrderService__r.GrossWeightKG__c, WorkOrderService__r.NETWeightKG__c,
                                Cargo__r.Product__r.GrossWeight__c, Cargo__r.Product__r.NETWeight__c,  Cargo__r.Product__r.Measurement__c,
                                Cargo__r.Product__r.CodeImageType__c, Cargo__r.Product__r.BarCodeImage__c, Cargo__r.Product__r.QRCodeImage__c,
                      			WorkOrderService__r.Measurement__c, Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c,
                      			Cargo__r.Product__r.TaxRateBuying__c, Cargo__r.Product__r.UnitType__c, Cargo__r.Product__r.QR_Image__c
                        FROM WOSLineItem__c 
                        WHERE WorkOrderService__c = :strWOId 
                        AND WorkOrderService__r.RecordType.DeveloperName = 'InboundReceiving'];
        return lstWOSLine;
    }
    
    public class Total{
        public Decimal totalPlanQuantity {get; set;}
        public Decimal totalNetWeight {get; set;}
        public Decimal totalGrossWeight {get; set;}
        public Decimal totalMeasurement {get; set;}
        
        public Total(){
            this.totalPlanQuantity = 0;
            this.totalNetWeight = 0;
            this.totalGrossWeight = 0;
            this.totalMeasurement = 0;
            
        }
    }
    
    public class Node{
        public String CodeImageType{get;set;}
        public String ProductId{get;set;}
        public String Product {get; set;}
        public String ProductName {get; set;}
        public String Type {get; set;}
        public Decimal PlanQuantity {get; set;}
        public Decimal GrossWeight {get; set;}
        public Decimal NetWeight {get; set;}
        public Decimal Measurement {get; set;}
        public String ProductBarcode{get; set;}
        public String ProductQRImage{get; set;}
        
        public Node(){
            this.Product = '';
            this.ProductName = '';
            this.Type = '';
            this.PlanQuantity = 0;
            this.NetWeight = 0;
            this.GrossWeight = 0;
            this.Measurement = 0;
            this.ProductBarcode = '';
            this.ProductQRImage = '';
        }
        
    }
}