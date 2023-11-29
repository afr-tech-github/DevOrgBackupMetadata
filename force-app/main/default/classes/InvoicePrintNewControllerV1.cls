public with sharing class InvoicePrintNewControllerV1 {
    private static final Integer MAX_FIELD_IN_DETAIL = 8;
    public String templateType{get;set;}
    public Boolean showContainer{get;set;}
    public String typeDoc {get; set;}
    public String language {get; set;}
    public String curr{get; set;}
    public String shipmentId{get; set;}
    public String recordTypeName{get; set;}
    public Boolean hideUnnecessaryInfo{get;set;}
    public String customerAddress{get;set;}
    public String customerId {get; set;}
    public String localCurr {get; set;}
    public Map<String, String> translations { get; set;}
    public String sayUppercaseLabel{get; set;}
    public Account customer{get; set;}
    public CustomObject1__c shipment{get;set;}
    public List<AnkenMeisai__c> listBill{get; set;}
    public List<BillWrapper> listBillWrapper{get;set;}
    public List<AnkenMeisai__c> listBillOnBehalf{get; set;}
    public List<BillWrapper> listBillWrapperOnBehalf{get;set;}
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
    public String houseBookingNos{get;set;}
    public String containerNosandtypes{get;set;}

    public Map<String, Boolean> selection1Map { get; set; }
    public Map<String, Boolean> selection2Map { get; set; } 

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
        ankenFieldSet.add('ContainerNo__c');
        
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
    public InvoicePrintNewControllerV1() {
        selection1Map = new Map<String, Boolean> {'row1' => false, 'row2' => false, 'row3' => false, 'row4' => false
                                                    ,'row5' => false, 'row6' => false, 'row7' => false, 'row8' => false
                                                    ,'row9' => false, 'row10' => false, 'row11' => false, 'row12' => false
                                                    ,'row13' => false, 'row14' => false, 'row15' => false, 'row16' => false};
        selection2Map = new Map<String, Boolean> {'row1' => false, 'row2' => false, 'row3' => false, 'row4' => false
                                                    ,'row5' => false, 'row6' => false, 'row7' => false, 'row8' => false
                                                    ,'row9' => false, 'row10' => false, 'row11' => false, 'row12' => false
                                                    ,'row13' => false, 'row14' => false, 'row15' => false, 'row16' => false};
        houseBookingNos = '';
        containerNosandtypes ='';
        showChargeableWeight = false;
        formatStringUSDDetail = '{0,number,###,###,###,##0.00}';
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
        typeDoc = ApexPages.currentPage().getParameters().get('typeDoc');
        language = ApexPages.currentPage().getParameters().get('language');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        curr = ApexPages.currentPage().getParameters().get('curr');
        bankType = ApexPages.currentPage().getParameters().get('bankType');
        templateType = ApexPages.currentPage().getParameters().get('templateType');
        if(ApexPages.currentPage().getParameters().get('showContainer') != null){
            showContainer = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showContainer'));
        }
        contentType = ApexPages.currentPage().getParameters().get('contentType');
        contentType = contentType?.replace(',', '');      
        //Get local curr
        List<Site_Custom_Settings__c> lstSiteCustomSettings = [Select Local_Currency__c, Id from Site_Custom_Settings__c limit 1];
        if(lstSiteCustomSettings.size()>0){
            Site_Custom_Settings__c sct = lstSiteCustomSettings[0];
            localCurr = sct.Local_Currency__c;
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
        if(showContainer == null){
            showContainer =false;
        }
        translations = getTranslationMap(language);
        sayUppercaseLabel = translations.get('say').toUppercase();
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
                recordTypeName = Schema.getGlobalDescribe().get(nameSpacePrefix +'__'+'CustomObject1__c').getDescribe().getRecordTypeInfosById().get(shipment.RecordTypeId).getName();
            }else{
                recordTypeName = 'Null';
            }
            hideUnnecessaryInfo = false;
            if(recordTypeName !='Logistics Service(Lock)' && recordTypeName !='Logistics Service'){
                hideUnnecessaryInfo = true;
            }
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
                }else if(newBill.curr == localCurr){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }
                
                /*
{
localCurr = newBill.curr;
subTotalVND += newBill.amountVND;
grandTotalVND += newBill.totalAmountVND;
}
if(newBill.curr == 'VND'){
subTotalVND += newBill.amountVND;
grandTotalVND += newBill.totalAmountVND;
}
*/
                
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
                }else if(newBill.curr == localCurr){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }
                
                /*
{
localCurr = newBill.curr;
subTotalVND += newBill.amountVND;
grandTotalVND += newBill.totalAmountVND;
}

if(newBill.curr == 'VND'){
subTotalVND += newBill.amountVND;
grandTotalVND += newBill.totalAmountVND;
}
*/
                
            }
            subTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSD = grandTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSDInENWording = NumbericUtils.readUSDAmountInEn(grandTotalUSD).toUpperCase();
            grandTotalUSDInVNWording = NumbericUtils.readUSDAmountInVN(grandTotalUSD).toUpperCase();
            grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND).toUpperCase();
            grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND').toUpperCase();

            // For rendering in VF
            // Set map SELECTION 1          
            List<String> filedSelected1 = new List<String>();
            List<String> filedSelected2 = new List<String>();

            if (String.isNotBlank(houseBookingNos)) {
                selection1Map.put('row1', true);
                filedSelected1.add('row1');
            }

            if (hideUnnecessaryInfo && shipment.HBL_Number_SEA_AIR__c != null) {
                selection1Map.put('row2', true);
                filedSelected1.add('row2');
            }

            if (hideUnnecessaryInfo && shipment.MBL_Number_SEA_AIR__c != null) {
                selection1Map.put('row3', true);
                filedSelected1.add('row3');
            }

            if (hideUnnecessaryInfo && (shipment.Vessle__c != null || shipment.No_Voyage_Flight__c != null)) {
                selection1Map.put('row4', true);
                filedSelected1.add('row4');
            }

            if (shipment.POL__r.Name != null && shipment.POL__r.Country_Name__c != null) {
                selection1Map.put('row5', true);
                filedSelected1.add('row5');
            }

            if (shipment.POD__r.Name != null && shipment.POD__r.Country_Name__c != null) {
                selection1Map.put('row6', true);
                filedSelected1.add('row6');
            }
            
            if (hideUnnecessaryInfo && (shipment.Place_Of_Delivery__r.Name != null || shipment.Place_Of_Delivery__r.Country_Name__c != null)) {
                selection1Map.put('row7', true);
                filedSelected1.add('row7');
            }

            if (shipment.ETD__c != null && shipment.ETA__c != null) {
                selection1Map.put('row8', true);
                filedSelected1.add('row8');
            } 

            // Set map SELECTION 2
            if (String.isNotBlank(recordTypeName)) {
                selection2Map.put('row1', true);
                filedSelected2.add('row1');
            }

            if (hideUnnecessaryInfo && shipment.PriceTerms__c != null) {
                selection2Map.put('row2', true);
                filedSelected2.add('row2');
            }

            if (shipment.CustomsClearanceDeclarationNo__c != null) {
                selection2Map.put('row3', true);
                filedSelected2.add('row3');
            }
            
            if (shipment.TranporationType__c != null) {
                selection2Map.put('row4', true);
                filedSelected2.add('row4');
            }

            if (shipment.carton__c != null) {
                selection2Map.put('row5', true);
                filedSelected2.add('row5');
            }

            if ((shipment.weight__c != null && !showChargeableWeight) || (shipment.chargable_weight__c != null && showChargeableWeight)) {
                selection2Map.put('row6', true);
                filedSelected2.add('row6');
            }

            if (shipment.CBM__c != null) {
                selection2Map.put('row7', true);
                filedSelected2.add('row7');
            }

            if (hideUnnecessaryInfo && (shipment.ExchangeRate__c != 0 && shipment.ExchangeRate__c != null)) {
                selection2Map.put('row8', true);
                filedSelected2.add('row8');
            }
            
            Integer totalSelected1 = filedSelected1.size();
            Integer totalSelected2 = filedSelected2.size();
            Integer delta = Math.abs(totalSelected1 - totalSelected2);

            if (delta > 0) {
                Integer fieldMod = delta / 2;
                Integer i = 1;

                if (totalSelected1 > totalSelected2) {
                    while (fieldMod > 0) {
                        String key = filedSelected1[totalSelected1 - i];
                        doChangeDisplay(selection1Map, selection2Map, key);                     

                        i++;
                        fieldMod--;
                    }
                }  else if (totalSelected2 > totalSelected1) {
                    fieldMod += Math.mod(delta, 2);
                    while (fieldMod > 0) {
                        String key = filedSelected2[totalSelected2 - i];
                        doChangeDisplay(selection2Map, selection1Map, key);                    

                        i++;
                        fieldMod--;
                    }
                }
            }
        }
        /*
if(listBillWrapperOnBehalf.isEmpty()){
listBillWrapperOnBehalf.add(new BillWrapper());
}
if(listBillWrapper.isEmpty()){
listBillWrapper.add(new BillWrapper());
}
*/
    }

    private void doChangeDisplay(Map<String, Boolean> oldMap, Map<String, Boolean> newMap, String key) {
        oldMap.put(key, false);    
        Integer index = Integer.valueOf(key.substringAfter('row')) + MAX_FIELD_IN_DETAIL;
        newMap.put('row' + index, true);

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
    
    private CustomObject1__c getShipment(){
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, RecordTypeId, (select id,name, MasterBkg__r.MasterBookingNo__c from House_Bkg__r), (select id, Container_NO__c, Container__c from Container_Info__r), ' + String.join(new List<String>(ankenFieldSet), ',');
        sqlStr += ' FROM CustomObject1__c WHERE Id = \''+ StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        List<CustomObject1__c> sos = Database.query(sqlStr);
        if(!sos.isEmpty()){
            so = sos[0];
            if(!so.House_Bkg__r.isEmpty()){
                for(HouseBkg__c houseBkg: so.House_Bkg__r){
                    if(houseBkg.MasterBkg__r.MasterBookingNo__c != null){
                        houseBookingNos += (houseBookingNos != '' ? '/' : '') + houseBkg.MasterBkg__r.MasterBookingNo__c;
                    }
                }
            }
            if(houseBookingNos == '' && so.MASTER_BOOKINGNO__c != null && so.MASTER_BOOKINGNO__c != ''){
                houseBookingNos = so.MASTER_BOOKINGNO__c;
            }
            if(!so.Container_Info__r.isEmpty()){
                for(Container_Info__c container_Info: so.Container_Info__r){
                    if(container_Info.Container_NO__c != null){
                        containerNosandtypes += (containerNosandtypes != '' ? ', ' : '') + container_Info.Container_NO__c;
                        if(container_Info.Container__c != null){
                            containerNosandtypes += (containerNosandtypes != '' ? '/' : '') + container_Info.Container__c;
                        }
                    }else{
                        if(container_Info.Container__c != null){
                            containerNosandtypes += (containerNosandtypes != '' ? ', ' : '') + container_Info.Container__c;
                        }
                    }
                }
            }
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
        if(curr == 'USD'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else if(curr == 'Both'){
            sqlStr += ' AND (curr__c = \''+ localCurr +'\' OR curr__c = \'USD\')';
        }else{
            sqlStr += ' AND (curr__c != \'USD\')';
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
        if(curr == 'USD'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else if(curr == 'Both'){
            sqlStr += ' AND (curr__c = \''+ localCurr +'\' OR curr__c = \'USD\')';
        }else{
            sqlStr += ' AND (curr__c != \'USD\')';
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