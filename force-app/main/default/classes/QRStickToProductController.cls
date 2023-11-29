public with sharing class QRStickToProductController {
    public Site_Custom_Settings__c siteSetting {get; set;}
    public WorkOrder__c wo {get; set;}
    public Map<String, Node> mapNode {get; set;}
    public Total total {get; set;}
    public Map<String, String> translations{get; set;}
    private String prmWOID {get; set;}
    public QRStickToProductController(){
        translations = new Map<String, String>();
		translations = getTranslationMap();
        mapNode = new Map<String, Node>();
        total = new Total();
        siteSetting = Site_Custom_Settings__c.getOrgDefaults();
        prmWOID = ApexPages.currentPage().getParameters().get('id');
        wo = getWorkOrder(prmWOID);
        
        // initData();
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

    // private void initData(){
    //     List<WOSLineItem__c> lstWOSLine = getAllWOSLineByWO(prmWOID);
    //     Node node = new Node();
    //     for(WOSLineItem__c line : lstWOSLine){
    //         if(!mapNode.containsKey(line.Cargo__r.Product__c)){
    //             node = new Node();
    //             node.ProductId = line.Cargo__r.Product__c;
    //             node.SKUNumber =  line.Cargo__r.Product__r.SKUNumber__c;
    //             node.HSCode = line.Cargo__r.Product__r.HSCode__r.HS_Code__c;
    //             node.CodeImageType = line.Cargo__r.Product__r.CodeImageType__c; 
    //             node.ProductQRImage = line.Cargo__r.Product__r.QRCodeImage__c;
    //             node.Product = line.Cargo__r.Product__r.Name;
    //             node.ProductBarcode = line.Cargo__r.Product__r.QR_Code__c;
    //             node.ProductName = line.Cargo__r.Product__r.ProductName__c;
    //             node.Type = line.Cargo__r.Product__r.UnitType__c;
    //             node.FinalQuantity = 1;
    //             node.BQ = line.Cargo__r.Product__r.QuantityPerUnit__c != null ? line.Cargo__r.Product__r.QuantityPerUnit__c : 0;
    //             node.NetWeight = line.Cargo__r.Product__r.NETWeight__c != null ? line.Cargo__r.Product__r.NETWeight__c : 0;
    //             node.GrossWeight = line.Cargo__r.Product__r.GrossWeight__c != null ? line.Cargo__r.Product__r.GrossWeight__c : 0;
    //             node.Measurement = line.Cargo__r.Product__r.Measurement__c != null ? line.Cargo__r.Product__r.Measurement__c : 0;
    //             node.NetPurchaseValue = line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c != null ? line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c : 0;
                
    //             if(line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c != null && 
    //               line.Cargo__r.Product__r.TaxRateBuying__c != null){
    //                 node.VAT = line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c * line.Cargo__r.Product__r.TaxRateBuying__c / 100 ;
    //             }
    //             else{
    //                 node.VAT = 0;
    //             }
                
    //             node.SubtotalNetPurchaseValue = line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c != null ? 
    //                 line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c : 0;
                
    //             if(line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c != null && 
    //                line.Cargo__r.Product__r.TaxRateBuying__c != null){
    //                    node.SubTotalVAT = line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c * line.Cargo__r.Product__r.TaxRateBuying__c / 100;
    //                }
    //             else{
    //                 node.SubTotalVAT = 0;
    //             }
                
    //             if(line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c != null){
    //                 if(line.Cargo__r.Product__r.TaxRateBuying__c != null){
    //                     node.PurchaseValue = line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c * (1 + line.Cargo__r.Product__r.TaxRateBuying__c);
    //                 }
    //                 else{
    //                     node.PurchaseValue = line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c;
    //                 }
    //             }
    //             else{
    //                 node.PurchaseValue = 0;
    //             }

    //             mapNode.put(line.Cargo__r.Product__c, node);
    //         }
    //         else{
    //             if(line.CargoStatus__c == 'Completed'){
    //                mapNode.get(line.Cargo__r.Product__c).FinalQuantity += 1;  
    //             }
               
    //             mapNode.get(line.Cargo__r.Product__c).BQ += (line.Cargo__r.Product__r.QuantityPerUnit__c != null ? line.Cargo__r.Product__r.QuantityPerUnit__c : 0);
    //             mapNode.get(line.Cargo__r.Product__c).NetWeight += (line.Cargo__r.Product__r.NETWeight__c != null ? line.Cargo__r.Product__r.NETWeight__c : 0);
    //             mapNode.get(line.Cargo__r.Product__c).GrossWeight += (line.Cargo__r.Product__r.GrossWeight__c != null ? line.Cargo__r.Product__r.GrossWeight__c : 0);
    //             mapNode.get(line.Cargo__r.Product__c).Measurement += (line.Cargo__r.Product__r.Measurement__c != null ? line.Cargo__r.Product__r.Measurement__c : 0);
    //             mapNode.get(line.Cargo__r.Product__c).SubtotalNetPurchaseValue = mapNode.get(line.Cargo__r.Product__c).FinalQuantity * mapNode.get(line.Cargo__r.Product__c).NetPurchaseValue;
    //             mapNode.get(line.Cargo__r.Product__c).SubTotalVAT = mapNode.get(line.Cargo__r.Product__c).FinalQuantity * mapNode.get(line.Cargo__r.Product__c).VAT;
    //         	//if(line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c != null){
    //          //       if(line.Cargo__r.Product__r.TaxRateBuying__c != null){
    //          //           mapNode.get(line.Cargo__r.Product__c).PurchaseValue = mapNode.get(line.Cargo__r.Product__c).FinalQuantity * line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c * (1 + line.Cargo__r.Product__r.TaxRateBuying__c);
    //          //       }
    //          //       else{
    //          //           mapNode.get(line.Cargo__r.Product__c).PurchaseValue = mapNode.get(line.Cargo__r.Product__c).FinalQuantity * line.Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c;
    //          //       }
    //          //   }
    //             mapNode.get(line.Cargo__r.Product__c).PurchaseValue = mapNode.get(line.Cargo__r.Product__c).SubtotalNetPurchaseValue + mapNode.get(line.Cargo__r.Product__c).SubTotalVAT;
    //         }
    //     }
        
    //     for(Node item : mapNode.values()){
    //         total.totalFinalQuantity += item.FinalQuantity;
    //         total.totalBQ += (item.BQ != null ? item.BQ : 0);
    //         total.totalNetWeight += (item.NetWeight != null ? item.NetWeight : 0);
    //         total.totalGrossWeight += (item.GrossWeight != null ? item.GrossWeight : 0);
    //         total.totalMeasurement += (item.Measurement != null ? item.Measurement : 0);
    //         total.totalSubtotalNetPurchaseValue += (item.SubtotalNetPurchaseValue != null ? item.SubtotalNetPurchaseValue : 0);
    //         total.totalSubTotalVAT += (item.SubTotalVAT != null ? item.SubTotalVAT : 0);
    //         //total.totalPurchaseValue += (item.PurchaseValue != null ? item.PurchaseValue : 0);
    //     }
    //     total.totalPurchaseValue = total.totalSubtotalNetPurchaseValue + total.totalSubTotalVAT;
    // }
    
    private WorkOrder__c getWorkOrder(String strId){
        List<WorkOrder__c> lstWO = new List<WorkOrder__c>();
        
        lstWO = [ SELECT WarehouseID__c, WarehouseID__r.Address__c, WarehouseID__r.Name, WarehouseID__r.FacilityName__c, PurchasingOrderID__r.POQRLabel__c,
                        PurchasingOrderID__r.PurchasingOrderNumber__c, PurchasingOrderID__r.CreatedBy.Name,PurchasingOrderID__r.CreatedBy.Email,
                 		PurchasingOrderID__r.GoodsPurchasingOrderDate__c, PurchasingOrderID__r.Name, PurchasingOrderID__r.Supplier__r.AccountNumber, 
                 		PurchasingOrderID__r.CSCDType__c, PurchasingOrderID__r.Supplier__r.Name, PurchasingOrderID__r.Supplier__r.EnglishAddress__c, 
                        PurchasingOrderID__r.Supplier__r.Phone,PurchasingOrderID__r.DeliveryTargetDateToWarehouse__c,
                        LastModifiedBy.Name, LastModifiedBy.Email, Name, SalesAccountedDate__c, WOQRLabel__c
                	FROM WorkOrder__c
                	WHERE Id =: strId];
        
        if(!lstWO.isEmpty()){
            return lstWO.get(0);
        }
        return new WorkOrder__c();
    }
    
    private List<WOSLineItem__c> getAllWOSLineByWO(String strWOId){
        List<WOSLineItem__c> lstWOSLine = new List<WOSLineItem__c>();
        lstWOSLine = [ SELECT Id, CargoStatus__c, WorkOrderService__r.WorkOrder__c, Cargo__r.Product__r.QR_Code__c, WorkOrderService__c, Cargo__r.Product__c, Cargo__r.Product__r.Name, Cargo__r.Product__r.ProductName__c, Cargo__r.ProductDetails__c,
                      			WorkOrderService__r.TypeUnit__c, Cargo__r.Product__r.QuantityPerUnit__c, WorkOrderService__r.GrossWeightKG__c, WorkOrderService__r.NETWeightKG__c,
                                Cargo__r.Product__r.GrossWeight__c, Cargo__r.Product__r.NETWeight__c,  Cargo__r.Product__r.Measurement__c,
                      			WorkOrderService__r.Measurement__c, Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c,
                      			Cargo__r.Product__r.TaxRateBuying__c, Cargo__r.Product__r.UnitType__c, Cargo__r.Product__r.QR_Image__c, 
                                Cargo__r.Product__r.CodeImageType__c,Cargo__r.Product__r.QRCodeImage__c,Cargo__r.Product__r.BarCodeImage__c,
                                Cargo__r.Product__r.SKUNumber__c, Cargo__r.Product__r.HSCode__r.HS_Code__c
                        FROM WOSLineItem__c 
                        WHERE WorkOrderService__r.WorkOrder__c = :strWOId 
                        AND WorkOrderService__r.RecordType.DeveloperName = 'InboundReceiving'];
        return lstWOSLine;
    }
    
    public class Total{
        public Decimal totalFinalQuantity {get; set;}
        public Decimal totalBQ {get; set;}
        public Decimal totalNetWeight {get; set;}
        public Decimal totalGrossWeight {get; set;}
        public Decimal totalMeasurement {get; set;}
        public Decimal totalSubtotalNetPurchaseValue {get; set;}
        public Decimal totalSubTotalVAT {get; set;}
        public Decimal totalPurchaseValue {get; set;}
        
        public Total(){
            this.totalFinalQuantity = 0;
            this.totalBQ = 0;
            this.totalNetWeight = 0;
            this.totalGrossWeight = 0;
            this.totalMeasurement = 0;
            this.totalSubtotalNetPurchaseValue = 0;
            this.totalSubTotalVAT = 0;
            this.totalPurchaseValue = 0;
        }

        public String getTotalSubtotalNetPurchaseValueVND(){
            if(totalSubtotalNetPurchaseValue == 0 || totalSubtotalNetPurchaseValue == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};

            return String.format(totalSubtotalNetPurchaseValue.format(), args);
        }

        public String getTotalSubTotalVATVND(){
            if(totalSubTotalVAT == 0 || totalSubTotalVAT == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s =  String.format(totalSubTotalVAT.format(), args);
            if(!s.contains(',')){
               s += ',0'; 
            }

            return s;
        }

        public String getTotalPurchaseValueVND(){
            if(totalPurchaseValue == 0 || totalPurchaseValue == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s =  String.format(totalPurchaseValue.format(), args);
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s;
        }
    }
    
    public class Node{
        public String CodeImageType{get;set;}
        public String ProductId{get; set;}
        public String SKUNumber{get; set;}
        public String HSCode{get; set;}
        public String Product {get; set;}
        public String ProductName {get; set;}
        public String Type {get; set;}
        public Decimal FinalQuantity {get; set;}
        public Decimal BQ {get; set;}
        public Decimal GrossWeight {get; set;}
        public Decimal NetWeight {get; set;}
        public Decimal Measurement {get; set;}
        public Decimal NetPurchaseValue {get; set;}
        public Decimal VAT {get; set;}
        public Decimal SubtotalNetPurchaseValue {get; set;}
        public Decimal SubTotalVAT {get; set;}
        public Decimal PurchaseValue {get; set;}
        public String ProductBarcode{get; set;}
        public String ProductQRImage{get; set;}
        
        public Node(){
            this.ProductId = '';
            this.SKUNumber = '';
            this.HSCode = '';
            this.Product = '';
            this.ProductName = '';
            this.Type = '';
            this.FinalQuantity = 0;
            this.BQ = 0;
            this.NetWeight = 0;
            this.GrossWeight = 0;
            this.Measurement = 0;
            this.NetPurchaseValue = 0;
            this.VAT = 0;
            this.SubtotalNetPurchaseValue = 0;
            this.SubTotalVAT = 0;
            this.PurchaseValue = 0;
            this.ProductBarcode = '';
            this.ProductQRImage = '';
        }
        public String getNetPurchaseValueVND(){
            if(NetPurchaseValue == 0 || NetPurchaseValue == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};

            return String.format(NetPurchaseValue.format(), args);
            
        }

        public String getVATVND(){
            if(VAT == 0 || VAT == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(VAT.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }

        public String getSubtotalNetPurchaseValueVND(){
            if(SubtotalNetPurchaseValue == 0 || SubtotalNetPurchaseValue == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};

            return String.format(SubtotalNetPurchaseValue.format(), args);   
        }

        public String getSubTotalVATVND(){
            if(SubTotalVAT == 0 || SubTotalVAT == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(SubTotalVAT.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }

        public String getPurchaseValueVND(){
            if(PurchaseValue == 0 || PurchaseValue == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(PurchaseValue.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }
    }
}