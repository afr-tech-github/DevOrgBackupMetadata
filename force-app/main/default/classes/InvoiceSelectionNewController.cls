public with sharing class InvoiceSelectionNewController {
    public Map<String, String> translations{get; set;}
    public String language{get; set;}
    public String docType{get; set;}
    public Boolean requiredAttachmentCreation{get; set;}
    public Boolean isTax{get; set;}
    public String currencyType{get; set;}
    public String customerId{get;set;}
    public String shipmentId{get;set;}
    private static Site_Custom_Settings__c customSetting;
    public String bankType{get;set;}
    public String templateType{get;set;}
    public String fileType{get;set;}
    public String attachName{get;set;}
    

    public InvoiceSelectionNewController() {
        language = 'en';
        docType = 'debit';
        currencyType = 'Both';
        bankType = 'local1';
        templateType = 'official';
        fileType = 'pdf';
        requiredAttachmentCreation = false;
        isTax = true;
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
        Set<String> languagesAvailable = new Set<String>{'en','vi','ko','ja','zh'};
        for(String la : languagesAvailable){
            if(UserInfo.getLanguage().contains(la)){
                language = la;
            }
        }
        translations = getTranslations();

    }
    
    public PageReference closePopupDialog() {
        PageReference page = new PageReference('/'+shipmentId);
        page.setRedirect(true);
        return page;
    }
    
    public void generateAttachmentFile(){
        PageReference pageTo;
        if(fileType == 'pdf'){
           pageTo = Page.page_InvoicePrint; 
        }else{
            pageTo = Page.page_InvoicePrintExcel; 
        }
        pageTo.getParameters().put('shipmentId',shipmentId);
        pageTo.getParameters().put('customerId',customerId);
        pageTo.getParameters().put('typeDoc',docType);
        pageTo.getParameters().put('curr',currencyType);
        pageTo.getParameters().put('language',language);
        pageTo.getParameters().put('bankType', bankType);
        pageTo.getParameters().put('templateType', templateType);
        
        pageTo.setRedirect(true);
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('wms')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        String namefile = translateMapResult.get(docType);
        
        String languaName='';
        for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
            if(value.getValue().contains(language)) {
                languaName = value.getLabel();
                break;
            }
        }
        Account customer = [Select Name, EnglishCompanyName__c from Account where Id =: customerId];
        String customerName = language == 'en'? customer.EnglishCompanyName__c : customer.Name;
        attachName = customerName + '-' + namefile + '-' + currencyType + '-' + languaName + ' v';
        String attachNameSearch = attachName + '%';
        // get exist file Name
        List<Attachment> attachments = [SELECT Id, Name, ParentId 
                                        FROM Attachment 
                                        WHERE ParentId =: shipmentId 
                                        AND Name LIKE : attachNameSearch 
                                        ORDER BY CreatedDate DESC LIMIT 1];
        if(attachments.isEmpty()){
            attachName += '1.1';
        }else{
            String attachNameExist = attachments[0].Name;
            attachNameExist = attachNameExist.substringAfter(attachName);
            attachNameExist = attachNameExist.substringBefore('.pdf');
            attachNameExist = attachNameExist.substringBefore('.xls');
            Decimal versionNumber = Decimal.valueOf(attachNameExist);
            versionNumber += 0.1;
            attachName += String.valueOf(versionNumber);
        }
        if(fileType != 'pdf'){
            pageTo.getParameters().put('contentType', 'application/vnd.ms-excel#' + attachName + '.xls'); 
        }
        if(requiredAttachmentCreation){
 
            Attachment attach = new Attachment();
            Blob body;
            attach.Name = fileType == 'pdf'? attachName + '.pdf' : attachName + '.xls'; 
            attach.IsPrivate = false;
            attach.ParentId = shipmentId;
            if(!Test.isRunningTest()){
                body = fileType == 'pdf'? pageTo.getContentAsPDF() : pageTo.getContent();
                attach.Body = body;
                FlsService.doInsert(attach);
            }
        }
        
    }
    
    public void refreshCustomerOption(){

    }
    public List<SelectOption> getCustomerList(){
        List<SelectOption> options = new List<SelectOption>();
        List<AnkenMeisai__c> bills = [SELECT Id, Seikyusaki__c, Seikyusaki__r.Name, PaymentTo__c, PaymentTo__r.Name 
                                        FROM AnkenMeisai__c
                                        WHERE Anken__c =: shipmentId];
        Set<Id> customerIds = new Set<Id>();

        for(AnkenMeisai__c bill: bills){
            
            if(docType == 'invoice' || docType == 'debit'){
                if(!String.isBlank(bill.Seikyusaki__c) && !customerIds.contains(bill.Seikyusaki__c)){
                    options.add(new SelectOption(bill.Seikyusaki__c, bill.Seikyusaki__r.Name));
                }
                customerIds.add(bill.Seikyusaki__c);
            }
            if(docType == 'credit'){
                if(!String.isBlank(bill.PaymentTo__c) && !customerIds.contains(bill.PaymentTo__c)){
                    options.add(new SelectOption(bill.PaymentTo__c, bill.PaymentTo__r.Name));
                }
                customerIds.add(bill.PaymentTo__c);
            }
        }
        return options;
    }
    public List<SelectOption> getFileTypeOptions(){

        List<SelectOption> fileTypes = new List<SelectOption>();
        fileTypes.add(new SelectOption('pdf', 'PDF'));
        fileTypes.add(new SelectOption('excel', 'Excel'));
        return fileTypes;
    }
    public List<SelectOption> getLanguageOptions(){

        List<SelectOption> languageOptions = new List<SelectOption>();
        languageOptions.add(new SelectOption('en', 'English'));
        languageOptions.add(new SelectOption('ja', '日本語'));
        languageOptions.add(new SelectOption('vi', 'Tiếng Việt'));
        languageOptions.add(new SelectOption('ko', '한국어'));
        languageOptions.add(new SelectOption('zh', '中文'));
        return languageOptions;
    }

    public List<SelectOption> getTemplateOptions(){

        List<SelectOption> templateOptions = new List<SelectOption>();
        templateOptions.add(new SelectOption('official', 'Official'));
        templateOptions.add(new SelectOption('non_official', 'Non-Official'));
        return templateOptions;
    }
    
    private Map<String, String> getTranslations(){
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('wms')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult;  
    }

    public List<SelectOption> getPrintOptions(){
        List<SelectOption> invoiceOptions = new List<SelectOption>();
        invoiceOptions.add(new SelectOption('debit','Debit'));
        invoiceOptions.add(new SelectOption('invoice','Invoice'));
        //invoiceOptions.add(new SelectOption('credit','Credit'));
        return invoiceOptions;
    }

    public List<SelectOption> getCurrencyTypeOptions(){
        List<SelectOption> currencyOptions = new List<SelectOption>();
        currencyOptions.add(new SelectOption('Local', 'Local'));
        currencyOptions.add(new SelectOption('USD', 'USD'));
        currencyOptions.add(new SelectOption('Both', 'Both'));
        return currencyOptions;
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
}