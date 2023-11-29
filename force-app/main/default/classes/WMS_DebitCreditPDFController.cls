public with sharing class WMS_DebitCreditPDFController {
	public static clofor_com_cfs__Site_Custom_Settings__c  siteSetting{get; set;}
	public static WorkOrder__c currentWorkOrder{get; set;}
	public static Account currentCustomer{get; set;}
	public List<BillingWapper> listWrapper{get; set;}
	public Map<String, String> translations{get; set;}
	public Decimal subTotalAmount{get; set;}
	public Decimal totalAmountOfTax{get; set;}
	public Decimal totalAmount{get; set;}
	public String currentCurency{get; set;}
	public String invoiceType{get; set;}
	public String language{get; set;}
	public string customerLocalAdress{get; set;}
	public String nameFilePDF{get; set;}
	public String amountInword{get;set;}

	public WMS_DebitCreditPDFController(){
		currentWorkOrder = new WorkOrder__c();
		currentCustomer = new Account();
		listWrapper = new List<BillingWapper>();
		siteSetting = clofor_com_cfs__Site_Custom_Settings__c.getOrgDefaults();
		String workOrderId = ApexPages.currentPage().getParameters().get('workOrderId');
		String customerId = ApexPages.currentPage().getParameters().get('customerId');
		String printType = ApexPages.currentPage().getParameters().get('printType');
		language = ApexPages.currentPage().getParameters().get('language');
		translations = getTranslationMap(language);
		currentCurency = 'USD';
		if(printType.contains('LOCAL')){
			currentCurency = 'VND';
		}
		// get data of workOrder
		invoiceType = printType;
		nameFilePDF = translations.get(invoiceType);
		nameFilePDF = nameFilePDF.substringBefore('(');
		
		List<WorkOrder__c> listWorkOrder = [SELECT Id, Name, DueDateReceivableCollection__c From WorkOrder__c where Id =: workOrderId];
		if(!listWorkOrder.isEmpty()){
			currentWorkOrder = listWorkOrder[0];
		}
		// get customer 
		List<Account> listCustomer = [SELECT Id, 
											Name, 
											TAX_CODE__c, 
											EnglishCompanyName__c,
											Bank1__c, 
											EnglishAddress__c,
											BillingStreet, 
											BillingCity, 
											BillingState, 
											BillingPostalCode,
       										BillingCountry
       									FROM Account WHERE Id =: customerId];
       	customerLocalAdress = '';
		if(!listCustomer.isEmpty()){
			currentCustomer = listCustomer[0];
			List<String> address = new List<String>();
			if(!String.isBlank(currentCustomer.BillingStreet)){
				address.add(currentCustomer.BillingStreet);
			}
			if(!String.isBlank(currentCustomer.BillingCity)){
				address.add(currentCustomer.BillingCity);
			}
			if(!String.isBlank(currentCustomer.BillingState)){
				address.add(currentCustomer.BillingState);
			}
			if(!String.isBlank(currentCustomer.BillingPostalCode)){
				address.add(currentCustomer.BillingPostalCode);
			}
			if(!String.isBlank(currentCustomer.BillingCountry)){
				address.add(currentCustomer.BillingCountry);
			}
			customerLocalAdress = String.join(address, ', ');
		}

		// get list Billing base on Work Order/ customer
		List<Billing__c> listBilling = getListBilling(workOrderId, customerId, printType);
		Integer no = 1;
		subTotalAmount = 0;
		totalAmountOfTax = 0;
		totalAmount = 0;
		for(Billing__c billing : listBilling){
			BillingWapper wrapper = new BillingWapper();
			wrapper.language = language;
			wrapper.no = (Integer)billing.BillingDisplayNo__c;
			List<String> unitAndTime = new List<String>();
			if(!String.isBlank(billing.Unit__c)){
				unitAndTime.add(billing.Unit__c);
			}
			if(!String.isBlank(billing.TimeUnit__c)){
				unitAndTime.add(billing.TimeUnit__c);
			}
			if(!unitAndTime.isEmpty()){
				wrapper.unit = String.join(unitAndTime, '/');
			}
			
			wrapper.chargeUnitTotal = billing.ChargeUnitTotal__c;
			wrapper.periodUnit = billing.PeriodUnit__c;
			if(printType == 'DEBIT_USD'){

				//wrapper.billingName = billing.PricingNameAtPrintENG__c;
				wrapper.currencyBilling = 'USD';
				wrapper.unitPrice = billing.UnitPriceOfSellingUSD__c;
				wrapper.amount = billing.TotalAmountOfSellingUSD__c;
				wrapper.amountOfTax = billing.AmountOfTaxSellingUSD__c;
				wrapper.taxRatio = billing.TaxRatioSelling__c;

			}
			if(printType == 'DEBIT_LOCAL'){

				//wrapper.billingName = billing.PricingNameAtPrintLocal__c;
				wrapper.currencyBilling = 'VND';
				wrapper.unitPrice = billing.UnitPriceOfSellingLocal__c;
				wrapper.amount = billing.TotalAmountOfSellingLocal__c;
				wrapper.amountOfTax = billing.AmountOfTaxSelling__c;
				wrapper.taxRatio = billing.TaxRatioSelling__c;

			}
			if(printType == 'CREDIT_USD'){
				//wrapper.billingName = billing.PricingNameAtPrintENG__c;
				wrapper.currencyBilling = 'USD';
				wrapper.unitPrice = billing.UnitPriceOfBuyingUSD__c;
				wrapper.amount = billing.TotalAmountOfBuyingUSD__c;
				wrapper.amountOfTax = billing.AmountOfTaxBuyingUSD__c;
				wrapper.taxRatio = billing.TaxRatioBuying__c;
			}
			if(printType == 'CREDIT_LOCAL'){
				//wrapper.billingName = billing.PricingNameAtPrintLocal__c;
				wrapper.currencyBilling = 'VND';
				wrapper.unitPrice = billing.UnitPriceOfBuying__c;
				wrapper.amount = billing.TotalAmountOfBuyingLocal__c;
				wrapper.amountOfTax = billing.AmountOfTaxBuying__c;
				wrapper.taxRatio = billing.TaxRatioBuying__c;
			}
			if(language == 'vi'){
				wrapper.billingName = billing.PricingNameAtPrintLocal__c;
			}else{
				wrapper.billingName = billing.PricingNameAtPrintENG__c;
			}
			if(wrapper.amount == null){
				wrapper.amount = 0;
			}
			if(wrapper.amountOfTax == null){
				wrapper.amountOfTax = 0;
			}
			subTotalAmount += wrapper.amount;
			totalAmountOfTax += wrapper.amountOfTax;
			listWrapper.add(wrapper);
			no++;

		}
		totalAmount = subTotalAmount + totalAmountOfTax;
		if(listWrapper.size() < 15){
			for(Integer i = listWrapper.size(); i < 15 ; i++){
				listWrapper.add(new BillingWapper());
			}
		}

	}

	public String getAmountInWord(){
			if(language =='vi'){
					amountInword = NumbericUtils.convertNumberToText(totalAmount, currentCurency);
				
			}else{
				if(currentCurency =='VND'){

				amountInword = NumbericUtils.readVNDAmountInEn(totalAmount);
				}else if(currentCurency =='USD'){
					amountInword = NumbericUtils.readUSDAmountInEn(totalAmount);
				}

			}
			
			return amountInword;
		}
	private static Map<String, String > getTranslationMap(String language){
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('unit_translation')){
               translateMapResult.put(key.substringAfter('.'), (String)translate.get(key)); 
            }
            if(key.contains('wms')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
	private static List<Billing__c> getListBilling(String workOrderId, String customerId, String printType){
		String strSql = 'SELECT ID, Name, BillingDisplayNo__c, PricingNameAtPrintENG__c, PricingNameAtPrintLocal__c, ' 
						+ 'Currency__c, Unit__c,TimeUnit__c, ChargeUnitTotal__c, PeriodUnit__c, '
						+ 'UnitPriceOfBuying__c, UnitPriceOfBuyingUSD__c, '
						+ 'TotalAmountOfBuyingLocal__c, TotalAmountOfBuyingUSD__c, '
						+ 'AmountOfTaxBuying__c, AmountOfTaxBuyingUSD__c, TaxRatioBuying__c, '
						+ 'UnitPriceOfSellingLocal__c, UnitPriceOfSellingUSD__c, ' 
						+ 'TotalAmountOfSellingLocal__c, TotalAmountOfSellingUSD__c, '
						+ 'AmountOfTaxSelling__c, AmountOfTaxSellingUSD__c, TaxRatioSelling__c '
						+ 'FROM Billing__c ';
		String strWHERE = 'WHERE WorkOrderID__c =\'' + String.escapeSingleQuotes(workOrderId) + '\'';
		if(printType.contains('DEBIT')){

			strWHERE += ' AND InvoiceTo__c =\'' + String.escapeSingleQuotes(customerId) + '\'';
		}else{
			strWHERE += ' AND PaymentTo__c =\'' + String.escapeSingleQuotes(customerId) + '\'';
		}
		strSql += strWHERE + ' ORDER BY BillingDisplayNo__c ASC';
		List<Billing__c> listBilling = Database.query(strSql);

		return listBilling;

	}
	public class BillingWapper{
		//public String billingId{get; set;}
		public String billingName{get; set;}
		public String language {get; set;}
		public Integer no{get; set;}
		public Decimal unitPrice{get; set;}
		public String unit{get; set;}
		public Decimal chargeUnitTotal{get; set;}
		public Decimal periodUnit{get; set;}
		public Decimal amount{get; set;}
		public Decimal amountOfTax{get; set;}
		public Decimal taxRatio{get; set;}
		public String currencyBilling{get; set;}
		public String amountInWord{get; set;}
		public BillingWapper(){

		}
		public Integer getBillingHeight(){
			Integer height = 1;
			if(billingName != null){
				height = billingName.length()/ 30;
				if(Math.mod(billingName.length(), 30) > 0){
					height += 1;
				}
			}
			
			return height;
		}
		
	}
}