@isTest
private class NumbericUtilsTest {
    testmethod static void shouldConvertNumberToText() {
        String result = 'Mười hai tỷ một trăm lẻ năm triệu một trăm mười hai nghìn không trăm lẻ năm đồng chẵn';
        String text = NumbericUtils.convertNumberToText(12105112005L);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    testmethod static void shouldConvertNumberToTextDecimal() {
        String result = 'ba đồng chẵn';
        String text = NumbericUtils.convertNumberToText(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void shouldConvertNumberToTextDecimalAndCurrency() {
        String result = 'Ba USD';
        String text = NumbericUtils.convertNumberToText(3.45, 'USD');
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void readUSDAmountTest() {
        String result = 'Ba USD,bốn mươi lăm cent';
        String text = NumbericUtils.readUSDAmount(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }   
    
    testmethod static void readUSDAmountInEnTest() {
        String result = 'three  dollars and fourty five  cents';
        String text = NumbericUtils.readUSDAmountInEn(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    
    
    testmethod static void isBlankTest() {
        Boolean text = NumbericUtils.isBlank(3.45);
        System.assertEquals(False, text);
    }
    
    testmethod static void isNonZeroTest() {
        Boolean text = NumbericUtils.isNonZero(3.45);
        System.assertEquals(True, text);
    }
    
    testmethod static void toDecimalTest() {
        Decimal text = NumbericUtils.toDecimal(3.45);
        System.assertEquals(3.45, text);
    }
    
    testmethod static void formatNumberByLocaleTest() {
        String result = '3';
        String text = NumbericUtils.formatNumberByLocale(3.45, 'vi', true, 3);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void readPHPAmountInEnTest() {
        String result = '(Philippine Pesos) three  pesos and fourty five  centavos';
        String text = NumbericUtils.readPHPAmountInEn(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void readUSDAmountInVNTest() {
        String result = 'Ba USD bốn mươi lăm cent';
        String text = NumbericUtils.readUSDAmountInVN(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void readPHPAmountInVNTest() {
        String result = 'Ba PESO bốn mươi lăm cent';
        String text = NumbericUtils.readPHPAmountInVN(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void readVNDAmountInEnTest() {
        String result = 'Vietnam dong three';
        String text = NumbericUtils.readVNDAmountInEn(3.45);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
    
    testmethod static void convertNumberToEnglishText() {
        String result = 'three';
        String text = NumbericUtils.convertNumberToEnglishText(3);
        System.assertEquals(result.toLowerCase(), text.trim().toLowerCase());
    }
}