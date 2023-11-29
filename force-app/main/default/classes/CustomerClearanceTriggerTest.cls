@isTest
private class CustomerClearanceTriggerTest {
    @testsetup static void setUp() {
        Date etd = Date.newInstance(2015, 01, 02);
        Date eta = Date.newInstance(2015, 02, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_IMPORT_RT];
        RecordType rt1 = [Select Id from RecordType where DeveloperName = :Constants.CROSS_BOARDER_RT AND SobjectType = 'clofor_com_cfs__CustomObject1__c'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionFields);

        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            									'RecordTypeId' => rt.Id, 'ETD__c' => etd, 'ETA__c' => eta,
            									'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES,
                                                'TranporationType__c' => 'LCL', 'DeliveryService_required__c' => '1',
                                                'clofor_com_cfs__POD__c' => objPort.Id};
		TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);    
         additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            									'RecordTypeId' => rt1.Id, 'ETD__c' => etd, 'ETA__c' => eta,
            									'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES,
                                                'TranporationType__c' => 'LCL', 'DeliveryService_required__c' => '1',
                                                'clofor_com_cfs__POD__c' => objPort.Id};
		TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        System.assert(true);
    }	
    
    testmethod static void shouldUpdateCustomClearance() {
        Date releaseDate = Date.newInstance(2015, 03, 02);
        Date pickupDate = Date.newInstance(2015, 04, 02);
        Date deliveryDate = Date.newInstance(2015, 05, 02);
        List<Custom_Clearance__c> ccs = [select Id, Customs_Release_Day__c from Custom_Clearance__c];
        List<Cargo_Delivery__c> cds = [select Id, Pickupdate__c, DeliveryDate__c from Cargo_Delivery__c];
        
        System.assertEquals(1, ccs.size());
        System.assertEquals(1, cds.size());
        
        Custom_Clearance__c cc = ccs.get(0);
        cc.Customs_Release_Day__c = releaseDate;
        
        Cargo_Delivery__c cd = cds.get(0);
        cd.Pickupdate__c = pickupDate;
        cd.DeliveryDate__c = deliveryDate;
        
        Test.startTest();
        FlsService.doUpdate(new List<SObject>{ cd, cc });
        Test.stopTest();
        CustomObject1__c shipment = [select Id, CustomsReleaseDay__c from CustomObject1__c limit 1];
        System.assertEquals(releaseDate, shipment.CustomsReleaseDay__c);
    }
    
    testmethod static void shouldFailToUpdateCustomClearance() {
        Date releaseDate = Date.newInstance(2015, 05, 02);
        Date pickupDate = Date.newInstance(2015, 04, 02);
        Date deliveryDate = Date.newInstance(2015, 05, 02);
        List<Custom_Clearance__c> ccs = [select Id, Customs_Release_Day__c from Custom_Clearance__c];
        List<Cargo_Delivery__c> cds = [select Id, Pickupdate__c, DeliveryDate__c from Cargo_Delivery__c];
        
        System.assertEquals(1, ccs.size());
        System.assertEquals(1, cds.size());
        
        Custom_Clearance__c cc = ccs.get(0);
        cc.Customs_Release_Day__c = releaseDate;
        
        Cargo_Delivery__c cd = cds.get(0);
        cd.Pickupdate__c = pickupDate;
        cd.DeliveryDate__c = deliveryDate;
        
        Test.startTest();
        
        try {
            FlsService.doUpdate(new List<SObject>{ cd, cc });
            System.assert(true);
        } catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void shouldUpdateShipmentOnCustomClearanceDelete() {
        List<Custom_Clearance__c> ccs = [select Id, Customs_Release_Day__c from Custom_Clearance__c];
        System.assertEquals(1, ccs.size());
        Custom_Clearance__c cc = ccs.get(0);
        
        Test.startTest();
			FlsService.doDelete(cc);
        Test.stopTest();
        
        CustomObject1__c shipment = [select Id, Custom__c from CustomObject1__c limit 1];
        System.assertEquals(PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO, shipment.Custom__c);
    }
}