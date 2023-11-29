public class WMS_InvoiceSelectionController {
	@AuraEnabled
    public static DisplayWrapper initDisplay(String workorderId, String language, String printType){
        if(String.isBlank(language)){
           language =  UserInfo.getLanguage().substringBefore('_');
        }
        DisplayWrapper resultDisplay = new DisplayWrapper(language, printType);
        resultDisplay.customerOptions = getCustommerOptions(workorderId, printType, language);
        resultDisplay.language = language;
        return resultDisplay;
    }
    @AuraEnabled
    public static Map<String, String > getTranslationMap(){
        String langCode = UserInfo.getLanguage();
        Map<String, Object> translate = TranslationService.getByLanguage(langCode.substringBefore('_'));
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('wms')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
    @AuraEnabled
    public static void createAttatchment(String recordId, String customerId, String printType, String language){
        PageReference pdf_file = Page.WMS_DebitCreditPDF;
        pdf_file.getParameters().put('workOrderId', recordId);
        pdf_file.getParameters().put('printType', printType);
        pdf_file.getParameters().put('language', language);
        pdf_file.getParameters().put('customerId', customerId);
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('wms')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        String currencyName = printType.substringAfter('_');
        if(currencyName == 'LOCAL'){
            currencyName = 'VND';
        }
        String namefile = 'Credit Note';
        if(printType.contains('DEBIT')){
            namefile = 'Debit Note';
        }
        /*language = 'English';
        if(language == 'vi'){
            language = 'VietNamese';
        }*/
        String languaName='';
        for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
            if(value.getValue().contains(language)) {
                languaName = value.getLabel();
                break;
            }
        }
        String attachName = 'WMS ' + namefile + '-' + languaName +'-' + currencyName + ' v';
        String attachNameSearch = attachName + '%';
        // get exist file Name
        List<Attachment> attachments = [SELECT Id, Name, ParentId 
                                        FROM Attachment 
                                        WHERE ParentId =: recordId 
                                        AND Name LIKE : attachNameSearch 
                                        ORDER BY CreatedDate DESC LIMIT 1];
        if(attachments.isEmpty()){
            attachName += '1.1';
        }else{
            String attachNameExist = attachments[0].Name;
            attachNameExist = attachNameExist.substringAfter(attachName);
            attachNameExist = attachNameExist.substringBefore('.pdf');
            Decimal versionNumber = Decimal.valueOf(attachNameExist);
            versionNumber += 0.1;
            attachName += String.valueOf(versionNumber);
        }
        Attachment attach = new Attachment();
        Blob body;
        attach.Name = attachName + '.pdf'; 
        attach.IsPrivate = false;
        attach.ParentId = recordId;
        if(!Test.isRunningTest()){
            body = pdf_file.getContentAsPDF();
            attach.Body = body;
			FlsService.doInsert(attach);
        }
    }

    public static List<SeletionWrapper>  getCustommerOptions( String workorderId, String printType, String language){
        List<clofor_com_cfs__Billing__c> listBilling = [SELECT Id, Name, InvoiceTo__c, InvoiceTo__r.Name, PaymentTo__c, PaymentTo__R.Name FROM clofor_com_cfs__Billing__c WHERE WorkOrderID__c =: workorderId ];
        List<SeletionWrapper> listCustomer = new List<SeletionWrapper>();
        Set<String> customerId = new Set<String>();
        for(clofor_com_cfs__Billing__c billing : listBilling){
            if(printType.contains('DEBIT')){
                if(billing.InvoiceTo__c != null){
                    customerId.add(billing.InvoiceTo__c);
                }
            }

            if(printType.contains('CREDIT')){
                
                if(billing.InvoiceTo__c != null){
                    customerId.add(billing.InvoiceTo__c);
                }
            }
        }

        // get custommer
        List<Account> custommerList = [SELECT Id, Name, EnglishCompanyName__c FROM Account WHERE Id IN: customerId];
        if(!custommerList.isEmpty()){
            for(Account acc : custommerList){
                SeletionWrapper option = new SeletionWrapper();
                option.value = acc.Id;
                option.label = acc.EnglishCompanyName__c;
                if(language == 'vi'){
                    option.label = acc.Name;
                }
                listCustomer.add(option);
            }
            
        }
        
        return listCustomer;

    }
	public class DisplayWrapper{
        @AuraEnabled
        public String language{get; set;}
        public String printType{get; set;}
        @AuraEnabled
        public List<SeletionWrapper> customerOptions{get; set;}
        @AuraEnabled
        public List<SeletionWrapper> languageOptions{get; set;}
        @AuraEnabled
        public Map<String, String> translationMap{get; set;}
        @AuraEnabled
        public List<SeletionWrapper> typePrintOptions{get; set;}

        public DisplayWrapper(String arglanguage, String argPrintType){
            this.language = arglanguage;
            this.printType = argPrintType;
            this.languageOptions = getLanguageOptions();
            this.translationMap = getTranslationMap();
            this.typePrintOptions = getTypePrintOptions();
        }
        private  List<SeletionWrapper> getLanguageOptions(){
            List<SeletionWrapper> languageOptions = new List<SeletionWrapper>();
            if(language == 'en'){
                languageOptions.add(new SeletionWrapper('English', 'en', true));
                languageOptions.add(new SeletionWrapper('Tiếng Việt', 'vi'));
            }
            if(language == 'vi'){
                languageOptions.add(new SeletionWrapper('English', 'en'));
                languageOptions.add(new SeletionWrapper('Tiếng Việt', 'vi', true));
            }
            
            
            return languageOptions;
        }
        
        private Map<String, String> getTranslationMap(){
            Map<String, Object> translate = TranslationService.getByLanguage(this.language);
            Map<String, String> translateMapResult = new Map<String, String>();
            for(String key : translate.keySet()){
                if(key.contains('wms_debitcredit')){
                    translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
                }
                
            }
            return translateMapResult;  
        }

        private List<SeletionWrapper> getTypePrintOptions(){
        List<SeletionWrapper> printOptions = new List<SeletionWrapper>();
        if( printType == 'DEBIT_LOCAL'){
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_LOCAL'), 'DEBIT_LOCAL', true));
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_USD'),'DEBIT_USD'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_LOCAL'), 'CREDIT_LOCAL'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_USD'),'CREDIT_USD'));

        }
        if(printType == 'DEBIT_USD'){
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_LOCAL'), 'DEBIT_LOCAL'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_USD'),'DEBIT_USD', true));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_LOCAL'), 'CREDIT_LOCAL'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_USD'),'CREDIT_USD'));

        }
        if( printType == 'CREDIT_LOCAL'){
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_LOCAL'), 'DEBIT_LOCAL'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_USD'),'DEBIT_USD'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_LOCAL'), 'CREDIT_LOCAL', true));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_USD'),'CREDIT_USD'));

        }
        if(printType == 'CREDIT_USD'){
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_LOCAL'), 'DEBIT_LOCAL'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_USD'),'DEBIT_USD'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_LOCAL'), 'CREDIT_LOCAL'));
            printOptions.add(new SeletionWrapper((String)translationMap.get('CREDIT_USD'),'CREDIT_USD', true));

        }
        
        return printOptions;
    }

    }
    public class SeletionWrapper{
        @AuraEnabled
        public String label{get; set;}
        @AuraEnabled
        public String value{get; set;}
        @AuraEnabled
        public Boolean selected{get; set;}
        public SeletionWrapper(){
        }
        public SeletionWrapper(String arglabel, String argValue){
            this.label = arglabel;
            this.value = argValue;
            this.selected = false;
        }
        public SeletionWrapper( String arglabel, String argValue, Boolean argSelected){
            this.label = arglabel;
            this.value = argValue;
            this.selected = argSelected;
        }

    }
}