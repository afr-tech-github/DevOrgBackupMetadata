@isTest
private class TranslationServiceTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Context__c' => 'TEST', 'Active__c' => true,
            'Name' => 'greeting', 'en_US__c' => 'Hello', 'vi__c' => 'Xin chào', 'ja__c' => 'こんにちは'};
		TestDataFactory.createSObject(new Translation__c(), true, additionalFields);
    }
    
    testmethod static void shouldReturnTranslationInEnglish() {
        TranslationService service = new TranslationService('TEST', 'en_US');
        
        Test.startTest();
        
        System.assertEquals('Hello', service.getTranslation('greeting'));
        String message = service.getTranslation('COST_ALLOCATION_MSG','Cost Allocation has been balanced successfully');
        String langCode = UserInfo.getLanguage();
        Map<String, Object> translate = TranslationService.getByLanguage(langCode.substringBefore('_'));
        
        Map<String, String> translations = service.getTranslations();
        System.assertEquals('Hello', translations.get('greeting'));
        
        
        Test.stopTest();
    }   
    
    testmethod static void shouldReturnTranslationInVietnamese() {
        TranslationService service = new TranslationService('TEST', 'vi');
        
        Test.startTest();
        
        System.assertEquals('Xin chào', service.getTranslation('greeting'));
        
        Map<String, String> translations = service.getTranslations();
        System.assertEquals('Xin chào', translations.get('greeting'));
        Map<String, Object> translate = TranslationService.getByLanguage('en_US');
        
        Test.stopTest();
    }
    
    testmethod static void shouldReturnTranslationInJapanese() {
        TranslationService service = new TranslationService('TEST', 'ja');
        
        Test.startTest();
        
        System.assertEquals('こんにちは', service.getTranslation('greeting'));
        
        Map<String, String> translations = service.getTranslations();
        Map<String, Object> translate = TranslationService.getByLanguage('');
        System.assertEquals('こんにちは', translations.get('greeting'));
        System.assertEquals('', service.getTranslation('nonexistence'));
        
        Test.stopTest();
    }
}