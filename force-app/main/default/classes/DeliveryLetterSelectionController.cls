public with sharing class DeliveryLetterSelectionController {
    public CustomObject1__c shipment { get; private set; }
    public Cargo_Delivery__c cargoDelivery { get; private set; }
    public boolean requiredAttachmentCreation { get; set; }
    public String openUrl { get; private set; }
    public String errorMessage { get; private set; }
    public Map<String, String> translations { get; private set; }
    public List<SelectOption> languages { get; private set; }
    public String selectedLanguage { get; set; }
    public List<SelectOption> letters { get; private set; }
    public String selectedLetter { get; set; }
    public List<SelectOption> locations { get; private set; }
    public String selectedLocation { get; set; }

    private String shipmentId;
    private Map<String, List<SelectOption>> lettersPerLanguage;
    private Map<String, ReportMappings> reportMappings = new Map<String, ReportMappings>();

    public DeliveryLetterSelectionController() {
        selectedLanguage = UserInfo.getLanguage();
        initializeTranslation();

        shipmentId = ApexPages.currentPage().getParameters().get('id');
        shipmentId = StringUtils.escapeSingleQuotes(shipmentId);

        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleHBL()) {
            loadCargoDeliveries(shipmentId);
        }

        buildLanguagesPerReportMappings();
        languages = new List<SelectOption>();
        languages.add(new SelectOption('en_US', 'English'));
        languages.add(new SelectOption('ja', '日本語'));
        languages.add(new SelectOption('vi', 'Tiếng Việt'));
        languages.add(new SelectOption('ko', '한국어'));

        letters = lettersPerLanguage.get(selectedLanguage);
    }

    public void showDeliveryLetter() {
        errorMessage = null;
        if (StringUtils.isEmpty(selectedLocation) || String.isBlank(selectedLetter)) {
            errorMessage = 'You have not selected any report or no report is applicable.';
        } else {
            ReportMappings reportMapping = reportMappings.get(selectedLetter);
            if (requiredAttachmentCreation) {
                String attachmentId = createAttachment(shipmentId, selectedLocation, selectedLanguage, reportMapping);
                openUrl = '/servlet/servlet.FileDownload?file=' + attachmentId;
            } else {
                openUrl = '/apex/' + Constants.NAMESPACE + reportMapping.reportPage + '?shipmentId=' + shipmentId
                        + '&cargoId=' + selectedLocation + '&lang=' + selectedLanguage;
            }
        }
    }

    public void refreshLettersList() {
        letters = lettersPerLanguage.get(selectedLanguage);
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('InvoiceSelection', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    private void buildLanguagesPerReportMappings() {
        String recordType = getRecordType(shipmentId);
        List<ReportMappings> mappings = setupReportMappings();
        lettersPerLanguage = new Map<String, List<SelectOption>>();

        for (ReportMappings mapping : mappings) {
            // 2019/08/13 Chien Truong MODIFY START
            /*
            if (StringUtils.isContainedInCommaSeparateString(mapping.recordTypes, recordType)) {
                reportMappings.put(mapping.id, mapping);
                if (lettersPerLanguage.containsKey(mapping.language)) {
                    lettersPerLanguage.get(mapping.language).add(new SelectOption(mapping.id, mapping.reportDisplayedName));
                } else {
                    List<SelectOption> report = new List<SelectOption>();
                    report.add(new SelectOption(mapping.id, mapping.reportDisplayedName));
                    lettersPerLanguage.put(mapping.language, report);
                }
            }*/

            reportMappings.put(mapping.id, mapping);
            if (lettersPerLanguage.containsKey(mapping.language)) {
                lettersPerLanguage.get(mapping.language).add(new SelectOption(mapping.id, mapping.reportDisplayedName));
            } else {
                List<SelectOption> report = new List<SelectOption>();
                report.add(new SelectOption(mapping.id, mapping.reportDisplayedName));
                lettersPerLanguage.put(mapping.language, report);
            }
            // 2019/08/13 Chien Truong MODIFY END
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

    private List<ReportMappings> setupReportMappings() {
        List<ReportMappings> mappings = new List<ReportMappings>();

        //[AIR/OCEAN IMPORT]Loading and unloading Request Form
        mappings.add(new ReportMappings('en_US_loading_unloading', 'Cargo Delivery Request Form（Common）', 'page_LoadUnloadLocations', 'en_US', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ja_loading_unloading', '配送依頼書（共通）', 'page_LoadUnloadLocations_JP', 'ja', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ko_loading_unloading', '배송의뢰서(공통)', 'page_LoadUnloadLocations_KR', 'ko', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('vi_loading_unloading', 'Mẫu yêu cầu giao hàng – Thông thường', 'page_LoadUnloadLocationsVI', 'vi', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));

        //[AIR/OCEAN EXPORT]Loading and unloading Request Form For Truck
        mappings.add(new ReportMappings('en_US_loading_unloading_truck', 'Cargo Delivery Request Form（Truck）', 'page_LoadUnloadTruck', 'en_US', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ja_loading_unloading_truck', '配送依頼書（トラック用）', 'page_LoadUnloadTruck_JP', 'ja', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ko_loading_unloading_truck', '배송의뢰서(트럭용)', 'page_LoadUnloadTruck_KR', 'ko', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('vi_loading_unloading_truck', 'Mẫu yêu cầu giao hàng cho vận chuyển', 'page_LoadUnloadTruckVI', 'vi', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));

        //[OCEAN IMPORT/EXPORT]Drayage Request Form
        mappings.add(new ReportMappings('en_US_oceanexport_drayage_request', 'Cargo Delivery Request Form（Drayage）', 'page_DrayageRequest', 'en_US', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ja_oceanexport_drayage_request', '配送依頼書（ドレー用）', 'page_DrayageRequest_JP', 'ja', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ko_oceanexport_drayage_request', '배송의뢰서(도레지용)', 'page_DrayageRequest_KR', 'ko', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('vi_oceanexport_drayage_request', 'Mẫu yêu cầu giao hàng cho Container Drayage', 'page_DrayageRequestVI', 'vi', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));

        //[Drayage] Invoice of Cargo
        mappings.add(new ReportMappings('en_US_drayage_invoice', 'Cargo Receipt Note（Drayage）', 'page_DrayageInvoiceOfCargo', 'en_US', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ja_drayage_invoice', '貨物受取証（ドレージ用）', 'page_DrayageInvoiceOfCargo_JP', 'ja', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ko_drayage_invoice', '화물수령증（도레지용）', 'page_DrayageInvoiceOfCargo_KR', 'ko', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('vi_drayage_invoice', 'Giấy nhận hàng cho Container Drayage', 'page_DrayageInvoiceOfCargoVI', 'vi', 'RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));

        //[Truck] Invoice of Cargo
        mappings.add(new ReportMappings('en_US_truck_invoice', 'Cargo Receipt Note（Truck）', 'page_TruckInvoiceOfCargo', 'en_US', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ja_truck_invoice', '貨物受取証（トラック用）', 'page_TruckInvoiceOfCargo_JP', 'ja', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('ko_truck_invoice', '화물수령증（트럭용）', 'page_TruckInvoiceOfCargo_KR', 'ko', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));
        mappings.add(new ReportMappings('vi_truck_invoice', 'Giấy nhận hàng cho vận chuyển', 'page_TruckInvoiceOfCargoVI', 'vi', 'InAir,OutAir,RecordType1,RecordType, Domestic_Transportation, Domestic_Transportation_Lock, CrossBoarderLock, CrossBoarder'));

        return mappings;
    }

    private void loadCargoDeliveries(String shipmentId) {
        shipment = [
                SELECT Id, Name, Mail_Merge_Company_Signature__c, Cnee__c, UnitType__c, carton__c, CBM__c,
                        weight__c, HAWB__c, Marks_and_Numbers__c, (
                        SELECT Id, Name, DeliveryCompany__r.Name, RecordTypeId
                        FROM Cargo_Delivery__r
                        ORDER BY CreatedDate ASC
                )
                FROM CustomObject1__c
                WHERE Id = :shipmentId
        ];

        locations = new List<SelectOption>();

        List<Cargo_Delivery__c> cargoDeliveries = shipment.Cargo_Delivery__r;

        if (!cargoDeliveries.isEmpty()) {
            for (Cargo_Delivery__c cd : cargoDeliveries) {
                String deliveryName = (StringUtils.isEmpty(cd.DeliveryCompany__r.Name) ? '' : cd.DeliveryCompany__r.Name);
                String recordType = RecordTypeUtil.getRecordTypeName(Cargo_Delivery__c.SObjectType, cd.RecordTypeId);
                locations.add(new SelectOption(cd.Id, cd.Name + ' - ' + recordType + ' - ' + deliveryName));
            }
            locations.add(new SelectOption('all', translations.get('ALL')));
        }
    }

    private static String createAttachment(String shipmentId, String cargoDeliveryId, String language, ReportMappings reportMapping) {
        if (PermissionValidationUtil.isCreatableAttachment()) {
            PageReference pageRef = new PageReference('/apex/' + Constants.NAMESPACE + reportMapping.reportPage);
            pageRef.getParameters().put('shipmentId', shipmentId);
            pageRef.getParameters().put('cargoId', cargoDeliveryId);
            pageRef.getParameters().put('lang', language);

            Attachment attachment = new Attachment();
            attachment.Name = reportMapping.reportDisplayedName + '.pdf';

            String attachmentId = null;
            if (!Test.IsRunningTest()) {
                attachment.Body = pageRef.getContentAsPDF();
                attachment.ParentId = shipmentId;
                FlsService.doInsert(attachment);

                attachmentId = attachment.Id;
            }

            return attachmentId;
        }
        return null;
    }

    public class ReportMappings {
        public String id { get; private set; }
        public String reportDisplayedName { get; private set; }
        public String language { get; private set; }
        public String reportPage { get; private set; }
        public String recordTypes { get; private set; }

        public ReportMappings(String id, String reportDisplayedName, String reportPage,
                String language, String recordTypes) {
            this.id = id;
            this.reportDisplayedName = reportDisplayedName;
            this.reportPage = reportPage;
            this.language = language;
            this.recordTypes = recordTypes;
        }
    }
}