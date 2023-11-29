/**
 * Created by khanhpham on 5/7/17.
 */

@IsTest(SeeAllData = false)
private class LoadingLocationTriggerHandlerTest {
    @TestSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'MaximumWeight__c' => 1, 'MaximumMeasurement__c' => 100
        };
        TruckFleet__c truckFleet = (TruckFleet__c) TestDataFactory.createSObject(new TruckFleet__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'RoutingDate__c' => Date.today(), 'Truck__c' => truckFleet.Id
        };
        Route__c route = (Route__c) TestDataFactory.createSObject(new Route__c(), true, additionalFields);
    }

    @IsTest static void shouldInsertLoadingLocation() {
        Route__c route = [SELECT Id, RoutingDate__c FROM Route__c LIMIT 1];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 1,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 10
        };
        LoadingLocation__c location1 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), false, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 2,
                'Route__c' => route.Id, 'CargoWeight__c' => 200, 'CargoMeasurement__c' => 20
        };
        LoadingLocation__c location2 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), false, additionalFields);

        List<LoadingLocation__c> locations = new List<LoadingLocation__c>();
        locations.add(location1);
        locations.add(location2);

        Test.startTest();
        FlsService.doInsert(locations);
        Test.stopTest();

        locations = [SELECT Id FROM LoadingLocation__c WHERE Route__c = :route.Id];
        System.assertEquals(2, locations.size());
    }

    @IsTest static void shouldShipLocationOnDelete() {
        Route__c route = [SELECT Id, RoutingDate__c FROM Route__c LIMIT 1];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 1,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 20, 'CargoMeasurementBefore__c' => 10
        };
        LoadingLocation__c location1 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 2,
                'Route__c' => route.Id, 'CargoWeight__c' => 200, 'CargoMeasurement__c' => 50
        };
        LoadingLocation__c location2 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 3,
                'Route__c' => route.Id, 'CargoWeight__c' => 200, 'CargoMeasurement__c' => 50
        };
        LoadingLocation__c location3 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);

        Test.startTest();
        List<LoadingLocation__c> locations = [SELECT Id, CargoMeasurementBefore__c FROM LoadingLocation__c WHERE Route__c = :route.Id ORDER BY SequenceNumber__c ASC];
        System.assertEquals(3, locations.size());
        System.assertEquals(30, locations.get(1).CargoMeasurementBefore__c);

        location1 = [SELECT Id, SequenceNumber__c FROM LoadingLocation__c WHERE Id = :location1.Id];
        FlsService.doDelete(location1);
        Test.stopTest();

        location2 = [SELECT Id, CargoMeasurementBefore__c FROM LoadingLocation__c WHERE Id = :location2.Id];
        System.assertEquals(null, location2.CargoMeasurementBefore__c);
    }

    @IsTest static void shouldFailIfMissingSequenceNumber() {
        Route__c route = [SELECT Id, RoutingDate__c FROM Route__c LIMIT 1];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 20, 'CargoMeasurementBefore__c' => 10
        };
        LoadingLocation__c location1 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), false, additionalFields);

        Test.startTest();
        try {
            FlsService.doInsert(location1);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest static void shouldFailIfDuplicatedSequenceNumber() {
        Route__c route = [SELECT Id, RoutingDate__c FROM Route__c LIMIT 1];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 1,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 20
        };
        LoadingLocation__c location1 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 2,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 20
        };
        LoadingLocation__c location2 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 1,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 20
        };
        LoadingLocation__c location3 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), false, additionalFields);

        Test.startTest();

        try {
            location2 = [SELECT Id, SequenceNumber__c FROM LoadingLocation__c WHERE Id = :location2.Id];
            location2.SequenceNumber__c = 1;
            FlsService.doUpdate(location2);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }

        try {
            FlsService.doInsert(location3);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest static void shouldFailIfNegativeMeasurementOrWeight() {
        Route__c route = [SELECT Id, RoutingDate__c FROM Route__c LIMIT 1];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 1,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => -20
        };
        LoadingLocation__c location1 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), false, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 2,
                'Route__c' => route.Id, 'CargoWeight__c' => -100, 'CargoMeasurement__c' => 20
        };
        LoadingLocation__c location2 = (LoadingLocation__c) TestDataFactory.createSObject(new LoadingLocation__c(), false, additionalFields);

        Test.startTest();
        try {
            FlsService.doInsert(location1);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }

        try {
            FlsService.doInsert(location2);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
}