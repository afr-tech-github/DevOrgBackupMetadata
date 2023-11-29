@isTest
private class SOSummaryNoteControllerTest {
    private static SALES_ORDER__c gSalesOrder {get; set;}
    static{
        Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
                TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        
        PRODUCT__c product = new PRODUCT__c( MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
                                            GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                            InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                            RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                            SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                            UsageChargeBillingFreqType__c = 'Continuous Billing');
        FlsService.doInsert(product);
        
        Contract__c contract = new Contract__c();
        FlsService.doInsert(contract);
        gSalesOrder = new SALES_ORDER__c(
            ContractID__c = contract.Id
        );
        FlsService.doInsert(gSalesOrder);
        
        SalesOrderProduct__c gp = new SalesOrderProduct__c(
            GoodSalesOrderID__c = gSalesOrder.Id,
            ProductID__c = product.Id);
        FlsService.doInsert(gp);
    }
    
    @isTest static void test_method_one() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', gSalesOrder.Id);
        SOSummaryNoteController ctrl = new SOSummaryNoteController();
        String  totalAmountVND = ctrl.total.getTotalAmountVND();
        String  getTotalAmountTaxVND = ctrl.total.getTotalAmountTaxVND();
        String  getTotalAmountIncludeTaxVND = ctrl.total.getTotalAmountIncludeTaxVND();
        String  getNetPurchaseValueVND = ctrl.listGoodSOProductNode[0].getNetPurchaseValueVND();
        String  getVATVND = ctrl.listGoodSOProductNode[0].getVATVND();
        String  getAmountVND = ctrl.listGoodSOProductNode[0].getAmountVND();
        String  getTotalAmountVND = ctrl.listGoodSOProductNode[0].getTotalAmountVND();
        String  getAmountTaxVND = ctrl.listGoodSOProductNode[0].getAmountTaxVND();
        system.assert(gSalesOrder.Id != null);
        Test.stopTest();
    }
    
}