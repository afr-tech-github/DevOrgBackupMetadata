/**
 * Master picklist text to support comparison 
 */ 
public class PicklistReference {
	/* Account - Type */
	public static final String DOMESTIC_CUSTOMER_EXISTING = '国内顧客 - 既存';   
    public static final String DOMESTIC_CUSTOMER_LEAD_APPROACHING = '国内顧客 - 見込み';
    public static final String DOMESTIC_CUSTOMER_NO_NEED_SALES = '国内顧客 - 営業不要';
    public static final String OVERSEA_PARTNER_EXISTING = '海外パートナー - 既存';
    public static final String DOMESTIC_CUSTOMER_FORWARDER = '国内顧客 - フォワーダー';
    public static final String THIRD_VENDOR_BB_CUSTOMERS_CLEARANCE = '業者 - BB/通関（当社手配先）';
    public static final String INTERNAL_TYPE = '当社社内利用';
    
    /*
     * H B/L SHIPMENT
     */ 
    
    // Custom__c
    public static final String CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO = '×(NO)';
    public static final String CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES = '○(YES)';    
        
    //H B/L-SHIPMENT: Statuses
    public static final String COMPLETED_ST = '完了(Completed)';
    public static final String ORIGINAL_INVOICE_ISSUED_ST = '輸出 請求書送付済(Original Invoice Issued)';
    public static final String TEMPORARY_UNLOCK_FOR_ACCOUNTING_PURPOSE_ST = '計上のための一時的なロック解除(Temporary Unlock)';
    public static final String CANCELLED_ST = 'キャンセル(Cancelled)';
    public static final String IMPORT_ORIGINAL_INVOICE_AND_STATEMENT_OF_PAYMENT_ISSUED_ST = '輸入 請求書/納付書原本送付済(Original Invoice and Statement of Payment issued)';
    public static final String IMPORT_PERMIT_INVOICE_ISSUED_ST = '輸入 許可書/請求書メール・ファクス送信済(An Import Permit/Invoice Issued)';
    public static final String IMPORT_REVISED_INVOICE_ISSUED_ST = '輸入 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)';
	public static final String CARGO_INFO_RECEIVED_ST = '輸入 出荷情報入手(Cargo Info Received)';
    public static final String BOOKING_INFO_CHANGED_ST = '輸入 ブッキング情報変更(Booking Info Changed)';
    public static final String DEPARTURED_ST = '輸入 本船/フライト出発済(Departured)';
    public static final String ON_VOYAGE_ST = '輸入 本船/フライト運行中(On Voyage)';
    public static final String BB_REQUESTED_ST = '輸入 BB依頼済み(BB Requested)-航空のみ(For AIR)';
    public static final String DO_ISSUED_ST = '輸入 出荷指図書発行済(D/O Issued)';
    public static final String APP_FOR_CUSTOMS_CLEARANCE_ST = '輸入 通関申告書作成中(Application for Customs Clearance)';
    public static final String CUSTOMS_INSPECTION_ST = '輸入 税関検査予定(Customs Inspection)';
    public static final String IMPORT_PERMITTED_ST = '輸入 輸入許可(Import Permitted)';
    public static final String CARGO_PICKED_UP_ST = '輸出 貨物集荷済(Cargo Picked Up)';
    public static final String ON_DELIVERY_ST = '輸入 貨物引取済/配送中(On Delivery)';
    public static final String DELIVERY_COMPLETED_ST = '輸入 納品完了(Delivery Completed)';
    public static final String SI_DATA_REGISTERED_ST = '輸出 船積指示書情報登録済み(SI Data Registered)';
    public static final String CHECK_BL_ISSUED_ST = '輸出 チェックB/L送付済(Check B/L Issued)';
    public static final String BL_ISSUED_ST = '輸出 船荷証券送付済(B/L Issued)';
    public static final String IN_STORAGE_ST = '輸出 入庫済(In Storage)';
    
    public static final String EXPORT_PERMITTED_ST = '輸出 輸出許可(Export Permitted)';
    public static final String EXPORT_PERMIT_INVOICE_ST = '輸出 許可書/請求書メール・ファクス送信済(An Export Permit/Invoice Issued)';
    public static final String EXPORT_REVISED_INVOICE_ST = '輸出 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)';
    public static final String BOOKING_CONFIRMED_ST = '輸出 ブッキング済(Booking Confirmed)';
    
    public static final String CONSOLIDATION_TYPE_CONSOLIDATION = '自社混載(Consolidation Cargo)';
    public static final String CONSOLIDATION_TYPE_MULTIPLE_BL = '複数BL貨物(Multiple BL Cargo)';
    public static final String HBL_NO_REQUIRED = 'H B/L Issue Required';
    
    /* TRANSPORT TYPE */
    public static final String TRANSPORT_TYPE_AIR = 'AIR';
    public static final String TRANSPORT_TYPE_SEA_AIR = 'SEA&AIR';
    
    /* Vessel Type*/
    public static final String VESSEL_FERRY = 'Ferry';
    public static final String VESSEL_CONTAINER_FERRY = 'Container Vessel';
    
    // Transportation Type
    public static final String TRANSPORTATION_FCL = 'FCL';
    public static final String TRANSPORTATION_LCL = 'LCL';
    public static final String TRANSPORTATION_AIR = 'AIR';
    public static final String TRANSPORTATION_BULK = 'BULK';
    public static final String TRANSPORTATION_MTY = 'MTY';
    public static final String TRANSPORTATION_MTY_FCL = 'MTY & FCL';
    public static final String TRANSPORTATION_Consol = 'Consol';

    /* 
     * H B/L SELLING BUYING
	 */
    // BUYING-TAX CATEGORY FOR THE CREDIT 
    public static final String BUYING_TAX_CAT_CREDIT_OUT_OF_SCOPE = '対象外';
    
    // BUYING-TAX CATEGORY FOR THE DEBIT 
    public static final String BUYING_TAX_CAT_DEBIT_COSTS_INCLUDED = '課対仕入込8%';
    public static final String BUYING_TAX_CAT_DEBIT_OUT_OF_SCOPE = '対外仕入';    
    
    // BUYING-THE CREDIT 
    public static final String BUYING_CREDIT_ACCOUNT_PAYABLE = '買掛';
    public static final String BUYING_CREDIT_ORDINARY_ACCOUNT = '普通預金';
    
    // BUYING-THE DEBIT 
    public static final String BUYING_DEBIT_ACCOUNT_PAYABLE = '買掛';
    public static final String BUYING_DEBIT_COSTS = '仕入高';
    
    //SELLING-TAX CATEGORY FOR THE CREDIT 
    public static final String SELLING_TAX_CAT_CREDIT_COSTS_INCLUDED = '課税売上込8%';
    public static final String SELLING_TAX_CAT_CREDIT_EXPORT_SALES = '輸出売上';
    
    // SELLING-TAX CATEGORY FOR THE DEBIT 
    public static final String SELLING_TAX_CAT_DEBIT_OUT_SCOPE = '対象外';
    
    // SELLING-THE CREDIT 
    public static final String SELLING_CREDIT_ACCOUNTS_RECEIVABLE = '売掛';
    public static final String SELLING_CREDIT_SALES = '売上高';
    
    // SELLING-THE DEBIT 
    public static final String SELLING_DEBIT_ACCOUNTS_RECEIVABLE = '売掛';
    public static final String SELLING_DEBIT_ORDINARY_ACCOUNT = '普通預金';
    
	public static final String SEARCH_ENGINE_FCL_IMPORT = 'FCL輸入';
    public static final String SEARCH_ENGINE_FCL_EXPORT = 'FCL輸出';
    
    public static final String CURRENCY_JPY = 'JPY';
    public static final String CURRENCY_USD = 'USD';
    
    /*
     * SERVICE MASTER
     */ 
    public static final String UNIT_CONTAINER = 'コンテナ';
    public static final String UNIT_RTON = 'R/TON';
    
    public static final String PRODUCT_TAX = '課税';
    public static final String PRODUCT_FREE_TAX = '免税';
    public static final String PRODUCT_NON_TAX = '非課税';
    public static final String PRODUCT_ADVANCED_TAX = '立替';
    
    public static final String DUAL_PRODUCT_TAX = 'TAX(課税)';
    public static final String DUAL_PRODUCT_FREE_TAX = 'Tax Free(免税)';
    public static final String DUAL_PRODUCT_NON_TAX = 'Non-Tax(非課税)';
    public static final String DUAL_PRODUCT_ADVANCED_TAX = 'Advanced Payment(立替)';
    
    public static final String SUB_CAT_CY_CHARGE = 'CY CHARGE';
    
    public static final String FORWARDING_SERVICE_PROVIDER_US = '自社フォワーディング(Forwarding by us)';
    public static final String FORWARDING_SERVICE_PROVIDER_OTHERS = '他社フォワーディング(Forwarding by others)';

    /*
     * Purchasing Order
     */
    public static final String PO_PAYMENT_SETTLED = 'Payment Settled';
}