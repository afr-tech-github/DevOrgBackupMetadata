global with sharing class ExchangeRateValidationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ExchangeRateValidationBatch batch = new ExchangeRateValidationBatch();
        Database.executeBatch(batch);
    }
}