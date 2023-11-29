@isTest
private class New_NavigationFlowControllerTest {
	private static List<Flow_Tab_Setting__c> flowtabList = new List<Flow_Tab_Setting__c>();
	
	private static Flow_Sub_Tab_Setting__c subTabSetting = new Flow_Sub_Tab_Setting__c();
	static{

		Flow_Tab_Setting__c tab1 = new Flow_Tab_Setting__c(
				Tab_Style__c = 'Link',
				Is_Active__c = true,
				Flow__c = '1',
				Tab_Link__c='/001',
				Tab_Order__c = 1,
				Tab_Name__c = 'tab 1',
				Flow_Style__c = 'Flow',
				External_Id__c = 1

			);
		Flow_Tab_Setting__c tab2 = new Flow_Tab_Setting__c(
				Tab_Style__c = 'Object',
				Is_Active__c = true,
				Flow__c = '1',
				API_Object_Name__c = 'clofor_com_cfs__Stock__c',
				Tab_Order__c = 2,
				Tab_Name__c = 'tab 2',
				Flow_Style__c = 'Flow',
				External_Id__c = 2
			);

		Flow_Tab_Setting__c tab3 = new Flow_Tab_Setting__c(
				Tab_Style__c = 'Report',
				Is_Active__c = true,
				Flow__c = '1',
				Report_Developer_Name__c = 'Account',
				Tab_Order__c = 3,
				Tab_Name__c = 'tab 3',
				Flow_Style__c = 'Flow',
				External_Id__c = 3
			);

		flowtabList.add(tab1);
		flowtabList.add(tab2);
		flowtabList.add(tab3);
        FlsService.doInsert(flowtabList);
		subTabSetting = new Flow_Sub_Tab_Setting__c(
			
			ParentTab__c = tab2.Id,
			Developer_Name_Record_Type__c = 'StockIn'
			);
        FlsService.doInsert(subTabSetting);
	}

	@isTest static void test_method_one() {
		// Implement test code
		Test.startTest();
		New_NavigationFlowController ctrl = new New_NavigationFlowController();
		ctrl.getListFlows();
		Test.stopTest();
		system.assertEquals(ctrl.languageSettingTab.subTabs.size(), 0);
	}
	
	
	
}