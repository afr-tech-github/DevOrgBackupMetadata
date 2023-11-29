/**
 * Created by khanhpham on 6/12/17.
 */

@IsTest
private class TrackingControllerTest {
    @TestSetup static void setUp() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
         setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        Map<String, Object> additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => '123456'};
        TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => '345678'};
        TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
    }

    @IsTest static void shouldFoundTwoOrder() {
        PageReference pageRef = Page.OrderTracking;
        Test.setCurrentPage(pageRef);
        TrackingController controller = new TrackingController();

        Test.startTest();
        controller.searchField = 'HBL_Number_SEA_AIR__c';
        controller.searchString = '3456';
        controller.doSearch();
        Test.stopTest();

        System.assertEquals(2, controller.shipmentOrderList.size());
    }

    @IsTest static void shouldReturnErrorMessage() {
        PageReference pageRef = Page.OrderTracking;
        Test.setCurrentPage(pageRef);
        TrackingController controller = new TrackingController();

        Test.startTest();
        controller.searchField = 'HBL_Number_SEA_AIR__c';
        controller.searchString = '000111';
        controller.doSearch();
        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
    }
}