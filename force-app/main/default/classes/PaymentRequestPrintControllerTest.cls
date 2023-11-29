@isTest
private class PaymentRequestPrintControllerTest {
    private static CustomObject1__c shipment{get; set;}
	private static List<VAT_INVOICE__c> vats = new List<VAT_INVOICE__c>();
	private static List<INVOICING_VAT__c> listBillVAT = new List<INVOICING_VAT__c>();
	private static PaymentRequest__c requestPayment{get;set;}
	private static List<AnkenMeisai__c> listbills = new List<AnkenMeisai__c>();
	private static AnkenMeisai__c bill3{get; set;}
	static{
		// turn off trigger
		Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
		FlsService.doInsert(config);
		RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING, 'BillingStreet' => 'Test Street', 'BillingCity' => 'Test City', 'BillingState' => 'Test State', 'BillingPostalCode' => '21342', 'BillingCountry' => 'Viet Nam'};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
         setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => false, 'AccountId' => account.Id};
        Contact partner = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);

        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 
            										'PartnerRep__c' => partner.Id, 'RecordTypeId' => rt.Id};
		shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields);
		FlsService.doInsert(shipment);
        CustomObject1__c shipment2 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields);
		FlsService.doInsert(shipment2);

        additionFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => account.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionFields);                                                                 
        additionFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id, 'PaymentTo__c' => account.Id, 'Seikyusaki__c' => account.Id,
            									'NyukinKakuninzumi__c' => false, 'Suryo__c' => 10, 'BuyTankaJPY__c' => 20,
                                                'Cost_Allocation_Margin__c' => 5, 'BuyTaxInitial__c' => 1,
                                                'BuyTankaUSD__c' => 20, 'Cost_Allocation_Margin_USD__c' => 5, 'Siharaigaku__c' => 5, 'AMOUNT_PAID_BUYING_USD__c' => 5};
		AnkenMeisai__c bill1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionFields);
        AnkenMeisai__c bill2 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionFields);
        AnkenMeisai__c bill3 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionFields);
		bill3.Anken__c = shipment2.Id;
		listbills.add(bill1);
		listbills.add(bill2);
        listbills.add(bill3);
		FlsService.doInsert(listbills);
		Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.SObjectType.VAT_INVOICE__c.getRecordTypeInfosByDeveloperName();

		VAT_INVOICE__c currentVAT1 = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('CloWMSVATInvoice').getRecordTypeId()
			);
		VAT_INVOICE__c currentVAT2 = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('FMSTMSWMSVATInvoice').getRecordTypeId()
			);
		VAT_INVOICE__c currentVAT3 = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('MULTIPLE_SHIPMENT_TO_1VAT_INVOICE_SUMMARY').getRecordTypeId()
			);
		VAT_INVOICE__c currentVAT4 = new VAT_INVOICE__c(
			RecordTypeId = recordTypeInfosMap.get('VendorVATInvoice').getRecordTypeId()
			);
		vats.add(currentVAT1);
		vats.add(currentVAT2);
		vats.add(currentVAT3);
		vats.add(currentVAT4);

		FlsService.doInsert(vats);
		INVOICING_VAT__c billVat1 = new INVOICING_VAT__c(
			VAT_INVOICE__c = vats[0].Id,
			INVOICING__c = listbills[0].Id
		);
		INVOICING_VAT__c billVat2 = new INVOICING_VAT__c(
			VAT_INVOICE__c = vats[1].Id,
			INVOICING__c = listbills[0].Id
		);

		INVOICING_VAT__c billVat3 = new INVOICING_VAT__c(
			VAT_INVOICE__c = vats[2].Id,
			INVOICING__c = listbills[0].Id
		);
		INVOICING_VAT__c billVat4 = new INVOICING_VAT__c(
			VAT_INVOICE__c = vats[3].Id,
			INVOICING__c = listbills[0].Id
		);
		listBillVAT.add(billVat1);
		listBillVAT.add(billVat2);
		listBillVAT.add(billVat3);
		listBillVAT.add(billVat4);
		FlsService.doInsert(listBillVAT);
		BankTransaction__c bank = new BankTransaction__c();
		FlsService.doInsert(bank);
    	Map<String, Schema.RecordTypeInfo> mapCashRecordTypeByDeveloperName = Schema.getGlobalDescribe().get('clofor_com_cfs__CASH_BOOK__c').getDescribe().getRecordTypeInfosByDeveloperName();

		CASH_BOOK__c cash = new CASH_BOOK__c(
			RecordTypeId = mapCashRecordTypeByDeveloperName.get('CashIn').getRecordTypeId()
		);
		FlsService.doInsert(cash);
		requestPayment = new PaymentRequest__c(
			RecordTypeId = Schema.SObjectType.PaymentRequest__c.getRecordTypeInfosByDeveloperName().get('PaymentRequestlocalCurrency').getRecordTypeId(),
			BankID__c = bank.Id,
			CashID__c = cash.Id,
            PaymentTo__c = account.Id
			);
		FlsService.doInsert(requestPayment);
        FMSBillPayReq__c billRequest1 = new FMSBillPayReq__c(
            FMSBillID__c = bill1.Id,
            PaymentRequestID__c = requestPayment.Id
        );
        FMSBillPayReq__c billRequest2 = new FMSBillPayReq__c(
            FMSBillID__c = bill2.Id,
            PaymentRequestID__c = requestPayment.Id
        );
        FMSBillPayReq__c billRequest3 = new FMSBillPayReq__c(
            FMSBillID__c = bill3.Id,
            PaymentRequestID__c = requestPayment.Id
        );
		FlsService.doInsert(new List<FMSBillPayReq__c>{billRequest1, billRequest2, billRequest3});
	}
    @isTest static void test_method_one() {
		
		Test.startTest();
			ApexPages.currentPage().getParameters().put('id',requestPayment.Id);
			PaymentRequestPrintController ctrl = new PaymentRequestPrintController();
            String totalPreTaxAmountStr = ctrl.total.getTotalPreTaxAmountStr();
            String totalVatAmountStr = ctrl.total.getTotalVatAmountStr();
            String totalAmountIncludeTaxStr = ctrl.total.getTotalAmountIncludeTaxStr();
            String totalPaidAmountStr = ctrl.total.getTotalPaidAmountStr();
            String totalUnpaidAmountStr = ctrl.total.getTotalUnpaidAmountStr();

            String PreTaxAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getAmountStr();
            String VatAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getAmountTaxStr();
            String AmountIncludeTaxStr = ctrl.listShippmentWrapper[0].listBilling[0].getAmountIncludeTaxStr();
            String PaidAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getPaidAmountStr();
            String UnpaidAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getUnpaidAmountStr();
            System.assert(requestPayment.Id != null);
		Test.stopTest();
	}

    @isTest static void test_method_2() {
		requestPayment.Currency__c = 'USD';
        FlsService.doUpdate(requestPayment);
		Test.startTest();
			ApexPages.currentPage().getParameters().put('id',requestPayment.Id);
			PaymentRequestPrintController ctrl = new PaymentRequestPrintController();
            String totalPreTaxAmountStr = ctrl.total.getTotalPreTaxAmountStr();
            String totalVatAmountStr = ctrl.total.getTotalVatAmountStr();
            String totalAmountIncludeTaxStr = ctrl.total.getTotalAmountIncludeTaxStr();
            String totalPaidAmountStr = ctrl.total.getTotalPaidAmountStr();
            String totalUnpaidAmountStr = ctrl.total.getTotalUnpaidAmountStr();

            String PreTaxAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getAmountStr();
            String VatAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getAmountTaxStr();
            String AmountIncludeTaxStr = ctrl.listShippmentWrapper[0].listBilling[0].getAmountIncludeTaxStr();
            String PaidAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getPaidAmountStr();
            String UnpaidAmountStr = ctrl.listShippmentWrapper[0].listBilling[0].getUnpaidAmountStr();
            System.assert(requestPayment.Id != null);
		Test.stopTest();
	}
}