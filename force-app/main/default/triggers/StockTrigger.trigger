trigger StockTrigger on Stock__c (before insert, before update, before delete, after insert, after update, after delete) {
	if (!ValidationUtils.canExecuteTrigger()) {
		return;
	}

	if (Trigger.isBefore) {
		if(Trigger.isInsert) {
			StockTriggerHelper.autoPopulateFields(Trigger.new, null);
			//StockTriggerHelper.setRecordTypeIdByWosLine(Trigger.new);
			//StockTriggerHelper.rollUpStockInAndOut(Trigger.new, null);
		} 
		if(Trigger.isUpdate) {
			StockTriggerHelper.autoPopulateFields(Trigger.new, Trigger.oldMap);
			//StockTriggerHelper.rollUpStockInAndOut(Trigger.new, Trigger.oldMap);
		} 
		if(Trigger.isDelete) {
			StockTriggerHelper.calculateLocatorWhenDeleteStock(Trigger.old);
		}
	} 
	if (Trigger.isAfter) {
		if(Trigger.isInsert) {
		} 
		if(Trigger.isUpdate) {
		} 
		if(Trigger.isDelete) {
		}
	}
}