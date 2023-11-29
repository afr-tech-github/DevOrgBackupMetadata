public with sharing class OrganizationPerformanceTriggerHandler {
	public static void onBeforeDelete(List<OrganizationPerformance__c> listOrganizationPerformance){
		Set<Id> parentOrgPerformanceIds = new Set<Id>();

		for(OrganizationPerformance__c orgPerformance : listOrganizationPerformance){
			parentOrgPerformanceIds.add(orgPerformance.ParentOrganizationalPerformanceID__c);

		}

		Map<Id, OrganizationPerformance__c> parentOrgPerformanceMap = new Map<Id, OrganizationPerformance__c>([SELECT 
																		Id, 
																		AccumulatedAnnualPerformance__c, 
																		SumPerformanceFromChildOrg__c 
																		FROM OrganizationPerformance__c
																		WHERE Id IN: parentOrgPerformanceIds]);
		for(OrganizationPerformance__c orgPerformance : listOrganizationPerformance){
			if(!parentOrgPerformanceMap.containsKey(orgPerformance.ParentOrganizationalPerformanceID__c)){
				continue;
			}

			if(parentOrgPerformanceMap.get(orgPerformance.ParentOrganizationalPerformanceID__c).SumPerformanceFromChildOrg__c > 0){

				parentOrgPerformanceMap.get(orgPerformance.ParentOrganizationalPerformanceID__c).SumPerformanceFromChildOrg__c = parentOrgPerformanceMap.get(orgPerformance.ParentOrganizationalPerformanceID__c).SumPerformanceFromChildOrg__c - orgPerformance.AccumulatedAnnualPerformance__c;
			}

		}

        FlsService.doUpdate(parentOrgPerformanceMap.values());
	}
}