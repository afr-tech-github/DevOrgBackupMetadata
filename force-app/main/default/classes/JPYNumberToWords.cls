public with sharing class JPYNumberToWords {
 
  private static final String[] tensNames = new String[] {
    '',
    ' TEN',
    ' TWENTY',
    ' THIRTY',
    ' FORTY',
    ' FIFTY',
    ' SIXTY',
    ' SEVENTY',
    ' EIGHTY',
    ' NINETY'
  };
 
  private static final String[] numNames = new String []{
    '',
    ' ONE',
    ' TWO',
    ' THREE',
    ' FOUR',
    ' FIVE',
    ' SIX',
    ' SEVEN',
    ' EIGHT',
    ' NINE',
    ' TEN',
    ' ELEVEN',
    ' TWELVE',
    ' THIRTEEN',
    ' FOURTEEN',
    ' FIFTEEN',
    ' SIXTEEN',
    ' SEVENTEEN',
    ' EIGHTEEN',
    ' NINETEEN'
  };
 

 
  private static String convertLessThanOneThousand(Integer number1) {
    String soFar = '';
 	String convert ='';
    if (math.mod(number1,100) < 20){
      soFar = numNames[math.mod(number1,100)];
      number1 /= 100;
    }
    else {
      soFar = numNames[math.mod(number1,10)];
      number1 /= 10;
 
      soFar = tensNames[math.mod(number1,10)] + soFar;
      number1 /= 10;
    }
    if (number1 == 0) return soFar;
    convert = numNames[number1] +' HUNDRED'+ soFar;
      return convert;
  }
 
 
  public static String convert(Decimal number1) {
    // 0 to 999 999 999 999
    if (number1 == 0) { return 'ZERO'; }
 
    String snumber = String.valueOf(number1);
      System.debug('snumber:'+ snumber);
 		System.debug('snumberlength:'+ snumber.length());
    // pad with '0'
    //String mask = '000000000000';
    //DecimalFormat df = new DecimalFormat(mask);
    //snumber = df.format(number1); 
    // 
    String snumberYen='';
    String snumberMan='';
    String snumberOku='';
    if(snumber.length()>8){
        snumberYen = snumber.substring(snumber.length()-4);
        snumberMan = snumber.substring(snumber.length()-8,snumber.length()-4);
        snumberOku = snumber.substring(0,snumber.length()-8);
    } else if(snumber.length()<9 && snumber.length()>4) {
      	snumberYen = snumber.substring(snumber.length()-4);
        snumberMan = snumber.substring(0,snumber.length()-4);
    } else {
        snumberYen = snumber;
    }
      
    String result = '';
    String resultYen = '';
    String resultMan = '';
    String resultOku = '';
    
    // Yen
    If (snumberYen.length()>0 && snumberYen.length()<4){
    	Integer thousands = Integer.valueOf(snumberYen.substring(0,snumberYen.length()));
        String tradThousand = '';
        if(thousands > 0){
        	tradThousand = convertLessThanOneThousand(thousands);
        }
        resultYen = tradThousand;
    }
    If (snumberYen.length()>3 && snumberYen.length()<5){
    	Integer thousands = Integer.valueOf(snumberYen.substring(snumberYen.length()-3,snumberYen.length()));
        String tradThousand = '';
        if(thousands > 0){
        	tradThousand = convertLessThanOneThousand(thousands);
        }
        resultYen = tradThousand;
        Integer hundredThousands = Integer.valueOf(snumberYen.substring(0,snumberYen.length()-3));
        String tradHundredThousands = '';
        if(hundredThousands > 0){
         	tradHundredThousands = convertLessThanOneThousand(hundredThousands)+ ' THOUSAND ';
        	}
       	resultYen = tradHundredThousands + resultYen;
    }
      
    //Man
    If (snumberMan != ''){
        If (Integer.valueOf(snumberMan) > 0){
            If (snumberMan.length()>0 && snumberMan.length()<4){
                Integer thousands = Integer.valueOf(snumberMan.substring(0,snumberMan.length()));
                String tradThousand = '';
                if(thousands > 0){
                    tradThousand = convertLessThanOneThousand(thousands);
                }
                resultMan = tradThousand + ' MAN,';
            }
            If (snumberMan.length()>3 && snumberMan.length()<5){
                Integer thousands = Integer.valueOf(snumberMan.substring(snumberMan.length()-3,snumberMan.length()));
                String tradThousand = '';
                if(thousands > 0){
                    tradThousand = convertLessThanOneThousand(thousands);
                }
                resultMan = tradThousand;
                Integer hundredThousands = Integer.valueOf(snumberMan.substring(0,snumberMan.length()-3));
                String tradHundredThousands = '';
                if(hundredThousands > 0){
                    tradHundredThousands = convertLessThanOneThousand(hundredThousands)+ ' THOUSAND ';
                    }
                resultMan = tradHundredThousands + resultMan + ' MAN,';
            }
        }
    }
      
    //OKU
    If (snumberOku.length()>0 && snumberOku.length()<4){
    	Integer thousands = Integer.valueOf(snumberOku.substring(0,snumberOku.length()));
        String tradThousand = '';
        if(thousands > 0){
        	tradThousand = convertLessThanOneThousand(thousands);
        }
        resultOku = tradThousand + ' OKU,';
    }
    
    result = resultOku + resultMan + resultYen + ' YEN';
    If (resultYen == ''){
    	result = result.substring(0, result.length()-5)+ result.substring(result.length()-4);      
    }
  	return result.replaceAll('^\\s+', '').replaceAll('\\b\\s{2,}\\b', ' ');
  }
}