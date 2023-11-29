/**
* ClassName:   page_QuotationPrintPdfCtrl
* Description: page Quotation Print Pdf Ctrl
* @created:    2022/10/13 Truong Lai
* @modified:
*/
public without sharing class page_QuotationPrintPdfCtrl {
    public String quoteId{get; set;}
    public String quoterRemarks{get;set;}
    public String readSubject{get;set;}
    public clofor_com_cfs__Quote__c quote{get;set;}
    public Map<String, RouterDataWapper> mapDynamicReferences{get;set;}
    private static final String TH_NO = 'NO';
    private static final String TH_DESCRIPTION = 'Items';
    private static final String TH_REMARK = 'REMARK';
    private static final String SECTION_1ST = '1st Section';
    private static final String SECTION_2ND = '2nd Section';
    private static final String HYPHEN = '-';
    private static final String KGS = 'KGS';
    private static final String OTHER = 'OTHER';
    private static Set<String> setFieldsQuote = new Set<String>();
    private static Set<String> setFieldsQuoteLine = new Set<String>();
    private static Boolean isExistTableData{get;set;}
    private static List<String> formatUnitPrice {get;set;}
    private static List<String> lstChargeUnits = new List<String>{  '-1000KGS',
                                                                    '+1000KGS',
                                                                    '+2000KGS',
                                                                    '+3000KGS',
                                                                    '+4000KGS',
                                                                    '+5000KGS',
                                                                    '+6000KGS',
                                                                    '+7000KGS',
                                                                    '+8000KGS',
                                                                    '+9000KGS',
                                                                    '+10000KGS',
                                                                    '20\'All',
                                                                    '40\'All',
                                                                    '20\'DC',
                                                                    '2*20\'DC',
                                                                    '40\'DC',
                                                                    '45\'DC',
                                                                    '20\'DC-Flexi',
                                                                    '20\'FR',
                                                                    '40\'FR',
                                                                    '40\'HC',
                                                                    '45\'HC',
                                                                    '20\'IMO',
                                                                    '40\'IMO',
                                                                    '45\'IMO',
                                                                    '20\'ISO',
                                                                    '40\'ISO',
                                                                    '20\'OT',
                                                                    '40\'OT',
                                                                    '45\'OT',
                                                                    '20\'RF',
                                                                    '40\'RF',
                                                                    '45\'RF',
                                                                    'AIR',
                                                                    'All',
                                                                    'B/L',
                                                                    'Bag',
                                                                    'Bale',
                                                                    'Bale,compressed',
                                                                    'Bale,non-compressed',
                                                                    'Bar',
                                                                    'Barrel',
                                                                    'Basket',
                                                                    'Bill',
                                                                    'Box',
                                                                    'Bulk',
                                                                    'Bulk, gas（at 1031mber and 15℃）',
                                                                    'Bulk, liguefied gas（at abnomal temperature/pressure）',
                                                                    'Bulk, liquid',
                                                                    'Bulk, solid, fineparticles(powders）',
                                                                    'Bulk, solid, granular particles(grains）',
                                                                    'Bulk, solid, large particles(nodules）',
                                                                    'Bundle',
                                                                    'Cage',
                                                                    'Can,cylindrical',
                                                                    'Can,rectangular',
                                                                    'Carboy,non-protected',
                                                                    'Carboy,protected',
                                                                    'Carton',
                                                                    'Case',
                                                                    'Cask',
                                                                    'CBM',
                                                                    'CBM',
                                                                    'Certificate',
                                                                    'Charter',
                                                                    'Chest',
                                                                    'Coil',
                                                                    'Container',
                                                                    'Crate',
                                                                    'Cylinder',
                                                                    'Day',
                                                                    'DemiJohn, protected',
                                                                    'DemiJohn,non-protected',
                                                                    'Drum',
                                                                    'EA',
                                                                    'Fibre Drum',
                                                                    'Flask',
                                                                    'Flexible Container',
                                                                    'Frame',
                                                                    'g',
                                                                    'HEAD',
                                                                    'Hogeshead',
                                                                    'Ingot',
                                                                    'Jar',
                                                                    'Jug',
                                                                    'Keg',
                                                                    'Km',
                                                                    'License',
                                                                    'Log',
                                                                    'Logs, in bundle/bunch/truss',
                                                                    'Mat',
                                                                    'MT',
                                                                    'Net',
                                                                    'Other',
                                                                    'Pack',
                                                                    'Package',
                                                                    'Packet',
                                                                    'Pail',
                                                                    'Pallet',
                                                                    'Pallet & Package',
                                                                    'Parcel',
                                                                    'Pen',
                                                                    'Piece',
                                                                    'Pipe',
                                                                    'Pipes, in bundle/bunch/truss',
                                                                    'Planks, in bundle/bunch/truss',
                                                                    'Plate',
                                                                    'Plates, in bundle/bunch/truss',
                                                                    'Reel',
                                                                    'Roll',
                                                                    'RTON',
                                                                    'RTON',
                                                                    'Sack',
                                                                    'Set',
                                                                    'Sheet',
                                                                    'Sheet,in bundle/bunch/truss',
                                                                    'Shipment',
                                                                    'Skeleton Case',
                                                                    'Skid',
                                                                    'Slab',
                                                                    'Steel Case',
                                                                    'Steel Envelop',
                                                                    'Tierce',
                                                                    'Time',
                                                                    'Tin',
                                                                    '1.5TONS',
                                                                    '2.5TONS',
                                                                    '3.5TONS',
                                                                    '5TONS',
                                                                    '8TONS',
                                                                    '10TONS',
                                                                    'Tray',
                                                                    'Truck',
                                                                    'Tub',
                                                                    'Unit',
                                                                    'Unpacked or unpackaged',
                                                                    'Vanpack',
                                                                    'Vat',
                                                                    'Wheel',
                                                                    '6WHEELS',
                                                                    '10WHEELS',
                                                                    'Wooden Drum'};

    static {
        // fields of Quote build query
		setFieldsQuote.add('clofor_com_cfs__QuoteIssueDate__c');
		setFieldsQuote.add('clofor_com_cfs__RequesterCompany__r.Name');
		setFieldsQuote.add('clofor_com_cfs__RequesterCompany__r.EnglishCompanyName__c');
		setFieldsQuote.add('clofor_com_cfs__PICOfRequesterCompany__r.Name');
        setFieldsQuote.add('clofor_com_cfs__PICOfRequesterCompany__r.Salutation');
		setFieldsQuote.add('clofor_com_cfs__QuoteName__c');
		setFieldsQuote.add('clofor_com_cfs__DescriptionOfGoods__c');
		setFieldsQuote.add('clofor_com_cfs__Location__c');
		setFieldsQuote.add('clofor_com_cfs__SignandSignature__c');
		setFieldsQuote.add('clofor_com_cfs__QuotationOpening__c');
		setFieldsQuote.add('clofor_com_cfs__QuotationClosing__c');
		setFieldsQuote.add('clofor_com_cfs__Remarks__c');
        setFieldsQuote.add('clofor_com_cfs__Subject__c');
        setFieldsQuote.add('clofor_com_cfs__Scope_of_Work__c');
        setFieldsQuote.add('clofor_com_cfs__QuotePIC__r.Name');
        setFieldsQuote.add('clofor_com_cfs__GrossWeightKG__c');
        setFieldsQuote.add('clofor_com_cfs__NetWeightKG__c');
        setFieldsQuote.add('clofor_com_cfs__MeasurementCBM__c');
        setFieldsQuote.add('clofor_com_cfs__Incoterms__c');
        setFieldsQuote.add('Name');
        setFieldsQuote.add('clofor_com_cfs__QuoteName__c');
        setFieldsQuote.add('clofor_com_cfs__ApprovalStatus__c');
        setFieldsQuote.add('clofor_com_cfs__QuotePIC__r.clofor_com_cfs__Signature__c');
        
        // fields of Quote Line build query
        setFieldsQuoteLine.add('clofor_com_cfs__QuoteLineNumber__c');
		setFieldsQuoteLine.add('clofor_com_cfs__PrintingSection__c');
		setFieldsQuoteLine.add('clofor_com_cfs__LineItemName__c');
        setFieldsQuoteLine.add('clofor_com_cfs__CurrencySelling__c');
        setFieldsQuoteLine.add('clofor_com_cfs__SellingListPriceLocal__c');
		setFieldsQuoteLine.add('clofor_com_cfs__SellingListPriceUSD__c');
		setFieldsQuoteLine.add('clofor_com_cfs__ChargeUnitInPrint__c');
        setFieldsQuoteLine.add('clofor_com_cfs__Quantity__c');
		setFieldsQuoteLine.add('clofor_com_cfs__Remarks__c');
		setFieldsQuoteLine.add('Route__r.Name');
		setFieldsQuoteLine.add('Route__r.Remarks__c');
		setFieldsQuoteLine.add('Route__r.TableNumber__c');
    }

    public class ChargeUnitWrapper {
       public ChargeUnitWrapper(){}
       public String  itemName{get;set;}
       public String  section{get;set;}
       public String  unit{get;set;}
       public Decimal price{get;set;}
       public Decimal quantity{get;set;}
       public Decimal amount{get;set;}
       public String  remark{get;set;}
       public String curr {get;set;}

       public ChargeUnitWrapper(clofor_com_cfs__QuoteLine__c ql) {
            itemName = ql.clofor_com_cfs__LineItemName__c;
            section = ql.clofor_com_cfs__PrintingSection__c;
            unit = ql.clofor_com_cfs__ChargeUnitInPrint__c;
            curr = ql.clofor_com_cfs__CurrencySelling__c;
            if (ql.clofor_com_cfs__CurrencySelling__c == clofor_com_cfs__Site_Custom_Settings__c.getOrgDefaults().Local_Currency__c) {
                price = ql.clofor_com_cfs__SellingListPriceLocal__c != null ? ql.clofor_com_cfs__SellingListPriceLocal__c : 0;
            } else {
                price = ql.clofor_com_cfs__SellingListPriceUSD__c != null ? ql.clofor_com_cfs__SellingListPriceUSD__c : 0;
            }
            quantity = ql.clofor_com_cfs__Quantity__c != null ? ql.clofor_com_cfs__Quantity__c : 0;
            amount = price * quantity;
            remark = (ql.clofor_com_cfs__Remarks__c == null) ? HYPHEN : ql.clofor_com_cfs__Remarks__c;
       }
    }

    public class RouterDataWapper {
        // public RouterDataWapper(){}
        public String routerTitle{get;set;}
        public String section1st{get;set;}
        public String section2nd{get;set;}
        public String routerRemark{get;set;}
        public RouterDataWapper(String title, String section1st, String section2nd, String remark) {
            this.routerTitle = title;
            this.section1st = section1st;
            this.section2nd = section2nd;
            this.routerRemark = remark;
        }
    }
    
    public page_QuotationPrintPdfCtrl() {
        quoteId = ApexPages.currentPage().getParameters().get('Id');
        mapDynamicReferences = new Map<String, RouterDataWapper>();
        formatUnitPrice = new String[]{'0','number','###,###,###,##0.00'};
        Apexpages.currentPage().getHeaders().put('content-disposition', 'filename=AccountReport.pdf');
        readSubject = '';

        if (!String.isBlank(quoteId)) {
            quote = getQuoteById();
            readSubject += quote.clofor_com_cfs__MeasurementCBM__c != null?' Total CBM: '+quote.clofor_com_cfs__MeasurementCBM__c +' CBM,':'';
            readSubject += quote.clofor_com_cfs__GrossWeightKG__c != null?' Gross Weight: ' +quote.clofor_com_cfs__GrossWeightKG__c +' Kgs,':'';
            readSubject += quote.clofor_com_cfs__NetWeightKG__c != null?' Net Weight: '+quote.clofor_com_cfs__NetWeightKG__c +' Kgs,':'';
            readSubject += quote.clofor_com_cfs__Incoterms__c != null?' Incoterms: '+quote.clofor_com_cfs__Incoterms__c:'';
            readSubject = readSubject.removeStart(' ');
            readSubject = readSubject.removeEnd(',');
            List<clofor_com_cfs__QuoteLine__c> listAllQuoteLine = getAllQuoteLine();
            Map<String, List<clofor_com_cfs__QuoteLine__c>> mapRouters = new Map<String, List<clofor_com_cfs__QuoteLine__c>>();
            for (clofor_com_cfs__QuoteLine__c sobj : listAllQuoteLine) {
                String titleNum = sobj.Route__r.TableNumber__c != null ? sobj.Route__r.TableNumber__c + '.' : '';
                String key = titleNum + sobj.Route__r.Name;
                if (mapRouters.containsKey(key)) {
                    mapRouters.get(key).add(sobj);
                } else {
                    mapRouters.put(key, new List<clofor_com_cfs__QuoteLine__c> {sobj});
                }
            }

            for (String keyRouter : mapRouters.keySet()) {
                Map<String, List<ChargeUnitWrapper>> mapRecordTable = new Map<String, List<ChargeUnitWrapper>>();
                Map<String, Decimal> mapSortTable = new Map<String, Decimal>();
                List<String> lstSortLineItemName;
                List<String> listDataTableHtmlSection1st = new List<String>();
                List<String> listDataTableHtmlSection2nd = new List<String>();
                Set<String> setChargeUnitForSc1 = new Set<String>();
                Set<String> setChargeUnitForSc2 = new Set<String>();
                String routerRemark = '';
                for (clofor_com_cfs__QuoteLine__c q : mapRouters.get(keyRouter)) {
                    String section = q.clofor_com_cfs__PrintingSection__c;
                    String chargeUnit =  q.clofor_com_cfs__ChargeUnitInPrint__c;
                    String keyLineItemSection =  q.clofor_com_cfs__LineItemName__c + section;
                    ChargeUnitWrapper tmp = new ChargeUnitWrapper(q);
                    if (mapRecordTable.containsKey(keyLineItemSection)) {
                        Boolean isExistUnit = false;
                        for (ChargeUnitWrapper v : mapRecordTable.get(keyLineItemSection)) {
                            if (v.unit == chargeUnit) {
                                // v.price += q.clofor_com_cfs__SellingListPriceUSD__c != null ? q.clofor_com_cfs__SellingListPriceUSD__c : 0;
                                if (q.clofor_com_cfs__CurrencySelling__c == clofor_com_cfs__Site_Custom_Settings__c.getOrgDefaults().Local_Currency__c){
                                    v.price = q.clofor_com_cfs__SellingListPriceLocal__c != null ? q.clofor_com_cfs__SellingListPriceLocal__c : 0;
                                } else {
                                    v.price = q.clofor_com_cfs__SellingListPriceUSD__c != null ? q.clofor_com_cfs__SellingListPriceUSD__c : 0;
                                }
                                v.quantity += q.clofor_com_cfs__Quantity__c != null ? q.clofor_com_cfs__Quantity__c : 0;
                                v.amount += v.price*v.quantity;
                                isExistUnit = true;
                                break;
                            }
                        }
                        // if do not exist charge unit add new for list wrapper
                        if (!isExistUnit) {
                            mapRecordTable.get(keyLineItemSection).add(tmp);
                        }
                        if(q.clofor_com_cfs__QuoteLineNumber__c > mapSortTable.get(keyLineItemSection)) {
                            mapSortTable.put(keyLineItemSection, q.clofor_com_cfs__QuoteLineNumber__c);
                        }
                    } else {
                        mapSortTable.put(keyLineItemSection, q.clofor_com_cfs__QuoteLineNumber__c);
                        mapRecordTable.put(keyLineItemSection, new List<ChargeUnitWrapper>{tmp});
                    }

    
                    // get charge unit for section 1
                    if (section == SECTION_1ST) {
                        setChargeUnitForSc1.add(chargeUnit);
                    }
    
                    // get charge unit for section 2
                    if (section == SECTION_2ND) {
                        setChargeUnitForSc2.add(chargeUnit);
                    }
    
                    // Router Remark for Quotation
                    routerRemark = q.Route__r.Remarks__c;
                }
                System.debug('setChargeUnitForSc1: '+ setChargeUnitForSc1);
                System.debug('setChargeUnitForSc2: '+ setChargeUnitForSc2);
                // init expand table
                isExistTableData = true;
                // Build th table for section 1st
                if (!setChargeUnitForSc1.isEmpty()) {
                    String lineItemNameTemp;
                    lstSortLineItemName = new  List<String> (mapSortTable.keySet());
                    if(lstSortLineItemName.size() >1) {
                        for(Integer i =1; i< lstSortLineItemName.size(); i++) {
                            for(Integer z =1; z< lstSortLineItemName.size(); z++) {
                                if(mapSortTable.get(lstSortLineItemName[z]) < mapSortTable.get(lstSortLineItemName[z-1])) {
                                    lineItemNameTemp = lstSortLineItemName[z];
                                    lstSortLineItemName[z] = lstSortLineItemName[z-1];
                                    lstSortLineItemName[z-1] = lineItemNameTemp;
                                }
                            }
                        }
                    }
                    listDataTableHtmlSection1st = generalTableData(mapRecordTable, setChargeUnitForSc1, SECTION_1ST, lstSortLineItemName);
                    System.debug('lstSortLineItemName1: '+ lstSortLineItemName);
                }
                // Build th table for section 2nd
                if (!setChargeUnitForSc2.isEmpty()) {
                    listDataTableHtmlSection2nd = generalTableData(mapRecordTable, setChargeUnitForSc2, SECTION_2ND, lstSortLineItemName);
                    System.debug('lstSortLineItemName2: '+ lstSortLineItemName);
                }
                // Build data router
                RouterDataWapper objectBuilder = new RouterDataWapper(
                    keyRouter, 
                    convertListToString(listDataTableHtmlSection1st), 
                    convertListToString(listDataTableHtmlSection2nd),
                    routerRemark
                );
                mapDynamicReferences.put(keyRouter, objectBuilder);
            }
        }
    }

    private String convertListToString(List<String> listString) {
        String result = '';
        if (!listString.isEmpty()) {
            result = String.join(listString,'');
        }
        return result;
    }

    private clofor_com_cfs__Quote__c getQuoteById() {
        String sqlStr = 'SELECT Id,' + String.join(new List<String>(setFieldsQuote), ',');
        sqlStr += ' FROM clofor_com_cfs__Quote__c WHERE Id = \'' + String.escapeSingleQuotes(quoteId) + '\'';
        List<clofor_com_cfs__Quote__c> sobjQuotes = Database.query(sqlStr);
        return !sobjQuotes.isEmpty() ? sobjQuotes[0] : new clofor_com_cfs__Quote__c();
    }

    private List<clofor_com_cfs__QuoteLine__c> getAllQuoteLine() {
        String sqlStr = 'SELECT Id,' + String.join(new List<String>(setFieldsQuoteLine), ',');
        sqlStr += ' FROM clofor_com_cfs__QuoteLine__c';
        String whereClause = '  WHERE clofor_com_cfs__QuoteID__c = \'' + String.escapeSingleQuotes(quoteId) + '\'';
        whereClause += ' AND clofor_com_cfs__LineItemName__c != null';
        whereClause += ' AND clofor_com_cfs__ChargeUnitInPrint__c != null';
        whereClause += ' AND (clofor_com_cfs__SellingListPriceUSD__c != null OR clofor_com_cfs__SellingListPriceLocal__c != null)';
        String orderClause = ' ORDER BY clofor_com_cfs__QuoteLineNumber__c, Route__r.TableNumber__c, clofor_com_cfs__ChargeUnitInPrint__c, clofor_com_cfs__LineItemName__c, clofor_com_cfs__SellingListPriceUSD__c';
        sqlStr += whereClause;
        sqlStr += orderClause; 
        List<clofor_com_cfs__QuoteLine__c> sobjQuoteLines = Database.query(sqlStr);
        return !sobjQuoteLines.isEmpty() ? sobjQuoteLines : new List<clofor_com_cfs__QuoteLine__c>();
    }

    private String tableHeaderBuilder(List<String> listTableHeaderValues, String section) {
        String thBuilder = '<thead>';
        thBuilder += '<tr class="slds-line-height_reset">';
        Integer i = 1;
        Integer endCol = !listTableHeaderValues.isEmpty() ? listTableHeaderValues.size() : 1;
        for (String thValue : listTableHeaderValues) {
            if (i == 1 || i == endCol) {
                thBuilder += i == endCol ? '<th class="slds-border-right" >' : '<th >';
            } else if (i == 2) {
                thBuilder += '<th style = "width: 20%; text-align: center;">';
            } else if (section ==  SECTION_2ND && i == 5) {
                thBuilder += '<th  colspan="2" class="slds-fixed-size" style = "width: 8%;>';
            } else {
                thBuilder += '<th  colspan="2" class="slds-fixed-size" style = "width: 13%;>';
            }
            thBuilder += '<div class="slds-truncate">' + thValue + '</div>';
            thBuilder += '</th>';

            i++;
        }
        thBuilder += '</tr>';
        thBuilder += '</thead>';

        return thBuilder;
    }

    private String tableBodyBuilder(List<String> listTableBodyValues, String section, String curr) {
        System.debug('curr:'+ curr);
        System.debug('lsst'+listTableBodyValues.size());
        System.debug('lsst'+listTableBodyValues);
        String tbodyBuilder = '<tr>';
        Integer i = 1;
        Integer endCol = !listTableBodyValues.isEmpty() ? listTableBodyValues.size() : 1;
        for (String tdValue : listTableBodyValues) {
            if (i == 1 || i == endCol) {
                tbodyBuilder += i == 1 ? '<td class="slds-text-align_center">' : '<td class="slds-text-align_center slds-border-right">';
            } else if(i == 2) {
                tbodyBuilder += '<td class="slds-text-align_left">';
            } else if(section ==  SECTION_2ND && (i == 3 || i == 5)) {
                tbodyBuilder += '<td class="slds-text-align_center" colspan="2">';
                // tbodyBuilder += '<td class="slds-text-align_center slds-none-border-left">';
            } else {
                tbodyBuilder += '<td class="slds-text-align_left">';
                if (curr == 'PHP'){
                    tbodyBuilder += '<div class="slds-truncate">' + '₱' + '</div>';
                } else if (curr == 'USD') {
                    tbodyBuilder += '<div class="slds-truncate">' + '$' + '</div>';
                } else if (curr == 'VND') {
                    tbodyBuilder += '<div class="slds-truncate">' + '₫' + '</div>';
                } else if (curr == 'JPY') {
                    tbodyBuilder += '<div class="slds-truncate">' + '¥' + '</div>';
                }
                tbodyBuilder += '</td>';
                tbodyBuilder += '<td class="slds-text-align_right slds-none-border-left">';
            }
            tbodyBuilder += '<div class="slds-truncate">' + tdValue + '</div>';
            tbodyBuilder += '</td>';
            i++;
        }
        tbodyBuilder += '</tr>';

        return tbodyBuilder;
    }

    private String tableBodyBuilder(List<String> listTableBodyValues, String section, List<String> curr) {
        System.debug('curr:'+ curr);
        System.debug('lsst'+listTableBodyValues.size());
        System.debug('lsst'+listTableBodyValues);
        String tbodyBuilder = '<tr>';
        Integer i = 1;
        Integer endCol = !listTableBodyValues.isEmpty() ? listTableBodyValues.size() : 1;
        for (String tdValue : listTableBodyValues) {
            if (i == 1 || i == endCol) {
                tbodyBuilder += i == 1 ? '<td class="slds-text-align_center">' : '<td class="slds-text-align_center slds-border-right">';
            } else if(i == 2) {
                tbodyBuilder += '<td class="slds-text-align_left">';
            } else if(section ==  SECTION_2ND && (i == 3 || i == 5)) {
                tbodyBuilder += '<td class="slds-text-align_center" colspan="2">';
                // tbodyBuilder += '<td class="slds-text-align_center slds-none-border-left">';
            } else {
                tbodyBuilder += '<td class="slds-text-align_left">';
                if (curr.get(i-1) == 'PHP'){
                    tbodyBuilder += '<div class="slds-truncate">' + '₱' + '</div>';
                } else if (curr.get(i-1) == 'USD') {
                    tbodyBuilder += '<div class="slds-truncate">' + '$' + '</div>';
                } else if (curr.get(i-1) == 'VND') {
                    tbodyBuilder += '<div class="slds-truncate">' + '₫' + '</div>';
                } else if (curr.get(i-1) == 'JPY') {
                    tbodyBuilder += '<div class="slds-truncate">' + '¥' + '</div>';
                }
                tbodyBuilder += '</td>';
                tbodyBuilder += '<td class="slds-text-align_right slds-none-border-left">';
            }
            tbodyBuilder += '<div class="slds-truncate">' + tdValue + '</div>';
            tbodyBuilder += '</td>';
            i++;
        }
        tbodyBuilder += '</tr>';

        return tbodyBuilder;
    }

    public List<String> generalTableData(Map<String, List<ChargeUnitWrapper>> mapRecordTable, Set<String> setColumn, String section, List<String> lstSortTable) {
        List<String> listHtmlString = new List<String>();
        Integer i = 1;
        Set<String> setHeaderTb = new Set<String>();
        Set<String> setColLessThan3 = new Set<String>(setColumn);
        List<String> listBodyPreVal = new List<String>();
        if (section == SECTION_1ST) {
            for (String unit : bubbleSortChargeUnitWrapper(new List<String>(setColumn))) {
                setHeaderTb.add(unit);
                listBodyPreVal.add(HYPHEN);
                System.debug('unit:'+ unit);
                System.debug('listBodyPreVal123:'+ listBodyPreVal);
                if (i == 5) {
                    // table start
                    String htmlCode = getHtmlStartTable(isExistTableData);
                    List<String> listTh = new List<String>();
                    listTh.add(TH_NO);
                    listTh.add(TH_DESCRIPTION);
                    listTh.addAll(new List<String>(setHeaderTb));
                    // listTh.addAll(setHeaderTb);
                    listTh.add(TH_REMARK);
                    // Build th for table
                    htmlCode += tableHeaderBuilder(listTh, section);
                    
                    Integer j = 1;
                    Map<String, List<String>> mapLineItem = new Map<String, List<String>>();
                    Map<String, List<String>> mapCurr = new Map<String, List<String>>();
                    System.debug('lstSortTable: '+lstSortTable);
                    System.debug('mapRecordTable: '+mapRecordTable);
                    for (String k : lstSortTable) {
                        if (k.containsIgnoreCase(section)) {
                            for (ChargeUnitWrapper unitInfo : mapRecordTable.get(k)) {
                                if (setHeaderTb.contains(unitInfo.unit)) {
                                    String lineItemName = unitInfo.itemName;
                                    String unitPrice = '';
                                    if(unitInfo.curr == 'VND'){
                                        unitPrice = (unitInfo.price.setScale(0, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(0, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(0, RoundingMode.HALF_UP).format()));
                                    } else {
                                        unitPrice = (unitInfo.price.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(2, RoundingMode.HALF_UP).format()+'.00'));
                                    }
                                    // String unitPrice = (unitInfo.price.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(2, RoundingMode.HALF_UP).format()+'.00'));
                                    Integer indexUnitPrice = listTh.indexOf(unitInfo.unit);
    
                                    if (mapLineItem.containsKey(lineItemName)) {
                                        List<String> listLineItemTmp = mapLineItem.get(lineItemName);
                                        listLineItemTmp[indexUnitPrice] = unitPrice;
                                        List<String> listLineItemTmpCurr = mapCurr.get(lineItemName);
                                        listLineItemTmpCurr[indexUnitPrice] = unitInfo.curr;
                                        System.debug('listLineItemTmp:'+listLineItemTmp[indexUnitPrice]);
                                    } else {
                                        List<String> listTd = new List<String>();
                                        listTd.add(String.valueOf(j));
                                        listTd.add(lineItemName);
                                        listTd.addAll(listBodyPreVal);
                                        listTd.add(unitInfo.remark);
                                        // Set price for unit column
                                        listTd[indexUnitPrice] = unitPrice;
                                        mapLineItem.put(lineItemName, listTd);
                                        List<String> listTdCurr = new List<String>();
                                        listTdCurr.add(String.valueOf(j));
                                        listTdCurr.add(lineItemName);
                                        listTdCurr.addAll(listBodyPreVal);
                                        listTdCurr.add(unitInfo.remark);
                                        // Set price for unit column
                                        listTdCurr[indexUnitPrice] = unitInfo.curr;
                                        mapCurr.put(lineItemName, listTdCurr);
                                        // mapCurr.put(lineItemName,unitInfo.curr);
                                        j++;
                                        System.debug('listTd: '+listTd);
                                    }
                                }
                            }
                        }
                    }
    
                    // Loop all row data line Item pickup
                    htmlCode += getTbodyTable(true);
                    System.debug('mapLineItem1: '+mapLineItem);
                    System.debug('mapCurr: '+mapCurr);
                    for (String rowData : mapLineItem.keySet()) {
                        htmlCode += tableBodyBuilder(mapLineItem.get(rowData), section, mapCurr.get(rowData));
                        System.debug('ok...');
                    }
                    htmlCode += getTbodyTable(false);
                    htmlCode += '</table>'; 
                    listHtmlString.add(htmlCode);
                    isExistTableData = true;
    
                    // Clear data builder
                    setCollessThan3.removeAll(setHeaderTb);
                    setHeaderTb.clear();
                    listBodyPreVal.clear();
                    i = 1;
                    continue;
                }
                i++;
            }
    
            setCollessThan3 = new Set<String>(bubbleSortChargeUnitWrapper(new List<String>(setCollessThan3)));
            System.debug('setCollessThan3: '+ setCollessThan3);
            if (!setCollessThan3.isEmpty()) {
                String htmlCode = getHtmlStartTable(isExistTableData);
                List<String> listTh = new List<String>();
                listTh.add(TH_NO);
                listTh.add(TH_DESCRIPTION);
                listTh.addAll(new List<String>(setCollessThan3));
                // listTh.addAll(setCollessThan3);
                listTh.add(TH_REMARK);
                // Build th for table
                htmlCode += tableHeaderBuilder(listTh, section);
    
                List<String> listTbodyExpand = new List<String>();
                for (String s : setCollessThan3) {
                    listTbodyExpand.add(HYPHEN);
                }
                
                Integer j = 1;
                Map<String, List<String>> mapLineItem = new Map<String, List<String>>();
                Map<String, List<String>> mapCurr = new Map<String, List<String>>();
                for (String k : lstSortTable) {
                    if (k.containsIgnoreCase(section)) {
                        for (ChargeUnitWrapper unitInfo : mapRecordTable.get(k)) {
                            if (setHeaderTb.contains(unitInfo.unit)) {
                                String lineItemName = unitInfo.itemName;
                                String unitPrice = '';
                                if(unitInfo.curr == 'VND'){
                                    unitPrice = (unitInfo.price.setScale(0, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(0, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(0, RoundingMode.HALF_UP).format()));
                                } else {
                                    unitPrice = (unitInfo.price.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(2, RoundingMode.HALF_UP).format()+'.00'));
                                }
                                // String unitPrice = (unitInfo.price.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(2, RoundingMode.HALF_UP).format()+'.00'));
                                Integer indexUnitPrice = listTh.indexOf(unitInfo.unit);
    
                                if (mapLineItem.containsKey(lineItemName)) {
                                    List<String> listLineItemTmp = mapLineItem.get(lineItemName);
                                    listLineItemTmp[indexUnitPrice] = unitPrice;
                                    List<String> listLineItemTmpCurr = mapCurr.get(lineItemName);
                                    listLineItemTmpCurr[indexUnitPrice] = unitInfo.curr;
                                } else {
                                    List<String> listTd = new List<String>();
                                    listTd.add(String.valueOf(j));
                                    listTd.add(lineItemName);
                                    listTd.addAll(listTbodyExpand);
                                    listTd.add(unitInfo.remark);
                                    // Set price for unit column
                                    listTd[indexUnitPrice] = unitPrice;
                                    mapLineItem.put(lineItemName, listTd);

                                    // Set curr for column
                                    List<String> listTdCurr = new List<String>();
                                    listTdCurr.add(String.valueOf(j));
                                    listTdCurr.add(lineItemName);
                                    listTdCurr.addAll(listTbodyExpand);
                                    listTdCurr.add(unitInfo.remark);
                                    listTdCurr[indexUnitPrice] = unitInfo.curr;
                                    mapCurr.put(lineItemName,listTdCurr);
                                    j++;
                                }
                            }
                        }
                    }
                }
    
                // Loop all row data line Item pickup
                System.debug('mapLineItem2'+mapLineItem);
                System.debug('mapCurr2:'+mapCurr);
                htmlCode += getTbodyTable(true);
                for (String rowData : mapLineItem.keySet()) {
                    htmlCode += tableBodyBuilder(mapLineItem.get(rowData), section, mapCurr.get(rowData));
                    System.debug('oke2...');
                }
                htmlCode += getTbodyTable(false);
                htmlCode += '</table>'; 
                listHtmlString.add(htmlCode);
            }
        } else if (section == SECTION_2ND) {
            isExistTableData = true;
            String htmlCode = getHtmlStartTable(isExistTableData);
            List<String> listTh = new List<String>();
            listTh.add(TH_NO);
            listTh.add(TH_DESCRIPTION);
            listTh.add('Unit');
            listTh.add('Unit Rate');
            listTh.add('QTY');
            listTh.add('Amount');
            listTh.add(TH_REMARK);
            // Build th for table
            htmlCode += tableHeaderBuilder(listTh, section);
            htmlCode += getTbodyTable(true);
            Integer j = 1;
            for (String k : mapRecordTable.keySet()) {
                if (k.containsIgnoreCase(section)) {
                    for (ChargeUnitWrapper unitInfo : mapRecordTable.get(k)) {
                        String lineItemName = unitInfo.itemName;
                        String unitPrice = '';
                        if(unitInfo.curr == 'VND'){
                            unitPrice = unitInfo.price.setScale(0, RoundingMode.HALF_UP) != 0 ? (unitInfo.price.setScale(0, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(0, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(0, RoundingMode.HALF_UP).format())) : HYPHEN;
                        } else {
                            unitPrice = unitInfo.price.setScale(2, RoundingMode.HALF_UP) != 0 ? (unitInfo.price.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(2, RoundingMode.HALF_UP).format()+'.00')) : HYPHEN;
                        }
                        // String unitPrice = unitInfo.price.setScale(2, RoundingMode.HALF_UP) != 0 ? (unitInfo.price.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.price.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.price.setScale(2, RoundingMode.HALF_UP).format()+'.00')) : HYPHEN;
                        String unitQuantity = unitInfo.quantity.setScale(2, RoundingMode.HALF_UP) != 0 ? (unitInfo.quantity.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.quantity.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.quantity.setScale(2, RoundingMode.HALF_UP).format()+'.00')) : HYPHEN;
                        String unitAmount = '';
                        if(unitInfo.curr == 'VND'){
                            unitAmount= unitInfo.amount.setScale(0, RoundingMode.HALF_UP) != 0 ? (unitInfo.amount.setScale(0, RoundingMode.HALF_UP).format().contains('.')?unitInfo.amount.setScale(0, RoundingMode.HALF_UP).format():(unitInfo.amount.setScale(0, RoundingMode.HALF_UP).format())) : HYPHEN;
                        } else {
                            unitAmount= unitInfo.amount.setScale(2, RoundingMode.HALF_UP) != 0 ? (unitInfo.amount.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.amount.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.amount.setScale(2, RoundingMode.HALF_UP).format()+'.00')) : HYPHEN;                        
                        }
                        // String unitAmount= unitInfo.amount.setScale(2, RoundingMode.HALF_UP) != 0 ? (unitInfo.amount.setScale(2, RoundingMode.HALF_UP).format().contains('.')?unitInfo.amount.setScale(2, RoundingMode.HALF_UP).format():(unitInfo.amount.setScale(2, RoundingMode.HALF_UP).format()+'.00')) : HYPHEN;
                        String unitSelling = unitInfo.curr;
                        List<String> listBodySection2nd = new List<String>();
                        listBodySection2nd.add(String.valueOf(j));
                        listBodySection2nd.add(lineItemName);
                        listBodySection2nd.add(unitInfo.unit);
                        listBodySection2nd.add(unitPrice);
                        listBodySection2nd.add(unitQuantity);
                        listBodySection2nd.add(unitAmount);
                        listBodySection2nd.add(unitInfo.remark);
                        j++;
                        htmlCode += tableBodyBuilder(listBodySection2nd, section, unitSelling);
                    }
                }
            }
            htmlCode += getTbodyTable(false);
            htmlCode += '</table>'; 
            listHtmlString.add(htmlCode);
        }
        System.debug('listHtmlString :'+listHtmlString);
        return listHtmlString;
    }

    private String getHtmlStartTable(Boolean isExpandTable) {
        String htmlCode = (isExpandTable == false) ? '<table class="slds-table_bordered" style="border-collapse:collapse;">' : '<table class="slds-table_bordered" style="border-collapse:collapse; margin-top: 7px;">';
        return htmlCode;
    }

    public String getTbodyTable(Boolean isStart){
        return isStart ? '<tbody>' : '</tbody>';
    }

    public Set<String> bubbleSortChargeUnitWrapper(List<String> listUnit) {
        Set<String> values = sortListWithUnit(listUnit);
        return values;
    }

    /*
    public Map<String, Object> convertValueUnit(String str) {
        Map<String, Object> mapResult = new Map<String, Object>();
        if (str != null) {
            String negative = str.left(1);
            String numberOnly = negative + str.replaceAll('[^0-9]', '');
            String unitCharacterOnly = str.replaceAll('[0-9]', '');


            mapResult.put('arg0', Decimal.valueOf(numberOnly));
            mapResult.put('arg1', unitCharacterOnly);
        }

        return mapResult;
    }
    */
    
    public Set<String> sortListWithUnit(List<String> listVal) {
        /*
        Map<String, List<String>> mapSortVal = new Map<String, List<String>>();
        for (String s : listVal) {
            if (s.contains(KGS)) {
                if (mapSortVal.containsKey(KGS)) {
                    mapSortVal.get(KGS).add(s);
                } else {
                    mapSortVal.put(KGS, new List<String>{s});
                }
            } else {
                if (mapSortVal.containsKey(OTHER)) {
                    mapSortVal.get(OTHER).add(s);
                } else {
                    mapSortVal.put(OTHER, new List<String>{s});
                }
            }
        }
        String temp;
        List<String> listResultKGS = new List<String>(mapSortVal.get('KGS'));
        //sort KGS
        for(Integer i=0; i < listResultKGS.size(); i++){
            for(Integer j=1; j < (listResultKGS.size()-i); j++){
                Integer index = j-1;
                Map<String, Object> mapCurrVal = convertValueUnit(listResultKGS[index]);
                Map<String, Object> mapNextVal = convertValueUnit(listResultKGS[j]);
                String unitNext = (String) mapNextVal.get('arg1');
                if(!mapCurrVal.isEmpty() && !mapNextVal.isEmpty() && (Decimal) mapCurrVal.get('arg0') > (Decimal) mapNextVal.get('arg0') && unitNext.contains(KGS)) {
                    temp = listResultKGS[index];
                    listResultKGS[index] = listResultKGS[j];
                    listResultKGS[j] = temp;
                }
            }
        }

        List<String> listResultOTHER = new List<String>(mapSortVal.get('OTHER'));
        //sort OTHER
        for(Integer i=0; i < listResultOTHER.size(); i++){
            for(Integer j=1; j < (listResultOTHER.size()-i); j++){
                Integer index = j-1;
                Map<String, Object> mapCurrVal = convertValueUnit(listResultOTHER[index]);
                Map<String, Object> mapNextVal = convertValueUnit(listResultOTHER[j]);
                String unitNext = (String) mapNextVal.get('arg1');
                if(!mapCurrVal.isEmpty() && !mapNextVal.isEmpty() &&(((String)mapCurrVal.get('arg1') > (String)mapNextVal.get('arg1')) || ( ((String)mapCurrVal.get('arg1') == (String)mapNextVal.get('arg1')) && ((Decimal) mapCurrVal.get('arg0') > (Decimal) mapNextVal.get('arg0'))))) {
                    
                    temp = listResultOTHER[index];
                    listResultOTHER[index] = listResultOTHER[j];
                    listResultOTHER[j] = temp;
                }
            }
        }

        List<String> listResult = new List<String>();
        
        listResult.addAll(listResultKGS);
        listResult.addAll(listResultOTHER);
        return listResult;
        */

        Set<String> listResult = new Set<String>();
        for(String s : lstChargeUnits){
            if(listVal.contains(s)) {
                listResult.add(s);
            }
        }
        return listResult;
    }

}