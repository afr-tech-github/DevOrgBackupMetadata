public with sharing class New_NavigationFlowController {

	private Map<String, Schema.SObjectType> schemaSobject;
	public TabWrapper languageSettingTab{get; set;}
	public New_NavigationFlowController() {
		 schemaSobject = Schema.getGlobalDescribe();
		 languageSettingTab = new TabWrapper();
	}



	public List<FlowWapper> getListFlows(){
		//get metadata
		List<clofor_com_cfs__NavigationTabDescriptionTranslation__mdt> descriptionTranslations = [SELECT Id, 
													clofor_com_cfs__NavigationTabName__c,
													clofor_com_cfs__EnglishDescription__c,
													clofor_com_cfs__JapaneseDescription__c,
													clofor_com_cfs__KoreanTranslation__c,
													clofor_com_cfs__VietnameseDescription__c
													FROM clofor_com_cfs__NavigationTabDescriptionTranslation__mdt Limit 2000];
		Map<String, String> desTranslationMap = new Map<String, String>();			
		for (clofor_com_cfs__NavigationTabDescriptionTranslation__mdt setting : descriptionTranslations) {
			String des = setting.clofor_com_cfs__EnglishDescription__c;
			if(UserInfo.getLanguage() =='vi'){
				des = setting.clofor_com_cfs__VietnameseDescription__c;
			}
				if(UserInfo.getLanguage() =='ja'){
				des = setting.clofor_com_cfs__JapaneseDescription__c;
			}
			if(UserInfo.getLanguage() =='ko'){
				des = setting.clofor_com_cfs__KoreanTranslation__c;
			}
			
			
			desTranslationMap.put(setting.clofor_com_cfs__NavigationTabName__c,des);
		}
		List<FlowWapper> flows = new List<FlowWapper>();
		// get list parent tab
		Map<Id, Flow_Tab_Setting__c> flowTabSettingMap =  new Map<Id, Flow_Tab_Setting__c>([SELECT 
														Id, 
														Name, 
														clofor_com_cfs__API_Object_Name__c,
														clofor_com_cfs__Flow__c,
														clofor_com_cfs__Is_Active__c,
														clofor_com_cfs__Static_Resource_Image_Name__c,
														clofor_com_cfs__Tab_Link__c,
														clofor_com_cfs__Tab_Name__c,
														clofor_com_cfs__Tab_Name_VN__c,
														clofor_com_cfs__Tab_Name_KR__c,
														clofor_com_cfs__Tab_Name_JP__c,
														clofor_com_cfs__Flow_Style__c,
														clofor_com_cfs__Tab_Order__c,
														clofor_com_cfs__Tab_Style__c,
														clofor_com_cfs__Report_Developer_Name__c 
														FROM clofor_com_cfs__Flow_Tab_Setting__c
														WHERE clofor_com_cfs__Is_Active__c = true
														Order by clofor_com_cfs__Flow__c, clofor_com_cfs__Tab_Order__c Limit 5000]);
		Set<String> reportNameSet = new Set<String>();
		Set<String> objectNameSet = new Set<String>();
		for(Flow_Tab_Setting__c tab : flowTabSettingMap.values()){
			if(tab.clofor_com_cfs__Tab_Style__c == 'Report'){
				reportNameSet.add(tab.clofor_com_cfs__Report_Developer_Name__c);
			}
			if(tab.clofor_com_cfs__Tab_Style__c == 'Object'){
				objectNameSet.add(tab.clofor_com_cfs__API_Object_Name__c);
			}
			
		}
		// list all record type
		Map<String, Map<String,RecordType>> mapRecInfobyObject = new Map<String, Map<String, RecordType>>();
		for(RecordType rec : [SELECT Id, Name, DeveloperName, Description, SobjectType FROM RecordType WHERE SobjectType IN: objectNameSet ORDER BY SobjectType]){
			if(mapRecInfobyObject.containsKey(rec.SobjectType)){
				mapRecInfobyObject.get(rec.SobjectType).put(rec.DeveloperName, rec);
			}else {
				Map<String,RecordType> newMap = new Map<String,RecordType>();
				newMap.put(rec.DeveloperName, rec);
				mapRecInfobyObject.put(rec.SobjectType, newMap);
			}
		}
		

		Map <String, Report> reportByNameMap = new Map <String, Report>();
		for( Report rpt : [SELECT Id, DeveloperName FROM Report WHERE DeveloperName IN: reportNameSet]){
			reportByNameMap.put(rpt.DeveloperName, rpt);
		}
		List<Flow_Sub_Tab_Setting__c> subTabSettingList = [SELECT
																Id, 
																Name,
																clofor_com_cfs__ParentTab__r.clofor_com_cfs__API_Object_Name__c,
																clofor_com_cfs__Developer_Name_Record_Type__c, 
																clofor_com_cfs__ParentTab__c
															FROM clofor_com_cfs__Flow_Sub_Tab_Setting__c
															WHERE clofor_com_cfs__ParentTab__c IN: flowTabSettingMap.keySet()];
		Map<Id, List<Flow_Sub_Tab_Setting__c>> subTabSettingbyTabMap = new Map<Id, List<Flow_Sub_Tab_Setting__c>>();

		for(Flow_Sub_Tab_Setting__c subTabSetting : subTabSettingList){

			if(subTabSettingbyTabMap.containsKey(subTabSetting.clofor_com_cfs__ParentTab__c)){
				subTabSettingbyTabMap.get(subTabSetting.clofor_com_cfs__ParentTab__c).add(subTabSetting);
			}else{
				subTabSettingbyTabMap.put(subTabSetting.clofor_com_cfs__ParentTab__c, new List<Flow_Sub_Tab_Setting__c>{subTabSetting});
			}

		}


		Map<String, String> mapFlowPickList = new Map<String, String>();

		mapFlowPickList = getPicklistValues('clofor_com_cfs__Flow_Tab_Setting__c', 'clofor_com_cfs__Flow__c');
		// initial list flows
		String flowTemp = null;
		FlowWapper flow; 
		Integer index = 0;
		String nextFlow = null;
		for(Flow_Tab_Setting__c tab :flowTabSettingMap.values()){
			if(tab.clofor_com_cfs__Flow__c == '0'){
				
				languageSettingTab.tabSetting = tab;
				languageSettingTab.tabName = tab.clofor_com_cfs__Tab_Name__c;
				if(UserInfo.getLanguage() =='vi'
					&& !String.isBlank(tab.clofor_com_cfs__Tab_Name_VN__c)){
					languageSettingTab.tabName = tab.clofor_com_cfs__Tab_Name_VN__c;
				}
				if(UserInfo.getLanguage() =='ja'
					&& !String.isBlank(tab.clofor_com_cfs__Tab_Name_JP__c)){
					languageSettingTab.tabName = tab.clofor_com_cfs__Tab_Name_JP__c;
				}
				if(UserInfo.getLanguage() =='ko'
					&& !String.isBlank(tab.clofor_com_cfs__Tab_Name_KR__c)){
					languageSettingTab.tabName = tab.clofor_com_cfs__Tab_Name_KR__c;
				}
				continue;
			}
			index += 1;
			if(index < flowTabSettingMap.values().size()){
				nextFlow = flowTabSettingMap.values()[index].clofor_com_cfs__Flow__c;
			}else{
				nextFlow = null;
			}
			if(flowTemp != tab.clofor_com_cfs__Flow__c){

				flow = new FlowWapper();
				flow.flowName = mapFlowPickList.get(tab.clofor_com_cfs__Flow__c); 
				flowTemp = tab.clofor_com_cfs__Flow__c;
				flow.flowType = tab.clofor_com_cfs__Flow_Style__c;
			}

			TabWrapper newTab = new TabWrapper();
			newTab.tabSetting = tab;
			if(tab.clofor_com_cfs__Tab_Style__c == 'Link'){
				newTab.urlTab = tab.clofor_com_cfs__Tab_Link__c;
			}
			if(tab.clofor_com_cfs__Tab_Style__c == 'Report'){
				if(reportByNameMap.containsKey(tab.clofor_com_cfs__Report_Developer_Name__c)){
					newTab.urlTab = '/' + reportByNameMap.get(tab.clofor_com_cfs__Report_Developer_Name__c).Id;
				}
			}
			if(tab.clofor_com_cfs__Tab_Style__c == 'User Info'){
				newTab.urlTab = '/' + UserInfo.getUserId() + tab.clofor_com_cfs__Tab_Link__c;
			}
			if(tab.clofor_com_cfs__Tab_Style__c == 'Object'){
				if(isObjectExist(tab.clofor_com_cfs__API_Object_Name__c)){
					Schema.SObjectType sObjectType = schemaSobject.get(tab.clofor_com_cfs__API_Object_Name__c);
					Schema.DescribeSObjectResult sobjectResult = sObjectType.getDescribe() ;
					//Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = sobjectResult.getRecordTypeInfosByDeveloperName();
					String keyPrefix = sobjectResult.getKeyPrefix();
					newTab.urlTab = '/' + keyPrefix;

					if(subTabSettingbyTabMap.containsKey(tab.Id)){
						List<Flow_Sub_Tab_Setting__c> listSubTabTemp = subTabSettingbyTabMap.get(tab.Id);
						Map<String, RecordType> mapRecByDeveloperName = new Map<String, RecordType>();
						if(mapRecInfobyObject.containsKey(tab.clofor_com_cfs__API_Object_Name__c)){
							mapRecByDeveloperName = mapRecInfobyObject.get(tab.clofor_com_cfs__API_Object_Name__c);
						}
                        Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = sobjectResult.getRecordTypeInfosByDeveloperName();
                        
						for(Flow_Sub_Tab_Setting__c subtabTemp : listSubTabTemp){
							if(mapRecByDeveloperName.containsKey(subtabTemp.clofor_com_cfs__Developer_Name_Record_Type__c)
                              && recordTypeInfosMap.containsKey(subtabTemp.clofor_com_cfs__Developer_Name_Record_Type__c)){
								Schema.RecordTypeInfo recInfoSchema = recordTypeInfosMap.get(subtabTemp.clofor_com_cfs__Developer_Name_Record_Type__c);
                                RecordType recInfo = mapRecByDeveloperName.get(subtabTemp.clofor_com_cfs__Developer_Name_Record_Type__c);
								SubTabWapper subTab = new SubTabWapper();
								subTab.tabId = tab.Id;
                                subTab.id = recInfo.Id;
								subTab.description = desTranslationMap.containsKey(subtabTemp.clofor_com_cfs__Developer_Name_Record_Type__c)? desTranslationMap.get(subtabTemp.clofor_com_cfs__Developer_Name_Record_Type__c) :recInfo.Description;
								subTab.subTabName = '+ ' + recInfoSchema.getName();
								subTab.subTabUrl = newTab.urlTab + '/e?RecordType=' + recInfo.Id;
								newTab.subTabs.add(subTab);
							}
						}

					}
				}
				
			}
			newTab.tabName = tab.clofor_com_cfs__Tab_Name__c;
			if(desTranslationMap.containsKey(tab.clofor_com_cfs__Tab_Name__c)){
				newTab.description = desTranslationMap.get(tab.clofor_com_cfs__Tab_Name__c);
			}
			if(UserInfo.getLanguage() =='vi'
				&& !String.isBlank(tab.clofor_com_cfs__Tab_Name_VN__c)){
				newTab.tabName = tab.clofor_com_cfs__Tab_Name_VN__c;
			}
			if(UserInfo.getLanguage() =='ja'
				&& !String.isBlank(tab.clofor_com_cfs__Tab_Name_JP__c)){
				newTab.tabName = tab.clofor_com_cfs__Tab_Name_JP__c;
			}
			if(UserInfo.getLanguage() =='ko'
				&& !String.isBlank(tab.clofor_com_cfs__Tab_Name_KR__c)){
				newTab.tabName = tab.clofor_com_cfs__Tab_Name_KR__c;
			}
			flow.tabFlows.add(newTab);
			if(nextFlow != tab.clofor_com_cfs__Flow__c){
				flows.add(flow);
			}

		}

		return flows;

	}

	private  boolean isObjectExist(String ObjectNameParam){
	     for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
	        String sobjName = String.valueOf(sObjectType);
	        if (sobjName.contains(ObjectNameParam) ) {
	            return true;
	        }
	     }
	     return false;
   	}
	private String convertString(String strSource){
		String strLowercase = strSource.toLowerCase();
		List<String> strDestinations = strLowercase.split(' ');
		for (Integer i = 0; i < strDestinations.size(); i++){

		    strDestinations[i] = strDestinations[i].capitalize();
		}
		return String.join(strDestinations, ' ');
	}
	private  Map<String, String> getPicklistValues(String ObjectApi_name, String Field_name){ 
		Map<String, String> piclistMap = new Map<String, String>();
		List<String> lstPickvals=new List<String>();
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
		Sobject Object_name = targetType.newSObject();
		Schema.SObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
	    Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
	    Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
	    List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
	    for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
	      piclistMap.put(a.getValue(), a.getLabel());//add the value  to our final list
	   }

  		return piclistMap;
	}

	public class FlowWapper {
		public List<TabWrapper> tabFlows {get;set;}
		public String flowName{get; set;}
		public String flowType{get; set;}

		public FlowWapper(){
			tabFlows = new List<TabWrapper>();
		}
		
	
	}

	public class TabWrapper {

		public Flow_Tab_Setting__c tabSetting {get; set;}
		public String tabName{get; set;}
		public String urlTab {get; set;}
		public String description{get;set;}
		public List<SubTabWapper> subTabs {get; set;}
		public TabWrapper(){
			tabSetting = new Flow_Tab_Setting__c();
			subTabs = new List<SubTabWapper>();
		}
	}
	public class SubTabWapper{
        public String id{get;set;}
		public String tabId{get; set;}
		public String subTabName{get; set;}
		public String subTabUrl{get; set;}
		public String description{get;set;}
		public SubTabWapper(){

		}

	}
}