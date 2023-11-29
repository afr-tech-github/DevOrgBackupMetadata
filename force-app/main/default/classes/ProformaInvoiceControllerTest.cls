@isTest
private class ProformaInvoiceControllerTest {
  private static Contract__c contract { get; set; }
  static {
    contract = new Contract__c(
      Unitpricewillbechargedbaseon__c = 'Gross Weight'
    );
    FlsService.doInsert(contract);

    ContractProduct__c conPro = new ContractProduct__c(
      CONTRACT__c = contract.Id,
      BillNameatPrintENG__c = 'Product A',
      PlanGrossWeightMT__c = 20,
      PlanNetWeightMT__c = 15,
      UnitPriceofSellingFCY__c = 1,
      PlanChargeQuantity__c = 5
    );
    FlsService.doInsert(conPro);
  }

  @isTest
  static void testProInvController() {
    Test.startTest();
    ApexPages.currentPage().getParameters().put('id', contract.Id);
    ApexPages.currentPage().getParameters().put('showFooter', 'true');
    ProformaInvoiceController proInvController = new ProformaInvoiceController();
    System.assert(proInvController.contractProducts.size() == 1);
    Test.stopTest();
  }
}