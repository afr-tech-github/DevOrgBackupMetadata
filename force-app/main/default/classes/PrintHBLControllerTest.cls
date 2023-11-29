@isTest
public with sharing class PrintHBLControllerTest {
    @isTest
    public static void testGetData(){
        Test.startTest();
        Account acc = new Account(Name = 'test acc');
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
        insert acc;
        clofor_com_cfs__CustomObject1__c shipment = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__Field1__c = acc.Id,
                                                                                        clofor_com_cfs__CBM__c = 34,
                                                                                        clofor_com_cfs__C_W_Dimension_dev__c = 78);
        
        insert shipment;
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        PrintHBLController ctrl = new PrintHBLController();
        System.assertNotEquals(null, ctrl.shipment);
        Test.stopTest();
    }

    @isTest
    public static void testIsAutoCheckedCreateAttachment(){
        Test.startTest();
        Account acc = new Account(Name = 'test acc');
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
        insert acc;
        clofor_com_cfs__CustomObject1__c shipment = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__Field1__c = acc.Id);
        insert shipment;
        System.assertEquals(false, PrintHBLController.isAutoCheckedCreateAttachment(shipment.Id));
        Test.stopTest();
    }
}