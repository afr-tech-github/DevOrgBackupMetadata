global with sharing class FMS_SortByCurrentSOController {
    
    @AuraEnabled
    public static void deleteAnkenMeisai(clofor_com_cfs__AnkenMeisai__c anken){
        delete anken;
    }
    
    @AuraEnabled
    public static void saveListAnken(List<clofor_com_cfs__AnkenMeisai__c> ankens){
		try{
			update ankens;
		}
		catch(Exception ex){
			System.debug('FMS_SortByCurrentSOController Exception ' + ex);
		}

    }

	@AuraEnabled(cacheable=true)
	public static List<sObject> lookUp(String searchTerm, String objectName, String filters, String recordId, String fields) {

		Integer limitNum = 20;

		String finalQuery = 'SELECT ' + fields + ' FROM ' + objectName;

		if(String.isBlank(recordId)){
			if(String.isNotBlank(searchTerm)){
				finalQuery += ' WHERE Name Like  \'%' + searchTerm + '%\' ';
			}

			if(String.isNotBlank(filters)){
				finalQuery += String.isNotBlank(searchTerm) ? ' AND ' : ' WHERE ';
				finalQuery += filters;
			}
		}else{
			finalQuery += ' WHERE Id =  \'' + recordId + '\'';
		}

		finalQuery+= ' LIMIT ' + limitNum;

		System.debug('Final Query::::' + finalQuery);

		List<sObject> lookUpList = database.query(finalQuery);

		return lookUpList;
	}

	@AuraEnabled (cacheable=true)
	public static List<PicklistOption> getPicklistValueFromObjectField(String objApiName, String fieldApiName) {
		List<PicklistOption> plOptions = new List<PicklistOption>();
		SObjectType objectType = Schema.getGlobalDescribe().get(objApiName);
		List<Schema.PicklistEntry> plEntries = objectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPickListValues();
		for (Schema.PicklistEntry plEntry : plEntries) {
			plOptions.add(new PicklistOption(plEntry.getValue(), plEntry.getLabel()));
		}
		return plOptions;
	}
    
    @AuraEnabled
    public static List<clofor_com_cfs__AnkenMeisai__c> getListAnkenMeisaiByShipment(String shipmentID){
        //List<AnkenWrapper> lstWrapper = new List<AnkenWrapper>();
        List<clofor_com_cfs__AnkenMeisai__c> lstAnken = new List<clofor_com_cfs__AnkenMeisai__c>();
        
        lstAnken = [ SELECT 
                   			Id
                    		, RecordTypeId 
                    		, clofor_com_cfs__Anken__c
                    		, clofor_com_cfs__Anken__r.Name
                   			, Name
                    		, clofor_com_cfs__Tariff__c
                    		, clofor_com_cfs__Tariff__r.Name
                    		, clofor_com_cfs__InsatuyouSyohin__c
                    		, clofor_com_cfs__Seikyusaki__c
                    		, clofor_com_cfs__Seikyusaki__r.Name
                    		, clofor_com_cfs__Suryo__c
                    		, clofor_com_cfs__ChargeUnit__c
                    		, clofor_com_cfs__ContainerSize__c
                    		, clofor_com_cfs__curr__c
                    		, clofor_com_cfs__SellTankaJPY__c
                    		, clofor_com_cfs__SellTankaUSD__c
                    		, clofor_com_cfs__TaxInitial__c
                    		, clofor_com_cfs__KawaseSel__c
                    		, clofor_com_cfs__SellInTaxAmount_USD__c
                    		, clofor_com_cfs__CurrencyConversionSelling__c
                    		, clofor_com_cfs__SeikyuBangou__c
                    		, clofor_com_cfs__PaymentTo__c
							, clofor_com_cfs__PaymentTo__r.Name
                    		, clofor_com_cfs__CurrencyBuying__c
                    		, clofor_com_cfs__BuyTankaJPY__c
                    		, clofor_com_cfs__BuyTankaUSD__c
                    		, clofor_com_cfs__BuyTaxInitial__c
                    		, clofor_com_cfs__KawaseBay__c
                    		, clofor_com_cfs__PrintFlag__c
                    		, clofor_com_cfs__BuyInTaxAmountJPY__c
                    		, clofor_com_cfs__CurrencyConversionBuying__c
                    FROM clofor_com_cfs__AnkenMeisai__c 
                    WHERE clofor_com_cfs__Anken__c = :shipmentID
                   ];
        
        /*if(!lstAnken.isEmpty()){
            for(clofor_com_cfs__AnkenMeisai__c item : lstAnken){
                AnkenWrapper wrapper = new AnkenWrapper();
                wrapper.anken = item;
                wrapper.isCheck = false;
                lstWrapper.add(wrapper);
            }
        }*/
        
        return !lstAnken.isEmpty()? lstAnken: new List<clofor_com_cfs__AnkenMeisai__c>();
    }
       
}