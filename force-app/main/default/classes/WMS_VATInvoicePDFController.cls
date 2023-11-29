public with sharing class WMS_VATInvoicePDFController {
    public String templateSet { get; set; }
    public InvoiceReportWrapper wrapper { get; set; }
    public Map<String, String> translations { get; set;}
    public VAT_INVOICE__c currentVat{get; set;}
    public static String currencyType{get; set;}
    public  String language{get; set;}
    public Boolean isDraftVersion{get; set;}
    public String invoiceDebitType{get; set;}
    public String invoiceDebitHeader{get; set;}
    private List<Billing__c> listBillingWMS;
    private List<AnkenMeisai__c> listBillingFMS;
    private List<ConnectBillingVAT__c> listLinkBillingWMS;
    private List<INVOICING_VAT__c> listLinkBillingFMS;
    private Set<String> shipmentOrderSet;
    private static List<String> vatFields = new List<String>();
    private static List<String> forwardingFields = new List<String>();
    private static List<String> invoicingFields = new List<String>();
    private static List<String> billingFields = new List<String>();
    private static List<String> workorderFields = new List<String>();
    private static List<String> containerFields = new List<String>();

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

        invoicingFields.add('INVOICING__c');
        invoicingFields.add('INVOICING__r.Name');
        invoicingFields.add('INVOICING__r.InsatuyouSyohin__c');
        invoicingFields.add('INVOICING__r.InsatuyouSyohinENG__c');   
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
        invoicingFields.add('INVOICING__r.SellInTaxAmount_USD__c');
        invoicingFields.add('INVOICING__r.ProductTax__c');
        invoicingFields.add('INVOICING__r.TAX_ADJUSTMENTSELL__c');
        invoicingFields.add('INVOICING__r.Tariff__r.EngSubcategory__c');
        invoicingFields.add('INVOICING__r.Tariff__r.VATInvoiceAtPrintLocal__c');
        invoicingFields.add('INVOICING__r.Tariff__r.VATInvoiceAtPrintENG__c');
        invoicingFields.add('INVOICING__r.Tariff__r.Name');
        invoicingFields.add('INVOICING__r.Tariff__r.TAX__c');

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

        //Billing WMS Fields
        billingFields.add('Id');
        billingFields.add('BillingID__c');
       
        //billingFields.add('BillingID__r.WorkOrderID__c');
        ////////
        billingFields.add('BillingID__r.PricingNameAtPrintLocal__c');
        billingFields.add('BillingID__r.PricingNameAtPrintENG__c');
        billingFields.add('BillingID__r.PricingName__c');
        billingFields.add('BillingID__r.PricingName__r.ContainerSize__c');
        billingFields.add('BillingID__r.PricingName__r.VATInvoiceAtPrintLocal__c');
        billingFields.add('BillingID__r.PricingName__r.VATInvoiceAtPrintENG__c');
        billingFields.add('BillingID__r.PricingName__r.Name');
        billingFields.add('BillingID__r.PricingName__r.UNIT__c');
        billingFields.add('BillingID__r.ChargeUnitinPrint__c');
        billingFields.add('BillingID__r.ChargeUnitFormula__c');
        billingFields.add('BillingID__r.ContainerrSizeFormula__c');
        billingFields.add('BillingID__r.PricingName__r.TAX__c');
        billingFields.add('BillingID__r.Unit__c');
        billingFields.add('BillingID__r.ChargeUnitTotal__c');
        billingFields.add('BillingID__r.TAX__c');
        billingFields.add('BillingID__r.TaxRatioSelling__c');
        billingFields.add('BillingID__r.UnitPriceOfSellingUSD__c');
        billingFields.add('BillingID__r.UnitPriceOfSellingLocal__c');
        billingFields.add('BillingID__r.TotalAmountOfSellingUSD__c');
        billingFields.add('BillingID__r.TotalAmountOfSellingLocal__c');
        billingFields.add('BillingID__r.AmountOfTaxSellingUSD__c');
        billingFields.add('BillingID__r.AmountOfTaxSelling__c');
        billingFields.add('BillingID__r.AmountSellingIncludeTAXUSD__c');
        billingFields.add('BillingID__r.AmountSellingIncludeTAX__c');
        billingFields.add('BillingID__r.WorkOrderID__c');
        billingFields.add('BillingID__r.WorkOrderID__r.Name');

        //Workorder Fields
        workorderFields.add('Id');
        
    }
    public WMS_VATInvoicePDFController() {
        wrapper = new InvoiceReportWrapper();
        isDraftVersion = true;
        // get parameters
        String invoiceId = ApexPages.currentPage().getParameters().get('invoiceId');
        String invoiceType = ApexPages.currentPage().getParameters().get('invoiceType');
        String groupingType = ApexPages.currentPage().getParameters().get('groupingType');
        currencyType = ApexPages.currentPage().getParameters().get('currencyType');
        language = ApexPages.currentPage().getParameters().get('language');
        if(!invoiceType.contains('DRAFT')){
            isDraftVersion = false;
        }

        invoiceDebitType = 'DEBIT_LOCAL';
        
        if(currencyType == 'USD'){
            invoiceDebitType = 'DEBIT_USD';
        }
        translations = getTranslationMap(language);
        invoiceDebitHeader = translations.get(invoiceDebitType).substringBefore('(');
        listLinkBillingWMS = new List<ConnectBillingVAT__c>();
        listLinkBillingFMS = new List<INVOICING_VAT__c>();

        listLinkBillingWMS = getListLinkBillingWMS(invoiceId);
        listLinkBillingFMS = getListLinkBillingFMS(invoiceId);
        List<InvoiceLineItem> listInvoiceLineItems = new List<InvoiceLineItem>();
        currentVat = getVATInvoice(invoiceId);

        if(groupingType == 'GROUPED_BY_WORKORDER'){
            listInvoiceLineItems = getInvoicebyWorkOrder(listLinkBillingWMS);
        }
        if(groupingType == 'GROUPED_BY_FORWARDING'){
            listInvoiceLineItems = getInvoicebyShipmentOrder(listLinkBillingFMS);
        }
        if(groupingType == 'GROUPED_BY_SO_WO'){
            listInvoiceLineItems.addAll(getInvoicebyWorkOrder(listLinkBillingWMS));
            listInvoiceLineItems.addAll(getInvoicebyShipmentOrder(listLinkBillingFMS));
        }
        if(groupingType == 'GROUP_BY_CATEGORY'){

            List<InvoiceLineItem> lineItems_WMS = getInvoicesbyPricingNameWMS(listLinkBillingWMS);
            List<InvoiceLineItem> lineItems_FMS = getInvoicesbyPricingNameFMS(listLinkBillingFMS);
            if(currentVat.RecordType.DeveloperName == 'CloWMSVATInvoice'){
                listInvoiceLineItems = lineItems_WMS;
            }
            if(currentVat.RecordType.DeveloperName == 'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY'){
                listInvoiceLineItems = lineItems_FMS;
            }
            if(currentVat.RecordType.DeveloperName == 'FMSTMSWMSVATInvoice'){
                Map<String, InvoiceLineItem> mapInvoiceLineItem = new Map<String, InvoiceLineItem>();
                List<InvoiceLineItem> lineItems_FMS_WMS = new List<InvoiceLineItem>();
                lineItems_FMS_WMS.addAll(lineItems_WMS);
                lineItems_FMS_WMS.addAll(lineItems_FMS);
                for(InvoiceLineItem item : lineItems_FMS_WMS){
                    if(mapInvoiceLineItem.containsKey(item.productName)){
                        InvoiceLineItem itemExist = mapInvoiceLineItem.get(item.productName);
                        itemExist.totalAmount += item.totalAmount;
                        itemExist.taxSellingAmount += item.taxSellingAmount;
                        if(itemExist.taxSellingAdjustmentAmount == null){
                            itemExist.taxSellingAdjustmentAmount = 0;
                        }
                        itemExist.taxSellingAdjustmentAmount += item.taxSellingAdjustmentAmount != null? item.taxSellingAdjustmentAmount : 0;
                        itemExist.amountSellingIncludeTax += item.amountSellingIncludeTax;
                        List<String> taxExist = itemExist.tax.split('/ ');
                        taxExist.addAll(item.tax.split('/ '));
                        Set<String> taxSet = new Set<String>(taxExist);
                        itemExist.tax = String.join(new List<String>(taxSet),'/ ');
                    }else{
                        mapInvoiceLineItem.put(item.productName, item);
                    }
                }
                listInvoiceLineItems = mapInvoiceLineItem.values();
            }
            
        }
        if(groupingType == 'GROUP_SUMMARY'){
            if(currentVat.RecordType.DeveloperName == 'CloWMSVATInvoice'){
                listInvoiceLineItems.add(getInvoicesToOneWMS(listLinkBillingWMS));
            }
            if(currentVat.RecordType.DeveloperName == 'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY'){
                listInvoiceLineItems.add(getInvoicesToOneFMS(listLinkBillingFMS));
            }
            if(currentVat.RecordType.DeveloperName == 'FMSTMSWMSVATInvoice'){
                listInvoiceLineItems.add(getInvoicesToOneWMS(listLinkBillingWMS));
                listInvoiceLineItems.add(getInvoicesToOneFMS(listLinkBillingFMS));
            }
        }
        if(groupingType == 'SINGLE_INVOICE'){
            if(currentVat.RecordType.DeveloperName == 'CloWMSVATInvoice'){
                listInvoiceLineItems = getInvoiceLineItemsSingleWMS(listLinkBillingWMS);
            }
            if(currentVat.RecordType.DeveloperName == 'MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY'){
                listInvoiceLineItems = getInvoiceLineItemsSingleFMS(listLinkBillingFMS);
            }
            if(currentVat.RecordType.DeveloperName == 'FMSTMSWMSVATInvoice'){
                listInvoiceLineItems.addAll(getInvoiceLineItemsSingleWMS(listLinkBillingWMS));
                listInvoiceLineItems.addAll(getInvoiceLineItemsSingleFMS(listLinkBillingFMS));
            }
        }
        
        // initial report wrapper
        wrapper.language = language;
        wrapper.invoiceNo = currentVat.RED_INVOICE_NO__c;
        wrapper.invoiceTo = currentVat.VAT_INVOICE_TO__r.Name;
        wrapper.invoiceToENG = currentVat.VAT_INVOICE_TO__r.EnglishCompanyName__c;
        wrapper.addressENG = currentVat.VAT_INVOICE_TO__r.EnglishAddress__c;
        wrapper.clientName = currentVat.CLIENTS_NAME_IN_VAT_INVOICE__r.Name;
        wrapper.issuedBy = currentVat.VAT_INVOICE_ISSUED_BY__r.Name;
        wrapper.issuedDate = currentVat.VATInvoicePrintDate__c;
        wrapper.termsOfPayment = currentVat.TERMS_OF_PAYMENT__c;
        String remark = currentVat.VAT_INVOICE_REMARKS__c;
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
        

        wrapper.taxCode = currentVat.TAX_CODE__c;
        wrapper.setBankAccounts(currentVat.LOCAL_BANK_ACCOUNT_NUMBER_1__c, currentVat.LOCAL_BANK_ACCOUNT_NUMBER_2__c);
        wrapper.setInvoiceToAddress(currentVat.VAT_INVOICE_TO__r.BillingStreet, currentVat.VAT_INVOICE_TO__r.BillingCity,
                currentVat.VAT_INVOICE_TO__r.BillingState, currentVat.VAT_INVOICE_TO__r.BillingCountry);
        wrapper.customerBankAccount = currentVat.CUSTOMER_BANK_ACCOUNT_NUMBER__c;
        wrapper.creditTerm = currentVat.CREDIT_TERM__c;
        wrapper.customerPhoneNumber = currentVat.CUSTOMER_PHONE_NUMBER__c;
        wrapper.invoiceLineItems = listInvoiceLineItems;
        Set<String> taxSet = new Set<String>();
        shipmentOrderSet = new Set<String>();
        Set<String> setWorkOrderId = new Set<String>();
        wrapper.totalAmount = 0; 
        wrapper.totalTaxSellingAdjustmentAmount= 0;
        wrapper.amountSellingIncludeTax = 0;
        for (InvoiceLineItem li : listInvoiceLineItems) {
            wrapper.totalAmount += li.totalAmount == null ? 0 : li.totalAmount;
            wrapper.totalTaxSellingAdjustmentAmount += (li.taxSellingAdjustmentAmount == null ? 0 : li.taxSellingAdjustmentAmount);
            wrapper.amountSellingIncludeTax += (li.amountSellingIncludeTax == null ? 0 : li.amountSellingIncludeTax);
            if (li.tax != null) {
               taxSet.add(li.tax);
            }
            if(!li.workOrderIds.isEmpty()){
                setWorkOrderId.addAll(li.workOrderIds);
            }

             if(!li.shipmentOrderIds.isEmpty()){
                shipmentOrderSet.addAll(li.shipmentOrderIds);
            }
        }
        List<String> taxList = new List<String>(taxSet);
        wrapper.tax = String.join(taxList, '/ ');

        // get list shipmentOrder
        List<CustomObject1__c> shipmentOrders =  new List<CustomObject1__c>();
        if(!shipmentOrderSet.isEmpty()){
            shipmentOrders = getShipmentOrderList(shipmentOrderSet);
        }
        
        List<String> wkids = new List<String>();
        List<String> numberSeaAir = new List<String>();
        Map<Id, List<String>> containersByShipmentOrderMap = getContainerDetailByShipment();
        for(CustomObject1__c shipment : shipmentOrders){

            String identificationTemp = '';
            if(currentVat.ShipmentOrderIdentification__c != null){
                if(currentVat.ShipmentOrderIdentification__c.contains(HBL_NO_INDENTIFICATION)
                && shipment.HBL_Number_SEA_AIR__c != null){
                identificationTemp += shipment.HBL_Number_SEA_AIR__c;
                }
                if(currentVat.ShipmentOrderIdentification__c.contains(MBL_NO_INDENTIFICATION)
                    && shipment.MBL_Number_SEA_AIR__c != null){
                    identificationTemp += String.isBlank(identificationTemp) ? shipment.MBL_Number_SEA_AIR__c : ': ' + shipment.MBL_Number_SEA_AIR__c;
                }
                if(currentVat.ShipmentOrderIdentification__c.contains(CONTAINER_INDENTIFICATION)
                    && containersByShipmentOrderMap.containsKey(shipment.Id)){
                    String containerDetailStr = String.join(containersByShipmentOrderMap.get(shipment.Id), ', ');
                    identificationTemp += String.isBlank(identificationTemp) ? containerDetailStr : ': ' + containerDetailStr;
                }
                if(currentVat.ShipmentOrderIdentification__c.contains(SHIPMENT_ORDER_INDENTIFICATION)
                    && shipment.ID__c != null){

                    String shipmentName = 'S' + shipment.WkInitial__c + shipment.Name;
                    identificationTemp += String.isBlank(identificationTemp) ? shipmentName : ': ' + shipmentName;
                }
            }
            if(!String.isBlank(identificationTemp)){
                wkids.add(identificationTemp);
            }
            numberSeaAir.add(StringUtils.isEmpty(shipment.HBL_Number_SEA_AIR__c) ? '' : (shipment.HBL_Number_SEA_AIR__c));
        }
         if((currentVat.ShipmentOrderIdentification__c != null 
                    && currentVat.ShipmentOrderIdentification__c.contains(MANUAL_INPUT_INDENTIFICATION))
                    || currentVat.ShipmentOrderIdentification__c == null ){
                    wrapper.WKIDs = currentVat.ShipmentOrderIdentificationDetail__c;
                    // wrapper.WKIDs = new List<String>{currentVat.ShipmentOrderIdentificationDetail__c};
        }
        else{
            wrapper.WKIDs = String.join(wkids, '/ ');
            //wrapper.WKIDs = wkids;
           
        }
        wrapper.NumberSeaAir = String.join(numberSeaAir, ' / ');
        

    }
    private List<CustomObject1__c> getShipmentOrderList(Set<String> shipmentOrderIds){

        List<CustomObject1__c> shipmentOrders = [SELECT Id, Name, HBL_Number_SEA_AIR__c,
                                        MBL_Number_SEA_AIR__c
                                        FROM CustomObject1__c WHERE Id IN: shipmentOrderIds];
        return shipmentOrders;
    }

     private Map<Id, List<String>> getContainerDetailByShipment(){

        String strQuery = 'SELECT ' + String.join(containerFields, ',') + ' FROM Container_Info__c WHERE HBL_SHIPMENT__c IN: shipmentOrderSet';
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

    private VAT_INVOICE__c getVATInvoice(String invoiceId){
        String strQuery = 'SELECT ' + String.join(vatFields, ',') + ' FROM VAT_INVOICE__c WHERE Id = \'' + String.escapeSingleQuotes(invoiceId) + '\'';
        List<VAT_INVOICE__c> listVat = Database.query(strQuery);
        VAT_INVOICE__c vat = new VAT_INVOICE__c();
        if(!listVat.isEmpty()){
            vat = listVat[0];
        }
        return vat;
    }

    private List<ConnectBillingVAT__c> getListLinkBillingWMS(String invoiceId){
        String strQuery = 'SELECT ' + String.join(billingFields, ',') + ' FROM ConnectBillingVAT__c WHERE VATInvoiceID__c = \'' + String.escapeSingleQuotes(invoiceId) + '\'';
        List<ConnectBillingVAT__c> listLinks = Database.query(strQuery);
        return listLinks;
    }

    private List<INVOICING_VAT__c> getListLinkBillingFMS(String invoiceId){
        String strQuery = 'SELECT ' + String.join(invoicingFields, ',') + ' FROM INVOICING_VAT__c WHERE VAT_INVOICE__c = \'' + String.escapeSingleQuotes(invoiceId) + '\'';
        List<INVOICING_VAT__c> listLinks = Database.query(strQuery);
        return listLinks;
    }
    private List<InvoiceLineItem> getInvoicebyShipmentOrder(List<INVOICING_VAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Map<Id, InvoiceLineItem> lineItemMaps = new Map<Id, InvoiceLineItem>();
        Integer index = 1;
        for (INVOICING_VAT__c link : listLink) {

            InvoiceLineItem lineItem = new InvoiceLineItem();
            lineItem.index = index++;
            lineItem.quantity = 0;
            lineItem.unitPrice = 0;
            lineItem.totalAmount = 0;
            lineItem.productName = 'Forwarding Service Fee ' + link.INVOICING__r.Anken__r.Name;
            lineItem.taxSellingAmount = 0;
            lineItem.taxSellingAdjustmentAmount = 0;
            lineItem.amountSellingIncludeTax = 0;
            lineItem.lineItemId = link.INVOICING__r.Anken__c;

            if (lineItemMaps.containsKey(link.INVOICING__r.Anken__c)){
                lineItem = lineItemMaps.get(link.INVOICING__r.Anken__c);
            }
            
            lineItem.containerSize = link.INVOICING__r.Tariff__r.ContainerSize__c;
            lineItem.curr = currencyType;
            lineItem.unit = translateUnit(link);
            lineItem.chargeUnitFormula = link.INVOICING__r.ChargeUnitFormula__c;
            lineItem.billType = 'FMS';
            lineItem.taxCategory = link.INVOICING__r.ProductTax__c;
            lineItem.tax = String.valueOf((Integer)link.INVOICING__r.TaxInitial__c);
            lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTankaUSD__c : link.INVOICING__r.SellTankaJPY__c);
            lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellAmountUSD__c : link.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTaxNum_USD__c : link.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount += (link.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : link.INVOICING__r.TAX_ADJUSTMENTSELL__c);
            lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellInTaxAmount_USD__c : link.INVOICING__r.SellInTaxAmountJPY__c);
            lineItem.quantity = 1;
            lineItem.unitPrice = lineItem.totalAmount;
            lineItem.shipmentOrderIds.add(link.INVOICING__r.Anken__c);
            lineItemMaps.put(link.INVOICING__r.Anken__c, lineItem);
        }

        return lineItemMaps.values();
    }

    private List<InvoiceLineItem> getInvoicebyWorkOrder(List<ConnectBillingVAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Map<String,InvoiceLineItem> lineItemWOMap = new Map<String,InvoiceLineItem>();
        Integer index = 1;
        for(ConnectBillingVAT__c link : listLink){
            InvoiceLineItem lineItem;
            Decimal totalAmountUSD = link.BillingID__r.TotalAmountOfSellingUSD__c == null? 0 : link.BillingID__r.TotalAmountOfSellingUSD__c;
            Decimal taxSellingAmountUSD = link.BillingID__r.AmountOfTaxSellingUSD__c == null? 0 : link.BillingID__r.AmountOfTaxSellingUSD__c;
            Decimal amountSellingIncludeTaxUSD = link.BillingID__r.AmountSellingIncludeTAXUSD__c == null? 0 : link.BillingID__r.AmountSellingIncludeTAXUSD__c;
            Decimal totalAmountLocal = link.BillingID__r.TotalAmountOfSellingLocal__c == null? 0 : link.BillingID__r.TotalAmountOfSellingLocal__c;
            Decimal taxSellingAmountLocal = link.BillingID__r.AmountOfTaxSelling__c == null? 0 : link.BillingID__r.AmountOfTaxSelling__c;
            Decimal amountSellingIncludeTaxLocal = link.BillingID__r.AmountSellingIncludeTAX__c == null? 0 : link.BillingID__r.AmountSellingIncludeTAX__c;
            if(lineItemWOMap.containsKey(link.BillingID__r.WorkOrderID__c)){
                lineItem = lineItemWOMap.get(link.BillingID__r.WorkOrderID__c);
                if( link.BillingID__r.TaxRatioSelling__c != null
                    && lineItem.tax != String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c)){
                    lineItem.tax += '/ ' + String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c);
                }
                lineItem.totalAmount +=  Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? totalAmountUSD : totalAmountLocal;
                lineItem.taxSellingAmount += Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? taxSellingAmountUSD : taxSellingAmountLocal;
                lineItem.amountSellingIncludeTax += Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? amountSellingIncludeTaxUSD : amountSellingIncludeTaxLocal;
            
            }else{
                lineItem = new InvoiceLineItem();
                lineItem.index = index++;
                lineItem.lineItemId = link.BillingID__r.WorkOrderID__c;
                // NEED TO REVIEW.
                //lineItem.containerSize = link.BillingID__r.PricingName__c != null? link.BillingID__r.PricingName__r.ContainerSize__c : null;

                lineItem.curr = currencyType;
                lineItem.productName = 'Warehouse Service Fee' + '-' +link.BillingID__r.WorkOrderID__r.Name;
                lineItem.quantity = 1;
                lineItem.tax = String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c);
                lineItem.totalAmount =  Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? totalAmountUSD : totalAmountLocal;
                lineItem.taxSellingAmount = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? taxSellingAmountUSD : taxSellingAmountLocal;
                lineItem.amountSellingIncludeTax = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? amountSellingIncludeTaxUSD : amountSellingIncludeTaxLocal;
            }
            lineItem.workOrderIds.add(link.BillingID__r.WorkOrderID__c);
            lineItem.unitPrice = lineItem.totalAmount;

            lineItemWOMap.put(link.BillingID__r.WorkOrderID__c,lineItem);
        }

        return lineItemWOMap.values();
    }

    private List<InvoiceLineItem> getInvoicesbyPricingNameWMS(List<ConnectBillingVAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Map<String,InvoiceLineItem> lineItemByPricingMap = new Map<String,InvoiceLineItem>();
        Integer index = 1; 
        for(ConnectBillingVAT__c link : listLink){
            InvoiceLineItem lineItem;
            String pricingName = '';
            if(link.BillingID__r.PricingName__c != null){
                pricingName = language != 'vi'? link.BillingID__r.PricingName__r.VATInvoiceAtPrintENG__c : link.BillingID__r.PricingName__r.VATInvoiceAtPrintLocal__c;
                
                if(String.isBlank(pricingName)){
                    pricingName = link.BillingID__r.PricingName__r.Name;
                }
            }else{
                pricingName ='Non-Pricing';
            }
            Decimal totalAmountUSD = link.BillingID__r.TotalAmountOfSellingUSD__c == null? 0 : link.BillingID__r.TotalAmountOfSellingUSD__c;
            Decimal taxSellingAmountUSD = link.BillingID__r.AmountOfTaxSellingUSD__c == null? 0 : link.BillingID__r.AmountOfTaxSellingUSD__c;
            Decimal amountSellingIncludeTaxUSD = link.BillingID__r.AmountSellingIncludeTAXUSD__c == null? 0 : link.BillingID__r.AmountSellingIncludeTAXUSD__c;
            Decimal totalAmountLocal = link.BillingID__r.TotalAmountOfSellingLocal__c == null? 0 : link.BillingID__r.TotalAmountOfSellingLocal__c;
            Decimal taxSellingAmountLocal = link.BillingID__r.AmountOfTaxSelling__c == null? 0 : link.BillingID__r.AmountOfTaxSelling__c;
            Decimal amountSellingIncludeTaxLocal = link.BillingID__r.AmountSellingIncludeTAX__c == null? 0 : link.BillingID__r.AmountSellingIncludeTAX__c;
            if(lineItemByPricingMap.containsKey(pricingName)){
                lineItem = lineItemByPricingMap.get(pricingName);

                lineItem.taxCategory = language == 'vi' && link.BillingID__r.PricingName__c != null? link.BillingID__r.PricingName__r.TAX__c: '';
                
                if( link.BillingID__r.TaxRatioSelling__c != null
                    && lineItem.tax != String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c)){
                    lineItem.tax += '/ ' + String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c);
                }
                lineItem.totalAmount +=  Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? totalAmountUSD : totalAmountLocal;
                lineItem.taxSellingAmount += Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? taxSellingAmountUSD : taxSellingAmountLocal;
                lineItem.amountSellingIncludeTax += Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? amountSellingIncludeTaxUSD : amountSellingIncludeTaxLocal;
            }else{
                lineItem = new InvoiceLineItem();
                lineItem.index = index++;
                lineItem.lineItemId = link.BillingID__r.PricingName__c;
                lineItem.containerSize = link.BillingID__r.PricingName__c != null? link.BillingID__r.PricingName__r.ContainerSize__c : null;
                lineItem.curr = currencyType;
                lineItem.productName = pricingName;
                lineItem.quantity = 1;
                //lineItem.unit = link.BillingID__r.PricingName__c != null && !String.isBlank(link.BillingID__r.PricingName__r.UNIT__c) ? link.BillingID__r.PricingName__r.UNIT__c: null;
                lineItem.unit = translateUnit(link);
                lineItem.chargeUnitFormula = link.BillingID__r.ChargeUnitFormula__c;
                lineItem.billType = 'WMS';
                lineItem.taxCategory = language == 'vi' && link.BillingID__r.PricingName__c != null? link.BillingID__r.PricingName__r.TAX__c: '';
                lineItem.tax = String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c);
                lineItem.totalAmount =  Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? totalAmountUSD : totalAmountLocal;
                lineItem.taxSellingAmount = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? taxSellingAmountUSD : taxSellingAmountLocal;
                lineItem.amountSellingIncludeTax = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? amountSellingIncludeTaxUSD : amountSellingIncludeTaxLocal;
                
            }
            lineItem.workOrderIds.add(link.BillingID__r.WorkOrderID__c);
            lineItem.unitPrice = lineItem.totalAmount;
            
            lineItemByPricingMap.put(pricingName,lineItem);

        }
        return lineItemByPricingMap.values();
    }

    private List<InvoiceLineItem> getInvoicesbyPricingNameFMS(List<INVOICING_VAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Map<String,InvoiceLineItem> lineItemByPricingMap = new Map<String,InvoiceLineItem>();
        Integer index = 1; 
        for(INVOICING_VAT__c link : listLink){
            InvoiceLineItem lineItem;
            String pricingName = '';
            if(link.INVOICING__r.Tariff__c != null){
                pricingName = language != 'vi'? link.INVOICING__r.Tariff__r.VATInvoiceAtPrintENG__c : link.INVOICING__r.Tariff__r.VATInvoiceAtPrintLocal__c;
                
                if(String.isBlank(pricingName)){
                    pricingName = link.INVOICING__r.Tariff__r.Name;
                }
            }else{
                pricingName ='Non-Pricing';
            }
            
            if(lineItemByPricingMap.containsKey(pricingName)){
                lineItem = lineItemByPricingMap.get(pricingName);

                lineItem.taxCategory = language == 'vi' && link.INVOICING__r.Tariff__c != null? link.INVOICING__r.Tariff__r.TAX__c: '';
                
                if( link.INVOICING__r.TaxInitial__c != null
                    && lineItem.tax != String.valueOf((Integer)link.INVOICING__r.TaxInitial__c)){
                    lineItem.tax += '/ ' + String.valueOf((Integer)link.INVOICING__r.TaxInitial__c);
                }
                lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellAmountUSD__c : link.INVOICING__r.SellAmountJPN__c);
                lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTaxNum_USD__c : link.INVOICING__r.SellTaxNum__c);
                lineItem.taxSellingAdjustmentAmount += (link.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : link.INVOICING__r.TAX_ADJUSTMENTSELL__c);
                lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellInTaxAmount_USD__c : link.INVOICING__r.SellInTaxAmountJPY__c);
            }else{
                lineItem = new InvoiceLineItem();
                lineItem.index = index++;
                lineItem.lineItemId = link.INVOICING__r.Tariff__c;
                lineItem.containerSize = link.INVOICING__r.Tariff__c != null? link.INVOICING__r.Tariff__r.ContainerSize__c : null;
                lineItem.curr = currencyType;
                lineItem.productName  = pricingName;
                lineItem.quantity = 1;
                //lineItem.unit = link.INVOICING__r.Tariff__c != null && !String.isBlank(link.INVOICING__r.Tariff__r.UNIT__c) ? link.INVOICING__r.Tariff__r.UNIT__c: null; 
                lineItem.unit = translateUnit(link);
                lineItem.chargeUnitFormula = link.INVOICING__r.ChargeUnitFormula__c;
                lineItem.billType = 'FMS';
                lineItem.taxCategory = language == 'vi' && link.INVOICING__r.Tariff__c != null? link.INVOICING__r.Tariff__r.TAX__c: '';
                lineItem.tax = String.valueOf((Integer)link.INVOICING__r.TaxInitial__c);
                lineItem.totalAmount = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellAmountUSD__c : link.INVOICING__r.SellAmountJPN__c);
                lineItem.taxSellingAmount = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTaxNum_USD__c : link.INVOICING__r.SellTaxNum__c);
                lineItem.taxSellingAdjustmentAmount = (link.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : link.INVOICING__r.TAX_ADJUSTMENTSELL__c);
                lineItem.amountSellingIncludeTax = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellInTaxAmount_USD__c : link.INVOICING__r.SellInTaxAmountJPY__c);
            }
            lineItem.shipmentOrderIds.add(link.INVOICING__r.Anken__c);
            lineItem.unitPrice = lineItem.totalAmount;
            
            lineItemByPricingMap.put(pricingName,lineItem);

        }
        return lineItemByPricingMap.values();
    }

    private InvoiceLineItem getInvoicesToOneWMS(List<ConnectBillingVAT__c> listLink){
        InvoiceLineItem lineItem = new InvoiceLineItem();
        lineItem.index = 1;
        lineItem.lineItemId = currentVat.Id;
        lineItem.quantity = 1;
        lineItem.totalAmount = 0;
        lineItem.unitPrice = 0;
        lineItem.taxSellingAmount = 0;
        lineItem.taxSellingAdjustmentAmount = 0;
        lineItem.amountSellingIncludeTax = 0;
        lineItem.curr = currencyType;
        lineItem.productName = currentVat.DESCRIPTION_FOR_COMBINE__c;
        lineItem.unit = 'Combined';
        lineItem.billType = 'WMS';
        Set<String> taxSet = new Set<String>();
        for (ConnectBillingVAT__c link : listLink){
             taxSet.add(String.valueOf(link.BillingID__r.TaxRatioSelling__c));
            Decimal totalAmountUSD = link.BillingID__r.TotalAmountOfSellingUSD__c == null? 0 : link.BillingID__r.TotalAmountOfSellingUSD__c;
            Decimal taxSellingAmountUSD = link.BillingID__r.AmountOfTaxSellingUSD__c == null? 0 : link.BillingID__r.AmountOfTaxSellingUSD__c;
            Decimal amountSellingIncludeTaxUSD = link.BillingID__r.AmountSellingIncludeTAXUSD__c == null? 0 : link.BillingID__r.AmountSellingIncludeTAXUSD__c;
            Decimal totalAmountLocal = link.BillingID__r.TotalAmountOfSellingLocal__c == null? 0 : link.BillingID__r.TotalAmountOfSellingLocal__c;
            Decimal taxSellingAmountLocal = link.BillingID__r.AmountOfTaxSelling__c == null? 0 : link.BillingID__r.AmountOfTaxSelling__c;
            Decimal amountSellingIncludeTaxLocal = link.BillingID__r.AmountSellingIncludeTAX__c == null? 0 : link.BillingID__r.AmountSellingIncludeTAX__c;
            //lineItem.unitPrice = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? link.BillingID__r.UnitPriceOfSellingUSD__c : link.BillingID__r.UnitPriceOfSellingLocal__c;
            lineItem.totalAmount +=  Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? totalAmountUSD : totalAmountLocal;
            lineItem.taxSellingAmount += Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? taxSellingAmountUSD : taxSellingAmountLocal;
            lineItem.amountSellingIncludeTax += Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? amountSellingIncludeTaxUSD : amountSellingIncludeTaxLocal;
            lineItem.workOrderIds.add(link.BillingID__r.WorkOrderID__c);
        }
        lineItem.tax = String.join(new List<String>(taxSet),'/ ');
        lineItem.unitPrice = lineItem.totalAmount;
        return lineItem;
    }

    private InvoiceLineItem getInvoicesToOneFMS(List<INVOICING_VAT__c> listLink){
        InvoiceLineItem lineItem = new InvoiceLineItem();
        lineItem.index = 1;
        lineItem.lineItemId = currentVat.Id;
        lineItem.quantity = 1;
        lineItem.totalAmount = 0;
        lineItem.unitPrice = 0;
        lineItem.taxSellingAmount = 0;
        lineItem.taxSellingAdjustmentAmount = 0;
        lineItem.amountSellingIncludeTax = 0;
        lineItem.curr = currencyType;
        lineItem.productName = currentVat.DESCRIPTION_FOR_COMBINE__c;
        lineItem.unit = 'Combined';
        lineItem.billType = 'FMS';
        Set<String> taxSet = new Set<String>();
        for (INVOICING_VAT__c link : listLink){
            taxSet.add(String.valueOf(link.INVOICING__r.TaxInitial__c));
            //lineItem.taxCategory = link.INVOICING__r.ProductTax__c;
            lineItem.totalAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellAmountUSD__c : link.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTaxNum_USD__c : link.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount += (link.INVOICING__r.TAX_ADJUSTMENTSELL__c == null ? 0 : link.INVOICING__r.TAX_ADJUSTMENTSELL__c);
            lineItem.amountSellingIncludeTax += (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellInTaxAmount_USD__c : link.INVOICING__r.SellInTaxAmountJPY__c);
            lineItem.shipmentOrderIds.add(link.INVOICING__r.Anken__c);
        }
        lineItem.tax = String.join(new List<String>(taxSet),'/ ');
        lineItem.unitPrice = lineItem.totalAmount;
        
        return lineItem;
    }
    private List<InvoiceLineItem> getInvoiceLineItemsSingleWMS(List<ConnectBillingVAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Integer index = 1; 
        for(ConnectBillingVAT__c link : listLink){
            InvoiceLineItem lineItem = new InvoiceLineItem();
            lineItem.index = index++;
            lineItem.lineItemId = link.Id;
            lineItem.productName = language == 'vi'? link.BillingID__r.PricingNameAtPrintLocal__c : link.BillingID__r.PricingNameAtPrintENG__c;
            lineItem.containerSize = link.BillingID__r.PricingName__c != null? link.BillingID__r.PricingName__r.ContainerSize__c : null;
            lineItem.curr = currencyType;
            //lineItem.unit = link.BillingID__r.Unit__c;
            lineItem.unit = translateUnit(link); 
            lineItem.chargeUnitFormula = link.BillingID__r.ChargeUnitFormula__c;
            lineItem.quantity = Integer.valueOf(link.BillingID__r.ChargeUnitTotal__c);
            lineItem.taxCategory = link.BillingID__r.TAX__c;
            lineItem.tax = String.valueOf((Integer)link.BillingID__r.TaxRatioSelling__c);
            lineItem.unitPrice = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? link.BillingID__r.UnitPriceOfSellingUSD__c : link.BillingID__r.UnitPriceOfSellingLocal__c;
            lineItem.totalAmount =  Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? link.BillingID__r.TotalAmountOfSellingUSD__c : link.BillingID__r.TotalAmountOfSellingLocal__c;
            lineItem.taxSellingAmount = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? link.BillingID__r.AmountOfTaxSellingUSD__c : link.BillingID__r.AmountOfTaxSelling__c;
            lineItem.amountSellingIncludeTax = Constants.CURRENCY_USD.equalsIgnoreCase(currencyType)? link.BillingID__r.AmountSellingIncludeTAXUSD__c : link.BillingID__r.AmountSellingIncludeTAX__c;
            lineItems.add(lineItem);

        }
        return lineItems;

    }

    private List<InvoiceLineItem> getInvoiceLineItemsSingleFMS(List<INVOICING_VAT__c> listLink){
        Schema.DescribeFieldResult fieldResult = TariffMaster__c.UNIT__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String, String> mapPicklistUnit = new Map<String, String>();
        for(Schema.PicklistEntry s : ple){
            mapPicklistUnit.put(s.getLabel(), s.getValue());
        } 
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        Integer index = 1;
        for(INVOICING_VAT__c link : listLink){
            InvoiceLineItem lineItem = new InvoiceLineItem();
            String description = language == 'vi'? link.INVOICING__r.InsatuyouSyohin__c : link.INVOICING__r.InsatuyouSyohinEng__c ;
            lineItem.index = index++;
            lineItem.lineItemId = link.Id;
            lineItem.productName = (StringUtils.isEmpty(description) ? '' : description.replaceAll('Surcharge Included', '').replaceAll('Surcharge Excluded', ''));
            lineItem.containerSize = link.INVOICING__r.Tariff__r.ContainerSize__c;
            lineItem.curr = currencyType;
            //lineItem.unit = mapPicklistUnit.get(link.INVOICING__r.Tariff__r.UNIT__c);
            lineItem.unit = translateUnit(link);
            lineItem.chargeUnitFormula = link.INVOICING__r.ChargeUnitFormula__c;
            lineItem.billType = 'FMS';
            lineItem.quantity = Decimal.valueOf(link.INVOICING__r.wkSuryo__c);
            lineItem.taxCategory = link.INVOICING__r.ProductTax__c;
            lineItem.tax = String.valueOf((Integer)link.INVOICING__r.TaxInitial__c);
            lineItem.unitPrice = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTankaUSD__c : link.INVOICING__r.SellTankaJPY__c);
            lineItem.totalAmount = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellAmountUSD__c : link.INVOICING__r.SellAmountJPN__c);
            lineItem.taxSellingAmount = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellTaxNum_USD__c : link.INVOICING__r.SellTaxNum__c);
            lineItem.taxSellingAdjustmentAmount = link.INVOICING__r.TAX_ADJUSTMENTSELL__c;
            lineItem.amountSellingIncludeTax = (Constants.CURRENCY_USD.equalsIgnoreCase(currencyType) ? link.INVOICING__r.SellInTaxAmount_USD__c : link.INVOICING__r.SellInTaxAmountJPY__c);
            if(link.INVOICING__c != null && link.INVOICING__r.Anken__c != null){
                lineItem.shipmentOrderIds.add(link.INVOICING__r.Anken__c);
            }
            
            lineItems.add(lineItem);
        }
        return lineItems;
    }

    private List<InvoiceLineItem> getInvoiceLineItemsCombinedWorkOrder(List<ConnectBillingVAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        return lineItems;
    }

    private List<InvoiceLineItem> getInvoiceLineItemsShipmentOrder(List<ConnectBillingVAT__c> listLink){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        return lineItems;
    }
    

    private static Map<String, String > getTranslationMap(String language){
        Map<String, Object> translate = TranslationService.getByLanguage(language);
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('wms')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
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
    
    private String translateUnit(ConnectBillingVAT__c billingVAT){
        String unit = billingVAT.BillingID__r.ChargeUnitFormula__c;
        if(billingVAT.BillingID__r.ChargeUnitFormula__c =='本'){
                unit = 'Unit';
            } 
        if(billingVAT.BillingID__r.ChargeUnitFormula__c =='コンテナ' || billingVAT.BillingID__r.ChargeUnitFormula__c =='Container'){
            unit = billingVAT.BillingID__r.ContainerrSizeFormula__c;
            if(String.isBlank(unit)){
                unit = 'Container';
            }
        }
        if(billingVAT.BillingID__r.ChargeUnitFormula__c =='件'){
            unit = 'Case';
        }
        return unit;
    }
    public class InvoiceReportWrapper {
        public String language {get;set;}
        public String invoiceNo { get; set; }
        public String invoiceTo { get; set; }
        public String invoiceToENG { get; set; }
        public String address { get; private set; }
        public String addressENG { get; private set; }
        public String clientName { get; set; }
        public String issuedBy { get; set; }
        public Date issuedDate { get; set; }
        public String termsOfPayment { get; set; }
        public String remarks { get; set; }
        public String tax { get; set; }
        public Decimal totalAmount { get; set; }
        public Decimal totalTaxSellingAdjustmentAmount { get; set; }
        public Decimal amountSellingIncludeTax { get; set; }
        public String taxCode { get; set; }
        public List<InvoiceLineItem> invoiceLineItems { get; set; }
        public String WKIDs { get; set; }
        public String bankAccounts { get; private set; }
        public String customerBankAccount { get; private set; }
        public String NumberSeaAir { get; set; }
        public String creditTerm { get; set; }
        public String mblNumberSeaAir { get; set; }
        public String hblNumberSeaAir { get; set; }
        public String customerPhoneNumber { get; set; }

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
            for(InvoiceLineItem lineItem : invoiceLineItems){
                lineItem.taxSellingAmount = lineItem.taxSellingAmount == null? 0 : lineItem.taxSellingAmount;
                taxAmount += lineItem.taxSellingAmount;
            }
            return taxAmount;
        }

        public String getTotalAmountText() {
            if(language == 'vi'){
                 return NumbericUtils.convertNumberToText(getTotalAmoutIncludedTax().round(System.RoundingMode.HALF_UP), WMS_VATInvoicePDFController.currencyType);
            }else{
                if(WMS_VATInvoicePDFController.currencyType == 'VND'){
                    return NumbericUtils.readVNDAmountInEn(getTotalAmoutIncludedTax().round(System.RoundingMode.HALF_UP));
                }else{
                    return NumbericUtils.readUSDAmountInEn(getTotalAmoutIncludedTax().round(System.RoundingMode.HALF_UP));
                }
            }
          
        }

        public void setInvoiceToAddress(String street, String city, String state, String country) {
            address = (StringUtils.isEmpty(street) ? '' : street) +
                    (StringUtils.isEmpty(city) ? '' : ',' + city) +
                    (StringUtils.isEmpty(state) ? '' : ',' + state) +
                    (StringUtils.isEmpty(country) ? '' : ',' + country);
        }

        public void setBankAccounts(String bank1, String bank2) {
            bankAccounts = '';

            if (!StringUtils.isEmpty(bank1) && !StringUtils.isEmpty(bank2)) {
                bankAccounts = bank1 + '\n' + bank2;
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

    public class InvoiceLineItem {
        public Set<String> shipmentOrderIds{get; set;}
        public Set<String> workOrderIds{get; set;}
        public String pricingName{get;set;}
        public String billType{get;set;}
        public String lineItemId {get; set;}
        public Decimal index { get; set; }
        public String productName { get; set; }
        public String chargeUnitFormula{get;set;}
        public String unit { get; set; }
        public Decimal quantity { get; set; }
        public String curr { get; set; }
        public String containerSize { get; set; }
        public String tax { get; set; }
        public String taxCategory { get; set; }
        public Decimal unitPrice { get; set; }
        public Decimal totalAmount { get; set; }
        public Decimal taxSellingAmount { get; set; }
        public Decimal taxSellingAdjustmentAmount { get; set; }
        public String totalAmountInWord{get;set;}
        public String language{get;set;}
        //Nga Do - 2018/09/04 - AFR-14- Add 3 New Data into Draft VAT Invoice - Start
        public Decimal amountSellingIncludeTax { get; set; }
        //Nga Do - 2018/09/04 - AFR-14- Add 3 New Data into Draft VAT Invoice - End
        public InvoiceLineItem(){
            shipmentOrderIds = new Set<String>();
            workOrderIds = new Set<String>();
        }
        public Integer getLineItemHeight(){
            Integer height = 1;
            if(productName != null){
                height = productName.length()/ 30;
                if(Math.mod(productName.length(), 30) > 0){
                    height += 1;
                }
            }
            
            return height;
        }

        public String getTotalAmountInWord(){
            if(language =='vi'){
                    totalAmountInWord = NumbericUtils.convertNumberToText(totalAmount, curr);
                
            }else{
                if(curr =='VND'){

                totalAmountInWord = NumbericUtils.readVNDAmountInEn(totalAmount);
                }else if(curr =='USD'){
                    totalAmountInWord = NumbericUtils.readUSDAmountInEn(totalAmount);
                }

            }
            
            return totalAmountInWord;
        }

    }
}