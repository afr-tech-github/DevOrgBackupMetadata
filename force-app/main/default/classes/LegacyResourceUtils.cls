public with sharing class LegacyResourceUtils {
    public static String getHBLDeliveryServiceRequired(String deliveryServiceRequired) {
        if (!StringUtils.isEmpty(deliveryServiceRequired)) {
            try {
                Integer numb = Integer.valueOf(deliveryServiceRequired);
                return String.valueOf(numb);
            } catch(Exception e) {
	            return deliveryServiceRequired.left(1);                
            }
        }
        
        return null;
    }
}