public class StringUtils {
    public static boolean isEmpty(String value) {
        if (value == null || value.trim() == '') {
            return true;
        }
        
        return false;
    }
    
    public static String capitalize(String value) {
        if (!StringUtils.isEmpty(value)) {
            return value.toUpperCase();
        }
        
        return value;
    }
    
    public static String escapeSingleQuotes(String value) {
        if (!isEmpty(value)) {
            return String.escapeSingleQuotes(value);
        }
        
        return value;
    }
    
    public static Boolean isContainedInCommaSeparateString(String content, String token) {
        if (!isEmpty(content) && !isEmpty(token)) {
	        List<String> tokens = content.split(',');    

            for (String t : tokens) {
                if (token.trim().equalsIgnoreCase(t.trim())) {
                    return true;
                }
            }
        }
		
        return false;
    }
    
    public static String prependZerosToNumber(Long intValue, Integer numberDigits) {
        String formatedValue = '' + intValue;
        Integer len = formatedValue.length();
        Integer numberOfZeros = (numberDigits > len ? (numberDigits - len) : 0);

        if (numberOfZeros > 0) {
            for (Integer i=0; i<numberOfZeros; i++) {
                formatedValue = '0' + formatedValue;
            }
        }
        
        return formatedValue;
    }
    
    public static String generateNameAbbreviation(String englishName) {
        String abbrName = '';
        
        if (!StringUtils.isEmpty(englishName)) {
            String[] tokens = englishName.split(' ');

            for (String token : tokens) {
                token = token.trim().toUppercase();
                if (!StringUtils.isEmpty(token)) {
                    abbrName += token.left(1);
                }
            }
        }
        
        return abbrName;
    }
}