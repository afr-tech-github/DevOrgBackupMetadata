@isTest
private class SOAReportNewController1Test {
    private static List<Account> listAccount = new List<Account>();
    private static CustomObject1__c shipment{get; set;}
    private static TariffMaster__c tariff{get; set;}
	static{
		// turn off trigger
		Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
        FlsService.doInsert(config);
		// tao account
		// 
		Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST',
            'LocalCurrencyBankAccountShortName1__c' => 'Bank 1',
            'LocalCurrencyBankAccountShortName2__c' => 'Bank 2',
            'LocalCurrencyBankAccountShortName3__c' => 'Bank 3',
            'LocalCurrencyBankAccountShortName4__c' => 'Bank 4',
            'LocalCurrencyBankAccountShortName5__c' => 'Bank 5',
            'FCYBankAccountShortName1__c' => 'Bank Foreign 1',
            'FCYBankAccountShortName2__c' => 'Bank Foreign 2',
            'FCYBankAccountShortName3__c' => 'Bank Foreign 3',
            'FCYBankAccountShortName4__c' => 'Bank Foreign 4',
            'FCYBankAccountShortName5__c' => 'Bank Foreign 5'
        };
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        listAccount = createAccounts();
		// tao shipment order ocean report
		String shipmentOceanReportRec = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get('RecordType').getRecordTypeId();
		// create warehouse
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => listAccount[0].Id, 
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
		// create M B/L SHIPMENT
        additionalFields = new Map<String, Object> {'MLoadLocation__c' => warehouse.Id, 'MBookingNv__c' => listAccount[0].Id, 'MCBM__c' => 2};
        MasterAnken__c mblShipment = (MasterAnken__c) TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mblShipment.Id, 'BuyTankaJPY__c' => 1000, 'Suryo__c' => 1,
            										'BuyTankaUSD__c' => 100, 'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'};
        MasterAnkenMeisai__c masterMeisai = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);

		// create h B/L SHIPMENT        
		additionalFields = new Map<String, Object> {'Field1__c' => listAccount[0].Id, 'CBM__c' => 1,
            										'Status__c' => '輸入 税関審査終了(Cunstoms Declared)',
            										'LoadLocation__c' => warehouse.Id, 'BookingNv__c' => listAccount[0].Id,
            										'RecordTypeId' => shipmentOceanReportRec , 'MasterAnkenName__c' => mblShipment.Id};
        shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service                
        additionalFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
             									'Supplier__c' => listAccount[0].Id,
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true};
		tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);      
        List<AnkenMeisai__c> listbilling =  createBilling(listAccount, tariff.Id, mblShipment.Id, masterMeisai.Id, shipment.Id);
		// tao billing
	}
	@isTest static void test_method_initiation() {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/page_SOAReportNew1'));
        ApexPages.currentPage().getParameters().put('showWKID', 'true');
        ApexPages.currentPage().getParameters().put('InvoiceDebit', 'true');
        ApexPages.currentPage().getParameters().put('showJobId', 'true');
        
        ApexPages.currentPage().getParameters().put('ankenIds', 'unit test');
      	ApexPages.currentPage().getParameters().put('language', 'vi');
        //ApexPages.currentPage().getParameters().put('condition', 'ETA');
        //ApexPages.currentPage().getParameters().put('condition', 'SHIPMENTORDER');
        //ApexPages.currentPage().getParameters().put('condition', 'INVOICING');
        //ApexPages.currentPage().getParameters().put('condition', 'SALES ACCOUNTED DATE (SHIPMENT ORDER)');
        //ApexPages.currentPage().getParameters().put('condition', 'SALES ACCOUNTED DATE (INVOICING)');
      
        ApexPages.currentPage().getParameters().put('clientId', listAccount[0].Id);
		SOAReportNewController1 ctrl = new SOAReportNewController1();
        
        List<SelectOption> accountList = ctrl.getAccountList();
        List<SelectOption> currencies = ctrl.getCurrencies();
        List<SelectOption> searchconditions = ctrl.getSearchConditions();
        
        List<SelectOption> reportTypes = ctrl.getReportTypes();
        List<SelectOption> getAdShipment = ctrl.getAdvancePaymentTypes();
        Map<String, String> translations = ctrl.getTranslations();
        List<SelectOption> language = ctrl.getLanguages();
        List<SelectOption> optionBanks = ctrl.getBankOptions();
        ctrl.onChangeType();
        ctrl.reportType  = 'partner_report_type';
        ctrl.onChangeType();
        ctrl.reportType  = 'vender_report_type';
        ctrl.onChangeType();
        ctrl.reportType  = 'custommer_report_type';
        ctrl.onChangeType();
        ctrl.reportType = 'customer_credit_debit_report_type';
        ctrl.onChangeType();
        ctrl.sFromDate = '2019/04/09';
        ctrl.sToDate = '2019/04/09';
        ctrl.onChangeDateFrom();
        ctrl.onChangeDateTo();
        System.assert(ctrl.sFromDate != null);
                //ApexPages.currentPage().getParameters().put('condition', 'ETA');
        //ApexPages.currentPage().getParameters().put('condition', 'SHIPMENTORDER');
        //ApexPages.currentPage().getParameters().put('condition', 'INVOICING');
        //ApexPages.currentPage().getParameters().put('condition', 'SALES ACCOUNTED DATE (SHIPMENT ORDER)');
        //ApexPages.currentPage().getParameters().put('condition', 'SALES ACCOUNTED DATE (INVOICING)');
        Test.stopTest();
	}
    	@isTest static void unitTest1() {
        Account account = new Account(
        	clofor_com_cfs__Field1__c = '立替',
            Name = 'Unit Test'
        );
        insert account;
		clofor_com_cfs__CustomObject1__c customer = new clofor_com_cfs__CustomObject1__c(
        	clofor_com_cfs__Field1__c = account.Id
        );
        insert customer;
        clofor_com_cfs__AnkenMeisai__c  anken = new clofor_com_cfs__AnkenMeisai__c (
        	clofor_com_cfs__Anken__c  = customer.Id
        );
        insert anken;
 		SOAReportNewController1.ReportBillingItemWrapper reportBillingItemWapper = new  SOAReportNewController1.ReportBillingItemWrapper();
        SOAReportNewController1.ReportBillingItemWrapper reportBillingItemWappers = new  SOAReportNewController1.ReportBillingItemWrapper(
        	anken,
            account.Id, 
            'TestLanguage', 
            'TestCurrencyType'
        );
        
	}

    @isTest static void test_method_generateReport() {
        Test.startTest();
        SOAReportNewController1 ctrl = new SOAReportNewController1();
        ctrl.accountId = listAccount[0].Id;
        ctrl.generateReport();
        ApexPages.currentPage().getParameters().put('id'   , listAccount[0].Id);
        System.assert(ctrl.accountId != null);
        Test.stopTest();
    }
	
	//@isTest static void test_method_two() {
	//	// Implement test code
	//}

    private static List<Account> createAccounts(){
        List<Account> lst = new List<Account>();
        Account accountVender = new Account(
            Name = 'Account vender',
            EnglishCompanyName__c = 'Account vender',
            Business_Relationship__c = '3rd Vendor');
        Account accountPartner = new Account(
            Name = 'Account Partner',
            EnglishCompanyName__c = 'Account Partner',
            Business_Relationship__c = 'Partner');
        Account accountCustomer = new Account(
            Name = 'Account Customer',
            EnglishCompanyName__c = 'Account Customer',
            Business_Relationship__c = 'Customer');
        lst.add(accountVender);
        lst.add(accountPartner);
        lst.add(accountCustomer);
        FlsService.doInsert(lst);
        return lst;
    }

    private static List<AnkenMeisai__c> createBilling(List<Account> accounts, String tariffId, 
                                                            String mblShipmentId,String masterMeisaiId,String shipmentId){
        List<AnkenMeisai__c> createBilling = new List<AnkenMeisai__c>();
        // create H B/L Selling/Buying
        for(integer i = 0; i < 6; i++){
            AnkenMeisai__c meisai = new AnkenMeisai__c(
                Anken__c= shipmentId, 
                curr__c = 'VND',
                CurrencyBuying__c = 'USD', 
                SerchSyubetu__c = 'FCL輸入',
                Tariff__c = tariffId,
                AM_MasterMeisaiID__c = masterMeisaiId,
                AM_MasterID__c = mblShipmentId, 
                Cost_Allocation_Catetory__c = 'Partner Cost allocation',
                Siharaigaku__c = 1,
                Suryo__c = 10,
                BuyTankaJPY__c = 2,
                Cost_Allocation_Margin__c = 1,
                BuyTaxInitial__c = 10,
                BuyTankaUSD__c = 4,
                Cost_Allocation_Margin_USD__c = 1,
                AMOUNT_PAID_BUYING_USD__c = 1,
                SellTankaJPY__c =10, 
                TaxInitial__c = 10, 
                Nyukingaku__c = 1,
                SellTankaUSD__c  = 10,
                AMOUNT_PAID_SELLING_USD__c = 1
            );
            if(i < 2){
                //meisai.PaymentTo__c = accounts[0].Id;
                meisai.Seikyusaki__c = accounts[1].Id;
                  
            }
            if(i >= 2 && i < 4){
                //meisai.PaymentTo__c = accounts[1].Id;
                meisai.Seikyusaki__c = accounts[2].Id;
            }
            if(i >= 4 && i < 6){
                //meisai.PaymentTo__c = accounts[2].Id;
                meisai.Seikyusaki__c = accounts[1].Id;
            }
            if(i == 6){
                //meisai.PaymentTo__c = accounts[1].Id;
                meisai.Seikyusaki__c = accounts[0].Id;
            }
            createBilling.add(meisai);
        }
        FlsService.doInsert(createBilling);
        return createBilling;
    }
	
}