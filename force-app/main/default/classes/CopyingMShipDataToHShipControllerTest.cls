@isTest(SeeAllData=false)
public class CopyingMShipDataToHShipControllerTest {

    static testmethod void shouldCopyDataFromMShipToHShips() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'InAir'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id};
        LoadLocation__c loadLocation = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionFields);
        
        Date etd = Date.newInstance(2015, 07, 04);
        additionFields = new Map<String, Object> {'METD__c' => etd, 'MBookingNv__c' => account.Id, 'MLoadLocation__c' => loadLocation.Id};
        MasterAnken__c mship = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'MasterAnkenName__c' => mship.Id, 'RecordTypeId' => rt.Id,
                                                    'Container2__c' =>'AIR',
                                                    'Container3__c' =>'AIR',
                                                    'Container4__c' =>'AIR',
                                                    'Container__c' =>'AIR',
                                                    'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                    'clofor_com_cfs__ContainerNumber4__c' => 1
                                                };
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        PageReference pageRef = Page.page_CopyingMShipDataToHShips;
        pageRef.getParameters().put('Id', mship.Id);
        Test.setCurrentPage(pageRef);
		
        Test.startTest();
        CopyingMShipDataToHShipController controller = new CopyingMShipDataToHShipController();
        controller.copy();
        Test.stopTest();
        
        CustomObject1__c actual = [SELECT ETD__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(actual.ETD__c, actual.ETD__c);
    }
}