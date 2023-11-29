public with sharing class FMS_VATInvoiceSelectionController {
	public Map<String, String> translations{get; set;}
	public DisplayWrapper resultDisplay{get; set;}
	private String recVATTypeName{get; set;}
	private String currentVATId{get; set;}
	public String language{get; set;}
	public String invoiceType{get; set;}
	public Boolean requiredAttachmentCreation{get; set;}
	public String currencyType{get; set;}
	public String groupingType{get;set;}
	private static Site_Custom_Settings__c customSetting;
	public FMS_VATInvoiceSelectionController() {
		requiredAttachmentCreation = false;
		translations = new Map<String, String>();
		translations = getTranslationMap();
		customSetting = Site_Custom_Settings__c.getOrgDefaults();
		currentVATId = ApexPages.currentPage().getParameters().get('invoiceId');
		language = UserInfo.getLanguage().substringBefore('_');
		VAT_INVOICE__c invoice =[SELECT ID, RecordType.DeveloperName FROM VAT_INVOICE__c WHERE id=: currentVATId];
       	recVATTypeName = '';
       	if(invoice.RecordType.DeveloperName == 'CloWMSVATInvoice' ){
       		recVATTypeName = 'WMS';
       	}
       	if(invoice.RecordType.DeveloperName == 'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY' ){
       		recVATTypeName = 'FMS';
       	}
       	if(invoice.RecordType.DeveloperName == 'FMSTMSWMSVATInvoice'){
       		recVATTypeName = 'FMS-WMS';
       	}
       	invoiceType = 'DRAFT_INVOICE';
        resultDisplay = new DisplayWrapper(language, invoiceType, recVATTypeName);

	}
	public void refreshResultDisplay(){
		resultDisplay = new DisplayWrapper(language, invoiceType, recVATTypeName);
	}
	public Map<String,String> getTranslationMap(){
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
    public PageReference generateInvoice(){
    	PageReference pageInvoice = Page.WMS_VATInvoicePDF;
        if(invoiceType.contains('DEBIT')){
            pageInvoice = Page.WMS_VATInvoiceDebitPDF;
        }
    	pageInvoice.getParameters().put('invoiceId', currentVATId);
    	pageInvoice.getParameters().put('invoiceType', invoiceType);
    	pageInvoice.getParameters().put('groupingType', groupingType);
    	pageInvoice.getParameters().put('currencyType', currencyType);
    	pageInvoice.getParameters().put('language', language);
    	if(requiredAttachmentCreation){
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
	                                        WHERE ParentId =: currentVATId 
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
	        attach.ParentId = currentVATId;
	        if(!Test.isRunningTest()){
	            body = pageInvoice.getContentAsPDF();
	            attach.Body = body;
	            FlsService.doInsert(attach);
	        }
    	}
    	pageInvoice.setRedirect(true);

    	return pageInvoice;
    }
	public class DisplayWrapper{
        public String companyShortName{get; set;}
        public String language{get; set;}
        public String invoiceType{get; set;}
        public String recVATTypeName{get; set;}
        public List<SelectOption> invoiceTypeOptions{get; set;}
        public List<SelectOption> languageOptions{get; set;}
        public Map<String, String> translationMap{get; set;}
        public List<SelectOption> groupingTypeOptions{get; set;}
        public List<SelectOption> currencyTypeOptions{get; set;}

        public DisplayWrapper(String arglanguage, String argInvoiceType, String argRecVATTypeName){
        	this.companyShortName = Site_Custom_Settings__c.getOrgDefaults().ShortCompanyName__c;
        	this.recVATTypeName = argRecVATTypeName;
            this.language = arglanguage;
            this.invoiceType = argInvoiceType;
            this.translationMap = getTranslationMap();
            this.languageOptions = getLanguageOptions();
            this.invoiceTypeOptions = getInvoiceTypeOptions();
            this.groupingTypeOptions = getGroupingTypeOptions();
            this.currencyTypeOptions = getCurrencyTypeOptions();
        }
        private  List<SelectOption> getLanguageOptions(){
            List<SelectOption> languageOptions = new List<SelectOption>();
            languageOptions.add(new SelectOption('en', 'English'));
	        languageOptions.add(new SelectOption('ja', '日本語'));
	        languageOptions.add(new SelectOption('vi', 'Tiếng Việt'));
	        languageOptions.add(new SelectOption('ko', '한국어'));
	        languageOptions.add(new SelectOption('zh', '中文'));
            return languageOptions;
        }
        
        private Map<String, String> getTranslationMap(){
            Map<String, Object> translate = TranslationService.getByLanguage(this.language);
            Map<String, String> translateMapResult = new Map<String, String>();
            for(String key : translate.keySet()){
                if(key.contains('wms')){
                    translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
                }
                
            }
            return translateMapResult;  
        }

        private List<SelectOption> getInvoiceTypeOptions(){
	        List<SelectOption> invoiceOptions = new List<SelectOption>();
	        invoiceOptions.add(new SelectOption('DRAFT_INVOICE',(String)translationMap.get('DRAFT_INVOICE') + ' - ' + companyShortName));
	        invoiceOptions.add(new SelectOption('DRAFT_INVOICE_COMBINED',(String)translationMap.get('DRAFT_INVOICE_COMBINED') + ' - ' + companyShortName));
	        invoiceOptions.add(new SelectOption('ORIGIN_INVOICE', (String)translationMap.get('ORIGIN_INVOICE') + ' - ' + companyShortName));
	        invoiceOptions.add(new SelectOption('ORIGIN_INVOICE_COMBINED', (String)translationMap.get('ORIGIN_INVOICE_COMBINED') + ' - ' + companyShortName));
	        invoiceOptions.add(new SelectOption('DEBIT_INVOICE',(String)translationMap.get('DEBIT_INVOICE') + ' - ' + companyShortName));
	        invoiceOptions.add(new SelectOption('DEBIT_INVOICE_COMBINED',(String)translationMap.get('DEBIT_INVOICE_COMBINED') + ' - ' + companyShortName));
	        
	        return invoiceOptions;
	    }

	    private List<SelectOption> getGroupingTypeOptions(){
	    	List<SelectOption> groupingOptions = new List<SelectOption>();
	    	if(invoiceType.contains('COMBINED')){
	    		if(this.recVATTypeName == 'WMS'){
	    			groupingOptions.add(new SelectOption('GROUPED_BY_WORKORDER', (String)translationMap.get('GROUPED_BY_WORKORDER')));
	    		}
	    		if(this.recVATTypeName == 'FMS'){
	    			groupingOptions.add(new SelectOption('GROUPED_BY_FORWARDING', (String)translationMap.get('GROUPED_BY_FORWARDING')));
	    		}

	    		if(this.recVATTypeName == 'FMS-WMS'){
	    			groupingOptions.add(new SelectOption('GROUPED_BY_FORWARDING', (String)translationMap.get('GROUPED_BY_SO_WO')));
	    		}

	    		groupingOptions.add(new SelectOption('GROUP_BY_CATEGORY', (String)translationMap.get('GROUP_BY_CATEGORY')));
	    		groupingOptions.add(new SelectOption('GROUP_SUMMARY', (String)translationMap.get('GROUP_SUMMARY')));
	    	}else{
	    		groupingOptions.add(new SelectOption('SINGLE_INVOICE', (String)translationMap.get('SINGLE_INVOICE')));
	    	}
	    	return groupingOptions;
	    }

	    private List<SelectOption> getCurrencyTypeOptions(){
	    	List<SelectOption> currencyOptions = new List<SelectOption>();
	    	currencyOptions.add(new SelectOption('VND', 'VND'));
	    	currencyOptions.add(new SelectOption('USD', 'USD'));
	    	return currencyOptions;
	    }

    }
	
}