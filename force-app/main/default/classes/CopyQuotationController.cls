global with sharing class CopyQuotationController {
	webService static String cloneFullQuotation(String quoteIdSource){
		return cloneFull(quoteIdSource); 
	}
	@AuraEnabled
	public static String cloneFull(String quoteIdSource){
		Quote__c quoteSource = getQuoteSource(quoteIdSource);
		Quote__c quoteDestination = quoteSource.clone(false);
		quoteDestination.SubmissionTargetDate__c = null;
		quoteDestination.QuoteIssueDate__c = null;
		quoteDestination.ValidTo__c = null;

		List<QuoteLine__c> quoteLineItems = getListQuoteLineSource(quoteIdSource);
		List<ProdSvcPricingQuoteLine__c> pricingLineItems = getListPricingQuoteLine(quoteIdSource);
		Map<Id, QuoteLine__c> mapQuoteLinebyIdSource = new  Map<Id, QuoteLine__c>();

		FlsService.doInsert(quoteDestination);
		for(QuoteLine__c item : quoteLineItems){
			QuoteLine__c itemClone = item.clone(false);
			itemClone.QuoteID__c = quoteDestination.Id;
			mapQuoteLinebyIdSource.put(item.Id, itemClone);
		}

		FlsService.doInsert(mapQuoteLinebyIdSource.values());
		List<ProdSvcPricingQuoteLine__c> pricingLineItemsClone = new List<ProdSvcPricingQuoteLine__c>();
		for(ProdSvcPricingQuoteLine__c pricingItem : pricingLineItems ){
			ProdSvcPricingQuoteLine__c pricingItemClone = pricingItem.clone(false);

			if(mapQuoteLinebyIdSource.containsKey(pricingItem.QuoteLineID__c)){
				pricingItemClone.QuoteLineID__c = mapQuoteLinebyIdSource.get(pricingItem.QuoteLineID__c).Id;
			}
			pricingLineItemsClone.add(pricingItemClone);
		}

		FlsService.doInsert(pricingLineItemsClone);
		return quoteDestination.Id; 

	}
	private static Quote__c getQuoteSource(String quoteIdSource){
		Quote__c quoteSource = [SELECT Id, 
						BuyingAmountInclTaxLocal__c, BuyingAmountInclTaxUSD__c, AmountInclTaxLocal__c,
		               	AmountInclTaxUSD__c, AmountOfTaxLocal__c, AmountOfTaxUSD__c, AmountOfTaxBuyingLocal__c,
		                AmountOfTaxBuyingUSD__c, CargoMode__c, CarrierVendor__c, Condition__c, ContainerType__c,
		                CntrTypeQnty__c, DeliveryAddress__c, DescriptionOfGoods__c, ETA__c, ETD__c, ExchangeRateID__c,
		                ExternalSales__c, Frequency__c, FXRateID__c, GrossWeightKG__c, Incoterms__c, MeasurementCBM__c,
		                NetWeightKG__c, PICOfRequesterCompany__c, PODAOA__c, POLAOD__c, ParentQuoteID__c, PaymentCondition__c,
		                PickupAddress__c, ProfitInclTaxLocal__c, ProfitIncludeTaxUSD__c, ProfitNICTaxLocal__c, ProfitNICTaxUSD__c,
		                ProfitRatioInclTaxLocal__c, ProfitRatioInclTaxUSD__c, ProfitRatioNICTaxLocal__c,
		                ProfitRatioNICTaxUSD__c, Quantity__c, QuoteIssueDate__c, QuoteName__c,
		                QuoteNumber__c, QuotePIC__c, QuoteStatus__c, Remarks__c,
		                RequestDetail__c,RequesterCompany__c, RFPRFQID__c, SubmissionTargetDate__c,
		                TargetRate__c, TotalAmountLocal__c, TotalAmountUSD__c, TotalAmountBuyingLocal__c,
		                TotalAmountBuyingUSD__c, Unit__c, ValidTo__c, VesselFlight__c, Volume__c, RecordTypeId
					FROM Quote__c
					WHERE Id =: quoteIdSource];
		return quoteSource;
	}

	private static List<QuoteLine__c> getListQuoteLineSource(String quoteIdSource){
		List<QuoteLine__c> quoteLineItems = [SELECT Id, Over1000kg__c, Over100kg__c, Over300kg__c, Over45kg__c, Over500kg__c,
									Under45kg__c, AmountOfBuyingTaxLocal__c, AmountOfBuyingTaxUSD__c,
									AmountOfSellingTaxLocal__c, AmountOfSellingTaxUSD__c, BuyingAmountInclTaxLocal__c,
									BuyingAmountInclTaxUSD__c, BuyingListPriceLocal__c, BuyingListPriceUSD__c, CarrierAirlinerVendor__c, 
									CarrierAirlinerVendorName__c, ContainerQuantity__c, ContainerType__c, CurrencyBuying__c, CurrencyConverseForBuying__c,
									CurrencyConverseForSelling__c, CurrencySelling__c, DeliveryAddress__c, ExchangeRateBuyingUpdate__c,
									ExchangeRateSelling__c, ExchangeRateSellingUpdate__c, FSCSCS__c, FXRateID__c, LineItemDescription__c, 
									LineItemName__c, Minimum__c, PODAOA__c, PODAOAName__c, POLAOD__c, POLAODName__c, ParentQuoteLine__c, PickupAddress__c,
									Print__c, PrintingSection__c, ProductID__c, Quantity__c, QuoteID__c, QuoteLineNumber__c, Remarks__c,
									SellingAmountInclTaxLocal__c, SellingAmountInclTaxUSD__c, DiscountRate__c, SellingListPriceLocal__c, 
									SellingListPriceUSD__c, ServiceCategory__c, ServiceCostingType__c, ServicePricingID__c, ServiceSchedule__c,
									ServiceSubCategory__c, ExchangeRateBuying__c, TaxRateBuying__c, TaxRate__c, TotalAmountBuyingLocal__c, TotalAmountOfBuyingUSD__c,
									TotalAmountSellingLocal__c, TotalAmountOfSellingUSD__c, TransitTimeDays__c, Unit__c, RecordTypeId
								FROM QuoteLine__c 
								WHERE QuoteID__c =: quoteIdSource];
		return quoteLineItems;
	}

	private static List<ProdSvcPricingQuoteLine__c> getListPricingQuoteLine(String quoteIdSource){
		List<ProdSvcPricingQuoteLine__c> pricingLineItems = [SELECT Id, deletedSvcSellingUnitPriceLocal__c, ProdPricingID__c,
																ProdBuyingUnitPriceLocal__c, ProdBuyingUnitPriceUSD__c, ProdSellingUnitPriceLocal__c,
																ProdSellingUnitPriceUSD__c, QuoteLineID__c, QuoteLineRollupStatus__c, SvcBuyingUnitPriceLocal__c, 
																SvcBuyingUnitPriceUSD__c, SvcPricingID__c, SvcSellingUnitPriceLocal__c, SvcSellingUnitPriceUSD__c
															FROM ProdSvcPricingQuoteLine__c
															WHERE QuoteLineID__r.QuoteID__c =: quoteIdSource];
		return pricingLineItems;
	}
}