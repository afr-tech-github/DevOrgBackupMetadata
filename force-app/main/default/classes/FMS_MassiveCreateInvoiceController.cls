/**
* ClassName:   FMS_MassiveCreateInvoiceController
* Description: Massive CreateInvoice Controller
* @created:    2022/09/14 Truong Lai
* @modified:
*/
public with sharing class FMS_MassiveCreateInvoiceController {
    private static final String TAB_PARAMETER_NAME = 'isTabShow';
	private static final String RECEIVABLE_TAB = 'receivableTab';
	private static final String PAYABLE_TAB = 'payableTab';
	private static final String MEISAIID = 'meisaiIds';
	private static final String SHOW_ALL = 'Show all';
	private static final String CHECK_ONLY = 'Check only';
	private static final String UNCHECK_ONLY = 'Un-check only';
	private static final String LOCAL = 'Local';
	private static final String ENGLISH = 'English';
	private static final String MESSAGE_ERROR_PERMISSIONS = 'Insufficent permissions. Please contact System Administrator for support!';

	public static clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiFilter {get; set;}
	public static clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiFilterTo {get; set;}
	public static clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiInput {get; set;}
	public static String orderNo {get; set;}

	public Boolean isShowReceivable {get; set;}
	public String localCurrency {get; set;}
	public String tabNameSelect {get; set;}

    private String parentId {get; set;}

	static {
		objAnkenMeisaiInput = new clofor_com_cfs__AnkenMeisai__c();
		objAnkenMeisaiFilter = new clofor_com_cfs__AnkenMeisai__c(
			clofor_com_cfs__Nyukingaku__c = 0
			,clofor_com_cfs__AmountSellingLocalAdjustment__c = 0
			,clofor_com_cfs__Siharaigaku__c = 0
			,clofor_com_cfs__AmountBuyingLocalAdjustment__c = 0
		);
		objAnkenMeisaiFilterTo = new clofor_com_cfs__AnkenMeisai__c();
	}

	public void init() {
		this.parentId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
	}

	public FMS_MassiveCreateInvoiceController(ApexPages.StandardSetController stdController) {
		try {
			Site_Custom_Settings__c objSiteCustomSettings = Site_Custom_Settings__c.getOrgDefaults();
			if (String.isNotBlank(objSiteCustomSettings.Id)) {
				this.localCurrency = objSiteCustomSettings.Local_Currency__c;
			}
			
			this.isShowReceivable = true;
			this.tabNameSelect = RECEIVABLE_TAB;			
		} catch (Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	@RemoteAction
    public static List<clofor_com_cfs__AnkenMeisai__c> getData(Boolean isReceivable
    															,Decimal amount
															  	,Decimal unpaid
															  	,String customerId
																,String advance
																,String strDateFrom
																,String strDateTo
																,String orderNo) {
		if (amount == null || amount < 0) {
			amount = 0;
		}

		if (unpaid == null || unpaid < 0) {
			unpaid = 0;
		}
		
		Boolean isAdvance = null;
		if (advance == CHECK_ONLY) {
			isAdvance = true;
		} else if (advance == UNCHECK_ONLY) {
			isAdvance = false;
		}

		Date dateFrom = null;
		Date dateTo = null;

		if (String.isNotBlank(strDateFrom)) {
			dateFrom = Date.parse(strDateFrom);
		}

		if (String.isNotBlank(strDateTo)) {
			dateTo = Date.parse(strDateTo);
		}

		List<String> orderNoList = new List<String>();
		if (String.isNotBlank(orderNo)) {
			List<String> orderNoInputList = orderNo.split(',');

			for (String oderNoInput : orderNoInputList) {
				oderNoInput = oderNoInput.trim();
				if (String.isNotBlank(oderNoInput)) {
					orderNoList.add('%' + oderNoInput + '%');
				}
			}
		}

        return getAnkenMeisaiList(isReceivable, amount, unpaid, customerId, isAdvance, dateFrom, dateTo, orderNoList);   
    }

	public void actionProcessing() {
		Savepoint sp;
		try {			
			List<String> ankenMeisaiIdUpdateList = new List<String>();
			String meisaiIdsSelected = ApexPages.currentPage().getParameters().get(MEISAIID);

			if (String.isNotBlank(meisaiIdsSelected)) {
				ankenMeisaiIdUpdateList = meisaiIdsSelected.split(',');
			}

			if (ankenMeisaiIdUpdateList.size() <= 10) {
				List<clofor_com_cfs__AnkenMeisai__c> ankenMeisaiUpdateList = new List<clofor_com_cfs__AnkenMeisai__c>();
				for(String meisaiIdUpdate : ankenMeisaiIdUpdateList) {
					ankenMeisaiUpdateList.add(this.createanKenMeisaiUpdate(meisaiIdUpdate, objAnkenMeisaiInput, this.isShowReceivable));					
				}

				sp = Database.setSavepoint();
				FlsService.doupdate(ankenMeisaiUpdateList);
			} else {
				ShowReceivablePayableBatch batch = new ShowReceivablePayableBatch(ankenMeisaiIdUpdateList, objAnkenMeisaiInput, this.isShowReceivable);
				Database.executeBatch(batch, 30);
			}
		} catch (Exception ex) {
			if (sp != null) {
				Database.rollback(sp);
			}
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}	

	/**
	* actionCreateInvoice
	* Create Invoice
	* @param:   None
	* @return:  None
	* @created: 2022/09/17 Truong Lai
	* @modified:
	*/
	public PageReference actionCreateInvoice() {
		try {
			String idSelected = ApexPages.currentPage().getParameters().get(MEISAIID);
			List<String> listAnkenMeisaiId = String.isNotBlank(idSelected) ? idSelected.split(',') : new List<String>();
			List<INVOICING_VAT__c> listInvoiceVAT = new List<INVOICING_VAT__c>();
			for (String billId : listAnkenMeisaiId) {
				INVOICING_VAT__c sobj = new INVOICING_VAT__c();
                sobj.INVOICING__c = billId;
                sobj.VAT_INVOICE__c = parentId;
                listInvoiceVAT.add(sobj);
			}
			// Insert data invoice with bill
			insertInvoicingVAT(listInvoiceVAT);
			// Redirect to VAT/INV Page
			if (!StringUtils.isEmpty(parentId)) {
                return goToParentPage();
            }
		} catch(Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		return null;
	}

	public Decimal getAmount(){
		Decimal amountNumber = objAnkenMeisaiFilter.clofor_com_cfs__Nyukingaku__c;
		if(isShowReceivable){
			amountNumber = objAnkenMeisaiFilter.clofor_com_cfs__AmountSellingLocalAdjustment__c; 
		}
		return amountNumber;
	}

	public Decimal getUnpaid(){
		Decimal unpaidNumber = objAnkenMeisaiFilter.clofor_com_cfs__Siharaigaku__c;
		if(isShowReceivable){
			unpaidNumber = objAnkenMeisaiFilter.clofor_com_cfs__AmountBuyingLocalAdjustment__c; 
		}
		return unpaidNumber;
	}

	public void actionFilter() {
		try {
			if (objAnkenMeisaiFilter.clofor_com_cfs__Nyukingaku__c == null
				|| objAnkenMeisaiFilter.clofor_com_cfs__Nyukingaku__c < 0) {
				objAnkenMeisaiFilter.clofor_com_cfs__Nyukingaku__c = 0;
			}

			if (objAnkenMeisaiFilter.clofor_com_cfs__AmountSellingLocalAdjustment__c == null
				|| objAnkenMeisaiFilter.clofor_com_cfs__AmountSellingLocalAdjustment__c < 0) {
				objAnkenMeisaiFilter.clofor_com_cfs__AmountSellingLocalAdjustment__c = 0;
			}

			if (objAnkenMeisaiFilter.clofor_com_cfs__Siharaigaku__c == null
				|| objAnkenMeisaiFilter.clofor_com_cfs__Siharaigaku__c < 0) {
				objAnkenMeisaiFilter.clofor_com_cfs__Siharaigaku__c = 0;
			}

			if (objAnkenMeisaiFilter.clofor_com_cfs__AmountBuyingLocalAdjustment__c == null
				|| objAnkenMeisaiFilter.clofor_com_cfs__AmountBuyingLocalAdjustment__c < 0) {
				objAnkenMeisaiFilter.clofor_com_cfs__AmountBuyingLocalAdjustment__c = 0;
			}
		} catch (Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public void actionChangeTab() {
		try {
			this.isShowReceivable = Boolean.valueOf(ApexPages.currentPage().getParameters().get(TAB_PARAMETER_NAME));
			if (this.isShowReceivable == true) {
				this.tabNameSelect = RECEIVABLE_TAB;
			} else {
				this.tabNameSelect = PAYABLE_TAB;
			}

			objAnkenMeisaiFilter = new clofor_com_cfs__AnkenMeisai__c(
				clofor_com_cfs__Nyukingaku__c = 0
				,clofor_com_cfs__AmountSellingLocalAdjustment__c = 0
				,clofor_com_cfs__Siharaigaku__c = 0
				,clofor_com_cfs__AmountBuyingLocalAdjustment__c = 0
			);
			objAnkenMeisaiFilterTo = new clofor_com_cfs__AnkenMeisai__c();
			orderNo = null;
		} catch (Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public void actionCancel() {
		try {
			objAnkenMeisaiInput = new clofor_com_cfs__AnkenMeisai__c();			
		} catch (Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(SHOW_ALL, SHOW_ALL));
		options.add(new SelectOption(CHECK_ONLY, CHECK_ONLY));
		options.add(new SelectOption(UNCHECK_ONLY, UNCHECK_ONLY));
		return options;
	}

	public List<SelectOption> getItemsLanguage() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(LOCAL, LOCAL));
		options.add(new SelectOption(ENGLISH, ENGLISH));
		return options;
	}
	
	private clofor_com_cfs__AnkenMeisai__c createanKenMeisaiUpdate(String meisaiIdUpdate
																	,clofor_com_cfs__AnkenMeisai__c objAnkenMeisai
																	,Boolean isReceivable) {
		clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiUpdate = new clofor_com_cfs__AnkenMeisai__c();
		objAnkenMeisaiUpdate.Id = meisaiIdUpdate;

		if (isReceivable) {
			objAnkenMeisaiUpdate.clofor_com_cfs__NyukinKakuninzumi__c = objAnkenMeisai.clofor_com_cfs__NyukinKakuninzumi__c;
			objAnkenMeisaiUpdate.clofor_com_cfs__BANKTRANSITTYPE__c = objAnkenMeisai.clofor_com_cfs__BANKTRANSITTYPE__c;
			objAnkenMeisaiUpdate.clofor_com_cfs__ReceiptanceDate_del__c = objAnkenMeisai.clofor_com_cfs__ReceiptanceDate_del__c;
		} else {
			objAnkenMeisaiUpdate.clofor_com_cfs__SiharaiKakuninzumi__c = objAnkenMeisai.clofor_com_cfs__SiharaiKakuninzumi__c;
			objAnkenMeisaiUpdate.clofor_com_cfs__payment_category__c = objAnkenMeisai.clofor_com_cfs__payment_category__c;
			objAnkenMeisaiUpdate.clofor_com_cfs__PaymentDate__c = objAnkenMeisai.clofor_com_cfs__PaymentDate__c;
		}

		return objAnkenMeisaiUpdate;
	}

	private static List<clofor_com_cfs__AnkenMeisai__c> getAnkenMeisaiList(Boolean isReceivable
																		  ,Decimal amount
																		  ,Decimal unpaid
																		  ,String customerId
																		  ,Boolean isAdvance
																		  ,Date dateFrom
																		  ,Date dateTo
																		  ,List<String> orderNoList) {		

		String soqlQuery = 'SELECT ' +
								'Id ' +
								',Name ' +
								',clofor_com_cfs__Anken__c ' +
								',clofor_com_cfs__Anken__r.Name ' +
								',clofor_com_cfs__Anken__r.clofor_com_cfs__SalesAccountedDate__c ' +
								',clofor_com_cfs__Seikyusaki__c ' +
								',clofor_com_cfs__Seikyusaki__r.Name ' +
								',clofor_com_cfs__InsatuyouSyohin__c ' +
								',clofor_com_cfs__InsatuyouSyohinEng__c ' +
								',clofor_com_cfs__NyukinKakuninzumi__c ' +
								',clofor_com_cfs__SellInTaxAmountJPY__c ' +
								',clofor_com_cfs__Nyukingaku__c ' +
								',clofor_com_cfs__SellDifferentiation__c' +
								',clofor_com_cfs__SellInTaxAmount_USD__c ' +
								',clofor_com_cfs__AMOUNT_PAID_SELLING_USD__c ' +
								',clofor_com_cfs__UNPAID_BALANCE_OF_SELLING_USD__c ' +
								',clofor_com_cfs__Payer__c ' +
								',clofor_com_cfs__Payer__r.Name ' +
								',toLabel(clofor_com_cfs__BANKTRANSITTYPE__c) ' +
								',clofor_com_cfs__ReceiptanceDate_del__c ' +
								',clofor_com_cfs__BankAccountForReceiving__c ' +
								',clofor_com_cfs__BankAccountForReceiving__r.Name ' +
								',clofor_com_cfs__SellDetail__c ' +
								',clofor_com_cfs__PaymentTo__c ' +
								',clofor_com_cfs__PaymentTo__r.Name ' +
								',clofor_com_cfs__SiharaiKakuninzumi__c ' +
								',clofor_com_cfs__BuyInTaxAmountJPY__c ' +
								',clofor_com_cfs__Siharaigaku__c ' +
								',clofor_com_cfs__BuyDifferentiation__c ' +
								',clofor_com_cfs__BuyInTaxAmountUSD__c ' +
								',clofor_com_cfs__AMOUNT_PAID_BUYING_USD__c ' +
								',clofor_com_cfs__UNPAID_BALANCE_OF_BUYING_USD__c ' +
								',clofor_com_cfs__actual_payer__c ' +
								',clofor_com_cfs__actual_payer__r.Name ' +
								',toLabel(clofor_com_cfs__payment_category__c) ' +								
								',clofor_com_cfs__PaymentDate__c ' +
								',clofor_com_cfs__BankAccountForPayment__c ' +
								',clofor_com_cfs__BankAccountForPayment__r.Name ' +
								',clofor_com_cfs__BuyDetail__c ' +
								',clofor_com_cfs__curr__c ' +
								',clofor_com_cfs__CurrencyBuying__c ' +	
								',clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c ' +	
								',clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c ' +
							'FROM clofor_com_cfs__AnkenMeisai__c ';
		if (isReceivable) {
			soqlQuery += 'WHERE (clofor_com_cfs__SellDifferentiation__c > 0 ';
			soqlQuery += 'OR clofor_com_cfs__UNPAID_BALANCE_OF_SELLING_USD__c > 0) ';
			soqlQuery += 'AND clofor_com_cfs__SellInTaxAmountJPY__c >=: amount ';
			soqlQuery += 'AND clofor_com_cfs__SellDifferentiation__c >=: unpaid ';


			if (String.isNotBlank(customerId)) {			
				soqlQuery += 'AND clofor_com_cfs__Seikyusaki__c =: customerId ';
			}

			if (isAdvance != null) {
				soqlQuery += 'AND clofor_com_cfs__ADVANCE_PAYMENT_ON_BEHALF_OF__c =: isAdvance ';
			}
		} else {
			soqlQuery += 'WHERE (clofor_com_cfs__BuyDifferentiation__c > 0 ';
			soqlQuery += 'OR clofor_com_cfs__UNPAID_BALANCE_OF_BUYING_USD__c > 0) ';
			soqlQuery += 'AND clofor_com_cfs__BuyInTaxAmountJPY__c >=: amount ';
			soqlQuery += 'AND clofor_com_cfs__BuyDifferentiation__c >=: unpaid ';

			if (String.isNotBlank(customerId)) {			
				soqlQuery += 'AND clofor_com_cfs__PaymentTo__c =: customerId ';
			}

			if (isAdvance != null) {
				soqlQuery += 'AND clofor_com_cfs__AdvancePaymentOnBehalfOfOurCompany__c =: isAdvance ';
			}
		}

		if (dateFrom != null) {
			soqlQuery += 'AND clofor_com_cfs__Anken__r.clofor_com_cfs__SalesAccountedDate__c >=: dateFrom ';
		}

		if (dateTo != null) {
			soqlQuery += 'AND clofor_com_cfs__Anken__r.clofor_com_cfs__SalesAccountedDate__c <=: dateTo ';
		}

		if (!orderNoList.isEmpty()) {			
			soqlQuery += 'AND clofor_com_cfs__Anken__r.clofor_com_cfs__ID__c LIKE: orderNoList';
		}

		List<clofor_com_cfs__AnkenMeisai__c> ankenMeisaiList = Database.query(soqlQuery);
		if (ankenMeisaiList == null) {
			ankenMeisaiList = new List<clofor_com_cfs__AnkenMeisai__c>();
		}

		return ankenMeisaiList;
	}

	private void insertInvoicingVAT(List<INVOICING_VAT__c> listInvoiceVAT) {
		if (!listInvoiceVAT.isEmpty() && PermissionValidationUtil.isCreatableHBLBuying() && PermissionValidationUtil.isCreatableVATInvoice()) {
			FlsService.doInsert(listInvoiceVAT);
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MESSAGE_ERROR_PERMISSIONS));
		}
    }

	private PageReference goToParentPage() {
        PageReference page = null;
        if (!StringUtils.isEmpty(parentId)) {
            page = new PageReference('/' + parentId);
            page.setRedirect(true);
        }

        return page;
    }
}