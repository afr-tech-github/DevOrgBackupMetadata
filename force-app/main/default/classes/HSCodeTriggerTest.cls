@isTest
private class HSCodeTriggerTest {
    @testsetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object> {'HS_Code__c' => '111100', 'Is_Chapter__c' => true};
		TestDataFactory.createSObject(new HS_Code__c(), true, additionalFields);
    }
    
    testmethod static void shouldAssignParentForSubCategory() {
        HS_Code__c parent = [select Id, HS_Code__c from HS_Code__c limit 1];
        System.assertNotEquals(null, parent);
        System.assertEquals('111100', parent.HS_Code__c);
        
        Map<String, Object> additionalFields = new Map<String, Object> {'HS_Code__c' => '111110', 'Is_Chapter__c' => false};
		HS_Code__c hsCode = (HS_Code__c) TestDataFactory.createSObject(new HS_Code__c(), false, additionalFields);
        
        Test.startTest();
        FlsService.doInsert(hsCode);
        Test.stopTest();
        
        hsCode = [select Id, HS_Code__c, Chapter__c from HS_Code__c where Id = :hsCode.Id];
        System.assertEquals(parent.Id, hsCode.Chapter__c);
        
        parent = [select Id, Has_Subcategory__c from HS_Code__c where Id = :parent.Id];
        System.assertEquals(true, parent.Has_Subcategory__c);
    }
}