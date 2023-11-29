public with sharing class MBLBuyingTriggerHandler extends AbstractTriggerHandler {
    private List<AnkenMeisai__c> meisais = null;
    private Set<AnkenMeisai__c> toBeUpdatedMeisais = new Set<AnkenMeisai__c>();
    private Map<Id, MasterAnken__c> mapMBLs = new Map<Id, MasterAnken__c>();
    private List<MgmtMaster__c> exchangeRates = new List<MgmtMaster__c>();
    private Map<Id, TariffMaster__c> mapServiceMasters = new Map<Id, TariffMaster__c>();
    private TaxRatioService taxRatioService;
    private static TranslationService translationService;
    
    static {
        translationService = new TranslationService('ERROR', UserInfo.getLanguage());
    }

    public override String getHandlerName() {
        return 'MBLBuyingTriggerHandler';
    }
 
    public override void bulkBefore() {
        exchangeRates = ExchangeRateSynchronizationService.loadMasterExchangeRates();
        loadReferenceData(Trigger.new);
        taxRatioService = new TaxRatioService();
    }
    
	public override void bulkAfter() {
        loadHBLSellingBuyingRecords(Trigger.new);
    }
    
    public override void beforeInsert(SObject so) {
        MasterAnkenMeisai__c mblBuying = (MasterAnkenMeisai__c) so;
        
        if (!validateCurrency(mblBuying)) {
            return;
        }
        
        MasterAnken__c mbl = mapMBLs.get(mblBuying.MasterAnken__c);
        
        syncTaxRation(mblBuying, mbl);
        syncExchangeRate(mblBuying, mbl);
        updateUnitPrice(mblBuying);
    }
    
    public override void afterInsert(SObject so) {
        MasterAnkenMeisai__c master = (MasterAnkenMeisai__c) so;
        linkHBLSellingBuying(master);
    }
    
    public override void beforeUpdate(SObject oldSo, SObject so) {
        MasterAnkenMeisai__c mblBuying = (MasterAnkenMeisai__c) so;
        
        if (!validateCurrency(mblBuying)) {
            return;
        }
        
        MasterAnken__c mbl = mapMBLs.get(mblBuying.MasterAnken__c);
        TariffMaster__c serviceMaster = mapServiceMasters.get(mblBuying.MTariff__c);
        if (serviceMaster != null && serviceMaster.Supplier__c != null && !StringUtils.isEmpty(serviceMaster.Supplier__r.Currency__c)) {
            taxRatioService.populateMBLTaxRatio(mblBuying, mbl, serviceMaster.Supplier__r.Currency__c);    
        }
        updateUnitPrice(mblBuying);
    }
    
    public override void afterUpdate(SObject oldSo, SObject so) {
        MasterAnkenMeisai__c oldMaster = (MasterAnkenMeisai__c) oldSo;
        MasterAnkenMeisai__c newMaster = (MasterAnkenMeisai__c) so;
            
        if ((newMaster.BuyInTaxAmountJPY__c != oldMaster.BuyInTaxAmountJPY__c) 
            	|| (newMaster.BuyAmountUSD__c != oldMaster.BuyAmountUSD__c)
           		|| (newMaster.Cost_Allocation_Catetory__c != oldMaster.Cost_Allocation_Catetory__c)) {
			linkHBLSellingBuying(newMaster);
		}
    }
    
    public override void andFinally() {
        if (!toBeUpdatedMeisais.isEmpty()) {
            FlsService.doUpdate(new List<AnkenMeisai__c>(toBeUpdatedMeisais));
        }
    }
    
    private void syncTaxRation(MasterAnkenMeisai__c mblBuying,  MasterAnken__c mbl) {
        TariffMaster__c serviceMaster = mapServiceMasters.get(mblBuying.MTariff__c);
        if (serviceMaster != null && serviceMaster.Supplier__c != null && !StringUtils.isEmpty(serviceMaster.Supplier__r.Currency__c)) {
            taxRatioService.populateMBLTaxRatio(mblBuying, mbl, serviceMaster.Supplier__r.Currency__c);    
        }
    }
    
    private void syncExchangeRate(MasterAnkenMeisai__c mblBuying,  MasterAnken__c mbl) {
        TariffMaster__c serviceMaster = mapServiceMasters.get(mblBuying.MTariff__c);
		Date lookupDate = null;
        
        if (ObjectClassificationUtils.isImportMBL(mbl.Master_Record_Type__c)) {
            lookupDate = mbl.META__c;
        } else if (ObjectClassificationUtils.isExportMBL(mbl.Master_Record_Type__c)) {
            lookupDate = mbl.METD__c;
        }
            
        if (lookupDate != null) {     
            if (serviceMaster != null && serviceMaster.Supplier__c != null) {
                ExchangeRateSynchronizationService.applyExchangeRateToMBLBuyings(mblBuying, lookupDate, serviceMaster.Supplier__r, exchangeRates);
            }
        }	
    }
    
    private void linkHBLSellingBuying(MasterAnkenMeisai__c master) {
        if (meisais != null && !meisais.isEmpty()) {
            for (AnkenMeisai__c meisai : meisais) {
                if (master.Id == meisai.AM_MasterMeisaiID__c 
                   || (!StringUtils.isEmpty(meisai.Cost_Allocation_Catetory__c) 
                       && meisai.Cost_Allocation_Catetory__c.equalsIgnoreCase(master.Cost_Allocation_Catetory__c))) {
                    meisai.AM_MasterMeisaiID__c = master.Id;
                    toBeUpdatedMeisais.add(meisai);
                }
            }
        }
    }
    
    private void loadHBLSellingBuyingRecords(List<MasterAnkenMeisai__c> masters) {
        Set<Id> masterMBLBuyingIds = new Set<Id>();
        Set<Id> masterMBLIds = new Set<Id>();
        
        for (MasterAnkenMeisai__c master : masters) {
            masterMBLBuyingIds.add(master.Id);
            masterMBLIds.add(master.MasterAnken__c);
        }
        
        meisais = [SELECT AM_MasterMeisaiID__c, BuyTankaJPY__c, BuyTankaUSD__c, AM_BuyInAfter_allocation__c, 
                   		  AM_BuyInAfter_allocation_USD__c, AM_MasterID__c, Cost_Allocation_Catetory__c 
				   FROM AnkenMeisai__c
                   WHERE AM_MasterMeisaiID__c IN :masterMBLBuyingIds OR AM_MasterID__c IN :masterMBLIds
				  ];
    }
    
    private void loadReferenceData(List<MasterAnkenMeisai__c> mblBuyings) {
        Set<Id> mblIds = new Set<Id>();
        Set<Id> serviceMasterIds = new Set<Id>();
        
        for (MasterAnkenMeisai__c mblBuying : mblBuyings) {
            mblIds.add(mblBuying.MasterAnken__c);
            serviceMasterIds.add(mblBuying.MTariff__c);
        }
        
        mapMBLs = new Map<Id, MasterAnken__c>([SELECT Id, METD__c, META__C, MPartner__c, Master_Record_Type__c 
                                               FROM MasterAnken__c 
                                               WHERE Id IN :mblIds]);
        
        mapServiceMasters = new Map<Id, TariffMaster__c>([SELECT Id, Supplier__r.Currency__c, Supplier__r.Secondary_Currency__c, 
                                                          	Supplier__r.Primary_Exchange_Rate_Currency__c, 
                                                          	Supplier__r.Secondary_Exchange_Rate_Currency__c,
                                                            Supplier__r.Business_Relationship__c, Supplier__r.Custom_Type__c
                                                          FROM TariffMaster__c 
                                                          WHERE Id IN :serviceMasterIds]);
    }
    
    private boolean validateCurrency(MasterAnkenMeisai__c meisai) {
        boolean result = true;
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();
        
        // if (!StringUtils.isEmpty(meisai.curr__c) && !meisai.curr__c.equalsIgnoreCase(setting.Local_Currency__c)
            	// && !meisai.curr__c.equalsIgnoreCase(PicklistReference.CURRENCY_USD)) {
            // result = false;
            // 
            // if (PicklistReference.CURRENCY_USD.equals(setting.Local_Currency__c)) {
                // meisai.addError(translationService.getTranslation(Constants.UNAVAILABLE_CURRENCY));    
            // } else {
                // meisai.addError(translationService.getTranslation(Constants.UNAVAILABLE_CURRENCY) + ', ' + setting.Local_Currency__c);
            // }
        // }
        return result;
    }
    
    private void updateUnitPrice(MasterAnkenMeisai__c meisai) {
        if (NumbericUtils.isNonZero(meisai.KawaseBay__c) && NumbericUtils.isNonZero(meisai.BuyTankaUSD__c)) {
            meisai.BuyTankaJPY__c = meisai.KawaseBay__c * meisai.BuyTankaUSD__c;
        }
    }
}