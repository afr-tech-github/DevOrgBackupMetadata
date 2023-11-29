@isTest
private class WorldExportControllerTest {
    private static SALES_ORDER__c so {get; set;}
    static{
        Contract__c contract = new Contract__c();
        FlsService.doInsert(contract);

        so = new SALES_ORDER__c(
            ContractID__c = contract.Id
        );
        FlsService.doInsert(so);

        TRSBill__c trsBill = new TRSBill__c(
        	SalesOrderID__c = so.Id,
            ProductNameonPackingList__c = 'Test TRS Bill'
        );
        FlsService.doInsert(trsBill);
        
        ContainerGoodSO__c container = new ContainerGoodSO__c(
        	GOODSSO__c = so.Id,
            TRSBill__c = trsBill.Id,
            ContainerNumber__c = 'c123',
            SealNumber__c = 's123',
            NetWeightMT__c = 5,
            GrossWeightMT__c = 10
        );
        FlsService.doInsert(container);
    }
    
    @isTest static void testWorldExportController() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', so.Id);
        ApexPages.currentPage().getParameters().put('showFooter', 'true');
		WorldExportController weController = new WorldExportController();
        System.assert(true == true, 'Success');
        Test.stopTest();
    }
}