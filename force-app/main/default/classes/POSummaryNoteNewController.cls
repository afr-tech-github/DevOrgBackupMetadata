public with sharing class POSummaryNoteNewController {
	public Site_Custom_Settings__c siteSetting {get; set;}
    public GoodsPurchasingOrder__c po {get; set;}
    public List<GoodsPOProductNode> listGoodPOProductNode {get; set;}
    public Total total {get; set;}
    public String printType {get; set;}
    public Map<String, String> translations{get; set;}
	public POSummaryNoteNewController() {
        translations = new Map<String, String>();
		translations = getTranslationMap();
		printType = ApexPages.currentPage().getParameters().get('printType');
		po = new GoodsPurchasingOrder__c();
		listGoodPOProductNode = new List<GoodsPOProductNode>();
		total = new Total();
		siteSetting = Site_Custom_Settings__c.getOrgDefaults();
        String poId = ApexPages.currentPage().getParameters().get('id');
        if(!String.isBlank(poId)){
        	po = getPurchasingOrder(poId);
        	total.totalNetWeight = po.RollUpNetWeight__c;
        	total.totalGrossWeight = po.RollUpGrossWeight__c;
        	total.totalMeasurement = po.RollupTotalMeasurement__c;
        	total.totalAmount = po.RollupTotalAmountBuying__c;
        	total.totalAmountTax = po.RollupAmountOfBuyingTax__c;
        	total.totalAmountIncludeTax = po.RollupBuyingAmountInclTax__c;
            total.totalFinalNetWeight = po.RollupFinalNetWeight__c;


        }
        if(!String.isBlank(po.Id)){
        	List<GoodsPOProduct__c> listGoodPOProduct = getListGoodPOProduct(poId);
        	for(GoodsPOProduct__c gp : listGoodPOProduct){
        		GoodsPOProductNode node = new GoodsPOProductNode();
        		node.Product = gp.ProductID__r.Name;
                node.ProductId = gp.ProductID__c;
                
                node.SKUNumber = gp.ProductID__r.SKUNumber__c;
                node.HSCode = gp.ProductID__r.HSCode__r.HS_Code__c;
	            node.ProductName = gp.ProductName__c;
                node.curr = gp.ForeignCurrency__c;
	            node.ProductQRCode = gp.ProductID__r.QR_Code__c;
	            node.ProductQRImage = gp.ProductID__r.QR_Image__c;
                node.CodeImageType = gp.ProductID__r.CodeImageType__c;
                node.ID = gp.ID;
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
                node.FinalQuantityAllUnit = gp.FinalQuantityAllUnit__c;
                node.PlanQuantityAllUnit = gp.PlanQuantityAllUnit__c;
	            node.FinalQuantity = gp.FinalQuantity__c;
	            node.PlanQuantity = gp.PlanQuantity__c;
	            node.BQ = gp.ProductID__r.QuantityPerUnit__c;
	            node.NetWeight = gp.TotalNetWeight__c == null? 0 : gp.TotalNetWeight__c;
	            node.GrossWeight = gp.TotalGrossWeight__c == null? 0 : gp.TotalGrossWeight__c;
	            node.Measurement = gp.TotalMeasurement__c == null? 0 : gp.TotalMeasurement__c;
	            node.BillingType = gp.ProductID__r.BillingType__c;
                if(gp.ProductID__r.BillingType__c == 'Weight'){
                    node.NetPurchaseValue = gp.ProductID__r.BuyingUnitPriceLocalKg__c;
                }else{
                    node.NetPurchaseValue = gp.ProductID__r.BuyingCommercialValuePerUnitLocal__c;
                }
	            node.VAT = (node.NetPurchaseValue != null? node.NetPurchaseValue : 0) * (gp.ProductID__r.TaxRateBuying__c != null? gp.ProductID__r.TaxRateBuying__c:0) / 100;
	            node.Amount = gp.TotalAmountOfBuying__c;
	            node.AmountTax = gp.AmountOfBuyingTax__c;
	            node.TotalAmount = gp.BuyingAmountInclTax__c;
                node.FinalNetWeight = gp.FinalNetWeight__c == null? 0 : gp.FinalNetWeight__c;
	            listGoodPOProductNode.add(node);
        	}

        }

	}

	private GoodsPurchasingOrder__c getPurchasingOrder(String poId){

		GoodsPurchasingOrder__c purchasingOrder = [ SELECT Id, POQRLabel__c,
                        PurchasingOrderNumber__c, CreatedBy.Name,CreatedBy.Email,
                 		GoodsPurchasingOrderDate__c, Name, Supplier__r.AccountNumber, 
                 		CSCDType__c, Supplier__r.Name, Supplier__r.EnglishAddress__c, 
                        Supplier__r.Phone,DeliveryTargetDateToWarehouse__c, GoodsPurchasingOrder__c,
                        LastModifiedBy.Name, LastModifiedBy.Email, DestinationWarehouseID__c, DestinationWarehouseID__r.Name, 
                        DestinationWarehouseID__r.FacilityName__c, DestinationWarehouseID__r.Address__c, RollUpGrossWeight__c,RollupFinalNetWeight__c,
                        RollupTotalMeasurement__c, RollupTotalAmountBuying__c, RollupAmountOfBuyingTax__c, RollupBuyingAmountInclTax__c, RollUpNetWeight__c
                        FROM GoodsPurchasingOrder__c
                        WHERE Id = : poId ];

		return purchasingOrder;
	}

	private List<GoodsPOProduct__c> getListGoodPOProduct(String poId){

		List<GoodsPOProduct__c> goodPOProducts = [ SELECT Id, PlanQuantity__c, FinalQuantity__c, AmountOfBuyingTax__c, BuyingAmountInclTax__c, 
													GoodsPOID__c, ProductID__c, ProductName__c, Quantity__c, ShippingTypeAtWarehouse__c,PlanQuantityAllUnit__c, FinalQuantityAllUnit__c,
													TotalAmountOfBuying__c, TotalGrossWeight__c, TotalMeasurement__c, TotalNetWeight__c,ForeignCurrency__c,
													ProductID__r.Name,ProductID__r.QR_Code__c, ProductID__r.UnitType__c, ProductID__r.BillingType__c,
													ProductID__r.QuantityPerUnit__c, ProductID__r.QR_Image__c,ProductID__r.CodeImageType__c, ProductID__r.BarCodeImage__c, ProductID__r.QRCodeImage__c,
                                                    ProductID__r.BuyingCommercialValuePerUnitLocal__c,
													ProductID__r.TaxRateBuying__c, FinalNetWeight__c, ProductID__r.BuyingUnitPriceLocalKg__c, ProductID__r.SKUNumber__c, ProductID__r.HSCode__r.HS_Code__c
						                        FROM GoodsPOProduct__c
						                        WHERE GoodsPOID__c = : poId];

		return goodPOProducts;
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

    public class GoodsPOProductNode{
        public String CodeImageType{get;set;}
        public String ID{get;set;}
        public String ProductId{get; set;}
        public String SKUNumber{get; set;}
        public String HSCode{get; set;}
        public String Product {get; set;}
        public String ProductName {get; set;}
        public String ProductQRCode {get; set;}
        public String ProductQRImage {get; set;}
        public String Type {get; set;}
        public String BillingType {get; set;}
        public Decimal FinalQuantity {get; set;}
        public Decimal PlanQuantity {get; set;}
        public Decimal FinalQuantityAllUnit {get; set;}
        public Decimal PlanQuantityAllUnit {get; set;}
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
        public Boolean isPlan{get; set;}
        public String curr{get; set;}
        
        public GoodsPOProductNode(){
            this.ProductId = '';
            this.FinalQuantityAllUnit = 0;
            this.PlanQuantityAllUnit = 0;
            this.BillingType ='';
            this.SKUNumber = '';
            this.HSCode = '';
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