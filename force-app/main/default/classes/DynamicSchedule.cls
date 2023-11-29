global with sharing class DynamicSchedule implements Schedulable, Database.AllowsCallouts  {
    global interface IScheduleHandler {
        void execute(SchedulableContext ctx);
    }

    private IScheduleHandler handler;
    
    global DynamicSchedule(IScheduleHandler handler) {
        this.handler = handler;
    }

    global void execute(SchedulableContext ctx) {
        this.handler.execute(ctx);
	}
}