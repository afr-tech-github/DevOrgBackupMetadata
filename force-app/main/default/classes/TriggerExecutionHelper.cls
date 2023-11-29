public class TriggerExecutionHelper {
    private static Set<String> handlers = new Set<String>();
    private static Set<String> forcedOffHandlers = new Set<String>();
    
    public static void register(String handlerName) {
        handlers.add(handlerName);
    }
       
    public static boolean isRunning(String handlerName) {
        return handlers.contains(handlerName);
    }    
    
    public static boolean isForcedOff(String handlerName) {
        return forcedOffHandlers.contains(handlerName);
    }
}