global with sharing class VATInvoiceController {
    private static List<String> vatFields = new List<String>();
    private static List<String> forwardingFields = new List<String>();
    private static List<String> invoicingFields = new List<String>();
    private static List<String> containerFields = new List<String>();
    private Set<Id> shipmentOrderIdSet;
    private String vatInvoiceId;
    private String groupingOption;
    public VAT_INVOICE__c vatInvoice {get; private set;}
    public String templateSet { get; private set; }

    global static String reportingCurrency { get; private set; }
    global InvoiceReportWrapper wrapper { get; private set; }
    global Map<String, String> translations { get; private set; }
    global string ReportName { get; private set; }

    private final static String FMS_REC_NAME =  'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY';
    private final static String WMS_REC_NAME =  'CloWMSVATInvoice';
    private final static String HBL_NO_INDENTIFICATION =  'H B/L No';
    private final static String MBL_NO_INDENTIFICATION =  'M B/L No';
    private final static String CONTAINER_INDENTIFICATION =  'Container No';
    private final static String SHIPMENT_ORDER_INDENTIFICATION =  'Shipment Order No';
    private final static String MANUAL_INPUT_INDENTIFICATION =  'Manual Input';
    static {

        vatFields.add('Id');
        vatFields.add('Name');
        vatFields.add('RED_INVOICE_NO__c');
        vatFields.add('VAT_INVOICE_TO__r.Name');
        vatFields.add('VAT_INVOICE_TO__r.BillingStreet');
        vatFields.add('VAT_INVOICE_TO__r.BillingCity');
        vatFields.add('VAT_INVOICE_TO__r.BillingState');
        vatFields.add('VAT_INVOICE_TO__r.BillingCountry');
        vatFields.add('VAT_INVOICE_TO__r.EnglishCompanyName__c');
        vatFields.add('VAT_INVOICE_TO__r.EnglishAddress__c');
        vatFields.add('CLIENTS_NAME_IN_VAT_INVOICE__r.Name');
        vatFields.add('CUSTOMER_PHONE_NUMBER__c');
        vatFields.add('VATInvoicePrintDate__c');
        vatFields.add('VAT_INVOICE_ISSUED_BY__r.Name');
        vatFields.add('toLabel(TERMS_OF_PAYMENT__c)');
        vatFields.add('VAT_INVOICE_REMARKS__c');
        vatFields.add('TAX_CODE__c');
        vatFields.add('DESCRIPTION_FOR_COMBINE__c');
        vatFields.add('LOCAL_BANK_ACCOUNT_NUMBER_1__c');
        vatFields.add('LOCAL_BANK_ACCOUNT_NUMBER_2__c');
        vatFields.add('CUSTOMER_BANK_ACCOUNT_NUMBER__c');
        vatFields.add('CREDIT_TERM__c');
        vatFields.add('ShipmentOrderIdentification__c');
        vatFields.add('ShipmentOrderIdentificationDetail__c');
        vatFields.add('RecordType.DeveloperName');

        invoicingFields.add('INVOICING__r.Name');
        invoicingFields.add('INVOICING__r.InsatuyouSyohin__c');
        invoicingFields.add('INVOICING__r.Tariff__r.UNIT__c');
        invoicingFields.add('INVOICING__r.ChargeUnitinPrint__c');
        invoicingFields.add('INVOICING__r.ChargeUnitFormula__c');
        invoicingFields.add('INVOICING__r.ContainerSizeFormula__c');
        invoicingFields.add('INVOICING__r.SellTankaJPY__c');
        invoicingFields.add('INVOICING__r.SellTankaUSD__c');
        invoicingFields.add('INVOICING__r.SellAmountJPN__c');
        invoicingFields.add('INVOICING__r.SellAmountUSD__c');
        invoicingFields.add('INVOICING__r.SeikyuBangou__c');
        invoicingFields.add('INVOICING__r.wkSuryo__c');
        invoicingFields.add('INVOICING__r.Tariff__r.ContainerSize__c');
        invoicingFields.add('INVOICING__r.curr__c');
        invoicingFields.add('INVOICING__r.Anken__r.Id');
        invoicingFields.add('INVOICING__r.Anken__r.Name');
        invoicingFields.add('INVOICING__r.Anken__c');

        invoicingFields.add('INVOICING__r.TaxInitial__c');
        invoicingFields.add('INVOICING__r.SellTaxNum__c');
        invoicingFields.add('INVOICING__r.SellTaxNum_USD__c');
        invoicingFields.add('INVOICING__r.SellInTaxAmountJPY__c');
        invoicingFields.add('INVOICING__r.SellInTaxAmountJPY_NoRound__c');
        invoicingFields.add('INVOICING__r.SellInTaxAmount_USD__c');
        invoicingFields.add('INVOICING__r.ProductTax__c');
        invoicingFields.add('INVOICING__r.TAX_ADJUSTMENTSELL__c');
        invoicingFields.add('INVOICING__r.Tariff__r.EngSubcategory__c');
        invoicingFields.add('INVOICING__r.Tariff__r.VATInvoiceAtPrintLocal__c');

        forwardingFields.add('FORWARDING__r.Name');
        forwardingFields.add('FORWARDING__r.Id');
        forwardingFields.add('FORWARDING__r.RecordTypeId');
        forwardingFields.add('FORWARDING__r.HBL_Number_SEA_AIR__c');
        forwardingFields.add('DESCRIPTION__c');
        forwardingFields.add('FORWARDING__r.ETD__c');
        forwardingFields.add('FORWARDING__r.ETA__c');
        forwardingFields.add('FORWARDING__r.shipper__r.Name');
        forwardingFields.add('FORWARDING__r.Cnee__r.Name');
        forwardingFields.add('FORWARDING__r.SalesAccountedDate__c');
        forwardingFields.add('FORWARDING__r.Container__c');
        forwardingFields.add('FORWARDING__r.Container2__c');
        forwardingFields.add('FORWARDING__r.Container3__c');
        forwardingFields.add('FORWARDING__r.Container4__c');
        forwardingFields.add('FORWARDING__r.ContainerNumber__c');
        forwardingFields.add('FORWARDING__r.ContainerNumber2__c');
        forwardingFields.add('FORWARDING__r.ContainerNumber3__c');
        forwardingFields.add('FORWARDING__r.ContainerNumber4__c');
        forwardingFields.add('FORWARDING__r.POL__r.Name');
        forwardingFields.add('FORWARDING__r.POD__r.Name');
        forwardingFields.add('FORWARDING__r.MBL_Number_SEA_AIR__c');
        forwardingFields.add('FORWARDING__r.ContainerNo__c');
        forwardingFields.add('FORWARDING__r.Fowarding__c');
        forwardingFields.add('VAT_INVOICE__r.RecordType.DeveloperName');
        forwardingFields.add('FORWARDING__c');
        forwardingFields.add('FORWARDING__r.ID__c');
        forwardingFields.add('FORWARDING__r.WkInitial__c');

        // Container detail Field
        containerFields.add('Id');
        containerFields.add('Container_NO__c');
        containerFields.add('HBL_SHIPMENT__c');

    }

    global VATInvoiceController() {
        this.ReportName = ApexPages.currentPage().getParameters().get('reportpage');//ApexPages.currentPage().getParameters().containsKey('reportpage') ? ApexPages.currentPage().getParameters().get('reportpage') : ApexPages.currentPage().getUrl().replaceAll('\\?.*', '').replaceAll('/apex/', '');
        initializeTranslation();
        wrapper = new InvoiceReportWrapper();
        readParameters();
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()
                && PermissionValidationUtil.isEditableVATInvoice() && PermissionValidationUtil.isAccessibleInvoicingVAT()
                && PermissionValidationUtil.isAccessibleForwardingVAT()) {
            buildReportData();
        }

    }

    public PageReference checkCustomTemplateUsed() {
        return String.isBlank(Site_Custom_Settings__c.getOrgDefaults().CustomInvoiceTemplate__c) ? null : new PageReference('/apex/' + Site_Custom_Settings__c.getOrgDefaults().CustomInvoiceTemplate__c);
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('Invoice', ApexPages.currentPage().getParameters().get('language').toLowerCase());
        translations = translationService.getTranslations();
    }

    private void buildReportData() {
        final String query = 'SELECT ' + String.join(vatFields, ',') + ' FROM VAT_INVOICE__c WHERE Id = \'' + StringUtils.escapeSingleQuotes(vatInvoiceId) + '\'';
        vatInvoice = Database.query(query);

        if (vatInvoice != null) {
            wrapper.invoiceNo = vatInvoice.RED_INVOICE_NO__c;
            wrapper.invoiceTo = vatInvoice.VAT_INVOICE_TO__r.Name;
            wrapper.invoiceToENG = vatInvoice.VAT_INVOICE_TO__r.EnglishCompanyName__c;
            wrapper.addressENG = vatInvoice.VAT_INVOICE_TO__r.EnglishAddress__c;
            wrapper.clientName = vatInvoice.CLIENTS_NAME_IN_VAT_INVOICE__r.Name;
            wrapper.issuedBy = vatInvoice.VAT_INVOICE_ISSUED_BY__r.Name;
            wrapper.issuedDate = vatInvoice.VATInvoicePrintDate__c;
            wrapper.termsOfPayment = translations.get(vatInvoice.TERMS_OF_PAYMENT__c);
            wrapper.remarks = vatInvoice.VAT_INVOICE_REMARKS__c;
                /*
            String remark = vatInvoice.VAT_INVOICE_REMARKS__c;
            wrapper.remarks = '';
            if(!String.isBlank(remark)){
                while(remark.length() > 35){
                wrapper.remarks += remark.substring(0,35) + ' ';
                remark = remark.substring(35,remark.length());
                }
                if(remark.length() < 35){
                   wrapper.remarks += remark;
                }

            }
*/

            wrapper.taxCode = vatInvoice.TAX_CODE__c;
            wrapper.setBankAccounts(vatInvoice.LOCAL_BANK_ACCOUNT_NUMBER_1__c, vatInvoice.LOCAL_BANK_ACCOUNT_NUMBER_2__c);
            wrapper.setInvoiceToAddress(vatInvoice.VAT_INVOICE_TO__r.BillingStreet, vatInvoice.VAT_INVOICE_TO__r.BillingCity,
                    vatInvoice.VAT_INVOICE_TO__r.BillingState, vatInvoice.VAT_INVOICE_TO__r.BillingCountry);
            wrapper.customerBankAccount = vatInvoice.CUSTOMER_BANK_ACCOUNT_NUMBER__c;
            wrapper.creditTerm = vatInvoice.CREDIT_TERM__c;
            wrapper.customerPhoneNumber = vatInvoice.CUSTOMER_PHONE_NUMBER__c;

            List<FORWARDING_VAT__c> lstVATHBL = enquiryHBL(vatInvoiceId);
            shipmentOrderIdSet = new Set<Id>();
            for(FORWARDING_VAT__c fwd : lstVATHBL){
                shipmentOrderIdSet.add(fwd.FORWARDING__c);
            }
            // get Container Detail

            Map<Id, List<String>> containersByShipmentOrderMap = getContainerDetailByShipment();

            if (lstVATHBL != null && !lstVATHBL.isEmpty()) {
                List<INVOICING_VAT__c> lstVATHBLSB = enquiryHBLSB(vatInvoiceId);

                if (lstVATHBLSB != null && !lstVATHBLSB.isEmpty()) {
                    List<InvoiceLineItem> lineItems = null;
                    if (Constants.GROUPED_BY_FORWARDING_KEY.equalsIgnoreCase(groupingOption)) {
                        lineItems = groupDataByHBL(lstVATHBLSB);
                    } else if (Constants.GROUPED_BY_INVOICING_KEY.equalsIgnoreCase(groupingOption)) {
                        lineItems = groupDataByHBLSB(lstVATHBLSB);
                    } else if (Constants.SUMMARY_KEY.equalsIgnoreCase(groupingOption)) {
                        lineItems = groupAllData(lstVATHBLSB);
                    } else if (Constants.GROUPED_BY_CATEGORY_KEY.equalsIgnoreCase(groupingOption)) {
                        lineItems = groupDataByPricingSubCategory(lstVATHBLSB);
                    }

                    wrapper.invoiceLineItems = lineItems;
                    Set<String> taxSet = new Set<String>();
                    for (InvoiceLineItem li : lineItems) {
                        wrapper.totalAmount += li.totalAmount;
                        wrapper.totalTaxSellingAdjustmentAmount += (li.taxSellingAdjustmentAmount == null ? 0 : li.taxSellingAdjustmentAmount);
                        if (li.tax != null) {
                           taxSet.add(li.tax);
                        }
                    }
                    List<String> taxList = new List<String>(taxSet);
                    wrapper.tax = String.join(taxList, '/');
                }

                List<String> wkids = new List<String>();
                List<String> numberSeaAir = new List<String>();
                for (FORWARDING_VAT__c vatHBL : lstVATHBL) {
                    // 2018-09-9 START- AFR-55: Change identification on DRAFT & ORIGINAL VAT in CloFMS
                    if(vatInvoice.RecordType.DeveloperName == FMS_REC_NAME){
                        String identificationTemp = '';
                        if(vatInvoice.ShipmentOrderIdentification__c != null){
                            if(vatInvoice.ShipmentOrderIdentification__c.contains(HBL_NO_INDENTIFICATION)
                            && vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c != null){
                            identificationTemp += vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c;
                            }
                            if(vatInvoice.ShipmentOrderIdentification__c.contains(MBL_NO_INDENTIFICATION)
                                && vatHBL.FORWARDING__r.MBL_Number_SEA_AIR__c != null){
                                identificationTemp += String.isBlank(identificationTemp) ? vatHBL.FORWARDING__r.MBL_Number_SEA_AIR__c : ': ' + vatHBL.FORWARDING__r.MBL_Number_SEA_AIR__c;
                            }
                            if(vatInvoice.ShipmentOrderIdentification__c.contains(CONTAINER_INDENTIFICATION)
                                && containersByShipmentOrderMap.containsKey(vatHBL.FORWARDING__c)){
                                String containerDetailStr = String.join(containersByShipmentOrderMap.get(vatHBL.FORWARDING__c), ', ');
                                identificationTemp += String.isBlank(identificationTemp) ? containerDetailStr : ': ' + containerDetailStr;
                            }
                            if(vatInvoice.ShipmentOrderIdentification__c.contains(SHIPMENT_ORDER_INDENTIFICATION)
                                && vatHBL.FORWARDING__r.ID__c != null){

                                String shipmentName = 'S' + vatHBL.FORWARDING__r.WkInitial__c + vatHBL.FORWARDING__r.Name;
                                identificationTemp += String.isBlank(identificationTemp) ? shipmentName : ': ' + shipmentName;
                            }
                        }
                        if(!String.isBlank(identificationTemp)){
                            wkids.add(identificationTemp);
                        }

                    }

                    //wkids.add(vatHBL.FORWARDING__r.Name + (StringUtils.isEmpty(vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c) ? '' : ('(' + vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c + ')')));
                    // 2018-09-9 END - AFR-55: Change Remarks on DRAFT & ORIGINAL VAT in CloFMS

                    numberSeaAir.add(StringUtils.isEmpty(vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c) ? '' : (vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c));

                    // for Campodia requirement
                    wrapper.etd = vatHBL.FORWARDING__r.ETD__c;
                    wrapper.eta = vatHBL.FORWARDING__r.ETA__c;

                    if (ObjectClassificationUtils.isImportHBL(vatHBL.FORWARDING__r.RecordTypeId)) {
                        wrapper.shipper = vatHBL.FORWARDING__r.shipper__r.Name;
                        wrapper.consignee = null;
                    } else if (ObjectClassificationUtils.isExportHBL(vatHBL.FORWARDING__r.RecordTypeId)) {
                        wrapper.shipper = null;
                        wrapper.consignee = vatHBL.FORWARDING__r.Cnee__r.Name;
                    }

                    wrapper.projectJob = vatHBL.FORWARDING__r.Name;
                    wrapper.serviceDate = vatHBL.FORWARDING__r.SalesAccountedDate__c;
                    wrapper.container = vatHBL.FORWARDING__r.Container__c;
                    wrapper.container2 = vatHBL.FORWARDING__r.Container2__c;
                    wrapper.container3 = vatHBL.FORWARDING__r.Container3__c;
                    wrapper.container4 = vatHBL.FORWARDING__r.Container4__c;
                    wrapper.containerNumber = vatHBL.FORWARDING__r.ContainerNumber__c;
                    wrapper.containerNumber2 = vatHBL.FORWARDING__r.ContainerNumber2__c;
                    wrapper.containerNumber3 = vatHBL.FORWARDING__r.ContainerNumber3__c;
                    wrapper.containerNumber4 = vatHBL.FORWARDING__r.ContainerNumber4__c;
                    wrapper.pol = vatHBL.FORWARDING__r.POL__r.Name;
                    wrapper.pod = vatHBL.FORWARDING__r.POD__r.Name;
                    wrapper.mblNumberSeaAir = vatHBL.FORWARDING__r.MBL_Number_SEA_AIR__c;
                    wrapper.hblNumberSeaAir = vatHBL.FORWARDING__r.HBL_Number_SEA_AIR__c;
                }
                if((vatInvoice.ShipmentOrderIdentification__c != null
                    && vatInvoice.ShipmentOrderIdentification__c.contains(MANUAL_INPUT_INDENTIFICATION))
                    || vatInvoice.ShipmentOrderIdentification__c == null ){
                    wrapper.WKIDs = vatInvoice.ShipmentOrderIdentificationDetail__c;
                    // wrapper.WKIDs = new List<String>{vatInvoice.ShipmentOrderIdentificationDetail__c};
                }
                else{
                    wrapper.WKIDs = String.join(wkids, '/ ');
                    //wrapper.WKIDs = wkids;

                }
                wrapper.NumberSeaAir = String.join(numberSeaAir, ' / ');
            }
        }

    }

    private Map<Id, List<String>> getContainerDetailByShipment(){

        String strQuery = 'SELECT ' + String.join(containerFields, ',') + ' FROM Container_Info__c WHERE HBL_SHIPMENT__c IN: shipmentOrderIdSet';
        List<Container_Info__c> containerDetailList = Database.query(strQuery);
        Map<Id, List<String>> containersByShipmentOrderMap = new Map<Id, List<String>> ();
        for(Container_Info__c containerinfo : containerDetailList){
            if(containersByShipmentOrderMap.containsKey(containerinfo.HBL_SHIPMENT__c)){
                containersByShipmentOrderMap.get(containerinfo.HBL_SHIPMENT__c).add(containerinfo.Container_NO__c);
            }else{
                containersByShipmentOrderMap.put(containerinfo.HBL_SHIPMENT__c, new List<String>{containerinfo.Container_NO__c});
            }
        }
        return containersByShipmentOrderMap;
    }
    private List<InvoiceLineItem> groupDataByHBL(List<FORWARDING_VAT__c> lstVATHBL, List<INVOICING_VAT__c> lstVATHBLSB) {
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Integer index = 1;
        for (FORWARDING_VAT__c vatHBL : lstVATHBL) {
            String hblId = vatHBL.FORWARDING__c;
            InvoiceLineItem lineItem = new InvoiceLineItem();
            lineItem.index = index++;
            lineItem.quantity = 0;
            lineItem.unitPrice = 0;
            lineItem.totalAmount = 0;
            lineItem.productName = vatHBL.DESCRIPTION__c;
            lineItem.taxSellingAmount = 0;
            lineItem.taxSellingAdjustmentAmount = 0;
            lineItem.amountSellingIncludeTax = 0;
            lineItem.lineItemId = vatHBL.Id;

            for (INVOICING_VAT__c vatHBLSB : lstVATHBLSB) {
                if (hblId == vatHBLSB.INVOICING__r.Anken__c) {
                    /*
                     * Don't think below is needed as it is not correct???
                     */
                    lineItem.containerSize = vatHBLSB.INVOICING__r.Tariff__r.ContainerSize__c;
                    lineItem.curr = vatHBLSB.INVOICING__r.curr__c;
                    //lineItem.unit = vatHBLSB.INVOICING__r.Tariff__r.UNIT__c;
                    lineItem.unit = translateUnit(vatHBLSB);
                    lineItem.chargeUnitFormula = vatHBLSB.INVOICING__r.ChargeUnitFormula__c;
                    lineItem.taxCategory = vatHBLSB.INVOICING__r.ProductTax__c;
                    lineItem.quantity += Decimal.valueOf(vatHBLSB.INVOICING__r.wkSuryo__c);
                    lineItem.tax = String.valueOf((Integer)vatHBLSB.INVOICING__r.TaxInitial__c);
                    lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTankaUSD__c : vatHBLSB.INVOICING__r.SellTankaJPY__c);
                    lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellAmountUSD__c : vatHBLSB.INVOICING__r.SellAmountJPN__c);
                    lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTaxNum_USD__c : vatHBLSB.INVOICING__r.SellTaxNum__c);
                    lineItem.taxSellingAdjustmentAmount += (vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c);
                    lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY__c);
                    lineItem.amountSellingIncludeTaxNoRound += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY_NoRound__c);
                }
            }

            if(lineItem.quantity == 0 || ApexPages.currentPage().getUrl().contains('Combined')){
                lineItem.quantity = 1;
                lineItem.unitPrice = lineItem.totalAmount;
            }
            lineItems.add(lineItem);
        }
        return lineItems;
    }

    private List<InvoiceLineItem> groupDataByHBL(List<INVOICING_VAT__c> lstVATHBLSB) {
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Map<Id, InvoiceLineItem> lineItemMaps = new Map<Id, InvoiceLineItem>();
        Integer index = 1;
        for (INVOICING_VAT__c vatHBLSB : lstVATHBLSB) {

            InvoiceLineItem lineItem = new InvoiceLineItem();
            lineItem.index = index++;
            lineItem.quantity = 0;
            lineItem.unitPrice = 0;
            lineItem.totalAmount = 0;
            lineItem.productName = 'Forwarding Service Fee ' + vatHBLSB.INVOICING__r.Anken__r.Name;
            lineItem.taxSellingAmount = 0;
            lineItem.taxSellingAdjustmentAmount = 0;
            lineItem.amountSellingIncludeTax = 0;
            lineItem.lineItemId = vatHBLSB.INVOICING__r.Anken__c;

            if (lineItemMaps.containsKey(vatHBLSB.INVOICING__r.Anken__c)){
                lineItem = lineItemMaps.get(vatHBLSB.INVOICING__r.Anken__c);
            }

            lineItem.containerSize = vatHBLSB.INVOICING__r.Tariff__r.ContainerSize__c;
            lineItem.curr = vatHBLSB.INVOICING__r.curr__c;
            //lineItem.unit = vatHBLSB.INVOICING__r.Tariff__r.UNIT__c;
            lineItem.unit = translateUnit(vatHBLSB);
            lineItem.chargeUnitFormula = vatHBLSB.INVOICING__r.ChargeUnitFormula__c;
            lineItem.taxCategory = vatHBLSB.INVOICING__r.ProductTax__c;
            //lineItem.quantity += Decimal.valueOf(vatHBLSB.INVOICING__r.wkSuryo__c);
            lineItem.tax = String.valueOf((Integer)vatHBLSB.INVOICING__r.TaxInitial__c) ;
            //lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTankaUSD__c : vatHBLSB.INVOICING__r.SellTankaJPY__c);
            lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellAmountUSD__c : vatHBLSB.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTaxNum_USD__c : vatHBLSB.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount += (vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c);
            lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY__c);
            lineItem.amountSellingIncludeTaxNoRound += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY_NoRound__c);
            lineItem.quantity = 1;
            lineItem.unitPrice = lineItem.totalAmount;

            lineItemMaps.put(vatHBLSB.INVOICING__r.Anken__c, lineItem);
        }

        return lineItemMaps.values();
    }

    private List<InvoiceLineItem> groupDataByHBLSB(List<INVOICING_VAT__c> lstVATHBLSB) {
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Integer index = 1;

        for (INVOICING_VAT__c vatHBLSB : lstVATHBLSB) {
            InvoiceLineItem lineItem = new InvoiceLineItem();
            String description = vatHBLSB.INVOICING__r.InsatuyouSyohin__c;
            lineItem.index = index++;
            lineItem.lineItemId = vatHBLSB.Id;
            lineItem.productName = (StringUtils.isEmpty(description) ? '' : description.replaceAll('Surcharge Included', '').replaceAll('Surcharge Excluded', ''));
            lineItem.containerSize = vatHBLSB.INVOICING__r.Tariff__r.ContainerSize__c;
            lineItem.curr = vatHBLSB.INVOICING__r.curr__c;
            //lineItem.unit = vatHBLSB.INVOICING__r.Tariff__r.UNIT__c;
            lineItem.unit = translateUnit(vatHBLSB);
            lineItem.chargeUnitFormula = vatHBLSB.INVOICING__r.ChargeUnitFormula__c;
            lineItem.quantity = Decimal.valueOf(vatHBLSB.INVOICING__r.wkSuryo__c);
            lineItem.taxCategory = vatHBLSB.INVOICING__r.ProductTax__c;
            lineItem.tax = String.valueOf((Integer)vatHBLSB.INVOICING__r.TaxInitial__c);
            lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTankaUSD__c : vatHBLSB.INVOICING__r.SellTankaJPY__c);
            lineItem.totalAmount = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellAmountUSD__c : vatHBLSB.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTaxNum_USD__c : vatHBLSB.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount = vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c;
            lineItem.amountSellingIncludeTax = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY__c);
            lineItem.amountSellingIncludeTaxNoRound = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY_NoRound__c);
            if(lineItem.quantity == 0 || ApexPages.currentPage().getUrl().contains('Combined')){
                lineItem.quantity = 1;
                lineItem.unitPrice = lineItem.totalAmount;
            }

            lineItems.add(lineItem);

        }

        return lineItems;
    }

    private List<InvoiceLineItem> groupDataByPricingSubCategory(List<INVOICING_VAT__c> lstVATHBLSB) {
        Map<String, InvoiceLineItem> invoiceLineItemMap = new Map<String, VATInvoiceController.InvoiceLineItem>();
        String emptySubCatetory = '---';
        Integer index = 1;

        for (INVOICING_VAT__c vatHBLSB : lstVATHBLSB) {
            String pricingSubCategory = (StringUtils.isEmpty(vatHBLSB.INVOICING__r.Tariff__r.VATInvoiceAtPrintLocal__c) ? emptySubCatetory : vatHBLSB.INVOICING__r.Tariff__r.VATInvoiceAtPrintLocal__c);
            InvoiceLineItem lineItem = invoiceLineItemMap.get(pricingSubCategory);

            if (lineItem == null) {
                lineItem = new InvoiceLineItem();
                lineItem.index = index++;
                lineItem.lineItemId = vatHBLSB.Id;
                lineItem.productName = vatHBLSB.INVOICING__r.Tariff__r.VATInvoiceAtPrintLocal__c;
//                lineItem.productName = vatHBLSB.INVOICING__r.InsatuyouSyohin__c;
                lineItem.containerSize = vatHBLSB.INVOICING__r.Tariff__r.ContainerSize__c;
                lineItem.curr = vatHBLSB.INVOICING__r.curr__c;
               // lineItem.unit = vatHBLSB.INVOICING__r.Tariff__r.UNIT__c;
               	lineItem.unit = translateUnit(vatHBLSB);
                lineItem.chargeUnitFormula = vatHBLSB.INVOICING__r.ChargeUnitFormula__c;
                lineItem.taxCategory = vatHBLSB.INVOICING__r.ProductTax__c;
                lineItem.tax = String.valueOf((Integer)vatHBLSB.INVOICING__r.TaxInitial__c);
                lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTankaUSD__c : vatHBLSB.INVOICING__r.SellTankaJPY__c);
                lineItem.quantity = 0;
                lineItem.totalAmount = 0;
                lineItem.taxSellingAmount = 0;
                lineItem.taxSellingAdjustmentAmount = 0;
                lineItem.amountSellingIncludeTax = 0;
                invoiceLineItemMap.put(pricingSubCategory, lineItem);
            }

            lineItem.quantity += Decimal.valueOf(vatHBLSB.INVOICING__r.wkSuryo__c);
            lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellAmountUSD__c : vatHBLSB.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTaxNum_USD__c : vatHBLSB.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount += (vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c != null ? vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c : 0);
            lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY__c);
            lineItem.amountSellingIncludeTaxNoRound += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY_NoRound__c);
            if(lineItem.quantity == 0 || ApexPages.currentPage().getUrl().contains('Combined')){
                lineItem.quantity = 1;
                lineItem.unitPrice = lineItem.totalAmount;
            }
            invoiceLineItemMap.put(pricingSubCategory, lineItem);
        }

        return invoiceLineItemMap.values();
    }

    private List<InvoiceLineItem> groupAllData(List<INVOICING_VAT__c> lstVATHBLSB) {
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        InvoiceLineItem lineItem = new InvoiceLineItem();
        lineItem.index = 1;
        lineItem.quantity = 0;
        lineItem.totalAmount = 0;
        lineItem.unitPrice = 0;
        lineItem.taxSellingAmount = 0;
        lineItem.taxSellingAdjustmentAmount = 0;
        lineItem.amountSellingIncludeTax = 0;
        lineItem.productName = vatInvoice.DESCRIPTION_FOR_COMBINE__c;

        for (INVOICING_VAT__c vatHBLSB : lstVATHBLSB) {
            /*
             * Don't think below is needed as it is not correct???
             */

            lineItem.lineItemId = vatHBLSB.Id;
            lineItem.containerSize = vatHBLSB.INVOICING__r.Tariff__r.ContainerSize__c;
            lineItem.curr = vatHBLSB.INVOICING__r.curr__c;
            //lineItem.unit = vatHBLSB.INVOICING__r.Tariff__r.UNIT__c;
            lineItem.unit = translateUnit(vatHBLSB);
            lineItem.chargeUnitFormula = vatHBLSB.INVOICING__r.ChargeUnitFormula__c;
            lineItem.tax = String.valueOf((Integer)vatHBLSB.INVOICING__r.TaxInitial__c);
            lineItem.quantity += Decimal.valueOf(vatHBLSB.INVOICING__r.wkSuryo__c);
            lineItem.taxCategory = vatHBLSB.INVOICING__r.ProductTax__c;
            lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTankaUSD__c : vatHBLSB.INVOICING__r.SellTankaJPY__c);
            lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellAmountUSD__c : vatHBLSB.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellTaxNum_USD__c : vatHBLSB.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount += (vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : vatHBLSB.INVOICING__r.TAX_ADJUSTMENTSELL__c);
            lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY__c);
            lineItem.amountSellingIncludeTaxNoRound += (Constants.CURRENCY_USD.equalsIgnoreCase(reportingCurrency) ? vatHBLSB.INVOICING__r.SellInTaxAmount_USD__c : vatHBLSB.INVOICING__r.SellInTaxAmountJPY_NoRound__c);
        }
        if(lineItem.quantity == 0 || ApexPages.currentPage().getUrl().contains('Combined')){
            lineItem.quantity = 1;
            lineItem.unitPrice = lineItem.totalAmount;
        }
        lineItems.add(lineItem);
        return lineItems;
    }

    private List<FORWARDING_VAT__c> enquiryHBL(String vatInvoiceId) {
        final String query = 'SELECT ' + String.join(forwardingFields, ',') + ' FROM FORWARDING_VAT__c WHERE VAT_INVOICE__r.Id = \'' + StringUtils.escapeSingleQuotes(vatInvoiceId) + '\'';
        List<FORWARDING_VAT__c> lstVATHBL = Database.query(query);

        return lstVATHBL;
    }

    private List<INVOICING_VAT__c> enquiryHBLSB(String vatInvoiceId) {
        final String query = 'SELECT ' + String.join(invoicingFields, ',')
                + ' FROM INVOICING_VAT__c WHERE VAT_INVOICE__r.Id = \'' + StringUtils.escapeSingleQuotes(vatInvoiceId)
                + '\' ORDER BY INVOICING__r.Tariff__r.EngSubcategory__c DESC, INVOICING__r.InsatuyouSyohin__c DESC';
        List<INVOICING_VAT__c> lstVATHBLSB = Database.query(query);

        return lstVATHBLSB;
    }

    private void readParameters() {
        vatInvoiceId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));
        groupingOption = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_GROUPTING_OPTION));
        templateSet = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_INVOICE_TEMPLATE_SET));
        reportingCurrency = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CURRENCY));
    }
    private String translateUnit(INVOICING_VAT__c invoicingVAT){
        String unit = invoicingVAT.INVOICING__r.ChargeUnitFormula__c;
        if(invoicingVAT.INVOICING__r.ChargeUnitFormula__c =='本'){
                unit = 'Unit';
            } 
        if(invoicingVAT.INVOICING__r.ChargeUnitFormula__c =='コンテナ' || invoicingVAT.INVOICING__r.ChargeUnitFormula__c =='Container'){
            unit = invoicingVAT.INVOICING__r.ContainerSizeFormula__c;
            if(String.isBlank(unit)){
                unit = 'Container';
            }
        }
        if(invoicingVAT.INVOICING__r.ChargeUnitFormula__c =='件'){
            unit = 'Case';
        }
        return unit;
    }

    global class InvoiceReportWrapper {
        global String invoiceNo { get; set; }
        global String invoiceTo { get; set; }
        global String invoiceToENG { get; set; }
        global String address { get; private set; }
        global String addressENG { get; private set; }
        global String clientName { get; set; }
        global String issuedBy { get; set; }
        global Date issuedDate { get; set; }
        global String termsOfPayment { get; set; }
        global String remarks { get; set; }
        global String tax { get; set; }
        global Decimal totalAmount { get; set; }
        global Decimal totalTaxSellingAdjustmentAmount { get; set; }
        global String taxCode { get; set; }
        global List<InvoiceLineItem> invoiceLineItems { get; set; }
        global String WKIDs { get; set; }
        global String bankAccounts { get; private set; }
        global String customerBankAccount { get; private set; }
        global String NumberSeaAir { get; set; }
        global String creditTerm { get; set; }
        global Date etd { get; set; }
        global Date eta { get; set; }
        global String shipper { get; set; }
        global String consignee { get; set; }
        global String projectJob { get; set; }
        global Date serviceDate { get; set; }
        global String container { get; set; }
        global String container2 { get; set; }
        global String container3 { get; set; }
        global String container4 { get; set; }
        global Decimal containerNumber { get; set; }
        global Decimal containerNumber2 { get; set; }
        global Decimal containerNumber3 { get; set; }
        global Decimal containerNumber4 { get; set; }
        global String pol { get; set; }
        global String pod { get; set; }
        global String mblNumberSeaAir { get; set; }
        global String hblNumberSeaAir { get; set; }
        global String customerPhoneNumber { get; set; }

        public InvoiceReportWrapper() {
            invoiceLineItems = new List<InvoiceLineItem>();
            //tax = ;
            totalAmount = 0;
            totalTaxSellingAdjustmentAmount = 0;
        }

        public Decimal getTotalAmoutIncludedTax() {
                return (totalAmount + getTaxAmount());
        }

        public Decimal getTaxAmount() {

            Decimal taxAmount = 0;
            /*if (tax != null && invoiceLineItems != null && !invoiceLineItems.isEmpty()) {
                for (InvoiceLineItem lineItem : invoiceLineItems) {
                    if (lineItem.totalAmount != null) {
                        Decimal lineItemTaxAmount = (Decimal) (tax * lineItem.totalAmount / 100);

                        if (lineItem.taxSellingAdjustmentAmount != null) {
                            lineItemTaxAmount += lineItem.taxSellingAdjustmentAmount;
                        }
                        taxAmount += lineItemTaxAmount;
                    }
                }
            }
            //return (tax > 0 ? (tax * totalAmount) / 100 : 0) + totalTaxSellingAdjustmentAmount;*/
            for(InvoiceLineItem lineItem : invoiceLineItems){
                taxAmount += lineItem.amountSellingIncludeTaxNoRound - lineItem.totalAmount;
            }
            return taxAmount;
        }

        public String getTotalAmountText() {
            return NumbericUtils.convertNumberToText(getTotalAmoutIncludedTax().round(System.RoundingMode.HALF_UP), VATInvoiceController.reportingCurrency);
        }

        public void setInvoiceToAddress(String street, String city, String state, String country) {
            address = (StringUtils.isEmpty(street) ? '' : street) +
                    (StringUtils.isEmpty(city) ? '' : ', ' + city) +
                    (StringUtils.isEmpty(state) ? '' : ', ' + state) +
                    (StringUtils.isEmpty(country) ? '' : ', ' + country);
        }

        public void setBankAccounts(String bank1, String bank2) {
            bankAccounts = '';

            if (!StringUtils.isEmpty(bank1) && !StringUtils.isEmpty(bank2)) {
                bankAccounts = bank1 + '/' + bank2;
            } else if (!StringUtils.isEmpty(bank1)) {
                bankAccounts = bank1;
            } else if (!StringUtils.isEmpty(bank2)) {
                bankAccounts = bank2;
            }
        }

        public List<String> getTaxCodeInCharacters() {
            List<String> characters = new List<String>();
            if (!StringUtils.isEmpty(taxCode)) {
                for (Integer i = 0; i < taxCode.length(); i++) {
                    characters.add(taxCode.substring(i, i + 1));
                }
            }

            return characters;
        }
    }

    global class InvoiceLineItem {
        global String lineItemId {get; set;}
        global Decimal index { get; set; }
        global String productName { get; set; }
        global String unit { get; set; }
        global String chargeUnitFormula{get;set;}
        global Decimal quantity { get; set; }
        global String curr { get; set; }
        global String containerSize { get; set; }
        global String tax { get; set; }
        global String taxCategory { get; set; }
        global Decimal unitPrice { get; set; }
        global Decimal totalAmount { get; set; }
        global Decimal taxSellingAmount { get; set; }
        global Decimal taxSellingAdjustmentAmount { get; set; }
        //Nga Do - 2018/09/04 - AFR-14- Add 3 New Data into Draft VAT Invoice - Start
        global Decimal amountSellingIncludeTax { get; set; }
        global Decimal amountSellingIncludeTaxNoRound { get; set; }
        //Nga Do - 2018/09/04 - AFR-14- Add 3 New Data into Draft VAT Invoice - End
        //
        global InvoiceLineItem() {
            amountSellingIncludeTaxNoRound = 0;
        }
    }
}