public with sharing class InvoiceDebitMultiCurreny {
    public String   templateType{get;set;}
    public String   typeDoc {get; set;}
    public String   language {get; set;}
    public String   curr{get; set;}
    public String   shipmentId{get; set;}
    public String   recordTypeName{get; set;}
    public Boolean  hideUnnecessaryInfo{get;set;}
    public String   customerAddress{get;set;}
    public String   customerId {get; set;}
    public String   localCurr {get; set;}
    public String   sayUppercaseLabel{get; set;}
    public Account  customer{get; set;}
    public String   etdFormattedDate{get;set;}
    public String   etaFormattedDate{get;set;}
    public String   bookDateFormatted{get;set;}
    public String   paymentDueDateFormatted{get;set;}
    public Decimal  subTotalUSD{get;set;}
    public Decimal  grandTotalUSD{get;set;}
    public Decimal  subTotalVND{get;set;}
    public Decimal  grandTotalVND{get;set;}
    public String   grandTotalVNDInVNWording{get;set;}
    public String   grandTotalVNDInENWording{get;set;}
    public String   grandTotalUSDInENWording{get;set;}
    public String   grandTotalUSDInVNWording{get;set;}
    public String   formatStringUSDDetail{get;set;}
    public String   formatStringVND{get;set;}
    public String   formatStringUSDTotal{get;set;}
    public String   bankType{get;set;}
    public Boolean  showChargeableWeight{get;set;}
    public String   contentType{get;set;}
    public String   houseBookingNos{get;set;}
    public String   companyAddress {get; set;}
    public Boolean  showContainer{get;set;}
    public String   containerNosandtypes{get;set;}
    public String   userName{get;set;}
    public String   today{get;set;}
    public String   formatUnitPriceUSD{get;set;}
    public String   formatUnitPriceLocal{get;set;}
    public String   formatAmountUSD{get;set;}
    public String   formatAmountLocal{get;set;}
    public String   formatTax{get;set;}
    public String   formatTotalAmountUSD{get;set;}
    public String   formatTotalAmountLocal{get;set;}
    public String   formatSubTotalUSD{get;set;}
    public String   formatSubTotalLocal{get;set;}
    public String   formatGrandTotalUSD{get;set;}
    public String   formatGrandTotalLocal{get;set;}
    public Decimal  colspanShowAll{get;set;}
    public Decimal  currsSetSize{get;set;}

    public Set<String>          currsSet{get;set;}
    public CustomObject1__c     shipment{get;set;}
    public Map<String, Decimal> currToSubAmountMap { get; set;}
    public Map<String, Decimal> currToGrandAmountMap { get; set;}
    public Map<String, String>  currToFormatSubMap { get; set;}
    public Map<String, String>  currToFormatGrandMap { get; set;}
    public Map<String, String>  currToViSayGrandMap { get; set;}
    public Map<String, String>  currToNotViSayGrandMap { get; set;}
    public Map<String, String>  translations { get; set;}
    public List<AnkenMeisai__c> listBill{get; set;}
    public List<BillWrapper>    listBillWrapper{get;set;}
    public List<AnkenMeisai__c> listBillOnBehalf{get; set;}
    public List<BillWrapper>    listBillWrapperOnBehalf{get;set;}
    private static Set<String>  accountFieldSet = new Set<String>();
    private static Set<String>  ankenFieldSet = new Set<String>();
    private static Set<String>  ankenMeisaiFieldSet = new Set<String>();
    // 2022-07-25 Truong Lai add new start
    private static Site_Custom_Settings__c siteSetting {get;set;}
    // 2022-07-25 Truong Lai add new enf

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
        ankenFieldSet.add('BookingDate__c');
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
        
        // 2022-07-25 Truong Lai Add new start
        ankenMeisaiFieldSet.add('UnitPriceofSelling3rdCurrency__c');
        ankenMeisaiFieldSet.add('TotalAmountofSelling3rdCurrency__c');
        ankenMeisaiFieldSet.add('AmountSellingInclTax3rdCurrency__c');
        // 2022-07-25 Truong Lai Add new end
            
    }
    public InvoiceDebitMultiCurreny() {
        containerNosandtypes    ='';
        houseBookingNos         = '';
        showChargeableWeight    = false;
        // Difine variable
        currsSet                = new Set<String>();
        currToSubAmountMap      = new Map<String, Decimal>();
        currToGrandAmountMap    = new Map<String, Decimal>();
        currToFormatSubMap      = new Map<String, String>();
        currToFormatGrandMap    = new Map<String, String>();
        currToViSayGrandMap     = new Map<String, String>();
        currToNotViSayGrandMap     = new Map<String, String>();
        // Default format
        formatStringUSDDetail   = '{0,number,###,###,###,##0.000}';
        formatStringVND         = '{0,number,###,###,###,##0}';
        formatStringUSDTotal    = '{0,number,###,###,###,##0.00}';
        // Set format for curency values
        formatUnitPriceUSD      = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaUSD__c');
        formatUnitPriceLocal    = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellTankaJPY__c');
        formatAmountUSD         = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        formatAmountLocal       = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        formatTax               = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__TaxInitial__c');
        formatTotalAmountUSD    = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmount_USD__c');
        formatTotalAmountLocal  = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmountJPY__c');
        formatSubTotalUSD       = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountUSD__c');
        formatSubTotalLocal     = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellAmountJPN__c');
        formatGrandTotalUSD     = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmount_USD__c');
        formatGrandTotalLocal   = setFormatValue('clofor_com_cfs__AnkenMeisai__c', 'clofor_com_cfs__SellInTaxAmountJPY__c');

        customer                = new Account();
        shipment                = new CustomObject1__c();
        listBill                = new List<AnkenMeisai__c>();
        listBillOnBehalf        = new List<AnkenMeisai__c>();
        listBillWrapper         = new List<BillWrapper>();
        listBillWrapperOnBehalf = new List<BillWrapper>();
        customerAddress         = '';
        shipmentId              = ApexPages.currentPage().getParameters().get('shipmentId');
        typeDoc                 = ApexPages.currentPage().getParameters().get('typeDoc');
        language                = ApexPages.currentPage().getParameters().get('language');
        customerId              = ApexPages.currentPage().getParameters().get('customerId');
        curr                    = ApexPages.currentPage().getParameters().get('curr');
        bankType                = ApexPages.currentPage().getParameters().get('bankType');
        templateType            = ApexPages.currentPage().getParameters().get('templateType');
        contentType             = ApexPages.currentPage().getParameters().get('contentType');
        contentType             = contentType?.replace(',', '');
        showContainer           = Boolean.valueOf(ApexPages.currentPage().getParameters().get('showContainer'));
        userName                = UserInfo.getName();
        today                   =  DateTime.now().format('yyyy/MM/dd hh:mm:ss');
        
        // 2022-07-25 Truong Lai modify start
        //Get local curr
        // List<Site_Custom_Settings__c> lstSiteCustomSettings = [Select Local_Currency__c, Id from Site_Custom_Settings__c limit 1];
        List<Site_Custom_Settings__c> lstSiteCustomSettings = [SELECT Id, Local_Currency__c, FCY_Currency__c FROM Site_Custom_Settings__c LIMIT 1];
        // 2022-07-25 Truong Lai modify end
        if(lstSiteCustomSettings.size()>0){
            Site_Custom_Settings__c sct = lstSiteCustomSettings[0];
            localCurr = sct.Local_Currency__c;
            // 2022-07-25 Truong Lai add new start
            siteSetting = sct;
            // 2022-07-25 Truong Lai add new end
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
            curr = 'ShowAll';
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
            if(shipment.BookingDate__c != null){
                bookDateFormatted = formattedDate(shipment.BookingDate__c);
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
                BillWrapper newBill= new BillWrapper(bill, curr);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }
                listBillWrapper.add(newBill);
                subTotalVND += newBill.amountVND;
                grandTotalVND += newBill.totalAmountVND;
                subTotalUSD += newBill.amountUSD;
                grandTotalUSD += newBill.totalAmountUSD;
                // Add Curr to currsSet
                currsSet.add(newBill.curr);
            }
            listBillOnBehalf = getBillListOnBehalf();
            for(AnkenMeisai__c bill : listBillOnBehalf){
                BillWrapper newBill = new BillWrapper(bill, curr);
                if(translations.containsKey(newBill.unit)){
                    newBill.unit = translations.get(newBill.unit);
                }                
                listBillWrapperOnBehalf.add(newBill) ;
                subTotalVND += newBill.amountVND;
                grandTotalVND += newBill.totalAmountVND;
                subTotalUSD += newBill.amountUSD;
                grandTotalUSD += newBill.totalAmountUSD;
                // Add Curr to currsSet
                currsSet.add(newBill.curr);
            }
            subTotalUSD = subTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalUSD = grandTotalUSD.setScale(2, RoundingMode.HALF_UP);
            grandTotalVND = grandTotalVND.setScale(0, RoundingMode.HALF_UP);
            grandTotalUSDInENWording = NumbericUtils.readUSDAmountInEn(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
            grandTotalUSDInVNWording = NumbericUtils.readUSDAmountInVN(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
            grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND).toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
            grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND').toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');

            // Set value for colspanShowAll
            colspanShowAll = 0;
            currsSetSize = currsSet.size();
            if(currsSet.size()>0) {
                colspanShowAll = 6/currsSet.size();
            }

            for(String currLabel: currsSet) {
                Decimal subTotal = 0;
                Decimal grandTotal = 0;
                // Set values for currToFormatSubMap and currToFormatGrandMap
                if(currLabel == 'USD') {
                    currToFormatSubMap.put(currLabel, formatSubTotalUSD);
                    currToFormatGrandMap.put(currLabel, formatGrandTotalUSD);
                } else {
                    currToFormatSubMap.put(currLabel, formatSubTotalLocal);
                    currToFormatGrandMap.put(currLabel, formatGrandTotalLocal);
                }


                for(AnkenMeisai__c bill : listBill){
                    BillWrapper newBill= new BillWrapper(bill, curr);
                    if(newBill.curr == currLabel && currLabel == 'USD') {
                        subTotal += newBill.amountUSD;
                        grandTotal += newBill.totalAmountUSD;
                    }
                    if(newBill.curr == currLabel && currLabel != 'USD') {
                        subTotal += newBill.amountVND;
                        grandTotal += newBill.totalAmountVND;
                    }
                }

                for(AnkenMeisai__c bill : listBillOnBehalf){
                    BillWrapper newBill= new BillWrapper(bill, curr);
                    if(newBill.curr == currLabel && currLabel == 'USD') {
                        subTotal += newBill.amountUSD;
                        grandTotal += newBill.totalAmountUSD;
                    }
                    if(newBill.curr == currLabel && currLabel != 'USD') {
                        subTotal += newBill.amountVND;
                        grandTotal += newBill.totalAmountVND;
                    }
                }
                // Put value for Map
                currToSubAmountMap.put(currLabel, subTotal);
                currToGrandAmountMap.put(currLabel, grandTotal);

                // Set value for currToViSayGrandMap and currToNotViSayGrandMap
                grandTotalUSDInENWording = NumbericUtils.readUSDAmountInEn(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
                grandTotalUSDInVNWording = NumbericUtils.readUSDAmountInVN(grandTotalUSD).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)');
                grandTotalVNDInENWording = NumbericUtils.readVNDAmountInEn(grandTotalVND).toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
                grandTotalVNDInVNWording = NumbericUtils.convertNumberToText(grandTotalVND, 'VND').toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)');
                if(language == 'vi') {
                    for(String currLabelSay: currToGrandAmountMap.keySet()) {
                        if(currLabelSay == 'USD') {
                            currToViSayGrandMap.put(currLabelSay, NumbericUtils.readUSDAmountInVN(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('U.S DOLLARS', '(U.S DOLLARS)'));
                        } else if(currLabelSay == 'EUR') {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readUSDAmountInVN(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('U.S', '(EURO)').replace('DOLLARS', ''));
                        } else if (currLabelSay == 'VND') {
                            currToViSayGrandMap.put(currLabelSay, NumbericUtils.convertNumberToText(currToGrandAmountMap.get(currLabelSay), 'VND').toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)'));
                        } else if(currLabelSay == 'PHP') {
                            currToViSayGrandMap.put(currLabelSay, NumbericUtils.readPHPAmountInVN(currToGrandAmountMap.get(currLabelSay)).toUpperCase());
                        } else {
                            currToViSayGrandMap.put(currLabelSay, NumbericUtils.convertNumberToText(currToGrandAmountMap.get(currLabelSay), 'VND').toUpperCase().replace('VIETNAM DONG', '(' + currLabelSay+ ')'));
                        }
                    }
                } else {
                    for(String currLabelSay: currToGrandAmountMap.keySet()) {
                        if(currLabelSay == 'USD') {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readUSDAmountInEn(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('DOLLARS', '').replace('DOLLAR', '').replace('U.S', '(U.S DOLLARS)'));
                        } else if(currLabelSay == 'EUR') {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readUSDAmountInEn(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('U.S', '(EURO)').replace('DOLLARS', '').replace('DOLLAR', ''));
                        } else if (currLabelSay == 'VND') {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readVNDAmountInEn(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)'));
                        } else if (currLabelSay == 'GBP') {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readVNDAmountInEn(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('VIETNAM DONG', '(POUND)'));
                        } else if(currLabelSay == 'PHP') {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readPHPAmountInEn(currToGrandAmountMap.get(currLabelSay)).toUpperCase());
                        } else {
                            currToNotViSayGrandMap.put(currLabelSay, NumbericUtils.readVNDAmountInEn(currToGrandAmountMap.get(currLabelSay)).toUpperCase().replace('VIETNAM DONG', '(VIETNAM DONG)'));
                        }
                    }
                }
            }
        }
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
        /*
        if(curr == 'USD'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else if(curr == 'Both'){
            sqlStr += ' AND (curr__c = \''+ localCurr +'\' OR curr__c = \'USD\')';
        }else{
            sqlStr += ' AND (curr__c != \'USD\')';
        }
        */
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
        /*
        if(curr == 'USD'){
            sqlStr += ' AND curr__c = \'' + StringUtils.escapeSingleQuotes(curr) + '\'';
        }else if(curr == 'Both'){
            sqlStr += ' AND (curr__c = \''+ localCurr +'\' OR curr__c = \'USD\')';
        }else{
            sqlStr += ' AND (curr__c != \'USD\')';
        }
        */
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
		String dayString = '';        
        if (modResult == 1) { 
            dayString = String.valueOf(n) + 'st'; 
        } else if (modResult == 2) { 
            dayString = String.valueOf(n) + 'nd'; 
        } else if (modResult == 3) { 
            dayString = String.valueOf(n) + 'rd'; 
        } else { 
            dayString = String.valueOf(n) + 'th';
        }
        
        if(n < 10) {
            return '0' + dayString;
        } else {
            return dayString;
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
        public String curr{get;set;}
        public Decimal amountUSD{get;set;}
        public Decimal amountVND{get;set;}
        public Decimal tax{get;set;}
        public Decimal totalAmountUSD{get;set;}
        public Decimal totalAmountVND{get;set;}
        public String note{get;set;}
        public BillWrapper(){

        }
        public BillWrapper(AnkenMeisai__c bill, String currencyOption){
            no = bill.SeikyuBangou__c;
            description = bill.InsatuyouSyohin__c;
            descriptionEng = bill.InsatuyouSyohinEng__c;
            quantity = bill.Suryo__c;
            unit = bill.ChargeUnitFormula__c;
            if(bill.ChargeUnitFormula__c == 'Container' || bill.ChargeUnitFormula__c == 'コンテナ'){
                unit = bill.ContainerSizeFormula__c;
            }

            String billCurrency = bill.curr__c;
            if (currencyOption == 'ShowAll' && billCurrency != null && billCurrency != siteSetting.Local_Currency__c && billCurrency != siteSetting.FCY_Currency__c) {
                Decimal unitPrice = bill.UnitPriceofSelling3rdCurrency__c == null ? 0 : bill.UnitPriceofSelling3rdCurrency__c;
                Decimal amountThird = bill.TotalAmountofSelling3rdCurrency__c == null ? 0 : bill.TotalAmountofSelling3rdCurrency__c;
                Decimal totalAmount = bill.AmountSellingInclTax3rdCurrency__c == null ? 0 : bill.AmountSellingInclTax3rdCurrency__c;
                unitPriceVND = unitPrice;
                unitPriceUSD = unitPrice.setScale(3, RoundingMode.HALF_UP);
                curr = billCurrency;
                amountVND = amountThird;
                amountUSD = amountThird.setScale(3, RoundingMode.HALF_UP);

                totalAmountVND = totalAmount;
                totalAmountUSD = totalAmount.setScale(3, RoundingMode.HALF_UP);
            } else {
                unitPriceUSD = bill.SellTankaUSD__c == null? 0 : bill.SellTankaUSD__c;
                unitPriceVND = bill.SellTankaJPY__c == null? 0 : bill.SellTankaJPY__c;
                unitPriceUSD = unitPriceUSD.setScale(3, RoundingMode.HALF_UP);
                curr = bill.curr__c;
                amountUSD = bill.SellAmountUSD__c == null? 0 : bill.SellAmountUSD__c;
                amountVND = bill.SellAmountJPN__c == null? 0 : bill.SellAmountJPN__c;
                amountUSD = amountUSD.setScale(3, RoundingMode.HALF_UP);

                totalAmountUSD = bill.SellInTaxAmount_USD__c == null? 0 : bill.SellInTaxAmount_USD__c;
                totalAmountVND = bill.SellInTaxAmountJPY__c == null? 0 : bill.SellInTaxAmountJPY__c;
                totalAmountUSD = totalAmountUSD.setScale(3, RoundingMode.HALF_UP);
            }

            tax = bill.TaxInitial__c;
            if(tax == 0 || tax == null) {
                tax = 0;
            }
            if(bill.Tariff__r.Zeibunrui__c == 'Non-Tax(非課税)'){
                tax = null;
            }
            if(bill.Tariff__r.Zeibunrui__c == 'Tax Free(免税)'){
                tax = 0;
            }
            // totalAmountUSD = bill.SellInTaxAmount_USD__c == null? 0 : bill.SellInTaxAmount_USD__c;
            // totalAmountVND = bill.SellInTaxAmountJPY__c == null? 0 : bill.SellInTaxAmountJPY__c;
            // totalAmountUSD = totalAmountUSD.setScale(3, RoundingMode.HALF_UP);
            note = bill.Description__c;

        }
    }
}