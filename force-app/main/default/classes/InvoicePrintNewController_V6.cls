public with sharing class InvoicePrintNewController_V6 {
    public String templateType{get;set;}
    public String typeDoc {get; set;}
    public String docService {get; set;}
    public Boolean isShowVAT {get; set;}
    public String language {get; set;}
    public Boolean showContainer{get;set;}
    public Boolean showLessTax{get;set;}
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
    public String etdFormattedDate{get;set;}
    public String etaFormattedDate{get;set;}
    public String bookDateFormatted{get;set;}
    public String paymentDueDateFormatted{get;set;}
    public List<AnkenMeisai__c> listBill{get; set;}
    public List<BillWrapper> listBillWrapper{get;set;}
    public List<AnkenMeisai__c> listBillOnBehalf{get; set;}
    public List<BillWrapper> listBillWrapperOnBehalf{get;set;}
    public Decimal subTotalUSD{get;set;}
    public Decimal subVATUSD{get;set;}
    public Decimal grandTotalUSD{get;set;}
    public Decimal subTotalVND{get;set;}
    public Decimal subVATLocal{get;set;}
    public Decimal grandTotalVND{get;set;}
    public String grandTotalVNDInVNWording{get;set;}
    public String grandTotalVNDInENWording{get;set;}
    public String grandTotalUSDInENWording{get;set;}
    public String grandTotalUSDInVNWording{get;set;}
    public String grandTotalPHPInENWording{get;set;}
    public String grandTotalPHPInVNWording{get;set;}
    private static Set<String> accountFieldSet = new Set<String>();
    private static Set<String> ankenFieldSet = new Set<String>();
    private static Set<String> ankenMeisaiFieldSet = new Set<String>();
    public String formatStringUSDDetail{get;set;}
    public String formatStringVND{get;set;}
    public String formatStringUSDTotal{get;set;}
    public String bankType{get;set;}
    public String invoiceNo{get;set;}
    public Boolean showChargeableWeight{get;set;}
    public String contentType{get;set;}
    public String houseBookingNos{get;set;}
    public String companyAddress {get; set;}
    public String containerNosandtypes{get;set;}
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
        ankenMeisaiFieldSet.add('clofor_com_cfs__KawaseSel__c');
        ankenMeisaiFieldSet.add('SeikyuBangou__c');
        ankenMeisaiFieldSet.add('Invoice_No__c');
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
        ankenMeisaiFieldSet.add('SellTaxNum__c');
        ankenMeisaiFieldSet.add('SellTaxNum_USD__c');
        ankenMeisaiFieldSet.add('TaxInitial__c ');
        ankenMeisaiFieldSet.add('Description__c');
        ankenMeisaiFieldSet.add('ContainerSizeFormula__c');
        ankenMeisaiFieldSet.add('ChargeUnitFormula__c');
        ankenMeisaiFieldSet.add('Tariff__r.Zeibunrui__c');
        
            
    }
    public InvoicePrintNewController_V6() {
        containerNosandtypes ='';
        houseBookingNos = '';
        showChargeableWeight = false;
        formatStringUSDDetail = '{0,number,###,###,###,##0.00}';
        formatStringVND = '{0,number,###,###,###,##0.00}';
        formatStringUSDTotal = '{0,number,###,###,###,##0.00}';
        customer = new Account();
        shipment = new CustomObject1__c();
        listBill = new List<AnkenMeisai__c>();
        listBillOnBehalf = new List<AnkenMeisai__c>();
        listBillWrapper = new List<BillWrapper>();
        listBillWrapperOnBehalf = new List<BillWrapper>();
        customerAddress = '';
        isShowVAT = false;
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
        typeDoc = ApexPages.currentPage().getParameters().get('typeDoc');
        docService = ApexPages.currentPage().getParameters().get('docService');
        language = ApexPages.currentPage().getParameters().get('language');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        curr = ApexPages.currentPage().getParameters().get('curr');
        bankType = ApexPages.currentPage().getParameters().get('bankType');
        templateType = ApexPages.currentPage().getParameters().get('templateType');
        contentType = ApexPages.currentPage().getParameters().get('contentType');
        contentType = contentType?.replace(',', '');
        invoiceNo = ApexPages.currentPage().getParameters().get('showInvoiceNo');
        showContainer = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showContainer'));
        showLessTax = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showLessTax'));    
        //Get local curr
        List<Site_Custom_Settings__c> lstSiteCustomSettings = [Select BillingDefaultCurrency__c, Id from Site_Custom_Settings__c limit 1];
        if(lstSiteCustomSettings.size()>0){
            Site_Custom_Settings__c sct = lstSiteCustomSettings[0];
            localCurr = sct.BillingDefaultCurrency__c;
        }
        // Get company address from Metadata Company_Address__mdt
        Site_Metadata_Types__mdt recordCompanyAdrress = [Select Address__c From Site_Metadata_Types__mdt limit 1];
        if(recordCompanyAdrress?.Address__c != null){
            companyAddress = recordCompanyAdrress.Address__c;
        }
        if(typeDoc == null){
            typeDoc = 'billingInvoice';
        }
        if(docService == null) {
            docService = 'both';
        }
        if (docService == 'both' || docService == 'service-vat') {
            isShowVAT = true;
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
        if(invoiceNo == null){
            invoiceNo ='1';
        }
        if(showContainer == null){
            showContainer =false;
        }
        if(showLessTax == null || typeDoc == 'statementOfAccount'){
            showLessTax =false;
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
            // Format date for ETD and ETA
            if(shipment.ETD__c != null){
                etdFormattedDate = formattedDate(shipment.ETD__c);
            } else {
                etdFormattedDate = '';
            }
            if(shipment.ETA__c != null){
                etaFormattedDate = formattedDate(shipment.ETA__c);
            } else {
                etaFormattedDate = '';
            }
            if(shipment.SalesAccountedDate__c != null){
                bookDateFormatted = formattedDate(shipment.SalesAccountedDate__c);
            } else {
                bookDateFormatted = '';
            }
            if(shipment.DeadlineForPaymentOfInvoices__c != null){
                paymentDueDateFormatted = formattedDate(shipment.DeadlineForPaymentOfInvoices__c);
            } else {
                paymentDueDateFormatted = '';
            }
            
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
            system.debug('hideUnnecessaryInfo: '+hideUnnecessaryInfo);
            Set<String> recordtypeSet = new Set<String>{'OutAir', 'OutAir_lock', 'InAir', 'airimportlock', 'Express', 'ExpressLock'};
            if(shipment != null && recordtypeSet.contains(shipment.RecordType.DeveloperName) ){
                showChargeableWeight = true;
            }
            listBill = getBillList();
            System.debug('listBill: '+listBill.size());
            subTotalUSD = 0;
            subTotalVND = 0;
            subVATUSD = 0;
            subVATLocal = 0;
            grandTotalUSD = 0;
            grandTotalVND = 0;
            for(AnkenMeisai__c bill : listBill){
                BillWrapper newBill= new BillWrapper(bill);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }
                listBillWrapper.add(newBill);
                /*
                if(newBill.curr == 'USD'){
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }else if(newBill.curr == localCurr){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }
                
				//Old one
                if(curr == localCurr) {
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                } else if(curr == 'USD') {
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                } else if(curr == 'Both') {
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }
				*/
                subTotalVND += newBill.amountVND.setScale(2, RoundingMode.HALF_UP);
                grandTotalVND += newBill.totalAmountVND.setScale(2, RoundingMode.HALF_UP);
                subTotalUSD += newBill.amountUSD.setScale(2, RoundingMode.HALF_UP);
                grandTotalUSD += newBill.totalAmountUSD.setScale(2, RoundingMode.HALF_UP);
                subVATUSD += newBill.amountSellTaxUSD.setScale(2, RoundingMode.HALF_UP);
                subVATLocal += newBill.amountSellTaxLocal.setScale(2, RoundingMode.HALF_UP);
            }
            listBillOnBehalf = getBillListOnBehalf();
            System.debug('listBillOnBehalf: '+ listBillOnBehalf.size());
            for(AnkenMeisai__c bill : listBillOnBehalf){
                BillWrapper newBill = new BillWrapper(bill);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }
                // handle Format nummber for USD EXcel issue
                
                listBillWrapperOnBehalf.add(newBill) ;
                /*
                if(newBill.curr == 'USD'){
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }else if(newBill.curr == localCurr){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }
				
				//Old one
                if(curr == localCurr) {
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                } else if(curr == 'USD') {
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                } else if(curr == 'Both') {
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }
				*/
                subTotalVND += newBill.amountVND.setScale(2, RoundingMode.HALF_UP);
                grandTotalVND += newBill.totalAmountVND.setScale(2, RoundingMode.HALF_UP);
                subTotalUSD += newBill.amountUSD.setScale(2, RoundingMode.HALF_UP);
                grandTotalUSD += newBill.totalAmountUSD.setScale(2, RoundingMode.HALF_UP);
                subVATUSD += newBill.amountSellTaxUSD.setScale(2, RoundingMode.HALF_UP);
                subVATLocal += newBill.amountSellTaxLocal.setScale(2, RoundingMode.HALF_UP);
            }
            if(showLessTax) {
                grandTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP) + subVATUSD.setScale(2, RoundingMode.HALF_UP) - (subTotalUSD*2/100).setScale(2, RoundingMode.HALF_UP);
                grandTotalVND = subTotalVND.setScale(2, RoundingMode.HALF_UP) + subVATLocal.setScale(2, RoundingMode.HALF_UP) - (subTotalVND*2/100).setScale(2, RoundingMode.HALF_UP);
            } else {
                grandTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP) + subVATUSD.setScale(2, RoundingMode.HALF_UP);
                grandTotalVND = subTotalVND.setScale(2, RoundingMode.HALF_UP) + subVATLocal.setScale(2, RoundingMode.HALF_UP);
            }

            //subTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSD = grandTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalVND = grandTotalVND.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSDInENWording = NumbericUtils.readUSDAmountInEn(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
            grandTotalUSDInVNWording = NumbericUtils.readUSDAmountInVN(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
            if(localCurr == 'VND') {
                grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND).toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
                grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND').toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
            } else if(localCurr == 'PHP') {
                grandTotalPHPInENWording = NumbericUtils.readPHPAmountInEn(grandTotalVND).toUpperCase();
                grandTotalPHPInVNWording = NumbericUtils.readPHPAmountInVN(grandTotalVND).toUpperCase();
            } else {
                grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND).toUpperCase().replace('VIETNAM DONG', '(' + localCurr+ ')');
                grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND').toUpperCase().replace('VIETNAM DONG', '(' + localCurr+ ')');
            }
            
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

    private CustomObject1__c getShipment(){
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, RecordTypeId, (select id,name, MasterBkg__r.MasterBookingNo__c from House_Bkg__r), (select id, Container_NO__c, Container__c from Container_Info__r), ' + String.join(new List<String>(ankenFieldSet), ',');
        switch on typeDoc {
            when 'billingInvoice' {
                sqlStr += ', Billing_Invoice_Remarks__c';
            }
            when 'debitNote' {
                sqlStr += ', SeikyusyoRemark__c';
            }
            when 'statementOfAccount' {
                sqlStr += ', Statement_of_Account_SOA_Remarks__c';
            }
        }
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
        // String serviceTax = 'TAX(課税)';
        // String serviceNoneTax = 'Non-Tax(非課税)';
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, ' + String.join(new List<String>(ankenMeisaiFieldSet), ',');
        sqlStr += ' FROM AnkenMeisai__c WHERE Anken__c = \''+ StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        sqlStr += ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        sqlStr += ' AND Invoice_No__c = \'' + StringUtils.escapeSingleQuotes(invoiceNo) + '\'';

        // if(typeDoc =='invoice' || typeDoc =='debit'){
        //     sqlStr += ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        // }
        /*
        if(curr == 'USD'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else if(curr == 'Both'){
            sqlStr += ' AND (curr__c = \''+ localCurr +'\' OR curr__c = \'USD\')';
        }else{
            sqlStr += ' AND (curr__c != \'USD\')';
        }
        */
        // if(typeDoc =='credit'){
        //     sqlStr += ' AND PaymentTo__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        // }

        if(docService == 'service-vat') {
            // sqlStr += ' AND Tariff__r.Zeibunrui__c = \'' + serviceTax + '\'';
            sqlStr += ' AND TaxInitial__c != 0';
        }

        if(docService == 'service-none-vat') {
            // sqlStr += ' AND Tariff__r.Zeibunrui__c = \'' + serviceNoneTax + '\'';
            sqlStr += ' AND TaxInitial__c = 0';
        }

        if(docService == 'both') {
            // sqlStr += ' AND (Tariff__r.Zeibunrui__c = \'' + serviceTax + '\' OR Tariff__r.Zeibunrui__c = \'' + serviceNoneTax + '\')';
            // Do nothing
        }

        sqlStr += ' AND PrintFlag__c = TRUE AND ADVANCE_PAYMENT_ON_BEHALF_OF__c = true  ORDER BY SeikyuBangou__c DESC Limit 1000';
        List<AnkenMeisai__c> bills = Database.query(sqlStr);
        if(!bills.isEmpty()){
            return bills;
        }
        return new List<AnkenMeisai__c>();
    }

    private List<AnkenMeisai__c> getBillList(){
        // String serviceTax = 'TAX(課税)';
        // String serviceNoneTax = 'Non-Tax(非課税)';
        CustomObject1__c so = new CustomObject1__c();
        String sqlStr = 'SELECT Id, ' + String.join(new List<String>(ankenMeisaiFieldSet), ',');
        sqlStr += ' FROM AnkenMeisai__c WHERE Anken__c = \''+ StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        sqlStr += ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        sqlStr += ' AND Invoice_No__c = \'' + StringUtils.escapeSingleQuotes(invoiceNo) + '\'';
        
        // if(typeDoc =='invoice' || typeDoc =='debit'){
        //     sqlStr += ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        // }
        /*
        if(curr == 'USD'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else if(curr == 'Both'){
            sqlStr += ' AND (curr__c = \''+ localCurr +'\' OR curr__c = \'USD\')';
        }else{
            sqlStr += ' AND (curr__c != \'USD\')';
        }
        */
        // if(typeDoc =='credit'){
            
        //     sqlStr += ' AND PaymentTo__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        // }

        if(docService == 'service-vat') {
            // sqlStr += ' AND Tariff__r.Zeibunrui__c = \'' + serviceTax + '\'';
            sqlStr += ' AND TaxInitial__c != 0';
        }

        if(docService == 'service-none-vat') {
            // sqlStr += ' AND Tariff__r.Zeibunrui__c = \'' + serviceNoneTax + '\'';
            sqlStr += ' AND TaxInitial__c = 0';
        }

        if(docService == 'both') {
            // sqlStr += ' AND (Tariff__r.Zeibunrui__c = \'' + serviceTax + '\' OR Tariff__r.Zeibunrui__c = \'' + serviceNoneTax + '\')';
            // Do nothing
        }

        sqlStr += ' AND PrintFlag__c = TRUE AND ADVANCE_PAYMENT_ON_BEHALF_OF__c = false  ORDER BY SeikyuBangou__c Limit 1000';
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
    
    public string formattedDate(Datetime unformattedDate) {

        // use some parameter substitution to build the string
        string formattedDate = String.format('{0} {1}, {2}', new List<String>{ String.valueOf(unformattedDate.format('MMM')), getDayOfMonthSuffix(unformattedDate.day()), String.valueOf(unformattedDate.year()) });
        return formattedDate;
    }

    public String getDayOfMonthSuffix(Integer n) {
        if (n == null) {
            return '';
        }

        if (n >= 11 && n <= 13) {
            return String.valueOf(n) + 'th';
        }

        Integer modResult = Math.mod(n, 10);        
        if (modResult == 1) { 
            return String.valueOf(n) + 'st'; 
        } else if (modResult == 2) { 
            return String.valueOf(n) + 'nd'; 
        } else if (modResult == 3) { 
            return String.valueOf(n) + 'rd'; 
        } else { 
            return String.valueOf(n) + 'th';
        }
    }

    public class BillWrapper{
        public String description{get;set;}
        public String invoice{get;set;}
        public Decimal no{get;set;}
        public String descriptionEng{get;set;}
        public Decimal quantity{get;set;}
        public String unit{get;set;}
        public Decimal unitPriceUSD{get;set;}
        public Decimal unitPriceVND{get;set;}
        public String curr{get;set;}
        public Decimal amountUSD{get;set;}
        public Decimal amountVND{get;set;}
        public Decimal amountSellTaxLocal{get;set;}
        public Decimal amountSellTaxUSD{get;set;}
        public Decimal tax{get;set;}
        public Decimal totalAmountUSD{get;set;}
        public Decimal totalAmountVND{get;set;}
        public String note{get;set;}
        public Decimal exchangeRate {get;set;}
        public BillWrapper(){

        }
        public BillWrapper( AnkenMeisai__c bill){
            invoice = bill.Invoice_No__c;
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
            amountSellTaxLocal = bill.SellTaxNum__c == null? 0 : bill.SellTaxNum__c;
            amountSellTaxUSD = bill.SellTaxNum_USD__c == null? 0 : bill.SellTaxNum_USD__c;
            //unitPriceUSD = unitPriceUSD.setScale(3, RoundingMode.HALF_UP);
            curr = bill.curr__c;
            amountUSD = bill.SellAmountUSD__c == null? 0 : bill.SellAmountUSD__c;
            amountVND = bill.SellAmountJPN__c == null? 0 : bill.SellAmountJPN__c;
            //amountUSD = amountUSD.setScale(3, RoundingMode.HALF_UP);
            tax = bill.TaxInitial__c;
            if(bill.Tariff__r.Zeibunrui__c == 'Non-Tax(非課税)'){
                tax = null;
            }
            if(bill.Tariff__r.Zeibunrui__c == 'Tax Free(免税)'){
                tax = 0;
            }
            totalAmountUSD = bill.SellTaxNum_USD__c == null? 0 : bill.SellTaxNum_USD__c;
            totalAmountVND = bill.SellTaxNum__c  == null? 0 : bill.SellTaxNum__c ;
            //totalAmountUSD = totalAmountUSD.setScale(3, RoundingMode.HALF_UP);
            note = bill.Description__c;
            exchangeRate = bill.clofor_com_cfs__KawaseSel__c;
        }
    }
}