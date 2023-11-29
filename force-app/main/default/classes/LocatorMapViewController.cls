public with sharing class LocatorMapViewController {
    public static Id warehouseId {get; set;}
    public Facility__c currentWarehouse {get; set;}
    public Boolean isDisplayWarehouseList{get; set;}
    public List<Facility__c> listWarehouse {get; set;}
    public List<LOCATOR__c>  listLocator{get; set;}
    public LOCATOR__c  parentLocator{get; set;}
    public Boolean isParentsSelected {get; set;}
    public List<LOCATOR__c> listTree{get; set;}
    public WapperLocator locatorSearch{get; set;}
    public String query {get; set;}
    public Boolean isDisplayResultSearch{get; set;}
    public List<LOCATOR__c> resultSearchLocator{get; set;}

    //==================Pagination variable===============
    Public Integer sizeSearch{get;set;}
    public Integer sizeChildLocator{get;set;}
    public Integer sizeWarehouse{get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}

    public Integer indexTree{get;set;}
    public LocatorMapViewController(){
        isDisplayResultSearch = false;
        locatorSearch = new WapperLocator();
        isDisplayWarehouseList = false;
        isParentsSelected = false;
        resultSearchLocator = new List<LOCATOR__c>();
        parentLocator = new LOCATOR__c();
        listLocator = new List<LOCATOR__c>();

        warehouseId = ApexPages.currentPage().getParameters().get('warehouseId');
        listTree = new List<LOCATOR__c>();
        indexTree = 0;
        sizeSearch=10;
        sizeChildLocator=10;
        sizeWarehouse=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        if(	!String.isBlank(warehouseId)){
            currentWarehouse = getWarehouseInfomationById(warehouseId);
        }else{
            isDisplayWarehouseList = true;
            listWarehouse = [SELECT 
                               	Id, 
                               	FacilityName__c,
                                FacilityImage__c,
                                FacilityType__c,
                                WarehoueType__c,
                                CapacityCBM__c,
                                CapacityKG__c,
                                ChargeType__c,
                                StorageType__c,
								                  Name
                               FROM 
                               	Facility__c
                               WHERE Active__c = true
                               Limit 50000];
        }
    }

    public void doInit(){
    warehouseId = null;
    isDisplayResultSearch = false;
    currentWarehouse = new Facility__c();
    isDisplayWarehouseList = true;
    listLocator = new List<LOCATOR__c>();
    parentLocator = new LOCATOR__c();
    isParentsSelected = false;
    listTree = new List<LOCATOR__c>();
    indexTree = 0;
    listWarehouse = [SELECT 
                                Id, 
                                FacilityName__c,
                                FacilityImage__c,
                                FacilityType__c,
                                WarehoueType__c,
                                CapacityCBM__c,
                                CapacityKG__c,
                                ChargeType__c,
                                StorageType__c,
                                  Name
                               FROM 
                                Facility__c
                               WHERE Active__c = true
                               Limit 50000];
    setWarehouseList = new ApexPages.StandardSetController(listWarehouse);
    setWarehouseList.setPageSize(sizeWarehouse);
    setWarehouseList.setPageNumber(1);
    }
    
    public void viewLocators(){
      isDisplayWarehouseList = false;
      isDisplayResultSearch = false;
      warehouseId = ApexPages.currentPage().getParameters().get('warehouseId');
      String locatorParentId = ApexPages.currentPage().getParameters().get('locatorParentId');
      String indexTreeParam = ApexPages.currentPage().getParameters().get('indexTreeParam');
      String locatorLayer = ApexPages.currentPage().getParameters().get('locatorLayer');
      if(!String.isBlank(locatorParentId)){
        isParentsSelected = true;
        parentLocator = getLocatorById(locatorParentId);
        if(!String.isBlank(indexTreeParam)){
          //indexTree = Integer.valueOf(indexTreeParam);
          Integer index = Integer.valueOf(indexTreeParam);
          if(index == 0){
            listTree = new List<LOCATOR__c>();
          }else{
            if(indexTree < index){

                listTree.add(parentLocator); 

              }else{
                for(Integer i = listTree.size()-1; i > Integer.valueOf(indexTreeParam) - 1; i--){

                  listTree.remove(i);
                }
              }

          }

          indexTree = index;

        }else{
          if(!String.isBlank(locatorLayer)){
              if(locatorLayer == 'Floor Layer'){
                listTree.add(parentLocator);
              }
              if(locatorLayer == 'Area Layer'){
                LOCATOR__c locatorFloorLayer = getLocatorById(parentLocator.ParentLocator__c);
                listTree.add(locatorFloorLayer);
                listTree.add(parentLocator);
              }
               if(locatorLayer == 'Section Layer'){
                LOCATOR__c locatorAreaLayer = getLocatorById(parentLocator.ParentLocator__c);
                LOCATOR__c locatorFloorLayer = getLocatorById(locatorAreaLayer.ParentLocator__c);
                listTree.add(locatorFloorLayer);
                listTree.add(locatorAreaLayer);
                listTree.add(parentLocator);
              }
              if(locatorLayer == 'Rack Layer'){
                LOCATOR__c locatorSectionLayer = getLocatorById(parentLocator.ParentLocator__c);
                LOCATOR__c locatorAreaLayer = getLocatorById(locatorSectionLayer.ParentLocator__c);
                LOCATOR__c locatorFloorLayer = getLocatorById(locatorAreaLayer.ParentLocator__c);
                listTree.add(locatorFloorLayer);
                listTree.add(locatorAreaLayer);
                listTree.add(locatorSectionLayer);
                listTree.add(parentLocator);
              }
              if(locatorLayer == 'Level Layer'){
                LOCATOR__c locatorRackLayer = getLocatorById(parentLocator.ParentLocator__c);
                LOCATOR__c locatorSectionLayer = getLocatorById(locatorRackLayer.ParentLocator__c);
                LOCATOR__c locatorAreaLayer = getLocatorById(locatorSectionLayer.ParentLocator__c);
                LOCATOR__c locatorFloorLayer = getLocatorById(locatorAreaLayer.ParentLocator__c);
                listTree.add(locatorFloorLayer);
                listTree.add(locatorAreaLayer);
                listTree.add(locatorSectionLayer);
                listTree.add(locatorRackLayer);
                listTree.add(parentLocator);
              }
              
            }else{
              listTree.add(parentLocator);
              
            }
            indexTree = listTree.size();
          
        }

      }else{
        locatorParentId = null;
        isParentsSelected = false;
        parentLocator = new LOCATOR__c();
        listTree = new List<LOCATOR__c>();
        indexTree = 0;
      }
      currentWarehouse = getWarehouseInfomationById(warehouseId);
      listLocator = getLocatorListByWareHouse(warehouseId, locatorParentId);
      setChildLocators = new ApexPages.StandardSetController(listLocator);
      setChildLocators.setPageSize(sizeChildLocator);
      setChildLocators.setPageNumber(1);
    }
    private List<LOCATOR__c> getLocatorListByCode(Set<String> codes, String argWareHouseId){
      List<LOCATOR__c> listLocator = [SELECT 
                                          Id, 
                                          Name,
                                          CapacityCBM__c,
                                          CapacityKG__c,
                                          ActualAvailableCapacityCBM__c,
                                          ActualAvailableCapacityKG__c,
                                          ChargeType__c,
                                          LocatorCode__c,
                                          LocatorLayer__c,
                                          ActualOccupiedCapacityCBM__c,
                                          ActualOccupiedCapacityKG__c,
                                          CurrentOccupiedCapacityCBM__c,
                                          CurrentOccupiedCapacityKG__c,
                                          CurrentAvailableCapacityCBM__c,
                                          CurrentAvailableCapacityKG__c,
                                          SKU__c,
                                          Supplier__c,
                                          Tenant__c,
                                          FastSlowClassification__c,
                                          Buyer__c,
                                          SharedCapacityCBM__c,
                                          SharedCapacityKG__c,
                                          WarehouseID__c,
                                          WarehouseID__r.FacilityName__c,
                                          LocatorDescription__c
                                         FROM LOCATOR__c
                                         WHERE 
                                          WarehouseID__c =: argWareHouseId
                                         AND LocatorCode__c IN: codes
                                         ORDER BY LocatorCode__c asc];
        return listLocator;
    }
    public List<LOCATOR__c> getLocatorListByWareHouse(ID warehouseId, Id locatorParentId){
        List<LOCATOR__c> listLocator = [SELECT 
                                          Id, 
                                          Name,
                                          CapacityCBM__c,
                                          CapacityKG__c,
                                          ActualAvailableCapacityCBM__c,
                                          ActualAvailableCapacityKG__c,
                                          ChargeType__c,
                                          LocatorCode__c,
                                          LocatorLayer__c,
                                          ActualOccupiedCapacityCBM__c,
                                          ActualOccupiedCapacityKG__c,
                                          CurrentOccupiedCapacityCBM__c,
                                          CurrentOccupiedCapacityKG__c,
                                          CurrentAvailableCapacityCBM__c,
                                          CurrentAvailableCapacityKG__c,
                                          SKU__c,
                                          Supplier__c,
                                          Tenant__c,
                                          FastSlowClassification__c,
                                          Buyer__c,
                                          SharedCapacityCBM__c,
                                          SharedCapacityKG__c,
                                          WarehouseID__c,
                                          WarehouseID__r.FacilityName__c,
                                          LocatorDescription__c,
                                          ParentLocator__c
                                         FROM LOCATOR__c
                                         WHERE 
                                          ParentLocator__c =: locatorParentId
                                         AND WarehouseID__c =: warehouseId];
        return listLocator;
    }

    private LOCATOR__c getLocatorById(String idSelectedLocator){

      List<LOCATOR__c> listLocator = [SELECT Id, 
                                          Name,
                                          CapacityCBM__c,
                                          CapacityKG__c,
                                          ActualAvailableCapacityCBM__c,
                                          ActualAvailableCapacityKG__c,
                                          ChargeType__c,
                                          LocatorCode__c,
                                          LocatorLayer__c,
                                          ActualOccupiedCapacityCBM__c,
                                          ActualOccupiedCapacityKG__c,
                                          CurrentOccupiedCapacityCBM__c,
                                          CurrentOccupiedCapacityKG__c,
                                          CurrentAvailableCapacityCBM__c,
                                          CurrentAvailableCapacityKG__c,
                                          SKU__c,
                                          Supplier__c,
                                          Tenant__c,
                                          FastSlowClassification__c,
                                          Buyer__c,
                                          SharedCapacityCBM__c,
                                          SharedCapacityKG__c,
                                          WarehouseID__c,
                                          WarehouseID__r.FacilityName__c,
                                          LocatorDescription__c,
                                          ParentLocator__c
                                         FROM LOCATOR__c
                                         WHERE 
                                          Id =: idSelectedLocator];
      if(!listLocator.isEmpty()){

        return listLocator[0];
      }

      return new LOCATOR__c();

    }
    private Facility__c getWarehouseInfomationById(Id argWarehouseId){

      List<Facility__c> warehouses = [SELECT Id,
                                        Name,
                                        FacilityName__c,
                                        FacilityImage__c,
                                        FacilityType__c,
                                        WarehoueType__c,
                                        CapacityCBM__c,
                                        CapacityKG__c,
                                        ChargeType__c,
                                        StorageType__c,
                                        Address__c,
                                        ItemType__c,
                                        OwnershipType__c,
                                        OwnerCompanyName__c,
                                        RollUpActualOccupiedCapacityCBM__c,
                                        RollUpActualOccupiedCapacityKG__c,
                                        RollUpCurrentOccupiedCapacityCBM__c,
                                        RollUpCurrentOccupiedCapacityKG__c,
                                        RollUpMaxMeasurementCapacity__c,
                                        RollUpMaxWeightKGCapacity__c
                                      FROM 
                                        Facility__c 
                                      WHERE 
                                        Id=: warehouseId
                                     AND Active__c = true];
      if(!warehouses.isEmpty()){
        return warehouses[0];
      }

      return new Facility__c();
    }

    public void doSearch(){

      String strQuery = buildQuery(locatorSearch);
      query = strQuery;
      resultSearchLocator = Database.query(strQuery);
      setLocatorSearch = new ApexPages.StandardSetController(resultSearchLocator);
      isDisplayWarehouseList = false;
      isDisplayResultSearch = true;
      setLocatorSearch.setPageNumber(1);
      setLocatorSearch.setPageSize(sizeSearch);
    }

    private string buildQuery(WapperLocator objSearch){
      String strQuery = '';

      String strSelectField = 'SELECT Id, '
                                + 'Name, '        
                                + 'CapacityCBM__c, '       
                                + 'CapacityKG__c, '    
                                + 'ActualAvailableCapacityCBM__c, '        
                                + 'ActualAvailableCapacityKG__c, '
                                + 'ChargeType__c, '                 
                                + 'LocatorCode__c, '
                                + 'LocatorLayer__c, '
                                + 'ActualOccupiedCapacityCBM__c, '
                                + 'ActualOccupiedCapacityKG__c, '
                                + 'CurrentOccupiedCapacityCBM__c, ' 
                                + 'CurrentOccupiedCapacityKG__c, '
                                + 'CurrentAvailableCapacityCBM__c, '
                                + 'CurrentAvailableCapacityKG__c, '
                                + 'SKU__c, '
                                + 'Supplier__c, '
                                + 'Tenant__c, '
                                + 'FastSlowClassification__c, '
                                + 'Buyer__c, '
                                + 'SharedCapacityCBM__c, '
                                + 'SharedCapacityKG__c, '
                                + 'WarehouseID__c, '
                                + 'WarehouseID__r.FacilityName__c, '
                                + 'ParentLocator__c, '
                                + 'LocatorDescription__c '
                                + 'FROM LOCATOR__c';
      String strCondition ='';

      if(!String.isBlank(objSearch.locatorLayer)){
        strCondition = strCondition + ' AND LocatorLayer__c =\'' + String.escapeSingleQuotes(objSearch.locatorLayer) + '\'';
      }
      if(!String.isBlank(objSearch.warehouseName)){

        strCondition = strCondition + ' AND WarehouseID__r.FacilityName__c LIKE \'%' + String.escapeSingleQuotes(objSearch.warehouseName) + '%\'';
      }
      if(objSearch.currentAvailableCBM != null && objSearch.currentAvailableCBM > 0){

        strCondition = strCondition + ' AND CurrentAvailableCapacityCBM__c = ' + objSearch.currentAvailableCBM ;
      }
      if(objSearch.currentAvailableKG != null && objSearch.currentAvailableKG > 0){
        
        strCondition = strCondition + ' AND CurrentAvailableCapacityKG__c = ' + objSearch.currentAvailableKG ;
      }
      if(objSearch.actualAvailableCBM != null && objSearch.actualAvailableCBM > 0){
        
        strCondition = strCondition + ' AND ActualAvailableCapacityCBM__c = ' + objSearch.actualAvailableCBM ;
      }
      if(objSearch.actualAvailableKG != null && objSearch.actualAvailableKG > 0){
        strCondition = strCondition + ' AND ActualAvailableCapacityKG__c = ' + objSearch.actualAvailableKG ;
      }
      if(objSearch.locator.CapacityCBM__c > 0){
        strCondition = strCondition + ' AND CapacityCBM__c = ' + objSearch.locator.CapacityCBM__c ;
      }
      if(objSearch.locator.CapacityKG__c > 0){
        strCondition = strCondition + ' AND CapacityKG__c = ' + objSearch.locator.CapacityKG__c ;
      }
      if(objSearch.locator.Tenant__c != null){
        strCondition = strCondition + ' AND Tenant__c = \'' + String.escapeSingleQuotes(objSearch.locator.Tenant__c) +'\'';
      }

      if(objSearch.locator.Supplier__c != null){
        strCondition = strCondition + ' AND Supplier__c = \'' + String.escapeSingleQuotes(objSearch.locator.Supplier__c) + '\'' ;
      }
      if(objSearch.locator.Buyer__c != null){
        strCondition = strCondition + ' AND Buyer__c = \'' + String.escapeSingleQuotes(objSearch.locator.Buyer__c) +'\'';
      }

      if(objSearch.locator.ChargeType__c != null){
        strCondition = strCondition + ' AND ChargeType__c =\'' + String.escapeSingleQuotes(objSearch.locator.ChargeType__c) + '\' ' ;
      }
      if(objSearch.locator.SKU__c != null){
        List<String> listSKUvalues = new List<String>();
        String skuValues =  objSearch.locator.SKU__c.replaceAll(';', '\',\'');
        skuValues = '(\''+ skuValues+'\')';

        strCondition = strCondition + ' AND SKU__c IN ' +  skuValues ;
      }
      if(objSearch.locator.FastSlowClassification__c != null){
        strCondition = strCondition + ' AND FastSlowClassification__c = \'' + String.escapeSingleQuotes(objSearch.locator.FastSlowClassification__c) + '\'' ;
      }
      strCondition = strCondition.replaceFirst('AND', 'WHERE');
      strQuery = strSelectField + strCondition;
      return strQuery;
    }

    public List<SelectOption> getLayerPickList() {
      List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = LOCATOR__c.LocatorLayer__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      options.add(new SelectOption('','--None--'));
      for( Schema.PicklistEntry f : ple){
        options.add(new SelectOption(f.getValue(), f.getLabel()));
       }     
      return options;
    }
    public ApexPages.StandardSetController setLocatorSearch{
        get {
            if(setLocatorSearch == null) {
                setLocatorSearch = new ApexPages.StandardSetController(resultSearchLocator);
                setLocatorSearch.setPageSize(sizeSearch);
            }
            return setLocatorSearch;
        }
        set;
    }
    public ApexPages.StandardSetController setChildLocators {
        get {
            if(setChildLocators == null) {
                setChildLocators = new ApexPages.StandardSetController(listLocator);
                setChildLocators.setPageSize(sizeChildLocator);
            }
            return setChildLocators;
        }
        set;
    }
    public ApexPages.StandardSetController setWarehouseList {
        get {
            if(setWarehouseList == null) {
                setWarehouseList = new ApexPages.StandardSetController(listWarehouse);
                setWarehouseList.setPageSize(sizeWarehouse);
            }
            return setWarehouseList;
        }
        set;
    }

    public List<LOCATOR__c> getLocatorSearchResult() {
        return (List<LOCATOR__c>) setLocatorSearch.getRecords();
    }
    public List<LOCATOR__c> getChildLocatorResult() {
        return (List<LOCATOR__c>) setChildLocators.getRecords();
    }
    public List<Facility__c> getWarehouseResult() {
        return (List<Facility__c>) setWarehouseList.getRecords();
    }

    public PageReference refreshPageSizeSearch() {
         setLocatorSearch.setPageSize(sizeSearch);
         return null;
    }
    public PageReference refreshPageSizeChildLocator() {
         setChildLocators.setPageSize(sizeSearch);
         return null;
    }
    public PageReference refreshPageSizeWarehouse() {
         setWarehouseList.setPageSize(sizeSearch);
         return null;
    }
    Public Integer getTotalPageSearchs(){
     Decimal totalSize = setLocatorSearch.getResultSize();
     Decimal pageSize = setLocatorSearch.getPageSize();
     Decimal pages = totalSize/pageSize;
     return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    Public Integer getTotalPageChildLocators(){
     Decimal totalSize = setChildLocators.getResultSize();
     Decimal pageSize = setChildLocators.getPageSize();
     Decimal pages = totalSize/pageSize;
     return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    Public Integer getTotalPageWarehouses(){
     Decimal totalSize = setWarehouseList.getResultSize();
     Decimal pageSize = setWarehouseList.getPageSize();
     Decimal pages = totalSize/pageSize;
     return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    public class WapperLocator{

      public LOCATOR__c locator{get; set;}
      public String locatorLayer{get; set;}
      public Decimal currentAvailableCBM{get; set;}
      public Decimal currentAvailableKG {get; set;}
      public Decimal actualAvailableCBM{get; set;}
      public Decimal actualAvailableKG{get; set;}
      public String warehouseName{get; set;}

      public WapperLocator(){
        locator = new LOCATOR__c();
      }
    }
    

}