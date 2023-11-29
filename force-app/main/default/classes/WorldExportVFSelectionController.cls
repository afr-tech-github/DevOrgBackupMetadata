public with sharing class WorldExportVFSelectionController {
    public Boolean showFooter{get;set;}
    public String fileType { get; set; }
    public String id { get; set; }
    public Map<String, String> translations { get; set; }
    public String language { get; set; }
    public WorldExportVFSelectionController() {
        showFooter =  false;
        fileType = 'pdf';
        language = 'en';
        id = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        translations = getTranslations();
    }

    private Map<String, String> getTranslations() {
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for (String key : translate.keySet()) {
          if (key.contains('wms')) {
            translateMapResult.put(
              key.substringAfter('.'),
              (String) translate.get(key)
            );
          }
        }
        return translateMapResult;
      }

    public void generateAttachmentFile(){
        PageReference pageTo;
    }

    public PageReference closePopupDialog() {
      PageReference page = new PageReference('/'+id);
      page.setRedirect(true);
      return page;
    }
}