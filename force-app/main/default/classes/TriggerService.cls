public class TriggerService {
    public enum Evt {
        afterdelete,
            afterinsert,
            afterundelete,
            afterupdate,
            beforedelete,
            beforeinsert,
            beforeupdate	
            }
    
    /**
Simplistic handler to implement on any of the event. It doesn't requires or enforces any pattern except the
method name to be "execute()", a developer is free to use any Trigger context variable or reuse any other
apex class here.
*/
    public interface ITriggerHandler {
        void execute();			
    } 
    
    // Internal mapping of handlers
    Map<String, List<ITriggerHandler>> eventHandlerMapping = new Map<String, List<ITriggerHandler>>();
    
    /**
Core API to bind handlers with events
*/
    public TriggerService bind(Evt event, ITriggerHandler eh) {
        List<ITriggerHandler> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) {
            handlers = new List<ITriggerHandler>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }
    
    /**
Invokes correct handlers as per the context of trigger and available registered handlers
*/
    public void execute() {
        Evt ev = null;
        if(Trigger.isInsert && Trigger.isBefore){
            ev = Evt.beforeinsert;
        } else if(Trigger.isInsert && Trigger.isAfter){
            ev = Evt.afterinsert;
        } else if(Trigger.isUpdate && Trigger.isBefore){
            ev = Evt.beforeupdate;
        } else if(Trigger.isUpdate && Trigger.isAfter){
            ev = Evt.afterupdate;
        } else if(Trigger.isDelete && Trigger.isBefore){
            ev = Evt.beforedelete;
        } else if(Trigger.isDelete && Trigger.isAfter){
            ev = Evt.afterdelete;
        } else if(Trigger.isundelete){
            ev = Evt.afterundelete;				
        }
        List<ITriggerHandler> handlers = eventHandlerMapping.get(ev.name());
        if (handlers != null && !handlers.isEmpty()) {
            for (ITriggerHandler h : handlers) {
                h.execute();
            }
        }
    }
}