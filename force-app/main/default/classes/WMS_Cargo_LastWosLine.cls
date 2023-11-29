public class WMS_Cargo_LastWosLine  {
	@AuraEnabled
	public static List<WosLineItem__c> getWosLines(String cargoId) {
		return [SELECT Id,Name FROM WosLineItem__c WHERE Cargo__c = :cargoId AND CargoStatus__c = 'Completed' ORDER BY ScanTime__c DESC NULLS LAST, LastModifiedDate DESC];
	}
}