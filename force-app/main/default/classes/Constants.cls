public class Constants {
    public static final String NAMESPACE = 'clofor_com_cfs__';
    public static final Integer PAGE_SIZE = 10;
    public static final Integer MAX_VAT_RUNNING_NUMBER = 9999999;
    public static final Integer RUNNING_NUMBER_LENGTH = 7;
    public static final String DEFAULT_DATE_FORMAT = 'dd/MM/yyyy';
    
    /**
     * Account: Business Relationship
     */
    public static final String PARTNER_RELATIONSHIP = 'Partner';
    public static final String CUSTOMER_RELATIONSHIP = 'Customer';
    public static final String VENDOR_RELATIONSHIP = '3rd Vendor';

    /**
     * H B/L-SHIPMENT: Record Types
     */
    public static final String OCEAN_IMPORT_RT = 'RecordType1';
    public static final String OCEAN_IMPORT_LOCK_RT = 'oceanimport_lock';
    public static final String OCEAN_EXPORT_RT = 'RecordType';
    public static final String OCEAN_EXPORT_LOCK_RT = 'oceanexport_lock';
    public static final String QUOTATION_RT = 'QUOTATION';
    public static final String AIR_EXPORT_RT = 'OutAir';
    public static final String AIR_EXPORT_LOCK_RT = 'OutAir_lock';
    public static final String AIR_IMPORT_RT = 'InAir';
    public static final String AIR_IMPORT_LOCK_RT = 'airimportlock';
    public static final String DOMESTIC_TRANSPORTATION_RT = 'Domestic_Transportation';
    public static final String DOMESTIC_TRANSPORTATION_LOCK_RT = 'Domestic_Transportation_Lock';
    public static final String CROSS_BOARDER_RT = 'CrossBoarder';
    public static final String CROSS_BOARDER_LOCK_RT = 'CrossBoarderLock';

    
    public static final String OCEAN_IMPORT_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(OCEAN_IMPORT_RT).getRecordTypeId();
    public static final String OCEAN_IMPORT_LOCK_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(OCEAN_IMPORT_LOCK_RT).getRecordTypeId();
    public static final String OCEAN_EXPORT_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(OCEAN_EXPORT_RT).getRecordTypeId();
    public static final String OCEAN_EXPORT_LOCK_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(OCEAN_EXPORT_LOCK_RT).getRecordTypeId();
    public static final String QUOTATION_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(QUOTATION_RT).getRecordTypeId();
    public static final String AIR_EXPORT_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(AIR_EXPORT_RT).getRecordTypeId();
    public static final String AIR_EXPORT_LOCK_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(AIR_EXPORT_LOCK_RT).getRecordTypeId();
    public static final String AIR_IMPORT_LOCK_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(AIR_IMPORT_LOCK_RT).getRecordTypeId();
    public static final String DOMESTIC_TRANSPORTATION_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(DOMESTIC_TRANSPORTATION_RT).getRecordTypeId();
    public static final String DOMESTIC_TRANSPORTATION_LOCK_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(DOMESTIC_TRANSPORTATION_LOCK_RT).getRecordTypeId();
    public static final String CROSS_BOARDER_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(CROSS_BOARDER_RT).getRecordTypeId();
    public static final String CROSS_BOARDER_LOCK_RT_ID = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get(CROSS_BOARDER_LOCK_RT).getRecordTypeId();


    // 2019/08/17 Chien Truong ADD START
    public static final String LOGISTICS_SERVICE = 'LogisticsService';
    public static final String LOGISTICS_SERVICE_LOCK = 'LogisticsServiceLock';
    // 2019/08/17 Chien Truong ADD END

    public static final Integer MAX_DELIVERY_LOCATIONS = 50;
    
    /* HBL SELLING/BUYING record types */
    public static final String SELLING_BUYING_CONSOLIDATION_RT = 'Consolidation_Cost_allocation';
    public static final String SELLING_BUYING_STANDARD_RT = 'Selling_Buyging_Standard';

    public static final String COUNTRY_JAPAN = 'JAPAN';
    
    /**
     * Invoice Selection Controller
     */
    public static final String IV_FREIGHT_MEMO = 'freightmemo';
    public static final String IV_INVOICE = 'invoice';
    public static final String IV_BB_INVOICE = 'bbinvoice';
    public static final String IV_QUOTATION = 'quotation';
    public static final String IV_CREDIT_NOTE = 'creditnote';
    public static final String IV_DEBIT_NOTE = 'debitnote';
    public static final String IV_ARRIVAL_NOTICE = 'arrivalnotice';
    public static final String IV_DELIVERY_ORDER = 'deliveryorder';
    public static final String IV_DUTY_PAYMENT = 'dutypayment';
    public static final String IV_INVOICE_WITH_TAX = 'invoicewithtax';
    public static final String IV_INVOICE_WITHOUT_TAX = 'invoicewithouttax';

    public static final String REQUEST_ID = 'id';
    public static final String REQUEST_CHECK_FLAG = 'checkFlag';
    public static final String REQUEST_QUOTATION_FLAG = 'quotationTotalFlag';
    public static final String REQUEST_REPORT_NAME = 'report';
    public static final String REQUEST_REPORT_TYPE = 'reportType';
    public static final String REQUEST_VERSION = 'version';
    public static final String REQUEST_WKID = 'wkid';
    public static final String REQUEST_LANGUAGE = 'language';
    public static final String REQUEST_CUSTOMER_ID = 'custId';
    public static final String REQUEST_VAT_FLAG = 'vat';
    public static final String REQUEST_GROUPTING_OPTION = 'grouping';
    public static final String REQUEST_INVOICE_TEMPLATE_SET = 'template';
    public static final String REQUEST_CURRENCY = 'currency';

    public static final String REPORT_TYPE_INVOICE = 'invoice';
    public static final String REPORT_TYPE_PARTNER_INVOICE = 'partner';
    public static final String REPORT_TYPE_DOCUMENT = 'document';
    public static final String REPORT_TYPE_QUOTATION = 'quotation';
    
    /**
     * Object classification Apex class
     */
    public static final String CL_DOMESTIC = '国内';
    public static final String CL_OVERSEA = '海外';
    public static final String CL_MRT_IMPORT = 'import';
    public static final String CL_MRT_EXPORT = 'export';
    public static final String CL_PARTNER_TYPE = 'パートナー';
    
    /**
     * Common Setting Keywords
     */
    public static final String COMMON_SETTINGS_ACCOUNT_REFERENCE = 'ACCOUNT_REF_KEY';
    
    /**
     * Custom Clearance Record Types
     */
    public static final String CC_OCEAN_IMPORT_RT = 'CC_Ocean_Import';
    public static final String CC_OCEAN_EXPORT_RT = 'CC_Ocean_Export';
    public static final String CC_AIR_IMPORT_RT = 'CC_Air_Import';
    public static final String CC_AIR_EXPORT_RT = 'CC_Air_Export';
    public static final String CC_INLAND_IMPORT_RT = 'CC_InlandImport';
    public static final String CC_INLAND_EXPORT_RT = 'CC_InlandExport';

    /**
     * Error codes
     * 
     */
    public static final String NOT_ALLOWED_DELETE_REQUIRED_HBL = 'Input H B/L No or Temporary No, or change to B/L Type to "Direct M B/L(H B/L Issue Not Required)"';
    public static final String NOT_ALLOWED_CREATE_LOCKED_HBL = 'NOT_ALLOWED_CREATE_LOCKED_HBL';
    public static final String NOT_ALLOWED_EDIT_LOCKED_HBL = 'NOT_ALLOWED_EDIT_LOCKED_HBL';
    public static final String INVALID_IMPORT_PROCESS_TIME_ORDER = 'INVALID_IMPORT_PROCESS_TIME_ORDER';
    public static final String INVALID_EXPORT_PROCESS_TIME_ORDER = 'INVALID_EXPORT_PROCESS_TIME_ORDER';
    public static final String INVALID_RECORD_TYPE = 'INVALID_RECORD_TYPE';
    public static final String LIMITED_DELIVERY_LOCATIONS = 'LIMITED_DELIVERY_LOCATIONS';
    public static final String INVALID_CONTAINER_NO = 'INVALID_CONTAINER_NO';
    public static final String DUPLICATED_CONTAINER_NO = 'DUPLICATED_CONTAINER_NO';
    public static final String EXCEEDED_NUM_CONTAINERS = 'EXCEEDED_NUM_CONTAINERS';
    public static final String NOT_UNIQUE_CONTAINER = 'NOT_UNIQUE_CONTAINER';
    public static final String CONTAINER_NOT_SET = 'CONTAINER_NOT_SET';
    public static final String UNAVAILABLE_CURRENCY = 'UNAVAILABLE_CURRENCY';
    public static final String OVERLAPPED_TAX_RATIO = 'OVERLAPPED_TAX_RATIO';
    public static final String OVERLAPPED_EXCHANGE_RATE = 'OVERLAPPED_EXCHANGE_RATE';
    
    /**
     * REF No code per Record Type
     */
    public static final String REF_OCEAN_IMPORT = 'SI';
    public static final String REF_OCEAN_EXPORT = 'SE';
    public static final String REF_AIR_IMPORT = 'AI';
    public static final String REF_AIR_EXPORT = 'AE';
    public static final String REF_CROSS_BORDER = 'CB';
    public static final String REF_DOMESTIC_TRANSPORTATION = 'DT';

    /**
     * VAT INVOICE report
     */
    public static final String GROUPED_BY_FORWARDING_KEY = 'GROUPED_BY_FORWARDING';
    public static final String GROUPED_BY_FORWARDING_VALUE = 'COMBINED TO SHIPMENT ORDER';
    public static final String GROUPED_BY_INVOICING_KEY = 'GROUPED_BY_INVOICING';
    public static final String GROUPED_BY_INVOICING_VALUE = 'GROUPED BY INVOICING';
    public static final String SUMMARY_KEY = 'SUMMARY';
    public static final String SUMMARY_VALUE = 'COMBINED TO 1 SUMMARY';
    public static final String GROUPED_BY_CATEGORY_KEY = 'GROUP_BY_CATEGORY';
    public static final String GROUPED_BY_CATEGORY_VALUE = 'GROUP BY SUB-CATEGORY';

    public static final String WORK_PROGRESS_COMPLETE = 'complete';
    public static final String WORK_PROGRESS_CURRENT = 'current';
    public static final String WORK_PROGRESS_INCOMPLETE = 'incomplete';

    /*
     * Purchasing Order Record Types
     */
    public static final String PO_LOCK_RT = 'LockedPurchasingOrder';
    public static final String PO_RT = 'LockedPurchasingOrder';

    /*
     * Cargo Delivery Record Types
     */
    public static final String CD_CHATTER_TRUCK_IMPORT_RT = 'Charter_Truck_Import';
    public static final String CD_CHATTER_TRUCK_EXPORT_RT = 'Charter_Truck_Export';
    public static final String CD_CONSOL_TRUCK_IMPORT_RT = 'Consolidation_Truck_Import';
    public static final String CD_CONSOL_TRUCK_EXPORT_RT = 'Consolidation_Truck_Export';
    public static final String CD_DRAYAGE_IMPORT_RT = 'Drayage_Import';
    public static final String CD_DRAYAGE_EXPORT_RT = 'Drayage_Export';

    /*
     * Transit Record Types
     */
    public static final String TRANSIT_SHIPMENT_RT = 'ShipmentOrderTransit';
    public static final String TRANSIT_CONSOL_RT = 'ConsolidationTransit';

    /**
       Currencies
     */
    public static final String CURRENCY_JPY = 'JPY';
    public static final String CURRENCY_USD = 'USD';
    public static final String CURRENCY_VND = 'VND';

    /*
     * Kickback Record Types
     */
    public static final String KICKBACK_TO_CUSTOMER_RT = 'KickbackToCustomer';
    public static final String KICKBACK_TO_CUSTOMER_OFFICER_RT = 'KickbackToCustomsOfficer';
    public static final String KICKBACK_TO_VENDOR_RT = 'KickbackToVendor';

    /*
     * PRICING Record Types
     */
    public static final String PRICING_AIR_RT = 'air';
    public static final String PRICING_CUSTOM_CLEARANCE_RT = 'Tukan';
    public static final String PRICING_CONSOLIDATION_RT = 'SM_Consolidation_Cost_Allocation';
    public static final String PRICING_EMPTY_CONTAINER_RT = 'EMPTY';
    public static final String PRICING_FLC_RT = 'FCL';
    public static final String PRICING_FULL_CONTAINER_TRUCK_RT = 'RecordTypeDore';
    public static final String PRICING_LCL_RT = 'LCL';
    public static final String PRICING_TRUCKING_RT = 'Tracking';
    public static final String PRICING_WAREHOUSING_RT = 'Warehouse';

    /*
     * CASH Record Types
     */
    public static final String CASH_IN_RT = 'CashIn';
    public static final String CASH_OUT_RT = 'CashOut';
    public static final String TRANSACTION_RT = 'Transaction';

    public static final String RecordTypeId_CashBook_CashIn = Schema.SObjectType.clofor_com_cfs__CASH_BOOK__c.getRecordTypeInfosByDeveloperName().get('CashIn').getRecordTypeId();
    public static final String RecordTypeId_CashBook_CashOut = Schema.SObjectType.clofor_com_cfs__CASH_BOOK__c.getRecordTypeInfosByDeveloperName().get('CashOut').getRecordTypeId();

    /*
     * TRUCK & FLEET Record Types
     */
    public static final String TF_CONTAINER_CHASSI_RT = 'FULL_CONTAINER_CHASSI';
    public static final String TF_CONTAINER_TRUCK_RT = 'FULL_CONTAINER_TRUCK';
    public static final String TF_TRUCK_RT = 'TRUCK';

    public static Map<String, String> CONTAINER_TYPE_NAMES;
    static {
        CONTAINER_TYPE_NAMES = new Map<String, String>();
        // 2019/08/08 Chien Truong MODIFY START
        /*
        CONTAINER_TYPE_NAMES.put('20\'All', '20ft CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'All', '40ft CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'DC', '20ft DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('220\'DC', '220ft DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'DC', '40ft DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'DC', '45ft DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'HC', '40ft HIGH CUBE CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'HC', '45ft HIGH CUBE CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'REF', '20ft REEFER CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'REF', '40ft REEFER CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'REF', '45ft REEFER CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'FT', '20ft FLAT TRACK CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'FT', '40ft FLAT TRACK CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'FT', '45ft FLAT TRACK CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'OT', '20ft OPEN TOP CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'OT', '40ft OPEN TOP CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'OT', '45ft OPEN TOP CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'PF', '20ft PLATFORM CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'PF', '40ft PLATFORM CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'PF', '45ft PLATFORM CONTAINER');
        CONTAINER_TYPE_NAMES.put('BULK', 'BULK CONTAINER');
        CONTAINER_TYPE_NAMES.put('ISO', 'ISO CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'IMO', '20ft IMO CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'IMO', '40ft IMO CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'IMO', '45ft IMO CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'DC-Flexitank', '20ft FLEXITANK CONTAINER');*/        
        CONTAINER_TYPE_NAMES.put('20\'DC', '20 DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'DC', '40 DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'DC', '45 DRY CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'HC', '40 HIGH CUBE CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'HC', '45 HIGH CUBE CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'RF', '20 REEFER CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'RF', '40 REEFER CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'RF', '45 REEFER CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'OT', '20 OPEN TOP CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'OT', '40 OPEN TOP CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'OT', '45 OPEN TOP CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'FR', '20 FLAT RACK CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'FR', '40 FLAT RACK CONTAINER');
        CONTAINER_TYPE_NAMES.put('ISO', 'ISO CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'IMO', '20 IMO CONTAINER');
        CONTAINER_TYPE_NAMES.put('40\'IMO', '40 IMO CONTAINER');
        CONTAINER_TYPE_NAMES.put('45\'IMO', '45 IMO CONTAINER');        
        CONTAINER_TYPE_NAMES.put('AIR', 'AIR CONTAINER');
        CONTAINER_TYPE_NAMES.put('20\'DC-Flexi', '20 FLEXITANK CONTAINER');
        // 2019/08/08 Chien Truong MODIFY END
    }

    public static final String RecordTypeId_Stock_StockIn = Schema.SObjectType.Stock__c.getRecordTypeInfosByDeveloperName().get('StockIn').getRecordTypeId();
    public static final String RecordTypeId_Stock_StockOut = Schema.SObjectType.Stock__c.getRecordTypeInfosByDeveloperName().get('StockOut').getRecordTypeId();

    public static final String RecordTypeId_Wos_Receiving = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('InboundReceiving').getRecordTypeId();
    public static final String RecordTypeId_Wos_Picking = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('Picking').getRecordTypeId();
    public static final String RecordTypeId_Wos_PutAway = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('Putaway').getRecordTypeId();
    public static final String RecordTypeId_Wos_OutboundDispatch = Schema.SObjectType.WorkOrderService__c.getRecordTypeInfosByDeveloperName().get('OutboundDispatch').getRecordTypeId();

    public static final String RecordTypeId_Account_Customer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CustomerB2B').getRecordTypeId();
    public static final String RecordTypeId_Account_Partner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
    public static final String RecordTypeId_Account_Vendor = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('VendorSupplier').getRecordTypeId();
    public static final String RecordTypeId_Account_Others = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Others').getRecordTypeId();
}