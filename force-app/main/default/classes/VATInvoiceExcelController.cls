global with sharing class VATInvoiceExcelController {
	private static final String VAT_INVOICE_ID_PARAMATER = 'invoiceId';
	private static final String INVOICE_TYPE_PARAMATER = 'invoiceType';
	private static final String BANK_TYPE_PARAMATER = 'bankType';

    global clofor_com_cfs__VAT_INVOICE__c objVatInvoice {get; set;}
	global List<clofor_com_cfs__INVOICING_VAT__c> invoicingVatList {get; set;}
	global CustomObject1__c customObject1 {get; set;}
	global String containerSealNo {get; set;}
	global String cusAddress {get; set;}
	global String bankType {get;set;}
	global String vatInvoiceId {get;set;}
	global String invoiceType {get; set;}
 
    global VATInvoiceExcelController() {
	}

	@AuraEnabled
	global static DataInitDTO getDataInit() {
		try {
			DataInitDTO objDataInitDTO = new DataInitDTO();
			objDataInitDTO.invoiceType = createInvoiceTypeOptions();
			objDataInitDTO.bankType = createBankTypeOptions();
			objDataInitDTO.theme = UserInfo.getUiThemeDisplayed();
			objDataInitDTO.reportName = Site_Custom_Settings__c.getOrgDefaults().CustomInvoiceExcelTemplate__c;

			return objDataInitDTO;
		} catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage());
		}
	}
	
	global void generateExcel() {
		try {			
			this.vatInvoiceId = ApexPages.currentPage().getParameters().get(VAT_INVOICE_ID_PARAMATER);
			this.invoiceType = ApexPages.currentPage().getParameters().get(INVOICE_TYPE_PARAMATER);
			this.bankType = ApexPages.currentPage().getParameters().get(BANK_TYPE_PARAMATER);

			this.objVatInvoice = this.getVatInvoice(this.vatInvoiceId);
			this.invoicingVatList = this.getInvoicingVatList(this.vatInvoiceId);
			this.containerSealNo = '';
			this.cusAddress = this.getInvoiceToAddress(this.objVATInvoice.clofor_com_cfs__VAT_INVOICE_TO__r.BillingStreet
														,this.objVATInvoice.clofor_com_cfs__VAT_INVOICE_TO__r.BillingCity
														,this.objVATInvoice.clofor_com_cfs__VAT_INVOICE_TO__r.BillingState
														,this.objVATInvoice.clofor_com_cfs__VAT_INVOICE_TO__r.BillingCountry);            
			
			this.customObject1 = new CustomObject1__c();
			if (!invoicingVatList.isEmpty()) {
				this.customObject1 = this.getCustomObject1(this.invoicingVatList[0].clofor_com_cfs__INVOICING__r.clofor_com_cfs__Anken__c);

				Integer count = 0;
				for (Container_Info__c objContainerInfo : this.customObject1.Container_Info__r) {
					if (String.isNotBlank(objContainerInfo.Container_No__c)
						&& String.isNotBlank(objContainerInfo.Seal_No__c)
						&& String.isNotBlank(objContainerInfo.Container__c)) {
						this.containerSealNo += objContainerInfo.Container_No__c + '/' + objContainerInfo.Seal_No__c + '/' + objContainerInfo.Container__c;
						count += 1;

						if (count == 3) {
							this.containerSealNo += '<br/>';
							count = 0;
						} else {
							this.containerSealNo += '-';
						}
					}		
				}
				this.containerSealNo = this.containerSealNo.removeEnd('-');
			}
		} catch (Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, +ex.getMessage()));
		}
	}

    private clofor_com_cfs__VAT_INVOICE__c getVatInvoice(String vatInvoiceId) {
		List<clofor_com_cfs__VAT_INVOICE__c> vatInvoiceList = new List<clofor_com_cfs__VAT_INVOICE__c>();
		vatInvoiceList = [
							SELECT
								Id
								,Name
								,clofor_com_cfs__RED_INVOICE_NO__c
								,clofor_com_cfs__VAT_INVOICE_TO__r.clofor_com_cfs__EnglishCompanyName__c
								,clofor_com_cfs__VAT_INVOICE_TO__r.Name
								,clofor_com_cfs__VAT_INVOICE_TO__r.clofor_com_cfs__BankNameForEInvoice__c
								,clofor_com_cfs__VAT_INVOICE_TO__r.clofor_com_cfs__BankNumberForEInvoice__c							
								,clofor_com_cfs__VAT_INVOICE_TO__r.clofor_com_cfs__TAX_CODE__c
								,clofor_com_cfs__VAT_INVOICE_TO__r.BillingStreet
								,clofor_com_cfs__VAT_INVOICE_TO__r.BillingCity
								,clofor_com_cfs__VAT_INVOICE_TO__r.BillingState
								,clofor_com_cfs__VAT_INVOICE_TO__r.BillingCountry 
								,clofor_com_cfs__VAT_INVOICE_TO__r.clofor_com_cfs__EnglishAddress__c
								,clofor_com_cfs__TERMS_OF_PAYMENT__c
								,clofor_com_cfs__VATInvoicePrintDate__c
								,clofor_com_cfs__CUSTOMER_PHONE_NUMBER__c
								,clofor_com_cfs__ExchangeRate__c
								,clofor_com_cfs__ForeignCurrency__c
								,clofor_com_cfs__TotalAmountOfVATSelling__c
								,clofor_com_cfs__Selling_Tax_Ratio__c
								,clofor_com_cfs__AmountOfTaxVATSelling__c
								,clofor_com_cfs__AmountVATSellingIncludeVAT__c
								,clofor_com_cfs__AmountVATSellingInclVATText__c
								,clofor_com_cfs__APIStatus__c
								,clofor_com_cfs__TotalAmountOfVATSellingFCY__c
								,clofor_com_cfs__AmountOfTaxVATSellingFCY__c
								,clofor_com_cfs__AmountVATSellingIncludeVATFCY__c
							FROM clofor_com_cfs__VAT_INVOICE__c
							WHERE Id =: vatInvoiceId
						];

		if (!vatInvoiceList.isEmpty()) {
			return vatInvoiceList[0];
		}
		
		return new clofor_com_cfs__VAT_INVOICE__c();
	}

	private List<clofor_com_cfs__INVOICING_VAT__c>  getInvoicingVatList(String vatInvoiceId) {
		List<clofor_com_cfs__INVOICING_VAT__c> invoicingVatList = new List<clofor_com_cfs__INVOICING_VAT__c>();
		invoicingVatList = [
							SELECT
								Id
								,Name
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__Anken__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__InsatuyouSyohin__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__InsatuyouSyohinEng__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__Tariff__r.clofor_com_cfs__UNIT__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__ChargeUnitInPrint__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__Tariff__r.clofor_com_cfs__ContainerSize__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__Suryo__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__SellTankaJPY__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__ProductTax__c
            					,clofor_com_cfs__INVOICING__r.clofor_com_cfs__SellTankaUSD__c
            					,clofor_com_cfs__INVOICING__r.clofor_com_cfs__SellAmountUSD__c
								,clofor_com_cfs__TotalAmountOfSellingLocalForVAT__c
								,clofor_com_cfs__INVOICING__r.clofor_com_cfs__TaxInitial__c
								,clofor_com_cfs__AmountOfTaxSellingLocalForVAT__c
								,clofor_com_cfs__AmountSellingInclTAXForVAT__c
							FROM clofor_com_cfs__INVOICING_VAT__c
							WHERE clofor_com_cfs__VAT_INVOICE__c =: vatInvoiceId
						];
		
		return invoicingVatList;
	}

	private CustomObject1__c getCustomObject1(String customObject1Id) {
		List<CustomObject1__c> customObject1List = new List<CustomObject1__c>();
		customObject1List = [
							SELECT
								Id
								,Name
								,clofor_com_cfs__MASTER_BOOKINGNO__c
								,clofor_com_cfs__HouseBookingNo__c
								,clofor_com_cfs__TranporationType__c
								,clofor_com_cfs__MBL_Number_SEA_AIR__c
								,clofor_com_cfs__PortOfLoadingDetailPrint__c
								,clofor_com_cfs__HBL_Number_SEA_AIR__c
								,clofor_com_cfs__PortOfDischargeDetailPrint__c	
								,clofor_com_cfs__ETD__c
								,clofor_com_cfs__ETA__c
								,clofor_com_cfs__NumberOfContainers__c
								,clofor_com_cfs__CBM__c
								,clofor_com_cfs__Container__c
								,clofor_com_cfs__ContainerNumber__c
								,clofor_com_cfs__Container2__c
								,clofor_com_cfs__ContainerNumber2__c	
								,clofor_com_cfs__Container3__c
								,clofor_com_cfs__ContainerNumber3__c	
								,clofor_com_cfs__Container4__c
								,clofor_com_cfs__ContainerNumber4__c
								,clofor_com_cfs__Container5__c
								,clofor_com_cfs__ContainerNumber5__c
								,clofor_com_cfs__Container6__c
								,clofor_com_cfs__ContainerNumber6__c	
								,clofor_com_cfs__Container7__c
								,clofor_com_cfs__ContainerNumber7__c
								,(
									SELECT
										Id
										,clofor_com_cfs__Container_No__c
										,clofor_com_cfs__Seal_No__c
										,clofor_com_cfs__Container__c										
									FROM clofor_com_cfs__Container_Info__r
								)
							FROM clofor_com_cfs__CustomObject1__c
							WHERE Id =: customObject1Id
							LIMIT 1
						];
		if (!customObject1List.isEmpty()) {
			return customObject1List[0];
		}
		
		return new CustomObject1__c();
	}

	private String getInvoiceToAddress(String street, String city, String state, String country) {
		return (String.isBlank(street) ? '' : street) +
				(String.isBlank(city) ? '' : ', ' + city) +
				(String.isBlank(state) ? '' : ', ' + state) +
				(String.isBlank(country) ? '' : ', ' + country);
	}	

	private static String createInvoiceTypeOptions() {
		List<ItemDTO> invoiceTypeOptions = new List<ItemDTO>();
		invoiceTypeOptions.add(new ItemDTO('invoice','Invoice'));
		invoiceTypeOptions.add(new ItemDTO('debit','Debit'));        
		return JSON.serialize(invoiceTypeOptions);
	}

	global static String createBankTypeOptions(){
        List<ItemDTO> bankTypeOptions = new List<ItemDTO>();
        bankTypeOptions.add(new ItemDTO('local1', 'Local 1'));
        bankTypeOptions.add(new ItemDTO('local2', 'Local 2'));
        bankTypeOptions.add(new ItemDTO('local3', 'Local 3'));
        bankTypeOptions.add(new ItemDTO('local4', 'Local 4'));
        bankTypeOptions.add(new ItemDTO('local5', 'Local 5'));
        return JSON.serialize(bankTypeOptions);
	}

	global class ResponeDTO {
        @AuraEnabled
        global String message {get; set;}

		@AuraEnabled
        global Boolean isSuccess {get; set;}
    }

	global class DataInitDTO {
        @AuraEnabled
        global String invoiceType {get; set;}
        
        @AuraEnabled
        global String bankType {get; set;}

		@AuraEnabled
        global String reportName {get; set;}

		@AuraEnabled
        global String theme {get; set;}
    }

	global class ItemDTO {
        global String label {get; set;}      
        global String value {get; set;}

		global ItemDTO(String value, String label) {
			this.value = value;
			this.label = label;
		}
    }
}