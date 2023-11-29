global with sharing class CostAllocationService {
    private static TranslationService translationService = new TranslationService('COST_ALLOCATION', UserInfo.getLanguage());
    
    webservice static String balanceCostAllocation(String masterShipmentId) {
        String infoMessage = translationService.getTranslation('COST_ALLOCATION_MSG'); 
        
        if (StringUtils.isEmpty(infoMessage)) {
        	infoMessage = 'Cost Allocation has been balanced successfully';    
        }
        
        masterShipmentId = StringUtils.escapeSingleQuotes(masterShipmentId);
        
        if (PermissionValidationUtil.isAccessibleMBLBuying() 
            	&& PermissionValidationUtil.isAccessibleHBLBuying() && PermissionValidationUtil.isEditableHBLBuying()) {
			List<MasterAnkenMeisai__c> mblBuyings = findMBLBuyingRecords(masterShipmentId);
            List<String> masterMeisaiIds = new List<String>();
            
            if (mblBuyings != null && mblBuyings.size() > 0) {
                for (MasterAnkenMeisai__c mm : mblBuyings) {
                    masterMeisaiIds.add(mm.Id);
                }
                
                List<AnkenMeisai__c> hblSellingBuyings = findHBLSellingBuyingRecords(masterMeisaiIds);
                
                /* 
			     * Make sure the following database operations are atomic transaction
				 */ 
                Savepoint sp = Database.setSavepoint();
                
                try {
                    // clear cost allocation margin
                    resetCostMargin(hblSellingBuyings);
                    
                    hblSellingBuyings = findHBLSellingBuyingRecords(masterMeisaiIds);
                    
                    resetUnitPrice(hblSellingBuyings);
                    
                    for (MasterAnkenMeisai__c mm : mblBuyings) {
                        balanceCostAllocation(mm, hblSellingBuyings);
                    }
                    
                    FlsService.doUpdate(hblSellingBuyings);
                } catch(Exception e) {                    
                    infoMessage = e.getMessage();
                    Database.rollback(sp);
                }
            }
		} else {
            infoMessage = translationService.getTranslation('INSUFFICIENT_PERMISSION');
            
            if (StringUtils.isEmpty(infoMessage)) {
                infoMessage = 'Insufficient permission.';                        
            }			
		}
        
        return infoMessage;
    }
    
    private static void resetCostMargin(List<AnkenMeisai__c> meisais) {
        List<AnkenMeisai__c> toBeUpdated = new List<AnkenMeisai__c>();
        
        for (AnkenMeisai__c meisai : meisais) {
            if ((meisai.Cost_Allocation_Margin__c != null && meisai.Cost_Allocation_Margin__c != 0)
                || (meisai.Cost_Allocation_Margin_USD__c != null && meisai.Cost_Allocation_Margin_USD__c != 0)) {
				meisai.Cost_Allocation_Margin__c = 0;	
				meisai.Cost_Allocation_Margin_USD__c = 0;
				toBeUpdated.add(meisai);
			}
        }
        
        if (toBeUpdated.size() > 0) {
            FlsService.doUpdate(toBeUpdated);
        }
    }
    
    private static void resetUnitPrice(List<AnkenMeisai__c> meisais) {
        for (AnkenMeisai__c meisai : meisais) {
            meisai.BuyTankaJPY__c = meisai.AM_BuyInAfter_allocation__c;
            meisai.BuyTankaUSD__c = meisai.AM_BuyInAfter_allocation_USD__c;
        }
    }
    
    private static void balanceCostAllocation(MasterAnkenMeisai__c masterMeisai, List<AnkenMeisai__c> meisais) {
        Double totalAmountBuyingIncludeTax = 0;
        Double totalAmountBuyingUSD = 0;
        AnkenMeisai__c toBeBalancedMeisai = null;
        
        for (AnkenMeisai__c meisai : meisais) {
            if (meisai.AM_MasterMeisaiID__c == masterMeisai.Id) {
                totalAmountBuyingIncludeTax += meisai.BuyTankaJPY__c * meisai.Suryo__c;//meisai.BuyInTaxAmountJPY__c;
                totalAmountBuyingUSD += meisai.BuyTankaUSD__c * meisai.Suryo__c;//meisai.BuyAmountUSD__c;
                
                if (toBeBalancedMeisai == null) {
	                toBeBalancedMeisai = meisai;    
                }
            }
        }
        
        if (toBeBalancedMeisai != null) {
            Double margin = 0;
            if (totalAmountBuyingUSD != masterMeisai.BuyAmountUSD__c) {
                margin = masterMeisai.BuyAmountUSD__c - totalAmountBuyingUSD;
                
                if (!(margin < 0 && margin > -0.5)) {
	                toBeBalancedMeisai.Cost_Allocation_Margin_USD__c = margin;    
                }
            }
            
            if (totalAmountBuyingIncludeTax != masterMeisai.BuyAmountJPN__c) {
                margin = masterMeisai.BuyAmountJPN__c - totalAmountBuyingIncludeTax;
                
                if (!(margin < 0 && margin > -0.5)) {
                	toBeBalancedMeisai.Cost_Allocation_Margin__c = margin;
                }
            }
        }        
    }
    
    private static List<MasterAnkenMeisai__c> findMBLBuyingRecords(String masterShipmentId) {
        List<MasterAnkenMeisai__c> masters = [SELECT Id, BuyAmountJPN__c, BuyAmountUSD__c, BuyInTaxAmountJPY__c
                                              FROM MasterAnkenMeisai__c 
                                              WHERE MasterAnken__c = :masterShipmentId];
        
        if (masters == null) {
            masters = new List<MasterAnkenMeisai__c>();
        }
        
        return masters;
    }
    
    private static List<AnkenMeisai__c> findHBLSellingBuyingRecords(List<String> masterMeisaiIds) {
        List<AnkenMeisai__c> meisais = [SELECT Id, Cost_Allocation_Margin__c, Cost_Allocation_Margin_USD__c,
                                        	AM_MasterMeisaiID__c, BuyInTaxAmountJPY__c, BuyAmountUSD__c,
                                        	BuyTankaJPY__c, BuyTankaUSD__c, BuyAmountJPN__c, Suryo__c,
                                        	AM_BuyInAfter_allocation__c, AM_BuyInAfter_allocation_USD__c
                                        FROM AnkenMeisai__c 
                                        WHERE AM_MasterMeisaiID__c IN :masterMeisaiIds 
                                        ORDER BY Id];
        
        if (meisais == null) {
            meisais = new List<AnkenMeisai__c>();
        }
        
        return meisais;
    }
}