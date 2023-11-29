/*
Class Name: LocatorTriggerHelper
Description: 
Author: Nga Do
Date: 2018/07/06
*/

public class LocatorTriggerHelper {
    
    public static void onBeforeInsert(List<LOCATOR__c > newLocators){
        Set<String> setLayer = new Set<String>();
        Set<Id> setFacilityId = new Set<Id>();
        for(LOCATOR__c locator : newLocators){
            
            setLayer.add(locator.LocatorLayer__c);
            setFacilityId.add(locator.WarehouseID__c);
        }
        List<LOCATOR__c> listLocatorSameLayer = [SELECT 
                                                 Id, 
                                                 WarehouseID__c, 
                                                 LocatorLayer__c, 
                                                 LocatorCode__c,
                                                 FloorCode__c,
                                                 AreaCode__c,
                                                 SectionCode__c,
                                                 Rack__c,
                                                 Level__c,
                                                 WarehouseID__r.Name
                                                 FROM LOCATOR__c 
                                                 WHERE LocatorLayer__c IN: setLayer 
                                                 AND WarehouseID__c IN: setFacilityId
                                                ];
        Map<Id, Set<String>> mapLocatorCodeInFacility = new Map<Id, Set<String>>();
        Map<Id, String> mapWarehouseName = new Map<Id, String>();
        
        for(LOCATOR__c locator : listLocatorSameLayer){
            String code = locator.FloorCode__c + locator.AreaCode__c + locator.SectionCode__c + locator.Rack__c + locator.Level__c;
            if(!mapLocatorCodeInFacility.containsKey(locator.WarehouseID__c)){
                
                
                mapLocatorCodeInFacility.put(locator.WarehouseID__c, new Set<String>{code});
                
            }else{
                mapLocatorCodeInFacility.get(locator.WarehouseID__c).add(code);
            }
            
            mapWarehouseName.put(locator.WarehouseID__c, locator.WarehouseID__r.Name );
        }
        for(LOCATOR__c locator : newLocators){
            // Check Duplicate LocatorCode
            String currentCode = locator.FloorCode__c + locator.AreaCode__c + locator.SectionCode__c + locator.Rack__c + locator.Level__c;

            if(mapLocatorCodeInFacility.containsKey(locator.WarehouseID__c)
               && mapLocatorCodeInFacility.get(locator.WarehouseID__c).contains(currentCode)){
                   String errorMesage = String.format(Label.DUPLICATE_LOCATOR_CODE_ERROR_MSG, new LIST<String> { locator.LocatorLayer__c , mapWarehouseName.get(locator.WarehouseID__c)});
                   locator.addError(errorMesage);
                   return;
               }
            if(locator.ActualOccupiedCapacityKG__c == null){
                locator.ActualOccupiedCapacityKG__c = 0;
            }
            if(locator.ActualOccupiedCapacityCBM__c == null){
                locator.ActualOccupiedCapacityCBM__c = 0;
            }
            if(locator.CurrentOccupiedCapacityKG__c == null){
                locator.CurrentOccupiedCapacityKG__c = 0;
            }
            if(locator.CurrentOccupiedCapacityCBM__c == null){
                locator.CurrentOccupiedCapacityCBM__c = 0;
            }
        }
        
        
    }
    
    public static void onAfterInsert(List<LOCATOR__c > newLocators){
        Set<Id> parentsLocatorIds = new Set<Id>();
        //Set<Id> setCurrentLocatorId = new Set<Id>();
        for(LOCATOR__c locator : newLocators){
            if(locator.ParentLocator__c != null){
                
                parentsLocatorIds.add(locator.ParentLocator__c);
            }
            //setCurrentLocatorId.add(locator.Id);
        }
        
        Map<Id, LOCATOR__c> mapParentsLocators = new Map<Id, LOCATOR__c>([SELECT 
                                                                          Id, 
                                                                          CapacityCBM__c,
                                                                          CapacityKG__c,
                                                                          SharedCapacityCBM__c,
                                                                          SharedCapacityKG__c,
                                                                          ActualOccupiedCapacityKG__c,
                                                                          ActualOccupiedCapacityCBM__c,
                                                                          CurrentOccupiedCapacityKG__c,
                                                                          CurrentOccupiedCapacityCBM__c
                                                                          FROM LOCATOR__c
                                                                          WHERE Id IN: parentsLocatorIds]);
        for(LOCATOR__c locator : newLocators){
            if(locator.ParentLocator__c == null
               || !mapParentsLocators.containsKey(locator.ParentLocator__c)){
                   continue;
               }
            mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityCBM__c = mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityCBM__c + locator.CapacityCBM__c;
            mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityKG__c = mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityKG__c + locator.CapacityKG__c;
        }
        
        
        try{
            FlsService.doUpdate(mapParentsLocators.values());
        }catch(Exception ex){
            newLocators[0].addError(ex.getMessage());
        }
    }
    /*
Method Name: calculateCapacityLocatorDeleteChild
prarams: list of child Locator
Description: re-Calculate Actual and Current Occupied Capacity of Locator
Author: Nga Do
*/
    public static void onBeforeDelete(List<LOCATOR__c > oldLocators){
        
        Set<Id> parentsLocatorIds = new Set<Id>();
        for(LOCATOR__c locator : oldLocators){
            if(locator.ParentLocator__c != null){
                
                parentsLocatorIds.add(locator.ParentLocator__c);
            }
        }
        Map<Id, LOCATOR__c> mapParentsLocators = new Map<Id, LOCATOR__c>([SELECT 
                                                                          Id, 
                                                                          CapacityCBM__c,
                                                                          CapacityKG__c,
                                                                          SharedCapacityCBM__c,
                                                                          SharedCapacityKG__c,
                                                                          ActualOccupiedCapacityKG__c,
                                                                          ActualOccupiedCapacityCBM__c,
                                                                          CurrentOccupiedCapacityKG__c,
                                                                          CurrentOccupiedCapacityCBM__c
                                                                          FROM LOCATOR__c
                                                                          WHERE Id IN: parentsLocatorIds]);
        
        for(LOCATOR__c locator : oldLocators){
            if(locator.ParentLocator__c == null
               || !mapParentsLocators.containsKey(locator.ParentLocator__c)){
                   continue;
               }
            mapParentsLocators.get(locator.ParentLocator__c).ActualOccupiedCapacityKG__c = mapParentsLocators.get(locator.ParentLocator__c).ActualOccupiedCapacityKG__c - locator.ActualOccupiedCapacityKG__c;
            mapParentsLocators.get(locator.ParentLocator__c).ActualOccupiedCapacityCBM__c = mapParentsLocators.get(locator.ParentLocator__c).ActualOccupiedCapacityCBM__c - locator.ActualOccupiedCapacityCBM__c;
            mapParentsLocators.get(locator.ParentLocator__c).CurrentOccupiedCapacityKG__c = mapParentsLocators.get(locator.ParentLocator__c).CurrentOccupiedCapacityKG__c - locator.CurrentOccupiedCapacityKG__c;
            mapParentsLocators.get(locator.ParentLocator__c).CurrentOccupiedCapacityCBM__c = mapParentsLocators.get(locator.ParentLocator__c).CurrentOccupiedCapacityCBM__c - locator.CurrentOccupiedCapacityCBM__c;
            mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityCBM__c = mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityCBM__c - locator.CapacityCBM__c;
            mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityKG__c = mapParentsLocators.get(locator.ParentLocator__c).SharedCapacityKG__c - locator.CapacityKG__c;
        }
        
        try{
            FlsService.doUpdate(mapParentsLocators.values());
        }catch(Exception ex){
            oldLocators[0].addError(ex.getMessage());
        }  
    }
    
    /*
Method Name: calculateCapacityLocatorDeleteChild
prarams: list of child Locator
Description: re-Calculate Actual and Current Occupied Capacity of Locator
Author: Nga Do
*/
    public static void onBeforeUpdate(List<LOCATOR__c > newLocators, Map<Id, LOCATOR__c> mapOldLocators){
        
        Set<Id> newParentsLocatorIds = new Set<Id>();
        Set<Id> oldParentsLocatorId = new Set<Id>();
        Set<Id> locatorParents = new Set<Id>();
        Map<Id, Id> mapOldParentbyLocators  = new Map<Id, Id>();
        Set<String> setLayer = new Set<String>();
        Set<Id> setFacilityId = new Set<Id>();
        Set<Id> setCurrentLocatorId = new Set<Id>();
        for(LOCATOR__c locator : newLocators){
            if(locator.ParentLocator__c != null){
                
                newParentsLocatorIds.add(locator.ParentLocator__c);
                locatorParents.add(locator.ParentLocator__c);
            }
            setLayer.add(locator.LocatorLayer__c);
            setFacilityId.add(locator.WarehouseID__c);
            setCurrentLocatorId.add(locator.Id);
        }
        
        for(LOCATOR__c locator : mapOldLocators.values()){
            
            if(locator.ParentLocator__c != null){
                locatorParents.add(locator.ParentLocator__c);
                oldParentsLocatorId.add(locator.ParentLocator__c);
                mapOldParentbyLocators.put(locator.Id, locator.ParentLocator__c);
            }
            
        }
        
        Map<Id, LOCATOR__c> mapParentsLocator = new Map<Id, LOCATOR__c>([SELECT 
                                                                         Id, 
                                                                         CapacityCBM__c,
                                                                         CapacityKG__c,
                                                                         SharedCapacityCBM__c,
                                                                         SharedCapacityKG__c,
                                                                         ActualOccupiedCapacityKG__c,
                                                                         ActualOccupiedCapacityCBM__c,
                                                                         CurrentOccupiedCapacityKG__c,
                                                                         CurrentOccupiedCapacityCBM__c
                                                                         FROM LOCATOR__c
                                                                         WHERE Id IN: locatorParents]);
        
        List<LOCATOR__c> listLocatorSameLayer = [SELECT 
                                                 Id, 
                                                 WarehouseID__c, 
                                                 LocatorLayer__c, 
                                                 LocatorCode__c,
                                                 FloorCode__c,
                                                 AreaCode__c,
                                                 SectionCode__c,
                                                 Rack__c,
                                                 Level__c,
                                                 WarehouseID__r.Name
                                                 FROM LOCATOR__c 
                                                 WHERE LocatorLayer__c IN: setLayer 
                                                 AND WarehouseID__c IN: setFacilityId
                                                 AND Id NOT IN : setCurrentLocatorId
                                                ];
        Map<Id, Set<String>> mapLocatorCodeInFacility = new Map<Id, Set<String>>();
        Map<Id, String> mapWarehouseName = new Map<Id, String>();
        
        for(LOCATOR__c locator : listLocatorSameLayer){
            String code = locator.FloorCode__c + locator.AreaCode__c + locator.SectionCode__c + locator.Rack__c + locator.Level__c;
            if(!mapLocatorCodeInFacility.containsKey(locator.WarehouseID__c)){
                
                
                mapLocatorCodeInFacility.put(locator.WarehouseID__c, new Set<String>{code});
                
            }else{
                mapLocatorCodeInFacility.get(locator.WarehouseID__c).add(code);
            }
            mapWarehouseName.put(locator.WarehouseID__c, locator.WarehouseID__r.Name );
        }
        for(LOCATOR__c locator : newLocators){
            // Check Duplicate LocatorCode
            String currentCode = locator.FloorCode__c + locator.AreaCode__c + locator.SectionCode__c + locator.Rack__c + locator.Level__c;
            if(mapLocatorCodeInFacility.containsKey(locator.WarehouseID__c)
               && mapLocatorCodeInFacility.get(locator.WarehouseID__c).contains(currentCode)){
                   String errorMesage = String.format(Label.DUPLICATE_LOCATOR_CODE_ERROR_MSG, new LIST<String> { locator.LocatorLayer__c , mapWarehouseName.get(locator.WarehouseID__c)});
                   locator.addError(errorMesage);
               }
            if(locator.ParentLocator__c == null){
                continue;
            }
            if(locator.ActualOccupiedCapacityCBM__c == null){
                locator.ActualOccupiedCapacityCBM__c  = 0;
            }
            if(locator.ActualOccupiedCapacityKG__c == null){
                locator.ActualOccupiedCapacityKG__c  = 0;
            }
            
            if(locator.CurrentOccupiedCapacityCBM__c == null){
                locator.CurrentOccupiedCapacityCBM__c  = 0;
            }
            if(locator.CurrentOccupiedCapacityKG__c == null){
                locator.CurrentOccupiedCapacityKG__c  = 0;
            }

            Decimal oldCurrentOccupiedCapacityCBM = 0;
            Decimal oldCurrentOccupiedCapacityKG = 0;
            Decimal oldActualOccupiedCapacityCBM = 0;
            Decimal oldActualOccupiedCapacityKG = 0;
            if(mapOldLocators.get(locator.Id).CurrentOccupiedCapacityCBM__c != null){
              oldCurrentOccupiedCapacityCBM = mapOldLocators.get(locator.Id).CurrentOccupiedCapacityCBM__c;
            }
            if(mapOldLocators.get(locator.Id).CurrentOccupiedCapacityKG__c != null){
              oldCurrentOccupiedCapacityKG = mapOldLocators.get(locator.Id).CurrentOccupiedCapacityKG__c;
            }
            if(mapOldLocators.get(locator.Id).ActualOccupiedCapacityCBM__c != null){
              oldActualOccupiedCapacityCBM = mapOldLocators.get(locator.Id).ActualOccupiedCapacityCBM__c;
            }
            if(mapOldLocators.get(locator.Id).ActualOccupiedCapacityKG__c != null){
              oldActualOccupiedCapacityKG = mapOldLocators.get(locator.Id).ActualOccupiedCapacityKG__c;
            }

            mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityCBM__c = mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityCBM__c == null? 0: mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityCBM__c;
            mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityKG__c = mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityKG__c == null? 0: mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityKG__c;
            
            if(mapParentsLocator.containsKey(locator.ParentLocator__c)){
                if(locator.CurrentOccupiedCapacityCBM__c != oldCurrentOccupiedCapacityCBM){
                    mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityCBM__c += locator.CurrentOccupiedCapacityCBM__c - oldCurrentOccupiedCapacityCBM;
                    
                }
                if(locator.CurrentOccupiedCapacityKG__c != oldCurrentOccupiedCapacityKG){
                    
                    mapParentsLocator.get(locator.ParentLocator__c).CurrentOccupiedCapacityKG__c += locator.CurrentOccupiedCapacityKG__c - oldCurrentOccupiedCapacityKG;
                    
                }
                if(locator.ActualOccupiedCapacityCBM__c != oldActualOccupiedCapacityCBM){
                    
                    mapParentsLocator.get(locator.ParentLocator__c).ActualOccupiedCapacityCBM__c += locator.ActualOccupiedCapacityCBM__c - oldActualOccupiedCapacityCBM;
                    
                }
                if(locator.ActualOccupiedCapacityKG__c != oldActualOccupiedCapacityKG){
                    mapParentsLocator.get(locator.ParentLocator__c).ActualOccupiedCapacityKG__c += locator.ActualOccupiedCapacityKG__c - oldActualOccupiedCapacityKG;
                    
                }
            }
            
            mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c == null? 0 : mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c;
            mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c == null? 0 : mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c;
           	locator.CapacityCBM__c = locator.CapacityCBM__c == null? 0: locator.CapacityCBM__c;
            locator.SharedCapacityKG__c = locator.SharedCapacityKG__c == null? 0: locator.SharedCapacityKG__c;
            
            if(mapOldLocators.get(locator.Id).ParentLocator__c != locator.ParentLocator__c){

                if(mapParentsLocator.containsKey(mapOldParentbyLocators.get(locator.Id))){
                    // thuc hien phep cong;
                    mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c + locator.CapacityCBM__c;
                    mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c + locator.CapacityKG__c;
                }
                if(mapParentsLocator.containsKey(locator.ParentLocator__c)){
                    //thuc hien phep tru
                    mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c - locator.CapacityCBM__c;
                    mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c - locator.CapacityKG__c;
                }
            }
            if(mapOldParentbyLocators.get(locator.Id) == locator.ParentLocator__c){
                if(locator.CapacityCBM__c != mapOldLocators.get(locator.Id).CapacityCBM__c){
                    mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityCBM__c + (locator.CapacityCBM__c - mapOldLocators.get(locator.Id).CapacityCBM__c);
                    
                }
                if(locator.CapacityKG__c != mapOldLocators.get(locator.Id).CapacityKG__c){
                    mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c = mapParentsLocator.get(locator.ParentLocator__c).SharedCapacityKG__c + (locator.CapacityKG__c - mapOldLocators.get(locator.Id).CapacityKG__c);
                }
            }

            
        }
        
        
        try{
            FlsService.doUpdate(mapParentsLocator.values());
        }catch(Exception ex){
            newLocators[0].addError(ex.getMessage());
        } 
    }
    
}