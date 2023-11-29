public with sharing class SOSummaryNoteController {
    public Site_Custom_Settings__c siteSetting {get; set;}
    public SALES_ORDER__c so {get; set;}
    public List<GoodsSOProductNode> listGoodSOProductNode {get; set;}
    public Total total {get; set;}
    public string receiverAdress {get; set;}
    public string printType {get; set;}
    public Map<String, String> translations{get; set;}
    public SOSummaryNoteController() {
        translations = new Map<String, String>();
		translations = getTranslationMap();
        printType = ApexPages.currentPage().getParameters().get('printType');
        so = new SALES_ORDER__c();
        listGoodSOProductNode = new List<GoodsSOProductNode>();
        receiverAdress = '';
        total = new Total();
        siteSetting = Site_Custom_Settings__c.getOrgDefaults();
        String soId = ApexPages.currentPage().getParameters().get('id');
        if(!String.isBlank(soId)){
            so = getShipingOder(soId);
            total.totalNetWeight = so.RollUpTotalNetWeight__c;
            total.totalFinalNetWeight = so.RollupFinalNetWeight__c;
            total.totalGrossWeight = so.RollUpTotalGrossWeight__c;
            total.totalMeasurement = so.RollupTotalMeasurement__c;
            total.totalAmount = so.RollupTotalAmountSelling__c;
            total.totalAmountTax = so.RollupAmountSellingTax__c;
            total.totalAmountIncludeTax = so.RollupSellingAmountInclTax__c;
            List<String> adresses = new List<String>();
            if(!String.isBlank(so.CustomerCompanyName__r.BillingStreet)){
                adresses.add(so.CustomerCompanyName__r.BillingStreet);
            }
            if(!String.isBlank(so.CustomerCompanyName__r.BillingCity)){
                adresses.add(so.CustomerCompanyName__r.BillingCity);
            }
            if(!String.isBlank(so.CustomerCompanyName__r.BillingState)){
                adresses.add(so.CustomerCompanyName__r.BillingState);
            }
            if(!String.isBlank(so.CustomerCompanyName__r.BillingPostalCode)){
                adresses.add(so.CustomerCompanyName__r.BillingPostalCode);
            }
            if(!String.isBlank(so.CustomerCompanyName__r.BillingCountry)){
                adresses.add(so.CustomerCompanyName__r.BillingCountry);
            }

            if(!adresses.isEmpty()){
                receiverAdress = String.join(adresses, ', ');
            }

        }
        if(!String.isBlank(SO.Id)){
            List<SalesOrderProduct__c> listGoodSOProduct = getListGoodSOProduct(soId);
            for(SalesOrderProduct__c gp : listGoodSOProduct){
                GoodsSOProductNode node = new GoodsSOProductNode();
                node.ID = gp.Id;
                node.Product = gp.ProductID__r.Name;
                node.ProductId = gp.ProductId__c;
                node.ProductName = gp.ProductName__c;
                node.SKUNumber = gp.ProductID__r.SKUNumber__c;
                node.HSCode = gp.ProductID__r.HSCode__r.HS_Code__c;
                node.ProductQRCode = gp.ProductID__r.QR_Code__c;
                node.ProductQRImage = gp.ProductID__r.QR_Image__c;
                node.CodeImageType = gp.ProductID__r.CodeImageType__c;
                // if(!siteSetting.SwitchToInternalBarCodePhoto__c){
                //     node.ProductQRImage = gp.ProductID__r.QR_Image__c;
                // }else{
                //     if(gp.ProductID__r.CodeImageType__c != 'Barcode'){
                //         node.ProductQRImage = gp.ProductID__r.QRCodeImage__c;
                //     }else {
                //         node.ProductQRImage = gp.ProductID__r.BarCodeImage__c;
                //     }
                // }
                node.Type = gp.ProductID__r.UnitType__c;
                node.FinalQuantity = gp.FinalQuantity__c;
                node.PlanQuantity = gp.PlannedQuantity__c;
                node.BQ = gp.ProductID__r.QuantityPerUnit__c;
                node.curr = gp.ForeignCurrency__c;
                node.NetWeight = gp.TotalNetWeight__c == null? 0 : gp.TotalNetWeight__c;
                node.GrossWeight = gp.TotalGrossWeight__c == null? 0 : gp.TotalGrossWeight__c;
                node.Measurement = gp.TotalMeasurement__c == null? 0 : gp.TotalMeasurement__c;
                node.BillingType = gp.ProductID__r.BillingType__c;
                if(gp.ProductID__r.BillingType__c == 'Weight'){
                    node.NetPurchaseValue = gp.ProductID__r.SellingUnitPriceLocalKg__c;
                }else{
                    node.NetPurchaseValue = gp.ProductID__r.SellingUnitPriceLocal__c;
                }
                
                node.VAT = (node.NetPurchaseValue != null? node.NetPurchaseValue : 0) * (gp.ProductID__r.TaxRateBuying__c != null? gp.ProductID__r.TaxRateBuying__c:0) / 100;
                node.Amount = gp.TotalAmountOfSelling__c;
                node.AmountTax = gp.AmountOfSellingTax__c;
                node.TotalAmount = gp.SellingAmountInclTax__c;
                node.FinalNetWeight = gp.FinalNetWeight__c == null? 0 : gp.FinalNetWeight__c;
                listGoodSOProductNode.add(node);
            }

        }

    }

    private SALES_ORDER__c getShipingOder(String soId){

        SALES_ORDER__c shipingOder = [ SELECT Id, SOQRLabel__c, ShippingAddress__c, SalesOrderStatus__c,
                        CustomerCompanyName__c, CustomerCompanyName__r.Name, OrderDate__c,
                        CustomerCompanyName__r.BillingStreet, CustomerCompanyName__r.BillingCity, 
                        CustomerCompanyName__r.BillingState, CustomerCompanyName__r.BillingPostalCode,
                        CustomerCompanyName__r.BillingCountry,CustomerCompanyName__r.Phone, CustomerCompanyName__r.Fax,
                        CustomerOrderNumber__c, Name, DeliveryTargetDate__c,  CreatedBy.Name, CreatedBy.Email,
                        LastModifiedBy.Name, LastModifiedBy.Email, RollUpTotalGrossWeight__c,RollupFinalNetWeight__c,
                        RollupTotalMeasurement__c, RollupTotalAmountSelling__c, RollupAmountSellingTax__c, RollupSellingAmountInclTax__c, RollUpTotalNetWeight__c
                        FROM SALES_ORDER__c
                        WHERE Id = : soId ];

        return shipingOder;
    }

    private List<SalesOrderProduct__c> getListGoodSOProduct(String soId){

        List<SalesOrderProduct__c> goodSOProducts = [ SELECT Id, PlannedQuantity__c, FinalQuantity__c, AmountOfSellingTax__c, SellingAmountInclTax__c, 
                                                    GoodSalesOrderID__c, ProductID__c, ProductName__c, Quantity__c, ShippingTypeAtWarehouse__c,
                                                    TotalAmountOfSelling__c, TotalGrossWeight__c, TotalMeasurement__c, TotalNetWeight__c,
                                                    ProductID__r.Name,ProductID__r.QR_Code__c, ProductID__r.UnitType__c,ForeignCurrency__c,
                                                    ProductID__r.QuantityPerUnit__c,ProductID__r.SellingCommercialValuePerUnitLocal__c,
                                                    ProductID__r.TaxRateBuying__c, FinalNetWeight__c,ProductID__r.SellingUnitPriceLocal__c,
                                                    ProductID__r.QR_Image__c,ProductID__r.CodeImageType__c, ProductID__r.BarCodeImage__c,
                                                    ProductID__r.SellingUnitPriceLocalKg__c, ProductID__r.BillingType__c, ProductID__r.SKUNumber__c, ProductID__r.HSCode__r.HS_Code__c
                                                     
                                                FROM SalesOrderProduct__c
                                                WHERE GoodSalesOrderID__c = : soId];

        return goodSOProducts;
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

    public class Total{
        public Decimal totalFinalQuantity {get; set;}
        public Decimal totalBQ {get; set;}
        public Decimal totalNetWeight {get; set;}
        public Decimal totalFinalNetWeight {get; set;}
        public Decimal totalGrossWeight {get; set;}
        public Decimal totalMeasurement {get; set;}
        public Decimal totalAmount {get; set;}
        public Decimal totalAmountTax {get; set;}
        public Decimal totalAmountIncludeTax {get; set;}
        public Boolean isPlan{get; set;}
        
        public Total(){
            this.totalFinalQuantity = 0;
            this.totalBQ = 0;
            this.totalNetWeight = 0;
            this.totalFinalNetWeight = 0;
            this.totalGrossWeight = 0;
            this.totalMeasurement = 0;
            this.totalAmount = 0;
            this.totalAmountTax = 0;
            this.totalAmountIncludeTax = 0;
            this.isPlan = false;
        }

        public String getTotalAmountVND(){
            if(totalAmount == 0 || totalAmount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};

            return String.format(totalAmount.format(), args);

            
        }
		public String getTotalAmountJPY(){
            if(TotalAmount == 0 || TotalAmount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###,###,###,###.0'};

            String s = String.format(TotalAmount.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }
        public String getTotalAmountTaxVND(){
            if(totalAmountTax == 0 || totalAmountTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s =  String.format(totalAmountTax.format(), args);
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s;
            
        }
        public String getTotalAmountTaxJPY(){
            if(totalAmountTax == 0 || totalAmountTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###,###,###,###.0'};

            String s =  String.format(totalAmountTax.format(), args);
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s;
            
        }
        public String getTotalAmountIncludeTaxVND(){
            if(TotalAmountIncludeTax == 0 || TotalAmountIncludeTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s =  String.format(TotalAmountIncludeTax.format(), args);
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s;
            
        }
    }

    public class GoodsSOProductNode{
        public String ID{get;set;}
        public String ProductId{get;set;}
        public String SKUNumber{get; set;}
        public String HSCode{get; set;}
        public String Product {get; set;}
        public String ProductName {get; set;}
        public String ProductQRCode {get; set;}
        public String ProductQRImage {get; set;}
        public String Type {get; set;}
        public Decimal FinalQuantity {get; set;}
        public Decimal PlanQuantity {get; set;}
        public Decimal BQ {get; set;}
        public Decimal GrossWeight {get; set;}
        public Decimal NetWeight {get; set;}
        public Decimal FinalNetWeight {get; set;}
        public Decimal Measurement {get; set;}
        public Decimal NetPurchaseValue {get; set;}
        public Decimal VAT {get; set;}
        public Decimal Amount {get; set;}
        public Decimal TotalAmount {get; set;}
        public Decimal AmountTax {get; set;}
        public String CodeImageType{get;set;}
        public String BillingType {get; set;}
        public Boolean isPlan{get; set;}
        public String curr{get; set;}
        
        public GoodsSOProductNode(){
            this.ProductId = '';
            this.SKUNumber = '';
            this.HSCode = '';
            this.BillingType = '';
            this.Product = '';
            this.ProductName = '';
            this.ProductQRCode = '';
            this.ProductQRImage = '';
            this.Type = '';
            this.FinalQuantity = 0;
            this.BQ = 0;
            this.NetWeight = 0;
            this.GrossWeight = 0;
            this.Measurement = 0;
            this.NetPurchaseValue = 0;
            this.VAT = 0;
            this.Amount = 0;
            this.TotalAmount = 0;
            this.AmountTax = 0;
            this.isPlan = false;
            this.FinalNetWeight = 0;
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

        public String getAmountVND(){
            if(Amount == 0 || Amount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};

            return String.format(Amount.format(), args);   
        }

        public String getTotalAmountVND(){
            if(TotalAmount == 0 || TotalAmount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(TotalAmount.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }
        
        public String getAmountTaxVND(){
            if(AmountTax == 0 || AmountTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(AmountTax.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }

        
    }
}