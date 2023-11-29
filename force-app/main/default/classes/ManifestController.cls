public with sharing class ManifestController {

    public clofor_com_cfs__CustomObject1__c objSearch {get; set;}
    public String message {get; set;}
    public Boolean displayReportTable {get; set;}
    public List<ResultWrapper> arrResult {get; set;}

    public String strQuery {get; set;}
    private static Set<String> setFields = new Set<String>();
    public String jobRequestId {get; set;}
    public String hbl {get; set;}

    static{
        setFields.add('Id');
        setFields.add('clofor_com_cfs__shipper__r.clofor_com_cfs__TAX_CODE__c');
        setFields.add('clofor_com_cfs__shipper__c');
        setFields.add('clofor_com_cfs__shipper__r.clofor_com_cfs__EnglishCompanyName__c');
        setFields.add('clofor_com_cfs__shipper__r.clofor_com_cfs__EnglishAddress__c');
        setFields.add('clofor_com_cfs__Cnee__r.clofor_com_cfs__TAX_CODE__c');
        setFields.add('clofor_com_cfs__Cnee__c');
        setFields.add('clofor_com_cfs__Cnee__r.clofor_com_cfs__EnglishCompanyName__c');
        setFields.add('clofor_com_cfs__Cnee__r.clofor_com_cfs__EnglishAddress__c');
        setFields.add('clofor_com_cfs__Notifyparty__c');
        setFields.add('clofor_com_cfs__Notifyparty__r.clofor_com_cfs__EnglishCompanyName__c');
        setFields.add('clofor_com_cfs__Notifyparty__r.clofor_com_cfs__TAX_CODE__c');
        setFields.add('clofor_com_cfs__Notifyparty__r.clofor_com_cfs__EnglishAddress__c');
        setFields.add('clofor_com_cfs__SecondNotifyParty__c');
        setFields.add('clofor_com_cfs__SecondNotifyParty__r.clofor_com_cfs__EnglishCompanyName__c');
        setFields.add('clofor_com_cfs__SecondNotifyParty__r.clofor_com_cfs__TAX_CODE__c');
        setFields.add('clofor_com_cfs__SecondNotifyParty__r.clofor_com_cfs__EnglishAddress__c');
        setFields.add('clofor_com_cfs__X2nd_Notify_Party__c');
        setFields.add('clofor_com_cfs__X2nd_Notify_Party__r.clofor_com_cfs__EnglishCompanyName__c');
        setFields.add('clofor_com_cfs__X2nd_Notify_Party__r.clofor_com_cfs__TAX_CODE__c');
        setFields.add('clofor_com_cfs__X2nd_Notify_Party__r.clofor_com_cfs__EnglishAddress__c');
        setFields.add('clofor_com_cfs__TransitPortCode__c');
        setFields.add('clofor_com_cfs__FinalDestination__c');
        setFields.add('clofor_com_cfs__FinalDestination__r.clofor_com_cfs__CodeOfPort__c');
        setFields.add('clofor_com_cfs__POL__c');
        setFields.add('clofor_com_cfs__POL__r.clofor_com_cfs__CodeOfPort__c');
        setFields.add('clofor_com_cfs__POD__c');
        setFields.add('clofor_com_cfs__POD__r.clofor_com_cfs__CodeOfPort__c');
        setFields.add('clofor_com_cfs__Place_Of_Delivery__c');
        setFields.add('clofor_com_cfs__Place_Of_Delivery__r.Name');
        setFields.add('clofor_com_cfs__CARGO_TYPE__c');
        setFields.add('clofor_com_cfs__HBL__c');
        setFields.add('clofor_com_cfs__DATE_OF_HOUSE_BL_ISSUED__c');
        setFields.add('clofor_com_cfs__Master_B_L__c');
        setFields.add('clofor_com_cfs__DATE_OF_MASTER_BL_ISSUED__c');
        setFields.add('clofor_com_cfs__ETD__c');
        setFields.add('clofor_com_cfs__carton__c');
        setFields.add('clofor_com_cfs__UnitType__c');
        setFields.add('clofor_com_cfs__weight__c');
        setFields.add('clofor_com_cfs__Remarks__c');
        setFields.add('clofor_com_cfs__ADDRESS_ON_B_L__c');
        setFields.add('clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c');
        setFields.add('clofor_com_cfs__NOTIFY_ADDRESS_ON_B_L__c');
        setFields.add('clofor_com_cfs__PackageUnitCode__c');
        setFields.add('clofor_com_cfs__JobRequestID__c');
        setFields.add('clofor_com_cfs__RemarkonManifest__c');
        //setFields.add('clofor_com_cfs__HSCode__r.Name');
        setFields.add('clofor_com_cfs__Item__c');
        setFields.add('clofor_com_cfs__GOODS_ATTACHMENT__c');
        setFields.add('clofor_com_cfs__ETD_Formula__c');
    }

    public ManifestController(){
        arrResult = new List<ResultWrapper>();
        objSearch = new clofor_com_cfs__CustomObject1__c();
        message = '';
        strQuery = '';
        jobRequestId = 'JobID';
        hbl = 'HBL';
        displayReportTable = false;
        String reportType = ApexPages.currentPage().getParameters().get('reportType');
        if(reportType == 'excel'){
            displayReportTable = true;
            String ankenIds = ApexPages.currentPage().getParameters().get('ankenIds');
            Set<String> setShipId = new Set<String>();
            String prmID = '';
            String prmJobRequestID = '';
            String prmMasterBL = '';
            String prmHBL = '';
            if(!String.isBlank(ankenIds)){
                setShipId.addAll(ankenIds.split(','));
            }
            else{
                prmID = ApexPages.currentPage().getParameters().get('ID');
                prmJobRequestID = ApexPages.currentPage().getParameters().get('JobRequestID');
                prmMasterBL = ApexPages.currentPage().getParameters().get('MasterBL');
                prmHBL = ApexPages.currentPage().getParameters().get('HBL');
            }
            strQuery = stringQueryShipment(prmID, prmJobRequestID, prmMasterBL, prmHBL, setShipId);
            arrResult = getData(strQuery);
            if(arrResult.size() > 0){
                if(!String.isBlank(String.valueOf(arrResult.get(0).shipment.clofor_com_cfs__JobRequestID__c))){
                    jobRequestId = String.valueOf(arrResult.get(0).shipment.clofor_com_cfs__JobRequestID__c);
                }
                if(!String.isBlank(String.valueOf(arrResult.get(0).shipment.clofor_com_cfs__HBL__c))){
                    hbl = String.valueOf(arrResult.get(0).shipment.clofor_com_cfs__HBL__c);
                }
            }
        }
    }

    public void reset(){
        arrResult = new List<ResultWrapper>();
        objSearch = new clofor_com_cfs__CustomObject1__c();
        message = '';
        displayReportTable = false;
    }

    public void generateReport(){
        strQuery = stringQueryShipment(objSearch.ID__c, objSearch.JobRequestID__c, objSearch.Master_B_L__c, objSearch.HBL__c, new Set<String>());
        arrResult = getData(strQuery);
        if(arrResult.size() == 0){
            message = 'No record.';
            displayReportTable = false;
        }
        else displayReportTable = true;
    }

    private List<ResultWrapper> getData(String strQuery){
        List<ResultWrapper> results = new List<ResultWrapper>();
        List<clofor_com_cfs__CustomObject1__c> shipments = new List<clofor_com_cfs__CustomObject1__c>();
        Set<String> setShipId = new Set<String>();
        shipments = Database.query(strQuery);
        for(clofor_com_cfs__CustomObject1__c ship : shipments){
            setShipId.add(ship.Id);
            ResultWrapper item = new ResultWrapper();
            item.shipmentId = String.valueOf(ship.Id);
            item.shipment = ship;
            if(ship.clofor_com_cfs__Notifyparty__c == ship.clofor_com_cfs__Cnee__c){
                item.notifyPart1 = 'SAME AS CONSIGNEE';
            }
            else if(!String.isBlank(ship.clofor_com_cfs__Notifyparty__c)){
                // item.notifyPart1 = ship.clofor_com_cfs__Notifyparty__r.clofor_com_cfs__TAX_CODE__c +'#'+ship.clofor_com_cfs__Notifyparty__r.clofor_com_cfs__EnglishCompanyName__c.replaceAll('\n', '<br/>')+'#'+ship.clofor_com_cfs__Notifyparty__r.clofor_com_cfs__EnglishAddress__c;
                item.notifyPart1 = '';
            }

            if(ship.clofor_com_cfs__X2nd_Notify_Party__c == ship.clofor_com_cfs__Cnee__c){
                item.notifyPart2 = 'SAME AS CONSIGNEE';
            }
            else if(!String.isBlank(ship.clofor_com_cfs__X2nd_Notify_Party__r.EnglishCompanyName__c)){
                // item.notifyPart2 = ship.clofor_com_cfs__X2nd_Notify_Party__r.clofor_com_cfs__TAX_CODE__c +'#'+ship.clofor_com_cfs__X2nd_Notify_Party__r.EnglishCompanyName__c.replaceAll('\n', '<br/>')+'#'+ship.clofor_com_cfs__X2nd_Notify_Party__r.clofor_com_cfs__EnglishAddress__c;
                item.notifyPart2 = '';
            }

            if(!String.isBlank(ship.clofor_com_cfs__ADDRESS_ON_B_L__c)){
                item.shipment.clofor_com_cfs__ADDRESS_ON_B_L__c = ship.clofor_com_cfs__ADDRESS_ON_B_L__c.replaceAll('\n', '<br/>');
            }
            
            if(!String.isBlank(ship.clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c)){
                item.shipment.clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c = ship.clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c.replaceAll('\n', '<br/>');
            }

            if(!String.isBlank(ship.Remarks__c)){
                item.shipment.Remarks__c = ship.Remarks__c.replaceAll('\n', '<br/>');
            }
            if(!String.isBlank(ship.RemarkonManifest__c)){
                item.shipment.RemarkonManifest__c = ship.RemarkonManifest__c.replaceAll('\n', '<br/>');
            }
            if(!String.isBlank(ship.clofor_com_cfs__Item__c)){
                if(!String.isBlank(ship.clofor_com_cfs__GOODS_ATTACHMENT__c)){
                    item.shipment.clofor_com_cfs__Item__c += '<br/>';
                }
                item.shipment.clofor_com_cfs__Item__c = ship.clofor_com_cfs__Item__c.replaceAll('\n', '<br/>');
            }
            if(!String.isBlank(ship.clofor_com_cfs__GOODS_ATTACHMENT__c)){
                item.shipment.clofor_com_cfs__GOODS_ATTACHMENT__c = ship.clofor_com_cfs__GOODS_ATTACHMENT__c.replaceAll('\n', '<br/>');
            }
            
            results.add(item);
        }

        Map<String, List<clofor_com_cfs__Container_Info__c>> mapConInfo = getContainerInfo(setShipId);
        for(ResultWrapper item : results){
            if(mapConInfo.containsKey(item.shipmentId)){
                item.arrConInfo = mapConInfo.get(item.shipmentId);
            }
        }

        return results;
    }

    private Map<String, List<clofor_com_cfs__Container_Info__c>> getContainerInfo(Set<String> setShipId){
        Map<String, List<clofor_com_cfs__Container_Info__c>> mapConInfo = new Map<String, List<clofor_com_cfs__Container_Info__c>>();
        List<clofor_com_cfs__Container_Info__c> conInfos = new List<clofor_com_cfs__Container_Info__c>();
        conInfos = [ SELECT clofor_com_cfs__HBL_SHIPMENT__c, 
                            clofor_com_cfs__GOODS__c, 
                            clofor_com_cfs__GROSS_WEIGHT__c, 
                            clofor_com_cfs__MEASUREMENT_CBM__c, 
                            clofor_com_cfs__Container_NO__c, 
                            clofor_com_cfs__Seal_No__c 
                    FROM clofor_com_cfs__Container_Info__c 
                    WHERE clofor_com_cfs__HBL_SHIPMENT__c IN :setShipId ];
        for(clofor_com_cfs__Container_Info__c con : conInfos){
            if(!mapConInfo.containsKey(con.clofor_com_cfs__HBL_SHIPMENT__c)){
                mapConInfo.put(con.clofor_com_cfs__HBL_SHIPMENT__c, new List<clofor_com_cfs__Container_Info__c>());
            }
            if(!String.isBlank(con.GOODS__c)){
                con.GOODS__c = con.GOODS__c.replaceAll('\n', '<br/>');
            } 
            mapConInfo.get(con.clofor_com_cfs__HBL_SHIPMENT__c).add(con);
        }
        return  mapConInfo;
    }

    private String stringQueryShipment(String prmID, String prmJobRequestID, String prmMasterBL, String prmHBL, Set<String> setIds){
        String strSelect = 'SELECT ' + String.join(new List<String>(setFields), ',');
        String strFrom = ' FROM clofor_com_cfs__CustomObject1__c ';
        String strWhere = '';
        String strOrderBy = ' ORDER BY Name';

        if(setIds.size() > 0){
            String condIds = '';
            for(String shipId : setIds){
                condIds += '\'' + shipId + '\',';
            }
            condIds = '(' + condIds.removeEnd(',') + ')';
            strWhere += 'AND Id IN ' + condIds;
        }

        if(!String.isBlank(prmID)){
            strWhere += returnWhereCondition('ID__c', String.escapeSingleQuotes(prmID));
        }

        if(!String.isBlank(prmJobRequestID)){
            strWhere += returnWhereCondition('JobRequestID__c', String.escapeSingleQuotes(prmJobRequestID));
        }

        if(!String.isBlank(prmMasterBL)){
            strWhere += returnWhereCondition('Master_B_L__c', String.escapeSingleQuotes(prmMasterBL));
        }

        if(!String.isBlank(prmHBL)){
            strWhere += returnWhereCondition('HBL__c', String.escapeSingleQuotes(prmHBL));
        }

        if(!String.isBlank(strWhere)) {
            strWhere = strWhere.replaceFirst('AND', 'WHERE');
        }
        return strSelect + strFrom + strWhere + strOrderBy;
    }

    private String returnWhereCondition(String fieldSearch, String valueSearch){
        String whereStr = '';
        List<String> listValue = valueSearch.split(',');
        for(String item : listValue){
            whereStr += fieldSearch + ' LIKE \'%' + String.escapeSingleQuotes(item.trim()) + '%\' OR ';
        }
        if(!String.isBlank(whereStr)){
            whereStr = ' AND (' + whereStr.removeEnd('OR ') + ')';
        }
        return whereStr;
    }

    public class ResultWrapper{
        public String shipmentId {get; set;}
        public clofor_com_cfs__CustomObject1__c shipment {get; set;}
        public String notifyPart1 {get; set;}
        public String notifyPart2 {get; set;}
        public List<clofor_com_cfs__Container_Info__c> arrConInfo {get; set;}

        public ResultWrapper(){
            this.shipmentId = '';
            this.shipment = new clofor_com_cfs__CustomObject1__c();
            this.notifyPart1 = '';
            this.notifyPart2 = '';
            this.arrConInfo = new List<clofor_com_cfs__Container_Info__c>();
        }
    }

}