public with sharing class WareHouseController {

    // public clofor_com_cfs__CustomObject1__c objSearch {get; set;}
    public String message {get; set;}
    // public Boolean displayReportTable {get; set;}
    public List<clofor_com_cfs__CustomObject1__c> listshipment {get; set;}
    public List<ResultWrapper> arrResult {get; set;}
    public List<ResultWrapperConsol> arrResultConsol {get; set;}
    public String strQuery {get; set;}
    public String strQueryConsol {get; set;}
    public String consolID {get; set;}
    public Decimal sumCarton {get; set;}
    public Decimal sumWeight {get; set;}
    public Decimal sumCBM {get; set;}
    private static Set<String> setFields = new Set<String>();
    private static Set<String> setFieldConsols = new Set<String>();
    public String userName{get;set;}
    public String today{get;set;}
    public String ContainerNumber {get;set;}
    public String SealNo{get;set;}
    public String ContainerType{get;set;}
    public String MDevan{get;set;}
    public String Mpartner{get;set;}
    public String MVessel{get;set;}
    public String MVoyNo{get;set;}
    public String DateMBL{get;set;}
    public String MMasterBL{get;set;}

    static{
        setFields.add('Id');
        setFields.add('clofor_com_cfs__HBL_Number_SEA_AIR__c');
        setFields.add('clofor_com_cfs__DATE_OF_HOUSE_BL_ISSUED__c');
        setFields.add('clofor_com_cfs__ADDRESS_ON_B_L__c');
        setFields.add('clofor_com_cfs__Marks_and_Numbers__c');
        setFields.add('clofor_com_cfs__Item__c');
        setFields.add('clofor_com_cfs__UnitType__c');
        setFields.add('clofor_com_cfs__carton__c');
        setFields.add('clofor_com_cfs__weight__c');
        setFields.add('clofor_com_cfs__CBM__c');
    }

    static{
        setFieldConsols.add('Id');
        setFieldConsols.add('clofor_com_cfs__Consolidation__r.clofor_com_cfs__MDevanWarehouse__c');
        setFieldConsols.add('clofor_com_cfs__Consolidation__r.clofor_com_cfs__MPartner__c');
        setFieldConsols.add('clofor_com_cfs__Consolidation__r.clofor_com_cfs__MVessel__c');
        setFieldConsols.add('clofor_com_cfs__Consolidation__r.clofor_com_cfs__MVoy_No__c');
        setFieldConsols.add('clofor_com_cfs__Consolidation__r.Date_of_MBL_Issued__c');
        setFieldConsols.add('clofor_com_cfs__ContainerNO__c');
        setFieldConsols.add('clofor_com_cfs__SealNo__c');
        setFieldConsols.add('clofor_com_cfs__ContainerType__c');
        setFieldConsols.add('clofor_com_cfs__Consolidation__r.clofor_com_cfs__MMaster_B_L_No__c');
        // setFieldConsols.add('clofor_com_cfs__Consolidation__r.Date_of_MBL_Issued__c');
    }

    public WareHouseController(){
        arrResult = new List<ResultWrapper>();
        arrResultConsol = new List<ResultWrapperConsol>();
        ContainerNumber ='';
        SealNo ='';
        ContainerType ='';
        MDevan ='';
        Mpartner =''; 
        MVessel  ='';
        MVoyNo  ='';
        DateMBL  ='';
        MMasterBL  ='';
        // objSearch = new clofor_com_cfs__Anken__c();
        strQuery = '';
        strQueryConsol = '';
        // displayReportTable = false;
        String reportType = ApexPages.currentPage().getParameters().get('reportType');
        consolID = ApexPages.currentPage().getParameters().get('ID');
        userName = UserInfo.getName();
        today =  DateTime.now().format('yyyy/MM/dd hh:mm:ss');
        strQuery = stringQueryShipment(consolID);
        strQueryConsol = stringQueryConsol(consolID);
        // listconsol = Database.query(strQuery);
        arrResult = getData(strQuery);
        arrResultConsol = getDataConsol(strQueryConsol);

        // arrResult = getData(strQuery);
        // if(reportType == 'excel'){
            // displayReportTable = true;
            // String ankenIds = ApexPages.currentPage().getParameters().get('ankenIds');
            // Set<String> setShipId = new Set<String>();
            // String prmID = '';
            // String prmJobRequestID = '';
            // String prmMasterBL = '';
            // String prmHBL = '';
            // consolID = ApexPages.currentPage().getParameters().get('ID');
            // strQuery = stringQueryShipment(consolID);
            // arrResult = getData(strQuery);
        // }
    }

    // public void reset(){
        // arrResult = new List<ResultWrapper>();
        // objSearch = new clofor_com_cfs__Anken__c();
        // message = '';
        // displayReportTable = false;
    // }

    // public void generateReport(){
        // strQuery = stringQueryShipment(objSearch.ID__c);
        // arrResult = getData(strQuery);
        // if(arrResult.size() == 0){
            // message = 'No record.';
            // displayReportTable = false;
        // }
        // else displayReportTable = true;
    // }

    private List<ResultWrapper> getData(String strQuery){
        List<ResultWrapper> results = new List<ResultWrapper>();
        List<clofor_com_cfs__CustomObject1__c> listshipments = new List<clofor_com_cfs__CustomObject1__c>();
        Set<String> setShipId = new Set<String>();
        sumCarton = 0;
        sumWeight = 0;
        sumCBM = 0;
        listshipments = Database.query(strQuery);
        for(clofor_com_cfs__CustomObject1__c shipment : listshipments){
            setShipId.add(shipment.Id);
            ResultWrapper item = new ResultWrapper();
            item.shipmentId = String.valueOf(shipment.Id);
            item.shipment = shipment;
            item.HBLNumber = shipment.clofor_com_cfs__HBL_Number_SEA_AIR__c;
            item.DateOfHouseBLIssued = shipment.clofor_com_cfs__DATE_OF_HOUSE_BL_ISSUED__c;
            item.AddressOnBL = shipment.clofor_com_cfs__ADDRESS_ON_B_L__c;
            item.Item = shipment.clofor_com_cfs__Item__c;
            item.MarksAndNumbers = shipment.clofor_com_cfs__Marks_and_Numbers__c;
            item.UnitType = shipment.clofor_com_cfs__UnitType__c;
            item.weight = shipment.clofor_com_cfs__weight__c;
            if (shipment.clofor_com_cfs__weight__c != null){
                sumWeight += shipment.clofor_com_cfs__weight__c;
            }
            item.Carton = shipment.clofor_com_cfs__carton__c;
            if (shipment.clofor_com_cfs__carton__c != null){
                sumCarton += shipment.clofor_com_cfs__carton__c;
            }
            item.CBM = shipment.clofor_com_cfs__CBM__c;
            if (shipment.clofor_com_cfs__CBM__c != null){
                sumCBM += shipment.clofor_com_cfs__CBM__c;
            }
            results.add(item);
        }
        return results;
    }

    private List<ResultWrapperConsol> getDataConsol(String strQuery){
        List<ResultWrapperConsol> resultConsol = new List<ResultWrapperConsol>();
        List<clofor_com_cfs__ConsolCNTR__c> listConsol = new List<clofor_com_cfs__ConsolCNTR__c>();
        Set<String> setShipId = new Set<String>();
        listConsol = Database.query(strQuery);
        for(clofor_com_cfs__ConsolCNTR__c Consol : listConsol){
            setShipId.add(Consol.Id);
            ResultWrapperConsol item = new ResultWrapperConsol();
            item.ConsolId = String.valueOf(Consol.Id);
            item.Consol = Consol;
            item.ContainerNumber = Consol.clofor_com_cfs__ContainerNO__c;
            item.SealNo = Consol.clofor_com_cfs__SealNo__c;
            item.ContainerType = Consol.clofor_com_cfs__ContainerType__c;
            item.MDevan = Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MDevanWarehouse__c;
            item.Mpartner = Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MPartner__c;
            item.MVessel = Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MVessel__c;
            item.MVoyNo = Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MVoy_No__c;
            item.DateMBL = Consol.clofor_com_cfs__Consolidation__r.Date_of_MBL_Issued__c;
            item.MMasterBL = Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MMaster_B_L_No__c;
            resultConsol.add(item);
            ContainerNumber += Consol.clofor_com_cfs__ContainerNO__c;
            SealNo += Consol.clofor_com_cfs__SealNo__c;
            ContainerType += Consol.clofor_com_cfs__ContainerType__c;
            MDevan += Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MDevanWarehouse__c;
            Mpartner += Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MPartner__c;
            MVessel += Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MVessel__c;
            MVoyNo += Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MVoy_No__c;
            DateMBL += Consol.clofor_com_cfs__Consolidation__r.Date_of_MBL_Issued__c;
            MMasterBL += Consol.clofor_com_cfs__Consolidation__r.clofor_com_cfs__MMaster_B_L_No__c;
        }
        return resultConsol;
    }
    
    // private Map<String, List<clofor_com_cfs__Container_Info__c>> getContainerInfo(Set<String> setShipId){
        // Map<String, List<clofor_com_cfs__Container_Info__c>> mapConInfo = new Map<String, List<clofor_com_cfs__Container_Info__c>>();
        // List<clofor_com_cfs__Container_Info__c> conInfos = new List<clofor_com_cfs__Container_Info__c>();
        // conInfos = [ SELECT clofor_com_cfs__HBL_SHIPMENT__c, 
                            // clofor_com_cfs__GOODS__c, 
                            // clofor_com_cfs__GROSS_WEIGHT__c, 
                            // clofor_com_cfs__MEASUREMENT_CBM__c, 
                            // clofor_com_cfs__Container_NO__c, 
                            // clofor_com_cfs__Seal_No__c 
                    // FROM clofor_com_cfs__Container_Info__c 
                    // WHERE clofor_com_cfs__HBL_SHIPMENT__c IN :setShipId ];
        // for(clofor_com_cfs__Container_Info__c con : conInfos){
            // if(!mapConInfo.containsKey(con.clofor_com_cfs__HBL_SHIPMENT__c)){
                // mapConInfo.put(con.clofor_com_cfs__HBL_SHIPMENT__c, new List<clofor_com_cfs__Container_Info__c>());
            // }
            // if(!String.isBlank(con.GOODS__c)){
                // con.GOODS__c = con.GOODS__c.replaceAll('\n', '<br/>');
            // } 
            // mapConInfo.get(con.clofor_com_cfs__HBL_SHIPMENT__c).add(con);
        // }
        // return  mapConInfo;
    // }

    private String stringQueryshipment(String consolID){
        String strSelect = 'SELECT ' + String.join(new List<String>(setFields), ',');
        String strFrom = ' FROM clofor_com_cfs__CustomObject1__c ';
        String strWhere = 'WHERE clofor_com_cfs__MasterAnkenName__c = \'' + consolID + '\'' ;
        String strOrderBy = ' ORDER BY Name';
        return strSelect + strFrom + strWhere + strOrderBy;
    }

    private String stringQueryConsol(String consolID){
        String strSelect = 'SELECT ' + String.join(new List<String>(setFieldConsols), ',');
        String strFrom = ' FROM clofor_com_cfs__ConsolCNTR__c ';
        String strWhere = 'WHERE clofor_com_cfs__Consolidation__c = \'' + consolID + '\'' ;
        String strOrderBy = ' ORDER BY Name';
        return strSelect + strFrom + strWhere + strOrderBy;
    }

    // private String returnWhereCondition(String fieldSearch, String valueSearch){
        // String whereStr = '';
        // List<String> listValue = valueSearch.split(',');
        // for(String item : listValue){
            // whereStr += fieldSearch + ' LIKE \'%' + String.escapeSingleQuotes(item.trim()) + '%\' OR ';
        // }
        // if(!String.isBlank(whereStr)){
            // whereStr = ' AND (' + whereStr.removeEnd('OR ') + ')';
        // }
        // return whereStr;
    // }

    public class ResultWrapper{
        public clofor_com_cfs__CustomObject1__c shipment {get; set;}
        public String shipmentId {get; set;}
        public String HBLNumber {get; set;}
        public Date DateOfHouseBLIssued {get; set;}
        public String AddressOnBL {get; set;}
        public String MarksAndNumbers {get; set;}
        public String Item {get; set;}
        public String UnitType {get; set;}
        public Decimal Carton {get; set;}
        public Decimal weight {get; set;}
        public Decimal CBM {get; set;}

        public ResultWrapper(){
            this.shipment = new clofor_com_cfs__CustomObject1__c();
            this.shipmentId = '';
            this.HBLNumber = '';
            this.DateOfHouseBLIssued = date.today();
            this.AddressOnBL = '';
            this.MarksAndNumbers = '';
            this.Item = '';
            this.UnitType = '';
            this.Carton = 0;
            this.weight = 0;
            this.CBM = 0;
        }
    }
    public class ResultWrapperConsol{
        public clofor_com_cfs__ConsolCNTR__c Consol {get; set;}
        public String ConsolId {get; set;}
        public String SealNo {get; set;}
        public String ContainerNumber {get; set;}
        public String ContainerType {get; set;}
        public String MDevan {get; set;}
        public String Mpartner {get; set;}
        public String MVessel {get; set;}
        public String MVoyNo {get; set;}
        public Date DateMBL {get; set;}
        public String MMasterBL {get; set;}
        public ResultWrapperConsol(){
            this.Consol = new clofor_com_cfs__ConsolCNTR__c();
            this.ConsolId = '';
            this.SealNo = '';
            this.ContainerNumber = '';
            this.ContainerType = '';
            this.MDevan = '';
            this.Mpartner = '';
            this.MVessel = '';
            this.MVoyNo = '';
            this.DateMBL = date.today();
            this.MMasterBL = '';
        }
    }
}