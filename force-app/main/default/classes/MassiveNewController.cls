public with sharing class MassiveNewController {
    
    public ObjSearch objSearch {get; set;}
    public CustomObject1__c soSearch{get;set;}
    public AnkenMeisai__c billSearch{get;set;}
    public List<ShipmentItem> lstItem {get; set;}
    public String strRT {get; set;}
    private List<AnkenMeisai__c> lstAnken {get; set;}
    private Map<String, AnkenMeisai__c> mapShipment {get; set;}
    private Map<String, List<BillItem>> mapAnken {get; set;}
    private Id prmId {get; set;}
    private VAT_INVOICE__c objVatInvoice {get; set;}
    public String strRTVAT {get; set;}
    public Boolean isCheckAll {get; set;}
    private Set<Id> connectedBillSet{get;set;}
    private Set<String> ankenRecTypeSet{get;set;}
    private Set<String> ankenStatusSet{get;set;}
    public MassiveNewController(){
        isCheckAll = false;
        prmId = ApexPages.currentPage().getParameters().get('id');
        strRTVAT = getRecordTypeNameOfVAT();
        objVatInvoice = getVatInvoice(prmId);
        objSearch = new ObjSearch();
        soSearch = new CustomObject1__c();
        billSearch = new AnkenMeisai__c();
        showData();
    }
    
    public void checkAll(){
        if(isCheckAll && !lstItem.isEmpty()){
            for(ShipmentItem ship : lstItem){
                ship.isCheck = true;
            }
        }
        if(!isCheckAll && !lstItem.isEmpty()){
            for(ShipmentItem ship : lstItem){
                ship.isCheck = false;
            }
        }
    }
    
    private String getRecordTypeNameOfVAT(){
        List<VAT_INVOICE__c> lstVAT = new List<VAT_INVOICE__c>();
        lstVAT = [SELECT Id, RecordType.DeveloperName FROM VAT_INVOICE__c WHERE Id = :prmId];
        if(!lstVAT.isEmpty()){
            return lstVAT.get(0).RecordType.DeveloperName;
        }
       	return '';
    }
    
    public void doSearch(){
        showData();
    }
    public Pagereference doClose(){
        PageReference page = new PageReference('/' + prmId);
        page.setRedirect(true);
        return page;
    }
    public void doClear(){
        objSearch = new ObjSearch();
        soSearch = new CustomObject1__c();
        billSearch = new AnkenMeisai__c();

    }
    
    public PageReference doInsert(){
        insertFORWARDINGVAT_AND_INVOICINGVAT();
        PageReference pageRef = new PageReference('/' + prmId);
        pageRef.setRedirect(true);
		return pageRef;
    }
    
    private void insertFORWARDINGVAT_AND_INVOICINGVAT(){
        List<INVOICING_VAT__c> lstInvoicingVat = new List<INVOICING_VAT__c>();
        List<FORWARDING_VAT__c> lstForwardingVat = new List<FORWARDING_VAT__c>();
        Set<Id> setAnkenOfForwarding = new Set<Id>();
        Set<Id> setAnkenOfInvoicing = new Set<Id>();
        for(ShipmentItem ship : lstItem){
            if(ship.isCheck){
                FORWARDING_VAT__c forwarding = new FORWARDING_VAT__c();
                forwarding.FORWARDING__c = ship.objShipment.Anken__c;
                forwarding.VAT_INVOICE__c = prmId;
                
                setAnkenOfForwarding.add(ship.objShipment.Anken__c);
                lstForwardingVat.add(forwarding);
                
                for(BillItem bill : ship.lstBill){
                    if(bill.isBillCheck){
                        INVOICING_VAT__c invoicing = new INVOICING_VAT__c();
                        invoicing.INVOICING__c = bill.objAnken.Id;
                        invoicing.VAT_INVOICE__c = prmId;
                        
                        setAnkenOfInvoicing.add(bill.objAnken.Id);
                        lstInvoicingVat.add(invoicing);
                    }
                }
            }
        }
        
        List<FORWARDING_VAT__c> lstForwarding = new List<FORWARDING_VAT__c>();
        lstForwarding = [ SELECT Id, FORWARDING__c, VAT_INVOICE__c 
                         FROM FORWARDING_VAT__c 
                         WHERE FORWARDING__c = :setAnkenOfForwarding 
                         		AND VAT_INVOICE__c = :Id.valueOf(prmId) LIMIT 1000];
        Set<String> setKeyForwarding = new Set<String>();
        for(FORWARDING_VAT__c ward : lstForwarding){
            setKeyForwarding.add(ward.FORWARDING__c + ':' + ward.VAT_INVOICE__c);
        }
        List<FORWARDING_VAT__c> lstInsertForwarding = new List<FORWARDING_VAT__c>();
        for(FORWARDING_VAT__c item : lstForwardingVat){
            if(!setKeyForwarding.contains(item.FORWARDING__c + ':' + item.VAT_INVOICE__c)){
                lstInsertForwarding.add(item);
            }
        }
        
        if(!lstForwardingVat.isEmpty()){
            FlsService.doInsert(lstInsertForwarding);
        }
        
        if(!lstInvoicingVat.isEmpty()){
            FlsService.doInsert(lstInvoicingVat);
        }
    }
    
    public void checkAllBill(){
        Integer intCount = Integer.valueOf(ApexPages.currentPage().getParameters().get('indexList'));
        if(lstItem[intCount].isCheckAllBill){
            for(BillItem bill : lstItem[intCount].lstBill){
                bill.isBillCheck = true;
            }
        }
        else{
            for(BillItem bill : lstItem[intCount].lstBill){
                bill.isBillCheck = false;
            }
        }
    }
    
    private void showData(){
        mapShipment = new Map<String, AnkenMeisai__c>();
        mapAnken = new Map<String, List<BillItem>>();
        lstAnken = new List<AnkenMeisai__c>();
        lstItem = new List<ShipmentItem>();
        //ItemWrapper item = new ItemWrapper();
        String strStatus = '';
        
        
        lstAnken = Database.query(generateSOQL());
        for(AnkenMeisai__c obj : lstAnken){
            //if(obj.PaymentTo__c == obj.Tariff__r.Supplier__c || obj.Seikyusaki__c == obj.Tariff__r.CUSTOMER__c){
                
                strStatus = obj.Anken__r.status__c;
                if(!String.isBlank(strStatus)){
                    obj.Anken__r.status__c = strStatus.substringAfter('(').removeEnd(')');
                }
                
                if(!mapShipment.containsKey(obj.Anken__r.Name)){
                    mapShipment.put(obj.Anken__r.Name, obj);
                }
                if(!mapAnken.containsKey(obj.Anken__r.Name)){
                    mapAnken.put(obj.Anken__r.Name, new List<BillItem>());
                }
                // if(objVatInvoice.Number_of_Invoicing__c == null || objVatInvoice.Number_of_Invoicing__c == 0 
                //    || (objVatInvoice.Selling_Tax_Ratio__c == obj.TaxInitial__c)){
                  
                // }
                 mapAnken.get(obj.Anken__r.Name).add(new BillItem(obj));
                 
                
            //}
        }
        List<ShipmentItem> lstData = new List<ShipmentItem>();
        if(mapShipment.size() > 0){
            for(String key: mapShipment.keySet()){
                ShipmentItem item;
                if(mapAnken.containsKey(key)){
                    item = new ShipmentItem(mapShipment.get(key), mapAnken.get(key));
                }
                else{
                    item = new ShipmentItem(mapShipment.get(key), new List<BillItem>());
                }
                lstData.add(item);
                //lstItem.add(item);
            }
        }
        //lstItem = mapAnken.values();
        Integer index = 0;
        for(ShipmentItem ship: lstData){
            if(!ship.lstBill.isEmpty()){
                lstItem.add(lstData.get(index));
            }
            index++;
        }
    }
    
    private void  getRecordType(){
        // String strRT = '';
        // Set<String> setRTName = new Set<String>();
        // setRTName.add('Air Import');
        // setRTName.add('Air Export');
        // setRTName.add('Ocean Export');
        // setRTName.add('Ocean Import');
        // setRTName.add('Domestic Transportation');
        // setRTName.add('Cross-Boarder');
        
        // String objectName = Constants.NAMESPACE + 'CustomObject1__c';
        // List<RecordType> recordTypes = [ SELECT Id, DeveloperName, Name
        //                                  FROM RecordType
        //                                  WHERE SObjectType = :objectName AND IsActive = True AND Name IN :setRTName
        //                             	];
        // for (RecordType rt : recordTypes) {
        //     strRT += '\'' + rt.Id + '\',';
        // }
        
        // return strRT.removeEnd(',');
        ankenRecTypeSet = new Set<String>();
        // Air Import
        ankenRecTypeSet.add('InAir');
        // Air Export
        ankenRecTypeSet.add('OutAir');
        // Ocean Export
        ankenRecTypeSet.add('RecordType');
        // Ocean Import
        ankenRecTypeSet.add('RecordType1');
        // Domestic Transportation
        ankenRecTypeSet.add('Domestic_Transportation');
        // Cross-Boarder
        ankenRecTypeSet.add('CrossBoarder');

    }
    
    private void getCargoStatus(){
        // String strStatus = '';
        // strStatus = '\'見積 受付済(Inquiry Received)\','
        //     		+ '\'見積 見積書作成中(Under Quotation)\','
        //             + '\'見積 見積書送付完了(Quotation Issued)\','
        //             + '\'見積 見積書修正中(Under Quotation Revision)\','
        //             + '\'見積 見積書再送付完了 (Quotation Reissued)\','
        //             + '\'キャンセル(Cancelled)\','
        //             + '\'完了(Completed)\'';
        // return strStatus;
        ankenStatusSet = new Set<String>();
        ankenStatusSet.add('見積 受付済(Inquiry Received)');
        ankenStatusSet.add('見積 見積書作成中(Under Quotation)');
        ankenStatusSet.add('見積 見積書送付完了(Quotation Issued)');
        ankenStatusSet.add('見積 見積書修正中(Under Quotation Revision)');
        ankenStatusSet.add('見積 見積書再送付完了 (Quotation Reissued)');
        ankenStatusSet.add('キャンセル(Cancelled)');
        ankenStatusSet.add('完了(Completed)');
    }
    
    private VAT_INVOICE__c getVatInvoice(String idVatVoice){
        List<VAT_INVOICE__c> lstVatVoice = new List<VAT_INVOICE__c>();
        lstVatVoice = [ SELECT Id, Number_of_Invoicing__c, Selling_Tax_Ratio__c 
                      	FROM VAT_INVOICE__c 
                      	WHERE Id = :idVatVoice 
                      	LIMIT 1 ];
        if(!lstVatVoice.isEmpty()){
            return lstVatVoice.get(0);
        }
        return new VAT_INVOICE__c();
    }
    
    private String generateSOQL(){
        String soql = '';
        String strWhere = '';
        String strDate = '';
        
        /*List<AggregateResult> lstFVat = new List<AggregateResult>();
        lstFVat = [ SELECT FORWARDING__c forward FROM FORWARDING_VAT__c GROUP BY FORWARDING__c LIMIT 1000];
        String strShipId = '';
        for(AggregateResult agg : lstFVat){
            strShipId += '\'' + agg.get('forward') + '\',';
        }*/
        
        /*List<AggregateResult> lstIVat = new List<AggregateResult>();
        lstIVat = [ SELECT INVOICING__c invoice FROM INVOICING_VAT__c GROUP BY INVOICING__c LIMIT 1000 ];
        String strAnkenId = '';
        for(AggregateResult arr : lstIVat){
            strAnkenId += '\'' + arr.get('invoice') + '\',';
        }
        */
        connectedBillSet = new Set<Id>();
        List<INVOICING_VAT__c> invoiceVAT = [SELECT INVOICING__c  FROM INVOICING_VAT__c WHERE VAT_INVOICE__c =: prmId];
        for(INVOICING_VAT__c inc : invoiceVAT){
            connectedBillSet.add(inc.INVOICING__c);
        }
        getRecordType();
        getCargoStatus();
        soql = 'SELECT Id, Name, SeikyuBangou__c, Seikyusaki__r.Name, InsatuyouSyohin__c, TaxInitial__c,'
            	+ '	SellTankaJPY__c, SellAmountJPN__c, SellTaxNum__c, BuyInTaxAmountJPY__c, SellInTaxAmountJPY__c,'
            	+ '	Anken__c, Anken__r.Id, Anken__r.Name, Anken__r.HBL__c , Anken__r.REFNO__c, Anken__r.MBL_Number_SEA_AIR__c,'
            	+ ' Anken__r.Account_Customer_Eng_name__c, Anken__r.SalesAccountedDate__c, '
            	+ ' BuyTankaJPY__c, BuyAmountJPN__c, BuyTaxNum__c, Anken__r.ID__c, '
                + '	Anken__r.status__c , Anken__r.shipper__c , Anken__r.shipper__r.Name , Anken__r.Cnee__c ,'
                + '	Anken__r.Cnee__r.Name , Anken__r.VESSEL_FLIGHT__c , Anken__r.ETD__c , Anken__r.ETA__c ,'
                + '	Anken__r.A_O_A_CODE__c , Anken__r.A_O_D_CODE__c, Anken__r.WkInitial__c,'
            	+ ' OutboundVATInvNo__c, InboundVATInvNo__c, BuyDifferentiation__c, SellDifferentiation__c, '
            	+ ' Suryo__c, BuyTaxInitial__c, Siharaigaku__c, Nyukingaku__c, InsatuyouSyohinEng__c,SellTankaUSD__c, SellAmountUSD__c,SellTaxNum_USD__c,SellInTaxAmount_USD__c,'
            	+ ' PaymentTo__c, Tariff__r.Supplier__c, Seikyusaki__c, Tariff__r.CUSTOMER__c, PaymentTo__r.Name, AMOUNT_PAID_SELLING_USD__c,UNPAID_BALANCE_OF_SELLING_USD__c, '
            	+ ' BuyTankaUSD__c, BuyAmountUSD__c, BuyTaxNum_USD__c, BuyInTaxAmountUSD__c, AMOUNT_PAID_BUYING_USD__c,UNPAID_BALANCE_OF_BUYING_USD__c ' 
            + '	FROM AnkenMeisai__c'
            + '	WHERE Anken__r.RecordType.DeveloperName IN: ankenRecTypeSet AND'
                + ' Anken__r.status__c NOT IN : ankenStatusSet AND'
            	+ '	Tariff__r.ProductFlag__c = true AND';
        if(!connectedBillSet.isEmpty()){
            strWhere += ' Id NOT IN: connectedBillSet AND';
        }
        
        // FMS/TMS S/O ID
        if(!String.isBlank(objSearch.sName)){
            strWhere += ' Anken__r.ID__c like \'%' + String.escapeSingleQuotes(objSearch.sName) + '%\' AND';
        }
        
        // REF.NO
        if(!String.isBlank(soSearch.REFNO__c)){
            strWhere += ' Anken__r.REFNO__c like \'%' + String.escapeSingleQuotes(soSearch.REFNO__c) + '%\' AND';
        }
 
        // CONSIGNEE
        if(!String.isBlank(soSearch.Cnee__c)){
            strWhere += ' Anken__r.Cnee__c = \'' + String.escapeSingleQuotes(soSearch.Cnee__c) + '\' AND';
            //strWhere += ' PaymentTo__r.Name like \'%' + objSearch.sCnee + '%\' OR';
            //strWhere += ' Seikyusaki__r.Name like \'%' + objSearch.sCnee + '%\') AND';
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
                strWhere += ' Anken__r.SalesAccountedDate__c >= ' + String.escapeSingleQuotes(strFrom) + ' AND';
            }
            if(objSearch.sTimeType == 'ETD'){
                strWhere += ' Anken__r.ETD__c >= ' + String.escapeSingleQuotes(strFrom) + ' AND';
            }
            if(objSearch.sTimeType == 'ETA'){
                strWhere += ' Anken__r.ETA__c >= ' + String.escapeSingleQuotes(strFrom) + ' AND';
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
                strWhere += ' Anken__r.SalesAccountedDate__c <= ' + String.escapeSingleQuotes(strTo) + ' AND';
            }
            if(objSearch.sTimeType == 'ETD'){
                strWhere += ' Anken__r.ETD__c <= ' + String.escapeSingleQuotes(strTo) + ' AND';
            }
            if(objSearch.sTimeType == 'ETA'){
                strWhere += ' Anken__r.ETA__c <= ' + String.escapeSingleQuotes(strTo) + ' AND';
            }
        }
        
        // H B/L NUMBER
        if(!String.isBlank(soSearch.HBL__c)){
            strWhere += ' Anken__r.HBL__c like \'%' + String.escapeSingleQuotes(soSearch.HBL__c) + '%\' AND';
        }
        
        // CUSTOMER
        if(!String.isBlank(soSearch.Account_Customer_Eng_name__c)){
            strWhere += ' Anken__r.Account_Customer_Eng_name__c like \'%' + String.escapeSingleQuotes(soSearch.Account_Customer_Eng_name__c) + '%\' AND';
        }
        
        // M B/L NUMBER
        if(!String.isBlank(soSearch.MBL_Number_SEA_AIR__c)){
            strWhere += ' Anken__r.MBL_Number_SEA_AIR__c like \'%' + String.escapeSingleQuotes(soSearch.MBL_Number_SEA_AIR__c) + '%\' AND';
        }
        
        // SHIPPER
        if(!String.isBlank(soSearch.shipper__c)){
            strWhere += ' Anken__r.shipper__c = \'' + String.escapeSingleQuotes(soSearch.shipper__c) + '\' AND';
        }
        
        // POL
        if(!String.isBlank(soSearch.A_O_D_CODE__c)){
            strWhere += ' Anken__r.A_O_D_CODE__c like \'%' + String.escapeSingleQuotes(soSearch.A_O_D_CODE__c) + '%\' AND';
        }

        // POD
        if(!String.isBlank(soSearch.A_O_A_CODE__c)){
            strWhere += ' Anken__r.A_O_A_CODE__c like \'%' + String.escapeSingleQuotes(soSearch.A_O_A_CODE__c) + '%\' AND';
        }
        
        // PAYMENT TO-BUYING
        if(!String.isBlank( billSearch.PaymentTo__c)){
            strWhere += ' PaymentTo__c = \'' + String.escapeSingleQuotes(billSearch.PaymentTo__c) + '\' AND';
        }
        
        // TAX RATE-BUYING
        if(!String.isBlank(objSearch.sBuyTaxInitial)){
            strWhere += ' BuyTaxInitial__c = ' + String.escapeSingleQuotes(objSearch.sBuyTaxInitial) + ' AND';
        }
        
        // INVOICE TO
        if(!String.isBlank(billSearch.Seikyusaki__c)){
            strWhere += ' Seikyusaki__c = \'' + String.escapeSingleQuotes(billSearch.Seikyusaki__c) + '\' AND';
        }
        
        // TAX RATE-SELLING
        if(!String.isBlank(objSearch.sTaxInitial)){
            strWhere += ' TaxInitial__c = ' + String.escapeSingleQuotes(objSearch.sTaxInitial) + ' AND';
        }
        
        if(!String.isBlank(strWhere)){
            soql += strWhere;
        }
        soql = soql.removeEnd('AND');
        soql += ' ORDER BY Anken__r.Name, Name LIMIT 500';
        return soql;
    }
   	
    public class ObjSearch{
        public String sName {get; set;}
        public String sRefNo {get; set;}
        public String sCnee {get; set;}
        public String sTimeType {get; set;}
        public String sHBL {get; set;}
        public String sCustomer {get; set;}
        public String sFromTime {get; set;}
        public String sToTime {get; set;}
        public String sMBL {get; set;}
        public String sShipper {get; set;}
        public String sPOL {get; set;}
        public String sPOD {get; set;}
        // Inbound
        public String sPayment {get; set;}
        public String sBuyTaxInitial {get; set;}
        // Outbound
        public String sSeikyusaki {get; set;}
        public String sTaxInitial {get; set;}
        public String curr {get;set;}
        public ObjSearch(){
            this.sName = '';
            this.sRefNo = '';
            this.sCnee = '';
            this.sTimeType = 'Accounted Date';
            this.sHBL = '';
            this.sCustomer = '';
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
            this.curr = 'local';
        }
    }
    public class BillItem{
        public Boolean isBillCheck {get; set;}
        public AnkenMeisai__c objAnken {get; set;}
        public BillItem(AnkenMeisai__c anken){
            this.isBillCheck = false;
            this.objAnken = anken;
        }
    }
    
    public class ShipmentItem{
        public Boolean isCheck {get; set;}
        public AnkenMeisai__c objShipment {get; set;}
        public Boolean isCheckAllBill {get; set;}
        public List<BillItem> lstBill {get; set;}
        public ShipmentItem(AnkenMeisai__c objCObject1, List<BillItem> lstAnken){
            this.isCheck = false;
            this.isCheckAllBill = false;
            this.objShipment = objCObject1;
            this.lstBill = lstAnken;
        }
    }
}