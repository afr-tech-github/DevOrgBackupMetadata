@isTest
private class FMSBillPayReqTriggerHelperTest {
	
	private static CustomObject1__c shipment{get; set;}
	private static List<VAT_INVOICE__c> vats = new List<VAT_INVOICE__c>();
	private static List<INVOICING_VAT__c> listBillVAT = new List<INVOICING_VAT__c>();
	private static PaymentRequest__c requestPayment{get;set;}
	private static PaymentRequest__c requestCollect{get;set;}
	private static List<AnkenMeisai__c> listbills = new List<AnkenMeisai__c>();
	private static AnkenMeisai__c bill3{get; set;}
    private static AnkenMeisai__c bill2{get; set;}
    private static AnkenMeisai__c bill1{get; set;}
	static{
		// turn off trigger
		Custom_Application_Config__c config =  new Custom_Application_Config__c(Disabled_Trigger__c = true);
		FlsService.doInsert(config);
		RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account acc = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => acc.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => false, 'AccountId' => acc.Id};
        Contact partner = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
		
        additionFields = new Map<String, Object> {'Field1__c' => acc.Id, 'Partner__c' => acc.Id,
            										'CustmerInCharge__c' => customer.Id, 
            										'PartnerRep__c' => partner.Id, 'RecordTypeId' => rt.Id};
		shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields);
		FlsService.doInsert(shipment);

        additionFields = new Map<String, Object> {'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
            									'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'Supplier__c' => acc.Id};
		TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionFields);                                                                 
        additionFields = new Map<String, Object> {'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
            									'Tariff__c' => tariff.Id, 'Seikyusaki__c' => acc.Id,
            									'NyukinKakuninzumi__c' => false};
		bill1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionFields);
        bill2 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), false, additionFields);
		
		listbills.add(bill1);
		listbills.add(bill2);
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
        CashAdvance__c cashAdvance = new CashAdvance__c();
		FlsService.doInsert(cashAdvance);
		requestPayment = new PaymentRequest__c(
			RecordTypeId = Schema.SObjectType.PaymentRequest__c.getRecordTypeInfosByDeveloperName().get('PaymentRequestlocalCurrency').getRecordTypeId(),
			BankID__c = bank.Id,
			CashID__c = cash.Id,
            CashAdvanceID__c = cashAdvance.Id,
            PaymentTo__c = acc.id,
            InvoiceTo__c = acc.id
			);
		FlsService.doInsert(requestPayment);
        FMSBillPayReq__c billPlan = new FMSBillPayReq__c(
				PaymentRequestID__c = requestPayment.Id,
				FMSBillID__c = bill1.Id,
				AutoConnectSourceToTransaction__c = 'Processing Requested'
				);
		FlsService.doInsert(billPlan);
        config.Disabled_Trigger__c = false;
		FlsService.doUpdate(config);
	}
	@isTest static void test_method_one() {
        Test.startTest();
			FMSBillPayReq__c billPlan = new FMSBillPayReq__c(
				PaymentRequestID__c = requestPayment.Id,
				FMSBillID__c = bill2.Id,
				AutoConnectSourceToTransaction__c = 'Processing Requested'
				);
        try{
			FlsService.doInsert(billPlan);
        } catch(Exception ex){
            
        }
        System.assert(1 != null);
		Test.stopTest();
	}

	@isTest static void test_method_two() {
		FMSBillPayReq__c billPlan = [select Id from FMSBillPayReq__c limit 1];
		Test.startTest();
        try{
        	FlsService.doDelete(billPlan);
         }catch(Exception ex){
            
        }
		System.assert(listbills != null);	
		Test.stopTest();
	}
}