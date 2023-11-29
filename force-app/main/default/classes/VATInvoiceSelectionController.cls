public with sharing class VATInvoiceSelectionController {
    private Map<String, List<SelectOption>> reportsPerLanguage;
    private Map<String, ReportMappings> reportMappings = new Map<String, ReportMappings>();
    public Map<String, String> translations { get; private set; }

    public List<SelectOption> languages { get; private set; }
    public String selectedLanguage { get; set; }
    public List<SelectOption> reports { get; private set; }
    public String selectedReport { get; set; }
    public Boolean requiredAttachmentCreation { get; set; }
    public String openUrl { get; private set; }
    public String errorMessage { get; private set; }
    public Boolean showedReportFormatSelection { get; private set; }
    public List<SelectOption> currencies { get; private set; }
    public String selectedCurrency { get; set; }
    public List<SelectOption> groupingOptions { get; private set; }
    public String selectedGroupingOption { get; set; }
    private String vatInvoiceId;

    public VATInvoiceSelectionController() {
        currencies = new List<SelectOption>();
        currencies.add(new SelectOption('USD', 'USD'));
        selectedCurrency = 'USD';

        String localCurrency = Site_Custom_Settings__c.getOrgDefaults().Local_Currency__c;
        if (!StringUtils.isEmpty(localCurrency)) {
            currencies.add(new SelectOption(localCurrency, localCurrency));
            selectedCurrency = localCurrency;
        }

        errorMessage = null;
        showedReportFormatSelection = false;
        requiredAttachmentCreation = false;
        showedReportFormatSelection = false;
        selectedLanguage = UserInfo.getLanguage();

        initializeTranslation();
        readParameters();
        buildLanguagesPerReportMappings();
        setUpReportOptions();
        selectedGroupingOption = 'group_by_forwarding';
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('InvoiceSelection', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    public void setUpReportOptions() {
        groupingOptions = new List<SelectOption>();
        if (!StringUtils.isEmpty(selectedReport)) {
            if (selectedReport.contains('_combined')) {
                groupingOptions.add(new SelectOption(Constants.GROUPED_BY_FORWARDING_KEY, translations.get(Constants.GROUPED_BY_FORWARDING_KEY)));
                groupingOptions.add(new SelectOption(Constants.GROUPED_BY_CATEGORY_KEY, translations.get(Constants.GROUPED_BY_CATEGORY_KEY)));
                groupingOptions.add(new SelectOption(Constants.SUMMARY_KEY, translations.get(Constants.SUMMARY_KEY)));
            } else {
                groupingOptions.add(new SelectOption(Constants.GROUPED_BY_INVOICING_KEY, translations.get(Constants.GROUPED_BY_INVOICING_KEY)));
            }
        }
    }

    private void readParameters() {
        vatInvoiceId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
    }

    /**
     * Which reports are available for a language?
     * Key: language
     * Reference: list of available reports
     *
     */
    private void buildLanguagesPerReportMappings() {
        List<ReportMappings> mappings = setUpReportMappings();
        reportsPerLanguage = new Map<String, List<SelectOption>>();
        selectedLanguage = 'vi';

        for (ReportMappings mapping : mappings) {
            reportMappings.put(mapping.id, mapping);
            if (reportsPerLanguage.containsKey(mapping.language)) {
                reportsPerLanguage.get(mapping.language).add(new SelectOption(mapping.id, mapping.reportDisplayedName));
            } else {
                List<SelectOption> report = new List<SelectOption>();
                report.add(new SelectOption(mapping.id, mapping.reportDisplayedName));
                reportsPerLanguage.put(mapping.language, report);
            }
        }

        reports = reportsPerLanguage.get(selectedLanguage);
        if (reports != null && !reports.isEmpty()) {
            selectedReport = reports.get(0).getValue();
        }
    }

    private List<ReportMappings> setUpReportMappings() {
        List<ReportMappings> mappings = new List<ReportMappings>();

        languages = new List<SelectOption>();
        languages.add(new SelectOption('vi', 'Tiếng Việt'));
        languages.add(new SelectOption('kh', 'ភាសាខ្មែរ'));
        setUpInvoices(mappings);

        return mappings;
    }

    private void setUpInvoices(List<ReportMappings> mappings) {
        Site_Custom_Settings__c settings = Site_Custom_Settings__c.getOrgDefaults();
        Integer numberOfTemplateSet = 15;
        for (Integer index = 1; index <= numberOfTemplateSet; index++) {
            String templateSetEnable = Constants.NAMESPACE + 'EnableInvoiceTemplateSet' + index + '__c';
            if (settings.get(templateSetEnable) == true) {
                String templateName = Constants.NAMESPACE + 'InvoiceTemplateSet' + index + 'Name__c';
                String invoiceNameSuffix = (String) settings.get(templateName);

                invoiceNameSuffix = (StringUtils.isEmpty(invoiceNameSuffix) ? '' : invoiceNameSuffix);

                mappings.add(new ReportMappings('vi_official_invoice_' + index, Constants.IV_INVOICE, translations.get('OfficialInvoice') + invoiceNameSuffix, 'page_InvoiceVI_Official', 'vi', String.valueOf(index)));
                mappings.add(new ReportMappings('vi_preprinted_invoice_' + index, Constants.IV_INVOICE_WITHOUT_TAX, translations.get('PreprintedInvoice') + invoiceNameSuffix, 'page_PrePrintedInvoice', 'vi', String.valueOf(index)));
                mappings.add(new ReportMappings('vi_drafttax_invoice_' + index, Constants.IV_INVOICE, translations.get('DraftTaxInvoice') + invoiceNameSuffix, 'page_DraftTaxInvoice', 'vi', String.valueOf(index)));
                mappings.add(new ReportMappings('vi_official_invoice_combined_' + index, Constants.IV_INVOICE, translations.get('OfficialInvoiceCombined') + invoiceNameSuffix, 'page_InvoiceVI_Official_Combined', 'vi', String.valueOf(index)));
                mappings.add(new ReportMappings('vi_preprinted_invoice_combined_' + index, Constants.IV_INVOICE_WITHOUT_TAX, translations.get('PreprintedInvoiceCombined') + invoiceNameSuffix, 'page_PrePrintedInvoice_Combined', 'vi', String.valueOf(index)));
                mappings.add(new ReportMappings('vi_drafttax_invoice_combined_' + index, Constants.IV_INVOICE, translations.get('DraftTaxInvoiceCombined') + invoiceNameSuffix, 'page_DraftTaxInvoice_Combined', 'vi', String.valueOf(index)));

                mappings.add(new ReportMappings('kh_official_invoice_' + index, Constants.IV_INVOICE, translations.get('OfficialInvoice') + invoiceNameSuffix, 'page_InvoiceKH_Official', 'kh', String.valueOf(index)));
                mappings.add(new ReportMappings('kh_preprinted_invoice_' + index, Constants.IV_INVOICE_WITHOUT_TAX, translations.get('PreprintedInvoice') + invoiceNameSuffix, 'page_PrePrintedInvoiceKH', 'kh', String.valueOf(index)));
                mappings.add(new ReportMappings('kh_drafttax_invoice_' + index, Constants.IV_INVOICE, translations.get('DraftTaxInvoice') + invoiceNameSuffix, 'page_DraftTaxInvoiceKH', 'kh', String.valueOf(index)));
                mappings.add(new ReportMappings('kh_official_invoice_combined_' + index, Constants.IV_INVOICE, translations.get('OfficialInvoiceCombined') + invoiceNameSuffix, 'page_InvoiceKH_Official_Combined', 'kh', String.valueOf(index)));
                mappings.add(new ReportMappings('kh_preprinted_invoice_combined_' + index, Constants.IV_INVOICE_WITHOUT_TAX, translations.get('PreprintedInvoiceCombined') + invoiceNameSuffix, 'page_PrePrintedInvoiceKH_Combined', 'kh', String.valueOf(index)));
                mappings.add(new ReportMappings('kh_drafttax_invoice_combined_' + index, Constants.IV_INVOICE, translations.get('DraftTaxInvoiceCombined') + invoiceNameSuffix, 'page_DraftTaxInvoiceKH_Combined', 'kh', String.valueOf(index)));
            }
        }
    }

    public void refreshReportList() {
        reports = reportsPerLanguage.get(selectedLanguage);

        if (!reports.isEmpty()) {
            selectedReport = reports.get(0).getValue();
        }
    }

    public void generateReport() {
        errorMessage = null;

        if (StringUtils.isEmpty(selectedReport)) {
            errorMessage = translations.get('no_report_selection');
            if (StringUtils.isEmpty(errorMessage)) {
                errorMessage = 'You have not selected any report or no report is applicable.';
            }
        } else {
            ReportMappings mapping = reportMappings.get(selectedReport);
            if (requiredAttachmentCreation && PermissionValidationUtil.isCreatableAttachment()) {
                String attachmentId = createAttachment(vatInvoiceId, mapping.reportDisplayedName, mapping.reportPage, selectedGroupingOption, mapping.templateSet, selectedCurrency, selectedLanguage);
                openUrl = '/servlet/servlet.FileDownload?file=' + attachmentId;
            } else {
                String reportPage = mapping.reportPage;
                openUrl = '/apex/' + Constants.NAMESPACE + reportPage + '?' + Constants.REQUEST_ID + '='
                        + vatInvoiceId + '&' + Constants.REQUEST_GROUPTING_OPTION + '=' + selectedGroupingOption
                        + '&' + Constants.REQUEST_INVOICE_TEMPLATE_SET + '=' + mapping.templateSet
                        + '&' + Constants.REQUEST_LANGUAGE + '=' + selectedLanguage
                        + '&' + Constants.REQUEST_CURRENCY + '=' + selectedCurrency
                        + '&reportpage=' + Constants.NAMESPACE + reportPage
                    ;
            }
        }
    }

    private static String createAttachment(Id id, String reportDisplayedName,
            String reportPage, String groupingOption, String templateSet, String selectedCurrency, String selectedLanguage) {
        if (PermissionValidationUtil.isCreatableAttachment()) {
            String reportPageFull = Constants.NAMESPACE + reportPage;
            String url = '/apex/' + (String.isBlank(Site_Custom_Settings__c.getOrgDefaults().CustomInvoiceTemplate__c) ? reportPageFull : Site_Custom_Settings__c.getOrgDefaults().CustomInvoiceTemplate__c);
            PageReference pageRef = new PageReference(url);
            pageRef.getParameters().put(Constants.REQUEST_ID, id);
            pageRef.getParameters().put(Constants.REQUEST_GROUPTING_OPTION, groupingOption);
            pageRef.getParameters().put(Constants.REQUEST_INVOICE_TEMPLATE_SET, templateSet);
            pageRef.getParameters().put(Constants.REQUEST_CURRENCY, selectedCurrency);
            pageRef.getParameters().put(Constants.REQUEST_LANGUAGE, selectedLanguage);
            pageRef.getParameters().put('reportpage', reportPageFull);

            Attachment attachment = new Attachment();
            attachment.Name = EncodingUtil.urlDecode(reportDisplayedName + '.pdf', 'UTF-8');

            String attachmentId = null;
            if (!Test.IsRunningTest()) {
                attachment.Body = pageRef.getContentAsPDF();
                attachment.ParentId = id;
                FlsService.doInsert(attachment);

                attachmentId = attachment.Id;
            }

            return attachmentId;
        }
        return null;
    }

    public class ReportMappings {
        public String id { get; private set; }
        public String reportName { get; private set; }
        public String reportDisplayedName { get; private set; }
        public String language { get; private set; }
        public String reportPage { get; private set; }
        public String templateSet { get; set; }

        public ReportMappings(String id, String reportName, String reportDisplayedName, String reportPage, String language,
                String templateSet) {
            this.id = id;
            this.reportName = reportName;
            this.reportDisplayedName = reportDisplayedName;
            this.reportPage = reportPage;
            this.language = language;
            this.templateSet = templateSet;
        }
    }
}