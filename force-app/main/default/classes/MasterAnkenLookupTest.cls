@isTest
public class MasterAnkenLookupTest {
    static private String recordTypeId;
    static private String makId;
    static private String shipmentId;
    
    private static void createData() {
        String objectName = Constants.NAMESPACE + 'CustomObject1__c';
        recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = :objectName AND DeveloperName = 'InAir'].Id;
        Account account = (Account) TestDataFactory.createSObject(new Account(), null);
        account.Field3__c = '年1回';
        account.cc_closing_date__c = '納品日';
        account.Custom_Type__c = '海外顧客 - 既存';
        account.ServiceType__c = 'FORWARDING';
        account.Ownership_cat__c = 'パートナーFree-Handカーゴ(輸入のみ）';
        account.AFRtype__c = 'AFRサービス見込み顧客';
        account.Outbound__c = 'HONG KONG';
        account.Inbound__c = 'TOKYO';
        account.Field1__c = 'ダイレクト口座';
        account.Filer__c = '登録会社';
        FlsService.doInsert(account);
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
        Map<String, Object> additionFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id};
        LoadLocation__c loadLocation = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionFields);
        
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), null);
        shipment.RecordTypeId = recordTypeId;
        shipment.ETD__c = Date.today();
        shipment.Field1__c = account.Id;
        shipment.Container__c = 'ISO';
        shipment.ContainerNumber__c = 10;
        shipment.ContainerNumber__c = 10;
        shipment.clofor_com_cfs__ContainerNumber__c = 1;
        shipment.clofor_com_cfs__ContainerNumber2__c = 1;
        shipment.clofor_com_cfs__ContainerNumber3__c= 1;
        shipment.clofor_com_cfs__ContainerNumber4__c = 1;
        shipment.clofor_com_cfs__Container__c = '20\'DC';
        shipment.clofor_com_cfs__Container2__c = '20\'DC';
        shipment.clofor_com_cfs__Container3__c = '20\'DC';
        shipment.clofor_com_cfs__Container4__c = '20\'DC';        
        
        FlsService.doInsert(shipment);
        shipmentId = shipment.Id;
        
        MasterAnken__c mak1 = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), null);
        mak1.name = 'ABC';
        mak1.MBookingNv__c = account.Id;
        mak1.MLoadLocation__c = loadLocation.Id;
        mak1.MVessel__c = 'SHIP123';
        FlsService.doInsert(mak1);
        makId = mak1.Id;
    }
    
    testmethod static void testCopyFromMasterAnken() {
        createData();

        Test.startTest();
        MasterAnkenLookupController controller = new MasterAnkenLookupController();
        List<SelectOption> lstSelects = controller.radioType;
        controller.strHShipmentID = shipmentId;
        controller.strSearchValue = 'ABC';
        controller.radioValue = 'Name';
        controller.doSearch();
        
        controller.strMasterAnkenID = [SELECT ID FROM MasterAnken__c WHERE Name = 'ABC'].ID;
        controller.copyFromMasterAnken();
		Test.stopTest();
        
        CustomObject1__c shipment = [SELECT Vessle__c FROM CustomObject1__c WHERE Id = :shipmentId];
        System.assertEquals('SHIP123', 'SHIP123');
    }
}