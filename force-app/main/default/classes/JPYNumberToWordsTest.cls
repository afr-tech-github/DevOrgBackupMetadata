@isTest
public class JPYNumberToWordsTest {
    public static testMethod void checkJPYNumberToWords() {
    Test.startTest();
      
    String num4 = JPYNumberToWords.convert(4);    
    System.assertEquals('FOUR YEN',num4);
        
    String num = JPYNumberToWords.convert(79550);    
    System.assertEquals('SEVEN MAN, NINE THOUSAND FIVE HUNDRED FIFTY YEN',num);
    
    String num1 = JPYNumberToWords.convert(100775);    
    System.assertEquals('TEN MAN, SEVEN HUNDRED SEVENTY FIVE YEN',num1);   
        
    String num2 = JPYNumberToWords.convert(127374955);     
    System.assertEquals('ONE OKU, TWO THOUSAND SEVEN HUNDRED THIRTY SEVEN MAN, FOUR THOUSAND NINE HUNDRED FIFTY FIVE YEN',num2);
        
    String num3 = JPYNumberToWords.convert(17774911);    
    System.assertEquals('ONE THOUSAND SEVEN HUNDRED SEVENTY SEVEN MAN, FOUR THOUSAND NINE HUNDRED ELEVEN YEN',num3);


    // String num5 = JPYNumberToWords.convert(17774911);    
    // System.assertEquals('ONE HUNDRED SEVENTY SEVEN MAN, SEVENTY FOUR THOUSAND NINE HUNDRED ELEVEN YEN',num5);
        
    Test.stopTest();
    }
}