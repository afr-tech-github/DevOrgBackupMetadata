@isTest(SeeAllData = false)
public class AccountTriggerTest {
    testmethod static void shouldGenerateReferenceNumberFirstTime() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Name' => 'My Klomos', 
														'EnglishCompanyName__c' =>'Kkk Lll   Ooo Mm Oooo Sss', 
            											'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};    
		Test.startTest();
		Account accn = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        Test.stopTest();
        accn = [SELECT Reference_Number__c FROM Account WHERE Id = :accn.Id];
        System.assertEquals('KLOMOS00001', accn.Reference_Number__c);
        
        Common_Settings__c setting = [SELECT Value__c FROM Common_Settings__c 
                                      WHERE Keyword__c = :Constants.COMMON_SETTINGS_ACCOUNT_REFERENCE];
        System.assertEquals('00001', setting.Value__c);
    }

	testmethod static void shouldGenerateReferenceNumberSubTime() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Keyword__c' => Constants.COMMON_SETTINGS_ACCOUNT_REFERENCE,
            											'Value__c' => '00011', 'Name' => 'ACCN-REF-No'};
		TestDataFactory.createSObject(new Common_Settings__c(), true, additionalFields);
            
		additionalFields = new Map<String, Object>{'Name' => 'My Klomos', 
														'EnglishCompanyName__c' =>'Kkk Lll   Ooo Mm Oooo Sss', 
            											'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};    
		Test.startTest();
		Account accn = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        Test.stopTest();
        accn = [SELECT Reference_Number__c FROM Account WHERE Id = :accn.Id];
        System.assertEquals('KLOMOS00012', accn.Reference_Number__c);
        
        Common_Settings__c setting = [SELECT Value__c FROM Common_Settings__c 
                                      WHERE Keyword__c = :Constants.COMMON_SETTINGS_ACCOUNT_REFERENCE];
        System.assertEquals('00012', setting.Value__c);
    }    
}