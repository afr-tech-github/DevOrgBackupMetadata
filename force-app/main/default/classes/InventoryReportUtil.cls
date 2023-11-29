global with sharing class InventoryReportUtil {

	@InvocableMethod(label='Run GenerateReportBatch' description='Run GenerateReportBatch')
	global static void executeGenerateReport () {
        System.scheduleBatch(new DynamicBatch(new GenerateReportBatch()), 'GenerateReportBatch', 0);
	}

    public class GenerateReportBatch implements DynamicBatch.IBatchHandler {
        public Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator(
                'SELECT StartDate__c, PreviousInventoryReportID__c, ReportPeriodType__c, ' + 
                '   InventoryLogID__c, InventoryLogID__r.FacilityID__c, InventoryLogID__r.ProductID__c, InventoryLogID__r.StockQuantityOnHand__c, InventoryLogID__r.StockInQuantity__c, InventoryLogID__r.StockOutQuantity__c, InventoryLogID__r.ReconcileQuantity__c, ' + 
                '   InventoryLogID__r.ProductID__r.InventoryReportFrequency__c ' +
                'FROM InventoryReport__c WHERE EndDate__c = NULL AND StartDate__c <= TODAY AND InventoryLogID__c != NULL AND ReportPeriodType__c != NULL '
            );
        }

        public void execute(Database.BatchableContext bc, List<Sobject> records) {
            Map<String, Integer> mapFrequencyToDays = new Map<String, Integer> {
                'Daily' => 1,
                'Weekly' => 7
            };
            Map<String, Integer> mapFrequencyToMonths = new Map<String, Integer> {
                'Monthly' => 1,
                'Quarterly' => 3,
                'Annually' => 12
            };
            List<InventoryReport__c> listNextRun = new List<InventoryReport__c>();
            for(InventoryReport__c item : (List<InventoryReport__c>)records) {
                item.StockInQuantity__c = item.InventoryLogID__r.StockInQuantity__c;
                item.StockOutQuantity__c = item.InventoryLogID__r.StockOutQuantity__c;
                item.ClosingQuantity__c = item.InventoryLogID__r.StockQuantityOnHand__c;
                item.ReconcileQuantity__c = item.InventoryLogID__r.ReconcileQuantity__c;
                item.EndDate__c = System.today();

                String freq = item.ReportPeriodType__c;
                listNextRun.add(new InventoryReport__c(
                    InventoryLogID__c = item.InventoryLogID__c,
                    PreviousInventoryReportID__c = item.Id,
                    FacilityID__c = item.InventoryLogID__r.FacilityID__c,
                    ProductID__c = item.InventoryLogID__r.ProductID__c,
                    ReportPeriodType__c = freq,
                    StartDate__c = mapFrequencyToDays.containsKey(freq) ? item.StartDate__c.addDays(mapFrequencyToDays.get(freq)) : item.StartDate__c.addMonths(mapFrequencyToMonths.get(freq))
                ));
            }
            FlsService.doupdate(records);
            FlsService.doinsert(listNextRun);
        }

        public void finish(Database.BatchableContext bc) {}
    }
}