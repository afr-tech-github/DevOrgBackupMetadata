public with sharing class PrintWOSReportController {
    
    public String titleVN {get; set;}
    public String titleEN {get; set;}
    public List<WOSLineItem__c> lstWOSLine {get; set;}
    public WorkOrderService__c wos {get; set;}
    public Map<String, Stock__c> mapStock {get; set;}
    public Decimal decWeight {get; set;}
    public Decimal decQuantity {get; set;}
    public Decimal decInitQuantity {get; set;}
    public Decimal decVarQuantity {get; set;}
    public Integer noOfRecords{get; set;}
    private String prmId {get; set;}
    private String prmRTId {get; set;}
    private Map<String, String> mapRTWOS {get; set;}
    private static final String RT_INBOUND_RECEIVING = 'InboundReceiving';
    private static final String RT_OUTBOUND_DISPATCH = 'OutboundDispatch';
    private static final String RT_PICKING = 'Picking';
    private static final String RT_PUTAWAY = 'Putaway';
    private static final String RT_TRANSFER_DISPATCH = 'TransferDispatch';
    private static final String RT_TRANSFER_RECEIVING = 'TransferReceiving';
    private static final String RT_VALUE_ADDED_SERVICE = 'ValueAddedService';
    public Map<String, String> translations{get; set;}
    public PrintWOSReportController(){
        translations = new Map<String, String>();
		translations = getTranslationMap();
        decWeight = 0;
        decQuantity = 0;
        decInitQuantity = 0;
        decVarQuantity = 0;
        titleVN = '';
        titleEN = '';
        wos = new WorkOrderService__c();
        lstWOSLine = new List<WOSLineItem__c>();
        mapStock = new Map<String, Stock__c>();
        prmId = ApexPages.currentPage().getParameters().get('wosId');
        prmRTId = ApexPages.currentPage().getParameters().get('rtype');
        if(prmId != null && prmRTId != null){
            Integer intLength = prmRTId.length();
            mapRTWOS = getRecordTypeWOS(intLength);
            
            wos = getWOSById(prmId);
            
            lstWOSLine = getListWOSLine(prmId);
            
            if(!lstWOSLine.isEmpty()){
                Set<Id> setWOSLId = (new Map<Id, WOSLineItem__c>(lstWOSLine)).keySet();
                mapStock = getStock(setWOSLId);
                for(WOSLineItem__c line : lstWOSLine){
                    if(!mapStock.containsKey(line.Id)){
                        mapStock.put(line.Id, new Stock__c());
                    }
                    if(!String.isBlank(String.valueOf(line.Cargo__r.Product__r.GrossWeight__c))){
                        decWeight += line.Cargo__r.Product__r.GrossWeight__c;
                    }/*
                    if(!String.isBlank(String.valueOf(line.Cargo__r.Quantity__c))){
                        decQuantity += line.Cargo__r.Quantity__c;
                    }*/
                    if(!String.isBlank(String.valueOf(line.Cargo__r.Product__r.QuantityPerUnit__c))){
                        decInitQuantity += line.Cargo__r.Product__r.QuantityPerUnit__c;
                    }
                    if(!String.isBlank(String.valueOf(line.WorkOrderService__r.VarianceQuantity__c))){
                        decVarQuantity += line.WorkOrderService__r.VarianceQuantity__c;
                    }
                }
            }
            
            if(mapRTWOS.get(prmRTId) == RT_INBOUND_RECEIVING){
                //titleVN = 'PHIẾU NHẬN HÀNG';
                //titleEN = 'GOODS RECEIPT NOTE';
                titleEN = 'good_receipt_note';
            }
            if(mapRTWOS.get(prmRTId) == RT_OUTBOUND_DISPATCH){
                //titleVN = 'PHIẾU GIAO HÀNG';
                //titleEN = 'DELIVERY NOTE';
                titleEN = 'delivery_note';
            }
            if(mapRTWOS.get(prmRTId) == RT_VALUE_ADDED_SERVICE){
                //titleVN = 'PHIẾU NHẬN HÀNG';
                //titleEN = 'GOODS RECEIPT NOTE';
               titleEN = 'good_receipt_note';
            }
            if(mapRTWOS.get(prmRTId) == RT_TRANSFER_DISPATCH){
                //titleVN = 'PHIẾU VẬN CHUYỂN NỘI BỘ';
                //titleEN = 'INTERNAL TRANSFER NOTE';
                titleEN = 'internal_transfer_note';
            }
            if(mapRTWOS.get(prmRTId) == RT_TRANSFER_RECEIVING){
                titleEN ='transfer_receiving_note';
            }
            
        }
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
        translateMapResult.put('','');
        return translateMapResult; 
    }
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(lstWOSLine);
                setCon.setPageSize(1000);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
    public List<WOSLineItem__c> getWOSLines(){
        return (List<WOSLineItem__c>) setCon.getRecords();
    }
    private Map<String, String> getRecordTypeWOS(Integer intLength){
        Map<String, String> mapRT = new Map<String, String>();
        List<RecordType> lstRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'clofor_com_cfs__WorkOrderService__c'];
        if(!lstRT.isEmpty()){
            for(RecordType rt : lstRT){
                mapRT.put(String.valueOf(rt.Id).substring(0, intLength), rt.DeveloperName);
            }
        }
        return mapRT;
    }
    
    private Map<String, Stock__c> getStock(Set<Id> setWOSLineId){
        Map<String, Stock__c> mapStock = new Map<String, Stock__c>();
        List<Stock__c> lstStock = new List<Stock__c>();
        lstStock = [ SELECT Id, ExpiredDate__c, WorkOrderServiceID__c, WorkOrderID__c, WOSLineID__c 
                        FROM Stock__c 
                        WHERE WOSLineID__c IN :setWOSLineId ];
        if(!lstStock.isEmpty()){
            for(Stock__c stock : lstStock){
                mapStock.put(stock.WOSLineID__c, stock);
            }
        }
        return mapStock;
    }
    
    private List<WOSLineItem__c> getListWOSLine(String woId){
        List<WOSLineItem__c> lstLine = new List<WOSLineItem__c>();
        lstLine = [ SELECT Id, Cargo__c, Cargo__r.Name, Cargo__r.QrCodeImage__c, Cargo__r.Product__c, Cargo__r.Product__r.Name, 
                            Cargo__r.ProductDetails__c, Cargo__r.ManufacturedDate__c, Cargo__r.ExpiredDate__c, Cargo__r.Product__r.QuantityPerUnit__c,  
                            WorkOrderService__r.VarianceQuantity__c, Cargo__r.Product__r.GrossWeight__c, Cargo__r.Product__r.UnitType__c,
                            WorkOrderService__r.TypeUnit__c, WorkOrderService__r.InitialQuantity__c, WorkOrderService__r.FinalQuantity__c, 
                            Cargo__r.Quantity__c, Cargo__r.CargoType__c, Cargo__r.Product__r.CodeImageType__c,
                            Cargo__r.Product__r.QR_Code__c  
                    FROM WOSLineItem__c 
                    WHERE WorkOrderService__c = :woId];
        return lstLine;
    }
    
    private WorkOrderService__c getWOSById(String wosId){
        List<WorkOrderService__c> lstWOS = new List<WorkOrderService__c>();
        lstWOS = [ SELECT Id, RecordTypeId, RecordType.Name, Name, DestinationWarehouseAddress__c, GrossWeightKG__c, 
                            ActualEndTime__c, GoodsPOID__c, CarrierCode__c, Carrier__c, Carrier__r.Name, Carrier__r.EnglishCompanyName__c, 
                            InitialQuantity__c, FinalQuantity__c, QuantityPerUnit__c, TypeUnit__c, Remarks__c, Owner.Name, 
                            VarianceQuantity__c, DestinationWarehouse__r.Name, Warehouse__r.Name, WarehouseName__c, GoodsPOID__r.Name, GoodsPOID__r.RecordType.Name,  
                            WorkOrder__r.CloFMSShipmentOrderID__r.ID__c, ActualStartTime__c, Carrier__r.AccountNumber, WorkOrder__r.CloFMSShipmentOrderID__r.Name, WorkOrder__r.CloFMSShipmentOrderID__r.WkInitial__c
                            ,WOSQRLabel__c 
                  FROM WorkOrderService__c 
                    WHERE Id = :wosId ];
        if(lstWOS.isEmpty()){
            
            return new WorkOrderService__c();
        }
        return lstWOS.get(0);
    }
    
}