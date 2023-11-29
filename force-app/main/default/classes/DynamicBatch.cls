public with sharing class DynamicBatch implements Database.Batchable<SObject> {
    public interface IBatchHandler {
        Database.QueryLocator start(Database.BatchableContext bc);
        void execute(Database.BatchableContext bc, List<SObject> scope);
        void finish(Database.BatchableContext bc);
    }
    
    private IBatchHandler handler;

    public DynamicBatch(IBatchHandler handler) {
        this.handler = handler;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return this.handler.start(bc);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        this.handler.execute(bc, scope);
    }
    
    public void finish(Database.BatchableContext bc) {
        this.handler.finish(bc);
    }
}