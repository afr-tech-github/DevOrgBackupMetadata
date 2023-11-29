public with sharing class InvoicePrintNewController {
    public String templateType{get;set;}
    public String typeDoc {get; set;}
    public String language {get; set;}
    public String curr{get; set;}
    public String shipmentId{get; set;}
    public String recordTypeName{get; set;}
    public Boolean hideUnnecessaryInfo{get;set;}
    public Boolean isTax{get;set;}
    public String customerAddress{get;set;}
    public String customerId {get; set;}
    public String localCurr {get; set;}
    public Map<String, String> translations { get; set;}
    public String sayUppercaseLabel{get; set;}
    public Account customer{get; set;}
    public CustomObject1__c shipment{get;set;}
    public String etdFormattedDate{get;set;}
    public String etaFormattedDate{get;set;}
    public String deliveryFormattedDate{get;set;}
    public String bookDateFormatted{get;set;}
    public String paymentDueDateFormatted{get;set;}
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
    public String grandTotalUSDInJPWording{get;set;}
    private static Set<String> accountFieldSet = new Set<String>();
    private static Set<String> ankenFieldSet = new Set<String>();
    private static Set<String> ankenMeisaiFieldSet = new Set<String>();
    public String formatStringUSDDetail{get;set;}
    public String formatStringVND{get;set;}
    public String formatStringUSDTotal{get;set;}

    public String formatUnitPriceUSD{get;set;}
    public String formatUnitPriceLocal{get;set;}
    public String formatAmountUSD{get;set;}
    public String formatAmountLocal{get;set;}
    public String formatTax{get;set;}
    public String formatTotalAmountUSD{get;set;}
    public String formatTotalAmountLocal{get;set;}
    public String formatSubTotalUSD{get;set;}
    public String formatSubTotalLocal{get;set;}
    public String formatGrandTotalUSD{get;set;}
    public String formatGrandTotalLocal{get;set;}

    public Integer scaleUnitPriceUSD{get;set;}
    public Integer scaleUnitPriceLocal{get;set;}
    public Integer scaleAmountUSD{get;set;}
    public Integer scaleAmountLocal{get;set;}
    public Integer scaleTax{get;set;}
    public Integer scaleTotalAmountUSD{get;set;}
    public Integer scaleTotalAmountLocal{get;set;}
    public Integer scaleSubTotalUSD{get;set;}
    public Integer scaleSubTotalLocal{get;set;}
    public Integer scaleGrandTotalUSD{get;set;}
    public Integer scaleGrandTotalLocal{get;set;}

    public String bankType{get;set;}
    public Boolean showChargeableWeight{get;set;}
    public String contentType{get;set;}
    public String houseBookingNos{get;set;}
    public String companyAddress {get; set;}
    public String userName{get;set;}
    public String today{get;set;}
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
        ankenFieldSet.add('DeliveryDate__c');
        //======================
        ankenMeisaiFieldSet.add('clofor_com_cfs__KawaseSel__c');
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

    private String setFormatValue(String sObjectName, String sObjectFieldName) {
        Integer scaleNum = ((SObject)(Type.forName('Schema.'+sObjectName).newInstance())).getSObjectType().getDescribe().fields.getMap().get(sObjectFieldName).getDescribe().getScale();
    	switch on scaleNum {
            when 0 {
        		return'{0,number,###,###,###,##0}';
    		}	
    		when 1 {
        		return'{0,number,###,###,###,##0.0}';
    		}	
    		when 2 {
        		return '{0,number,###,###,###,##0.00}';
    		}
    		when 3 {
        		return '{0,number,###,###,###,##0.000}';
    		}
            when 4 {
        		return '{0,number,###,###,###,##0.0000}';
    		}
            when 5 {
        		return '{0,number,###,###,###,##0.00000}';
    		}
    		when else {	
        		return '{0,number,###,###,###,##0.000}';
    		}
		}
    }

    private Integer setScaleValue(String sObjectName, String sObjectFieldName) {
        return ((SObject)(Type.forName('Schema.'+sObjectName).newInstance())).getSObjectType().getDescribe().fields.getMap().get(sObjectFieldName).getDescribe().getScale();
    }

    public InvoicePrintNewController() {
        houseBookingNos = '';
        showChargeableWeight = false;
        isTax = false;
        formatStringUSDDetail = '{0,number,###,###,###,##0.000}';
        formatStringVND = '{0,number,###,###,###,###}';
        formatStringUSDTotal = '{0,number,###,###,###,##0.00}';

        formatUnitPriceUSD = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaUSD__c');
        formatUnitPriceLocal = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaJPY__c');
        formatAmountUSD = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        formatAmountLocal = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        formatTax = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__TaxInitial__c');
        formatTotalAmountUSD = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmount_USD__c');
        formatTotalAmountLocal = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmountJPY__c');
        formatSubTotalUSD = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        formatSubTotalLocal = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        formatGrandTotalUSD = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmount_USD__c');
        formatGrandTotalLocal = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmountJPY__c');

        scaleUnitPriceUSD = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaUSD__c');
        scaleUnitPriceLocal = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaJPY__c');
        scaleAmountUSD = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        scaleAmountLocal = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        scaleTax = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__TaxInitial__c');
        scaleTotalAmountUSD = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmount_USD__c');
        scaleTotalAmountLocal = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmountJPY__c');
        scaleSubTotalUSD = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        scaleSubTotalLocal = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        scaleGrandTotalUSD = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmount_USD__c');
        scaleGrandTotalLocal = setScaleValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmountJPY__c');


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
        if(ApexPages.currentPage().getParameters().get('contentType') != null){
            contentType = ApexPages.currentPage().getParameters().get('contentType');
            contentType = contentType?.replace(',', '');
        }
        if(ApexPages.currentPage().getParameters().get('isTax') != null){
            isTax = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isTax'));

        }
              
        userName = UserInfo.getName();
        today =  DateTime.now().format('yyyy/MM/dd hh:mm:ss');
        //Get local curr
        List<Site_Custom_Settings__c> lstSiteCustomSettings = [Select Local_Currency__c, Id from Site_Custom_Settings__c limit 1];
        if(lstSiteCustomSettings.size()>0){
            Site_Custom_Settings__c sct = lstSiteCustomSettings[0];
            localCurr = sct.Local_Currency__c;
        }
        // Get company address from Metadata Company_Address__mdt
        Site_Metadata_Types__mdt recordCompanyAdrress = [Select Address__c From Site_Metadata_Types__mdt limit 1];
        if(recordCompanyAdrress?.Address__c != null){
            companyAddress = recordCompanyAdrress.Address__c;
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
            if(shipment.DeliveryDate__c != null){
                deliveryFormattedDate = formattedDate(shipment.DeliveryDate__c);
            } else {
                deliveryFormattedDate = '';
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
            subTotalUSD = 0;
            subTotalVND = 0;
            grandTotalUSD = 0;
            grandTotalVND = 0;
            for(AnkenMeisai__c bill : listBill){
                BillWrapper newBill= new BillWrapper(bill);
                newBill.unitPriceUSD = newBill.unitPriceUSD.setScale(scaleUnitPriceUSD, System.RoundingMode.HALF_UP);
                newBill.unitPriceVND = newBill.unitPriceVND.setScale(scaleUnitPriceLocal, System.RoundingMode.HALF_UP);
                newBill.unitPriceUSDInclTax = newBill.unitPriceUSDInclTax.setScale(scaleUnitPriceUSD, System.RoundingMode.HALF_UP);
                newBill.unitPriceVNDInclTax = newBill.unitPriceVNDInclTax.setScale(scaleUnitPriceLocal, System.RoundingMode.HALF_UP);
                newBill.amountUSD = newBill.amountUSD.setScale(scaleAmountUSD, System.RoundingMode.HALF_UP);
                newBill.amountVND = newBill.amountVND.setScale(scaleAmountLocal, System.RoundingMode.HALF_UP);
                if(newBill.tax != null && newBill.tax != 0) {
                    newBill.tax = newBill.tax.setScale(scaleTax, System.RoundingMode.HALF_UP);
                }
                newBill.totalAmountUSD = newBill.totalAmountUSD.setScale(scaleTotalAmountUSD, System.RoundingMode.HALF_UP);
                newBill.totalAmountVND = newBill.totalAmountVND.setScale(scaleTotalAmountLocal, System.RoundingMode.HALF_UP);
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
            }
            listBillOnBehalf = getBillListOnBehalf();
            for(AnkenMeisai__c bill : listBillOnBehalf){
                BillWrapper newBill = new BillWrapper(bill);
                newBill.unitPriceUSD = newBill.unitPriceUSD.setScale(scaleUnitPriceUSD, System.RoundingMode.HALF_UP);
                newBill.unitPriceVND = newBill.unitPriceVND.setScale(scaleUnitPriceLocal, System.RoundingMode.HALF_UP);
                newBill.unitPriceUSDInclTax = newBill.unitPriceUSDInclTax.setScale(scaleUnitPriceUSD, System.RoundingMode.HALF_UP);
                newBill.unitPriceVNDInclTax = newBill.unitPriceVNDInclTax.setScale(scaleUnitPriceLocal, System.RoundingMode.HALF_UP);
                newBill.amountUSD = newBill.amountUSD.setScale(scaleAmountUSD, System.RoundingMode.HALF_UP);
                newBill.amountVND = newBill.amountVND.setScale(scaleAmountLocal, System.RoundingMode.HALF_UP);
                if(newBill.tax != null && newBill.tax != 0) {
                    newBill.tax = newBill.tax.setScale(scaleTax, System.RoundingMode.HALF_UP);
                }
                newBill.totalAmountUSD = newBill.totalAmountUSD.setScale(scaleTotalAmountUSD, System.RoundingMode.HALF_UP);
                newBill.totalAmountVND = newBill.totalAmountVND.setScale(scaleTotalAmountLocal, System.RoundingMode.HALF_UP);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }
                // handle Format nummber for USD EXcel issue
                
                listBillWrapperOnBehalf.add(newBill) ;
                if(newBill.curr == 'USD'){
                    subTotalUSD += newBill.amountUSD;
                    grandTotalUSD += newBill.totalAmountUSD;
                }else if(newBill.curr == localCurr){
                    subTotalVND += newBill.amountVND;
                    grandTotalVND += newBill.totalAmountVND;
                }
            }
            subTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSD = grandTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSDInENWording = NumbericUtils.readUSDAmountInEn(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
            grandTotalUSDInVNWording = NumbericUtils.readUSDAmountInVN(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
            grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND).toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
            grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND').toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
            grandTotalUSDInJPWording = JPYNumberToWords.convert(grandTotalVND);
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
        String sqlStr = 'SELECT Id, RecordTypeId, (select id,name, MasterBkg__r.MasterBookingNo__c from House_Bkg__r),  ' + String.join(new List<String>(ankenFieldSet), ',');
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
        system.debug('curr - Torres: '+curr);
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
    
    //Format day time
    public string formattedDate(Datetime unformattedDate) {

        // use some parameter substitution to build the string
        // string formattedDate = String.format('{0} {1}, {2}', new List<String>{ String.valueOf(unformattedDate.format('MMMMM')), getDayOfMonthSuffix(unformattedDate.day()), String.valueOf(unformattedDate.year()) });
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
        public Decimal no{get;set;}
        public String descriptionEng{get;set;}
        public Decimal quantity{get;set;}
        public String unit{get;set;}
        public Decimal unitPriceUSD{get;set;}
        public Decimal unitPriceVND{get;set;}
        public Decimal unitPriceUSDInclTax{get;set;}
        public Decimal unitPriceVNDInclTax{get;set;}
        public String curr{get;set;}
        public Decimal amountUSD{get;set;}
        public Decimal amountVND{get;set;}
        public Decimal tax{get;set;}
        public Decimal totalAmountUSD{get;set;}
        public Decimal totalAmountVND{get;set;}
        public String note{get;set;}
        public Decimal exchangeRate {get;set;}
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
            
            curr = bill.curr__c;
            amountUSD = bill.SellAmountUSD__c == null? 0 : bill.SellAmountUSD__c;
            amountVND = bill.SellAmountJPN__c == null? 0 : bill.SellAmountJPN__c;

            tax = bill.TaxInitial__c == null? 0 : bill.TaxInitial__c;
            unitPriceUSDInclTax = bill.SellTankaUSD__c == null? 0 : bill.SellTankaUSD__c*(1+tax/100);
            unitPriceVNDInclTax = bill.SellTankaJPY__c == null? 0 : bill.SellTankaJPY__c*(1+tax/100);

            if(bill.Tariff__r.Zeibunrui__c == 'Non-Tax(非課税)'){
                tax = null;
            }
            if(bill.Tariff__r.Zeibunrui__c == 'Tax Free(免税)'){
                tax = 0;
            }
            totalAmountUSD = bill.SellInTaxAmount_USD__c == null? 0 : bill.SellInTaxAmount_USD__c;
            totalAmountVND = bill.SellInTaxAmountJPY__c == null? 0 : bill.SellInTaxAmountJPY__c;
            note = bill.Description__c;
            exchangeRate = bill.clofor_com_cfs__KawaseSel__c;
        }
    }
}