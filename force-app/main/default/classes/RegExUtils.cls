public class RegExUtils {
    public static Integer countAlphabetCharacterOccurrences(String content) {
        return countOccurrences(content, '[a-zA-Z]');
    }
    
    public static Integer countDigitOccurrences(String content) {
        return countOccurrences(content, '\\d');
    }
    
    private static Integer countOccurrences(String content, String regEx) {
        Pattern p = Pattern.compile(regEx);
        Matcher m = p.matcher(content);
        
        Integer count = 0;
        while (m.find()) {
            count++;
        }
            
        return count;
    }
}