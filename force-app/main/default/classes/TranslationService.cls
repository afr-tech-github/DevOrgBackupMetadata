public with sharing class TranslationService {
	private String language;
    private String context;
    private Map<String, String> translations;

    public TranslationService(String context, String language) {
        this.context = context;
        this.language = language;
        loadTranslations();
    }

    public String getTranslation(String keyword) {
        if (translations.containsKey(keyword)) {
            return translations.get(keyword);
        }

        return '';
    }

    public String getTranslation(String keyword, String defaultMessage) {
        if (translations.containsKey(keyword)) {
            return translations.get(keyword);
        }

        return defaultMessage;
    }

    public Map<String, String> getTranslations() {
        translations.put(null,'');
        return translations;
    }

	public static Map<String, Object> getByLanguage(String language) {
		if (String.isBlank(language)) {
			return getDefaultLanguage();
		}

		if (language.contains('_')) {
			language = language.split('_')[0];
		}

		language = language.toLowerCase();

		if ([SELECT COUNT() FROM StaticResource WHERE Name like :('%translations_' + language)] == 0) {
			return getDefaultLanguage();
		}

		StaticResource resx = [SELECT Id, Body FROM StaticResource WHERE Name like :('%translations_' + language) LIMIT 1];

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(resx.Body.toString().trim().replace('\uFEFF', ''));

		return result;
	}

	public static Map<String, Object> getDefaultLanguage() {
		StaticResource defaultResx = [SELECT Id, Body FROM StaticResource WHERE Name like '%translations_en' LIMIT 1];
		return (Map<String, Object>)JSON.deserializeUntyped(defaultResx.Body.toString());
	}

    private void loadTranslations() {
        translations = new Map<String, String>();

        if (!StringUtils.isEmpty(language)) {
            for(Translation__c translation : Translation__c.getAll().values()){
                if (context.equalsIgnoreCase(translation.Context__c) || 'ALL'.equalsIgnoreCase(translation.Context__c)) {
                    Object o = translation.get(language + '__c');
                    String translatedContent = String.valueOf(o);

                    translations.put(translation.Name, translatedContent);
                }
            }
        }
        translations.put(null,'');
    }
}