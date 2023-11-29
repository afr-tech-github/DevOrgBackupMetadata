public with sharing class MassInvoicingUpdateController {
    public InvoicingWrapper wrapper { get; private set; }
    public Map<String, String> translations { get; private set; }
    public String userLanguage { get; private set; }
    public List<SelectOption> actioningOptions { get; private set; }
    public String selectedActioningOption { get; set; }
    public List<SelectOption> transactionOptions { get; private set; }
    public String selectedTransactionOption { get; set; }
    public String operation { get; private set; }
    public Boolean isCreation { get; set; }
    public String numberOfRecords { get; set; }

    private String parentId;
    private Boolean isShipmentOrder;
    private Boolean isConsol;
    private Boolean isConsolBuying;
    private static List<String> fields = new List<String>();
    private List<AnkenMeisai__c> backUpHBLSBList;

    public MassInvoicingUpdateController() {
        userLanguage = UserInfo.getLanguage();
        wrapper = new InvoicingWrapper();
        buidQueryField();
        getParameters();
        initializeTranslation();
        setupOptions();

        if (!isCreation) {
            if (PermissionValidationUtil.isAccessibleHBLBuying() && PermissionValidationUtil.isEditableHBLBuying()) {
                searchInvoicing();

                if (wrapper.lstHBLSB != null && !wrapper.lstHBLSB.isEmpty()) {
                    backUpHBLSBList = wrapper.lstHBLSB.clone();
                }
            }
        }
    }

    private void setupOptions() {
        final String option = ApexPages.currentPage().getParameters().get('option');
        final String action = ApexPages.currentPage().getParameters().get('action');

        if (!StringUtils.isEmpty(option)) {
            if ('rp'.equalsIgnoreCase(option)) {
                setupReceivablePayableOptions();
                operation = 'receivable_payable';
            }
        } else {
            setupSellingBuyingOptions();
            operation = 'selling_buying';
        }

        if (String.isNotBlank(action) && 'new'.equalsIgnoreCase(action)) {
            isCreation = true;
        } else {
            isCreation = false;
        }
    }

    private void setupSellingBuyingOptions() {
        actioningOptions = new List<SelectOption>();
        if (!Test.isRunningTest()) {
            if (isShipmentOrder) {
                actioningOptions.add(new SelectOption('selling', translations.get('UPDATE_SELLING_FIGURE')));
                selectedActioningOption = 'selling';
            } else {
                selectedActioningOption = 'buying';
            }
            actioningOptions.add(new SelectOption('buying', translations.get('UPDATE_BUYING_FIGURE')));
        }
    }

    private void setupReceivablePayableOptions() {
        transactionOptions = new List<SelectOption>();
        if (isShipmentOrder) {
            transactionOptions.add(new SelectOption('receivable', translations.get('RECEIVABLE_PROCESSING')));
            selectedTransactionOption = 'receivable';
        } else {
            selectedTransactionOption = 'payable';
        }
        transactionOptions.add(new SelectOption('payable', translations.get('PAYABLE_PROCESSING')));
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('MassiveUpdate', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    private void getParameters() {
        parentId = ApexPages.currentPage().getParameters().get('id');
        String prefixKey = ((String.isNotBlank(parentId) && parentId.length() >= 15) ? parentId.left(3) : '');
        isShipmentOrder = false;
        isConsol = false;
        isConsolBuying = false;

        if (prefixKey.equalsIgnoreCase(ObjectClassificationUtils.getObjectTypeId(Constants.NAMESPACE + 'CustomObject1__c'))) {
            isShipmentOrder = true;
        } else if (prefixKey.equalsIgnoreCase(ObjectClassificationUtils.getObjectTypeId(Constants.NAMESPACE + 'MasterAnken__c'))) {
            isConsol = true;
        } else if (prefixKey.equalsIgnoreCase(ObjectClassificationUtils.getObjectTypeId(Constants.NAMESPACE + 'MasterAnkenMeisai__c'))) {
            isConsolBuying = true;
        }
    }

    private void searchInvoicing() {
        String query = null;

        if (isShipmentOrder) {
            query = 'SELECT ' + String.join(fields, ',') + ' FROM AnkenMeisai__c WHERE Anken__c = \'' + StringUtils.escapeSingleQuotes(parentId) + '\' ORDER BY SeikyuBangou__c ASC';
        } else if (isConsol) {
            query = 'SELECT ' + String.join(fields, ',') + ' FROM AnkenMeisai__c WHERE AM_MasterID__c = \'' + StringUtils.escapeSingleQuotes(parentId) + '\' ORDER BY SeikyuBangou__c ASC';
        } else if (isConsolBuying) {
            query = 'SELECT ' + String.join(fields, ',') + ' FROM AnkenMeisai__c WHERE AM_MasterMeisaiID__c = \'' + StringUtils.escapeSingleQuotes(parentId) + '\' ORDER BY SeikyuBangou__c ASC';
        }

        List<AnkenMeisai__c> lstHBLSB = Database.query(query);
        wrapper.setSHBSBList(lstHBLSB);
    }

    private PageReference gotoHBLShipment() {
        PageReference page = null;

        if (!StringUtils.isEmpty(parentId)) {
            page = new PageReference('/' + parentId);
            page.setRedirect(true);
        }

        return page;
    }

    public void createNewRecords() {
        if (isCreation && String.isNotBlank(numberOfRecords) && numberOfRecords.isNumeric() && Integer.valueOf(numberOfRecords) > 0) {
            Integer numOfRecords = Integer.valueOf(numberOfRecords);
            Integer numOfExistingRecords = wrapper.lstHBLSB.size();

            if (numOfExistingRecords > 0) {
                numOfRecords -= numOfExistingRecords;
            }

            if (numOfRecords > 0) {
                List<AnkenMeisai__c> lstHBLSB = new List<AnkenMeisai__c>();

                for (Integer i = 0; i < numOfRecords; i++) {
                    AnkenMeisai__c invoicing = new AnkenMeisai__c();

                    if (isShipmentOrder) {
                        invoicing.Anken__c = parentId;
                    } else if (isConsol) {
                        invoicing.AM_MasterID__c = parentId;
                    } else if (isConsolBuying) {
                        invoicing.AM_MasterMeisaiID__c = parentId;
                    }

                    lstHBLSB.add(invoicing);
                }

                wrapper.lstHBLSB.addAll(lstHBLSB);
            } else {
                numOfRecords *= (-1);

                if (numOfRecords <= numOfExistingRecords) {
                    for (Integer i = 0; i < numOfRecords; i++) {
                        wrapper.lstHBLSB.remove(numOfExistingRecords - i - 1);
                    }
                }
            }
        }
    }

    public PageReference updateInvoicing() {
        if (isCreation) {
            if (PermissionValidationUtil.isCreatableHBLBuying()) {
                try {
                    FlsService.doinsert(wrapper.lstHBLSB);

                    if (!StringUtils.isEmpty(parentId)) {
                        return gotoHBLShipment();
                    }
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient Permission. Please contact system administrator'));
            }
        } else {
            if (PermissionValidationUtil.isEditableHBLBuying()) {
                try {
                    FlsService.doupdate(wrapper.lstHBLSB);

                    if (!StringUtils.isEmpty(parentId)) {
                        return gotoHBLShipment();
                    }
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient Permission. Please contact system administrator'));
            }
        }

        return null;
    }

    public PageReference cancel() {
        return gotoHBLShipment();
    }

    class InvoicingWrapper {
        public List<AnkenMeisai__c> lstHBLSB {
            get;
            private set;
        }
        public Decimal sumOfTotalAmountOfSellingLocal {
            get;
            private set;
        }
        public Decimal sumOfAmountOfTaxSellingLocal {
            get;
            private set;
        }
        public Decimal sumOfAmountSellingIncludingTaxLocal {
            get;
            private set;
        }
        public Decimal sumOfTotalAmountOfSelling {
            get;
            private set;
        }
        public Decimal sumOfAmountOfTaxSelling {
            get;
            private set;
        }
        public Decimal sumOfAmountSellingIncludingTax {
            get;
            private set;
        }
        public Decimal sumOfTotalAmountOfBuyingLocal {
            get;
            private set;
        }
        public Decimal sumOfAmountOfTaxBuyingLocal {
            get;
            private set;
        }
        public Decimal sumOfAmountBuyingIncludingTaxLocal {
            get;
            private set;
        }
        public Decimal sumOfTotalAmountOfBuying {
            get;
            private set;
        }
        public Decimal sumOfAmountOfTaxBuying {
            get;
            private set;
        }
        public Decimal sumOfAmountBuyingIncludingTax {
            get;
            private set;
        }
        public Decimal sumOfUnpaidBalanceOfBuyingLocal {
            get;
            private set;
        }
        public Decimal sumOfUnpaidBalanceOfBuying {
            get;
            private set;
        }
        public Decimal sumOfAmountReceivedFromCustomerLocal {
            get;
            private set;
        }
        public Decimal sumOfAmountReceivedFromCustomer {
            get;
            private set;
        }
        public Decimal sumOfAmountPaidBuyingLocal {
            get;
            private set;
        }
        public Decimal sumOfAmountPaidBuying {
            get;
            private set;
        }
        public Decimal sumOfUnreceivedBalanceOfSellingLocal {
            get;
            private set;
        }
        public Decimal sumOfUnreceivedBalanceOfSelling {
            get;
            private set;
        }

        public InvoicingWrapper() {
            lstHBLSB = new List<AnkenMeisai__c>();
            sumOfTotalAmountOfSellingLocal = 0;
            sumOfAmountOfTaxSellingLocal = 0;
            sumOfAmountSellingIncludingTaxLocal = 0;
            sumOfTotalAmountOfSelling = 0;
            sumOfAmountOfTaxSelling = 0;
            sumOfAmountSellingIncludingTax = 0;

            sumOfTotalAmountOfBuyingLocal = 0;
            sumOfAmountOfTaxBuyingLocal = 0;
            sumOfAmountBuyingIncludingTaxLocal = 0;
            sumOfTotalAmountOfBuying = 0;
            sumOfAmountOfTaxBuying = 0;
            sumOfAmountBuyingIncludingTax = 0;

            sumOfUnpaidBalanceOfBuyingLocal = 0;
            sumOfUnpaidBalanceOfBuying = 0;
            sumOfAmountReceivedFromCustomerLocal = 0;
            sumOfAmountReceivedFromCustomer = 0;

            sumOfAmountPaidBuyingLocal = 0;
            sumOfAmountPaidBuying = 0;
            sumOfUnreceivedBalanceOfSellingLocal = 0;
            sumOfUnreceivedBalanceOfSelling = 0;
        }

        public void setSHBSBList(List<AnkenMeisai__c> lstHBLSB) {
            this.lstHBLSB = lstHBLSB;

            if (lstHBLSB != null && !lstHBLSB.isEmpty()) {
                for (AnkenMeisai__c hblsb : lstHBLSB) {
                    sumOfTotalAmountOfSellingLocal += NumbericUtils.toDecimal(hblsb.SellAmountJPN__c);
                    sumOfAmountOfTaxSellingLocal += NumbericUtils.toDecimal(hblsb.SellTaxNum__c);
                    sumOfAmountSellingIncludingTaxLocal += NumbericUtils.toDecimal(hblsb.SellInTaxAmountJPY__c);
                    sumOfTotalAmountOfSelling += NumbericUtils.toDecimal(hblsb.SellAmountUSD__c);
                    sumOfAmountOfTaxSelling += NumbericUtils.toDecimal(hblsb.SellTaxNum_USD__c);
                    sumOfAmountSellingIncludingTax += NumbericUtils.toDecimal(hblsb.SellInTaxAmount_USD__c);

                    sumOfTotalAmountOfBuyingLocal += NumbericUtils.toDecimal(hblsb.BuyAmountJPN__c);
                    sumOfAmountOfTaxBuyingLocal += NumbericUtils.toDecimal(hblsb.BuyTaxNum__c);
                    sumOfAmountBuyingIncludingTaxLocal += NumbericUtils.toDecimal(hblsb.BuyInTaxAmountJPY__c);
                    sumOfTotalAmountOfBuying += NumbericUtils.toDecimal(hblsb.BuyAmountUSD__c);
                    sumOfAmountOfTaxBuying += NumbericUtils.toDecimal(hblsb.BuyTaxNum_USD__c);
                    sumOfAmountBuyingIncludingTax += NumbericUtils.toDecimal(hblsb.BuyInTaxAmountUSD__c);

                    sumOfUnreceivedBalanceOfSellingLocal += NumbericUtils.toDecimal(hblsb.SellDifferentiation__c);
                    sumOfUnreceivedBalanceOfSelling += NumbericUtils.toDecimal(hblsb.UNPAID_BALANCE_OF_SELLING_USD__c);
                    sumOfAmountReceivedFromCustomerLocal += NumbericUtils.toDecimal(hblsb.Nyukingaku__c);
                    sumOfAmountReceivedFromCustomer += NumbericUtils.toDecimal(hblsb.AMOUNT_PAID_SELLING_USD__c);

                    sumOfUnpaidBalanceOfBuyingLocal += NumbericUtils.toDecimal(hblsb.BuyDifferentiation__c);
                    sumOfUnpaidBalanceOfBuying += NumbericUtils.toDecimal(hblsb.UNPAID_BALANCE_OF_BUYING_USD__c);
                    sumOfAmountPaidBuyingLocal += NumbericUtils.toDecimal(hblsb.Siharaigaku__c);
                    sumOfAmountPaidBuying += NumbericUtils.toDecimal(hblsb.AMOUNT_PAID_BUYING_USD__c);
                }
            }
        }
    }

    private void buidQueryField(){

        fields.add('Id');
        fields.add('Name');
        fields.add('SeikyuBangou__c');
        fields.add('curr__c');
        fields.add('Tariff__c');
        fields.add('InsatuyouSyohinEng__c');
        fields.add('InsatuyouSyohin__c');
        fields.add('Suryo__c');
        fields.add('PrintFlag__c');

// SELLING fields
        fields.add('Seikyusaki__c');
        fields.add('KawaseSel__c');
        fields.add('TaxInitial__c');
        fields.add('SellTankaUSD__c');
        fields.add('SellTankaJPY__c');
        fields.add('SellAmountJPN__c');
        fields.add('SellTaxNum__c');
        fields.add('SellInTaxAmountJPY__c');
        fields.add('SellAmountUSD__c');
        fields.add('SellTaxNum_USD__c');
        fields.add('SellInTaxAmount_USD__c');

// BUYING fields
        fields.add('KawaseBay__c');
        fields.add('PaymentTo__c');
        fields.add('BuyTaxInitial__c');
        fields.add('BuyTankaJPY__c');
        fields.add('BuyTankaUSD__c');
        fields.add('BuyAmountJPN__c');
        fields.add('BuyTaxNum__c');
        fields.add('BuyInTaxAmountJPY__c');
        fields.add('BuyAmountUSD__c');
        fields.add('BuyTaxNum_USD__c');
        fields.add('BuyInTaxAmountUSD__c');
        fields.add('ProductTax__c');

// Receivable Processing
        fields.add('Payer__c');
        fields.add('NyukinKakuninzumi__c');
        fields.add('ReceiptanceDate_del__c');
        fields.add('BANKTRANSITTYPE__c');
        fields.add('ReceivingBank__c');
        fields.add('SellDetail__c');
        fields.add('Nyukingaku__c');
        fields.add('AMOUNT_PAID_SELLING_USD__c');
        fields.add('SellDifferentiation__c');
        fields.add('UNPAID_BALANCE_OF_SELLING_USD__c');
        fields.add('BankAccountForPayment__c');

// Payable Processing
        fields.add('actual_payer__c');
        fields.add('SiharaiKakuninzumi__c');
        fields.add('PaymentDate__c');
        fields.add('payment_category__c');
        fields.add('PayingBank__c');
        fields.add('BuyDetail__c');
        fields.add('Siharaigaku__c');
        fields.add('AMOUNT_PAID_BUYING_USD__c');
        fields.add('BuyDifferentiation__c');
        fields.add('UNPAID_BALANCE_OF_BUYING_USD__c');
        fields.add('BankAccountForReceiving__c');
    }

    static {
       /* fields.add('Id');
        fields.add('Name');
        fields.add('SeikyuBangou__c');
        fields.add('curr__c');
        fields.add('Tariff__c');
        fields.add('InsatuyouSyohinEng__c');
        fields.add('InsatuyouSyohin__c');
        fields.add('Suryo__c');

// SELLING fields
        fields.add('Seikyusaki__c');
        fields.add('KawaseSel__c');
        fields.add('TaxInitial__c');
        fields.add('SellTankaUSD__c');
        fields.add('SellTankaJPY__c');
        fields.add('SellAmountJPN__c');
        fields.add('SellTaxNum__c');
        fields.add('SellInTaxAmountJPY__c');
        fields.add('SellAmountUSD__c');
        fields.add('SellTaxNum_USD__c');
        fields.add('SellInTaxAmount_USD__c');

// BUYING fields
        fields.add('KawaseBay__c');
        fields.add('PaymentTo__c');
        fields.add('BuyTaxInitial__c');
        fields.add('BuyTankaJPY__c');
        fields.add('BuyTankaUSD__c');
        fields.add('BuyAmountJPN__c');
        fields.add('BuyTaxNum__c');
        fields.add('BuyInTaxAmountJPY__c');
        fields.add('BuyAmountUSD__c');
        fields.add('BuyTaxNum_USD__c');
        fields.add('BuyInTaxAmountUSD__c');
        fields.add('ProductTax__c');

// Receivable Processing
        fields.add('Payer__c');
        fields.add('NyukinKakuninzumi__c');
        fields.add('ReceiptanceDate_del__c');
        fields.add('BANKTRANSITTYPE__c');
        fields.add('ReceivingBank__c');
        fields.add('SellDetail__c');
        fields.add('Nyukingaku__c');
        fields.add('AMOUNT_PAID_SELLING_USD__c');
        fields.add('SellDifferentiation__c');
        fields.add('UNPAID_BALANCE_OF_SELLING_USD__c');
        fields.add('BankAccountForPayment__c');

// Payable Processing
        fields.add('actual_payer__c');
        fields.add('SiharaiKakuninzumi__c');
        fields.add('PaymentDate__c');
        fields.add('payment_category__c');
        fields.add('PayingBank__c');
        fields.add('BuyDetail__c');
        fields.add('Siharaigaku__c');
        fields.add('AMOUNT_PAID_BUYING_USD__c');
        fields.add('BuyDifferentiation__c');
        fields.add('UNPAID_BALANCE_OF_BUYING_USD__c');
        fields.add('BankAccountForReceiving__c');
        */

    }
}