public with sharing class QuotationReportController {
    public Quote__c quote{get; set;}
    public String reportType{get;set;}
    public List<QuoteLine__c> listQuoteLineMain{get; set;}
    public List<QuoteLine__c> listQuoteLineSub{get; set;}
    public List<QuoteLine__c> listQuoteLineSub3rd{get; set;}
    public List<String> contTypeHeader{get; set;}
    public List<String> CarrierList{get; set;}
    public List<String> ScheduleList{get; set;}
    public Decimal Ttday{get; set;}
    public String currencyStrMain{get;set;}
    public String carrierStrMain{get;set;}
    public String currencyStrSub{get;set;}
    public String carrierStrSub{get;set;}
    private List<String> currencySub{get; set;}
    public List<LineItemWrapper> lineItems {get; set;} 
    public List<LineItemWrapper> lineItemsDom {get; set;} 
    public List<LineItemWrapper> lineItemsAir {get; set;} 
    public List<LineItemWrapper> lineItemsSub {get; set;} 
    public List<LineItemWrapper> lineItemsSub3rd {get; set;} 
    public String leftfooter {get; set;}
    public String language  {get;set;}
    public Map<String, String>translations{get;set;}
    public String quoteId;
    public Boolean Check1stSection {get; set;}
    public Boolean Check2ndSection {get; set;}
    public Boolean Check3rdSection {get; set;}

    public Boolean requiredAttachmentCreation{get;set;}
    public Boolean isTax{get;set;}
    public Boolean isAmount{get;set;}
    public Boolean isSum{get;set;}

    public Decimal Sum{get; set;}
    public Decimal Sum3rd{get; set;}
    public Decimal SumUSD{get; set;}
    public Decimal SumUSD3rd{get; set;}
    public Decimal SumVND{get; set;}
    public Decimal SumVND3rd{get; set;}
    public String OtherCurrency{get; set;}
    public Decimal SumMain{get; set;}
    public Decimal SumUSDMain{get; set;}
    public Decimal SumVNDMain{get; set;}
    public Decimal SumShipment{get; set;}
    public Decimal SumUSDShipment{get; set;}
    public Decimal SumVNDShipment{get; set;}
    public String OtherCurrencyMain{get; set;}
    
    private static Set<String> fieldsQuery = new Set<String>();
    static{
        fieldsQuery.add('Id');
        fieldsQuery.add('LineItemName__c');
        fieldsQuery.add('lineitemnamelocal__c');
        fieldsQuery.add('QuoteLineNumber__c');
        fieldsQuery.add('Unit__c');
        fieldsQuery.add('Quantity__c');
        fieldsQuery.add('SellingListPriceLocal__c');
        fieldsQuery.add('SellingListPriceUSD__c');
        fieldsQuery.add('TaxRate__c');
        fieldsQuery.add('SellingAmountInclTaxLocal__c');
        fieldsQuery.add('SellingAmountInclTaxUSD__c');
        fieldsQuery.add('CurrencySelling__c');
        fieldsQuery.add('POLAOD__c');
        fieldsQuery.add('PODAOA__c');
        fieldsQuery.add('POLAOD__r.Name');
        fieldsQuery.add('PODAOA__r.Name');
        fieldsQuery.add('POLAODName__c');
        fieldsQuery.add('PODAOAName__c');
        fieldsQuery.add('CarrierAirlinerVendor__c');
        fieldsQuery.add('CarrierAirlinerVendorName__c');
        fieldsQuery.add('ContainerType__c');
        fieldsQuery.add('ContainerQuantity__c');
        fieldsQuery.add('ServiceSchedule__c');
        fieldsQuery.add('TransitTimeDays__c');
        fieldsQuery.add('Remarks__c');
        fieldsQuery.add('TotalAmountSellingLocal__c');
        fieldsQuery.add('TotalAmountOfSellingUSD__c');
        fieldsQuery.add('PickupAddress__c');
        fieldsQuery.add('DeliveryAddress__c');
        fieldsQuery.add('Minimum__c');
        fieldsQuery.add('Under45kg__c');
        fieldsQuery.add('Over45kg__c');
        fieldsQuery.add('Over100kg__c');
        fieldsQuery.add('Over300kg__c');
        fieldsQuery.add('Over500kg__c');
        fieldsQuery.add('Over1000kg__c');
        fieldsQuery.add('FSCSCS__c');
        fieldsQuery.add('Quantity__c');
        fieldsQuery.add('Unit__c');
        fieldsQuery.add('ChargeUnitInPrint__c');

    }

    public QuotationReportController() {
        
        lineItems = new List<LineItemWrapper>();
        lineItemsDom = new List<LineItemWrapper>();
        lineItemsAir = new List<LineItemWrapper>();
        lineItemsSub = new List<LineItemWrapper>();
        lineItemsSub3rd = new List<LineItemWrapper>();
        requiredAttachmentCreation = false;
        isTax = ApexPages.currentPage().getParameters().get('isTax') == 'true';
        System.debug('quoteId: ' + quoteId + ' isTax: ' + isTax);
        isAmount = ApexPages.currentPage().getParameters().get('isAmount') == 'true';
        System.debug('quoteId: ' + quoteId + ' isAmount: ' + isAmount);
        isSum = ApexPages.currentPage().getParameters().get('isSum') == 'true';
        System.debug('quoteId: ' + quoteId + ' isSum: ' + isSum);
        contTypeHeader = new List<String>();
        CarrierList = new List<String>();
        ScheduleList = new List<String>();
        Ttday = 0;
        Sum = 0;
        Sum3rd = 0;
        SumUSD = 0;
        SumUSD3rd = 0;
        SumVND = 0;
        SumVND3rd = 0;
        OtherCurrency = null;
        SumMain = 0;
        SumUSDMain = 0;
        SumVNDMain = 0;
        SumShipment = 0;
        SumUSDShipment = 0;
        SumVNDShipment = 0;
        OtherCurrencyMain = null;
        Check1stSection = true;
        Check2ndSection = true;
        Check3rdSection = true;
     	quoteId = ApexPages.currentPage().getParameters().get('quoteId');
         System.debug('ffffffff :'+quoteId);
        language = ApexPages.currentPage().getParameters().get('language');
        quote = getQuote(quoteId);
        String filename = quote.Name + '.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=\"'+filename+'\"');
        translations = getTranslation();
        Datetime now = Datetime.now();
        String convertDate = now.format('HH:mm:ss dd/MM/yyyy');
        leftfooter = String.join(new List<String>{quote.LastModifiedBy.Name,quote.LastModifiedBy.Email,convertDate}, ' - ');
        if(quote.RecordType.DeveloperName =='LogisticsServiceQuote' ){
            reportType = 'ocean_freight';
        }
        if(quote.RecordType.DeveloperName == 'DomesticLogisticsServiceQuote'){
            reportType = 'domestic_service';
        }
        if(quote.RecordType.DeveloperName == 'AirLogisticsServiceQuote'){
            reportType = 'air_freight';
        }

        listQuoteLineMain = getListQuoteLineMain(quoteId, reportType);
        if (listQuoteLineMain.size() > 0){
            Check1stSection = false;
        }
        listQuoteLineSub = getListQuoteLineSub(quoteId);
        if (listQuoteLineSub.size() > 0){
            Check2ndSection = false;
        }
        listQuoteLineSub3rd = getListQuoteLineSub3rd(quoteId);
        if (listQuoteLineSub3rd.size() > 0){
            Check3rdSection = false;
        }
        Map<String,QuoteLine__c> mapQuoteLineMainFinal = new Map<String,QuoteLine__c>();
        Set<String> currencyMainSet = new Set<String>();
        Set<String> contTypeSet = new Set<String>();
        String carrierMainSet ='';

        Map<String, LineItemWrapper> mapLineItemByKey = new Map<String, LineItemWrapper>();
        if(quote.RecordType.DeveloperName != 'DomesticLogisticsServiceQuote'){
            for(QuoteLine__c line : listQuoteLineMain){
                if(line.CarrierAirlinerVendorName__c != null){
                    carrierMainSet += line.CarrierAirlinerVendorName__c;
                }
                if(!String.isBlank(line.ContainerType__c) && !contTypeSet.contains(line.ContainerType__c)){
                    contTypeHeader.add(line.ContainerType__c);
                    contTypeSet.add(line.ContainerType__c);
                }
                else if(!String.isBlank(line.ChargeUnitInPrint__c) && !contTypeSet.contains(line.ChargeUnitInPrint__c)){
                    contTypeHeader.add(line.ChargeUnitInPrint__c);
                    contTypeSet.add(line.ChargeUnitInPrint__c);
                }
                if(!String.isBlank(line.CurrencySelling__c)){
                    currencyMainSet.add(line.CurrencySelling__c);
                }
                if(!String.isBlank(line.clofor_com_cfs__CarrierAirlinerVendorName__c)){
                    CarrierList.add(line.clofor_com_cfs__CarrierAirlinerVendorName__c);
                }
                if(!String.isBlank(line.clofor_com_cfs__ServiceSchedule__c)){
                    ScheduleList.add(line.clofor_com_cfs__ServiceSchedule__c);
                }
                if(line.clofor_com_cfs__TransitTimeDays__c != null){
                    Ttday += line.clofor_com_cfs__TransitTimeDays__c;
                }
            }
            System.debug('111: ' + contTypeHeader.size());
            if(quote.RecordType.DeveloperName =='LogisticsServiceQuote'){
                for(QuoteLine__c line : listQuoteLineMain){
                    String key = line.POLAOD__c + '-' + line.PODAOA__c;
                    key += '-' + line.Quantity__c + '-' + line.CurrencySelling__c;
                    key += line.CarrierAirlinerVendorName__c;
                    if(line.CurrencySelling__c == 'JPY'){
                        key += '-' + line.SellingListPriceLocal__c + '-' + line.TotalAmountSellingLocal__c;
                    }else{
                         key += '-' + line.SellingListPriceUSD__c + '-' + line.TotalAmountOfSellingUSD__c;
                    }
                    key += '-' + line.ServiceSchedule__c + '-' + line.TransitTimeDays__c;
                    if(mapLineItemByKey.containsKey(key)){
                        if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        else if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(String.isBlank(mapLineItemByKey.get(key).remarks)){
                            mapLineItemByKey.get(key).remarks = line.Remarks__c;
                        }
                    }else{
                        LineItemWrapper itemWrapper = new LineItemWrapper();
                        if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ContainerType__c){
                            itemWrapper.contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType1 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        else if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType1 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ContainerType__c){
                            itemWrapper.contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType2 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType2 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ContainerType__c){
                            itemWrapper.contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType3 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType3 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ContainerType__c){
                            itemWrapper.contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType4 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType4 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        // String temp;
                        // for (Integer j = 0; j < contTypeHeader.size(); j++) {
                            // for (Integer i = j + 1; i < contTypeHeader.size(); i++) {
                                // if (contTypeHeader[i] < contTypeHeader[j]) {
                                    // temp = contTypeHeader[j];
                                    // contTypeHeader[j] = contTypeHeader[i];
                                    // contTypeHeader[i] = temp;
                                // }
                            // }
                        // }
                        itemWrapper.quoteLineNumber = line.QuoteLineNumber__c;
                        if (language != 'vi'){
                            itemWrapper.lineItemName = line.LineItemName__c;
                        } else {
                            itemWrapper.lineItemName = line.lineitemnamelocal__c;
                        }
                        itemWrapper.POLAOD = line.POLAOD__c;
                        itemWrapper.PODAOA = line.PODAOA__c;
                        itemWrapper.POLAODName = line.POLAOD__r.Name;
                        itemWrapper.PODAOAName = line.PODAOA__r.Name;
                        if(line.Quantity__c == null){
                            line.Quantity__c = 0;
                        }
                        itemWrapper.quantity = line.Quantity__c;
                        itemWrapper.unit = line.Unit__c;
                        itemWrapper.chargeunitinprint = line.ChargeUnitInPrint__c;
                        itemWrapper.currencySelling = line.CurrencySelling__c;
                        if(line.SellingListPriceUSD__c == null){
                            line.SellingListPriceUSD__c = 0;
                        }
                        itemWrapper.sellingListPriceUSD = line.SellingListPriceUSD__c;
                        if(line.SellingListPriceLocal__c == null){
                            line.SellingListPriceLocal__c = 0;
                        }
                        itemWrapper.sellingListPriceLocal = line.SellingListPriceLocal__c;
                        itemWrapper.totalAmountSellingLocal = line.TotalAmountSellingLocal__c;
                        itemWrapper.totalAmountOfSellingUSD = line.TotalAmountOfSellingUSD__c;
                        itemWrapper.carrierAirlinerVendorName = line.CarrierAirlinerVendorName__c;
                        itemWrapper.serviceSchedule = line.ServiceSchedule__c;
                        itemWrapper.transitTimeDays = line.TransitTimeDays__c;
                        itemWrapper.remarks = line.Remarks__c;
                        itemWrapper.ContainerType = line.ContainerType__c;
                        if (line.TaxRate__c == null){
                            line.TaxRate__c = 0;
                        }
                        itemWrapper.tax = line.TaxRate__c;
                        if(line.CurrencySelling__c == 'USD'){
                            if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                                itemWrapper.AmountUSD = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                                SumUSDMain += line.Quantity__c*line.SellingListPriceUSD__c;
                            }
                            
                        } else if (line.CurrencySelling__c == 'JPY'){
                            if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                                itemWrapper.AmountVND = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                                SumVNDMain += line.Quantity__c*line.SellingListPriceLocal__c;
                            }
                            
                        } else {
                            if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                                itemWrapper.Amount = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                                SumMain += line.Quantity__c*line.SellingListPriceUSD__c;
                                OtherCurrencyMain = line.CurrencySelling__c;
                            }
                        }
                        mapLineItemByKey.put(key, itemWrapper);
                    }
                    
                }
            }
            if(quote.RecordType.DeveloperName =='AirLogisticsServiceQuote'){
                for(QuoteLine__c line : listQuoteLineMain){
                    String key = line.POLAOD__c + '-' + line.PODAOA__c;
                    key += '-' + line.Quantity__c + '-' + line.CurrencySelling__c;
                    key += line.CarrierAirlinerVendorName__c;
                    if(line.CurrencySelling__c == 'JPY'){
                        key += '-' + line.SellingListPriceLocal__c + '-' + line.TotalAmountSellingLocal__c;
                    }else{
                         key += '-' + line.SellingListPriceUSD__c + '-' + line.TotalAmountOfSellingUSD__c;
                    }
                    key += '-' + line.ServiceSchedule__c + '-' + line.TransitTimeDays__c;
                    if(mapLineItemByKey.containsKey(key)){
                        if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        else if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ContainerType__c){
                            mapLineItemByKey.get(key).contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ChargeUnitInPrint__c){
                            mapLineItemByKey.get(key).contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceLocal__c;
                            }else{
                                mapLineItemByKey.get(key).contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(String.isBlank(mapLineItemByKey.get(key).remarks)){
                            mapLineItemByKey.get(key).remarks = line.Remarks__c;
                        }
                    }else{
                        LineItemWrapper itemWrapper = new LineItemWrapper();
                        if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ContainerType__c){
                            itemWrapper.contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType1 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        else if(contTypeHeader.size() > 0 && contTypeHeader[0] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType1Name = contTypeHeader[0];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType1 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType1 = line.SellingListPriceUSD__c;
                            }
                            
                        }
                        if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ContainerType__c){
                            itemWrapper.contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType2 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 1 && contTypeHeader[1] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType2Name = contTypeHeader[1];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType2 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType2 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ContainerType__c){
                            itemWrapper.contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType3 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 2 && contTypeHeader[2] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType3Name = contTypeHeader[2];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType3 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType3 = line.SellingListPriceUSD__c;
                            }
                        }
                        if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ContainerType__c){
                            itemWrapper.contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType4 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        else if(contTypeHeader.size() > 3 && contTypeHeader[3] == line.ChargeUnitInPrint__c){
                            itemWrapper.contType4Name = contTypeHeader[3];
                            if(line.CurrencySelling__c == 'JPY'){
                                itemWrapper.contType4 = line.SellingListPriceLocal__c;
                            }else{
                                itemWrapper.contType4 = line.SellingListPriceUSD__c;
                            }
                        }
                        // String temp;
                        // for (Integer j = 0; j < contTypeHeader.size(); j++) {
                            // for (Integer i = j + 1; i < contTypeHeader.size(); i++) {
                                // if (contTypeHeader[i] < contTypeHeader[j]) {
                                    // temp = contTypeHeader[j];
                                    // contTypeHeader[j] = contTypeHeader[i];
                                    // contTypeHeader[i] = temp;
                                // }
                            // }
                        // }
                        itemWrapper.quoteLineNumber = line.QuoteLineNumber__c;
                        if (language != 'vi'){
                            itemWrapper.lineItemName = line.LineItemName__c;
                        } else {
                            itemWrapper.lineItemName = line.lineitemnamelocal__c;
                        }
                        itemWrapper.POLAOD = line.POLAOD__c;
                        itemWrapper.PODAOA = line.PODAOA__c;
                        itemWrapper.POLAODName = line.POLAOD__r.Name;
                        itemWrapper.PODAOAName = line.PODAOA__r.Name;
                        if(line.Quantity__c == null){
                            line.Quantity__c = 0;
                        }
                        itemWrapper.quantity = line.Quantity__c;
                        itemWrapper.unit = line.Unit__c;
                        itemWrapper.chargeunitinprint = line.ChargeUnitInPrint__c;
                        itemWrapper.currencySelling = line.CurrencySelling__c;
                        if(line.SellingListPriceUSD__c == null){
                            line.SellingListPriceUSD__c = 0;
                        }
                        itemWrapper.sellingListPriceUSD = line.SellingListPriceUSD__c;
                        if(line.SellingListPriceLocal__c == null){
                            line.SellingListPriceLocal__c = 0;
                        }
                        itemWrapper.sellingListPriceLocal = line.SellingListPriceLocal__c;
                        itemWrapper.totalAmountSellingLocal = line.TotalAmountSellingLocal__c;
                        itemWrapper.totalAmountOfSellingUSD = line.TotalAmountOfSellingUSD__c;
                        itemWrapper.carrierAirlinerVendorName = line.CarrierAirlinerVendorName__c;
                        itemWrapper.serviceSchedule = line.ServiceSchedule__c;
                        itemWrapper.transitTimeDays = line.TransitTimeDays__c;
                        itemWrapper.remarks = line.Remarks__c;
                        itemWrapper.ContainerType = line.ContainerType__c;
                        if (line.TaxRate__c == null){
                            line.TaxRate__c = 0;
                        }
                        itemWrapper.tax = line.TaxRate__c;
                        if(line.CurrencySelling__c == 'USD'){
                            if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                                itemWrapper.AmountUSD = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                                SumUSDMain += line.Quantity__c*line.SellingListPriceUSD__c;
                            }
                            
                        } else if (line.CurrencySelling__c == 'JPY'){
                            if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                                itemWrapper.AmountVND = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                                SumVNDMain += line.Quantity__c*line.SellingListPriceLocal__c;
                            }
                            
                        } else {
                            if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                                itemWrapper.Amount = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                                SumMain += line.Quantity__c*line.SellingListPriceUSD__c;
                                OtherCurrencyMain = line.CurrencySelling__c;
                            }
                        }
                        mapLineItemByKey.put(key, itemWrapper);
                    }
                    
                }
            }
            Map<String, LineItemWrapper> mapItemWrapperFinal = new Map<String, LineItemWrapper>();
            String key;
            if(quote.RecordType.DeveloperName =='LogisticsServiceQuote'){
                String temp;
                for (Integer j = 0; j < contTypeHeader.size(); j++) {
                    for (Integer i = j + 1; i < contTypeHeader.size(); i++) {
                        if (contTypeHeader[i] < contTypeHeader[j]) {
                            temp = contTypeHeader[j];
                            contTypeHeader[j] = contTypeHeader[i];
                            contTypeHeader[i] = temp;
                        }
                    }
                }
                for(LineItemWrapper item : mapLineItemByKey.values()){
                    key = item.contType1 + '-' + item.contType2 + '-' + item.contType3 + '-'+ item.contType4;
                    key += item.carrierAirlinerVendorName+'-' + item.POLAOD + '-' + item.PODAOA + '-' + item.quantity + '-' + item.currencySelling + '-' + item.remarks;
                    // key += item.carrierAirlinerVendorName + '-' + item.POLAOD + '-' + item.PODAOA + '-' + item.currencySelling + '-' + item.serviceSchedule + '-' + item.transitTimeDays + '-' + item.remarks;
                    if(item.currencySelling == 'JPY'){
                        key += '-' + item.totalAmountSellingLocal;
                    }else{
                         key += '-' + item.totalAmountOfSellingUSD;
                    }
                    key += '-' + item.serviceSchedule + '-' + item.transitTimeDays;
                    LineItemWrapper itemTemp = item;
                    if(mapItemWrapperFinal.containsKey(key)){
                        itemTemp = mapItemWrapperFinal.get(key);
                        if(!String.isBlank(itemTemp.carrierAirlinerVendorName)){
                            itemTemp.carrierAirlinerVendorName = itemTemp.carrierAirlinerVendorName.remove('null');
                        }
                        if(!String.isBlank(itemTemp.carrierAirlinerVendorName) 
                            && !String.isBlank(item.carrierAirlinerVendorName)){
                            mapItemWrapperFinal.get(key).carrierAirlinerVendorName += '&nbsp;';
                        }
                        mapItemWrapperFinal.get(key).carrierAirlinerVendorName += item.carrierAirlinerVendorName;
                    }else{
                        mapItemWrapperFinal.put(key, itemTemp);
                    }
                }
            }
            if(quote.RecordType.DeveloperName =='AirLogisticsServiceQuote'){
                String temp;
                for (Integer j = 0; j < contTypeHeader.size(); j++) {
                    for (Integer i = j + 1; i < contTypeHeader.size(); i++) {
                        if (contTypeHeader[i] < contTypeHeader[j]) {
                            temp = contTypeHeader[j];
                            contTypeHeader[j] = contTypeHeader[i];
                            contTypeHeader[i] = temp;
                        }
                    }
                }
                for(LineItemWrapper item : mapLineItemByKey.values()){
                    key = item.contType1 + '-' + item.contType2 + '-' + item.contType3 + '-'+ item.contType4;
                    key += item.carrierAirlinerVendorName+'-' + item.POLAOD + '-' + item.PODAOA + '-' + item.quantity + '-' + item.currencySelling + '-' + item.remarks;
                    // key += item.carrierAirlinerVendorName + '-' + item.POLAOD + '-' + item.PODAOA + '-' + item.currencySelling + '-' + item.serviceSchedule + '-' + item.transitTimeDays + '-' + item.remarks;
                    if(item.currencySelling == 'JPY'){
                        key += '-' + item.totalAmountSellingLocal;
                    }else{
                         key += '-' + item.totalAmountOfSellingUSD;
                    }
                    key += '-' + item.serviceSchedule + '-' + item.transitTimeDays;
                    LineItemWrapper itemTemp = item;
                    if(mapItemWrapperFinal.containsKey(key)){
                        itemTemp = mapItemWrapperFinal.get(key);
                        if(!String.isBlank(itemTemp.carrierAirlinerVendorName)){
                            itemTemp.carrierAirlinerVendorName = itemTemp.carrierAirlinerVendorName.remove('null');
                        }
                        if(!String.isBlank(itemTemp.carrierAirlinerVendorName) 
                            && !String.isBlank(item.carrierAirlinerVendorName)){
                            mapItemWrapperFinal.get(key).carrierAirlinerVendorName += '&nbsp;';
                        }
                        mapItemWrapperFinal.get(key).carrierAirlinerVendorName += item.carrierAirlinerVendorName;
                    }else{
                        mapItemWrapperFinal.put(key, itemTemp);
                    }
                }
            }
            // lineItems = mapItemWrapperFinal.values();
            // 
            // Group the LineItems by carrierAirlinerVendorName
                    
            Map<String, LineItemWrapper> mapItemWrappertoGroup = new Map<String, LineItemWrapper>();
            if(quote.RecordType.DeveloperName =='LogisticsServiceQuote'){
                for(LineItemWrapper item : mapItemWrapperFinal.values()){
                    key = item.carrierAirlinerVendorName + '-' + item.POLAOD + '-' + item.PODAOA + '-' + item.currencySelling + '-' + item.serviceSchedule + '-' + item.transitTimeDays + '-' + item.remarks;
                    LineItemWrapper itemTemp = item;
                    
                    if(mapItemWrappertoGroup.containsKey(key)){
                        if(item.contType1 != null && item.contType1 != 0){
                            mapItemWrappertoGroup.get(key).contType1 = item.contType1;
                            mapItemWrappertoGroup.get(key).contType1Name = item.contType1Name;
                        }
                        if(item.contType2 != null && item.contType2 != 0){
                            mapItemWrappertoGroup.get(key).contType2 = item.contType2;
                            mapItemWrappertoGroup.get(key).contType2Name = item.contType2Name;
                        }
                        if(item.contType3 != null && item.contType3 != 0){
                            mapItemWrappertoGroup.get(key).contType3 = item.contType3;
                            mapItemWrappertoGroup.get(key).contType3Name = item.contType3Name;
                        }
                        if(item.contType4 != null && item.contType4 != 0){
                            mapItemWrappertoGroup.get(key).contType4 = item.contType4;
                            mapItemWrappertoGroup.get(key).contType4Name = item.contType4Name;
                        }
                    }else{
                        mapItemWrappertoGroup.put(key, itemTemp);
                    }
                }
                
            }
            if(quote.RecordType.DeveloperName =='AirLogisticsServiceQuote'){
                for(LineItemWrapper item : mapItemWrapperFinal.values()){
                    key = item.carrierAirlinerVendorName + '-' + item.POLAOD + '-' + item.PODAOA + '-' + item.currencySelling + '-' + item.serviceSchedule + '-' + item.transitTimeDays + '-' + item.remarks;
                    LineItemWrapper itemTemp = item;
                    
                    if(mapItemWrappertoGroup.containsKey(key)){
                        if(item.contType1 != null && item.contType1 != 0){
                            mapItemWrappertoGroup.get(key).contType1 = item.contType1;
                            mapItemWrappertoGroup.get(key).contType1Name = item.contType1Name;
                        }
                        if(item.contType2 != null && item.contType2 != 0){
                            mapItemWrappertoGroup.get(key).contType2 = item.contType2;
                            mapItemWrappertoGroup.get(key).contType2Name = item.contType2Name;
                        }
                        if(item.contType3 != null && item.contType3 != 0){
                            mapItemWrappertoGroup.get(key).contType3 = item.contType3;
                            mapItemWrappertoGroup.get(key).contType3Name = item.contType3Name;
                        }
                        if(item.contType4 != null && item.contType4 != 0){
                            mapItemWrappertoGroup.get(key).contType4 = item.contType4;
                            mapItemWrappertoGroup.get(key).contType4Name = item.contType4Name;
                        }
                    }else{
                        mapItemWrappertoGroup.put(key, itemTemp);
                    }
                }         
            }
                    
            lineItems = mapItemWrappertoGroup.values();
        }
        if(quote.RecordType.DeveloperName == 'DomesticLogisticsServiceQuote'){
            for(QuoteLine__c line : listQuoteLineMain){
                if(!String.isBlank(line.CurrencySelling__c)){
                    currencyMainSet.add(line.CurrencySelling__c);
                }
                if(line.CarrierAirlinerVendorName__c != null){
                    carrierMainSet += line.CarrierAirlinerVendorName__c;
                }
                LineItemWrapper itemWrapper = new LineItemWrapper();
                itemWrapper.quoteLineNumber = line.QuoteLineNumber__c;
                itemWrapper.unit = line.Unit__c;
                if(itemWrapper.unit == 'Container' || itemWrapper.unit == 'コンテナ'){
                    itemWrapper.unit = line.ContainerType__c;
                }
                if(translations.containsKey(itemWrapper.unit)){
                    itemWrapper.unit = translations.get(itemWrapper.unit);
                }
                if (language != 'vi'){
                    itemWrapper.lineItemName = line.LineItemName__c;
                } else {
                    itemWrapper.lineItemName = line.lineitemnamelocal__c;
                }
                // itemWrapper.lineItemName = line.LineItemName__c;
                itemWrapper.POLAOD = line.POLAOD__c;
                itemWrapper.PODAOA = line.PODAOA__c;
                itemWrapper.POLAODName = line.POLAOD__r.Name;
                itemWrapper.PODAOAName = line.PODAOA__r.Name;
                if (line.Quantity__c == null){
                    line.Quantity__c = 0;
                }
                itemWrapper.quantity = line.Quantity__c;
                itemWrapper.unit = line.Unit__c;
                itemWrapper.chargeunitinprint = line.ChargeUnitInPrint__c;
                itemWrapper.currencySelling = line.CurrencySelling__c;
                if (line.SellingListPriceUSD__c == null) {
                    line.SellingListPriceUSD__c = 0;
                }
                itemWrapper.sellingListPriceUSD = line.SellingListPriceUSD__c;
                if (line.SellingListPriceLocal__c == null) {
                    line.SellingListPriceLocal__c = 0;
                }
                itemWrapper.sellingListPriceLocal = line.SellingListPriceLocal__c;
                itemWrapper.totalAmountSellingLocal = line.TotalAmountSellingLocal__c;
                itemWrapper.totalAmountOfSellingUSD = line.TotalAmountOfSellingUSD__c;
                itemWrapper.carrierAirlinerVendorName = line.CarrierAirlinerVendorName__c;
                itemWrapper.serviceSchedule = line.ServiceSchedule__c;
                itemWrapper.transitTimeDays = line.TransitTimeDays__c;
                itemWrapper.remarks = line.Remarks__c;
                itemWrapper.ContainerType = line.ContainerType__c;
                if (line.TaxRate__c == null){
                    line.TaxRate__c = 0;
                }
                itemWrapper.tax = line.TaxRate__c;
                if(line.CurrencySelling__c == 'USD'){
                    if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                        itemWrapper.AmountUSD = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                        SumUSDMain += itemWrapper.AmountUSD;
                    }
                } else if (line.CurrencySelling__c == 'JPY'){
                    if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                        itemWrapper.AmountVND = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                        SumVNDMain += itemWrapper.AmountVND;    
                    }
                } else {
                    if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                        itemWrapper.Amount = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                        SumMain += itemWrapper.Amount;
                        OtherCurrencyMain = line.CurrencySelling__c;
                    }
                }
                lineItems.add(itemWrapper);
            }
        
        }
		// 
		
        currencyStrMain = String.join(new List<String>(currencyMainSet), '/');
        carrierStrMain = carrierMainSet;

        listQuoteLineSub = getListQuoteLineSub(quoteId);
        listQuoteLineSub3rd = getListQuoteLineSub3rd(quoteId);
        Set<String> currencySubSet = new Set<String>();
        String carrierSubSet = '';
        for(QuoteLine__c line : listQuoteLineSub){
            
            if(!String.isBlank(line.CurrencySelling__c)){
                currencySubSet.add(line.CurrencySelling__c);
            }
            if(line.CarrierAirlinerVendorName__c != null){
                carrierSubSet += line.CarrierAirlinerVendorName__c;
            }
            LineItemWrapper itemWrapper = new LineItemWrapper();
            itemWrapper.quoteLineNumber = line.QuoteLineNumber__c;
            itemWrapper.unit = line.Unit__c;
            if(itemWrapper.unit == 'Container' || itemWrapper.unit == 'コンテナ'){
                itemWrapper.unit = line.ContainerType__c;
            }
            if(translations.containsKey(itemWrapper.unit)){
                itemWrapper.unit = translations.get(itemWrapper.unit);
            }
            if (language == 'en'){
                itemWrapper.lineItemName = line.LineItemName__c;
            } else {
                itemWrapper.lineItemName = line.lineitemnamelocal__c;
            }
            System.debug('152 :' + language);
            System.debug('153 :' + itemWrapper.lineItemName);
            // itemWrapper.lineItemName = line.LineItemName__c;
            itemWrapper.POLAOD = line.POLAOD__c;
            itemWrapper.PODAOA = line.PODAOA__c;
            itemWrapper.POLAODName = line.POLAOD__r.Name;
            itemWrapper.PODAOAName = line.PODAOA__r.Name;
            if (line.Quantity__c == null){
                line.Quantity__c = 0;
            }
            itemWrapper.quantity = line.Quantity__c;
            itemWrapper.unit = line.Unit__c;
            itemWrapper.chargeunitinprint = line.ChargeUnitInPrint__c;
            itemWrapper.currencySelling = line.CurrencySelling__c;
            if (line.SellingListPriceUSD__c == null) {
                line.SellingListPriceUSD__c = 0;
            }
            itemWrapper.sellingListPriceUSD = line.SellingListPriceUSD__c;
            if (line.SellingListPriceLocal__c == null) {
                line.SellingListPriceLocal__c = 0;
            }
            itemWrapper.sellingListPriceLocal = line.SellingListPriceLocal__c;
            itemWrapper.totalAmountSellingLocal = line.TotalAmountSellingLocal__c;
            itemWrapper.totalAmountOfSellingUSD = line.TotalAmountOfSellingUSD__c;
            itemWrapper.carrierAirlinerVendorName = line.CarrierAirlinerVendorName__c;
            itemWrapper.serviceSchedule = line.ServiceSchedule__c;
            itemWrapper.transitTimeDays = line.TransitTimeDays__c;
            itemWrapper.remarks = line.Remarks__c;
            itemWrapper.ContainerType = line.ContainerType__c;
            if (line.TaxRate__c == null){
                line.TaxRate__c = 0;
            }
            itemWrapper.tax = line.TaxRate__c;
            if(line.CurrencySelling__c == 'USD'){
                if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                    itemWrapper.AmountUSD = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                    SumUSD += itemWrapper.AmountUSD;
                }
            } else if (line.CurrencySelling__c == 'JPY'){
                if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                    itemWrapper.AmountVND = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                    SumVND += itemWrapper.AmountVND;    
                }
            } else {
                if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                    itemWrapper.Amount = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                    Sum += itemWrapper.Amount;
                    OtherCurrency = line.CurrencySelling__c;
                }
            }
            lineItemsSub.add(itemWrapper);
        }

        for(QuoteLine__c line : listQuoteLineSub3rd){
            
            if(!String.isBlank(line.CurrencySelling__c)){
                currencySubSet.add(line.CurrencySelling__c);
            }
            if(line.CarrierAirlinerVendorName__c != null){
                carrierSubSet += line.CarrierAirlinerVendorName__c;
            }
            LineItemWrapper itemWrapper = new LineItemWrapper();
            itemWrapper.quoteLineNumber = line.QuoteLineNumber__c;
            itemWrapper.unit = line.Unit__c;
            if(itemWrapper.unit == 'Container' || itemWrapper.unit == 'コンテナ'){
                itemWrapper.unit = line.ContainerType__c;
            }
            if(translations.containsKey(itemWrapper.unit)){
                itemWrapper.unit = translations.get(itemWrapper.unit);
            }
            if (language == 'en'){
                itemWrapper.lineItemName = line.LineItemName__c;
            } else {
                itemWrapper.lineItemName = line.lineitemnamelocal__c;
            }
            // itemWrapper.lineItemName = line.LineItemName__c;
            itemWrapper.POLAOD = line.POLAOD__c;
            itemWrapper.PODAOA = line.PODAOA__c;
            itemWrapper.POLAODName = line.POLAOD__r.Name;
            itemWrapper.PODAOAName = line.PODAOA__r.Name;
            if (line.Quantity__c == null){
                line.Quantity__c = 0;
            }
            itemWrapper.quantity = line.Quantity__c;
            itemWrapper.unit = line.Unit__c;
            itemWrapper.chargeunitinprint = line.ChargeUnitInPrint__c;
            itemWrapper.currencySelling = line.CurrencySelling__c;
            if (line.SellingListPriceUSD__c == null) {
                line.SellingListPriceUSD__c = 0;
            }
            itemWrapper.sellingListPriceUSD = line.SellingListPriceUSD__c;
            if (line.SellingListPriceLocal__c == null) {
                line.SellingListPriceLocal__c = 0;
            }
            itemWrapper.sellingListPriceLocal = line.SellingListPriceLocal__c;
            itemWrapper.totalAmountSellingLocal = line.TotalAmountSellingLocal__c;
            itemWrapper.totalAmountOfSellingUSD = line.TotalAmountOfSellingUSD__c;
            itemWrapper.carrierAirlinerVendorName = line.CarrierAirlinerVendorName__c;
            itemWrapper.serviceSchedule = line.ServiceSchedule__c;
            itemWrapper.transitTimeDays = line.TransitTimeDays__c;
            itemWrapper.remarks = line.Remarks__c;
            itemWrapper.ContainerType = line.ContainerType__c;
            if (line.TaxRate__c == null){
                line.TaxRate__c = 0;
            }
            itemWrapper.tax = line.TaxRate__c;
            if(line.CurrencySelling__c == 'USD'){
                if (line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100) != null){
                    itemWrapper.AmountUSD = line.Quantity__c*line.SellingListPriceUSD__c*(1+line.TaxRate__c/100);
                    SumUSD3rd += itemWrapper.AmountUSD;
                }
            } else if (line.CurrencySelling__c == 'JPY'){
                if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                    itemWrapper.AmountVND = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                    SumVND3rd += itemWrapper.AmountVND;    
                }
            } else {
                if (line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100) != null){
                    itemWrapper.Amount = line.Quantity__c*line.SellingListPriceLocal__c*(1+line.TaxRate__c/100);
                    Sum3rd += itemWrapper.Amount;
                    OtherCurrency = line.CurrencySelling__c;
                }
            }
            lineItemsSub3rd.add(itemWrapper);
        }
        currencyStrSub = String.join(new List<String>(currencySubSet), '/');
        carrierStrSub = carrierSubSet;
        

        if(listQuoteLineMain.size() == 0){
            listQuoteLineMain.add(new QuoteLine__c());
        }
        if(listQuoteLineSub.size() == 0){
            listQuoteLineSub.add(new QuoteLine__c());
        }
        if(lineItems.size() == 0 ){
            lineItems.add(new LineItemWrapper());
        }
        SumShipment = SumMain + Sum + Sum3rd;
        SumUSDShipment = SumUSDMain + SumUSD + SumUSD3rd;
        SumVNDShipment = SumVNDMain + SumVND + SumVND3rd;
    }
    @AuraEnabled
    public static String checkContainerTypeNumber(String recordId){
        Quote__c quoteREC = getQuote(recordId);
        Set<String> containerTypeSet = new Set<String>();
        if(quoteREC.RecordType.DeveloperName == 'LogisticsServiceQuote'){
            List<QuoteLine__c> listItems = getListQuoteLineMain(recordId, 'ocean_freight');
            for(QuoteLine__c item : listItems){
                
                if (item.Unit__c != 'Container'){
                    containerTypeSet.add(item.ChargeUnitInPrint__c);
                } else {
                    containerTypeSet.add(item.ContainerType__c);
                }
                if(containerTypeSet.size() > 4){

                    return 'The number of container type is more than 4 types. Please check again to ensure the number of types is not more than 4 types';
                }
            }
        }
        return '';
    }


    @AuraEnabled
    public static void createAttatchment(String recordId, String language){
        PageReference pdf_file = Page.page_QuotationReportPdf;
        pdf_file.getParameters().put('quoteId', recordId);
        pdf_file.getParameters().put('language', language);
        String namefile = 'Quotation';
        String languaName='';
        for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
            if(value.getValue().contains(language)) {
                languaName = value.getLabel();
                break;
            }
        }
        String attachName = namefile + '-' + languaName + ' v';
        String attachNameSearch = attachName + '%';
        // get exist file Name
        List<Attachment> attachments = [SELECT Id, Name, ParentId 
                                        FROM Attachment 
                                        WHERE ParentId =: recordId 
                                        AND Name LIKE : attachNameSearch 
                                        ORDER BY CreatedDate DESC LIMIT 1];
        if(attachments.isEmpty()){
            attachName += '1.1';
        }else{
            String attachNameExist = attachments[0].Name;
            attachNameExist = attachNameExist.substringAfter(attachName);
            attachNameExist = attachNameExist.substringBefore('.pdf');
            Decimal versionNumber = Decimal.valueOf(attachNameExist);
            versionNumber += 0.1;
            attachName += String.valueOf(versionNumber);
        }
        Attachment attach = new Attachment();
        Blob body;
        attach.Name = attachName + '.pdf'; 
        attach.IsPrivate = false;
        attach.ParentId = recordId;
        if(!Test.isRunningTest()){
            body = pdf_file.getContentAsPDF();
            attach.Body = body;
            FlsService.doInsert(attach);
        }

    }

    public PageReference generateQuotation(){
        if (requiredAttachmentCreation) {
            createAttatchment(quoteId, language);
        }

        PageReference pageRedirect = Page.page_QuotationReportPdf;
        pageRedirect.getParameters().put('quoteId', quoteId);
        pageRedirect.getParameters().put('language', language);
        pageRedirect.getParameters().put('isTax', String.valueOf(isTax));
        pageRedirect.getParameters().put('isAmount', String.valueOf(isAmount));
        pageRedirect.getParameters().put('isSum', String.valueOf(isSum));
        pageRedirect.setRedirect(true);

        return pageRedirect;
    }

    public List<SelectOption> getLanguageOptions(){
            List<SelectOption> languageOptions = new List<SelectOption>();
            languageOptions.add(new SelectOption('en', 'English'));
            languageOptions.add(new SelectOption('ja', '日本語'));
            languageOptions.add(new SelectOption('vi', 'Tiếng Việt'));
            languageOptions.add(new SelectOption('ko', '한국어'));
            languageOptions.add(new SelectOption('zh', '中文'));
            return languageOptions;
        } 

    public Map<String, String > getTranslation(){

        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('unit_translation')){
               translateMapResult.put(key.substringAfter('.'), (String)translate.get(key)); 
            }
            if(key.contains('quotation')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
       
        return translateMapResult; 
    }
    private static Quote__c getQuote(String quoteId){
        Quote__c quote = [SELECT Id, Name, QuoteName__c, QuoteNumber__c,ValidTo__c, QuoteIssueDate__c,
                            RequesterCompany__c, RequesterCompany__r.Name, RequesterCompany__r.EnglishAddress__c, RequesterCompany__r.EnglishCompanyName__c,
                            PICOfRequesterCompany__c, PICOfRequesterCompany__r.Name,PICOfRequesterCompany__r.Salutation,
                            QuotePIC__r.Phone, PICOfRequesterCompany__r.Phone,
                            QuotePIC__r.Email, PICOfRequesterCompany__r.Email, Volume__c,
                            NetWeightKG__c, MeasurementCBM__c, GrossWeightKG__c, DescriptionOfGoods__c,
                            CargoMode__c, Quantity__c, Incoterms__c, PickupAddress__c, DeliveryAddress__c, LastModifiedBy.Name,LastModifiedBy.Email,
                            ExchangeRateID__c, Remarks__c, PaymentCondition__c, QuotePIC__r.Name, RecordType.DeveloperName
                            FROM Quote__c WHERE Id =: quoteId];


        return quote;

    }
    
    private static List<QuoteLine__c> getListQuoteLineMain(String quoteId, String reportType){
        String strSelect = String.join(new List<String>(fieldsQuery), ',');
        String strQuery = 'SELECT ' + strSelect 
                    + ' FROM QuoteLine__c'
                    + ' WHERE QuoteID__c = \'' + String.escapeSingleQuotes(quoteId) + '\''
                    + ' AND Print__c = true ';
        if(reportType != 'domestic_service'){
            strQuery += ' AND PrintingSection__c = \'1st Section\'';
        }
        strQuery += ' ORDER BY QuoteLineNumber__c ASC';
        List<QuoteLine__c> quoteLines = Database.query(strQuery);
        return quoteLines;
    }

    private List<QuoteLine__c> getListQuoteLineSub(String quoteId){
        String strSelect = String.join(new List<String>(fieldsQuery), ',');
        String strQuery = 'SELECT ' + strSelect 
                    + ' FROM QuoteLine__c'
                    + ' WHERE QuoteID__c = \'' + String.escapeSingleQuotes(quoteId) + '\''
                    + ' AND Print__c = true';
        if(reportType != 'domestic_service'){
            strQuery += ' AND PrintingSection__c = \'2nd Section\'';
        }
        strQuery += ' ORDER BY QuoteLineNumber__c ASC';
        List<QuoteLine__c> quoteLines = Database.query(strQuery);
        return quoteLines;
    }

    private List<QuoteLine__c> getListQuoteLineSub3rd(String quoteId){
        String strSelect = String.join(new List<String>(fieldsQuery), ',');
        String strQuery = 'SELECT ' + strSelect 
                    + ' FROM QuoteLine__c'
                    + ' WHERE QuoteID__c = \'' + String.escapeSingleQuotes(quoteId) + '\''
                    + ' AND Print__c = true';
        if(reportType != 'domestic_service'){
            strQuery += ' AND PrintingSection__c = \'3rd Section\'';
        }
        strQuery += ' ORDER BY QuoteLineNumber__c ASC';
        List<QuoteLine__c> quoteLines = Database.query(strQuery);
        return quoteLines;
    }
    public class LineItemWrapper{
        public Decimal contType1{get; set;}
        public Decimal contType2{get; set;}
        public Decimal contType3{get; set;}
        public Decimal contType4{get; set;}
        public String contType1Name{get; set;}
        public String contType2Name{get; set;}
        public String contType3Name{get; set;}
        public String contType4Name{get; set;}
        public Decimal quoteLineNumber{get; set;}
        public String POLAOD{get; set;}
        public String PODAOA{get; set;}
        public String POLAODName{get; set;}
        public String PODAOAName{get; set;}
        public Decimal quantity{get; set;}
        public String currencySelling{get; set;}
        public Decimal sellingListPriceUSD{get; set;}
        public Decimal sellingListPriceLocal{get; set;}
        public Decimal totalAmountSellingLocal{get; set;}
        public Decimal totalAmountOfSellingUSD{get; set;}
        public Decimal tax{get; set;}
        public Decimal Amount{get; set;}
        public Decimal AmountUSD{get; set;}
        public Decimal AmountVND{get; set;}
        public String carrierAirlinerVendorName{get; set;}
        public String serviceSchedule{get; set;}
        public Decimal transitTimeDays{get; set;}
        public String remarks{get; set;}
        public String lineItemName{get;set;}
        public String unit{get;set;}
        public String chargeunitinprint{get;set;}
        public String ContainerType {get;set;}

        public LineItemWrapper(){
            contType1 = null;
            contType2 = null;
            contType3 = null;
            contType4 = null;
            contType1Name = '';
            contType2Name = '';
            contType3Name = '';
            contType4Name = '';
            quoteLineNumber = null; 
            POLAOD = '';
            PODAOA = '';
            POLAODName = '';
            PODAOAName = '';
            quantity = null;
            currencySelling = '';
            sellingListPriceUSD = 0;
            sellingListPriceLocal = 0;
            totalAmountSellingLocal = null;
            totalAmountOfSellingUSD = null;
            carrierAirlinerVendorName = '';
            serviceSchedule = '';
            transitTimeDays = null;
            remarks = '';
            lineItemName = '';
            unit = '';
            chargeunitinprint='';
            ContainerType = '';
            tax = 0;
            Amount = 0;
            AmountUSD = 0;
            AmountVND = 0;
            
        }
        public String getSellingListPriceLocalVND(){
            if(sellingListPriceLocal == 0 || sellingListPriceLocal == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(sellingListPriceLocal.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }
        public String getTotalAmountSellingLocalVND(){
            if(totalAmountSellingLocal == 0 || totalAmountSellingLocal == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###,0'};

            String s = String.format(totalAmountSellingLocal.format(), args);  
            if(!s.contains(',')){
               s += ',0'; 
            }
            return s; 
        }
    }
}