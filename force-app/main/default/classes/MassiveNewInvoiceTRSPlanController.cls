public with sharing class MassiveNewInvoiceTRSPlanController {
	public VAT_INVOICE__c objectSearch{get; set;}
	public String shipmentOrderId{get; set;}
	public String fmsBillId{get; set;}
	public String invoiceName{get;set;}
	public String invoiceType{get; set;}
	public CustomObject1__c shipmentOrderSearch{get; set;}
	public AnkenMeisai__c billSearch{get; set;}
	public String shipmentTimeType{get; set;}
	public String shipmentFromTime{get; set;}
	public String shipmentToTime{get; set;}
	public String shipmentCustomerName{get; set;}
	public List <VAT_INVOICE__c> VATListInbound{get; set;}
	public List <VAT_INVOICE__c> VATListOutbound{get; set;}
	public Boolean isInboundVAT{get; set;}
	private Map<String, String> mapVATType{get; set;}
	private static Set<String> vatIds{get; set;}
	private static Set<String> combinedVATIds{get; set;} 
	private static Set<String> fieldsQuery = new Set<String>();
	private String transactionPlanId{get;set;}
	private String conditionBill{get;set;}
	private String conditionSbipment{get;set;}
    public Map<String, String> mapLabelVatType{get; set;}
	public String tabNameSelect{get;set;}

	static{
		fieldsQuery.add('Id');
		fieldsQuery.add('RecordTypeId');
		fieldsQuery.add('RecordType.DeveloperName');
		fieldsQuery.add('RecordType.Name');
		fieldsQuery.add('Name');
		fieldsQuery.add('RED_INVOICE_NO__c');
		fieldsQuery.add('VAT_INVOICE_TO__c');
		fieldsQuery.add('VAT_INVOICE_TO__r.Name');
		fieldsQuery.add('VAT_INVOICE_ISSUE_STATUS__c');
		fieldsQuery.add('AmountOfTaxVATSelling__c');
		fieldsQuery.add('TotalAmountOfVATSelling__c');
		fieldsQuery.add('AmountVATSellingIncludeVAT__c');
		fieldsQuery.add('VatIssueFrom__c');
		fieldsQuery.add('VatIssueFrom__r.Name');
		fieldsQuery.add('TotalAmountOfVATBuying__c');
		fieldsQuery.add('AmountOfTaxVATBuying__c');
		fieldsQuery.add('AmountVATBuyingIncludeVAT__c');
		fieldsQuery.add('AccountedDate__c');
		fieldsQuery.add('VATInvoicePrintDate__c');
		fieldsQuery.add('VATInvoiceNoFromVendor__c');
	}
	public MassiveNewInvoiceTRSPlanController() {
		transactionPlanId = ApexPages.currentPage().getParameters().get('requestId');
        mapLabelVatType = new Map<String, String>();
        Map<String, Schema.RecordTypeInfo> mapInvoiceRecs = Schema.SObjectType.VAT_INVOICE__c.getRecordTypeInfosByDeveloperName();
		for(String developerName : mapInvoiceRecs.keySet()){
			Schema.RecordTypeInfo recInfo = mapInvoiceRecs.get(developerName);
			mapLabelVatType.put(developerName, recInfo.getName());	
		}
		init();
	}
	private void init(){
		conditionBill = '';
		conditionSbipment = '';
		
		shipmentOrderSearch = new CustomObject1__c();
		billSearch = new AnkenMeisai__c();
		objectSearch = new VAT_INVOICE__c();
		VATListInbound = new List <VAT_INVOICE__c>();
		VATListOutbound = new List <VAT_INVOICE__c>();

		isInboundVAT = false;
		vatIds = new Set<String>();
		combinedVATIds = new Set<String>();
		mapVATType = new Map<String, String>();

		mapVATType.put('VendorVATInvoice','Inbound');
		mapVATType.put('FMSTMSWMSVATInvoice','Outbound');
		mapVATType.put('CloWMSVATInvoice','Outbound');
		mapVATType.put('MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY','Outbound');
		
		//get recordTypedetail
		PaymentRequest__c trxPlan = getTransactionPlanDetail(transactionPlanId);
		if(trxPlan.RecordType.developerName == 'PaymentRequestUSDCurrency'
			|| trxPlan.RecordType.developerName == 'PaymentRequestlocalCurrency'){
			isInboundVAT = true;
			invoiceType = 'VendorVATInvoice';
			tabNameSelect = 'VATInbound';
		}else{
			isInboundVAT = false;
			invoiceType = 'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY';
			tabNameSelect = 'VATOutbound';
		}
		getCombinedVATIds();
		String vatQuery = buildVATQuery();
		handleVATList(Database.query(vatQuery));
	}
	private PaymentRequest__c getTransactionPlanDetail(String planId){
		List<PaymentRequest__c> trxPlans = [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName 
								FROM PaymentRequest__c
								WHERE Id =: planId];
		if(!trxPlans.isEmpty()){
			return trxPlans[0];
		}
		return new PaymentRequest__c();
	}
	public List<SelectOption> getInvoiceTypes(){
		List<SelectOption> options = new List<SelectOption>();
		Map<String, Schema.RecordTypeInfo> mapInvoiceRecs = Schema.SObjectType.VAT_INVOICE__c.getRecordTypeInfosByDeveloperName();
		for(String developerName : mapInvoiceRecs.keySet()){
			Schema.RecordTypeInfo recInfo = mapInvoiceRecs.get(developerName);
			if(recInfo.isActive() && developerName != 'Master'){
				options.add(new SelectOption(developerName, recInfo.getName()));
			}
		}
		return options;
	}
	public void doSearch(){
		combinedVATIds = new Set<String>();
		vatIds = new Set<String>();
		getCombinedVATIds();
		VATListInbound = new List <VAT_INVOICE__c>();
		VATListOutbound = new List <VAT_INVOICE__c>();
		if( mapVATType.get(invoiceType) == 'Inbound'){
			isInboundVAT = true;
		}
		// search shipment
		String shipmnetQuery = buildShipmentQuery();
		if(!String.isBlank(conditionSbipment)){
			List<FORWARDING_VAT__c> shipmentVATList = Database.query(shipmnetQuery);
			
			for(FORWARDING_VAT__c shipmentVAT : shipmentVATList){
				vatIds.add(shipmentVAT.VAT_INVOICE__c);
			}
		}
		
		// Search bill
		String billQuery = buildBillQuery();
		if(!String.isBlank(conditionBill)){
			
			List<INVOICING_VAT__c> billVATList = Database.query(billQuery);
			for(INVOICING_VAT__c billVAT : billVATList){
				vatIds.add(billVAT.VAT_INVOICE__c);
			}
		}
		// Search vat
		String vatQuery = buildVATQuery();
		List<VAT_INVOICE__c> VATList = Database.query(vatQuery);
		handleVATList(Database.query(vatQuery));
		
	}
	public void actionChangeTab(){
		tabNameSelect = ApexPages.currentPage().getParameters().get('tabName');
	}

	public PageReference actionCombineVat(){
		PageReference page = new PageReference('/' + transactionPlanId);
		String strSelectedVatIds = ApexPages.currentPage().getParameters().get('selectedVatIds');
		List<String> selectedVatIds = strSelectedVatIds.split(',');
		List<VATPayReq__c> newVATPayReqs = new List<VATPayReq__c>();
		for(String vatId : selectedVatIds){
			VATPayReq__c vatPlan = new VATPayReq__c(
				PaymentRequestID__c = transactionPlanId,
				VATInvoiceID__c = vatId);
			newVATPayReqs.add(vatPlan);
		}
		try{
        	FlsService.doInsert(newVATPayReqs);
            //VATPayReqTriggerHelper.connectSOANDBillToTransactionPlan(newVATPayReqs);
			page.setRedirect(true);
			return page;
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm, 'Success!'));
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
			return null;
		}
	}

	private void getCombinedVATIds(){
		List<VATPayReq__c> listCombinedVat = [SELECT Id, VATInvoiceID__c FROM VATPayReq__c
			WHERE  PaymentRequestID__c =: transactionPlanId];
		for(VATPayReq__c vatPlan : listCombinedVat){
			combinedVATIds.add(vatPlan.VATInvoiceID__c);
		}
	}
	private void handleVATList(List<VAT_INVOICE__c> argVATList){

		for(VAT_INVOICE__c vat : argVATList){
			if(mapVATType.get(vat.RecordType.DeveloperName) == 'Inbound'){
				VATListInbound.add(vat);
			}else{
				VATListOutbound.add(vat);
			}
		}
		// if(VATListInbound.size() > 0){
		// 	tabNameSelect = 'VATInbound';
		// }else{
		// 	tabNameSelect = 'VATOutbound';
		// }
	}
	private Date formatStringDate(String strDate){
		try{
			Date result = date.parse(strDate);
			return result;
		}catch(Exception ex){
			return null;
		}
	}
	private String buildShipmentQuery(){
		String strQuery = 'SELECT ID, FORWARDING__c, VAT_INVOICE__c FROM FORWARDING_VAT__c';
		String condition = '';
		if(!String.isBlank(shipmentOrderId)){
			condition += ' AND FORWARDING__r.Name like \'%' + String.escapeSingleQuotes(shipmentOrderId) + '%\'';
		}
		if(!String.isBlank(shipmentOrderSearch.REFNO__c)){
			condition += ' AND FORWARDING__r.REFNO__c like \'%' + String.escapeSingleQuotes(shipmentOrderSearch.REFNO__c) + '%\'';
		}
		if(!String.isBlank(shipmentOrderSearch.Cnee__c)){
			condition += ' AND FORWARDING__r.Cnee__c = \'' + String.escapeSingleQuotes(shipmentOrderSearch.Cnee__c) + '\'';
		}
		if(!String.isBlank(shipmentTimeType)){
			Date fromDate = formatStringDate(shipmentFromTime);
			Date toDate = formatStringDate(shipmentToTime);
			if(shipmentTimeType == 'ETD'){
				if(fromDate != null){
					condition += ' AND FORWARDING__r.ETD__c >= ' + String.valueOf(fromDate);
				}
				if(toDate != null){
					condition += ' AND FORWARDING__r.ETD__c <= ' + String.valueOf(toDate);
				}
			}else if(shipmentTimeType == 'Accounted Date'){
				if(fromDate != null){
					condition += ' AND FORWARDING__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate);
				}
				if(toDate != null){
					condition += ' AND FORWARDING__r.SalesAccountedDate__c <= ' + String.valueOf(toDate);
				}
			}else{
				if(fromDate != null){
					condition += ' AND FORWARDING__r.ETA__c >= ' + String.valueOf(fromDate);
				}
				if(toDate != null){
					condition += ' AND FORWARDING__r.ETA__c <= ' + String.valueOf(toDate);
				}
			}
			
		}
		if(!String.isBlank(shipmentOrderSearch.HBL__c)){
			condition += ' AND FORWARDING__r.HBL__c like \'%' + String.escapeSingleQuotes(shipmentOrderSearch.HBL__c) + '%\'';
		}
		if(!String.isBlank(shipmentCustomerName)){
			condition += ' AND FORWARDING__r.Field1__r.Name like \'%' + String.escapeSingleQuotes(shipmentCustomerName) + '%\'';
		}
		if(!String.isBlank(shipmentOrderSearch.Master_B_L__c)){
			condition += ' AND FORWARDING__r.Master_B_L__c like \'%' + String.escapeSingleQuotes(shipmentOrderSearch.Master_B_L__c) + '%\'';
		}
		if(!String.isBlank(shipmentOrderSearch.shipper__c)){
			condition += ' AND FORWARDING__r.shipper__c = \'' + String.escapeSingleQuotes(shipmentOrderSearch.shipper__c) + '\'';
		}

		if(!String.isBlank(shipmentOrderSearch.POL__c)){
			condition += ' AND FORWARDING__r.POL__c = \'' + String.escapeSingleQuotes(shipmentOrderSearch.POL__c) + '\'';
		}
		if(!String.isBlank(shipmentOrderSearch.POD__c)){
			condition += ' AND FORWARDING__r.POD__c = \'' + String.escapeSingleQuotes(shipmentOrderSearch.POD__c) + '\'';
		}
		conditionSbipment = condition;
		strQuery += condition.replaceFirst('AND', 'WHERE');
		return strQuery;
	}
	private String buildBillQuery(){
		String strQuery = 'SELECT Id, VAT_INVOICE__c, INVOICING__c FROM INVOICING_VAT__c';
		String condition = '';
		if(!String.isBlank(fmsBillId)){
			condition += ' AND INVOICING__r.Name like \'%' + String.escapeSingleQuotes(fmsBillId) + '%\'';
		}
		if(!String.isBlank(billSearch.Seikyusaki__c)){
			condition += ' AND INVOICING__r.Seikyusaki__c = \'' + String.escapeSingleQuotes(billSearch.Seikyusaki__c) + '\'';
		}
		if(!String.isBlank(billSearch.PaymentTo__c)){
			condition += ' AND INVOICING__r.PaymentTo__c = \'' + String.escapeSingleQuotes(billSearch.PaymentTo__c) + '\'';
		}
		conditionBill = condition;
		strQuery += condition.replaceFirst('AND', 'WHERE');
		return strQuery;
	}

	private String buildVATQuery(){
		String strQuery = 'SELECT ' + String.join(new List<String>(fieldsQuery), ',')+' FROM VAT_INVOICE__c';
		String condition = '';
		if(!String.isBlank(invoiceType)){
			condition += ' AND RecordType.DeveloperName = \'' + String.escapeSingleQuotes(invoiceType) + '\'';
		}
		if(!String.isBlank(invoiceName)){
			condition += ' AND Name like \'%' + String.escapeSingleQuotes(invoiceName) + '%\'';
		}
		if(!String.isBlank(objectSearch.RED_INVOICE_NO__c)){
			condition += ' AND (RED_INVOICE_NO__c like \'%' + String.escapeSingleQuotes(objectSearch.RED_INVOICE_NO__c) + '%\'';
			condition += ' OR VATInvoiceNoFromVendor__c like \'%' + String.escapeSingleQuotes(objectSearch.RED_INVOICE_NO__c) + '%\')';
		}
		if(!String.isBlank(objectSearch.VatIssueFrom__c)){
			condition += ' AND VatIssueFrom__c = \'' + String.escapeSingleQuotes(objectSearch.VatIssueFrom__c) + '\'';
		}
		if(!String.isBlank(objectSearch.VAT_INVOICE_TO__c)){
			condition += ' AND VAT_INVOICE_TO__c = \'' + String.escapeSingleQuotes(objectSearch.VAT_INVOICE_TO__c) + '\'';
		}
		if(!vatIds.isEmpty()){
			//if(String.isBlank(condition)){
				condition += ' AND Id IN: vatIds';
			//}
			//}else{
			//	condition = ' AND (' + condition.replaceFirst('AND', '') + ' ) OR Id IN: vatIds';
			//}

		}
		if(!combinedVATIds.isEmpty()){
			condition += ' AND Id NOT IN: combinedVATIds';
		}

		strQuery += condition.replaceFirst('AND', 'WHERE');
		return strQuery;
	}
	public void doClear(){
		init();
	}
	
}