/**
* ClassName:   page_QuotationPrintPdfCtrlTest
* Description: page Quotation Print Pdf Ctrl Test
* @created:    2022/10/26 Truong Lai
* @modified:
*/
@isTest(SeeAllData=false)
public with sharing class page_QuotationPrintPdfCtrlTest {
    private static User userTest = createUser();

    @IsTest
    static void testMethodInitData(){
        System.runAs(userTest){
            Account customer = createAccountCompany('Customer service');
            clofor_com_cfs__Quote__c q = createQuote();
            List<clofor_com_cfs__QuoteLine__c> listLineItem = new List<clofor_com_cfs__QuoteLine__c>();
            
            String quoteId = q.Id;
            String comReq = customer.Id;
            String printSection = '1st Section';
            String itemName = 'CUSTOM CLEARANCE';
            String unit;
            for (Integer i = 1; i < 15; i++) {
                unit = '+'+String.valueOf(i*1000)+'KGS';
                if (i == 7) {
                    printSection = '2nd Section';
                    unit = '1000KGS';
                }
                clofor_com_cfs__QuoteLine__c ql = createQuoteLineItem(quoteId, printSection, itemName, unit, comReq, false);
                listLineItem.add(ql);
            }

            insert listLineItem;

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', quoteId);
            page_QuotationPrintPdfCtrl ctrl = new page_QuotationPrintPdfCtrl();
            ctrl.quoterRemarks = 'Remark testing';
            page_QuotationPrintPdfCtrl.ChargeUnitWrapper ChargeUnit = new page_QuotationPrintPdfCtrl.ChargeUnitWrapper();
            Test.stopTest();
            System.assertEquals(true, quoteId != null);
        }
    }

    private static clofor_com_cfs__Quote__c createQuote() {
        clofor_com_cfs__Quote__c sobj = new clofor_com_cfs__Quote__c(
            clofor_com_cfs__QuoteName__c = 'Steel Door',                                // Quote Name
            clofor_com_cfs__QuoteNumber__c = 'SD190213',                                // Quote Number
            clofor_com_cfs__QuoteStatus__c = 'Inquiry Received',                        // Quote Status
            clofor_com_cfs__SignandSignature__c = 'Assistant Genneral Manager',         // Sign and Signature
            clofor_com_cfs__TargetRate__c = '1550 USD/Steel Door',                      // Target Rate
            clofor_com_cfs__PaymentCondition__c = 'Payment once getting enough cargo',  // Payment Condition
            clofor_com_cfs__DescriptionOfGoods__c = 'Steel Door',                       // Description of Goods
            clofor_com_cfs__Quantity__c = 10,                                           // Cargo Quantity
            clofor_com_cfs__MeasurementCBM__c = 200,                                    // Measurement(CBM)
            clofor_com_cfs__Unit__c = 'Pallet',                                         // Cargo Unit
            clofor_com_cfs__GrossWeightKG__c = 2500,                                    // Gross Weight(Kg)
            clofor_com_cfs__NetWeightKG__c = 2000                                       // Net Weight(Kg)
        );
        insert sobj;
        return sobj;
    }

    private static clofor_com_cfs__QuoteLine__c createQuoteLineItem(String quoteId, String printSection, String itemName, String unit, String comReq, Boolean isInsert) {
        clofor_com_cfs__QuoteLine__c sobj = new clofor_com_cfs__QuoteLine__c(
            clofor_com_cfs__Print__c = false,                           // Print
            clofor_com_cfs__QuoteID__c = quoteId,                       // Quote
            clofor_com_cfs__PrintingSection__c = printSection,          // Printing Section
            clofor_com_cfs__QuoteLineNumber__c = 1,                     // Quote Line Number
            clofor_com_cfs__Remarks__c = 'SET',                         // Remarks
            clofor_com_cfs__RequesterCompany__c = comReq,               // Requester Company
            clofor_com_cfs__Unit__c = 'Pallet',                         // Charge Unit
            clofor_com_cfs__Quantity__c = 10.000,                       // Charge Quantity
            clofor_com_cfs__ChargeUnitInPrint__c = unit,                // Charge Unit in Print
            clofor_com_cfs__LineItemName__c = itemName,                 // Line Item Name (Eng)
            clofor_com_cfs__CurrencySelling__c = 'VND',                 // Currency-Selling
            clofor_com_cfs__CurrencyBuying__c = 'VND',                  // Currency-Buying
            clofor_com_cfs__SellingListPriceLocal__c = 3.600,           // Selling List Price(Local)
            clofor_com_cfs__BuyingListPriceLocal__c = 1.200,            // Buying List Price(Local)
            clofor_com_cfs__SellingListPriceUSD__c = 100.000,           // Selling List Price(FCY)
            clofor_com_cfs__BuyingListPriceUSD__c = 2150.000,           // Buying List Price(FCY)
            clofor_com_cfs__DiscountRate__c = 0.00,                     // Selling Discount(%)
            clofor_com_cfs__TotalAmountSellingLocal__c = 36.000,        // Total Amount of Selling(Local)
            clofor_com_cfs__TotalAmountOfSellingUSD__c = 1000.000,      // Total Amount of Selling(FCY)
            clofor_com_cfs__TotalAmountBuyingLocal__c = 12.000,         // Total Amount of Buying(Local)
            clofor_com_cfs__TotalAmountOfBuyingUSD__c = 21500.000       // Total Amount of Buying(FCY)
        );
        if (isInsert) {
            insert sobj;
        }

        return sobj;
    }

    private static Account createAccountCompany(String customName){
        Account sobj = new Account(
            clofor_com_cfs__Business_Relationship__c = 'Customer',                               // Business Relationship
            Name = customName,                                                                   // Account Name
            clofor_com_cfs__TAX_CODE__c = '0315164481',                                          // Tax Code
            clofor_com_cfs__CustomerType__c = 'Enterprise',                                      // Customer Type
            clofor_com_cfs__EnglishAddress__c = '495 TO HIEN THANH STR, WARD 14, DISTRICT 10,',  // English Address
            clofor_com_cfs__mail__c = 'company@test-solutions.com'                               // Mail
        );
        insert sobj;
        return sobj;
    }

    private static User createUser() {
        // Profile
        Profile profile = [SELECT Id FROM Profile WHERE userType = 'standard' AND Name LIKE 'System Administrator' LIMIT 1];
        // Unique name
        String uniqueName = UserInfo.getOrganizationId()
                            + Datetime.now().format('yyyyMMddHHmmssSSS')
                            + Integer.valueOf(math.rint(math.random()* (2000000 - 1)));
        // User
        User user = new User (
            FirstName = uniqueName.subString(29, 34),
            LastName = uniqueName.subString(30, 35),
            Email = uniqueName + '@usertest.co.us',
            UserName = uniqueName + '@usertest.co.us',
            EmailEncodingKey = 'UTF-8',
            Alias = uniqueName.substring(29, 34),
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id,
            PostalCode = '123456789',
            Department = 'test',
            Phone = '123456789',
            Fax = '123456789',
            CompanyName  = 'testing service'
        );
        FlsService.doInsert(user);
        return user;
    }
}