public with sharing class WorldExportController {
    public Site_Custom_Settings__c siteSetting {get; set;}
    public SALES_ORDER__c so {get; set;}
    public List<BillWrapper> billWrappers {get; set;}
    public Decimal totalShipmentNetWeightMT {get; set;}
    public Decimal totalShipmentGrossWeightMT {get; set;}
    public Boolean showFooter{get;set;}

    public WorldExportController() {
        String soId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        showFooter = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showFooter'));
        siteSetting = Site_Custom_Settings__c.getOrgDefaults();
        so = new SALES_ORDER__c();
        billWrappers = new List<BillWrapper>();
        totalShipmentNetWeightMT = 0;
        totalShipmentGrossWeightMT = 0;

        if(!String.isBlank(soId)){
            so = getSalesOrder(soId);
            getBillWrappers(soId);
        }
    }

    private SALES_ORDER__c getSalesOrder(String soId){
        SALES_ORDER__c salesOrder = new SALES_ORDER__c();
        salesOrder = [
            SELECT Id,
            CommercialInvoiceNo__c,
            InvoiceDate__c,
            ContractID__r.ContractNumber__c,
            ContractID__r.ContractSignedDate__c,
            ContractID__r.SellerCompany__r.Name,
            ContractID__r.SellerCompany__r.EnglishAddress__c,
            CustomerAddress__c,
            CustomerCompanyName__r.Name, 
            NotifyParty__r.Name,
            NotifyPartysAddress__c,
            PortofLoading__r.Name,
            PortofLoading__r.Country_Name__c,
            PortofDischarge__r.Name,
            PortofDischarge__r.Country_Name__c,
            PaymentCondition__c,
            LCNo__c,
            LCDate__c,
            CommodityDescriptionofGoods__c,
            NETWeightKG__c,
            RollupJumboBagWeightMTfromTRSBill__c,
            GrossWeightKG__c, 
            Packing__c,
            NumberofContainer_inwords__c,
            (SELECT ProductNamedetailatprintEng__c, NetWeightMT__c, GrossWeightMT__c FROM TRSBill__r ORDER BY name),
            RollupNWMTfromTRSBill__c,
            RollupGWMTfromTRSBill__c,
            ReceiptancePaymentType__c
            FROM SALES_ORDER__c
            WHERE Id =: soId WITH SECURITY_ENFORCED ];
        return salesOrder;
    }
    
    private void getBillWrappers(string soId){
        List<TRSBill__c> trsBills = [
            SELECT Id, ProductNameonPackingList__c
                FROM TRSBill__c
                WHERE SalesOrderID__c = :soId WITH SECURITY_ENFORCED ORDER BY Name];
        
        List<ContainerGoodSO__c> containerGoodSOs = [
            SELECT ContainerNumber__c,
                SealNumber__c,
                NetWeightMT__c,
                GrossWeightMT__c,
                TRSBill__c
                FROM ContainerGoodSO__c
                WHERE GOODSSO__c = :soId and TRSBill__c != null WITH SECURITY_ENFORCED ORDER BY TRSBill__r.Name];

        for(TRSBill__c trsBill : trsBills){
            BillWrapper billWrapper = new BillWrapper();

            billWrapper.productNameonPackingList = trsBill.ProductNameonPackingList__c;
            for(ContainerGoodSO__c containerGoodSO: containerGoodSOs){
                if(containerGoodSO.TRSBill__c == trsBill.Id){
                    billWrapper.containerGoodSOs.add(containerGoodSO);
                    
                    if(containerGoodSO.NetWeightMT__c!= null){
                        billWrapper.totalNetWeightMT += containerGoodSO.NetWeightMT__c;
                    }
                    if(containerGoodSO.GrossWeightMT__c!= null){
                        billWrapper.totalGrossWeightMT += containerGoodSO.GrossWeightMT__c;
                    }
                }
            }

            if(billWrapper.containerGoodSOs.size() != 0){
                totalShipmentNetWeightMT += billWrapper.totalNetWeightMT;
                totalShipmentGrossWeightMT += billWrapper.totalGrossWeightMT;
                
                billWrapper.romanNumber = intToRoman(billWrappers.size() + 1) + '/';
                billWrappers.add(billWrapper);
            }
        }
    }

    public static string intToRoman(integer index){
        return  'I'.repeat(index)
                  .replace('IIIII', 'V')
                  .replace('IIII', 'IV')
                  .replace('VV', 'X')
                  .replace('VIV', 'IX')
                  .replace('XXXXX', 'L')
                  .replace('XXXX', 'XL')
                  .replace('LL', 'C');
                //   .replace('LXL', 'XC')
                //   .replace('CCCCC', 'D')
                //   .replace('CCCC', 'CD')
                //   .replace('DD', 'M')
                //   .replace('DCD', 'CM');
      }

    public class BillWrapper{
        public string productNameonPackingList{get; set;}
        public string id{get; set;}
        public string romanNumber{get; set;}
        public List<ContainerGoodSO__c> containerGoodSOs{get; set;}
        public Decimal totalNetWeightMT{get; set;}
        public Decimal totalGrossWeightMT{get; set;}

        public BillWrapper(){
            productNameonPackingList = '';
            romanNumber = '';
            containerGoodSOs = new List<ContainerGoodSO__c>();
            totalNetWeightMT = 0;
            totalGrossWeightMT = 0;
        }
    }
}