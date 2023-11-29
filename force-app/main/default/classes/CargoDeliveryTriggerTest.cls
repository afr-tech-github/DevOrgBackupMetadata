@isTest
private class CargoDeliveryTriggerTest {
    @testsetup static void setUp() {
        Date etd = Date.newInstance(2015, 01, 02);
        Date eta = Date.newInstance(2015, 02, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.CROSS_BOARDER_RT AND SobjectType = 'clofor_com_cfs__CustomObject1__c'];
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
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);        
    }
    
    testmethod static void shouldInsertCargoDelivery() {
        Date pickupDate = Date.newInstance(2015, 04, 02);
        Date deliveryDate = Date.newInstance(2015, 05, 02);
        CustomObject1__c shipment = [select Id, DeliveryService_required__c from CustomObject1__c limit 1];
        
        System.assertNotEquals(null, shipment);
        System.assertEquals('1', shipment.DeliveryService_required__c);
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Consolidation_Truck_Import'];
        Map<String, Object> additionalFields = new Map<String, Object> {'HBL_SHIPMENT__c' => shipment.Id, 'RecordTypeId' => rt.Id,
            									'Pickupdate__c' => pickupDate, 'DeliveryDate__c' => deliveryDate};
		Cargo_Delivery__c cd = (Cargo_Delivery__c) TestDataFactory.createSObject(new Cargo_Delivery__c(), false, additionalFields);
        
        Test.startTest();
		FlsService.doInsert(cd);
        Test.stopTest();
        shipment = [select Id, DeliveryService_required__c from CustomObject1__c where Id = :shipment.Id];
        
        System.assertNotEquals(null, shipment);
        System.assertEquals('2', shipment.DeliveryService_required__c);
    }
    
    testmethod static void shouldUpdateCargoDelivery() {
        Date pickupDate = Date.newInstance(2015, 04, 02);
        Date deliveryDate = Date.newInstance(2015, 05, 02);
        CustomObject1__c shipment = [select Id, DeliveryService_required__c from CustomObject1__c limit 1];
        
        System.assertNotEquals(null, shipment);
        System.assertEquals('1', shipment.DeliveryService_required__c);

		Cargo_Delivery__c cd = [select Id, Pickupdate__c, DeliveryDate__c from Cargo_Delivery__c limit 1];
        cd.DeliveryDate__c = deliveryDate;
        cd.Pickupdate__c = pickupDate;
        
        Test.startTest();
			FlsService.doUpdate(cd);
        Test.stopTest();
        
        cd = [select Id, Pickupdate__c, DeliveryDate__c from Cargo_Delivery__c limit 1];
        System.assertEquals(pickupDate, cd.Pickupdate__c);
        System.assertEquals(deliveryDate, cd.DeliveryDate__c);
    }
    
    testmethod static void shouldUpdateShipmentOnCargoDeliveryDelete() {
        CustomObject1__c shipment = [select Id, DeliveryService_required__c from CustomObject1__c limit 1];
        
        System.assertNotEquals(null, shipment);
        System.assertEquals('1', shipment.DeliveryService_required__c);

		Cargo_Delivery__c cd = [select Id, Pickupdate__c, DeliveryDate__c from Cargo_Delivery__c limit 1];
        
        Test.startTest();
        FlsService.doDelete(cd);
        Test.stopTest();
        
        shipment = [select Id, DeliveryService_required__c from CustomObject1__c where Id = :shipment.Id];
        System.assertEquals('0', shipment.DeliveryService_required__c);
    }
}