public with sharing class MassiveQuoteLineController {
    public String action{get; set;}
    public Map<String, String> translations { get; private set; }
    public MassiveQuoteLineController() {
        action = ApexPages.currentPage().getParameters().get('action');
        initializeTranslation();
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('MassiveUpdate', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }
}