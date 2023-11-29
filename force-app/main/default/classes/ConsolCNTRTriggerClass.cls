public class ConsolCNTRTriggerClass {
    // public static void RollupConsol(Set<Id> Ids) {
        // List<AggregateResult> queryResults= [SELECT COUNT(Id), clofor_com_cfs__ContainerType__c, clofor_com_cfs__Consolidation__c FROM clofor_com_cfs__ConsolCNTR__c  WHERE clofor_com_cfs__Consolidation__c in :Ids GROUP BY  clofor_com_cfs__ContainerType__c, clofor_com_cfs__Consolidation__c];
        // List<clofor_com_cfs__MasterAnken__c> lstConsol = [SELECT Id, clofor_com_cfs__MContainerNumber__c, clofor_com_cfs__MContainerNumber2__c, clofor_com_cfs__MContainer__c, clofor_com_cfs__MContainer2__c FROM clofor_com_cfs__MasterAnken__c WHERE Id in :Ids];
        // List<clofor_com_cfs__MasterAnken__c> lstConsolUpdate = new List<clofor_com_cfs__MasterAnken__c>();
        // Map<Id, clofor_com_cfs__MasterAnken__c> consolToUpdate = new Map<Id, clofor_com_cfs__MasterAnken__c>();
        // for (AggregateResult ar : queryResults){
            // Id csId = (Id)ar.get('clofor_com_cfs__Consolidation__c');
            // Integer count = (Integer)ar.get('expr0');
            // clofor_com_cfs__MasterAnken__c consol = new clofor_com_cfs__MasterAnken__c(Id = csId);
            // for (clofor_com_cfs__MasterAnken__c cs : lstConsol){
                // If (cs.clofor_com_cfs__MContainer__c == (String)ar.get('clofor_com_cfs__ContainerType__c') && cs.Id == csId){
                    // cs.clofor_com_cfs__MContainerNumber__c = count;
                // }
                // If (cs.clofor_com_cfs__MContainer2__c == (String)ar.get('clofor_com_cfs__ContainerType__c') && cs.Id == csId){
                    // cs.clofor_com_cfs__MContainerNumber2__c = count;
                // }
            // }
            // update lstConsol;
        // }
    // }

    public static void onInsertUpdateDelete(List<clofor_com_cfs__ConsolCNTR__c> newConsolCNTRList, List<clofor_com_cfs__ConsolCNTR__c> oldConsolCNTRList) {
        Set<Id> consolId = new Set<Id>();
        if (newConsolCNTRList != null){
            for (clofor_com_cfs__ConsolCNTR__c csCNTR : newConsolCNTRList){
                consolId.add(csCNTR.clofor_com_cfs__Consolidation__c);
            }
        }

        if (oldConsolCNTRList != null){
            for (clofor_com_cfs__ConsolCNTR__c csCNTR : oldConsolCNTRList){
                consolId.add(csCNTR.clofor_com_cfs__Consolidation__c);
            }
        }
        RollupConsol(consolId);
    }
    public static void RollupConsol(Set<Id> Ids) {
        clofor_com_cfs__MasterAnken__c Consol = [SELECT Id, clofor_com_cfs__MContainerNumber__c, clofor_com_cfs__MContainerNumber2__c, clofor_com_cfs__MContainer__c, clofor_com_cfs__MContainer2__c FROM clofor_com_cfs__MasterAnken__c WHERE Id in :Ids LIMIT 1];
        List<clofor_com_cfs__ConsolCNTR__c> lstConsolInfo = [SELECT Id, clofor_com_cfs__ContainerType__c FROM clofor_com_cfs__ConsolCNTR__c WHERE clofor_com_cfs__Consolidation__c in :Ids ];
        Integer count = 0;
        Integer count2 = 0;
        Integer countResult = 0;
        String typeResult ='';
        String conType = '';
        String conType2 = '';
        // for (clofor_com_cfs__ConsolCNTR__c con : lstConsolInfo){
        //     if (con.clofor_com_cfs__ContainerType__c == Consol.clofor_com_cfs__MContainer__c){
        //         conType = con.clofor_com_cfs__ContainerType__c;
        //         count++;
        //     }
        //     if (con.clofor_com_cfs__ContainerType__c == Consol.clofor_com_cfs__MContainer2__c){
        //         conType2 = con.clofor_com_cfs__ContainerType__c;
        //         count2++;
        //     }
        //     if (con.clofor_com_cfs__ContainerType__c != Consol.clofor_com_cfs__MContainer2__c && con.clofor_com_cfs__ContainerType__c != Consol.clofor_com_cfs__MContainer__c){
        //         countResult++;
        //         typeResult = con.clofor_com_cfs__ContainerType__c;
        //     }
        // }

        // String words = '';
        // String myString = NumbericUtils.convertNumberToEnglishText(count).toUpperCase() + ' (' + count + ') ' + conType + (count > 1?' CONTAINERS':' CONTAINER');
        // String myString1 = NumbericUtils.convertNumberToEnglishText(count2).toUpperCase() + ' (' + count2 + ') ' + conType2 + (count2 > 1?' CONTAINERS':' CONTAINER');
        // words = (conType != null ? (myString + (conType2 != null ? ' AND ' + myString1 + ' ONLY' : ' ONLY')) : ((conType2 != null) ? myString1 + ' ONLY' : '' ));
        // Consol.clofor_com_cfs__NumberofContainer1__c = words;

        // if (count != 0){
        //     Consol.clofor_com_cfs__MContainerNumber__c = count;
        // }else{
        //     Consol.clofor_com_cfs__MContainer__c = null;
        //     Consol.clofor_com_cfs__MContainerNumber__c = null;
        // }
        // if (count2 != 0){
        //     Consol.clofor_com_cfs__MContainerNumber2__c = count2;
        // }else{
        //     Consol.clofor_com_cfs__MContainer2__c = null;
        //     Consol.clofor_com_cfs__MContainerNumber2__c = null;
        // }
        // System.debug('typeResult'+ typeResult+countResult );

        // if(Consol.clofor_com_cfs__MContainer__c == null && countResult !=0 && typeResult !=''){
        //     Consol.clofor_com_cfs__MContainer__c = typeResult;
        //     Consol.clofor_com_cfs__MContainerNumber__c = countResult;
        // } else if (Consol.clofor_com_cfs__MContainer2__c == null && countResult !=0 && typeResult !=''){
        //     Consol.clofor_com_cfs__MContainer2__c = typeResult;
        //     Consol.clofor_com_cfs__MContainerNumber2__c = countResult;
        // }
        // String words = '';
        // Integer numberOfCon = (Integer) Consol.clofor_com_cfs__MContainerNumber__c;
        // String Con = (String) Consol.clofor_com_cfs__MContainer__c;
        // Integer numberOfCon1 = (Integer) Consol.clofor_com_cfs__MContainerNumber2__c;
        // String Con1 = (String) Consol.clofor_com_cfs__MContainer2__c;
        // String myString = NumbericUtils.convertNumberToEnglishText(numberOfCon).toUpperCase() + ' (' + numberOfCon + ') ' + Con + (numberOfCon > 1?' CONTAINERS':' CONTAINER');
        // String myString1 = NumbericUtils.convertNumberToEnglishText(numberOfCon1).toUpperCase() + ' (' + numberOfCon1 + ') ' + Con1 + (numberOfCon1 > 1?' CONTAINERS':' CONTAINER');
        // words = (Consol.clofor_com_cfs__MContainer__c != null ? (myString + (Consol.clofor_com_cfs__MContainer2__c != null ? ' AND ' + myString1 + ' ONLY' : ' ONLY')) : ((Consol.clofor_com_cfs__MContainer2__c != null) ? myString1 + ' ONLY' : '' ));
        // Consol.clofor_com_cfs__NumberofContainer1__c = words;
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
                    Consol.clofor_com_cfs__NumberofContainer1__c = words;

                }else if(arr[0] != null && arr[1] == null ){
                    words = NumbericUtils.convertNumberToEnglishText(arrCount[0]).toUpperCase() + ' (' +  arrCount[0] + ') ' + arr[0] + ( arrCount[0] > 1?' CONTAINERS':' CONTAINER');
                    Consol.clofor_com_cfs__NumberofContainer1__c = words;

                }else{
                    words = '';
                    Consol.clofor_com_cfs__NumberofContainer1__c = words;
                }
                if(arr[0] == null && arr[1] == null){
                    Consol.clofor_com_cfs__MContainer__c = null;
                    Consol.clofor_com_cfs__MContainer2__c = null;
                    Consol.clofor_com_cfs__MContainerNumber__c = null;
                    Consol.clofor_com_cfs__MContainerNumber2__c = null;
                }else if(arr[0] != null){
                    if(arr[1] != null){
                        Consol.clofor_com_cfs__MContainer__c = arr[0];
                        Consol.clofor_com_cfs__MContainer2__c = arr[1];
                        Consol.clofor_com_cfs__MContainerNumber__c = arrCount[0];
                        Consol.clofor_com_cfs__MContainerNumber2__c = arrCount[1];
                    }else{
                        Consol.clofor_com_cfs__MContainer__c = arr[0];
                        Consol.clofor_com_cfs__MContainerNumber__c = arrCount[0];
                        Consol.clofor_com_cfs__MContainer2__c = null;
                        Consol.clofor_com_cfs__MContainerNumber2__c = null;
                    }
                }      
        update Consol;
    }
}