public with sharing class DCBReportService { 
    private static List<String> selectFields = new List<String>();
    private Map<String, Id> mapRecordTypes = new Map<String, Id>();

    static {
        selectFields.add('Anken__r.Field1__r.Name');
        selectFields.add('Anken__r.Field1__r.PaidDay__c');
        selectFields.add('Anken__r.Field1__r.PaidDayAdvance__c');
        selectFields.add('Anken__r.Name');
        selectFields.add('Anken__r.ID__c');
        selectFields.add('Anken__r.WkInitial__c');
        selectFields.add('Anken__r.QuotationVer__c');
        selectFields.add('Anken__c');
        selectFields.add('Anken__r.HBL_Number_Sea_Air__c');
        selectFields.add('Anken__r.MBL_Number_Sea_Air__c');
        selectFields.add('Anken__r.ETD__c');
        selectFields.add('Anken__r.ETA__c');
        selectFields.add('Anken__r.Ship_number__c');
        selectFields.add('Anken__r.DeadlineForPaymentOfInvoices__c');
        selectFields.add('Anken__r.DeadlineForPaymentOfExpense__c');
        selectFields.add('Anken__r.DeliveryDate__c');
        selectFields.add('Anken__r.carton__c');
        selectFields.add('Anken__r.Status__c');
        selectFields.add('UNPAID_BALANCE_OF_BUYING_USD__c');
        selectFields.add('BuyDifferentiation__c');
        selectFields.add('SellDifferentiation__c');
        selectFields.add('UNPAID_BALANCE_OF_SELLING_USD__c');
        selectFields.add('curr__c');
        selectFields.add('CurrencyBuying__c');
        selectFields.add('ProductTax__c');
        selectFields.add('SellInTaxAmountJPY__c'); // AMMOUNT SELLING INCLUDING TAX
        selectFields.add('Id');
        selectFields.add('Seikyusaki__r.Name');
        selectFields.add('Seikyusaki__r.EnglishCompanyName__c');
        selectFields.add('PartnerDebitJPN__c');
        selectFields.add('PartnerCreditJPN__c');
        selectFields.add('PartnerSeisanJPY__c');
        selectFields.add('Anken__r.SeikyusyoRemark__c');
        selectFields.add('Suryo__c');
        selectFields.add('SellTankaJPY__c');
        selectFields.add('TaxInitial__c');
        selectFields.add('TAX_ADJUSTMENTSELL__c');
        selectFields.add('Nyukingaku__c');
        selectFields.add('Siharaigaku__c');
        selectFields.add('SalesAccountedDate__c');
        selectFields.add('SalesAccountedDateInvoicing__c');
        selectFields.add('BuyTankaJPY__c');
        selectFields.add('BuyTaxInitial__c');
        selectFields.add('Cost_Allocation_Margin__c');
        selectFields.add('BuyTankaUSD__c');
        selectFields.add('SellTankaUSD__c');
        selectFields.add('AMOUNT_PAID_SELLING_USD__c');
        selectFields.add('PartnerCredit__c');
        selectFields.add('PartnerDebit__c');
        selectFields.add('PartnerSeisanUSD__c');
        selectFields.add('InsatuyouSyohin__c');
        selectFields.add('PaymentTo__r.Name');
        selectFields.add('Description__c');
        selectFields.add('Name');
        selectFields.add('BuyAmountUSD__c');
        selectFields.add('SellAmountUSD__c');
        selectFields.add('SellInTaxAmount_USD__c');
        selectFields.add('BuyInTaxAmountJPY__c');
        selectFields.add('BuyInTaxAmountUSD__c');
    }

    public DCBReportService() {
        loadRecordTypes();
    }
    
    public DCB_ReportWrapper generateGeneralReportCustomer(String strId, String customerId, String fromDate, String toDate, String searchTypeDate) {
        strId = strId.replaceAll('\'','');
        strId = String.escapeSingleQuotes(strId);
        customerId = String.escapeSingleQuotes(customerId);
        fromDate = String.escapeSingleQuotes(fromDate);
        toDate = String.escapeSingleQuotes(toDate);
        searchTypeDate = String.escapeSingleQuotes(searchTypeDate);

        String soqlQuery = buildSelectClause() + buildFromClause() 
                        + buildWhereClauseCustomer(strId, customerId, fromDate, toDate, '1', searchTypeDate) 
                        + buildOrderByClause();
        DCB_ReportWrapper report;
        if (!String.isBlank(strId) && PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleHBL()
                && PermissionValidationUtil.isAccessibleHBLBuying()) {
            report = retrieveReportData(soqlQuery);
        }
        else{
            report = retrieveReportData(soqlQuery);
        }
        return report;
    }
    
    public Map<String, List<DCB_ReportLineItem>> generateGeneralReportCustomerDetail(String strId, String customerId, String fromDate, String toDate, String searchTypeDate) {
        strId = strId.replaceAll('\'','');
        strId = String.escapeSingleQuotes(strId);
        customerId = String.escapeSingleQuotes(customerId);
        fromDate = String.escapeSingleQuotes(fromDate);
        toDate = String.escapeSingleQuotes(toDate);
        searchTypeDate = String.escapeSingleQuotes(searchTypeDate);

        String soqlQuery = buildSelectClause() + buildFromClause() 
                        + buildWhereClauseCustomer(strId, customerId, fromDate, toDate, '0', searchTypeDate) 
                        + buildOrderByClause();
        Map<String, List<DCB_ReportLineItem>> report = retrieveReportDataDetail(soqlQuery);
        return report;
    }
    public DCB_ReportWrapper generateGeneralReportCustomerCreditDebit(String strId, String customerId, String fromDate, String toDate, String searchTypeDate) {
        strId = strId.replaceAll('\'','');
        strId = String.escapeSingleQuotes(strId);
        customerId = String.escapeSingleQuotes(customerId);
        fromDate = String.escapeSingleQuotes(fromDate);
        toDate = String.escapeSingleQuotes(toDate);
        searchTypeDate = String.escapeSingleQuotes(searchTypeDate);
        
        String soqlQuery = buildSelectClause() + buildFromClause() 
                        + buildWhereClauseCustomerCreditDebit(strId, customerId, fromDate, toDate, '1', searchTypeDate) 
                        + buildOrderByClause();
        DCB_ReportWrapper report;
        report = retrieveReportDataCreditDebit(soqlQuery, customerId);
        return report;
    }
    
    public Map<String, List<DCB_ReportLineItem>> generateGeneralReportCustomerCreditDebitDetail(String strId, String customerId, String fromDate, String toDate, String searchTypeDate) {
        strId = strId.replaceAll('\'','');
        strId = String.escapeSingleQuotes(strId);
        customerId = String.escapeSingleQuotes(customerId);
        fromDate = String.escapeSingleQuotes(fromDate);
        toDate = String.escapeSingleQuotes(toDate);
        searchTypeDate = String.escapeSingleQuotes(searchTypeDate);
        
        String soqlQuery = buildSelectClause() + buildFromClause() 
                        + buildWhereClauseCustomerCreditDebit(strId, customerId, fromDate, toDate, '0', searchTypeDate) 
                        + buildOrderByClause();
        Map<String, List<DCB_ReportLineItem>> report = retrieveReportDataDetailCreditDebit(soqlQuery, customerId);
        return report;
    }

    public DCB_ReportWrapper generateGeneralReport(String fromDate, String toDate) {
        String soqlQuery = buildSelectClause() + buildFromClause() + buildWhereClause(null, fromDate, toDate, '0') + buildOrderByClause();

        DCB_ReportWrapper report = retrieveReportData(soqlQuery);
        return report;
    }

    public DCB_ReportWrapper generateCustomerReport(String customerId, String fromDate, String toDate, String option) {
        String soqlQuery = buildSelectClause() + buildFromClause() +
                buildWhereClause(customerId, fromDate, toDate, option) + buildOrderByClause();
        DCB_ReportWrapper report = new DCB_ReportWrapper();

        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleHBL()
                && PermissionValidationUtil.isAccessibleHBLBuying()) {
            report = retrieveReportData(soqlQuery);
        }

        return report;
    }
    
    private Map<String, List<DCB_ReportLineItem>> retrieveReportDataDetail(String soqlQuery) {
        List<AnkenMeisai__c> billingRecords = Database.query(soqlQuery);
        Map<String, List<DCB_ReportLineItem>> wrappers = new Map<String, List<DCB_ReportLineItem>>();

        for (AnkenMeisai__c record : billingRecords) {
            DCB_ReportLineItem reportItem = createWrapperRecord(record, '');
            if(!wrappers.containsKey(record.Seikyusaki__r.Name + record.Anken__r.Name)){
                wrappers.put(record.Seikyusaki__r.Name + record.Anken__r.Name, new List<DCB_ReportLineItem>());
            }
            if(record.Seikyusaki__r.Name != record.PaymentTo__r.Name){
                reportItem.credit = 0;
                reportItem.creditUSD = 0;
            }
            wrappers.get(record.Seikyusaki__r.Name + record.Anken__r.Name).add(reportItem);
        }

        return wrappers;
    }

    private Map<String, List<DCB_ReportLineItem>> retrieveReportDataDetailCreditDebit(String soqlQuery, String customerId) {
        List<AnkenMeisai__c> billingRecords = Database.query(soqlQuery);
        Map<String, List<DCB_ReportLineItem>> wrappers = new Map<String, List<DCB_ReportLineItem>>();
        Account customer = [SELECT Id, Name, EnglishCompanyName__c FROM Account WHERE Id =: customerId];
        for (AnkenMeisai__c record : billingRecords) {
            DCB_ReportLineItem reportItem = createLineItemCreditDebit(record, customer );
            if(!wrappers.containsKey(customer.Name + record.Anken__r.Name)){
                wrappers.put(customer.Name + record.Anken__r.Name, new List<DCB_ReportLineItem>());
            }
            if(record.Seikyusaki__c != customerId){
                reportItem.debit = 0;
                reportItem.debitUSD = 0;
            }
            if(record.PaymentTo__c != customerId){
                reportItem.credit = 0;
                reportItem.creditUSD = 0;
            }
            wrappers.get(customer.Name + record.Anken__r.Name).add(reportItem);
        }

        return wrappers;
    }
    private DCB_ReportWrapper retrieveReportDataCreditDebit(String soqlQuery, String customerId) {
        List<AnkenMeisai__c> billingRecords = Database.query(soqlQuery);
        String customerName = '';
        DCB_SubReportWrapper subReport = null;
        Map<String, DCB_ReportLineItem> wrappers = new Map<String, DCB_ReportLineItem>();
        DCB_ReportWrapper report = new DCB_ReportWrapper();
        boolean itemAdded = false;

        Account customer = [Select Id, EnglishCompanyName__c, Name  FROM Account Where Id =: customerId];

        subReport = new DCB_SubReportWrapper(customer.Name, customer.EnglishCompanyName__c, customer.Id);
        customerName = customer.Name;

        for (AnkenMeisai__c record : billingRecords) {

            String key = record.Anken__c;
            if(!wrappers.containsKey(key)){

                DCB_ReportLineItem wrapper = createLineItemCreditDebit(record,customer);
                wrappers.put(key, wrapper);

            }else{
                DCB_ReportLineItem wrapper = wrappers.get(key);
                Decimal sellingAmountInclTax = Util.calculateSellingInTaxAmount(record);
                wrapper.recordCount++;
                wrapper.sumOfAmountSelling += sellingAmountInclTax;
                wrapper.sumOfUnPaidBalance += (sellingAmountInclTax - (record.Nyukingaku__c != null ? record.Nyukingaku__c : 0));//(record.SellDifferentiation__c == null ? 0 : record.SellDifferentiation__c);
                Decimal credit = 0;
                Decimal creditUSD = 0;
                Decimal debit = 0;
                Decimal debitUSD = 0;
                if(customerName != record.PaymentTo__r.Name){
                    credit = 0;
                    creditUSD = 0;
                    if(record.curr__c == 'VND'){
                        debit = (record.SellDifferentiation__c == null ? 0 : record.SellDifferentiation__c);
                    }else{
                        debitUSD = (record.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : record.UNPAID_BALANCE_OF_SELLING_USD__c);
                    }
                    
                     
                }
                else{
                    if(record.CurrencyBuying__c == 'VND'){
                        credit = (record.BuyDifferentiation__c == null ? 0 : record.BuyDifferentiation__c);
                    }else{
                        creditUSD = (record.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : record.UNPAID_BALANCE_OF_BUYING_USD__c); 
                    }
                    
                    
                    debit = 0;
                    debitUSD = 0;
                }

                wrapper.sumOfCredit += credit;
                wrapper.sumOfDebit += debit;
                wrapper.sumOfCreditUSD += creditUSD;
                wrapper.sumOfDebitUSD += debitUSD;

                wrapper.sumOfBalance = wrapper.sumOfDebit - wrapper.sumOfCredit;
                wrapper.sumOfBalanceUSD = wrapper.sumOfDebitUSD - wrapper.sumOfCreditUSD;//(record.PartnerSeisanJPY__c == null ? 0 : record.PartnerSeisanJPY__c);
            
            }
        }

        if (!itemAdded) {
            if (subReport != null) {
                subReport.addLineItems(wrappers.values());
                report.addCustomerReport(subReport);
            }
        }
        return report;
    }

    private DCB_ReportWrapper retrieveReportData(String soqlQuery) {
        List<AnkenMeisai__c> billingRecords = Database.query(soqlQuery);
        String customerName = '';
        DCB_SubReportWrapper subReport = null;
        Map<String, DCB_ReportLineItem> wrappers = null;
        DCB_ReportWrapper report = new DCB_ReportWrapper();
        boolean itemAdded = true;

        for (AnkenMeisai__c record : billingRecords) {
            if (!customerName.equalsIgnoreCase(record.Seikyusaki__r.Name)) {
                // assign for previous customer
                if (subReport != null) {
                    subReport.addLineItems(wrappers.values());
                    report.addCustomerReport(subReport);
                }

                // reset for new customer
                customerName = record.Seikyusaki__r.Name;
                subReport = new DCB_SubReportWrapper(customerName, record.Seikyusaki__r.EnglishCompanyName__c, record.Seikyusaki__c);
                wrappers = new Map<String, DCB_ReportLineItem>();
                itemAdded = false;
            }

            String key = buildSTIDKey(record);
            
            if (!wrappers.containsKey(key)) {
                DCB_ReportLineItem wrapper = createWrapperRecord(record, key);
                wrappers.put(key, wrapper);
            } else {
                DCB_ReportLineItem wrapper = wrappers.get(key);
                Decimal sellingAmountInclTax = Util.calculateSellingInTaxAmount(record);
                wrapper.recordCount++;
                wrapper.sumOfAmountSelling += sellingAmountInclTax;
                wrapper.sumOfUnPaidBalance += (sellingAmountInclTax - (record.Nyukingaku__c != null ? record.Nyukingaku__c : 0));//(record.SellDifferentiation__c == null ? 0 : record.SellDifferentiation__c);
                Decimal credit = 0;
                //Decimal debit = (record.PartnerDebitJPN__c == null ? 0 : record.PartnerDebitJPN__c);
                Decimal creditUSD = 0;
                //Decimal debitUSD = (record.PartnerDebit__c == null ? 0 : record.PartnerDebit__c);
                Decimal debit = (record.SellInTaxAmountJPY__c == null ? 0 : record.SellInTaxAmountJPY__c);
                Decimal debitUSD = (record.SellInTaxAmount_USD__c == null ? 0 : record.SellInTaxAmount_USD__c);
                
                if(record.Seikyusaki__r.Name != record.PaymentTo__r.Name){
                    credit = 0;
                    creditUSD = 0;
                }
                else{
                    //credit = (record.PartnerCreditJPN__c == null ? 0 : record.PartnerCreditJPN__c);
                    //creditUSD = (record.PartnerCredit__c == null ? 0 : record.PartnerCredit__c);
                    credit = (record.BuyInTaxAmountJPY__c == null ? 0 : record.BuyInTaxAmountJPY__c);
                    creditUSD = (record.BuyInTaxAmountUSD__c == null ? 0 : record.BuyInTaxAmountUSD__c);
                }


                
                wrapper.sumOfCredit += credit;
                wrapper.sumOfDebit += debit;
                Decimal balance = debit - credit;
                Decimal balanceUSD = debitUSD - creditUSD;
                
                wrapper.sumOfBalance += balance;//(record.PartnerSeisanJPY__c == null ? 0 : record.PartnerSeisanJPY__c);
                wrapper.sumOfCreditUSD += creditUSD;
                wrapper.sumOfDebitUSD += debitUSD;
                wrapper.sumOfBalanceUSD += balanceUSD;//(record.PartnerSeisanJPY__c == null ? 0 : record.PartnerSeisanJPY__c);
            }
        }

        if (!itemAdded) {
            if (subReport != null) {
                subReport.addLineItems(wrappers.values());
                report.addCustomerReport(subReport);
            }
        }

        return report;
    }

    private String buildSelectClause() {
        return 'SELECT ' + String.join(selectFields, ',') + ' ';
    }

    private String buildFromClause() {
        return 'FROM AnkenMeisai__c ';
    }

    private String buildWhereClause(String customerId, String fromDate, String toDate, String option) {
        String whereClause = 'WHERE NyukinKakuninzumi__c = false ';
        whereClause += ' AND Anken__r.RecordTypeId NOT IN ' + getExcludedShipmentRecordTypes();
        whereClause += ' AND Anken__r.Status__c NOT IN ' + getExcludedShipmentStatuses();
        whereClause += ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        whereClause += buildTimeFrameCondition(fromDate, toDate);
        whereClause += buildCustomIdCondition(customerId);
        whereClause += buildOptionCondition(option);

        return whereClause;
    }
    
    private String buildWhereClauseCustomer(String strId, String customerId, String fromDate, String toDate, String option, String typeSearch) {
        String whereClause = 'WHERE NyukinKakuninzumi__c = false ';
        if(!String.isEmpty(strId)){
            whereClause += ' AND Id = \'' + strId + '\' ';
        }
        whereClause += ' AND Anken__r.RecordTypeId NOT IN ' + getExcludedShipmentRecordTypes();
        whereClause += ' AND Anken__r.Status__c NOT IN ' + getExcludedShipmentStatuses();
        whereClause += ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        whereClause += buildTimeFrameConditionCustomer(fromDate, toDate, typeSearch);
        whereClause += buildCustomIdCondition(customerId);
        whereClause += buildOptionCondition(option);

        return whereClause;
    }

    private String buildWhereClauseCustomerCreditDebit(String strId, String customerId, String fromDate, String toDate, String option, String typeSearch) {
        String whereClause = 'WHERE ((NyukinKakuninzumi__c = false AND Seikyusaki__c =\''+customerId+ '\') OR (SiharaiKakuninzumi__c = false AND PaymentTo__c =\''+customerId+ '\'))';
        if(!String.isEmpty(strId)){
            whereClause += ' AND Id = \'' + strId + '\' ';
        }
        whereClause += ' AND Anken__r.RecordTypeId NOT IN ' + getExcludedShipmentRecordTypes();
        whereClause += ' AND Anken__r.Status__c NOT IN ' + getExcludedShipmentStatuses();
        //whereClause += ' AND Seikyusaki__r.Business_Relationship__c = \'' + Constants.CUSTOMER_RELATIONSHIP + '\'';
        whereClause += buildTimeFrameConditionCustomer(fromDate, toDate, typeSearch);
        //whereClause += ' AND (Seikyusaki__c = \'' + customerId + '\' OR PaymentTo__c = ' '')';
        //buildCustomIdCondition(customerId);
        whereClause += buildOptionCondition(option);

        return whereClause;
    }
    
    private String buildTimeFrameConditionCustomer(String fromDate, String toDate, String typeSearch){
        String searchFilter = '';

        if (!StringUtils.isEmpty(fromDate) && !StringUtils.isEmpty(toDate)) {
            if (fromDate <= toDate) {
                if(typeSearch.equals('ETD')){
                    searchFilter = ' AND (Anken__r.ETD__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(typeSearch.equals('ETA')){
                    searchFilter = ' AND (Anken__r.ETA__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(typeSearch.equals('SHIPMENTORDER')){
                    searchFilter = ' AND (Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate) + ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate) + ')';
                }
                else if(typeSearch.equals('INVOICING')){
                    searchFilter = ' AND (SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate) + ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate) + ')';
                } 
            }
        } 
        else if (!StringUtils.isEmpty(fromDate) && StringUtils.isEmpty(toDate)) {
            //searchFilter = ' AND Anken__r.SalesAccountedDate__c >= ' + fromDate ;
            if(typeSearch.equals('ETD')){
                searchFilter = ' AND Anken__r.ETD__c >= ' + String.valueOf(fromDate);
            }
            else if(typeSearch.equals('ETA')){
                searchFilter = ' AND Anken__r.ETA__c >= ' + String.valueOf(fromDate);
            }
            else if(typeSearch.equals('SHIPMENTORDER')){
                searchFilter = ' AND Anken__r.SalesAccountedDate__c >= ' + String.valueOf(fromDate);
            }
            else if(typeSearch.equals('INVOICING')){
                searchFilter = ' AND SalesAccountedDateInvoicing__c >= ' + String.valueOf(fromDate);
            }
        } 
        else if (!StringUtils.isEmpty(toDate) && StringUtils.isEmpty(fromDate)) {
            //searchFilter = ' AND Anken__r.SalesAccountedDate__c <= ' + toDate ;
            if(typeSearch.equals('ETD')){
                searchFilter = ' AND Anken__r.ETD__c <= ' + String.valueOf(toDate);
            }
            else if(typeSearch.equals('ETA')){
                searchFilter = ' AND Anken__r.ETA__c <= ' + String.valueOf(toDate);
            }
            else if(typeSearch.equals('SHIPMENTORDER')){
                searchFilter = ' AND Anken__r.SalesAccountedDate__c <= ' + String.valueOf(toDate);
            }
            else if(typeSearch.equals('INVOICING')){
                searchFilter = ' AND SalesAccountedDateInvoicing__c <= ' + String.valueOf(toDate);
            }
        }

        return searchFilter;
    }

    private String buildOrderByClause() {
        return ' ORDER BY Seikyusaki__r.Name, Anken__r.Name LIMIT 1000';
    }

    private String buildCustomIdCondition(String customerId) {
        if (!StringUtils.isEmpty(customerId)) {
            return ' AND Seikyusaki__c = \'' + StringUtils.escapeSingleQuotes(customerId) + '\'';
        }

        return '';
    }

    private String buildOptionCondition(String option) {
        String advancedFilter = '';
        if ('2'.equals(option)) {
            advancedFilter = ' AND Selling_Tatekae__c = false';
        } else if ('3'.equals(option)) {
            advancedFilter = ' AND Selling_Tatekae__c = true';
        }

        return advancedFilter;
    }

    private String buildTimeFrameCondition(String fromDate, String toDate) {
        String filter = '';

        if (!StringUtils.isEmpty(fromDate) && !StringUtils.isEmpty(toDate)) {
            filter = ' AND (Anken__r.SalesAccountedDate__c >= ' + fromDate;
            filter += ' AND Anken__r.SalesAccountedDate__c <= ' + toDate + ')';
        } else if (!StringUtils.isEmpty(fromDate)) {
            filter = ' AND Anken__r.SalesAccountedDate__c >= ' + fromDate ;
        } else if (!StringUtils.isEmpty(toDate)) {
            filter = ' AND Anken__r.SalesAccountedDate__c <= ' + toDate ;
        }

        return filter;
    }

    private String getExcludedShipmentRecordTypes() {
        String excludedRecordTypes = '';
        
        if(mapRecordTypes.get(Constants.QUOTATION_RT) != null){
            excludedRecordTypes += '\'' + mapRecordTypes.get(Constants.QUOTATION_RT) + '\',';
        }
        if(mapRecordTypes.get(Constants.OCEAN_EXPORT_LOCK_RT) != null){
            excludedRecordTypes += '\'' + mapRecordTypes.get(Constants.OCEAN_EXPORT_LOCK_RT) + '\',';
        }
        if(mapRecordTypes.get(Constants.AIR_EXPORT_LOCK_RT) != null){
            excludedRecordTypes += '\'' + mapRecordTypes.get(Constants.AIR_EXPORT_LOCK_RT) + '\',';
        }
        if(mapRecordTypes.get(Constants.AIR_IMPORT_LOCK_RT) != null){
            excludedRecordTypes += '\'' + mapRecordTypes.get(Constants.AIR_IMPORT_LOCK_RT) + '\',';
        }
        if(mapRecordTypes.get(Constants.OCEAN_IMPORT_LOCK_RT) != null){
            excludedRecordTypes += '\'' + mapRecordTypes.get(Constants.OCEAN_IMPORT_LOCK_RT) + '\',';
        }
        
        if(!String.isBlank(excludedRecordTypes)){
                    excludedRecordTypes = '(' + excludedRecordTypes.removeEnd(',') + ')';
                }

        return excludedRecordTypes;
    }

    private String getExcludedShipmentStatuses() {
        String excludedStatuses = '(\'' + PicklistReference.COMPLETED_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.ORIGINAL_INVOICE_ISSUED_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.IMPORT_ORIGINAL_INVOICE_AND_STATEMENT_OF_PAYMENT_ISSUED_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.TEMPORARY_UNLOCK_FOR_ACCOUNTING_PURPOSE_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.EXPORT_REVISED_INVOICE_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.EXPORT_PERMIT_INVOICE_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.IMPORT_REVISED_INVOICE_ISSUED_ST + '\'';
     //   excludedStatuses += ',\'' + PicklistReference.IMPORT_PERMIT_INVOICE_ISSUED_ST + '\'';
        excludedStatuses += ',\'' + PicklistReference.CANCELLED_ST + '\')';

        return excludedStatuses;
    }

    private String getIncludedCustomerTypes() {
        String includedTypes = '(\'' + PicklistReference.DOMESTIC_CUSTOMER_EXISTING + '\'';
        includedTypes += ',\'' + PicklistReference.DOMESTIC_CUSTOMER_NO_NEED_SALES + '\'';
        includedTypes += ',\'' + PicklistReference.DOMESTIC_CUSTOMER_FORWARDER + '\')';

        return includedTypes;
    }

    private void loadRecordTypes() {
        String objectName = Constants.NAMESPACE + 'CustomObject1__c';
        List<RecordType> recordTypes = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE SObjectType = :objectName AND IsActive = True
        ];
        for (RecordType rt : recordTypes) {
            mapRecordTypes.put(rt.DeveloperName, rt.Id);
        }
    }

    private String buildSTIDKey(AnkenMeisai__c record) {
        return 'Key' + record.Anken__r.Name + '-' + record.Anken__r.HBL_Number_Sea_Air__c + '-'
                + record.Anken__r.MBL_Number_Sea_Air__c + '-' + record.Anken__r.ETD__c + '-' + record.Anken__r.ETA__c;
    }
    
    private Decimal calculateSellingAmountUSD(AnkenMeisai__c record) {
        Decimal chargeUnit = (record.Suryo__c != null ? record.Suryo__c : 0);
        Decimal sellingUnitPrice = (record.SellTankaUSD__c != null ? record.SellTankaUSD__c : 0);

        return (chargeUnit * sellingUnitPrice);
    }

    private Decimal calculateSellingInTaxAmountUSD(AnkenMeisai__c record) {
        Decimal sellingAmount = calculateSellingAmountUSD(record);
        Decimal taxRatio = (record.TaxInitial__c != null ? record.TaxInitial__c : 0);
        Decimal taxAdjustment = (record.TAX_ADJUSTMENTSELL__c != null ? record.TAX_ADJUSTMENTSELL__c : 0);

        return (sellingAmount * (1 + taxRatio / 100) + taxAdjustment);
    }

    private Decimal calculateBuyingAmountUSD(AnkenMeisai__c record) {
        Decimal chargeUnit = (record.Suryo__c != null ? record.Suryo__c : 0);
        Decimal buyingUnitPrice = (record.BuyTankaUSD__c != null ? record.BuyTankaUSD__c : 0);
        Decimal taxRatio = (record.BuyTaxInitial__c != null ? record.BuyTaxInitial__c : 0);
        Decimal costAllocationMargin = (record.Cost_Allocation_Margin__c != null ? record.Cost_Allocation_Margin__c : 0);

        return (chargeUnit * buyingUnitPrice + costAllocationMargin/(1 + taxRatio));
    }

    private Decimal calculateBuyingInTaxAmountUSD(AnkenMeisai__c record) {
        Decimal buyingAMount = calculateBuyingAmountUSD(record);
        Decimal taxRatio = (record.BuyTaxInitial__c != null ? record.BuyTaxInitial__c : 0);
        Decimal taxAdjustment = (record.TAX_ADJUSTMENTSELL__c != null ? record.TAX_ADJUSTMENTSELL__c : 0);

        return (buyingAMount * (1 + taxRatio / 100) + taxAdjustment);
    }
    private DCB_ReportLineItem createLineItemCreditDebit(AnkenMeisai__c record, Account customer) {
        DCB_ReportLineItem wrapper = new DCB_ReportLineItem(customer.Name, customer.EnglishCompanyName__c, customer.Id);

        wrapper.hblId = record.Anken__c;
        wrapper.sisid = record.Anken__r.ID__c;
        wrapper.customerName = customer.Name;
        wrapper.wkid = record.Anken__r.Name;
        wrapper.invoiceNo = 'S' + record.Anken__r.WkInitial__c + record.Anken__r.Name
                + (record.Anken__r.QuotationVer__c != null ? '-' + record.Anken__r.QuotationVer__c : '');
        wrapper.shipNumber = record.Anken__r.Ship_number__c;
        wrapper.hblNo = record.Anken__r.HBL_Number_Sea_Air__c;
        wrapper.mblNo = record.Anken__r.MBL_Number_Sea_Air__c;
        wrapper.status = record.Anken__r.Status__c;
        wrapper.deadlinePaymentInvoice = record.Anken__r.DeadlineForPaymentOfInvoices__c;
        wrapper.deadlinePaymentExpense = record.Anken__r.DeadlineForPaymentOfExpense__c;
        wrapper.deliveryDate = record.Anken__r.DeliveryDate__c;
        wrapper.carton = record.Anken__r.carton__c;
        wrapper.etd = record.Anken__r.ETD__c;
        wrapper.eta = record.Anken__r.ETA__c;
        wrapper.salesAccountDate = record.SalesAccountedDate__c;
        wrapper.dueDatePayment = record.Anken__r.Field1__r.PaidDay__c;
        wrapper.dueDateAdvancePayment = record.Anken__r.Field1__r.PaidDayAdvance__c;
        wrapper.recordCount = 1;
        wrapper.stid = record.Anken__c;
        wrapper.remarks = record.Anken__r.SeikyusyoRemark__c;
        
        wrapper.suryo = (record.Suryo__c == null ? 0 : record.Suryo__c);
        wrapper.name = record.Name;
        wrapper.id = record.Id;
        wrapper.salesAccountedDateInvoicing = record.SalesAccountedDateInvoicing__c;
        wrapper.insatuyouSyohin = record.InsatuyouSyohin__c;
        wrapper.seikyusakiName = record.Seikyusaki__r.Name;
        wrapper.paymentToName = record.PaymentTo__r.Name;
        wrapper.description = record.Description__c;
        
        if(wrapper.customerName != wrapper.paymentToName){
            wrapper.credit = 0;
            wrapper.creditUSD = 0;
            wrapper.sumOfCredit = 0;
            wrapper.sumOfCreditUSD = 0;
            if(record.curr__c == 'VND'){
                wrapper.debit = (record.SellDifferentiation__c == null ? 0 : record.SellDifferentiation__c);
                wrapper.debitUSD = 0;
                wrapper.sumOfDebit = (record.SellDifferentiation__c == null ? 0 : record.SellDifferentiation__c);
                wrapper.sumOfDebitUSD = 0;
            }else{
                wrapper.debit = 0;
                wrapper.debitUSD = (record.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : record.UNPAID_BALANCE_OF_SELLING_USD__c);
                wrapper.sumOfDebit = 0;
                wrapper.sumOfDebitUSD = (record.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 : record.UNPAID_BALANCE_OF_SELLING_USD__c);
            }
        }
        else{
            if(record.CurrencyBuying__c == 'VND'){
                wrapper.credit = (record.BuyDifferentiation__c == null ? 0 : record.BuyDifferentiation__c);
                wrapper.creditUSD = 0;
                wrapper.sumOfCredit = (record.BuyDifferentiation__c == null ? 0 : record.BuyDifferentiation__c);
                wrapper.sumOfCreditUSD = 0;
            }else{
                wrapper.credit = 0;
                wrapper.creditUSD = (record.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : record.UNPAID_BALANCE_OF_BUYING_USD__c);
                wrapper.sumOfCredit = 0;
                wrapper.sumOfCreditUSD = (record.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 : record.UNPAID_BALANCE_OF_BUYING_USD__c);
            }
            
            wrapper.debit = 0;
            wrapper.debitUSD = 0;
            wrapper.sumOfDebit = 0;
            wrapper.sumOfDebitUSD = 0;
        }

        wrapper.balance = wrapper.debit - wrapper.credit;
        wrapper.balanceUSD = wrapper.debitUSD - wrapper.creditUSD;

        ////wrapper.debit = (record.PartnerDebitJPN__c == null ? 0 : record.PartnerDebitJPN__c);
        ////wrapper.debitUSD = (record.SellAmountUSD__c == null ? 0 : record.SellAmountUSD__c);
        //wrapper.debit = (record.SellInTaxAmountJPY__c == null ? 0 : record.SellInTaxAmountJPY__c);
        //wrapper.debitUSD = (record.SellInTaxAmount_USD__c == null ? 0 : record.SellInTaxAmount_USD__c);
        
        ////wrapper.sumOfDebit = (record.PartnerDebitJPN__c == null ? 0 : record.PartnerDebitJPN__c);
        //wrapper.sumOfDebit = wrapper.debit;
        //wrapper.sumOfBalance = wrapper.sumOfDebit - wrapper.sumOfCredit;
        ////wrapper.sumOfDebitUSD = (record.SellAmountUSD__c == null ? 0 : record.SellAmountUSD__c);
        //wrapper.sumOfDebitUSD = wrapper.debitUSD;
        //wrapper.sumOfBalanceUSD = wrapper.sumOfDebitUSD - wrapper.sumOfCreditUSD;

        //Decimal sellingAmountInclTax = Util.calculateSellingInTaxAmount(record);
        //wrapper.sumOfAmountSelling = sellingAmountInclTax;
        //wrapper.sumOfAmountBuying = (record.Nyukingaku__c != null ? record.Nyukingaku__c : 0); // buyingingAmountInclTax
        //wrapper.sumOfUnPaidBalance = sellingAmountInclTax - (record.Nyukingaku__c != null ? record.Nyukingaku__c : 0);//record.SellDifferentiation__c;
        
        //Decimal sellingAmountInclTaxUSD = calculateSellingAmountUSD(record);
        //Decimal buyingingAmountInclTaxUSD = calculateBuyingInTaxAmountUSD(record);
        //wrapper.sumOfAmountSellingUSD = sellingAmountInclTaxUSD;
        //wrapper.sumOfAmountBuyingUSD = (record.AMOUNT_PAID_SELLING_USD__c != null ? record.AMOUNT_PAID_SELLING_USD__c : 0); // buyingingAmountInclTaxUSD
        //wrapper.sumOfUnPaidBalanceUSD = sellingAmountInclTaxUSD - (record.AMOUNT_PAID_SELLING_USD__c != null ? record.AMOUNT_PAID_SELLING_USD__c : 0);
        
        return wrapper;
    }

    private DCB_ReportLineItem createWrapperRecord(AnkenMeisai__c record, String key) {
        DCB_ReportLineItem wrapper = new DCB_ReportLineItem(record.Seikyusaki__r.Name, record.Seikyusaki__r.EnglishCompanyName__c, key);

        wrapper.hblId = record.Anken__c;
        wrapper.sisid = record.Anken__r.ID__c;
        wrapper.customerName = record.Seikyusaki__r.Name;
        wrapper.wkid = record.Anken__r.Name;
        wrapper.invoiceNo = 'S' + record.Anken__r.WkInitial__c + record.Anken__r.Name
                + (record.Anken__r.QuotationVer__c != null ? '-' + record.Anken__r.QuotationVer__c : '');
        wrapper.shipNumber = record.Anken__r.Ship_number__c;
        wrapper.hblNo = record.Anken__r.HBL_Number_Sea_Air__c;
        wrapper.mblNo = record.Anken__r.MBL_Number_Sea_Air__c;
        wrapper.status = record.Anken__r.Status__c;
        wrapper.deadlinePaymentInvoice = record.Anken__r.DeadlineForPaymentOfInvoices__c;
        wrapper.deadlinePaymentExpense = record.Anken__r.DeadlineForPaymentOfExpense__c;
        wrapper.deliveryDate = record.Anken__r.DeliveryDate__c;
        wrapper.carton = record.Anken__r.carton__c;
        wrapper.etd = record.Anken__r.ETD__c;
        wrapper.eta = record.Anken__r.ETA__c;
        wrapper.salesAccountDate = record.SalesAccountedDate__c;
        wrapper.dueDatePayment = record.Anken__r.Field1__r.PaidDay__c;
        wrapper.dueDateAdvancePayment = record.Anken__r.Field1__r.PaidDayAdvance__c;
        wrapper.recordCount = 1;
        wrapper.stid = key;
        wrapper.remarks = record.Anken__r.SeikyusyoRemark__c;
        
        wrapper.suryo = (record.Suryo__c == null ? 0 : record.Suryo__c);
        wrapper.name = record.Name;
        wrapper.id = record.Id;
        wrapper.salesAccountedDateInvoicing = record.SalesAccountedDateInvoicing__c;
        wrapper.insatuyouSyohin = record.InsatuyouSyohin__c;
        wrapper.seikyusakiName = record.Seikyusaki__r.Name;
        wrapper.paymentToName = record.PaymentTo__r.Name;
        wrapper.description = record.Description__c;
        
        if(wrapper.customerName != wrapper.paymentToName){
            wrapper.credit = 0;
            wrapper.creditUSD = 0;
            wrapper.sumOfCredit = 0;
            wrapper.sumOfCreditUSD = 0;
        }
        else{
            //wrapper.credit = (record.PartnerCreditJPN__c == null ? 0 : record.PartnerCreditJPN__c);
            //wrapper.creditUSD = (record.BuyAmountUSD__c == null ? 0 : record.BuyAmountUSD__c);
            //wrapper.sumOfCredit = (record.PartnerCreditJPN__c == null ? 0 : record.PartnerCreditJPN__c);
            //wrapper.sumOfCreditUSD = (record.BuyAmountUSD__c == null ? 0 : record.BuyAmountUSD__c);
            wrapper.credit = (record.BuyInTaxAmountJPY__c == null ? 0 : record.BuyInTaxAmountJPY__c);
            wrapper.creditUSD = (record.BuyInTaxAmountUSD__c == null ? 0 : record.BuyInTaxAmountUSD__c);
            wrapper.sumOfCredit = (record.PartnerCreditJPN__c == null ? 0 : record.PartnerCreditJPN__c);
            wrapper.sumOfCreditUSD = (record.BuyAmountUSD__c == null ? 0 : record.BuyAmountUSD__c);
        }
        //wrapper.debit = (record.PartnerDebitJPN__c == null ? 0 : record.PartnerDebitJPN__c);
        //wrapper.debitUSD = (record.SellAmountUSD__c == null ? 0 : record.SellAmountUSD__c);
        wrapper.debit = (record.SellInTaxAmountJPY__c == null ? 0 : record.SellInTaxAmountJPY__c);
        wrapper.debitUSD = (record.SellInTaxAmount_USD__c == null ? 0 : record.SellInTaxAmount_USD__c);
        wrapper.balance = wrapper.debit - wrapper.credit;
        
        wrapper.balanceUSD = wrapper.debitUSD - wrapper.creditUSD;
        //wrapper.sumOfDebit = (record.PartnerDebitJPN__c == null ? 0 : record.PartnerDebitJPN__c);
        wrapper.sumOfDebit = wrapper.debit;
        wrapper.sumOfBalance = wrapper.sumOfDebit - wrapper.sumOfCredit;
        //wrapper.sumOfDebitUSD = (record.SellAmountUSD__c == null ? 0 : record.SellAmountUSD__c);
        wrapper.sumOfDebitUSD = wrapper.debitUSD;
        wrapper.sumOfBalanceUSD = wrapper.sumOfDebitUSD - wrapper.sumOfCreditUSD;

        Decimal sellingAmountInclTax = Util.calculateSellingInTaxAmount(record);
        wrapper.sumOfAmountSelling = sellingAmountInclTax;
        wrapper.sumOfAmountBuying = (record.Nyukingaku__c != null ? record.Nyukingaku__c : 0); // buyingingAmountInclTax
        wrapper.sumOfUnPaidBalance = sellingAmountInclTax - (record.Nyukingaku__c != null ? record.Nyukingaku__c : 0);//record.SellDifferentiation__c;
        
        Decimal sellingAmountInclTaxUSD = calculateSellingAmountUSD(record);
        Decimal buyingingAmountInclTaxUSD = calculateBuyingInTaxAmountUSD(record);
        wrapper.sumOfAmountSellingUSD = sellingAmountInclTaxUSD;
        wrapper.sumOfAmountBuyingUSD = (record.AMOUNT_PAID_SELLING_USD__c != null ? record.AMOUNT_PAID_SELLING_USD__c : 0); // buyingingAmountInclTaxUSD
        wrapper.sumOfUnPaidBalanceUSD = sellingAmountInclTaxUSD - (record.AMOUNT_PAID_SELLING_USD__c != null ? record.AMOUNT_PAID_SELLING_USD__c : 0);
        
        return wrapper;
    }
}