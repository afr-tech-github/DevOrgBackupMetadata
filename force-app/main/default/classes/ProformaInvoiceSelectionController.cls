public with sharing class ProformaInvoiceSelectionController {
  public Map<String, String> translations { get; set; }
  public String language { get; set; }
  public String docType { get; set; }
  public String id { get; set; }
  public String bankType { get; set; }
  public String fileType { get; set; }
  public String attachName { get; set; }
  public Boolean showFooter{get;set;}

  public ProformaInvoiceSelectionController() {
    language = 'en';
    docType = 'debit';
    bankType = 'local1';
    fileType = 'pdf';
    showFooter =  false;
    id = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    Set<String> languagesAvailable = new Set<String>{
      'en',
      'vi',
      'ko',
      'ja',
      'zh'
    };
    for (String la : languagesAvailable) {
      if (UserInfo.getLanguage().contains(la)) {
        language = la;
      }
    }
    translations = getTranslations();
  }
  public void generateAttachmentFile() {
    PageReference pageTo;
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
  public List<SelectOption> getBankOptions(){
    clofor_com_cfs__Site_Custom_Settings__c banks = [Select clofor_com_cfs__LocalCurrencyBankAccountShortName1__c,
                                                        clofor_com_cfs__LocalCurrencyBankAccountShortName2__c,
                                                        clofor_com_cfs__LocalCurrencyBankAccountShortName3__c,
                                                        clofor_com_cfs__LocalCurrencyBankAccountShortName4__c,
                                                        clofor_com_cfs__LocalCurrencyBankAccountShortName5__c,
                                                        clofor_com_cfs__FCYBankAccountShortName1__c,
                                                        clofor_com_cfs__FCYBankAccountShortName2__c,
                                                        clofor_com_cfs__FCYBankAccountShortName3__c,
                                                        clofor_com_cfs__FCYBankAccountShortName4__c,
                                                        clofor_com_cfs__FCYBankAccountShortName5__c
                                                        From clofor_com_cfs__Site_Custom_Settings__c limit 1];
    List<SelectOption> bankOptions = new List<SelectOption>();
    // value, title
    if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName1__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName1__c != ''){
        bankOptions.add(new SelectOption('local1', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName1__c));
    }
    if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName2__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName2__c != ''){
        bankOptions.add(new SelectOption('local2', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName2__c));
    }
    if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName3__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName3__c != ''){
        bankOptions.add(new SelectOption('local3', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName3__c));
    }
    if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName4__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName4__c != ''){
        bankOptions.add(new SelectOption('local4', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName4__c));
    }
    if(banks.clofor_com_cfs__LocalCurrencyBankAccountShortName5__c != null && banks.clofor_com_cfs__LocalCurrencyBankAccountShortName5__c != ''){
        bankOptions.add(new SelectOption('local5', banks.clofor_com_cfs__LocalCurrencyBankAccountShortName5__c));
    }
    if(banks.clofor_com_cfs__FCYBankAccountShortName1__c != null && banks.clofor_com_cfs__FCYBankAccountShortName1__c != ''){
        bankOptions.add(new SelectOption('foreign1', banks.clofor_com_cfs__FCYBankAccountShortName1__c));
    }        
    if(banks.clofor_com_cfs__FCYBankAccountShortName2__c != null && banks.clofor_com_cfs__FCYBankAccountShortName2__c != ''){
        bankOptions.add(new SelectOption('foreign2', banks.clofor_com_cfs__FCYBankAccountShortName2__c));
    }
    if(banks.clofor_com_cfs__FCYBankAccountShortName3__c != null && banks.clofor_com_cfs__FCYBankAccountShortName3__c != ''){
      bankOptions.add(new SelectOption('foreign3', banks.clofor_com_cfs__FCYBankAccountShortName3__c));
    }
    if(banks.clofor_com_cfs__FCYBankAccountShortName4__c != null && banks.clofor_com_cfs__FCYBankAccountShortName4__c != ''){
        bankOptions.add(new SelectOption('foreign4', banks.clofor_com_cfs__FCYBankAccountShortName4__c));
    }
    if(banks.clofor_com_cfs__FCYBankAccountShortName5__c != null && banks.clofor_com_cfs__FCYBankAccountShortName5__c != ''){
        bankOptions.add(new SelectOption('foreign5', banks.clofor_com_cfs__FCYBankAccountShortName5__c));
    }
    return bankOptions;
  }
  public PageReference closePopupDialog() {
    PageReference page = new PageReference('/'+id);
    page.setRedirect(true);
    return page;
  }
}