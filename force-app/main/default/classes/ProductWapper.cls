global with sharing class ProductWapper {
	@AuraEnabled
	public PRODUCT__c product{get; set;}
	@AuraEnabled
	public String productName{get; set;}
	@AuraEnabled
	public String goodsOwnerName{get; set;}
	@AuraEnabled
	public String buyerName{get; set;}
	@AuraEnabled
	public Decimal totalProductMeasurement{get; set;}
	@AuraEnabled
	public Decimal totalProductGrossWeight{get; set;}
	@AuraEnabled
	public Decimal totalProductMeasurementIncludePlan{get; set;}
	@AuraEnabled
	public Decimal totalProductGrossWeightIncludePlan{get; set;}
	@AuraEnabled
	public Integer remainQuantityProduct{get; set;}
	@AuraEnabled
	public List<LocatorWapper> listLocator{get; set;}
	@AuraEnabled
	public Map<String, LocatorWapper> locatorMap{get; set;}
	@AuraEnabled
	public Integer listLocatorSize{get; set;}
	@AuraEnabled
	public List<SOPWrapper> listSOPWrapper{get; set;}
	public ProductWapper(){
		product = new PRODUCT__c();
		productName = '';
		goodsOwnerName ='';
		buyerName ='';
		listSOPWrapper = new List<SOPWrapper>();
		listLocator = new List<LocatorWapper>();
		totalProductMeasurement = 0;
		totalProductGrossWeight = 0;
		totalProductMeasurementIncludePlan = 0;
		totalProductGrossWeightIncludePlan = 0;
		remainQuantityProduct = 0;
		listLocatorSize = 0;
		locatorMap = new Map<String, LocatorWapper>();
	}
	public class SOPWrapper{
		@AuraEnabled
		public String SOName{get; set;}
		@AuraEnabled
		public String SOId{get; set;}
		@AuraEnabled
		public Decimal requiredNumber{get; set;}
		public SOPWrapper(){
			SOName = '';
			SOId = '';
			requiredNumber = 0;
		}
	}
}