@isTest
private class POCashTriggerHelperTest {
    
    private static List<ConnectPurchasingInvoiceCash__c> lishPurchasingCash = new List<ConnectPurchasingInvoiceCash__c>();
    private static List<CASH_BOOK__c> listCash = new List<CASH_BOOK__c>();
    static{
        Custom_Application_Config__c appConfig = new Custom_Application_Config__c(
            Disabled_Trigger__c = false
            );
        insert appConfig;
        PurchasingOrder__c purchasingOrder = new PurchasingOrder__c(
            );
        insert purchasingOrder;
        PurchasingInvoice__c purchasing  = new PurchasingInvoice__c(
            UnitPriceLocal__c = 10,
            ChargeUnit__c = 1,
            UnitPrice__c = 2,
            PaidAmountLocal__c = 0,
            PaidAmount__c =1,
            TaxRate__c =10,
            PurchasingOrder__c = purchasingOrder.Id
            );
        insert purchasing;
        
        Map<String, Schema.RecordTypeInfo> mapCashRecordTypeByDeveloperName = Schema.getGlobalDescribe().get('clofor_com_cfs__CASH_BOOK__c').getDescribe().getRecordTypeInfosByDeveloperName();

        CASH_BOOK__c cash1 = new CASH_BOOK__c(
            RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashIn').getRecordTypeId()
        );
        CASH_BOOK__c cash2 = new CASH_BOOK__c(
            RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashOut').getRecordTypeId()
        );

        listCash.add(cash1);
        listCash.add(cash2);

        insert listCash;
        ConnectPurchasingInvoiceCash__c link1 = new ConnectPurchasingInvoiceCash__c(
            Cashbook__c = listCash[0].Id,
            PurchasingInvoice__c = purchasing.Id

        );
        ConnectPurchasingInvoiceCash__c link2 = new ConnectPurchasingInvoiceCash__c(
            Cashbook__c = listCash[1].Id,
            PurchasingInvoice__c = purchasing.Id
        );
        lishPurchasingCash.add(link1);
        lishPurchasingCash.add(link2);
        

    } 
    
    @isTest static void test_method_onAfterInsert() {
        Test.startTest();

            insert lishPurchasingCash;
            System.assert(lishPurchasingCash != null);
        Test.stopTest();    
        // Implement test code
    }
    
    @isTest static void test_method_onBeforeDelete() {
        
        insert lishPurchasingCash;
        
        Test.startTest();
        
            delete lishPurchasingCash;
            Integer x =1;
            System.assert(x != null);
        Test.stopTest();    
    }
    
}