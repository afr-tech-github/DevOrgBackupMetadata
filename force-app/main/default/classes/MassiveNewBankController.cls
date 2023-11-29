public with sharing class MassiveNewBankController {
    public ObjSearch objSearch {get; set;}
    public CustomObject1__c shipmentOrderSearch{get; set;}
    public AnkenMeisai__c billFMSSearch{get; set;}
    public List<AnkenMeisai__c> listBillFMSResult{get; set;}
    public String listBillFMSString{get; set;}
    public String strHeader {get; set;}
	
    public String strType {get; set;}
    private String strId {get; set;}
	
    public String strTypeFMS {get; set;}
    public FMSWrapper wrapperFMS {get; set;}
    public WMSWrapper wrapperWMS {get; set;}
    private static Set<Id> connectedFMSBills = new Set<Id>();
    private static Set<String> fieldsQuery = new Set<String>();

    private static final String TAB_PARAMETER_NAME = 'isTabShow';
	private static final String RECEIVABLE_TAB = 'receivableTab';
	private static final String PAYABLE_TAB = 'payableTab';
	private static final String MEISAIID = 'meisaiIds';
	private static final String SHOW_ALL = 'Show all';
	private static final String CHECK_ONLY = 'Check only';
	private static final String UNCHECK_ONLY = 'Un-check only';
	private static final String LOCAL = 'Local';
	private static final String ENGLISH = 'English';

    public static clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiFilter {get; set;}
	public static clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiFilterTo {get; set;}
	public static clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiInput {get; set;}
	public static String orderNo {get; set;}
    
    public Boolean isShowReceivable {get; set;}
	public String localCurrency {get; set;}
	public String tabNameSelect {get; set;}

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
        fieldsQuery.add('BuyInTaxAmountUSD__c');
        fieldsQuery.add('AMOUNT_PAID_BUYING_USD__c');
        fieldsQuery.add('UNPAID_BALANCE_OF_BUYING_USD__c');
        fieldsQuery.add('SellInTaxAmount_USD__c');
        fieldsQuery.add('AMOUNT_PAID_SELLING_USD__c');
        fieldsQuery.add('UNPAID_BALANCE_OF_SELLING_USD__c');
        
	}

    static {
		objAnkenMeisaiInput = new clofor_com_cfs__AnkenMeisai__c();
		objAnkenMeisaiFilter = new clofor_com_cfs__AnkenMeisai__c(
			clofor_com_cfs__Nyukingaku__c = 0
			,clofor_com_cfs__AmountSellingLocalAdjustment__c = 0
			,clofor_com_cfs__Siharaigaku__c = 0
			,clofor_com_cfs__AmountBuyingLocalAdjustment__c = 0
		);
		objAnkenMeisaiFilterTo = new clofor_com_cfs__AnkenMeisai__c();
	}

    @RemoteAction
    public static List<clofor_com_cfs__AnkenMeisai__c> getData(
    															// ,Decimal amount
															  	// ,Decimal unpaid
															  	// ,String customerId
																// ,String advance
																// ,String strDateFrom
																// ,String strDateTo
																String orderNo) {
		// if (amount == null || amount < 0) {
		// 	amount = 0;
		// }

		// if (unpaid == null || unpaid < 0) {
		// 	unpaid = 0;
		// }
		
		// Boolean isAdvance = null;
		// if (advance == 'Check only') {
		// 	isAdvance = true;
		// } else if (advance == 'Un-check only') {
		// 	isAdvance = false;
		// }

		// Date dateFrom = null;
		// Date dateTo = null;

		// if (String.isNotBlank(strDateFrom)) {
		// 	dateFrom = Date.parse(strDateFrom);
		// }

		// if (String.isNotBlank(strDateTo)) {
		// 	dateTo = Date.parse(strDateTo);
		// }

		List<String> orderNoList = new List<String>();
		if (String.isNotBlank(orderNo)) {
			List<String> orderNoInputList = orderNo.split(',');

			for (String oderNoInput : orderNoInputList) {
				oderNoInput = oderNoInput.trim();
				if (String.isNotBlank(oderNoInput)) {
					orderNoList.add('%' + oderNoInput + '%');
				}
			}
		}

        return getAnkenMeisaiList(orderNoList);   
    }

    private clofor_com_cfs__AnkenMeisai__c createanKenMeisaiUpdate(String meisaiIdUpdate
																	,clofor_com_cfs__AnkenMeisai__c objAnkenMeisai) {
		clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiUpdate = new clofor_com_cfs__AnkenMeisai__c();
		objAnkenMeisaiUpdate.Id = meisaiIdUpdate;

			objAnkenMeisaiUpdate.clofor_com_cfs__NyukinKakuninzumi__c = objAnkenMeisai.clofor_com_cfs__NyukinKakuninzumi__c;
			// objAnkenMeisaiUpdate.clofor_com_cfs__Payer__c = objAnkenMeisai.clofor_com_cfs__Payer__c;
			objAnkenMeisaiUpdate.clofor_com_cfs__BANKTRANSITTYPE__c = objAnkenMeisai.clofor_com_cfs__BANKTRANSITTYPE__c;
			objAnkenMeisaiUpdate.clofor_com_cfs__ReceiptanceDate_del__c = objAnkenMeisai.clofor_com_cfs__ReceiptanceDate_del__c;
			// objAnkenMeisaiUpdate.clofor_com_cfs__BankAccountForReceiving__c = objAnkenMeisai.clofor_com_cfs__BankAccountForReceiving__c;
			// objAnkenMeisaiUpdate.clofor_com_cfs__SellDetail__c = objAnkenMeisai.clofor_com_cfs__SellDetail__c;

		return objAnkenMeisaiUpdate;
	}

    private static List<clofor_com_cfs__AnkenMeisai__c> getAnkenMeisaiList(List<String> orderNoList) {		

		String soqlQuery = 'SELECT ' +
								'Id ' +
								',Name ' +
								',clofor_com_cfs__Anken__c ' +
								',clofor_com_cfs__Anken__r.Name ' +
								',clofor_com_cfs__Anken__r.clofor_com_cfs__SalesAccountedDate__c ' +
								',clofor_com_cfs__Seikyusaki__c ' +
								',clofor_com_cfs__Seikyusaki__r.Name ' +
								',clofor_com_cfs__InsatuyouSyohin__c ' +
								',clofor_com_cfs__InsatuyouSyohinEng__c ' +
								',clofor_com_cfs__NyukinKakuninzumi__c ' +
								',clofor_com_cfs__SellInTaxAmountJPY__c ' +
								',clofor_com_cfs__Nyukingaku__c ' +
								',clofor_com_cfs__SellDifferentiation__c' +
								',clofor_com_cfs__SellInTaxAmount_USD__c ' +
								',clofor_com_cfs__AMOUNT_PAID_SELLING_USD__c ' +
								',clofor_com_cfs__UNPAID_BALANCE_OF_SELLING_USD__c ' +
								',clofor_com_cfs__Payer__c ' +
								',clofor_com_cfs__Payer__r.Name ' +
								',toLabel(clofor_com_cfs__BANKTRANSITTYPE__c) ' +
								',clofor_com_cfs__ReceiptanceDate_del__c ' +
								',clofor_com_cfs__BankAccountForReceiving__c ' +
								',clofor_com_cfs__BankAccountForReceiving__r.Name ' +
								',clofor_com_cfs__SellDetail__c ' +
								',clofor_com_cfs__PaymentTo__c ' +
								',clofor_com_cfs__PaymentTo__r.Name ' +
								',clofor_com_cfs__SiharaiKakuninzumi__c ' +
								',clofor_com_cfs__BuyInTaxAmountJPY__c ' +
								',clofor_com_cfs__Siharaigaku__c ' +
								',clofor_com_cfs__BuyDifferentiation__c ' +
								',clofor_com_cfs__BuyInTaxAmountUSD__c ' +
								',clofor_com_cfs__AMOUNT_PAID_BUYING_USD__c ' +
								',clofor_com_cfs__UNPAID_BALANCE_OF_BUYING_USD__c ' +
								',clofor_com_cfs__actual_payer__c ' +
								',clofor_com_cfs__actual_payer__r.Name ' +
								',toLabel(clofor_com_cfs__payment_category__c) ' +								
								',clofor_com_cfs__PaymentDate__c ' +
								',clofor_com_cfs__BankAccountForPayment__c ' +
								',clofor_com_cfs__BankAccountForPayment__r.Name ' +
								',clofor_com_cfs__BuyDetail__c ' +
								',clofor_com_cfs__curr__c ' +
								',clofor_com_cfs__CurrencyBuying__c ' +	
								',clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c ' +	
								',clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c ' +
							'FROM clofor_com_cfs__AnkenMeisai__c ';
			soqlQuery += 'WHERE (clofor_com_cfs__SellDifferentiation__c > 0 ';
			soqlQuery += 'OR clofor_com_cfs__UNPAID_BALANCE_OF_SELLING_USD__c > 0) ';
			soqlQuery += 'AND clofor_com_cfs__SellInTaxAmountJPY__c >=: amount ';
			soqlQuery += 'AND clofor_com_cfs__SellDifferentiation__c >=: unpaid ';


		if (!orderNoList.isEmpty()) {			
			soqlQuery += 'AND clofor_com_cfs__Anken__r.clofor_com_cfs__ID__c LIKE: orderNoList';
		}

		List<clofor_com_cfs__AnkenMeisai__c> ankenMeisaiList = Database.query(soqlQuery);
		if (ankenMeisaiList == null) {
			ankenMeisaiList = new List<clofor_com_cfs__AnkenMeisai__c>();
		}

		return ankenMeisaiList;
	}


    public MassiveNewBankController(){
        objSearch = new ObjSearch();
        shipmentOrderSearch = new CustomObject1__c();
        billFMSSearch = new AnkenMeisai__c();
        strType = ApexPages.currentPage().getParameters().get('type');
        strId = ApexPages.currentPage().getParameters().get('id');
        strTypeFMS = getRecordTypeNameOfBank();
        if(strType == 'FMS'){
            objSearch.currencyType = 'Both';
            objSearch.amountType = 'Both';
            listBillFMSResult = new List<AnkenMeisai__c>();
            strHeader = 'FMS/TMS BILL+BANK'; 
            getBillFMSConnected();
            listBillFMSResult = showDataOfFMS();
            listBillFMSString = JSON.serialize(listBillFMSResult);
        }
        if(strType == 'WMS'){
            strHeader = 'WMS BILL+BANK';
            wrapperWMS = showDataOfWMS();
        }
        
    }
    
    public void doClear(){
        objSearch = new ObjSearch();
        shipmentOrderSearch = new CustomObject1__c();
        billFMSSearch = new AnkenMeisai__c();
        objSearch.currencyType = 'Both';
        objSearch.amountType = 'Both';
    }
    
    public void doCheckAll(){
        // if(strType == 'FMS'){
        //     if(wrapperFMS.isCheckFMSAll){
        //         for(FMS item : wrapperFMS.lstFMS){
        //             item.isCheckFMS = true;
        //         }
        //     }
        //     else{
        //         for(FMS item : wrapperFMS.lstFMS){
        //             item.isCheckFMS = false;
        //         }
        //     }
        // }
        if(strType == 'WMS'){
            if(wrapperWMS.isCheckWMSAll){
                for(WMS item : wrapperWMS.lstWMS){
                    item.isCheckWMS = true;
                }
            }
            else{
                for(WMS item : wrapperWMS.lstWMS){
                    item.isCheckWMS = false;
                }
            }
        }
    }
    
    public void doSearch(){
        if(strType == 'FMS'){
            listBillFMSResult = new List<AnkenMeisai__c>();
            strHeader = 'FMS/TMS BILL+BANK';
            getBillFMSConnected();
            listBillFMSResult = showDataOfFMS();
            listBillFMSString = JSON.serialize(listBillFMSResult);
        }
        if(strType == 'WMS'){
            strHeader = 'WMS BILL+BANK';
            wrapperWMS = showDataOfWMS();
        }
    }
    
    public void doInsertFMS(){
        
		try{
            String strIdBills = ApexPages.currentPage().getParameters().get('listBillIds');
            List<String> listBillIds = strIdBills.split(',');
            List<CloFMSBillBank__c> listNewBillBank = new List<CloFMSBillBank__c>();
            for(String billId : listBillIds){
                CloFMSBillBank__c newBillBank = new CloFMSBillBank__c(
                    CloFMSBillID__c = billId, 
                    BankTransactionID__c = strId
                );
                listNewBillBank.add(newBillBank);
            }
			FlsService.doInsert(listNewBillBank);
			doSearch();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm, 'Success!'));
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
		}
    }
    public PageReference doInsert(){
        if(strType == 'WMS'){
            List<CloWMSBillBank__c> lstWMSInsert = new List<CloWMSBillBank__c>();
            CloWMSBillBank__c wmsBill = new CloWMSBillBank__c();
            for(WMS item : wrapperWMS.lstWMS){
                if(item.isCheckWMS){
                    wmsBill = new CloWMSBillBank__c();
                    wmsBill.CloWMSBillID__c = item.bill.Id;
                    wmsBill.BankTransactionID__c = strId;
                    lstWMSInsert.add(wmsBill);
                }
            }
            if(!lstWMSInsert.isEmpty()){
                FlsService.doInsert(lstWMSInsert);
            }
        }
        PageReference pageRef = new PageReference('/' + strId);
        pageRef.setRedirect(true);
		return pageRef;
    }
    
    private String getRecordTypeNameOfBank(){
        List<BankTransaction__c> lstBank = new List<BankTransaction__c>();
        lstBank = [SELECT Id, RecordType.Name FROM BankTransaction__c WHERE Id = :strId];
        if(!lstBank.isEmpty()){
            return lstBank.get(0).RecordType.Name;
        }
       	return '';
    }
    
    private void getBillFMSConnected(){
		List<CloFMSBillBank__c> listBillBank = [SELECT Id, CloFMSBillID__c FROM CloFMSBillBank__c WHERE BankTransactionID__c =: strId];
		for(CloFMSBillBank__c billBank : listBillBank){
			connectedFMSBills.add(billBank.CloFMSBillID__c);
		}
	}
    private List<AnkenMeisai__c> showDataOfFMS(){
        // FMSWrapper fmsWrapper = new FMSWrapper();
        List<AnkenMeisai__c> lstAnken = new List<AnkenMeisai__c>();
        List<CloFMSBillBank__c> lstFMS = new List<CloFMSBillBank__c>();
        String strSQL = buildQueryStrFMS();
        lstAnken = Database.query(strSQL);
        
        return lstAnken;
    }

    private String buildQueryStrFMS(){
		String queryStr = 'SELECT ' + String.join(new List<String>(fieldsQuery), ',') + ' FROM AnkenMeisai__c ';
		String conditionStr = '';
		if(!connectedFMSBills.isEmpty()){
			conditionStr += ' AND Id NOT IN: connectedFMSBills';
		}
		if(!String.isBlank(objSearch.ShipmentOrderId)){
            conditionStr += ' AND Anken__r.Name like \'%' + String.escapeSingleQuotes(objSearch.ShipmentOrderId) + '%\'';
        }
        // REF.NO/job ID
        if(!String.isBlank(shipmentOrderSearch.REFNO__c)){
            conditionStr += ' AND ( Anken__r.REFNO__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.REFNO__c) + '\'';
            conditionStr += ' OR Anken__r.JobRequestID__c =\'' + String.escapeSingleQuotes(shipmentOrderSearch.REFNO__c) + '\') ';
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
        if(!String.isBlank(billFMSSearch.PaymentTo__c)){
            conditionStr += ' AND PaymentTo__c = \'' + String.escapeSingleQuotes(billFMSSearch.PaymentTo__c) + '\'';
        }
        // INVOICE TO
        if(!String.isBlank(billFMSSearch.Seikyusaki__c)){
            conditionStr += ' AND Seikyusaki__c = \'' + String.escapeSingleQuotes(billFMSSearch.Seikyusaki__c) + '\'';
        }
        if(!String.isBlank(billFMSSearch.InboundVATInvNo__c)){
            conditionStr += ' AND InboundVATInvNo__c LIKE \'%' + String.escapeSingleQuotes(billFMSSearch.InboundVATInvNo__c) + '%\'';
        }
         if(!String.isBlank(billFMSSearch.OutboundVATInvNo__c)){
            conditionStr += ' AND OutboundVATInvNo__c LIKE \'%' + String.escapeSingleQuotes(billFMSSearch.OutboundVATInvNo__c) + '%\'';
        }
        if(objSearch.amountType == 'BUYING'){
            conditionStr += ' AND PaymentTo__c != null';
        }
        if(objSearch.amountType == 'SELLING'){
            conditionStr += ' AND Seikyusaki__c != null';
        }

		if(!String.isBlank(conditionStr)){
			conditionStr = conditionStr.replaceFirst('AND', 'WHERE');
			queryStr += conditionStr;
		}
		queryStr += ' LIMIT 500';
		return queryStr;
	}
    
    private WMSWrapper showDataOfWMS(){
        List<Billing__c> lstBill = new List<Billing__c>();
        WMSWrapper wmsWrapper = new WMSWrapper();
        List<CloWMSBillBank__c> lstWMS = new List<CloWMSBillBank__c>();
        lstWMS = [SELECT Id, CloWMSBillID__c FROM CloWMSBillBank__c WHERE BankTransactionID__c =: strId];
        String strWMSId = '';
        for(CloWMSBillBank__c wms : lstWMS){
            strWMSId += '\'' + wms.CloWMSBillID__c + '\',';
        }
        if(!String.isBlank(strWMSId)){
            strWMSId = strWMSId.removeEnd(',');
        }
        String strSQL = '';
        strSQL = ' SELECT Id, Name, WorkOrderID__r.Name, PaymentTo__r.Name, AmountSellingIncludeTAXLocal__c,'
            	+ ' AmountReceivedFromCustomerLocal__c, UnreceivedBalanceLocal__c, AmountBuyingIncludeTAXUSDCur__c,'
            	+ ' AmountPaidBuyingUSD__c, UnpaidBalanceOfBuyingUSD__c, InvoiceTo__r.Name, AmountSellingIncludeTAXUSDCur__c,'
            	+ ' AmountReceivedFromCustomerUSD__c, UnreceivedBalanceUSD__c, AmountBuyingIncludeTAXLocal__c,'
            	+ ' AmountPaidBuyingLocal__c, UnpaidBalanceOfBuyingLocal__c '
            	+ ' FROM Billing__c ';
        String strWhere = '';
        if(!String.isBlank(strWMSId)){
            strWhere += ' Id NOT IN (' + strWMSId + ') AND';
        }
        if(!String.isBlank(objSearch.WorkOrderId)){
            strWhere += ' WorkOrderID__r.Name like \'%' + String.escapeSingleQuotes(objSearch.WorkOrderId) + '%\' AND';
        }
        if(!String.isBlank(objSearch.WMSBillId)){
            strWhere += ' Name like \'%' + String.escapeSingleQuotes(objSearch.WMSBillId) + '%\' AND';
        }
        if(!String.isBlank(objSearch.PaymentTo)){
            strWhere += ' PaymentTo__r.Name like \'%' + String.escapeSingleQuotes(objSearch.PaymentTo) + '%\' AND';
        }
        if(!String.isBlank(objSearch.InvoiceTo)){
            strWhere += ' InvoiceTo__r.Name like \'%' + String.escapeSingleQuotes(objSearch.InvoiceTo) + '%\' AND';
        }
        if(!String.isBlank(strWhere)){
            strWhere = ' WHERE ' + strWhere.removeEnd('AND');
        }
        
        strSQL += strWhere + ' ORDER BY Name, WorkOrderID__r.Name LIMIT 1000';
        lstBill = Database.query(strSQL);
        if(!lstBill.isEmpty()){
            WMS objWMS = new WMS();
            for(Billing__c bill : lstBill){
                objWMS = new WMS();
                objWMS.bill = bill;
                wmsWrapper.lstWMS.add(objWMS);
            }
        }
        return wmsWrapper;
    }
    
    public class ObjSearch{
        public String ShipmentOrderId {get; set;}
        public String FMSBillId {get; set;}
        public String WMSBillId {get; set;}
        public String WorkOrderId {get; set;}
        public String InvoiceTo {get; set;}
        public String PaymentTo {get; set;}
        public String sCustomer {get; set;}
        public String sTimeType {get; set;}
        public String currencyType{get; set;}
        public String amountType{get; set;}
        public String sFromTime {get; set;}
        public String sToTime {get; set;}
        public ObjSearch(){
            this.ShipmentOrderId = '';
            this.FMSBillId = '';
            this.WMSBillId = '';
            this.WorkOrderId = '';
            this.InvoiceTo = '';
            this.PaymentTo = '';
            this.sTimeType = 'Accounted Date';
            this.sFromTime = '';
            this.sToTime = '';
        }
    }
    
    public class WMS{
        public Boolean isCheckWMS {get; set;}
        public Billing__c bill {get; set;}
        public WMS(){
            this.isCheckWMS = false;
            this.bill = new Billing__c();
        }
    }
    
    public class WMSWrapper{
        public Boolean isCheckWMSAll {get; set;}
        public List<WMS> lstWMS {get; set;}
        public WMSWrapper(){
            this.isCheckWMSAll = false;
            this.lstWMS = new List<WMS>();
        }
    }
    
    public class FMS{
        public Boolean isCheckFMS {get; set;}
        public AnkenMeisai__c anken {get; set;}
        public FMS(){
            this.isCheckFMS = false;
            this.anken = new AnkenMeisai__c();
        }
    }
    
    public class FMSWrapper{
        public Boolean isCheckFMSAll {get; set;}
        public List<FMS> lstFMS {get; set;}
        public FMSWrapper(){
            this.isCheckFMSAll = false;
            this.lstFMS = new List<FMS>();
        }
    }
}