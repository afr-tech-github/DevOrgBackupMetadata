@isTest
private class RecordTypeUtilTest {
    testmethod static void shouldReturnCorrectRecordType() {
		final String developerName = 'InAir';
        
        Test.startTest();
        
        String rtId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, developerName);
        System.assertNotEquals(null, rtId);
        String rtDeveloperName = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, rtId);
        System.assertEquals(developerName, rtDeveloperName);
            
        Test.stopTest();
    }
}