public with sharing class ProformaInvoiceController {
  public Site_Custom_Settings__c siteSetting { get; set; }
  public Contract__c contract { get; set; }
  public List<ContractProduct__c> contractProducts { get; set; }
  public Decimal totalWeightMT { get; set; }
  public Decimal totalUnitPrice { get; set; }
  public Decimal totalAmount { get; set; }
  public String bankType { get; set; }
  public Boolean showFooter{get;set;}
  public String sayContext{get;set;}

  public ProformaInvoiceController() {
    String contractId = ApexPages.currentPage()
      .getParameters()
      .get('id')
      .escapeHtml4();
    bankType = ApexPages.currentPage().getParameters().get('bankType');
    showFooter = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showFooter'));

    siteSetting = Site_Custom_Settings__c.getOrgDefaults();
    contract = new Contract__c();
    contractProducts = new List<ContractProduct__c>();
    totalWeightMT = 0;
    totalUnitPrice = 0;
    totalAmount = 0;
    sayContext = '';

    if (bankType == null) {
      bankType = 'local1';
    }

    if (!String.isBlank(contractId)) {
      contract = getContract(contractId);
      getContractProducts(contractId);
      if(contract != null && contract.TotalAmountofSellingFCYtext__c != null) {
 
        sayContext = contract.TotalAmountofSellingFCYtext__c;
      }
    }
  }

  private Contract__c getContract(String contractId) {
    Contract__c con = new Contract__c();
    con = [
      SELECT
        Id,
        SellerCompany__r.Name,
        SellerCompany__r.EnglishAddress__c,
        ProformaInvoiceNo__c,
        ProformaInvoiceDate__c,
        ContractNumber__c,
        ContractSignedDate__c,
        ContractorName__r.Name,
        BuyersAddress__c,
        PortofLoading__r.Name,
        PortofLoading__r.Country_Name__c,
        PortofDischarge__r.Name,
        PortofDischarge__r.Country_Name__c,
        PaymentCondition__c,
        //LCNo__c,
        //LCDate__c,
        Unitpricewillbechargedbaseon__c,
        UnitpriceChargeUnit__c,
        CommodityDescriptionofGoodsPI__c,
        TotalAmountofSellingFCYtext__c,
        Notes__c,
        ReceiptancePaymentType__c,
        NotifyParty__c,
        NotifyParty__r.Name,
        NotifyPartysAddress__c
      FROM Contract__c
      WHERE Id = :contractId
      WITH SECURITY_ENFORCED
    ];
    return con;
  }

  private void getContractProducts(string contractId) {
    contractProducts = [
      SELECT
        BillNameatPrintENG__c,
        PlanGrossWeightMT__c,
        PlanNetWeightMT__c,
        PlanChargeQuantity__c,
        UnitPriceofSellingFCY__c,
        PlanTotalAmountofSellingFCY__c
      FROM ContractProduct__c
      WHERE CONTRACT__c = :contractId
      WITH SECURITY_ENFORCED
    ];

    for (ContractProduct__c conProc : contractProducts) {
      if (
        contract.Unitpricewillbechargedbaseon__c == 'G.W (MT)' &&
        conProc.PlanGrossWeightMT__c != null
      ) {
        totalWeightMT += conProc.PlanGrossWeightMT__c;
      }

      if (
        contract.Unitpricewillbechargedbaseon__c == 'N.W (MT)' &&
        conProc.PlanNetWeightMT__c != null
      ) {
        totalWeightMT += conProc.PlanNetWeightMT__c;
      }

      if (
        contract.Unitpricewillbechargedbaseon__c != 'G.W (MT)' &&
        contract.Unitpricewillbechargedbaseon__c != 'N.W (MT)' &&
        conProc.PlanChargeQuantity__c != null
      ) {
        totalWeightMT += conProc.PlanChargeQuantity__c;
      }

      if (conProc.UnitPriceofSellingFCY__c != null) {
        totalUnitPrice += conProc.UnitPriceofSellingFCY__c;
      }
      if (conProc.PlanTotalAmountofSellingFCY__c != null) {
        totalAmount += conProc.PlanTotalAmountofSellingFCY__c;
      }
    }
  }
}