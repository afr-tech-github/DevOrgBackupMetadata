public with sharing class PrintCommercialInvoiceController {
    public String templateType{get;set;}
    public String typeDoc {get; set;}
    public String language {get; set;}
    public String curr{get; set;}
    public String shipmentId{get; set;}
    public String recordTypeName{get; set;}
    public Boolean hideUnnecessaryInfo{get;set;}
    public String customerAddress{get;set;}
    public String customerId {get; set;}
    public Map<String, String> translations { get; set;}
    public Account customer{get; set;}
    public CustomObject1__c shipment{get;set;}
    public SALES_ORDER__c salesOrder{get;set;}
    public List<TRSBill__c> listTRSBills{get;set;}
    public List<AnkenMeisai__c> listBill{get; set;}
    public List<BillWrapper> listBillWrapper{get;set;}
    public List<AnkenMeisai__c> listBillOnBehalf{get; set;}
    public List<BillWrapper> listBillWrapperOnBehalf{get;set;}
    public Decimal grossWeightTotal{get;set;}
    public Decimal unitPriceTotal{get;set;}
    public Decimal amountOfSellUSDTotal{get;set;}
    public Decimal subTotalUSD{get;set;}
    public Decimal grandTotalUSD{get;set;}
    public Decimal subTotalVND{get;set;}
    public Decimal grandTotalVND{get;set;}
    public String grandTotalVNDInVNWording{get;set;}
    public String grandTotalVNDInENWording{get;set;}
    public String grandTotalUSDInENWording{get;set;}
    public String grandTotalUSDInVNWording{get;set;}
    private static Set<String> accountFieldSet = new Set<String>();
    private static Set<String> ankenFieldSet = new Set<String>();
    private static Set<String> ankenMeisaiFieldSet = new Set<String>();
    public String formatStringUSDDetail{get;set;}
    public String formatStringVND{get;set;}
    public String formatStringUSDTotal{get;set;}
    public String bankType{get;set;}
    public Boolean showChargeableWeight{get;set;}
    public String contentType{get;set;}
    public Boolean showFooter{get;set;}
    public String sayContext{get;set;}
    
    static{
        accountFieldSet.add('EnglishCompanyName__c');
        accountFieldSet.add('Name');
        accountFieldSet.add('EnglishAddress__c');
        accountFieldSet.add('Phone');
        accountFieldSet.add('Fax');
        accountFieldSet.add('TAX_CODE__c');
        accountFieldSet.add('BillingStreet');
        accountFieldSet.add('BillingCity');
        accountFieldSet.add('BillingState');
        accountFieldSet.add('BillingPostalCode');
        accountFieldSet.add('BillingCity');
        accountFieldSet.add('BillingCountry');

        //========================

        ankenFieldSet.add('ID__c');
        ankenFieldSet.add('QuotationVer__c');
        ankenFieldSet.add('JobRequestID__c');
        ankenFieldSet.add('REFNO__c');
        ankenFieldSet.add('SalesAccountedDate__c');
        ankenFieldSet.add('DeadlineForPaymentOfInvoices__c');
        ankenFieldSet.add('HBL_Number_SEA_AIR__c');
        ankenFieldSet.add('MBL_Number_SEA_AIR__c');
        ankenFieldSet.add('Vessle__c');
        ankenFieldSet.add('No_Voyage_Flight__c');
        ankenFieldSet.add('POL__r.Name');
        ankenFieldSet.add('POL__r.Country_Name__c');
        ankenFieldSet.add('Place_Of_Delivery__r.Name');
        ankenFieldSet.add('Place_Of_Delivery__r.Country_Name__c');
        ankenFieldSet.add('ETD__c ');
        ankenFieldSet.add('ETA__c');
        ankenFieldSet.add('CustomsClearanceDeclarationNo__c');
        ankenFieldSet.add('TranporationType__c');
        ankenFieldSet.add('Container__c');
        ankenFieldSet.add('ContainerNumber__c');
        ankenFieldSet.add('Container2__c');
        ankenFieldSet.add('ContainerNumber2__c');
        ankenFieldSet.add('Container3__c');
        ankenFieldSet.add('ContainerNumber3__c');
        ankenFieldSet.add('Container4__c');
        ankenFieldSet.add('ContainerNumber4__c');
        ankenFieldSet.add('carton__c');
        ankenFieldSet.add('UnitType__c');
        ankenFieldSet.add('weight__c');
        ankenFieldSet.add('CBM__c');
        ankenFieldSet.add('PriceTerms__c');
        ankenFieldSet.add('ExchangeRate__c');
        ankenFieldSet.add('SeikyusyoRemark__c');
        ankenFieldSet.add('POD__r.Name');
        ankenFieldSet.add('POD__r.Country_Name__c');
        ankenFieldSet.add('POL__r.Name');
        ankenFieldSet.add('POL__r.Country_Name__c');
        ankenFieldSet.add('Chargable_weight__c');
        ankenFieldSet.add('RecordType.DeveloperName');
        ankenFieldSet.add('MASTER_BOOKINGNO__c');
        ankenFieldSet.add('HouseBookingNo__c');
        ankenFieldSet.add('CONTAINERSEALNO__c');
        //======================
        ankenMeisaiFieldSet.add('SeikyuBangou__c');
        ankenMeisaiFieldSet.add('InsatuyouSyohinEng__c');
        ankenMeisaiFieldSet.add('ADVANCE_PAYMENT_ON_BEHALF_OF__c');
        ankenMeisaiFieldSet.add('InsatuyouSyohin__c ');
        ankenMeisaiFieldSet.add('Suryo__c');
        ankenMeisaiFieldSet.add('ChargeUnitInPrint__c');
        ankenMeisaiFieldSet.add('SellTankaUSD__c');
        ankenMeisaiFieldSet.add('SellTankaJPY__c');
        ankenMeisaiFieldSet.add('curr__c');
        ankenMeisaiFieldSet.add('SellAmountUSD__c');
        ankenMeisaiFieldSet.add('SellAmountJPN__c');
        ankenMeisaiFieldSet.add('TaxInitial__c ');
        ankenMeisaiFieldSet.add('SellInTaxAmount_USD__c');
        ankenMeisaiFieldSet.add('SellInTaxAmountJPY__c');
        ankenMeisaiFieldSet.add('Description__c');
        ankenMeisaiFieldSet.add('SellInTaxAmountJPY__c');
        ankenMeisaiFieldSet.add('SellInTaxAmount_USD__c');
        ankenMeisaiFieldSet.add('ContainerSizeFormula__c');
        ankenMeisaiFieldSet.add('ChargeUnitFormula__c');
        ankenMeisaiFieldSet.add('Tariff__r.Zeibunrui__c');
        
            
    }
    public PrintCommercialInvoiceController() {
        showChargeableWeight = false;
        formatStringUSDDetail = '{0,number,###,###,###,##0.000}';
        formatStringVND = '{0,number,###,###,###,###}';
        formatStringUSDTotal = '{0,number,###,###,###,##0.00}';
        customer = new Account();
        shipment = new CustomObject1__c();
        listBill = new List<AnkenMeisai__c>();
        listBillOnBehalf = new List<AnkenMeisai__c>();
        listBillWrapper = new List<BillWrapper>();
        listBillWrapperOnBehalf = new List<BillWrapper>();
        customerAddress = '';
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
        salesOrder = getSalesOrder();
        listTRSBills = getListTRSBills();
        typeDoc = ApexPages.currentPage().getParameters().get('typeDoc');
        language = ApexPages.currentPage().getParameters().get('language');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        curr = ApexPages.currentPage().getParameters().get('curr');
        bankType = ApexPages.currentPage().getParameters().get('bankType');
        templateType = ApexPages.currentPage().getParameters().get('templateType');
        contentType = ApexPages.currentPage().getParameters().get('contentType');
        showFooter = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showFooter'));
        system.debug('showFooter: '+showFooter);
        contentType = contentType?.replace(',', '');
        grossWeightTotal = 0;
        unitPriceTotal = 0;
        amountOfSellUSDTotal = 0;
        sayContext = '';
        if(salesOrder != null && salesOrder.TotalAmountofSelling_inwords__c != null) {
      		sayContext = salesOrder.TotalAmountofSelling_inwords__c.toUppercase().replace('DOLLARS', '').replace('DOLLAR', '').replace('U.S ', 'U.S DOLLARS');
      	}
        
        for(TRSBill__c trsBill : listTRSBills){
            if(trsBill.ChargeUnitTotal__c != null) {
                grossWeightTotal = grossWeightTotal + trsBill.ChargeUnitTotal__c;
            }
            if(trsBill.UnitPriceOfSellUSD__c != null) {
                unitPriceTotal = unitPriceTotal + trsBill.UnitPriceOfSellUSD__c;
            }
            if(trsBill.TotalAmountOfSellUSD__c != null) {
                amountOfSellUSDTotal  = amountOfSellUSDTotal + trsBill.TotalAmountOfSellUSD__c;
            }
            
        }
        if(typeDoc == null){
            typeDoc = 'invoice';
        }
        if(language == null){
            language = 'en';
        }
        if(curr == null){
            curr = 'both';
        }
        if(bankType == null){
            bankType ='local1';
        }
        if(templateType == null){
            templateType ='official';
        }
        translations = getTranslationMap(language);
        if(!String.isBlank(customerId) && !String.isBlank(shipmentId)){
            customer = getAccount();
            List<String> addresses = new List<String>();
            if(!String.isBlank(customer.BillingStreet)){
                addresses.add(customer.BillingStreet);
            }
            if(!String.isBlank(customer.BillingCity)){
                addresses.add(customer.BillingCity);
            }
            if(!String.isBlank(customer.BillingState)){
                addresses.add(customer.BillingState);
            }
            if(!String.isBlank(customer.BillingPostalCode)){
                addresses.add(customer.BillingPostalCode);
            }
            if(!String.isBlank(customer.BillingCountry)){
                addresses.add(customer.BillingCountry);
            }
            if(!addresses.isEmpty()){
                customerAddress = String.join(addresses, ', ');
            }
            shipment = getShipment();
            string nameSpacePrefix = [SELECT NamespacePrefix FROM Organization limit 1].NamespacePrefix;
            if(shipment !=null){
                nameSpacePrefix = nameSpacePrefix!=null?nameSpacePrefix:'clofor_com_cfs';
                recordTypeName = Schema.getGlobalDescribe().get(nameSpacePrefix +'__'+'SALES_ORDER__c').getDescribe().getRecordTypeInfosById().get(salesOrder.RecordTypeId).getName();
            }else{
                recordTypeName = 'Null';
            }
			hideUnnecessaryInfo = false;
            if(recordTypeName !='Logistics Service(Lock)' && recordTypeName !='Logistics Service'){
                hideUnnecessaryInfo = true;
            }
            system.debug('hideUnnecessaryInfo: '+hideUnnecessaryInfo);
            Set<String> recordtypeSet = new Set<String>{'OutAir', 'OutAir_lock', 'InAir', 'airimportlock', 'Express', 'ExpressLock'};
            if(shipment != null && recordtypeSet.contains(shipment.RecordType.DeveloperName) ){
                showChargeableWeight = true;
            }
            listBill = getBillList();
            subTotalUSD = 0;
            subTotalVND = 0;
            grandTotalUSD = 0;
            grandTotalVND = 0;
            for(AnkenMeisai__c bill : listBill){
                BillWrapper newBill= new BillWrapper(bill);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }
                listBillWrapper.add(newBill);
                if(newBill.curr == 'USD'){
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }
                if(newBill.curr == 'VND'){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }
                
            }
            listBillOnBehalf = getBillListOnBehalf();
            for(AnkenMeisai__c bill : listBillOnBehalf){
                BillWrapper newBill = new BillWrapper(bill);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }
                listBillWrapperOnBehalf.add(newBill) ;
                if(newBill.curr == 'USD'){
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }
                if(newBill.curr == 'VND'){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }

            }
            subTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSD = grandTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSDInENWording = NumbericUtils.readUSDAmountInEn(grandTotalUSD);
            grandTotalUSDInVNWording = NumbericUtils.readUSDAmountInVN(grandTotalUSD);
            grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND);
            grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND');
        }
    }

    private Account getAccount(){
        Account acc = new Account();
        String sqlStr = 'SELECT Id, ' + String.join(new List<String>(accountFieldSet), ',');
        sqlStr += ' FROM Account WHERE Id = \''+ StringUtils.escapeSingleQuotes(customerId) + '\'';
        List<Account> accs = Database.query(sqlStr);
        if(!accs.isEmpty()){
            acc = accs[0];
        }
        return acc;
    }
    
    private SALES_ORDER__c getSalesOrder(){
        SALES_ORDER__c so = new SALES_ORDER__c();
        so = [SELECT
              RecordTypeId,
              ContractID__r.SellerCompany__c,
              ContractID__r.SellerCompany__r.EnglishAddress__c,
              ContractID__r.SellerCompany__r.Name,
              CommercialInvoiceNo__c,
              InvoiceDate__c,
              ContractID__r.ContractNumber__c,
              ContractID__r.ContractSignedDate__c,
              CustomerCompanyName__c,
              CustomerCompanyName__r.Name,
              CustomerAddress__c,
              ReceiptancePaymentType__c,
              PaymentCondition__c,
              LCNo__c,
              LCDate__c,
              NotifyParty__c,
              NotifyParty__r.Name,
              NotifyPartysAddress__c,
              PortofLoading__r.Name,
              PortofLoading__r.Country_Name__c,
              PortofDischarge__r.Name,
              PortofDischarge__r.Country_Name__c,
              CommodityDescriptionofGoods__c,
              TotalAmountofSelling_inwords__c,
              Notes__c,
              ChargeUnit__c,
              UnitpriceChargeUnit__c
              FROM SALES_ORDER__c
              WHERE Id =: shipmentId
             ];
        system.debug('SALES_ORDER__c: '+ so);
        return so;
    }
    
    private List<TRSBill__c> getListTRSBills(){
        List<TRSBill__c> lst = new List<TRSBill__c>();
        lst = [SELECT 
              BillNameAtPrintENG__c,
               ProductNamedetailatprintEng__c,
              GrossWeightMT__c,
              UnitPriceOfSellUSD__c,
               ChargeUnitTotal__c,
              TotalAmountOfSellUSD__c
              FROM TRSBill__c
              WHERE SalesOrderID__c =: shipmentId];
        system.debug('List<TRSBill__c>: '+ lst.size());
        return lst;
    }

    private CustomObject1__c getShipment(){
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, RecordTypeId, ' + String.join(new List<String>(ankenFieldSet), ',');
        sqlStr += ' FROM CustomObject1__c WHERE Id = \''+ StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        List<CustomObject1__c> sos = Database.query(sqlStr);
        if(!sos.isEmpty()){
            so = sos[0];
        }
        return so;
    }
    private List<AnkenMeisai__c> getBillListOnBehalf(){
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, ' + String.join(new List<String>(ankenMeisaiFieldSet), ',');
        sqlStr += ' FROM AnkenMeisai__c WHERE Anken__c = \''+ StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        if(typeDoc =='invoice' || typeDoc =='debit'){
            sqlStr += ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        }
        if(curr != 'Both'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else{
            sqlStr += ' AND (curr__c = \'VND\' OR curr__c = \'USD\')';
        }
        if(typeDoc =='credit'){
            
            sqlStr += ' AND PaymentTo__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        }

        sqlStr += ' AND PrintFlag__c = TRUE AND ADVANCE_PAYMENT_ON_BEHALF_OF__c = true  ORDER BY SeikyuBangou__c ASC Limit 1000';
        List<AnkenMeisai__c> bills = Database.query(sqlStr);
        if(!bills.isEmpty()){
            return bills;
        }
        return new List<AnkenMeisai__c>();
    }

    private List<AnkenMeisai__c> getBillList(){
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, ' + String.join(new List<String>(ankenMeisaiFieldSet), ',');
        sqlStr += ' FROM AnkenMeisai__c WHERE Anken__c = \''+ StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        if(typeDoc =='invoice' || typeDoc =='debit'){
            sqlStr += ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        }
        if(curr != 'Both'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else{
            sqlStr += ' AND (curr__c = \'VND\' OR curr__c = \'USD\')';
        }
        if(typeDoc =='credit'){
            
            sqlStr += ' AND PaymentTo__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        }

        sqlStr += ' AND PrintFlag__c = TRUE AND ADVANCE_PAYMENT_ON_BEHALF_OF__c = false  ORDER BY SeikyuBangou__c ASC Limit 1000';
        List<AnkenMeisai__c> bills = Database.query(sqlStr);
        if(!bills.isEmpty()){
            return bills;
        }
        return new List<AnkenMeisai__c>();
    }
    private static Map<String, String > getTranslationMap(String language){
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        translateMapResult.put(null, '');
        for(String key : translate.keySet()){
            if(key.contains('wms') || key.contains('unit_translation')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
            
        }
        return translateMapResult; 
    }

    public class BillWrapper{
        public String description{get;set;}
        public Decimal no{get;set;}
        public String descriptionEng{get;set;}
        public Decimal quantity{get;set;}
        public String unit{get;set;}
        public Decimal unitPriceUSD{get;set;}
        public Decimal unitPriceVND{get;set;}
        public String curr{get;set;}
        public Decimal amountUSD{get;set;}
        public Decimal amountVND{get;set;}
        public Decimal tax{get;set;}
        public Decimal totalAmountUSD{get;set;}
        public Decimal totalAmountVND{get;set;}
        public String note{get;set;}
        public BillWrapper(){

        }
        public BillWrapper( AnkenMeisai__c bill){
            no = bill.SeikyuBangou__c;
            description = bill.InsatuyouSyohin__c;
            descriptionEng = bill.InsatuyouSyohinEng__c;
            quantity = bill.Suryo__c;
            unit = bill.ChargeUnitFormula__c;
            if(bill.ChargeUnitFormula__c == 'Container' || bill.ChargeUnitFormula__c == 'コンテナ'){
                unit = bill.ContainerSizeFormula__c;
            }
            unitPriceUSD = bill.SellTankaUSD__c == null? 0 : bill.SellTankaUSD__c;
            unitPriceVND = bill.SellTankaJPY__c == null? 0 : bill.SellTankaJPY__c;
            unitPriceUSD = unitPriceUSD.setScale(3, RoundingMode.HALF_UP);
            curr = bill.curr__c;
            amountUSD = bill.SellAmountUSD__c == null? 0 : bill.SellAmountUSD__c;
            amountVND = bill.SellAmountJPN__c == null? 0 : bill.SellAmountJPN__c;
            amountUSD = amountUSD.setScale(3, RoundingMode.HALF_UP);
            tax = bill.TaxInitial__c;
            if(bill.Tariff__r.Zeibunrui__c == 'Non-Tax(非課税)'){
                tax = null;
            }
            if(bill.Tariff__r.Zeibunrui__c == 'Tax Free(免税)'){
                tax = 0;
            }
            totalAmountUSD = bill.SellInTaxAmount_USD__c == null? 0 : bill.SellInTaxAmount_USD__c;
            totalAmountVND = bill.SellInTaxAmountJPY__c == null? 0 : bill.SellInTaxAmountJPY__c;
            totalAmountUSD = totalAmountUSD.setScale(3, RoundingMode.HALF_UP);
            note = bill.Description__c;

        }
    }
}