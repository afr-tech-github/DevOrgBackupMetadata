public with sharing class SinglePickingNoteController {
    public Site_Custom_Settings__c siteSetting {get; set;}
    public WorkOrder__c wo {get; set;}
    public WorkOrderService__c wos{get; set;}
    public List<WOSLineItem__c> lstWOSLine{get; set;}
    public List<Cargo__c> listCargo{get; set;}
    private String prmWOID {get; set;}
    public Integer noOfRecords{get; set;}
    public Map<String, String> translations{get; set;}
    public SinglePickingNoteController() {
        translations = new Map<String, String>();
		translations = getTranslationMap();
        siteSetting = Site_Custom_Settings__c.getOrgDefaults();
        prmWOID = ApexPages.currentPage().getParameters().get('id');
        //wo = getWorkOrder(prmWOID);
        wos = getWorkOrderService(prmWOID);
        listCargo = new List<Cargo__c>();
        initData();
    }

    private void initData(){
        lstWOSLine = getAllWOSLineByWOS(prmWOID);
        Set<String> cargoIds = new Set<String>();
        for(WOSLineItem__c line : lstWOSLine){
            if(!String.isBlank(line.Cargo__c)){
                cargoIds.add(line.Cargo__c);
            }
        }
        listCargo = getAllCargo(cargoIds);
        
        
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
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(listCargo);
                setCon.setPageSize(1000);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
    public List<Cargo__c> getCargos(){
        return (List<Cargo__c>) setCon.getRecords();
    }
    public List<ConnectWOSWorker__c> getWorkerConnectedList(){
        List<ConnectWOSWorker__c> workers = [SELECT Id, Worker__c, Worker__r.Name, WorkOrderService__c FROM ConnectWOSWorker__c WHERE WorkOrderService__c =: prmWOID];
        //
        Set<Id> workerIds = new Set<Id>();
        List<ConnectWOSWorker__c> result = new List<ConnectWOSWorker__c>();
        for(ConnectWOSWorker__c ww : workers){
            if(!workerIds.contains(ww.Worker__c)){
                workerIds.add(ww.Worker__c);
                result.add(ww);
            }
        }
        return result;
    }
    private WorkOrderService__c getWorkOrderService(String strId){
        List<WorkOrderService__c> lstWOS = new List<WorkOrderService__c>();
        
        lstWOS = [ SELECT Name , Warehouse__c, Warehouse__r.Address__c, Warehouse__r.Name, Warehouse__r.FacilityName__c, GoodsSOID__r.SOQRLabel__c,
                        GoodsSOID__r.SalesOrderNumber__c, GoodsSOID__r.CreatedBy.Name,GoodsSOID__r.CreatedBy.Email,
                 		GoodsSOID__r.OrderDate__c, GoodsSOID__r.Name, GoodsSOID__r.SalesOrderType__c, GoodsSOID__r.CustomerCompanyName__r.AccountNumber, 
                 		GoodsSOID__r.CustomerCompanyName__r.Name, GoodsSOID__r.CustomerCompanyName__r.EnglishAddress__c, WorkOrder__c, WorkOrder__r.Name,
                        GoodsSOID__r.CustomerCompanyName__r.Phone,LastModifiedBy.Name, LastModifiedBy.Email, RecordType.DeveloperName,
                        WorkOrder__r.SalesOrderID__r.SOQRLabel__c, WorkOrder__r.SalesOrderID__r.CustomerCompanyName__r.Phone,
                        WorkOrder__r.SalesOrderID__r.SalesOrderNumber__c, WorkOrder__r.SalesOrderID__r.CreatedBy.Name,WorkOrder__r.SalesOrderID__r.CreatedBy.Email, WorkOrder__r.SalesOrderID__c,
                 		WorkOrder__r.SalesOrderID__r.OrderDate__c, WorkOrder__r.SalesOrderID__r.Name, WorkOrder__r.SalesOrderID__r.SalesOrderType__c, WorkOrder__r.SalesOrderID__r.CustomerCompanyName__r.AccountNumber, 
                 		WorkOrder__r.SalesOrderID__r.CustomerCompanyName__r.Name, WorkOrder__r.SalesOrderID__r.CustomerCompanyName__r.EnglishAddress__c
                	FROM WorkOrderService__c
                	WHERE Id =: strId];
        
        if(!lstWOS.isEmpty()){
            return lstWOS.get(0);
        }
        return new WorkOrderService__c();
    }
    
    private List<WOSLineItem__c> getAllWOSLineByWOS(String strWOId){
        List<WOSLineItem__c> lstWOSLine = new List<WOSLineItem__c>();
        lstWOSLine = [ SELECT Id, WorkOrderService__r.WorkOrder__c,  Cargo__c, Cargo__r.Name, Cargo__r.Product__r.QR_Code__c, WorkOrderService__c, Cargo__r.Product__c, Cargo__r.Product__r.Name, Cargo__r.Product__r.ProductName__c, Cargo__r.ProductDetails__c,
                      			WorkOrderService__r.TypeUnit__c, Cargo__r.Product__r.QuantityPerUnit__c, Cargo__r.QuantityPerUnit__c, Cargo__r.ManufacturedDate__c,  WorkOrderService__r.GrossWeightKG__c, WorkOrderService__r.NETWeightKG__c,
                                Cargo__r.ExpiredDate__c, Cargo__r.QuantityVarianceinUnit__c, Cargo__r.MissingQuantityinUnit__c, Cargo__r.CargoTroubleNote__c, Cargo__r.ExpireDateSKUNumber__c,
								Cargo__r.DamagedQuantityInUnit__c, Cargo__r.Product__r.GrossWeight__c, Cargo__r.Product__r.NETWeight__c,  Cargo__r.Product__r.Measurement__c,
                      			WorkOrderService__r.Measurement__c, Cargo__r.Product__r.BuyingCommercialValuePerUnitLocal__c, Locator__c, WorkOrderID__c, 
								//PurchasingOrderID__c,
                      			Cargo__r.Product__r.TaxRateBuying__c, Cargo__r.Product__r.UnitType__c, Cargo__r.Product__r.QR_Image__c
                        FROM WOSLineItem__c 
                        WHERE WorkOrderService__c = :strWOId];
        return lstWOSLine;
    }

    private List<Cargo__c> getAllCargo(Set<String> cargoIds){
        List<Cargo__c> lstCargo = new List<Cargo__c>();
        lstCargo = [ SELECT Id, Name, Product__r.QR_Code__c, LastWosLineItem__c, Product__c, Product__r.Name, Product__r.ProductName__c, ProductDetails__c,
                      			LastWosLineItem__r.WorkOrderService__r.TypeUnit__c, Product__r.QuantityPerUnit__c, QuantityPerUnit__c, ManufacturedDate__c,  
                                LastWosLineItem__r.WorkOrderService__r.GrossWeightKG__c, LastWosLineItem__r.WorkOrderService__r.NETWeightKG__c,CargoType__c,
                                ExpiredDate__c, QuantityVarianceinUnit__c, MissingQuantityinUnit__c, CargoTroubleNote__c, ExpireDateSKUNumber__c, QuantityInUnit__c,
								DamagedQuantityInUnit__c, Product__r.GrossWeight__c, Product__r.NETWeight__c,  Product__r.Measurement__c,LastWosLineItem__r.WorkOrderService__r.Name, 
                                LastWosLineItem__r.WorkOrderService__c, LastWosLineItem__r.WorkOrderService__r.Measurement__c, Product__r.BuyingCommercialValuePerUnitLocal__c, 
                                LastWosLineItem__r.Locator__c, LastWosLineItem__r.WorkOrderID__c, LastWosLineItem__r.WorkOrderID__r.Name, LastWosLineItem__r.Locator__r.Name, 
                                LastWosLineItem__r.Locator__r.LocatorCode__c,LastWosLineItem__r.WorkOrderID__r.PurchasingOrderID__r.Name, LastWosLineItem__r.WorkOrderID__r.PurchasingOrderID__c,
                      			Product__r.TaxRateBuying__c, Product__r.UnitType__c, Product__r.QR_Image__c,Product__r.QRCodeImage__c,Product__r.BarCodeImage__c, Product__r.CodeImageType__c, 
                                QrCodeImage__c, Remark__c, AcceptedQuantityInUnit__c, Product__r.LOTNumber__c
                        FROM Cargo__c 
                        WHERE Id IN: cargoIds];
        return lstCargo;
    }
    public Map<String, String> getSoTypeMap(){
        Map<String, String> pickListValuesMap= new Map<String, String>();
		Schema.DescribeFieldResult fieldResult = SALES_ORDER__c.SalesOrderType__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
		}     
		return pickListValuesMap;
    }
}