/**
 * Created by khanhpham on 5/7/17.
 */
@IsTest(SeeAllData = false)
private class ObjectCloningServiceTest {
    @TestSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'MaximumWeight__c' => 1, 'MaximumMeasurement__c' => 100
        };
        TruckFleet__c truckFleet = (TruckFleet__c) TestDataFactory.createSObject(new TruckFleet__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'RoutingDate__c' => Date.today(), 'Truck__c' => truckFleet.Id
        };
        Route__c route = (Route__c) TestDataFactory.createSObject(new Route__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 1,
                'Route__c' => route.Id, 'CargoWeight__c' => 100, 'CargoMeasurement__c' => 10
        };
        TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'HandlingType__c' => LoadingLocationTriggerHandler.TRUCK_HANDLE_LOAD, 'SequenceNumber__c' => 2,
                'Route__c' => route.Id, 'CargoWeight__c' => 200, 'CargoMeasurement__c' => 20
        };
        TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);
    }

    @IsTest static void shouldDeepCloneRoute() {
        Route__c route = [SELECT Id, RoutingDate__c, Truck__c FROM Route__c LIMIT 1];

        Test.startTest();
        String clonedId = ObjectCloningService.cloneDeepRoute(route.Id);
        Test.stopTest();

        Route__c clonedRoute = [SELECT Id, RoutingDate__c, Truck__c FROM Route__c LIMIT 1];
        System.assertNotEquals(null, clonedId);
        System.assertEquals(route.Truck__c, clonedRoute.Truck__c);

        List<LoadingLocation__c> locations = [SELECT Id FROM LoadingLocation__c WHERE Route__c = :clonedId];
        System.assertEquals(2, locations.size());
    }
}