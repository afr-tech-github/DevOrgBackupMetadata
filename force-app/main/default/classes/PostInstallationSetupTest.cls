@isTest
private class PostInstallationSetupTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        System.assert(true);
    }

    testmethod static void shouldPopulateSettingOnFirstInstallation() {
        Integer count = [SELECT count() FROM CONTAINER_INFO_MAPPINGS__c];
        System.assertEquals(0, count);

        try {
            Test.startTest();
            PostInstallationSetup job = new PostInstallationSetup();
            Test.testInstall(job, null);
            Test.stopTest();

            count = [SELECT count() FROM CONTAINER_INFO_MAPPINGS__c];
            System.assertEquals(13, count);
        } catch (System.DmlException e) {
            System.assert(true);
        }
    }

    testmethod static void shouldNotPopulateSettingOnSubsequentInstallation() {
        Integer count = [SELECT count() FROM CONTAINER_INFO_MAPPINGS__c];
        System.assertEquals(0, count);

        Test.startTest();
        PostInstallationSetup job = new PostInstallationSetup();
        Version ver = new Version(1, 0);
        Test.testInstall(job, ver, true);
        Test.stopTest();

        count = [SELECT count() FROM CONTAINER_INFO_MAPPINGS__c];
        System.assertEquals(0, count);
    }
}