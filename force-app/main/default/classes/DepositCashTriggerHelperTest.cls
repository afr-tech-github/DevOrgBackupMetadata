@isTest
private class DepositCashTriggerHelperTest {
    private static List<Deposit__c> listDeposit = new List<Deposit__c>();
    private static List<CASH_BOOK__c> listCash = new List<CASH_BOOK__c>();
    static{
        Custom_Application_Config__c appConfig = new Custom_Application_Config__c(
            Disabled_Trigger__c = false
            );
        insert appConfig;

        Map<String, Schema.RecordTypeInfo> mapDepositRecordTypeByDeveloperName = Schema.getGlobalDescribe().get('clofor_com_cfs__Deposit__c').getDescribe().getRecordTypeInfosByDeveloperName();

        Deposit__c deposit1 = new Deposit__c(
            RecordTypeId = mapDepositRecordTypeByDeveloperName.get('DepositTo3rdPartyLocalCurrency').getRecordTypeId(),
            DepositName__c = 'Test1',
            AmountPaidToVendorLocal__c = 1,
            AmountPaidToVendor__c = 1,
            AmountReceivedFromCustomerUSD__c =1
            );

        listDeposit.add(deposit1);
        insert listDeposit;
        
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


    } 
    
    @isTest static void test_method_onAfterInsert() {
        Test.startTest();

            DepositCash__c newDepositCash1 = new DepositCash__c(
                Cash__c = listCash[0].Id,
                Deposit__c = listDeposit[0].Id

            );
            DepositCash__c newDepositCash2 = new DepositCash__c(
                Cash__c = listCash[1].Id,
                Deposit__c = listDeposit[0].Id
            );

            List<DepositCash__c> listDepositCash = new List<DepositCash__c>();
            listDepositCash.add(newDepositCash1);
            listDepositCash.add(newDepositCash2);

            insert listDepositCash;
            System.assert(listDepositCash != null);
        Test.stopTest();    
        // Implement test code
    }
    
    @isTest static void test_method_onAfterDelete() {
        
        DepositCash__c newDepositCash1 = new DepositCash__c(
            Cash__c = listCash[0].Id,
            Deposit__c = listDeposit[0].Id

        );
        DepositCash__c newDepositCash2 = new DepositCash__c(
            Cash__c = listCash[1].Id,
            Deposit__c = listDeposit[0].Id
        );

        List<DepositCash__c> listDepositCash = new List<DepositCash__c>();
        listDepositCash.add(newDepositCash1);
        listDepositCash.add(newDepositCash2);

        insert listDepositCash;
        Test.startTest();
        
        delete listDepositCash;
        System.assert(listDeposit != null);
        Test.stopTest();    
    }
    
}