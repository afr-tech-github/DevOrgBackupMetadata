public with sharing class WMS_VATSelectionController {
	@AuraEnabled
    public static DisplayWrapper initDisplay(String invoiceId, String language, String invoiceType){
        if(String.isBlank(language)){
        	language =  UserInfo.getLanguage().substringBefore('_');
        }
       	VAT_INVOICE__c invoice =[SELECT ID, RecordType.DeveloperName FROM VAT_INVOICE__c WHERE id=: invoiceId];
       	String recVATTypeName = '';
       	if(invoice.RecordType.DeveloperName == 'CloWMSVATInvoice' ){
       		recVATTypeName = 'WMS';
       	}
       	if(invoice.RecordType.DeveloperName == 'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY' ){
       		recVATTypeName = 'FMS';
       	}
       	if(invoice.RecordType.DeveloperName == 'FMSTMSWMSVATInvoice'){
       		recVATTypeName = 'FMS-WMS';
       	}
       
        DisplayWrapper resultDisplay = new DisplayWrapper(language, invoiceType, recVATTypeName);
        //resultDisplay.customerOptions = getCustommerOptions(workorderId, printType);
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
    public static void createAttatchment(String recordId, String invoiceType, String currencyType, String language, String groupingType){
        PageReference pdf_file = Page.WMS_VATInvoicePDF;
        if(invoiceType.contains('DEBIT')){
            pdf_file = Page.WMS_VATInvoiceDebitPDF;
        }
        
        pdf_file.getParameters().put('invoiceId', recordId);
        pdf_file.getParameters().put('invoiceType', invoiceType);
        pdf_file.getParameters().put('language', language);
        pdf_file.getParameters().put('currencyType', currencyType);
        pdf_file.getParameters().put('groupingType', groupingType);
        Map<String, Object> translate = TranslationService.getByLanguage(language);
            Map<String, String> translateMapResult = new Map<String, String>();
            for(String key : translate.keySet()){
                if(key.contains('wms')){
                    translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
                }
                
            }
            String namefile = translateMapResult.get(invoiceType);
            
            String languaName='';
            for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
                if(value.getValue().contains(language)) {
                    languaName = value.getLabel();
                    break;
                }
            }
            String attachName = namefile + '-' + languaName +'-' + currencyType + ' v';
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
	public class DisplayWrapper{
		@AuraEnabled
        public String companyShortName{get; set;}
        @AuraEnabled
        public String language{get; set;}
        @AuraEnabled
        public String invoiceType{get; set;}
        @AuraEnabled
        public String recVATTypeName{get; set;}
        @AuraEnabled
        public List<SeletionWrapper> invoiceTypeOptions{get; set;}
        @AuraEnabled
        public List<SeletionWrapper> languageOptions{get; set;}
        @AuraEnabled
        public Map<String, String> translationMap{get; set;}
        @AuraEnabled
        public List<SeletionWrapper> groupingTypeOptions{get; set;}
        //@AuraEnabled
        //public List<SeletionWrapper> groupingTypeOptions{get; set;}
        
        @AuraEnabled
        public List<SeletionWrapper> currencyTypeOptions{get; set;}

        public DisplayWrapper(String arglanguage, String argInvoiceType, String argRecVATTypeName){
        	this.companyShortName = Site_Custom_Settings__c.getOrgDefaults().ShortCompanyName__c;
        	this.recVATTypeName = argRecVATTypeName;
            this.language = arglanguage;
            this.invoiceType = argInvoiceType;
            this.languageOptions = getLanguageOptions();
            this.translationMap = getTranslationMap();
            this.invoiceTypeOptions = getInvoiceTypeOptions();
            this.groupingTypeOptions = getGroupingTypeOptions();
            this.currencyTypeOptions = getCurrencyTypeOptions();
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
                if(key.contains('wms_VATInvoice')){
                    translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
                }
                
            }
            return translateMapResult;  
        }

        private List<SeletionWrapper> getInvoiceTypeOptions(){
	        List<SeletionWrapper> invoiceOptions = new List<SeletionWrapper>();
	        if( invoiceType == 'DRAFT_INVOICE'){
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE'), 'DRAFT_INVOICE', true));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE_COMBINED'),'DRAFT_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE'), 'ORIGIN_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE_COMBINED'),'ORIGIN_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE'), 'DEBIT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE_COMBINED'),'DEBIT_INVOICE_COMBINED'));

	        }

	        if( invoiceType == 'DRAFT_INVOICE_COMBINED'){
	           	invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE'), 'DRAFT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE_COMBINED'),'DRAFT_INVOICE_COMBINED',true));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE'), 'ORIGIN_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE_COMBINED'),'ORIGIN_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE'), 'DEBIT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE_COMBINED'),'DEBIT_INVOICE_COMBINED'));

	        }
	        if( invoiceType == 'ORIGIN_INVOICE'){
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE'), 'DRAFT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE_COMBINED'),'DRAFT_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE'), 'ORIGIN_INVOICE',true));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE_COMBINED'),'ORIGIN_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE'), 'DEBIT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE_COMBINED'),'DEBIT_INVOICE_COMBINED'));

	        }
	        if( invoiceType == 'ORIGIN_INVOICE_COMBINED'){
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE'), 'DRAFT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE_COMBINED'),'DRAFT_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE'), 'ORIGIN_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE_COMBINED'),'ORIGIN_INVOICE_COMBINED',true));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE'), 'DEBIT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE_COMBINED'),'DEBIT_INVOICE_COMBINED'));

	        }
	        if( invoiceType == 'DEBIT_INVOICE'){
	           	invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE'), 'DRAFT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE_COMBINED'),'DRAFT_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE'), 'ORIGIN_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE_COMBINED'),'ORIGIN_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE'), 'DEBIT_INVOICE',true));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE_COMBINED'),'DEBIT_INVOICE_COMBINED'));
	        }

	        if( invoiceType == 'DEBIT_INVOICE_COMBINED'){
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE'), 'DRAFT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DRAFT_INVOICE_COMBINED'),'DRAFT_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE'), 'ORIGIN_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('ORIGIN_INVOICE_COMBINED'),'ORIGIN_INVOICE_COMBINED'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE'), 'DEBIT_INVOICE'));
	            invoiceOptions.add(new SeletionWrapper((String)translationMap.get('DEBIT_INVOICE_COMBINED'),'DEBIT_INVOICE_COMBINED',true));
	        }
	        
	        return invoiceOptions;
	    }

	    private List<SeletionWrapper> getGroupingTypeOptions(){
	    	List<SeletionWrapper> groupingOptions = new List<SeletionWrapper>();
	    	if(invoiceType.contains('COMBINED')){
	    		if(this.recVATTypeName == 'WMS'){
	    			groupingOptions.add(new SeletionWrapper((String)translationMap.get('GROUPED_BY_WORKORDER'),'GROUPED_BY_WORKORDER'));
	    		}
	    		if(this.recVATTypeName == 'FMS'){
	    			groupingOptions.add(new SeletionWrapper((String)translationMap.get('GROUPED_BY_FORWARDING'),'GROUPED_BY_FORWARDING'));
	    		}

	    		if(this.recVATTypeName == 'FMS-WMS'){
	    			groupingOptions.add(new SeletionWrapper((String)translationMap.get('GROUPED_BY_SO_WO'),'GROUPED_BY_FORWARDING'));
	    		}

	    		groupingOptions.add(new SeletionWrapper((String)translationMap.get('GROUP_BY_CATEGORY'),'GROUP_BY_CATEGORY'));
	    		groupingOptions.add(new SeletionWrapper((String)translationMap.get('GROUP_SUMMARY'),'GROUP_SUMMARY'));
	    	}else{
	    		groupingOptions.add(new SeletionWrapper((String)translationMap.get('SINGLE_INVOICE'),'SINGLE_INVOICE'));
	    	}
	    	return groupingOptions;
	    }

	    private List<SeletionWrapper> getCurrencyTypeOptions(){
	    	List<SeletionWrapper> currencyOptions = new List<SeletionWrapper>();
	    	currencyOptions.add(new SeletionWrapper('VND', 'VND'));
	    	currencyOptions.add(new SeletionWrapper('USD', 'USD'));
	    	return currencyOptions;
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