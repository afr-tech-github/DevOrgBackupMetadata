public with sharing class MassiveNewCashController {
	public ObjSearch objSearch {get; set;}
    public CustomObject1__c shipmentOrderSearch{get; set;}
    public AnkenMeisai__c billFMSSearch{get; set;}
    public List<AnkenMeisai__c> listBillFMSResult{get; set;}
    public String strHeader {get; set;}
    public String strType {get; set;}
    private String strId {get; set;}
    public String strTypeCash {get; set;}
    public FMSWrapper wrapperFMS {get; set;}
    public WMSWrapper wrapperWMS {get; set;}
    private static Set<Id> connectedFMSBills = new Set<Id>();
    private static Set<String> fieldsQuery = new Set<String>();
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
    public MassiveNewCashController(){
        objSearch = new ObjSearch();
        shipmentOrderSearch = new CustomObject1__c();
        billFMSSearch = new AnkenMeisai__c();
        strType = ApexPages.currentPage().getParameters().get('type');
        strId = ApexPages.currentPage().getParameters().get('id');
        strTypeCash = getRecordTypeNameOfCash();
        if(strType == 'FMS'){
            objSearch.currencyType = 'Both';
            objSearch.amountType = 'Both';
            listBillFMSResult = new List<AnkenMeisai__c>();
            strHeader = 'FMS/TMS BILL+CASH'; 
            getBillFMSConnected();
            listBillFMSResult = showDataOfFMS();
        }
        if(strType == 'WMS'){
            strHeader = 'WMS BILL+CASH';
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

    public void doInsertFMS(){
        
		try{
            String strIdBills = ApexPages.currentPage().getParameters().get('listBillIds');
            List<String> listBillIds = strIdBills.split(',');
            List<ConnectInvoicingAndCash__c> listNewBillCash = new List<ConnectInvoicingAndCash__c>();
            for(String billId : listBillIds){
                ConnectInvoicingAndCash__c newBillCash = new ConnectInvoicingAndCash__c(
                    Invoicing__c = billId, 
                    Cashbook__c = strId
                );
                listNewBillCash.add(newBillCash);
            }
			FlsService.doInsert(listNewBillCash);
			doSearch();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm, 'Success!'));
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
		}
    }
    
    public void doSearch(){
        if(strType == 'FMS'){
            strHeader = 'FMS/TMS BILL+CASH'; 
            getBillFMSConnected();
            listBillFMSResult = showDataOfFMS();
        }
        if(strType == 'WMS'){
            strHeader = 'WMS BILL+CASH';
            wrapperWMS = showDataOfWMS();
        }
    }
    
    public PageReference doInsert(){
        if(strType == 'WMS'){
            List<ConnectBillingCAsh__c> lstWMSInsert = new List<ConnectBillingCAsh__c>();
            ConnectBillingCAsh__c wmsBill = new ConnectBillingCAsh__c();
            for(WMS item : wrapperWMS.lstWMS){
                if(item.isCheckWMS){
                    wmsBill = new ConnectBillingCAsh__c();
                    wmsBill.BillingID__c = item.bill.Id;
                    wmsBill.CashID__c = strId;
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
    
    private String getRecordTypeNameOfCash(){
        List<CASH_BOOK__c> lstCash = new List<CASH_BOOK__c>();
        lstCash = [SELECT Id, RecordType.Name FROM CASH_BOOK__c WHERE Id = :strId];
        if(!lstCash.isEmpty()){
            return lstCash.get(0).RecordType.Name;
        }
       	return '';
    }

    private void getBillFMSConnected(){
		List<ConnectInvoicingAndCash__c> listBillCash = [SELECT Id, Invoicing__c FROM ConnectInvoicingAndCash__c WHERE Cashbook__c =: strId];
		for(ConnectInvoicingAndCash__c billCash : listBillCash){
			connectedFMSBills.add(billCash.Invoicing__c);
		}
	}
    private List<AnkenMeisai__c> showDataOfFMS(){
        // FMSWrapper fmsWrapper = new FMSWrapper();
        List<AnkenMeisai__c> lstAnken = new List<AnkenMeisai__c>();
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
        List<ConnectBillingCAsh__c> lstWMS = new List<ConnectBillingCAsh__c>();
        lstWMS = [SELECT Id, BillingID__c FROM ConnectBillingCAsh__c WHERE CashID__c =: strId];
        String strWMSId = '';
        for(ConnectBillingCAsh__c wms : lstWMS){
            strWMSId += '\'' + wms.BillingID__c + '\',';
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
            strWhere += ' Id NOT IN (' + String.escapeSingleQuotes(strWMSId) + ') AND';
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
                
                if(strTypeCash == 'CASH OUT' && bill.UnpaidBalanceOfBuyingLocal__c != 0 
                  && bill.UnpaidBalanceOfBuyingLocal__c != null){
                    wmsWrapper.lstWMS.add(objWMS);
                }
                if(strTypeCash == 'CASH IN' && bill.UnreceivedBalanceLocal__c != 0 
                  && bill.UnreceivedBalanceLocal__c != null){
                    wmsWrapper.lstWMS.add(objWMS);
                }
                if(strTypeCash == 'Outbound Transaction-USD Currency' && bill.UnpaidBalanceOfBuyingUSD__c != 0 
                  && bill.UnpaidBalanceOfBuyingUSD__c != null){
                    wmsWrapper.lstWMS.add(objWMS);
                }
                if(strTypeCash == 'Inbound Transaction-USD Currency' && bill.UnreceivedBalanceUSD__c != 0 
                  && bill.UnreceivedBalanceUSD__c != null){
                    wmsWrapper.lstWMS.add(objWMS);
                }
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