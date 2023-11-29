@isTest
private class CarrierCodeTrigerTest {
    @testsetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object> {'Name' => 'NAME', 
            										'Carrier_Code__c' => 'AB01', 'Company_Name__c' => 'ABC Corp.'};
		TestDataFactory.createSObject(new Carrier_Code__c(), true, additionalFields);
        System.assert(true);
    }
    
    testmethod static void shouldUpdateNameOnInsert() {
        Map<String, Object> additionalFields = new Map<String, Object> {'Name' => 'NAME', 
            										'Carrier_Code__c' => 'CD01', 'Company_Name__c' => 'ABC Corp.'};
		Carrier_Code__c cc = (Carrier_Code__c) TestDataFactory.createSObject(new Carrier_Code__c(), true, additionalFields);
        
        Test.startTest();
        cc = [select Id, Carrier_Code__c, Name from Carrier_Code__c where Id = :cc.Id];
        
        System.assertEquals('CD01', cc.Carrier_Code__c);
        System.assertEquals('CD01', cc.Name);
        Test.stopTest();
    }
    
    testmethod static void shouldUpdateNameOnUpdate() {
		Carrier_Code__c cc = [select Id, Name, Carrier_Code__c from Carrier_Code__c limit 1];
        System.assertEquals('AB01', cc.Carrier_Code__c);
        System.assertEquals('AB01', cc.Name);
        
        Test.startTest();
        cc.Carrier_Code__c = 'XY01';
        FlsService.doUpdate(cc);
        Test.stopTest();
        
        cc = [select Id, Name, Carrier_Code__c from Carrier_Code__c where Id = :cc.Id];
        System.assertEquals('XY01', cc.Carrier_Code__c);
        System.assertEquals('XY01', cc.Name);
    }
}