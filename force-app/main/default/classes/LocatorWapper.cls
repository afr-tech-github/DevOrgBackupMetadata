global with sharing class LocatorWapper {
	@AuraEnabled
	public String locatorId {get; set;}
    @AuraEnabled
	public String locatorCode {get; set;}
	@AuraEnabled
	public String locatorName {get; set;}
    @AuraEnabled
	public String warehouseId {get; set;}
	@AuraEnabled
	public String warehouseName {get; set;}
	@AuraEnabled
	public Decimal totalLocatorMeasurement{get; set;}
	@AuraEnabled
	public Decimal totalLocatorGrossWeight{get; set;}
	@AuraEnabled
	public Decimal totalLocatorMeasurementIncludePlan{get; set;}
	@AuraEnabled
	public Decimal totalLocatorGrossWeightIncludePlan{get; set;}
	@AuraEnabled
	public String facitityName{get; set;}
	@AuraEnabled
	public String facitityId{get; set;}
	@AuraEnabled
	public String productName {get; set;}
	@AuraEnabled
	public Integer index {get; set;}
	@AuraEnabled
	public Integer remainQuantity{get; set;}
	@AuraEnabled
	public List<Stock__c> listStock {get; set;}
	@AuraEnabled
	public Integer listStocksize {get; set;}
    @AuraEnabled
	public Date expiredDate {get; set;}
    @AuraEnabled
	public Date inboundDate {get; set;}

	
	public LocatorWapper(){
		index = 0;
		productName = '';
		locatorName = '';
        warehouseName = '';
		totalLocatorMeasurement = 0;
		totalLocatorGrossWeight = 0;
		remainQuantity = 0;
		totalLocatorMeasurementIncludePlan = 0;
		totalLocatorGrossWeightIncludePlan = 0;
		listStock = new List<Stock__c>();
		listStocksize = 0;
		}
}