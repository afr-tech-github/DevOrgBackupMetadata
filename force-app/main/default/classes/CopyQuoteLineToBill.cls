public with sharing class CopyQuoteLineToBill {
	public List<QuoteLine__c> lineItems{get; set;}
	public String  msgError {get; set;}
    public String shipmentId{get; set;}
    public Decimal checkcur3rd{get; set;}
    public CustomObject1__c invoiceToSo {get;set;}
	private static Set<String> fieldsQuery = new Set<String>();
	private static List<String> quoteLineIdList = new List<String>();
    static{
        fieldsQuery.add('Id');
        fieldsQuery.add('LineItemName__c');
        fieldsQuery.add('QuoteLineNumber__c');
        fieldsQuery.add('Unit__c');
        fieldsQuery.add('Quantity__c');
        fieldsQuery.add('SellingListPrice3rdCurrency__c');
        fieldsQuery.add('SellingListPriceLocal__c');
        fieldsQuery.add('SellingListPriceUSD__c');
        fieldsQuery.add('SellingAmountInclTaxLocal__c');
        fieldsQuery.add('SellingAmountInclTaxUSD__c');
        fieldsQuery.add('CurrencySelling__c');
        fieldsQuery.add('POLAOD__c');
        fieldsQuery.add('PODAOA__c');
        fieldsQuery.add('POLAODName__c');
        fieldsQuery.add('PODAOAName__c');
        fieldsQuery.add('CarrierAirlinerVendor__c');
        fieldsQuery.add('CarrierAirlinerVendorName__c');
        fieldsQuery.add('ContainerType__c');
        fieldsQuery.add('ContainerQuantity__c');
        fieldsQuery.add('ServiceSchedule__c');
        fieldsQuery.add('TransitTimeDays__c');
        fieldsQuery.add('Remarks__c');
        fieldsQuery.add('TotalAmountSellingLocal__c');
        fieldsQuery.add('TotalAmountOfSellingUSD__c');
        fieldsQuery.add('PickupAddress__c');
        fieldsQuery.add('DeliveryAddress__c');
        fieldsQuery.add('Minimum__c');
        fieldsQuery.add('Under45kg__c');
        fieldsQuery.add('Over45kg__c');
        fieldsQuery.add('Over100kg__c');
        fieldsQuery.add('Over300kg__c');
        fieldsQuery.add('Over500kg__c');
        fieldsQuery.add('Over1000kg__c');
        fieldsQuery.add('FSCSCS__c');
        fieldsQuery.add('LineItemDescription__c');
        fieldsQuery.add('Name');
        //fieldsQuery.add('Anken__r.Field1__c');
        fieldsQuery.add('ServicePricingID__c');
        fieldsQuery.add('ServicePricingID__r.Supplier__c');
        fieldsQuery.add('ServicePricingID__r.Zeibunrui__c');
        fieldsQuery.add('ServicePricingID__r.VATInvoiceAtPrintLocal__c');
        fieldsQuery.add('ServicePricingID__r.VATInvoiceAtPrintENG__c');
        fieldsQuery.add('ContainerQuantity__c');
        fieldsQuery.add('TaxRate__c');
        fieldsQuery.add('TaxRateBuying__c');
        fieldsQuery.add('CurrencyBuying__c');
        fieldsQuery.add('FXRateID__c');
        fieldsQuery.add('ExchangeRateSelling__c');
        fieldsQuery.add('ExchangeRateBuying__c');
        fieldsQuery.add('ExchangeRateBuyingUpdate__c');
        fieldsQuery.add('CurrencyConverseForSelling__c');
        fieldsQuery.add('CurrencyConverseForBuying__c');
        fieldsQuery.add('BuyingListPriceLocal__c');
        fieldsQuery.add('BuyingListPriceUSD__c');
        fieldsQuery.add('QuoteID__c');
        fieldsQuery.add('ExchangeRateSellingUpdate__c');
        fieldsQuery.add('ExchangeRateBuyingUpdate__c');
        fieldsQuery.add('Invoice_to__r.Name');
        fieldsQuery.add('clofor_com_cfs__RequesterCompany__c');
        
        
    }
	public CopyQuoteLineToBill() {
		lineItems = new List<QuoteLine__c>();
		msgError ='';
        checkcur3rd = 0;
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
		String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        invoiceToSo = [SELECT Field1__c, Field1__r.Name FROM CustomObject1__c WHERE id = :shipmentId];
		if(String.isBlank(quoteId)){
			msgError = 'Please enter Quote Id field.';
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,msgError));
			return;
		}
		msgError = '';
		lineItems = getListQuoteLine(quoteId);
        if (lineItems.size()>0){
            for (QuoteLine__c line : lineItems){
                if (line.SellingListPrice3rdCurrency__c != null && line.SellingListPrice3rdCurrency__c != 0){
                    checkcur3rd += line.SellingListPrice3rdCurrency__c;
                }
            }
        }
	}
	private List<QuoteLine__c> getListQuoteLine(String quoteId){
        String strSelect = String.join(new List<String>(fieldsQuery), ',');
        String strQuery = 'SELECT ' + strSelect 
                    + ' FROM QuoteLine__c'
                    + ' WHERE QuoteID__c = \'' + String.escapeSingleQuotes(quoteId) + '\'';
        strQuery += ' ORDER BY Name ASC';
        List<QuoteLine__c> quoteLines = Database.query(strQuery);
        return quoteLines;
    }
    private List<QuoteLine__c> getListQuoteLineByIds(){
        String strSelect = String.join(new List<String>(fieldsQuery), ',');
        String strQuery = 'SELECT clofor_com_cfs__Invoice_to__c,' + strSelect 
                    + ' FROM QuoteLine__c'
                    + ' WHERE Id IN: quoteLineIdList';
        strQuery += ' ORDER BY Name ASC';
        List<QuoteLine__c> quoteLines = Database.query(strQuery);
        return quoteLines;
    }
    private CustomObject1__c getShipmentOrder(String shipmentId){

    	List<CustomObject1__c> shipmentOrders = [SELECT Id, Field1__c FROM CustomObject1__c WHERE Id=: shipmentId];
    	if(!shipmentOrders.isEmpty()){
    		return shipmentOrders[0];
    	}
    	return new CustomObject1__c();
    }
    
    public void createFMSBill(){
    	msgError ='';
    	String quoteLineIds = ApexPages.currentPage().getParameters().get('quoteLineIds');
    	CustomObject1__c so = getShipmentOrder(shipmentId);
        //QuoteLine__c quo = getquoteOrder(quoteId);
    	if(String.isBlank(quoteLineIds)){
    		msgError = 'Please Select Quote Line.';
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,msgError));
    		return;
    		//a2i0K000000BDfu
    	}
    	quoteLineIdList = quoteLineIds.split(',');
    	List<QuoteLine__c> listQuoteLine = getListQuoteLineByIds();
    	List<AnkenMeisai__c> listNewBill = new List<AnkenMeisai__c>();
    	Id recordTypeId = Schema.SObjectType.AnkenMeisai__c.getRecordTypeInfosByDeveloperName().get('Selling_Buyging_Standard').getRecordTypeId();
    	for(QuoteLine__c line : listQuoteLine){
    		AnkenMeisai__c newBill = new AnkenMeisai__c();
           
    		newBill.RecordTypeId = recordTypeId;
            newBill.PaymentTo__c = line.CarrierAirlinerVendor__c;
            newBill.Suryo__c = line.Quantity__c;
            newBill.Anken__c = shipmentId;
            if(line.SellingListPrice3rdCurrency__c == null &&
                line.SellingListPriceUSD__c == null &&
                line.SellingListPriceLocal__c == null){
                    newBill.Seikyusaki__c = null;
                }else{
                    if(line.clofor_com_cfs__Invoice_to__c != null){
                        newBill.Seikyusaki__c = line.clofor_com_cfs__Invoice_to__c;
                    }else{
                        newBill.Seikyusaki__c = so.Field1__c;
                    }
                }
    		//newBill.Seikyusaki__c = so.Field1__c;
            
			newBill.SeikyuBangou__c = line.QuoteLineNumber__c;
			newBill.Tariff__c = line.ServicePricingID__c;
            //newBill.Reference_Price__r.Servicename__c = line.ServicePricingID__c;
			//newBill.PaymentTo__c = line.ServicePricingID__r.Supplier__c;
			//newBill.InsatuyouSyohin__c = line.ServicePricingID__r.VATInvoiceAtPrintLocal__c;
			//newBill.InsatuyouSyohinEng__c = line.ServicePricingID__r.VATInvoiceAtPrintENG__c; 
			newBill.InsatuyouSyohin__c = line.LineItemName__c;
            newBill.InsatuyouSyohinEng__c = line.LineItemName__c;
            if(String.isBlank(line.LineItemName__c)){
                newBill.InsatuyouSyohin__c = line.ServicePricingID__r.VATInvoiceAtPrintLocal__c;
                newBill.InsatuyouSyohinEng__c = line.ServicePricingID__r.VATInvoiceAtPrintENG__c;
            }
			//newBill.Suryo__c = line.ContainerQuantity__c; 
            newBill.QuoteLineID__c = line.Id;
            newBill.ChargeUnit__c = line.Unit__c;
            newBill.ContainerSize__c = line.ContainerType__c;
			newBill.TaxInitial__c = line.TaxRate__c;
			newBill.BuyTaxInitial__c = line.TaxRateBuying__c;
			newBill.curr__c = line.CurrencySelling__c;
			newBill.CurrencyBuying__c = line.CurrencyBuying__c;
			newBill.ExchangeRateID__c = line.FXRateID__c;
			newBill.KawaseSel__c = line.ExchangeRateSelling__c;
			newBill.KawaseBay__c = line.ExchangeRateBuying__c;
			if(String.isBlank(line.ExchangeRateSellingUpdate__c)){
				newBill.ExchangeRateSellingUpdate__c = line.ExchangeRateSellingUpdate__c;
			}
			if(String.isBlank(line.ExchangeRateBuyingUpdate__c)){
				newBill.ExchangeRateBuyingUpdate__c = line.ExchangeRateBuyingUpdate__c;
			}
			
			
			newBill.CurrencyConversionSelling__c = line.CurrencyConverseForSelling__c;
			newBill.CurrencyConversionBuying__c = line.CurrencyConverseForBuying__c;
			newBill.SellTankaJPY__c = line.SellingListPriceLocal__c;
			newBill.SellTankaUSD__c = line.SellingListPriceUSD__c;
            newBill.UnitPriceofSelling3rdCurrency__c = line.SellingListPrice3rdCurrency__c;
			newBill.BuyTankaJPY__c = line.BuyingListPriceLocal__c;
			newBill.BuyTankaUSD__c = line.BuyingListPriceUSD__c;
    		listNewBill.add(newBill);
    	}
    	try{
            msgError = '';
    		FlsService.doInsert(listNewBill);
			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, msgError));
    	}catch(Exception ex){
    		msgError = ex.getMessage();
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, msgError));
    	}
    	
    	
    }
}