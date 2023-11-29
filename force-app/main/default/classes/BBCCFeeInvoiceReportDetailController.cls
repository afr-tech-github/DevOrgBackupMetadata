public with sharing class BBCCFeeInvoiceReportDetailController {
    public String partnerName {get;set;}
    public Date currentDate {get;set;}
    public Map<String,BBCCReportWrapper> mapBBCC {get;set;}
    public List<BBCCReportWrapper> lstBBCC {get;set;}
    public String message {get;set;}
    public Decimal totalSellInTaxAmount {get;set;}
    public Decimal totalSellTax {get;set;}
    public Decimal totalSellAmount {get;set;}
    private static List<String> selectFields = new List<String>();
    
    static {
		selectFields.add('Id');
        selectFields.add('Name');
        selectFields.add('Seikyusaki__r.Name');
        selectFields.add('SellInTaxAmountJPY__c');
        selectFields.add('SellDifferentiation__c');
        selectFields.add('SellAmountJPN__c');
        selectFields.add('Anken__r.Break_Bulk_Agent__r.Name');
        selectFields.add('SellTaxNum__c');
        selectFields.add('BuyAmountJPN__c');
        selectFields.add('BuyTaxNum__c');
        selectFields.add('BuyInTaxAmountJPY__c');
        selectFields.add('BuyDifferentiation__c');
    }
    
    public BBCCFeeInvoiceReportDetailController() {
        message = '';
        totalSellTax = 0;
        totalSellInTaxAmount = 0;
        totalSellAmount = 0;
        currentDate = Date.today();
        mapBBCC = new Map<String,BBCCReportWrapper>();
        lstBBCC = new List<BBCCReportWrapper>();
        
        partnerName = StringUtils.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('partnerName'), 'UTF-8'));
        String fromDate = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fromDate'));
        String toDate = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('toDate'));
        String soqlComm = generateSOQL(toDate, fromDate, partnerName);

        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleHBL() 
            && PermissionValidationUtil.isAccessibleHBLBuying() && PermissionValidationUtil.isAccessibleServiceMaster()) {
            List<AnkenMeisai__c> lstAKM = Database.query(soqlComm);
            
            if (!lstAKM.isEmpty()) {
                collectReportData(lstAKM);
            } else {
                message = 'There is no data collected from the database';
            }
        } else {
            message = 'Insufficient Permissions';
        }
    }
    
    private void collectReportData(List<AnkenMeisai__c> lstAKM) {
        for (AnkenMeisai__c item : lstAKM) {
            Decimal diff = (item.SellDifferentiation__c == null ? 0 : item.SellDifferentiation__c) - (item.BuyDifferentiation__c == null ? 0 : item.BuyDifferentiation__c);
            BBCCReportWrapper wrapper = new BBCCReportWrapper(item.Seikyusaki__r.Name, diff, 1);
            
            if (!mapBBCC.containsKey(wrapper.invoiceName)) {
                mapBBCC.put(wrapper.invoiceName,wrapper);
            }
            else {
                mapBBCC.get(wrapper.invoiceName).recordCount += 1;
                mapBBCC.get(wrapper.invoiceName).totalBalance += diff;
            }
            
            totalSellTax += (item.SellTaxNum__c == null ? 0 : item.SellTaxNum__c) - (item.BuyTaxNum__c == null ? 0 : item.BuyTaxNum__c);
            totalSellInTaxAmount += (item.SellInTaxAmountJPY__c == null ? 0 : item.SellInTaxAmountJPY__c) - (item.BuyInTaxAmountJPY__c == null ? 0 : item.BuyInTaxAmountJPY__c);
            totalSellAmount += (item.SellAmountJPN__c == null ? 0 : item.SellAmountJPN__c) - (item.BuyAmountJPN__c == null ? 0 : item.BuyAmountJPN__c);
        }
        
        if (!mapBBCC.isEmpty()) {
            Integer i = 1;
            
            for(BBCCReportWrapper item : mapBBCC.values()) {
                item.index = i;
                lstBBCC.add(item); 
                i++;
            } 
        }
    }
    
    private String generateSOQL(String toDate,String fromDate,String partnerName) {
        String soqlComm = 'SELECT ' + String.join(selectFields, ',') + 
            ' FROM AnkenMeisai__c' +
            ' WHERE ((Invoiceto_type__c = \'' + PicklistReference.THIRD_VENDOR_BB_CUSTOMERS_CLEARANCE 
            	+ '\' AND SellDifferentiation__c != 0) ' 
            	+ 'OR (SiharaisakiSyubetu__c = \'' + PicklistReference.THIRD_VENDOR_BB_CUSTOMERS_CLEARANCE 
            	+ '\' AND BuyDifferentiation__c != 0 AND ' 
            	+ '(InsatuyouSyohin__c LIKE \'%Break Bulk Fee%\' OR InsatuyouSyohin__c = \'CC FEE\' ' 
            	+ 'OR Tariff__r.Name LIKE \'%写真%\')))';     
        
        String filter = '';
        
        if (partnerName != null && !String.isEmpty(partnerName)) {
            filter = ' AND Seikyusaki__r.Name = \'' + partnerName + '\' ';
        }
        
        if (fromDate != null && toDate != null) {
            filter += ' AND (Anken__r.SalesAccountedDate__c >= ' + fromDate;
            filter += ' AND Anken__r.SalesAccountedDate__c <= ' + toDate + ')';
        }
        else if (fromDate != null && toDate == null) {
            filter += ' AND Anken__r.SalesAccountedDate__c >= ' + fromDate ;
        }
        else if (fromDate == null && toDate != null) {
            filter += ' AND Anken__r.SalesAccountedDate__c <= ' + toDate ;
        }
        
        if (!String.isEmpty(filter)) {
            soqlComm += filter;
        }
        
        return soqlComm;
    }
    
    public class BBCCReportWrapper {
        public String invoiceName {get;set;}
        public Integer recordCount {get;set;}    
        public Integer index {get;set;}
        public Decimal totalBalance {get;set;}
        
        public BBCCReportWrapper(String invoiceName, Decimal sellDifferentiation, Integer recordCount) {
			this.index = 0;
			this.invoiceName = invoiceName;
            this.recordCount = recordCount;
            this.totalBalance = sellDifferentiation;
		}
    }
}