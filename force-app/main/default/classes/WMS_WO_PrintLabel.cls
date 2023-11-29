public with sharing class WMS_WO_PrintLabel {
	public List<WosLineItem__c> Records{ get; set; }
	public Integer noOfRecords{get; set;}
	public Map<String, String> translations{get; set;}
        
	public WMS_WO_PrintLabel(ApexPages.StandardController con) {
		translations = new Map<String, String>();
		translations = getTranslationMap();
		WorkOrder__c record = [SELECT RecordType.DeveloperName FROM WorkOrder__c WHERE Id = :con.getRecord().Id];
		this.Records = new List<WosLineItem__c>();

		if (!(new Set<String>{ 'Inbound', 'CrossDock', 'ExpressCargoTransfer'}.contains(record.RecordType.DeveloperName))) {
			return;
		}
		Set<Id> cargoIds = new Set<Id>();
		List<WosLineItem__c> wosls = [
			SELECT Id,
				Cargo__r.Product__r.ProductName__c, Cargo__r.Product__r.UnitType__c, Cargo__r.Name, Cargo__r.QrCodeImage__c, 
				Cargo__r.Product__r.QuantityPerUnit__c, Cargo__r.Product__r.Measurement__c, Cargo__r.Product__r.GrossWeight__c, 
				Cargo__r.DeliveryAddress__c,WorkOrderService__r.WorkOrder__r.Customer__r.Name, WorkOrderService__r.DestinationWarehouse__r.Name, 
				WorkOrderService__r.DestinationWarehouse__r.FacilityName__c, Cargo__r.Product__r.CodeImageType__c,
				Cargo__r.Product__r.QR_Code__c
			FROM WosLineItem__c
			WHERE WorkOrderService__r.WorkOrder__c = :record.Id
				AND (
					(WorkOrderService__r.WorkOrder__r.RecordType.DeveloperName = 'Inbound' AND WorkOrderService__r.RecordType.DeveloperName = 'InboundReceiving')
					OR (WorkOrderService__r.DestinationWarehouse__c != null)
				)
		];
        for(WosLineItem__c wosl : wosls){
            if(!String.isBlank(wosl.Cargo__c)
              && !cargoIds.contains(wosl.Cargo__c)){
                this.Records.add(wosl); 
               cargoIds.add(wosl.Cargo__c);
            }
        }
         

	}
	public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Records);
                setCon.setPageSize(1000);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
    public List<WosLineItem__c> getWosLineItems(){
        return (List<WosLineItem__c>) setCon.getRecords();
	}
	public Map<String,String> getTranslationMap(){
        String langCode = UserInfo.getLanguage();
        Map<String, Object> translate = TranslationService.getByLanguage(langCode.substringBefore('_'));
        Map<String, String> translateMapResult = new Map<String, String>();
        for(String key : translate.keySet()){
            if(key.contains('summary_note') || key.contains('unit_translation')){
                translateMapResult.put(key.substringAfter('.'), (String)translate.get(key));
            }
            
        }
        return translateMapResult; 
    }
}