public with sharing class ConsolTriggerClass {

    public void onBeforeUpdate(Map<Id, clofor_com_cfs__MasterAnken__c> oldConsolMap, List<clofor_com_cfs__MasterAnken__c> newConsolList) {
        Set<Id> setid = new Set<Id>();
        for(clofor_com_cfs__MasterAnken__c objNewConsol : newConsolList ){
            setid.add(objNewConsol.Id);
        }
        System.debug('setid:' + setid);
        String readword = RollupConsol(setid);
        for(clofor_com_cfs__MasterAnken__c objNewConsol : newConsolList ){
            clofor_com_cfs__MasterAnken__c objConsolOld = oldConsolMap.get(objNewConsol.Id);
            if ((String.isBlank(objNewConsol.clofor_com_cfs__NumberofContainer1__c))) {
                objNewConsol.clofor_com_cfs__NumberofContainer1__c = readword;
                //  objNewConsol.clofor_com_cfs__NumberofContainer1__c = objConsolOld.clofor_com_cfs__NumberofContainer1__c;
                // System.debug('setid1:' + readword);
            }
        }
    }

    public static String RollupConsol(Set<Id> Ids) {
        clofor_com_cfs__MasterAnken__c Consol = [SELECT Id, clofor_com_cfs__MContainerNumber__c, clofor_com_cfs__MContainerNumber2__c, clofor_com_cfs__MContainer__c, clofor_com_cfs__MContainer2__c FROM clofor_com_cfs__MasterAnken__c WHERE Id in :Ids LIMIT 1];
        List<clofor_com_cfs__ConsolCNTR__c> lstConsolInfo = [SELECT Id, clofor_com_cfs__ContainerType__c FROM clofor_com_cfs__ConsolCNTR__c WHERE clofor_com_cfs__Consolidation__c in :Ids];
            String [] arr = new String[]{null,null,null,null};
            Integer j =0;
            List<String> lst = new List<String>();
                for(clofor_com_cfs__ConsolCNTR__c con : lstConsolInfo){
                    if(!lst.contains(con.clofor_com_cfs__ContainerType__c)){
                        arr[j] = con.clofor_com_cfs__ContainerType__c;
                        lst.add((String.valueOf(con.clofor_com_cfs__ContainerType__c)));
                        j++;
                    }
                }       
                System.debug('212:' + arr);
                System.debug('212:' + arr[0]);    
            Integer [] arrCount = new Integer[]{0,0,0,0};
                for(Integer i=0 ; i< lst.size();i++){
                    for (clofor_com_cfs__ConsolCNTR__c con : lstConsolInfo){
                        if(con.clofor_com_cfs__ContainerType__c == arr[i] ){
                            arrCount[i]++;
                        } 
                    }
            }
                String words = '';
                String myString = '';
                String myString1 = '';
                System.debug('213:' + arrCount);
                System.debug('213:' + arr);
                if(arr[1] != null){
                    myString = NumbericUtils.convertNumberToEnglishText(arrCount[0]).toUpperCase() + ' (' +  arrCount[0] + ') ' + arr[0] + ( arrCount[0] > 1?' CONTAINERS':' CONTAINER');
                    myString1 = NumbericUtils.convertNumberToEnglishText(1).toUpperCase() + ' (' + arrCount[1] + ') ' + arr[1] + (arrCount[1] > 1?' CONTAINERS':' CONTAINER');
                    words = (arr[0] != null ? (myString + (arr[1] != null ? ' AND ' + myString1 + ' ONLY' : ' ONLY')) : ((arr[1] != null) ? myString1 + ' ONLY' : '' ));
                }else if(arr[0] != null && arr[1] == null ){
                    words = NumbericUtils.convertNumberToEnglishText(arrCount[0]).toUpperCase() + ' (' +  arrCount[0] + ') ' + arr[0] + ( arrCount[0] > 1?' CONTAINERS':' CONTAINER');
                }else{
                    words = '';
                }
        return words;
    }
}