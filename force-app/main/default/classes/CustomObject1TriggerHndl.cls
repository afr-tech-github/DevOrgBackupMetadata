/**
* CustomObject1TriggerHndl
* @created: 2019/07/06 Chien Truong
* @modified:
*/
public with sharing class CustomObject1TriggerHndl {
    private static final Integer MAX_CODE_YEAR = 6;
    private static final Integer MAX_CODE_MONTH = 4;
    // 2021/08/19 Chien Truong DELETE START
    // private static final String BL_TYPE = 'H B/L Issue Required';
    // 2021/08/19 Chien Truong DELETE END

    public void onBeforeInsert(List<CustomObject1__c> newCustomObject1List) {
        clofor_com_cfs__Site_Custom_Settings__c cusSetting = [Select Id, Name, clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c From clofor_com_cfs__Site_Custom_Settings__c];
        try {
            //QuanDo Add Deadline Alert start
            for (clofor_com_cfs__CustomObject1__c cus : newCustomObject1List) {
                if (cus.clofor_com_cfs__AlertDebitIssuedBefore__c != null && cus.clofor_com_cfs__DeliveryDate__c != null){
                    Integer numberDate = Integer.valueOf(cus.clofor_com_cfs__AlertDebitIssuedBefore__c);
                    Date deliveryDate = cus.clofor_com_cfs__DeliveryDate__c;
                    Datetime deliveryDatetime = (Datetime)cus.clofor_com_cfs__DeliveryDate__c;
                    Integer dayOfWeek = Integer.valueOf(String.valueOf(deliveryDatetime.format('u')));
                    Integer daySuns = 0;
                    Integer totalDates = 0;
                    if ((7 - dayOfWeek) == 0){
                        daySuns = numberDate/7;
                    } else {
                        if (math.mod(numberDate, 7) >= (7-dayOfWeek)) {
                            daySuns = numberDate/7 + 1;
                        } else {
                            daySuns = numberDate/7;
                        }
                    }
                    totalDates = numberDate + daySuns;
                    Datetime deadline = deliveryDatetime.addDays(totalDates);
                    if (Integer.valueOf(String.valueOf(deadline.format('u'))) == 7){
                        cus.clofor_com_cfs__DebitIssuedDeadline__c = deliveryDate.addDays(totalDates +1);
                    } else {
                        cus.clofor_com_cfs__DebitIssuedDeadline__c = deliveryDate.addDays(totalDates);
                    }
                }
            }
            //QuanDo Add Deadline Alert end
            Map<Integer, ItemDTO> dataCodeMap = this.createCodeNextMap(newCustomObject1List);
            Map<String, Id> mapRecordTypes = retrieveRecordTypeIdsByNames();
            for (clofor_com_cfs__CustomObject1__c objNewCustomObject1 : newCustomObject1List) {
                Date accountedDate = objNewCustomObject1.clofor_com_cfs__SalesAccountedDate__c;
                if (accountedDate == null) {
                    continue;
                }
                //QuanDo Add 2022/07/13
                if (objNewCustomObject1.SalesAccountedDate__c == null || objNewCustomObject1.isClone()) {
                    if (objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_LOCK_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_LOCK_RT)){
                        objNewCustomObject1.SalesAccountedDate__c = objNewCustomObject1.ETD__c;
                    } else if (objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_LOCK_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_LOCK_RT)){
                        objNewCustomObject1.SalesAccountedDate__c = objNewCustomObject1.ETA__c;
                    } else {
                        objNewCustomObject1.SalesAccountedDate__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
                    }
                }
                //QuanDo End 2022/07/13
                Integer year = accountedDate.year();
                Integer month = accountedDate.month();
                
                Integer codeYearNext = 0;
                Integer codeMonthNext = 0;

                ItemDTO objDTO = new ItemDTO();
                if (dataCodeMap.containsKey(year)) {
                    objDTO = dataCodeMap.get(year);
                    codeYearNext = objDTO.codeYearly + 1;

                    if (objDTO.codeMonthlyMap.containsKey(month)) {
                        codeMonthNext = objDTO.codeMonthlyMap.get(month) + 1;
                    } else {
                        codeMonthNext += 1;
                    }
                } else {
                    codeYearNext += 1;
                    codeMonthNext += 1;                    
                } 

                objDTO.codeYearly = codeYearNext;
                objDTO.codeMonthlyMap.put(month, codeMonthNext);
                dataCodeMap.put(year, objDTO);
                if(cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c != true){
                    if (String.isBlank(objNewCustomObject1.YearlyFMSSOID__c )) {
                        objNewCustomObject1.YearlyFMSSOID__c = this.createCodeNext(codeYearNext, MAX_CODE_YEAR);
                    }
    
                    if (String.isBlank(objNewCustomObject1.MonthlyFMSSOID__c )) {
                        objNewCustomObject1.MonthlyFMSSOID__c = this.createCodeNext(codeMonthNext, MAX_CODE_MONTH);
                    }
                }else {
                    objNewCustomObject1.YearlyFMSSOID__c = null;
                    objNewCustomObject1.MonthlyFMSSOID__c = null;
                }
              
            }
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }

    public void onAfterInsert(Map<Id, CustomObject1__c> newCustomObject1Map) {
        try {
            List<CustomObject1__c> newCustomObject1List = [SELECT Id, clofor_com_cfs__BL_TYPE__c, CreatedDate,ETA__c,ETD__c,RecordTypeId,SalesAccountedDate__c FROM CustomObject1__c WHERE Id =: newCustomObject1Map.keySet()];
            Map<Date, Integer> dateCodeMap = this.createCodeMonthHBLIDNextMap(newCustomObject1List);
            Map<String, Id> mapRecordTypes = retrieveRecordTypeIdsByNames();
            clofor_com_cfs__Site_Custom_Settings__c cusSetting = [Select Id, Name, clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c From clofor_com_cfs__Site_Custom_Settings__c];
            List<CustomObject1__c> customObject1UpdateList = new List<CustomObject1__c>();
            for (CustomObject1__c objNewCustomObject1 : newCustomObject1List) {
                Date dateETD = Date.newInstance(objNewCustomObject1.CreatedDate.year(), objNewCustomObject1.CreatedDate.month(), 1);
                Integer codeMonthHBLIDNext = 0; 
                if (dateCodeMap.containsKey(dateETD)) {
                    codeMonthHBLIDNext = dateCodeMap.get(dateETD);
                }
                
                codeMonthHBLIDNext += 1;
                dateCodeMap.put(dateETD, codeMonthHBLIDNext);
                System.debug('Checkmonth1 :'+cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c);
                if(cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c != true){
                    objNewCustomObject1.MonthlyHBLID__c = this.createCodeNext(codeMonthHBLIDNext, MAX_CODE_MONTH);
                }
                

                // Accounted Date
                // if (objNewCustomObject1.SalesAccountedDate__c == null) {
                    // objNewCustomObject1.SalesAccountedDate__c = Date.newInstance(objNewCustomObject1.CreatedDate.year(), objNewCustomObject1.CreatedDate.month(), objNewCustomObject1.CreatedDate.day());
                // }
                //QuanDo Add 2022/05/30
                if (objNewCustomObject1.SalesAccountedDate__c == null) {
                    if (objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_LOCK_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_LOCK_RT)){
                        objNewCustomObject1.SalesAccountedDate__c = objNewCustomObject1.ETD__c;
                    } else if (objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_LOCK_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_RT) || objNewCustomObject1.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_LOCK_RT)){
                        objNewCustomObject1.SalesAccountedDate__c = objNewCustomObject1.ETA__c;
                    } else {
                        objNewCustomObject1.SalesAccountedDate__c = Date.newInstance(objNewCustomObject1.CreatedDate.year(), objNewCustomObject1.CreatedDate.month(), objNewCustomObject1.CreatedDate.day());
                    }
                }
                //QuanDo End 2022/05/30

                
                customObject1UpdateList.add(objNewCustomObject1);
            }
            
            if (!customObject1UpdateList.isEmpty()) {
                FlsService.doUpdate(customObject1UpdateList);
            }
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }
    
    public void onBeforeUpdate(Map<Id, CustomObject1__c> oldCustomObject1Map, List<CustomObject1__c> newCustomObject1List) {
        clofor_com_cfs__Site_Custom_Settings__c cusSetting = [Select Id, Name, clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c From clofor_com_cfs__Site_Custom_Settings__c];
        try {       
            //QuanDo Add Deadline Alert start
            for (clofor_com_cfs__CustomObject1__c cus : newCustomObject1List) {
                if (cus.clofor_com_cfs__AlertDebitIssuedBefore__c != null && cus.clofor_com_cfs__DeliveryDate__c != null){
                    Integer numberDate = Integer.valueOf(cus.clofor_com_cfs__AlertDebitIssuedBefore__c);
                    Date deliveryDate = cus.clofor_com_cfs__DeliveryDate__c;
                    Datetime deliveryDatetime = (Datetime)cus.clofor_com_cfs__DeliveryDate__c;
                    Integer dayOfWeek = Integer.valueOf(String.valueOf(deliveryDatetime.format('u')));
                    Integer daySuns = 0;
                    Integer totalDates = 0;
                    if ((7 - dayOfWeek) == 0){
                        daySuns = numberDate/7;
                    } else {
                        if (math.mod(numberDate, 7) >= (7-dayOfWeek)) {
                            daySuns = numberDate/7 + 1;
                        } else {
                            daySuns = numberDate/7;
                        }
                    }
                    totalDates = numberDate + daySuns;
                    Datetime deadline = deliveryDatetime.addDays(totalDates);
                    if (Integer.valueOf(String.valueOf(deadline.format('u'))) == 7){
                        cus.clofor_com_cfs__DebitIssuedDeadline__c = deliveryDate.addDays(totalDates +1);
                    } else {
                        cus.clofor_com_cfs__DebitIssuedDeadline__c = deliveryDate.addDays(totalDates);
                    }
                }
            }
            //QuanDo Add Deadline Alert end        
                     
            // 2021/07/23 Chien Truong ADD START
            Map<Id, List<Container_Info__c>> containerInfosPerShipment = new Map<Id, List<Container_Info__c>>();
            for (Container_Info__c containerInfo : [
                    SELECT Container_No__c, Seal_No__c, Container__c, QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, NET_WEIGHT__c, MEASUREMENT_CBM__c, GOODS__c, HBL_SHIPMENT__c, CargoTypeUnit__c
                    FROM Container_Info__c
                    WHERE HBL_SHIPMENT__c IN :oldCustomObject1Map.keySet()
            ]) {
                List<Container_Info__c> containerInfos = containerInfosPerShipment.get(containerInfo.HBL_SHIPMENT__c);
                if (containerInfos == null || containerInfos.isEmpty()) {
                    containerInfos = new List<Container_Info__c>();
                    containerInfosPerShipment.put(containerInfo.HBL_SHIPMENT__c, containerInfos);
                }
    
                containerInfos.add(containerInfo);
            }
            // 2021/07/23 Chien Truong ADD END

            Map<Date, Integer> CodeMonthHBLIDMap = this.createCodeMonthHBLIDNextMap(newCustomObject1List);
            Map<Integer, ItemDTO> dataCodeMap = this.createCodeNextMap(newCustomObject1List);
            Map<String, Id> mapRecordTypes = retrieveRecordTypeIdsByNames();

            for (clofor_com_cfs__CustomObject1__c objNewCustomObject1 : newCustomObject1List) {
                clofor_com_cfs__CustomObject1__c objOldCustomObject1 = oldCustomObject1Map.get(objNewCustomObject1.Id);
                Date accountedDate = objNewCustomObject1.clofor_com_cfs__SalesAccountedDate__c;

                //QuanDo Add 2022/05/30
                
                //QuanDo End 2022/05/30
                                

                if (accountedDate != null) {                                 
                    Integer year = accountedDate.year();
                    Integer month = accountedDate.month();
                    
                    Integer codeYearNext = 0;
                    Integer codeMonthNext = 0;

                    ItemDTO objDTO = new ItemDTO();
                    if (dataCodeMap.containsKey(year)) {
                        objDTO = dataCodeMap.get(year);
                        codeYearNext = objDTO.codeYearly + 1;

                        if (objDTO.codeMonthlyMap.containsKey(month)) {
                            codeMonthNext = objDTO.codeMonthlyMap.get(month) + 1;
                        } else {
                            codeMonthNext += 1;
                        }
                    } else {
                        codeYearNext += 1;
                        codeMonthNext += 1;
                    }

                    objDTO.codeYearly = codeYearNext;
                    objDTO.codeMonthlyMap.put(month, codeMonthNext);
                    dataCodeMap.put(year, objDTO);          
                    if(cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c != true){
                        if (objOldCustomObject1.clofor_com_cfs__SalesAccountedDate__c != objNewCustomObject1.clofor_com_cfs__SalesAccountedDate__c
                        || String.isBlank(objNewCustomObject1.YearlyFMSSOID__c )) {
                        objNewCustomObject1.YearlyFMSSOID__c = this.createCodeNext(codeYearNext, MAX_CODE_YEAR);
                        }

                        if (objOldCustomObject1.clofor_com_cfs__SalesAccountedDate__c != objNewCustomObject1.clofor_com_cfs__SalesAccountedDate__c
                            || String.isBlank(objNewCustomObject1.MonthlyFMSSOID__c )) {
                            objNewCustomObject1.MonthlyFMSSOID__c = this.createCodeNext(codeMonthNext, MAX_CODE_MONTH);
                        }
                    }else {
                        objNewCustomObject1.YearlyFMSSOID__c = null;
                        objNewCustomObject1.MonthlyFMSSOID__c = null;
                    }

                } else {
                    objNewCustomObject1.YearlyFMSSOID__c = null;
                    objNewCustomObject1.MonthlyFMSSOID__c = null;
                }

                // 2021/08/19 Chien Truong MODIFY START
                // if (String.isBlank(objNewCustomObject1.MonthlyHBLID__c) &&
                //     objNewCustomObject1.BL_TYPE__c == BL_TYPE) {
                if(cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c != true){
                    if (String.isBlank(objNewCustomObject1.MonthlyHBLID__c)) {
                        // 2021/08/19 Chien Truong MODIFY END
                            Date createdDate = Date.newInstance(objNewCustomObject1.CreatedDate.year(), objNewCustomObject1.CreatedDate.month(), 1);
                            Integer codeMonthHBLIDNext = 0;                    
                            if (CodeMonthHBLIDMap.containsKey(createdDate)) {
                                codeMonthHBLIDNext = CodeMonthHBLIDMap.get(createdDate);
                            }
                            
                            codeMonthHBLIDNext += 1;
                            CodeMonthHBLIDMap.put(createdDate, codeMonthHBLIDNext);
                            objNewCustomObject1.MonthlyHBLID__c = this.createCodeNext(codeMonthHBLIDNext, MAX_CODE_MONTH);
                        }
                }
                
                
                // 2021/07/23 Chien Truong ADD START
                CustomObject1__c objCustomObject1Old = oldCustomObject1Map.get(objNewCustomObject1.Id);
                if (String.isBlank(objNewCustomObject1.ContainerNumberList__c) || String.isBlank(objNewCustomObject1.ContainerTypeList__c) || (String.isBlank(objNewCustomObject1.Container_Measurement_Details__c) || String.isBlank(objNewCustomObject1.Container_Details_SL__c) || String.isBlank(objNewCustomObject1.ContainerDetailBLType2__c) || String.isBlank(objNewCustomObject1.ContainerDetailSIType2__c) || String.isBlank(objNewCustomObject1.CONTAINERSEALNO__c))
                    && (objNewCustomObject1.Container__c == objCustomObject1Old.Container__c)
                    && (objNewCustomObject1.ContainerNumber__c == objCustomObject1Old.ContainerNumber__c)
                    && (objNewCustomObject1.Container2__c == objCustomObject1Old.Container2__c)
                    && (objNewCustomObject1.ContainerNumber2__c == objCustomObject1Old.ContainerNumber2__c)
                    && (objNewCustomObject1.Container3__c == objCustomObject1Old.Container3__c)
                    && (objNewCustomObject1.ContainerNumber3__c == objCustomObject1Old.ContainerNumber3__c)) {
                    ContainerInfoService.resetHBLContainerInfo(objNewCustomObject1, containerInfosPerShipment.get(objNewCustomObject1.Id));
                }
                // 2021/07/23 Chien Truong ADD END
            }
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }

    private Integer checkCode(String code) {
        if (String.isNotBlank(code) && code.isNumeric()) {
            return Integer.valueOf(code);
        }
        
        return 0;
    }

    private String createCodeNext(Integer numNext, Integer lengthCode) {
        String code = '';
        Integer countNumber = String.valueOf(numNext).length();
        
        for (Integer i = lengthCode; i > countNumber; i--) {
            code += '0';
        }
        return code + String.valueOf(numNext);
    }
    
    private Map<Integer, ItemDTO> createCodeNextMap(List<clofor_com_cfs__CustomObject1__c> customObject1List) {
        Map<Integer, ItemDTO> dateCodeMap = new Map<Integer, ItemDTO>();
     	Set<Integer> yearInputSet = new Set<Integer>();
        Set<Integer> monthInputSet = new Set<Integer>();
        Set<String> idInputSet = new Set<String>();
        clofor_com_cfs__Site_Custom_Settings__c cusSetting = [Select Id, Name, clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c From clofor_com_cfs__Site_Custom_Settings__c];
        for (clofor_com_cfs__CustomObject1__c objCustomObject1 : customObject1List) {
            if (objCustomObject1.clofor_com_cfs__SalesAccountedDate__c != null) {
                yearInputSet.add(objCustomObject1.clofor_com_cfs__SalesAccountedDate__c.year());   
                idInputSet.add(objCustomObject1.Id);          
            }				
        }
        List<AggregateResult> aggregateResultList = new List<AggregateResult>();
        if(cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c != true){
            aggregateResultList = this.getCustomObject1List(yearInputSet, idInputSet);
        }	
        if(aggregateResultList.size() > 0){
            for (AggregateResult objAggregateResult : aggregateResultList) {
                Integer year = (Integer)objAggregateResult.get('Year');
                Integer month = (Integer)objAggregateResult.get('Month');
    
                Integer yearly = this.checkCode(String.valueOf(objAggregateResult.get('YearlyFMSSOID')));
                Integer monthly = this.checkCode(String.valueOf(objAggregateResult.get('MonthlyFMSSOID')));
    
                ItemDTO data = new ItemDTO();
                if (dateCodeMap.containsKey(year)) {
                    data = dateCodeMap.get(year);
                }
    
                data.setCodeMonthly(yearly, month, monthly);
                dateCodeMap.put(year, data);
            }
        }       
        
        
        return dateCodeMap;
    }
        
    private Map<Date, Integer> createCodeMonthHBLIDNextMap(List<CustomObject1__c> customObject1List) {
        Map<Date, Integer> dateCodeMap = new Map<Date, Integer>();
        Set<Integer> yearInputSet = new Set<Integer>();
        Set<Integer> monthInputSet = new Set<Integer>();
        Set<String> idInputSet = new Set<String>();

        clofor_com_cfs__Site_Custom_Settings__c cusSetting = [Select Id, Name, clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c From clofor_com_cfs__Site_Custom_Settings__c];
        
        for (CustomObject1__c objCustomObject1 : customObject1List) {
            yearInputSet.add(objCustomObject1.CreatedDate.year());
            idInputSet.add(objCustomObject1.Id);
        }
        List<AggregateResult> aggregateResultList = new List<AggregateResult>();
        System.debug('check1');
        if(cusSetting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c != true){
            System.debug('check2');
            aggregateResultList = this.getCustomObject1ListHBLID(yearInputSet, idInputSet);
        }
        System.debug('check3');
        if(aggregateResultList.size() > 0){
            System.debug('check4');
            for (AggregateResult objAggregateResult : aggregateResultList) {
                Integer year = (Integer)objAggregateResult.get('Year');
                Integer month = (Integer)objAggregateResult.get('Month');
                String monthlyHBLID = String.valueOf(objAggregateResult.get('MonthlyHBLID'));
                    
                Date dateETD = Date.newInstance(year, month, 1);
                Integer codeMonthHBLIDNext = this.checkCode(monthlyHBLID);
                dateCodeMap.put(dateETD, codeMonthHBLIDNext);
            }
        }
        
        
        return dateCodeMap;
    }

    private List<AggregateResult> getCustomObject1List(Set<Integer> yearInputSet, Set<String> idInputSet) {
        if (yearInputSet.isEmpty()) {
             return new List<AggregateResult>();
        }
        
        List<AggregateResult> aggregateResultList = [
                                                        SELECT
                                                            Max(clofor_com_cfs__YearlyFMSSOID__c) YearlyFMSSOID
                                                            ,Max(clofor_com_cfs__MonthlyFMSSOID__c) MonthlyFMSSOID
                                                            ,CALENDAR_YEAR(clofor_com_cfs__SalesAccountedDate__c) Year
                                                            ,CALENDAR_MONTH(clofor_com_cfs__SalesAccountedDate__c) Month
                                                        FROM clofor_com_cfs__CustomObject1__c
                                                        WHERE clofor_com_cfs__SalesAccountedDate__c != null
                                                            AND CALENDAR_YEAR(clofor_com_cfs__SalesAccountedDate__c) IN: yearInputSet
                                                            AND Id NOT IN: idInputSet
                                                        GROUP BY CALENDAR_YEAR(clofor_com_cfs__SalesAccountedDate__c), CALENDAR_MONTH(clofor_com_cfs__SalesAccountedDate__c)                                                                                  
                                                    ];
        
        if (aggregateResultList == null) {
            return new List<AggregateResult>();
        }
        return aggregateResultList;
    }

    private List<AggregateResult> getCustomObject1ListHBLID(Set<Integer> yearInputSet, Set<String> idInputSet) {
        if (yearInputSet.isEmpty()) {
             return new List<AggregateResult>();
        }
        
        List<AggregateResult> aggregateResultList = [
                                                        SELECT
                                                            Max(MonthlyHBLID__c) MonthlyHBLID
                                                            ,CALENDAR_YEAR(CreatedDate) Year
                                                            ,CALENDAR_MONTH(CreatedDate) Month
                                                        FROM CustomObject1__c
                                                        WHERE MonthlyHBLID__c != NULL
                                                            AND CALENDAR_YEAR(CreatedDate) IN: yearInputSet
                                                            AND Id NOT IN: idInputSet
                                                        GROUP BY CALENDAR_YEAR(CreatedDate), CALENDAR_MONTH(CreatedDate)                                                                                  
                                                    ];
        
        if (aggregateResultList == null) {
            return new List<AggregateResult>();
        }
        return aggregateResultList;
    }

    public class ItemDTO {
        public Integer codeYearly {get; set;}
        public Map<Integer, Integer> codeMonthlyMap {get; set;}

        public ItemDTO() {
            this.codeYearly = 0;
            this.codeMonthlyMap = new Map<Integer, Integer>();
        }

        public void setCodeMonthly(Integer codeYearly, Integer month, Integer codeMonthly) {
            if (this.codeYearly < codeYearly) {
                this.codeYearly = codeYearly;
            }

            this.codeMonthlyMap.put(month, codeMonthly);
        }
    }

    //QuanDo add 2022/05/19
    private static Map<String, Id> retrieveRecordTypeIdsByNames() {
        String objectName = Constants.NAMESPACE + 'CustomObject1__c';
        Map<String, Id> mapRecordTypes = new Map<String, Id>();
        List<RecordType> recordTypes = [
                SELECT DeveloperName, Id
                FROM RecordType
                WHERE SObjectType = :objectName AND IsActive = True
        ];
        for (RecordType rt : recordTypes) {
            mapRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        return mapRecordTypes;
    }
    
    /**
    * CustomException
    * @created: 2019/07/06 Chien Truong
    * @modified:
    */
    public class CustomException extends Exception {}
}