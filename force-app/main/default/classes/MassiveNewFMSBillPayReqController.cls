public with sharing class MassiveNewFMSBillPayReqController {
    public AnkenMeisai__c billSearch{get; set;}
	public List<AnkenMeisai__c> listBillResult{get; set;}
	public String shipmentOrderId{get; set;}
    public String shipmentJobNo{get;set;}
	public CustomObject1__c shipmentOrderSearch{get; set;}
	public String shipmentCustomerName{get; set;}
    public ObjSearch objSearch {get; set;}
    public String strRT {get; set;}
    private Id prmId {get; set;}
	private static Set<String> fieldsQuery = new Set<String>();
	private static Set<Id> connectedBills = new Set<Id>();
    private static Set<Id> lstbillId = new Set<Id>();

    public String strQuery {get; set;}
    public String shipmentID {get; set;}
    public String[] trxPlan2 {get;set;}

	static{
		fieldsQuery.add('Id');
		fieldsQuery.add('RecordTypeId');
		fieldsQuery.add('RecordType.DeveloperName');
		fieldsQuery.add('RecordType.Name');
		fieldsQuery.add('Name');
		fieldsQuery.add('Anken__r.Name');
		fieldsQuery.add('Anken__c');
		fieldsQuery.add('SeikyuBangou__c');
		fieldsQuery.add('Seikyusaki__r.Name');
		fieldsQuery.add('Seikyusaki__c');
		fieldsQuery.add('InsatuyouSyohin__c');
		fieldsQuery.add('TaxInitial__c');
		fieldsQuery.add('SellTankaJPY__c'); 
        fieldsQuery.add('BuyAmountJPN__c');
		fieldsQuery.add('SellAmountJPN__c');
		fieldsQuery.add('SellTaxNum__c');
        fieldsQuery.add('BuyTankaJPY__c');
		fieldsQuery.add('BuyInTaxAmountJPY__c');
		fieldsQuery.add('SellInTaxAmountJPY__c');
		fieldsQuery.add('OutboundVATInvNo__c');
		fieldsQuery.add('InboundVATInvNo__c');
		fieldsQuery.add('BuyDifferentiation__c');
		fieldsQuery.add('SellDifferentiation__c');
		fieldsQuery.add('Suryo__c');
		fieldsQuery.add('BuyTaxInitial__c');
		fieldsQuery.add('Siharaigaku__c');
		fieldsQuery.add('Nyukingaku__c');
		fieldsQuery.add('PaymentTo__c');
		fieldsQuery.add('Tariff__r.Supplier__c');
		fieldsQuery.add('Tariff__c');
		fieldsQuery.add('Tariff__r.Name');
		fieldsQuery.add('Tariff__r.CUSTOMER__c');
		fieldsQuery.add('PaymentTo__r.Name');
        fieldsQuery.add('Anken__r.JobRequestID__c');
        fieldsQuery.add('Anken__r.HBL_Number_SEA_AIR__c');
        fieldsQuery.add('Anken__r.MBL_Number_SEA_AIR__c');
        fieldsQuery.add('Anken__r.Id__c');
        fieldsQuery.add('BuyInTaxAmountUSD__c');
        fieldsQuery.add('AMOUNT_PAID_BUYING_USD__c');
        fieldsQuery.add('UNPAID_BALANCE_OF_BUYING_USD__c');
        fieldsQuery.add('SellInTaxAmount_USD__c');
        fieldsQuery.add('AMOUNT_PAID_SELLING_USD__c');
        fieldsQuery.add('UNPAID_BALANCE_OF_SELLING_USD__c');
        fieldsQuery.add('AmountBuyingInclTax3rdCurrency__c');
        fieldsQuery.add('AmountPaid3rdCurrency__c');
        fieldsQuery.add('UnpaidBalance3rdCurrency__c');
        fieldsQuery.add('AmountSellingInclTax3rdCurrency__c');
        fieldsQuery.add('AmountReceived3rdCurrency__c');
        
	}

    public MassiveNewFMSBillPayReqController(){
        Site_Custom_Settings__c settings = Site_Custom_Settings__c.getOrgDefaults();
		billSearch = new AnkenMeisai__c();
		objSearch = new ObjSearch();
        // objSearch.currencyType = 'Both';
        objSearch.currencyType = settings.Local_Currency__c;
        objSearch.amountType = 'Both';
		shipmentOrderSearch = new CustomObject1__c();
		listBillResult = new List<AnkenMeisai__c>();
        prmId = ApexPages.currentPage().getParameters().get('requestId');
        String recordTypeTrx = [SELECT Id,RecordTypeId FROM clofor_com_cfs__PaymentRequest__c WHERE id = :prmId].RecordTypeId;
        List<clofor_com_cfs__PaymentRequest__c> listTrx = [SELECT id, Name , (select clofor_com_cfs__FTMSBillName__c from clofor_com_cfs__FMSBillPayReq__r) FROM clofor_com_cfs__PaymentRequest__c WHERE RecordTypeId = :recordTypeTrx];
        for (clofor_com_cfs__PaymentRequest__c trx : listTrx){
            for (FMSBillPayReq__c billpay : trx.clofor_com_cfs__FMSBillPayReq__r){
                if (billpay.clofor_com_cfs__FTMSBillName__c != null && billpay.clofor_com_cfs__FTMSBillName__c != ''){
                    lstbillId.add(billpay.clofor_com_cfs__FTMSBillName__c);
                }
                // a += billpay.clofor_com_cfs__FMSBillID__c +' <br/>';
            }
        }

        List<String> Borrow = getBorrower();

        List<PaymentRequest__c> pqs= [Select Id from PaymentRequest__c where Id =: prmId];
        if(pqs.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'This payment request is not existing.'));
        }else{
            doSearchNew();
        }
    }
    
    private List<String> getBorrower(){                                          
        String queryStr = buildQueryStr();
        Integer count = 1;
        List<AnkenMeisai__c> listBill = Database.query(queryStr);
        trxPlan2 = new String[listBill.size()];
        List<String> trxPlan = new List<String>();
        for (AnkenMeisai__c bill : listBill){
            String trxName = '';
            for (FMSBillPayReq__c billpay : bill.clofor_com_cfs__FMSBillPayReq__r){
                
                trxName += billpay.clofor_com_cfs__TrxPlanName__c +' <br/>';                     
            }
            trxPlan.add(trxName);
            count++;
        }
        for (Integer i=0;i<listBill.size();i++){
            trxPlan2[i]= trxPlan.get(i);
        }
        return trxPlan;
    }

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(listBillResult);
                setCon.setPageSize(30);  
                //noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        private set;
    }
    public List<AnkenMeisai__c> getBills(){
        System.debug('lstBill : '+ (List<AnkenMeisai__c>) setCon.getRecords());
        return (List<AnkenMeisai__c>) setCon.getRecords();
    }

    public List<SelectOption> getCurrencies() {
        List<SelectOption> currencies = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = AnkenMeisai__c.curr__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : ple) {
            currencies.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return currencies;
    }

	public void doSearchNew(){
		getBillIdsConnected();
        List<FMSBillPayReq__c> lstbill  = new List<FMSBillPayReq__c>();
		String queryStr = buildQueryStr();
        listBillResult = Database.query(queryStr);
        System.debug('Quan query: '+queryStr);
        listBillResult.size();
        setCon = new ApexPages.StandardSetController(listBillResult);
        setCon.setPageSize(30);
        setCon.first();
        
	}
	private void getBillIdsConnected(){
		List<FMSBillPayReq__c> listBillPlan = [SELECT Id, PaymentRequestID__c, FMSBillID__c
													FROM FMSBillPayReq__c 
													WHERE PaymentRequestID__c =: prmId];
		for(FMSBillPayReq__c billReq : listBillPlan){
			connectedBills.add(billReq.FMSBillID__c);
		}
	}


	private String buildQueryStr(){
		String queryStr = 'SELECT ' + String.join(new List<String>(fieldsQuery), ',') +', (SELECT clofor_com_cfs__TrxPlanName__c FROM clofor_com_cfs__FMSBillPayReq__r) FROM clofor_com_cfs__AnkenMeisai__c';
		String conditionStr = '';
        String shipmentOrderIdList = '';
        String shipmentOrderIdListFinal = '';
        String JobInputList = '';
        String JobInputListFinal = '';
        // if (String.isNotBlank(shipmentOrderId)) {
	        // List<String> shipmentOrderInputList = shipmentOrderId.split(',');
	        // for (String shipmentOrderInput : shipmentOrderInputList) {
		        // shipmentOrderInput = shipmentOrderInput.trim();
		    // if (String.isNotBlank(shipmentOrderInput)) {
			    // shipmentOrderIdList += '\'' + shipmentOrderInput + '\',';
		        // }
	        // }
            // shipmentOrderIdListFinal = shipmentOrderIdList.substring(0,shipmentOrderIdList.length() - 1);
        // }
        if (String.isNotBlank(shipmentOrderId)) {
            List<String> shipmentOrderInputList = shipmentOrderId.split(',');
            for (String shipmentOrderInput : shipmentOrderInputList) {
                shipmentOrderInput = shipmentOrderInput.trim();
            if (String.isNotBlank(shipmentOrderInput)) {
                shipmentOrderIdList += 'Anken__r.Id__c LIKE \'%' + shipmentOrderInput + '%\' OR ';
                }
            }
            shipmentOrderIdListFinal = shipmentOrderIdList.substring(0,shipmentOrderIdList.length() - 4);
        }
        if (String.isNotBlank(shipmentOrderSearch.REFNO__c)) {
            List<String> JobNoInputList = shipmentOrderSearch.REFNO__c.split(',');
            for (String JobNoInput : JobNoInputList) {
                JobNoInput = JobNoInput.trim();
            if (String.isNotBlank(JobNoInput)) {
                JobInputList += '\'' + JobNoInput + '\',';
                }
            }
            JobInputListFinal = JobInputList.substring(0,JobInputList.length() - 1);
        }
        if (objSearch.amountType == 'BUYING'){
            conditionStr += ' AND (BuyDifferentiation__c != 0 OR UNPAID_BALANCE_OF_BUYING_USD__c != 0)';
        } else if (objSearch.amountType == 'SELLING'){
            conditionStr += ' AND (SellDifferentiation__c != 0 OR UNPAID_BALANCE_OF_SELLING_USD__c != 0)';
        } else {
            conditionStr += ' AND (BuyDifferentiation__c != 0 OR SellDifferentiation__c != 0 OR UNPAID_BALANCE_OF_BUYING_USD__c != 0 OR UNPAID_BALANCE_OF_SELLING_USD__c != 0)';
        }
		if(!connectedBills.isEmpty()){
			conditionStr += ' AND Id NOT IN: connectedBills';
		}
        if(!lstbillId.isEmpty()){
            conditionStr += ' AND Id NOT IN: lstbillId';
        }
		// if(!String.isBlank(shipmentOrderId)){
            // conditionStr += ' AND Anken__r.Name like \'%' + String.escapeSingleQuotes(shipmentOrderId) + '%\'';
        // }
        // if(!String.isBlank(shipmentOrderId)){
            // conditionStr += ' AND Anken__r.Name IN(' + shipmentOrderIdListFinal + ')';
        // }
        if(!String.isBlank(shipmentOrderId)){
            conditionStr += ' AND (' + shipmentOrderIdListFinal + ')';
        }
        // REF.NO/job ID
        // if(!String.isBlank(shipmentOrderSearch.REFNO__c)){
            // conditionStr += ' AND ( Anken__r.REFNO__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.REFNO__c) + '\'';
            // conditionStr += ' OR Anken__r.JobRequestID__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.REFNO__c) + '\') ';
        // }
        if(!String.isBlank(shipmentOrderSearch.REFNO__c)){
            conditionStr += ' AND ( Anken__r.REFNO__c IN(' + JobInputListFinal + ')';
            conditionStr += ' OR Anken__r.JobRequestID__c IN(' + JobInputListFinal + '))';
        }
 
        // CONSIGNEE
        if(!String.isBlank(shipmentOrderSearch.Cnee__c)){
            conditionStr += ' AND Anken__r.Cnee__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.Cnee__c) + '\'';
        }
        
        // TIME
        if(!String.isBlank(objSearch.sFromTime)){
            List<String> lstDate = new List<String>();
            lstDate = objSearch.sFromTime.split('/');
            String strFrom = '';
            if(!lstDate.isEmpty()){
                strFrom = lstDate.get(2) + '-' + lstDate.get(1) + '-' + lstDate.get(0);
            }
            if(objSearch.sTimeType == 'Accounted Date'){
                conditionStr += ' AND Anken__r.SalesAccountedDate__c >= ' + String.escapeSingleQuotes(strFrom);
            }
            if(objSearch.sTimeType == 'ETD'){
                conditionStr += ' AND Anken__r.ETD__c >= ' + String.escapeSingleQuotes(strFrom);
            }
            if(objSearch.sTimeType == 'ETA'){
                conditionStr += ' AND Anken__r.ETA__c >= ' + String.escapeSingleQuotes(strFrom);
            }
        }
        if(!String.isBlank(objSearch.sToTime)){
            List<String> lstDate = new List<String>();
            lstDate = objSearch.sToTime.split('/');
            String strTo = '';
            if(!lstDate.isEmpty()){
                strTo = lstDate.get(2) + '-' + lstDate.get(1) + '-' + lstDate.get(0);
            }
            if(objSearch.sTimeType == 'Accounted Date'){
                conditionStr += ' AND Anken__r.SalesAccountedDate__c <= ' + String.escapeSingleQuotes(strTo);
            }
            if(objSearch.sTimeType == 'ETD'){
                conditionStr += ' AND Anken__r.ETD__c <= ' + String.escapeSingleQuotes(strTo) ;
            }
            if(objSearch.sTimeType == 'ETA'){
                conditionStr += ' AND Anken__r.ETA__c <= ' + String.escapeSingleQuotes(strTo);
            }
        }
        
        // H B/L NUMBER
        // if(!String.isBlank(shipmentOrderSearch.HBL__c)){
        //     conditionStr += ' AND Anken__r.HBL__c like \'%' + shipmentOrderSearch.HBL__c + '%\'';
        // }
        // H B/L NUMBER / M B/L NUMBER
        if(!String.isBlank(shipmentOrderSearch.HBL_Number_SEA_AIR__c)){
            conditionStr += ' AND Anken__r.HBL_Number_SEA_AIR__c like \'%' + String.escapeSingleQuotes(shipmentOrderSearch.HBL_Number_SEA_AIR__c) + '%\'';
            
        }
        if(!String.isBlank(shipmentOrderSearch.MBL_Number_SEA_AIR__c)){
            conditionStr += ' AND Anken__r.MBL_Number_SEA_AIR__c like \'%' + String.escapeSingleQuotes(shipmentOrderSearch.MBL_Number_SEA_AIR__c) + '%\'';
        }
        // CUSTOMER
        if(!String.isBlank(objSearch.sCustomer)){
            conditionStr += ' AND Anken__r.Field1__r.Name like \'%' + String.escapeSingleQuotes(objSearch.sCustomer) + '%\'';
        }
        
        // M B/L NUMBER
        // if(!String.isBlank(shipmentOrderSearch.Master_B_L__c)){
        //     conditionStr += ' AND Anken__r.Master_B_L__c like \'%' + shipmentOrderSearch.Master_B_L__c + '%\'';
        // }
        
        // SHIPPER
        if(!String.isBlank(shipmentOrderSearch.shipper__c)){
            conditionStr += ' AND Anken__r.shipper__c = \'' + String.escapeSingleQuotes(shipmentOrderSearch.shipper__c) + '\'';
        }
        
        // POL
        if(!String.isBlank(shipmentOrderSearch.POL__c)){
            conditionStr += ' AND Anken__r.POL__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.POL__c) + '\'';
        }

        // POD
        if(!String.isBlank(shipmentOrderSearch.POD__c)){
            conditionStr += ' AND Anken__r.POD__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.POD__c) + '\'';
        }
        
        // PAYMENT TO-BUYING
        if(!String.isBlank(billSearch.PaymentTo__c)){
            conditionStr += ' AND PaymentTo__c = \'' + String.escapeSingleQuotes(billSearch.PaymentTo__c) + '\'';
        }
        // INVOICE TO
        if(!String.isBlank(billSearch.Seikyusaki__c)){
            conditionStr += ' AND Seikyusaki__c = \'' + String.escapeSingleQuotes(billSearch.Seikyusaki__c) + '\'';
        }
        if(!String.isBlank(billSearch.InboundVATInvNo__c)){
            conditionStr += ' AND InboundVATInvNo__c LIKE \'%' + String.escapeSingleQuotes(billSearch.InboundVATInvNo__c) + '%\'';
        }
         if(!String.isBlank(billSearch.OutboundVATInvNo__c)){
            conditionStr += ' AND OutboundVATInvNo__c LIKE \'%' + String.escapeSingleQuotes(billSearch.OutboundVATInvNo__c) + '%\'';
        }
		if(!String.isBlank(conditionStr)){
			conditionStr = conditionStr.replaceFirst('AND', 'WHERE');
			queryStr += conditionStr;
		}
		queryStr += ' ORDER BY Anken__c, Name LIMIT 500';
		return queryStr;
	}

	public void doClear(){
        objSearch = new ObjSearch();
        objSearch.currencyType = 'Both';
        objSearch.amountType = 'Both';
        shipmentOrderSearch = new CustomObject1__c();
        billSearch = new AnkenMeisai__c();
	
    }
    
    public void doInsert(){
        
		try{
		String strIdBills = ApexPages.currentPage().getParameters().get('listBillIds');
		List<String> listBillIds = strIdBills.split(',');
		List<FMSBillPayReq__c> listNewBillRequest = new List<FMSBillPayReq__c>();
		for(String billId : listBillIds){
			FMSBillPayReq__c newBillReq = new FMSBillPayReq__c(
				PaymentRequestID__c = prmId, 
				FMSBillID__c = billId
			);
			listNewBillRequest.add(newBillReq);
		}
            FlsService.doInsert(listNewBillRequest);
			doSearchNew();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm, 'Success!'));
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
		}
    }

    public Pagereference doClose(){
        PageReference page = new PageReference('/' + prmId);
        page.setRedirect(true);
        return page;
    }
	
    public class ObjSearch{
        public String sName {get; set;}
        public String sRefNo {get; set;}
        public String sCnee {get; set;}
        
        public String sHBL {get; set;}
        public String sCustomer {get; set;}
       
        public String sMBL {get; set;}
        public String sShipper {get; set;}
        public String sPOL {get; set;}
        public String sPOD {get; set;}
        public String sTimeType {get; set;}
        public String currencyType{get; set;}
        public String amountType{get; set;}
        public String sFromTime {get; set;}
        public String sToTime {get; set;}
        // Inbound
        public String sPayment {get; set;}
        public String sBuyTaxInitial {get; set;}
        // Outbound
        public String sSeikyusaki {get; set;}
        public String sTaxInitial {get; set;}
        public ObjSearch(){
            this.sName = '';
            this.sRefNo = '';
            this.sCnee = '';
            this.sCustomer = '';
            this.sHBL = '';
            this.sTimeType = 'Accounted Date';
            this.sFromTime = '';
            this.sToTime = '';
            this.sMBL = '';
            this.sShipper = '';
            this.sPOL = '';
            this.sPOD = '';
            this.sPayment = '';
            this.sBuyTaxInitial = '';
            this.sSeikyusaki = '';
            this.sTaxInitial = '';
        }
    }
   
}