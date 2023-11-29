public with sharing class OutStandingStatementDetailController {
    public transient String partnerName {get;set;}
    public transient String partnerEnglishName {get;set;}
    public transient String businessRelationship {get;set;}
    public transient Decimal totalDebit {get;set;}
    public transient Decimal totalCredit {get;set;}
    public transient Decimal totalBalance {get;set;}
    public transient Decimal totalDebitLocal {get;set;}
    public transient Decimal totalCreditLocal {get;set;}
    public transient Decimal totalBalanceLocal {get;set;}
    public transient String currentDate {get;set;}
    public transient String reportDate {get;set;}
    public transient String period {get;set;}
    public transient Decimal recordQuantity {get;set;}
    public transient String currencyType {get; set;}
    public transient String searchType {get; set;}
    public transient Map<String, ReportLocal> mapLocal {get; set;}
    public transient String strWkid {get; set;}
    public List<AnkenDetail> lstAKMDetail {get; set;}
    
    Map<String,ReportDetailWrapper> mapTemp {get;set;}
    
    public transient List<ReportDetailWrapper> lstSTID {
        get {
            List<ReportDetailWrapper> lstMySTIDs = new List<ReportDetailWrapper>();
            Decimal i = 1;
            if (!mapTemp.isEmpty()) {
                for (ReportDetailWrapper item : mapTemp.values()) {
                    recordQuantity += item.myQuantity;
                    item.index = i;
					lstMySTIDs.add(item);                    
                    i++;
                }    
            }
            
            return lstMySTIDs;
        }
        set;
    }
    
    public OutStandingStatementDetailController() {
        totalDebit = 0;
        totalCredit = 0;
        totalBalance = 0;
        totalDebitLocal = 0;
        totalCreditLocal = 0;
        totalBalanceLocal = 0;
        recordQuantity = 0;
        lstAKMDetail = new List<AnkenDetail>();
        Boolean isDisplayDetail = false;
        
        mapLocal = new Map<String, ReportLocal>();
        
        reportDate = String.valueOf(System.today());
        
        currentDate = String.valueOf(Date.today());
        String fromDate = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fromDate'));
        String toDate = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('toDate'));
        partnerName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('partnerName'), 'UTF-8'));
        partnerEnglishName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('partnerENName'), 'UTF-8'));
        businessRelationship = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('relationship'), 'UTF-8'));
		currencyType = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('currency'), 'UTF-8'));
        searchType = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('searchType'), 'UTF-8'));
        strWkid = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('strWkid'), 'UTF-8'));
        List<String> lstWkid = new List<String>();
        lstWkid = strWkid.split(',');
        String strId = '';
        for(String idAnken : lstWkid){
            strId += '\'' + idAnken + '\', ';
        }
        strId = strId.removeEnd(', ');
        String soqlComm = 'SELECT Id, Name, PartnerSeisan__c, Anken__r.partnerSeisanTani__c, Anken__r.ETA__c, ' +
            '   Anken__r.Name, Anken__r.HBL_Number_Sea_Air__c, Anken__r.MBL_Number_Sea_Air__c, Anken__r.ETD__c, ' +
            '   PartnerDebit__c, PartnerCredit__c, PartnerSeisanUSD__c, PaymentTo__r.Business_Relationship__c, ' +  
            '   PaymentTo__r.Name, Seikyusaki__r.Business_Relationship__c, Seikyusaki__r.Name, ' +
            '	InsatuyouSyohin__c, Description__c , Suryo__c, ' +
            '   BuyDifferentiation__c, SellDifferentiation__c, SalesAccountedDate__c, SalesAccountedDateInvoicing__c, ' +
            '   UNPAID_BALANCE_OF_BUYING_USD__c, UNPAID_BALANCE_OF_SELLING_USD__c, SiharaiKakuninzumi__c, NyukinKakuninzumi__c' +
            ' FROM AnkenMeisai__c ' +
            ' WHERE Anken__r.RecordType.DeveloperName != \'Quotation\'' + 
            //' AND Id IN (' + strId + ') ' +
            '   AND ((PaymentTo__r.Business_Relationship__c = \'' + businessRelationship + '\'' +
            '           AND PaymentTo__r.Name = \'' + partnerName + '\'' +
            '           AND SiharaiKakuninzumi__c = false AND (UNPAID_BALANCE_OF_BUYING_USD__c != 0 OR BuyDifferentiation__c != 0))' +
            '       OR (Seikyusaki__r.Business_Relationship__c = \'' + businessRelationship + '\'' +
            '           AND Seikyusaki__r.Name = \'' + partnerName + '\'' +
            '           AND NyukinKakuninzumi__c = false AND (UNPAID_BALANCE_OF_SELLING_USD__c != 0 OR SellDifferentiation__c != 0)))' +
            '   AND Anken__r.status__c NOT IN (\'' + PicklistReference.CANCELLED_ST + '\',' + 
            '       \'' + PicklistReference.COMPLETED_ST + '\',' +
            '       \'' + PicklistReference.TEMPORARY_UNLOCK_FOR_ACCOUNTING_PURPOSE_ST + '\')';

        String filter = '';
        if (fromDate != null && toDate != null) {
            //filter = ' AND (Anken__r.ETD__c >= ' + fromDate + ' AND Anken__r.ETD__c <= ' + toDate + ')';
            if(searchType.equals('ETD')){
                filter = ' AND (Anken__r.ETD__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate) + ')';
            }
            else if(searchType.equals('ETA')){
                filter = ' AND (Anken__r.ETA__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate) + ')';
            }
            else if(searchType.equals('SHIPMENTORDER')){
                filter = ' AND (Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate) + ')';
            }
            else if(searchType.equals('INVOICING')){
                filter = ' AND (SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate) + ')';
            }
            
            period = 'From ' + fromDate + ' To ' + toDate;
        }        
        else if (fromDate != null && toDate == null) {
            //filter = ' AND Anken__r.ETD__c >= ' + fromDate;
            if(searchType.equals('ETD')){
                filter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
            }
            else if(searchType.equals('ETA')){
                filter = ' AND Anken__r.ETA__c >= ' + String.valueOf(fromDate);
            }
            else if(searchType.equals('SHIPMENTORDER')){
                filter = ' AND Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate);
            }
            else if(searchType.equals('INVOICING')){
                filter = ' AND SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate);
            }
            period = 'From ' + fromDate;
        }
        else if (fromDate == null && toDate != null) {
            //filter = ' AND Anken__r.ETD__c <= ' + toDate;
            if(searchType.equals('ETD')){
                filter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
            }
            else if(searchType.equals('ETA')){
                filter = ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate);
            }
            else if(searchType.equals('SHIPMENTORDER')){
                filter = ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate);
            }
            else if(searchType.equals('INVOICING')){
                filter = ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate);
            }
            period = 'To ' + toDate;
        }
        
        if(!String.isBlank(strWkid)){
            filter +=' AND Id IN (' + strId + ') ';
            isDisplayDetail = true;
        }
        
        if (filter != '') {
            soqlComm += filter;
        }
        soqlComm += ' ORDER BY PartnerSeisan__c, Anken__r.Name ';

        List<AnkenMeisai__c> lstAKM = new List<AnkenMeisai__c>();
        
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()) {
            lstAKM = Database.query(soqlComm);
            lstSTID = new List<ReportDetailWrapper>();
            mapTemp = new Map<String,ReportDetailWrapper>();

            for (AnkenMeisai__c item : lstAKM) {
                String strSTID = item.Anken__r.partnerSeisanTani__c;
                Decimal debit = 0;
                Decimal credit = 0;
                Decimal balance = 0;
                Decimal debitLocal = 0;
                Decimal creditLocal = 0;
                Decimal balanceLocal = 0;
                String wkid = item.Anken__r.Name;
                String hbl = item.Anken__r.HBL_Number_Sea_Air__c;
                String mbl = item.Anken__r.MBL_Number_Sea_Air__c;
                String strEtd = String.valueof(item.Anken__r.ETD__c);
                String strEta = String.valueof(item.Anken__r.ETA__c);
                
                if(!String.isEmpty(strEtd)){
                    Date etd = item.Anken__r.ETD__c;
                    strEtd = etd.day() + '/' + etd.month() + '/' + etd.year();
                }
                if(!String.isEmpty(strEta)){
                    Date eta = item.Anken__r.ETA__c;
                    strEta = eta.day() + '/' + eta.month() + '/' + eta.year();
                }

                if (businessRelationship.equals(item.Seikyusaki__r.Business_Relationship__c)
                        && item.NyukinKakuninzumi__c == false 
                        && (item.UNPAID_BALANCE_OF_SELLING_USD__c != 0 || item.SellDifferentiation__c != 0)
                        && item.Seikyusaki__r.Name.equals(partnerName)) {
                    debit = item.UNPAID_BALANCE_OF_SELLING_USD__c;
                    debitLocal = item.SellDifferentiation__c;
                }
                    
                else if (businessRelationship.equals(item.PaymentTo__r.Business_Relationship__c)
                        && item.SiharaiKakuninzumi__c == false 
                        && (item.UNPAID_BALANCE_OF_BUYING_USD__c != 0 || item.BuyDifferentiation__c != 0)
                        && item.PaymentTo__r.Name.equals(partnerName)) {
                    credit = item.UNPAID_BALANCE_OF_BUYING_USD__c;
                    creditLocal = item.BuyDifferentiation__c;
                }
                
                balance = debit - credit;
                balanceLocal = debitLocal - creditLocal;
                
                if (mapTemp.isEmpty()) {
                    ReportDetailWrapper temp = new ReportDetailWrapper();
                    setSTIDData(temp, strSTID, debit, credit, balance, wkid, hbl, mbl, strEta, strEtd);
                    temp.myQuantity = 1;
                    mapTemp.put(temp.stid,temp);
                }
                else if (mapTemp.containsKey(strSTID)) {
                    mapTemp.get(strSTID).debit += debit;
                    mapTemp.get(strSTID).credit += credit;
                    mapTemp.get(strSTID).balance += balance;
                    mapTemp.get(strSTID).myQuantity += 1;
                }
                else {
                    ReportDetailWrapper temp = new ReportDetailWrapper();
                    setSTIDData(temp, strSTID, debit, credit, balance, wkid, hbl, mbl, strEta, strEtd);
                    temp.myQuantity = 1;
                    mapTemp.put(temp.stid,temp);
                }
                
                if(!mapLocal.containsKey(wkid)){
                    mapLocal.put(wkid, new ReportLocal());
                }
                
                String strSaleDate = String.valueOf(item.SalesAccountedDate__c);
                if(!String.isEmpty(strSaleDate)){
                    Date saleDate = item.SalesAccountedDate__c;
                    strSaleDate = saleDate.day() + '/' + saleDate.month() + '/' + saleDate.year();
                    mapLocal.get(wkid).salesAccountedDate = strSaleDate;
                }
                
                mapLocal.get(wkid).creditLocal += creditLocal;
                mapLocal.get(wkid).debitLocal += debitLocal;
                mapLocal.get(wkid).balanceLocal += balanceLocal;
                
                if(isDisplayDetail){
                    lstAKMDetail.add(new AnkenDetail(item, debit, debitLocal, credit, creditLocal, balance, balanceLocal));
                }

                totalDebit += debit;
                totalCredit += credit;
                totalBalance += balance;
                
                totalDebitLocal += debitLocal;
                totalCreditLocal += creditLocal;
                totalBalanceLocal += balanceLocal;
            }
        }
    }
    
    private void setSTIDData(ReportDetailWrapper temp, String stid, Decimal debit, 
                             Decimal credit, Decimal balance,String wkid,String hbl, 
                             String mbl,String eta, String etd) {
        temp.stid = stid;
        temp.debit = debit;
        temp.credit = credit;
        temp.balance = balance;
        temp.wkid = wkid;
        temp.hbl = hbl;
        temp.mbl = mbl;
        temp.eta = eta;
        temp.etd = etd;
    }
   	
    public class ReportLocal{
        public Decimal creditLocal {get; set;}
        public Decimal debitLocal {get; set;}
        public Decimal balanceLocal {get; set;}
        public String salesAccountedDate {get; set;}
        public ReportLocal(){
            this.creditLocal = 0;
            this.debitLocal = 0;
            this.balanceLocal = 0;
            this.salesAccountedDate = '';
        }
        
        public ReportLocal(Decimal dmlCredit, Decimal dmlDebit, Decimal dmlBalance, String strSalesAccountedDate){
            this.creditLocal = dmlCredit;
            this.debitLocal = dmlDebit;
            this.balanceLocal = dmlBalance;
            this.salesAccountedDate = strSalesAccountedDate;
        }
    }
    
    public class AnkenDetail{
        public AnkenMeisai__c anken {get; set;}
        public Decimal debitUSD {get; set;}
        public Decimal debitLocal {get; set;}
        public Decimal creditUSD {get; set;}
        public Decimal creditLocal {get; set;}
        public Decimal balanceUSD {get; set;}
        public Decimal balanceLocal {get; set;}
        public AnkenDetail(){
            this.anken = new AnkenMeisai__c();
            this.debitUSD = 0;
            this.debitLocal = 0;
            this.creditUSD = 0;
            this.creditLocal = 0;
            this.balanceUSD = 0;
            this.balanceLocal = 0;
        }
        public AnkenDetail(AnkenMeisai__c objAnken, Decimal dmlDebitUSD, Decimal dmlDebitLocal, 
                           Decimal dmlCreditUSD, Decimal dmlCreditLocal, Decimal dmlBalanceUSD, Decimal dmlBanlanceLocal){
            this.anken = objAnken;
            this.debitUSD = dmlDebitUSD;
            this.debitLocal = dmlDebitLocal;
            this.creditUSD = dmlCreditUSD;
            this.creditLocal = dmlCreditLocal;
            this.balanceUSD = dmlBalanceUSD;
            this.balanceLocal = dmlBanlanceLocal;
        }
    }
}