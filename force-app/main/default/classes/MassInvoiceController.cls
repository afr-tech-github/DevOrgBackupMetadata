/**
 * Created by khanhpham on 6/30/17.
 */

public with sharing class MassInvoiceController {
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
    public List<SelectOption> customers { get; private set; }
    public String selectedCustomerId { get; set; }
    public Boolean showCustomerSelection { get; private set; }
    public Boolean showedReportFormatSelection { get; private set; }
    public List<SelectOption> downloadDocumentTypes { get; private set; }
    public String selectedDownloadDocumentType { get; set; }

    private String consolId;
    private String repShipmentId;
    private List<String> shipmentIdList;
    private String reportType;
    private String vatInvoiceId;
    private Map<Id, SelectOption> mapCustomers = new Map<Id, SelectOption>();
    private Map<Id, SelectOption> mapPartnerCredit = new Map<Id, SelectOption>();
    private Map<Id, SelectOption> mapPartnerDebit = new Map<Id, SelectOption>();
    private Map<Id, String> invoiceTos = new Map<Id, String>();

    private Map<Id, SelectOption> mapCustomersVAT = new Map<Id, SelectOption>();

    public MassInvoiceController() {
        downloadDocumentTypes = new List<SelectOption>();
        downloadDocumentTypes.add(new SelectOption('pdf', 'PDF'));
        downloadDocumentTypes.add(new SelectOption('excel', 'Excel'));
        selectedDownloadDocumentType = 'pdf';
        showedReportFormatSelection = false;
        selectedLanguage = UserInfo.getLanguage();

        initializeTranslation();
        readParameters();
        loadShipmentOrders();
        loadCustomersAndPartners();
        buildLanguagesPerReportMappings();

        errorMessage = null;
        requiredAttachmentCreation = false;
        showedReportFormatSelection = false;
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('InvoiceSelection', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    private void readParameters() {
        reportType = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_REPORT_TYPE));
        consolId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
    }

    /**
     * Which reports are available for a language?
     * Key: language
     * Reference: list of available reports
     *
     */
    private void buildLanguagesPerReportMappings() {
        if (String.isBlank(repShipmentId)) {
            errorMessage = 'There is no SHIPMENT ORDER linked to this CONSOLIDATION';
            return;
        }

        String recordType = getRecordType(repShipmentId);
        if (!StringUtils.isEmpty(recordType)) {
            List<ReportMappings> mappings = setUpReportMappings();
            reportsPerLanguage = new Map<String, List<SelectOption>>();

            for (ReportMappings mapping : mappings) {
                if (StringUtils.isContainedInCommaSeparateString(mapping.recordTypes, recordType)) {
                    reportMappings.put(mapping.id, mapping);
                    if (reportsPerLanguage.containsKey(mapping.language)) {
                        reportsPerLanguage.get(mapping.language).add(new SelectOption(mapping.id, mapping.reportDisplayedName));
                    } else {
                        List<SelectOption> report = new List<SelectOption>();
                        report.add(new SelectOption(mapping.id, mapping.reportDisplayedName));
                        reportsPerLanguage.put(mapping.language, report);
                    }
                }
            }

            reports = reportsPerLanguage.get(selectedLanguage);
            if (reports == null) {
                selectedLanguage = languages.get(0).getValue();
                reports = reportsPerLanguage.get(selectedLanguage);
            }
            determineReportFormat();
        }
    }

    private String getRecordType(String recordId) {
        if (PermissionValidationUtil.isAccessibleHBL()) {
            CustomObject1__c hbl = [SELECT RecordTypeId FROM CustomObject1__c WHERE Id = :recordId];
            String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, hbl.RecordTypeId);

            return recordType;
        }
        return null;
    }

    private List<ReportMappings> setUpReportMappings() {
        List<ReportMappings> mappings = new List<ReportMappings>();

        languages = new List<SelectOption>();
        languages.add(new SelectOption('en_US', 'English'));
        languages.add(new SelectOption('ja', '日本語'));
        languages.add(new SelectOption('vi', 'Tiếng Việt'));
        languages.add(new SelectOption('ko', '한국어'));
        languages.add(new SelectOption('kh', 'ភាសាខ្មែរ'));

        if (Constants.REPORT_TYPE_INVOICE.equalsIgnoreCase(reportType)) { // For Invoice
            setUpInvoices(mappings);
        } else if (Constants.REPORT_TYPE_PARTNER_INVOICE.equalsIgnoreCase(reportType)) { // For Print Document (D/O and A/N)
            setUpPartnerCreditDebit(mappings);
        } else if (Constants.REPORT_TYPE_DOCUMENT.equalsIgnoreCase(reportType)) { // For Print Document (D/O and A/N)
            setUpPrintDocument(mappings);
        } else if (Constants.REPORT_TYPE_QUOTATION.equalsIgnoreCase(reportType)) { // For Invoice
            setUpQuotation(mappings);
        }

        return mappings;
    }

    private void setUpInvoices(List<ReportMappings> mappings) {
        showCustomerSelection = true;
        customers = mapCustomers.values();

        mappings.add(new ReportMappings('ja_freightmemo_invoice', Constants.IV_FREIGHT_MEMO, 'FREIGHT MEMO', 'page_FreightMemoJPN', 'ja', true, false, 'OutAir,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('vi_freightmemo_invoice', Constants.IV_FREIGHT_MEMO, 'DEBIT NOTE FOR CUSTOMER', 'page_FreightMemoVI', 'vi', true, false, 'OutAir,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('ko_freightmemo_invoice', Constants.IV_FREIGHT_MEMO, 'FREIGHT MEMO', 'page_FreightMemoKRW', 'ko', true, false, 'OutAir,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('ko_invoice', Constants.IV_INVOICE, '청구서', 'page_InvoiceKRW', 'ko', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('ja_invoice', Constants.IV_INVOICE, '請求書', 'page_InvoiceJPN', 'ja', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('kh_invoice', Constants.IV_INVOICE, 'Reimbursement Invoice', 'Reimbursement Invoice', 'kh', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('kh_invoice', Constants.IV_INVOICE, 'Reimbursement Invoice(Debit)', 'Reimbursement_Invoice_Debit', 'kh', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_jpy_invoice', Constants.IV_INVOICE, 'STANDARD INVOICE', 'page_InvoiceENGJPY', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_vnd_invoice', Constants.IV_INVOICE, 'INTERNAL INVOICE-ENGLISH TEMPLATE(TOTAL:LOCAL CURRENCY)', 'page_InvoiceENGVND', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('vi_invoice', Constants.IV_INVOICE, 'PROFORMA INVOICE', 'page_InvoiceVI', 'vi', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_official_invoice', Constants.IV_INVOICE, 'OFFICIAL INVOICE-ENGLISH TEMPLATE(TOTAL:LOCAL CURRENCY)', 'page_InvoiceENGVND_Official', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('ja_bb_invoice', Constants.IV_BB_INVOICE, '航空貨物取扱い及び代行回収依頼書', 'page_BBInvoiceJPN', 'ja', true, false, 'InAir'));
        mappings.add(new ReportMappings('ja_dutypayment_invoice', Constants.IV_DUTY_PAYMENT, '立替請求書', 'page_DutyPayment', 'ja', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_proforma_invoice', Constants.IV_INVOICE, 'OFFICIAL INVOICE-ENGLISH TEMPLATE(TOTAL:USD)', 'proforma_invoice_USD', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_official_invoice_en_template', Constants.IV_INVOICE, 'VIETNAM OFFICIAL INVOICE-ENGLISH TEMPLATE(TOTAL: LOCAL CURRENCY AND USD)', 'page_VietnameOfficialInvoiceENTemplate', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
    }

    private void setUpQuotation(List<ReportMappings> mappings) {
        showCustomerSelection = true;

        if ('en_US'.equalsIgnoreCase(selectedLanguage)
                && !'en_quotationwithtotal4customer'.equalsIgnoreCase(selectedReport)
                && !'en_quotationwithouttotal4customer'.equalsIgnoreCase(selectedReport)) {
            customers = mapPartnerDebit.values();
        } else {
            customers = mapCustomers.values();
        }

        mappings.add(new ReportMappings('ja_quotationwithtotal', Constants.IV_QUOTATION, '見積書　合計金額あり', 'page_QuotationJPN', 'ja', true, true, 'QUOTATION'));
        mappings.add(new ReportMappings('ja_quotationwithouttotal', Constants.IV_QUOTATION, '見積書　合計金額なし', 'page_QuotationJPN', 'ja', true, false, 'QUOTATION'));
        mappings.add(new ReportMappings('en_quotationwithtotal', Constants.IV_QUOTATION, 'QUOTATION WITH TOTAL FOR PARTNER', 'page_QuotationENG', 'en_US', true, true, 'QUOTATION'));
        mappings.add(new ReportMappings('en_quotationwithouttotal4partner', Constants.IV_QUOTATION, 'QUOTATION WITHOUT TOTAL FOR PARTNER', 'page_QuotationENG', 'en_US', true, false, 'QUOTATION'));
        mappings.add(new ReportMappings('ko_quotationwithtotal4partner', Constants.IV_QUOTATION, '견적서(합계금액포함)', 'page_QuotationKRW', 'ko', true, true, 'QUOTATION'));
        mappings.add(new ReportMappings('ko_quotationwithouttotal', Constants.IV_QUOTATION, '견적서(합계금액불포함)', 'page_QuotationKRW', 'ko', true, false, 'QUOTATION'));
        mappings.add(new ReportMappings('vi_quotationwithtotal', Constants.IV_QUOTATION, 'BÁO GIÁ BAO GỒM TỔNG', 'page_QuotationVI', 'vi', true, true, 'QUOTATION'));
        mappings.add(new ReportMappings('vi_quotationwithouttotal', Constants.IV_QUOTATION, 'BÁO GIÁ KHÔNG BAO GỒM TỔNG', 'page_QuotationVI', 'vi', true, false, 'QUOTATION'));
        mappings.add(new ReportMappings('en_quotationwithtotal4customer', Constants.IV_QUOTATION, 'QUOTATION WITH TOTAL FOR CUSTOMER', 'page_QuotationENGCSTMR', 'en_US', true, true, 'QUOTATION'));
        mappings.add(new ReportMappings('en_quotationwithouttotal4customer', Constants.IV_QUOTATION, 'QUOTATION WITHOUT TOTAL FOR CUSTOMER', 'page_QuotationENGCSTMR', 'en_US', true, false, 'QUOTATION'));
    }

    private void setUpPartnerCreditDebit(List<ReportMappings> mappings) {
        showCustomerSelection = true;
        customers = mapPartnerDebit.values();

        mappings.add(new ReportMappings('en_debitnote', Constants.IV_DEBIT_NOTE, 'DEBIT NOTE', 'page_CreditDebitNoteENG', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_creditnote', Constants.IV_CREDIT_NOTE, 'CREDIT NOTE', 'page_CreditDebitNoteENG', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('en_debit_creditnote', Constants.IV_CREDIT_NOTE, 'DEBIT/CREDIT NOTE', 'DebitCreditNoteENG', 'en_US', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));

        mappings.add(new ReportMappings('ja_debitnote', Constants.IV_DEBIT_NOTE, 'DEBIT NOTE', 'page_CreditDebitNoteENG', 'ja', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('ja_creditnote', Constants.IV_CREDIT_NOTE, 'CREDIT NOTE', 'page_CreditDebitNoteENG', 'ja', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));

        mappings.add(new ReportMappings('vi_debitnote', Constants.IV_DEBIT_NOTE, 'GHI CHÚ NỢ TÍN DỤNG', 'page_CreditDebitNoteENG', 'vi', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('vi_creditnote', Constants.IV_CREDIT_NOTE, 'GHI CHÚ TÍN DỤNG', 'page_CreditDebitNoteENG', 'vi', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));

        mappings.add(new ReportMappings('ko_debitnote', Constants.IV_DEBIT_NOTE, '데빗 노트', 'page_CreditDebitNoteENG', 'ko', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
        mappings.add(new ReportMappings('ko_creditnote', Constants.IV_CREDIT_NOTE, '크리딧 노트', 'page_CreditDebitNoteENG', 'ko', true, false, 'InAir,OutAir,RecordType1,RecordType,Domestic_Transportation'));
    }

    private void setUpPrintDocument(List<ReportMappings> mappings) {
        showCustomerSelection = false;

        mappings.add(new ReportMappings('en_arrival_notice_air_portrait', Constants.IV_ARRIVAL_NOTICE, 'A/N-Air-Portrait(English)', 'AirPortraitArrivalNoticeENG', 'en_US', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_arrival_notice_air_portrait', Constants.IV_ARRIVAL_NOTICE, 'A/N-Air-Portrait(Vietnamese)', 'AirPortraitArrivalNoticeVN', 'vi', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_arrival_notice_air', Constants.IV_ARRIVAL_NOTICE, 'A/N-Air-Landscape(English)', 'page_ArrivalNoticeENG_air', 'en_US', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ja_arrival_notice_air', Constants.IV_ARRIVAL_NOTICE, 'A/N-航空(日本語)', 'page_ArrivalNoticeJP_air', 'ja', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ko_arrival_notice_air', Constants.IV_ARRIVAL_NOTICE, 'A/N-항공(한국어)', 'page_ArrivalNoticeKR_air', 'ko', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vn_arrival_notice_air', Constants.IV_ARRIVAL_NOTICE, 'A/N-Air-Landscape(Vietnamese)', 'page_ArrivalNoticeVN_air', 'vi', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));

        mappings.add(new ReportMappings('en_delivery_order_air_portrait', Constants.IV_DELIVERY_ORDER, 'D/O-Air-Portrait(English)', 'AirPortraitDeliveryOrderENG', 'en_US', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_air_portrait', Constants.IV_DELIVERY_ORDER, 'D/O-Air-Portrait(Vietnamese)', 'AirPortraitDeliveryOrderVN', 'vi', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_delivery_order_air', Constants.IV_DELIVERY_ORDER, 'D/O-Air-Landscape(English)', 'page_DeliveryOrderENG_Air', 'en_US', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_delivery_order_air_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-Air-Landscape(English)', 'page_DeliveryOrderENG_Air_STAMP_SIGN', 'en_US', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ja_delivery_order_air', Constants.IV_DELIVERY_ORDER, 'D/O-航空(日本語)', 'page_DeliveryOrderJP_Air', 'ja', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ja_delivery_order_air_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-航空(日本語)', 'page_DeliveryOrderJP_Air_STAMP_SIGN', 'ja', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ko_delivery_order_air', Constants.IV_DELIVERY_ORDER, 'D/O-항공(한국어)', 'page_DeliveryOrderKR_Air', 'ko', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ko_delivery_order_air_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-항공(한국어)', 'page_DeliveryOrderKR_Air_STAMP_SIGN', 'ko', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_air', Constants.IV_DELIVERY_ORDER, 'D/O-Air-Landscape(Vietnamese)', 'page_DeliveryOrderVN_Air', 'vi', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_air_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-Air-Landscape(Vietnamese)', 'page_DeliveryOrderVN_AIR_STAMP_SIGN', 'vi', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_delivery_order_air_sig_portrait', Constants.IV_DELIVERY_ORDER, 'D/O Original-Air-Portrait(English)', 'AirPortraitDeliveryOrderOriginalENG', 'en_US', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_air_sig_portrait', Constants.IV_DELIVERY_ORDER, 'D/O Original-Air-Portrait(Vietnamese)', 'AirPortraitDeliveryOrderOriginalVN', 'vi', false, false, 'InAir,airimportlock,Domestic_Transportation,,Domestic_Transportation_Lock'));

        mappings.add(new ReportMappings('en_arrival_notice_portrait', Constants.IV_ARRIVAL_NOTICE, 'A/N-Ocean-Portrait(English)', 'OceanPortraitArrivalNoticeENG', 'en_US', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock', 'page_ArrivalNoticeExcel'));
        mappings.add(new ReportMappings('vi_arrival_notice_portrait', Constants.IV_ARRIVAL_NOTICE, 'A/N-Ocean-Portrait(Vietnamese)', 'OceanPortraitArrivalNoticeVN', 'vi', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock', 'page_ArrivalNoticeExcel'));
        mappings.add(new ReportMappings('en_arrival_notice', Constants.IV_ARRIVAL_NOTICE, 'A/N-Ocean-Landscape(English)', 'page_ArrivalNoticeENG', 'en_US', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock', 'page_ArrivalNoticeExcel'));
        mappings.add(new ReportMappings('ja_arrival_notice', Constants.IV_ARRIVAL_NOTICE, 'A/N-海上(日本語)', 'page_ArrivalNoticeJPN', 'ja', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_arrival_notice', Constants.IV_ARRIVAL_NOTICE, 'A/N-Ocean-Landscape(Vietnamese)', 'page_ArrivalNoticeVI', 'vi', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ko_arrival_notice', Constants.IV_ARRIVAL_NOTICE, 'A/N-해상(한국어)', 'page_ArrivalNoticeKO', 'ko', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));

        mappings.add(new ReportMappings('en_delivery_order_portrait', Constants.IV_DELIVERY_ORDER, 'D/O-Ocean-Portrait(English)', 'OceanPortraitDeliveryOrderENG', 'en_US', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_portrait', Constants.IV_DELIVERY_ORDER, 'D/O-Ocean-Portrait(Vietnamese)', 'OceanPortraitDeliveryOrderVN', 'vi', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_delivery_order', Constants.IV_DELIVERY_ORDER, 'D/O-Ocean-Landscape(English)', 'page_DeliveryOrderENG', 'en_US', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_delivery_order_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-Ocean-Landscape(English)', 'page_DeliveryOrderENG_STAMP_SIGNATURE', 'en_US', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ja_delivery_order', Constants.IV_DELIVERY_ORDER, 'D/O-海上(日本語)', 'page_DeliveryOrderJPN', 'ja', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ja_delivery_order_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-海上(日本語)', 'page_DeliveryOrderJP_STAMP_SIGNATURE', 'ja', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order', Constants.IV_DELIVERY_ORDER, 'D/O-Ocean-Landscape(Vietnamese)', 'page_DeliveryOrderVI', 'vi', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-Ocean-Landscape(Vietnamese)', 'page_DeliveryOrderVN_STAMP_SIGNATURE', 'vi', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ko_delivery_order', Constants.IV_DELIVERY_ORDER, 'D/O-해상(한국어)', 'page_DeliveryOrderKO', 'ko', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('ko_delivery_order_sig', Constants.IV_DELIVERY_ORDER, 'D/O Original-해상(한국어)', 'page_DeliveryOrderKR_STAMP_SIGNATURE', 'ko', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('en_delivery_order_sig_portrait', Constants.IV_DELIVERY_ORDER, 'D/O Original-Ocean-Portrait(English)', 'OceanPortraitDeliveryOrderOriginalENG', 'en_US', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
        mappings.add(new ReportMappings('vi_delivery_order_sig_portrait', Constants.IV_DELIVERY_ORDER, 'D/O Original-Ocean-Portrait(Vietnamese)', 'OceanPortraitDeliveryOrderOriginalVN', 'vi', false, false, 'RecordType1,oceanimport_lock,Domestic_Transportation,,Domestic_Transportation_Lock'));
    }

    private void determineReportFormat() {
        if ((selectedReport != null && selectedReport.contains('arrival_notice'))
                || (selectedReport == null && reports.get(0).getValue().contains('arrival_notice'))) {
            showedReportFormatSelection = true;
        } else {
            showedReportFormatSelection = false;
        }
    }

    public void refreshReportsAndCustomersList() {
        reports = reportsPerLanguage.get(selectedLanguage);

        if (!reports.isEmpty()) {
            selectedReport = reports.get(0).getValue();
        }
        refreshCustomersList();
    }

    public void refreshCustomersList() {
        determineReportFormat();

        if (!StringUtils.isEmpty(selectedReport) && selectedReport.contains('creditnote')) {
            customers = mapPartnerCredit.values();
        } else if (!StringUtils.isEmpty(selectedReport) && selectedReport.contains('debitnote')) {
            customers = mapPartnerDebit.values();
        } else if (Constants.REPORT_TYPE_QUOTATION.equalsIgnoreCase(reportType)) {
            if ('en_US'.equalsIgnoreCase(selectedLanguage)
                    && !'en_quotationwithtotal4customer'.equalsIgnoreCase(selectedReport)
                    && !'en_quotationwithouttotal4customer'.equalsIgnoreCase(selectedReport)) {
                customers = mapPartnerDebit.values();
            } else {
                customers = mapCustomers.values();
            }
        } else if (!StringUtils.isEmpty(selectedReport) && selectedReport.contains('invoice')) {
            customers = mapCustomers.values();
            if (selectedReport.equals('vi_preprinted_invoice') || selectedReport.equals('vi_preprinted_vat_invoice') || selectedReport.equals('vi_InvoiceVI_Official') || selectedReport.equals('vi_drafttax_invoice')) {
                customers.addAll(mapCustomersVAT.values());
            }
        }
    }

    public void generateReport() {
        errorMessage = null;

        if (StringUtils.isEmpty(selectedReport)) {
            errorMessage = translations.get('no_report_selection');
            if (StringUtils.isEmpty(errorMessage)) {
                errorMessage = 'You have not selected any report or no report is applicable.';
            }
        } else if (StringUtils.isEmpty(selectedCustomerId) && showCustomerSelection) {
            errorMessage = translations.get('NO_CUSTOMER_SELECTION');
            if (StringUtils.isEmpty(errorMessage)) {
                errorMessage = 'You have not selected any customer/partner or no customer/partner is applicable.';
            }
        } else {
            ReportMappings mapping = reportMappings.get(selectedReport);
            selectedCustomerId = invoiceTos.get(selectedCustomerId);
            Boolean filterByVATInvoiceTo = false;

            if (!StringUtils.isEmpty(selectedCustomerId) && selectedCustomerId.contains('VAT_')) {
                filterByVATInvoiceTo = true;
                selectedCustomerId = selectedCustomerId.replace('VAT_', '');
            }

//            if (requiredAttachmentCreation) {
            for (String shipmentId : shipmentIdList) {
                String attachmentId = createAttachment(consolId, shipmentId, 'wkid', mapping.reportName,
                        EncodingUtil.urlEncode(mapping.reportDisplayedName, 'UTF-8'),
                        mapping.reportPage, 'quotationVersion', mapping.checkFlag,
                        mapping.quotationFlag, selectedLanguage, selectedCustomerId, filterByVATInvoiceTo);
            }
//                openUrl = '/servlet/servlet.FileDownload?file=' + attachmentId;


            /*} else {
                String reportPage = mapping.reportPage;
                if (selectedDownloadDocumentType.equalsIgnoreCase('excel')) {
                    reportPage = mapping.reportExcelPage;
                }

                openUrl = '/apex/' + Constants.NAMESPACE + reportPage + '?' + Constants.REQUEST_QUOTATION_FLAG + '=' + mapping.quotationFlag
                        + '&' + Constants.REQUEST_REPORT_NAME + '=' + mapping.reportName + '&' + Constants.REQUEST_WKID + '=' + 'wkid' + '&' + Constants.REQUEST_ID + '=' + repShipmentId
                        + '&' + Constants.REQUEST_VERSION + '=' + 'quotationVersion' + '&' + Constants.REQUEST_CHECK_FLAG + '=' + mapping.checkFlag
                        + '&' + Constants.REQUEST_LANGUAGE + '=' + selectedLanguage + '&' + Constants.REQUEST_CUSTOMER_ID + '=' + selectedCustomerId
                        + '&' + Constants.REQUEST_VAT_FLAG + '=' + filterByVATInvoiceTo;
            }*/
        }
    }

    /**
     * This utility will generate PDF report for HBL SHIPMENT by requesting Visualforce page which renders in PDF.
     * It takes the PDF content from requesting Visualforce, create attachment and return the ID.
     *
     * Used from: InvoiceSelectionController
     * @Id: HBL id
     * @wkid: HBL WKID (Name) - used to name the attachment
     * @reportName: the report key which is used to identify the report such as creditnote, invoice, etc.
     * @reportDisplayedName: the displayed name of the report
     * @reportPage: the VF page of the report - which will render the content in PDF format
     * @quotationVersion: the HBL quotation version - it is increased each time an attachment is generated
     * @checkFlag: the 'Check' flag from HBL Selling/Buying record link to HBL
     * @quotationTotalFlag: the flag to indicate whether to total fields are shown on QUOTATION report
     */
    private String createAttachment(Id id, String shipmentId, String wkid, String reportName, String reportDisplayedName,
            String reportPage, String quotationVersion, Boolean checkFlag,
            Boolean quotationTotalFlag, String language, String customerId, Boolean filterByVATInvoiceTo) {
        if (PermissionValidationUtil.isCreatableAttachment()) {
            PageReference pageRef = new PageReference('/apex/' + Constants.NAMESPACE + reportPage);
            pageRef.getParameters().put(Constants.REQUEST_ID, shipmentId);
            pageRef.getParameters().put(Constants.REQUEST_REPORT_NAME, String.valueof(reportName));
            pageRef.getParameters().put(Constants.REQUEST_CHECK_FLAG, String.valueof(checkFlag));
            pageRef.getParameters().put(Constants.REQUEST_QUOTATION_FLAG, String.valueof(quotationTotalFlag));
            pageRef.getParameters().put(Constants.REQUEST_LANGUAGE, language);
            pageRef.getParameters().put(Constants.REQUEST_CUSTOMER_ID, customerId);
            pageRef.getParameters().put(Constants.REQUEST_VAT_FLAG, String.valueOf(filterByVATInvoiceTo));

            Attachment attachment = new Attachment();
            attachment.Name = EncodingUtil.urlDecode(reportDisplayedName, 'UTF-8') + '(' + wkid + '-' + quotationVersion + ').pdf';

            String attachmentId = null;
            if (!Test.IsRunningTest()) {
                attachment.Body = pageRef.getContentAsPDF();
                attachment.ParentId = id;
                FlsService.doInsert(attachment);

                attachmentId = attachment.Id;
            }

//            increaseQuotationVersion(id);
            return attachmentId;
        }
        return null;
    }

    private static void increaseQuotationVersion(String shipmentId) {
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isEditableHBL()) {
            CustomObject1__c hbl = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :shipmentId];
            if (hbl.QuotationVer__c != null) {
                hbl.QuotationVer__c = hbl.QuotationVer__c + 1;
            } else {
                hbl.QuotationVer__c = 1;
            }

            FlsService.doupdate (hbl);
        }
    }

    private void loadShipmentOrders() {
        List<CustomObject1__c> shipmentOrderList = [SELECT Id FROM CustomObject1__c WHERE MasterAnkenName__c = :consolId];
        shipmentIdList = new List<String>();
        if (!shipmentOrderList.isEmpty()) {
            repShipmentId = shipmentOrderList.get(0).Id;
            for (CustomObject1__c shipment : shipmentOrderList) {
                shipmentIdList.add(shipment.Id);
            }
        }
    }

    private void loadCustomersAndPartners() {
        List<SelectOption> customers = new List<SelectOption>();
        List<SelectOption> partners = new List<SelectOption>();

        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleHBL()) {
            Set<Id> customerIds = new Set<Id>();
            List<AnkenMeisai__c> meisais = [
                    SELECT Seikyusaki__r.Id, Seikyusaki__r.Name, Seikyusaki__r.Business_Relationship__c,
                            PaymentTo__r.Id, PaymentTo__r.Name, PaymentTo__r.Business_Relationship__c,
                            VAT_INVOICE_TO__c, VAT_INVOICE_TO__r.Id, VAT_INVOICE_TO__r.Name, VAT_INVOICE_TO__r.Business_Relationship__c
                    FROM AnkenMeisai__c
                    WHERE Anken__r.MasterAnkenName__c = :consolId
            ];

            for (AnkenMeisai__c meisai : meisais) {
                if (meisai.VAT_INVOICE_TO__c != null) {
                    if (!mapCustomers.containsKey(meisai.VAT_INVOICE_TO__r.Id)
                            && Constants.CUSTOMER_RELATIONSHIP.equals(meisai.VAT_INVOICE_TO__r.Business_Relationship__c)) {
                        mapCustomersVAT.put(meisai.VAT_INVOICE_TO__r.Id, new SelectOption(meisai.VAT_INVOICE_TO__r.Id, meisai.VAT_INVOICE_TO__r.Name));
                        invoiceTos.put(meisai.VAT_INVOICE_TO__r.Id, 'VAT_' + meisai.VAT_INVOICE_TO__r.Id);
                    }
                }

                if (!mapCustomers.containsKey(meisai.Seikyusaki__r.Id)
                        && Constants.CUSTOMER_RELATIONSHIP.equals(meisai.Seikyusaki__r.Business_Relationship__c)) {
                    mapCustomers.put(meisai.Seikyusaki__r.Id, new SelectOption(meisai.Seikyusaki__r.Id, meisai.Seikyusaki__r.Name));
                    invoiceTos.put(meisai.Seikyusaki__r.Id, meisai.Seikyusaki__r.Id);
                } else if (!mapPartnerDebit.containsKey(meisai.Seikyusaki__r.Id)
                        && Constants.PARTNER_RELATIONSHIP.equals(meisai.Seikyusaki__r.Business_Relationship__c)) {
                    mapPartnerDebit.put(meisai.Seikyusaki__r.Id, new SelectOption(meisai.Seikyusaki__r.Id, meisai.Seikyusaki__r.Name));
                    invoiceTos.put(meisai.Seikyusaki__r.Id, meisai.Seikyusaki__r.Id);
                }

                if (!mapPartnerCredit.containsKey(meisai.PaymentTo__r.Id)
                        && Constants.PARTNER_RELATIONSHIP.equals(meisai.PaymentTo__r.Business_Relationship__c)) {
                    mapPartnerCredit.put(meisai.PaymentTo__r.Id, new SelectOption(meisai.PaymentTo__r.Id, meisai.PaymentTo__r.Name));
                    invoiceTos.put(meisai.PaymentTo__r.Id, meisai.PaymentTo__r.Id);
                }
            }
        }
    }

    public class ReportMappings {
        public String id { get; private set; }
        public String reportName { get; private set; }
        public String reportDisplayedName { get; private set; }
        public String language { get; private set; }
        public String reportPage { get; private set; }
        public Boolean checkFlag { get; private set; }
        public Boolean quotationFlag { get; private set; }
        public String recordTypes { get; private set; }
        public String customerId { get; private set; }
        public String reportExcelPage { get; private set; }

        public ReportMappings(String id, String reportName, String reportDisplayedName, String reportPage,
                String language, Boolean checkFlag, Boolean quotationFlag, String recordTypes) {
            this.id = id;
            this.reportName = reportName;
            this.reportDisplayedName = reportDisplayedName;
            this.reportPage = reportPage;
            this.language = language;
            this.checkFlag = checkFlag;
            this.quotationFlag = quotationFlag;
            this.recordTypes = recordTypes;
        }

        public ReportMappings(String id, String reportName, String reportDisplayedName, String reportPage,
                String language, Boolean checkFlag, Boolean quotationFlag, String recordTypes, String reportExcelPage) {
            this.id = id;
            this.reportName = reportName;
            this.reportDisplayedName = reportDisplayedName;
            this.reportPage = reportPage;
            this.language = language;
            this.checkFlag = checkFlag;
            this.quotationFlag = quotationFlag;
            this.recordTypes = recordTypes;
            this.reportExcelPage = reportExcelPage;
        }
    }
}