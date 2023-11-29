global with sharing class NumbericUtils {
    public static boolean isBlank(Decimal value) {
        return (value == null || value == 0);
    }

    public static boolean isNonZero(Decimal value) {
        return (value != null && value != 0);
    }

    public static Decimal toDecimal(Decimal value) {
        return (isNonZero(value) ? value : 0);
    }

    public static String formatNumberByLocale(Decimal value, String locale, Boolean roundUp, Integer decimalPlaces) {
        String result = '';
        String thousandSeperator = ('vi'.equalsIgnoreCase(locale) ? ',' : '.');
        String decimalSeperator = ('vi'.equalsIgnoreCase(locale) ? '.' : ',');
        String decimalMark = getDecimalMark();

        if (roundUp) {
            decimalPlaces = 0;
        }

        if (value != null) {
            if (roundUp != null && roundUp == true) {
                value = value.round(System.RoundingMode.HALF_UP);// Math.roundToLong(value);
            }

            if (value == 0) {
                result = '0';
                //
                //if (decimalPlaces != null && decimalPlaces > 0) {
                //    result += decimalMark;

                //    for (Integer i = 0; i < decimalPlaces - 1; i++) {
                //        result += '0';
                //    }
                //}
            } else {
                String decimalString = value.toPlainString();
                decimalString = decimalString.replace(',', '.');
                List<String> numbers = decimalString.split('\\.');
                String firstPart = numbers.get(0);
                String secondPart = '';

                if (numbers.size() == 2 && Integer.valueOf(numbers.get(1).substring(0, 2)) > 0) {
                    secondPart = numbers.get(1).substring(0, 2);

                    if (decimalPlaces != null && decimalPlaces > 0) {
                        Decimal fractionalValue = Decimal.valueOf('0' + decimalMark + secondPart);
                        fractionalValue = fractionalValue.setScale(decimalPlaces, System.RoundingMode.HALF_DOWN);
                        secondPart = fractionalValue.toPlainString().substringAfter(decimalMark);

                        if (secondPart != null && '0'.equals(secondPart.substring(decimalPlaces - 1))) {
                            secondPart = secondPart.substring(0, decimalPlaces - 1);
                        }
                    } else {
                        secondPart = '';
                    }

                    secondPart = removeTrailingZeros(secondPart);
                } 
                //else if (decimalPlaces != null && decimalPlaces > 0) {
                //    for (Integer i = 0; i < decimalPlaces - 1; i++) {
                //        secondPart += '0';
                //    }
                //}

                Long firstPartNumber = Long.valueOf(firstPart);
                List<String> tokens = new List<String>();

                while (firstPartNumber >= 1000) {
                    tokens.add(StringUtils.prependZerosToNumber((Long) Math.mod(firstPartNumber, 1000), 3));
                    firstPartNumber = firstPartNumber / 1000;
                }

                if (firstPartNumber > 0) {
                    tokens.add('' + firstPartNumber);
                }

                List<String> revertedTokens = new List<String>();
                if (tokens.size() > 0) {
                    revertedTokens.add('' + Integer.valueOf(tokens.get(tokens.size() - 1)));

                    for (Integer i = tokens.size() - 2; i >= 0; i--) {
                        revertedTokens.add(tokens.get(i));
                    }
                }

                result = String.join(revertedTokens, thousandSeperator);
                result = (StringUtils.isEmpty(result) ? '0' : result);
                if (!StringUtils.isEmpty(secondPart) && (Integer.valueOf(secondPart) > 0 || (decimalPlaces != null && decimalPlaces > 0))) {
                    result += decimalSeperator + secondPart;
                }
            }
        }

        return result;
    }

    /*public static String formatNumberByLocale(Decimal value, String locale, Boolean roundUp, Integer decimalPlaces) {
        String result = '';
        String thousandSeperator = ('vi'.equalsIgnoreCase(locale) ? ',' : '.');
        String decimalSeperator = ('vi'.equalsIgnoreCase(locale) ? '.' : ',');
        //String decimalMark = getDecimalMark();

        if (roundUp || decimalPlaces == null) {
            decimalPlaces = 0;
        }
        if(value == null){
            value = 0;   
        }
        value = value.setScale(decimalPlaces);

        String valueToString = String.valueOf(value);
        List<String> numbers = valueToString.split('\\.');
        String integerPart = numbers[0];
        String integerPartResult = '';
        String modPart = '';
        Integer mod = Math.mod(integerPart.length(), 3);
        if(mod > 0){
            modPart = integerPart.substring(0, mod);
            integerPartResult = integerPart.substring(mod, integerPart.length());
        }else{
            integerPartResult = integerPart;
        }
        List<String> integerPartArr = new List<String>();
        for(Integer i = 0; i < integerPartResult.length()/3; i++){
            integerPartArr.add(integerPartResult.substring(i, i + 3));
        }

        integerPartResult = String.join(integerPartArr, thousandSeperator);

        if(modPart != '' && integerPart.length() > 3){
            integerPartResult = modPart + thousandSeperator + integerPartResult;
        }
        if(modPart != '' && integerPart.length() <= 3){
            integerPartResult = modPart;
        }
        if(numbers.size() > 1){

            String decimalPart = numbers[1];
            while(decimalPart.lastIndexOf('0') == decimalPart.length() -1 && decimalPart.length() > 0){
                decimalPart = decimalPart.removeEnd('0');
            }
            if(!String.isBlank(decimalPart)){
                integerPartResult = integerPartResult + decimalSeperator + decimalPart;
            }
            
        }
        
        return integerPartResult;
    }*/

    private static String removeTrailingZeros(String numberString) {
        if (StringUtils.isEmpty(numberString)) {
            return '';
        } else {
            while (numberString.endsWith('0')) {
                numberString = numberString.left(numberString.length() - 1);
            }

            return numberString;
        }
    }

    public static String getDecimalMark() {
        Decimal dummyValue = 1.5;
        String dummyValueString = dummyValue.toPlainString();
        String decimalMark = (dummyValueString.contains('.') ? '.' : ',');

        return decimalMark;
    }
    
    /**
     * Convert number to words.
     * Scope: applicable to Vietnamese only
     */
    private static final String[] VI_WORDS = new String[]{
            'không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'
    };
    private static final String[] EN_WORDS = new String[]{
            'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
    };
    private static final String VI_SUFFIX = ' đồng chẵn';

    private static String readTenth(Long value, Boolean full) {
        String result = '';
        Integer tens = (Integer) Math.floor(value / 10);
        Integer unit = (Integer) Math.mod(value, 10);

        if (tens > 1) {
            result = ' ' + VI_WORDS[tens] + ' mươi';
            if (unit == 1) {
                result += ' mốt';
            }
        } else if (tens == 1) {
            result = ' mười';
            if (unit == 1) {
                result += ' một';
            }
        } else if (full && unit > 0) {
            result = ' lẻ';
        }

        if (unit == 5 && tens >= 1) {
            result += ' lăm';
        } else if (unit > 1 || (unit == 1 && tens == 0)) {
            result += ' ' + VI_WORDS[unit];
        }

        return result;
    }

     private static String readTenthEn(Long value) {
        String result = '';
        Integer tens = (Integer) Math.floor(value / 10);
        Integer unit = (Integer) Math.mod(value, 10);
        String[] arrayTenthEn1 = new String []{'ten', 'eleven', 'twelve', 'thirteen','fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'};
        String[] arrayTenthEn2 = new String []{'zero','ten', 'twenty', 'thirty', 'fourty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'};
        if (tens > 1) {
            result = ' ' + arrayTenthEn2[tens];

            if(unit > 0){
                result += ' ' + EN_WORDS[unit];
            }
            
        } else if (tens == 1) {
            result = ' ' + arrayTenthEn1[unit];
        }else if(tens < 1){
            result = ' ' + EN_WORDS[unit];
        }

        return result;
    }

    private static String readBlock(Long value, boolean full) {
        String result = '';
        Integer hundreds = (Integer) Math.floor(value / 100);
        value = Math.mod(value, 100);


        if (full || hundreds > 0) {
            result = ' ' + VI_WORDS[hundreds] + ' trăm';
            result += readTenth(value, true);
        } else {
            result = readTenth(value, false);
        }

        return result;
    }

    private static String readBlockEn(Long value) {
        String result = '';
        Integer hundreds = (Integer) Math.floor(value / 100);
        value = Math.mod(value, 100);

        if (hundreds > 0) {
            result = ' ' + EN_WORDS[hundreds] + ' hundred';
        }
        if(value > 0 ){
            result += readTenthEn(value);
        }
        
        

        return result;
    }

    private static String readMillionth(Long value, boolean full) {
        String result = '';
        Integer millions = (Integer) Math.floor(value / 1000000);
        value = Math.mod(value, 1000000);

        if (millions > 0) {
            result = readBlock(millions, full) + ' triệu';
            full = true;
        }

        Integer thousands = (Integer) Math.floor(value / 1000);
        value = Math.mod(value, 1000);

        if (thousands > 0) {
            result += readBlock(thousands, full) + ' nghìn';
            full = true;
        }

        if (value > 0) {
            result += readBlock(value, full);
        }

        return result;
    }

     private static String readMillionthEn(Long value, boolean full) {
        String result = '';
        Integer millions = (Integer) Math.floor(value / 1000000);
        
        value = Math.mod(value, 1000000);

        if (millions > 0) {
            
            result = readBlockEn(millions) + ' million';
            full = true;
        }

        Integer thousands = (Integer) Math.floor(value / 1000);
        value = Math.mod(value, 1000);

        if (thousands > 0) {
            result += readBlockEn(thousands) + ' thousand';
            full = true;
        }

        if (value > 0) {
            result += readBlockEn(value);
        }

        return result;
    }

    public static String convertNumberToText(Decimal value) {
        return convertNumberToText((Long) value);
    }

    public static String convertNumberToText(Decimal value, String readCurrency) {
        return convertNumberToText((Long) value, readCurrency);
    }

    public static String readUSDAmount(Decimal value) {
        String result = '';
        String decimalPoint = getDecimalMark();
        String plainValue = value.toPlainString();
        List<String> numbers = plainValue.split('\\.');

        if (numbers != null && numbers.size() > 0) {
            Long firstPart = Long.valueOf(numbers.get(0));
            firstPart = (firstPart < 0) ? firstPart * (-1) : firstPart;

            result = NumbericUtils.convertNumberToText(firstPart, 'USD');

            if (numbers.size() == 2) {
                Long secondPart = Long.valueOf(numbers.get(1).substring(0, 2));

                result += ',' + NumbericUtils.convertNumberToText(secondPart, 'cent').toLowerCase();
            }
        }

        return result;
    }

    public static String readUSDAmountInEn(Decimal value) {
        String result = '';
        String decimalPoint = getDecimalMark();
        String plainValue = value.toPlainString();
        List<String> numbers = plainValue.split('\\.');

        if (numbers != null && numbers.size() > 0) {
            Long firstPart = Long.valueOf(numbers.get(0));
            firstPart = (firstPart < 0) ? firstPart * (-1) : firstPart;

            result = NumbericUtils.convertNumberToEnText(firstPart, firstPart > 1? ' dollars' : ' dollar');

            if (numbers.size() == 2) {
                Long secondPart = Long.valueOf(numbers.get(1).substring(0, 2));
                if(secondPart > 0){
                    result += ' and' + NumbericUtils.convertNumberToEnText(secondPart, secondPart > 1?' cents': ' cent').toLowerCase();
                }else{
                    result += ' and zero cents';

                }
                
            }
        }
		
        return   result.trim().toUpperCase();
    }

    public static String readPHPAmountInEn(Decimal value) {
        String result = '';
        String decimalPoint = getDecimalMark();
        String plainValue = value.toPlainString();
        List<String> numbers = plainValue.split('\\.');

        if (numbers != null && numbers.size() > 0) {
            Long firstPart = Long.valueOf(numbers.get(0));
            firstPart = (firstPart < 0) ? firstPart * (-1) : firstPart;

            result = NumbericUtils.convertNumberToEnText(firstPart, firstPart > 1? ' pesos' : ' peso');

            if (numbers.size() == 2) {
                Long secondPart = Long.valueOf(numbers.get(1).substring(0, 2));
                if(secondPart > 0){
                    result += ' and' + NumbericUtils.convertNumberToEnText(secondPart, secondPart > 1?' centavos': ' centavo').toLowerCase();
                }
                
            }
        }
		
        return  '(Philippine Pesos) ' + result.trim();
    }
    
    public static String readUSDAmountInVN(Decimal value) {
        String result = '';
        String decimalPoint = getDecimalMark();
        String plainValue = value.toPlainString();
        List<String> numbers = plainValue.split('\\.');

        if (numbers != null && numbers.size() > 0) {
            Long firstPart = Long.valueOf(numbers.get(0));
            firstPart = (firstPart < 0) ? firstPart * (-1) : firstPart;

            result = NumbericUtils.convertNumberToText(firstPart, 'USD');

            if (numbers.size() == 2) {
                Long secondPart = Long.valueOf(numbers.get(1).substring(0, 2));
                if(secondPart > 0){
                    result += ' ' + NumbericUtils.convertNumberToText(secondPart, 'CENT').toLowerCase();
                }
                
            }
        }
		
        return capitalizeFirstUnicodeWord(result.trim());
    }

    public static String readPHPAmountInVN(Decimal value) {
        String result = '';
        String decimalPoint = getDecimalMark();
        String plainValue = value.toPlainString();
        List<String> numbers = plainValue.split('\\.');

        if (numbers != null && numbers.size() > 0) {
            Long firstPart = Long.valueOf(numbers.get(0));
            firstPart = (firstPart < 0) ? firstPart * (-1) : firstPart;

            result = NumbericUtils.convertNumberToText(firstPart, 'PESO');

            if (numbers.size() == 2) {
                Long secondPart = Long.valueOf(numbers.get(1).substring(0, 2));
                if(secondPart > 0){
                    result += ' ' + NumbericUtils.convertNumberToText(secondPart, 'CENT').toLowerCase();
                }
                
            }
        }
		
        return capitalizeFirstUnicodeWord(result.trim());
    }

     public static String readVNDAmountInEn(Decimal value) {
        String result = '';
        String decimalPoint = getDecimalMark();
        String plainValue = value.toPlainString();
        List<String> numbers = plainValue.split('\\.');

        if (numbers != null && numbers.size() > 0) {
            Long firstPart = Long.valueOf(numbers.get(0));
            firstPart = (firstPart < 0) ? firstPart * (-1) : firstPart;

            result = NumbericUtils.convertNumberToEnText(firstPart, '');
            //if (numbers.size() == 2) {
            //    Long secondPart = Long.valueOf(numbers.get(1).substring(0, 2));

            //    result += ',' + NumbericUtils.convertNumberToEnText(secondPart, 'cents').toLowerCase();
            //}
        }

        return 'Vietnam dong ' + result.trim();
    }

    public static String convertNumberToText(Long value) {
        String result = '';
        String suffix = '';

        if (value == 0) {
            result = VI_WORDS[0];
        }

        do {
            Integer billions = (Integer) Math.mod(value, 1000000000);
            value = (Long) Math.floor(value / 1000000000);

            if (value > 0) {
                result = readMillionth(billions, true) + suffix + result;
            } else {
                result = readMillionth(billions, false) + suffix + result;
            }

            suffix = ' tỷ';
        } while (value > 0);

        if (!StringUtils.isEmpty(result)) {
            result += VI_SUFFIX;
        }

        return capitalizeFirstUnicodeWord(result);
    }

    public static String convertNumberToText(Long value, String readCurrency) {
        String result = '';
        String suffix = '';

        if (value == 0) {
            result = VI_WORDS[0];
        }

        do {
            Integer billions = (Integer) Math.mod(value, 1000000000);
            value = (Long) Math.floor(value / 1000000000);

            if (value > 0) {
                result = readMillionth(billions, true) + suffix + result;
            } else {
                result = readMillionth(billions, false) + suffix + result;
            }

            suffix = ' tỷ';
        } while (value > 0);

        if (!StringUtils.isEmpty(result)) {
            if (Constants.CURRENCY_VND.equalsIgnoreCase(readCurrency)) {
                result += VI_SUFFIX;
            } else {
                result += ' ' + readCurrency;
            }
        }

        //return result;
        
        return capitalizeFirstUnicodeWord(result.trim());
    }


    global static String convertNumberToEnText(Long value, String readCurrency) {
        String result = '';
        String suffix = '';
        if (value == 0) {
            result = 'zero';
        }

        do {
            Integer billions = (Integer) Math.mod(value, 1000000000);
            value = (Long) Math.floor(value / 1000000000);
            if (value > 0) {
                result = readMillionthEn(billions, true) + suffix + result;
            } else {
                result = readMillionthEn(billions, false) + suffix + result;
                
            }

            suffix = ' Billion';
        } while (value > 0);

        if (!StringUtils.isEmpty(result)) {

            result += ' ' + readCurrency;
        }

        //return result;
        //result = result.trim();
        return capitalizeFirstUnicodeWord(result);
    }

    private static String capitalizeFirstUnicodeWord(String value) {
        if (!StringUtils.isEmpty(value) && value.length() > 1) {
            return value.substring(0, 1).toUpperCase() + value.substring(1);
        }

        return value;
    }

    /**
     * Convert numbers to words in English
     * Note: This is a simple version which can accommodate upto billion only
     */

    global static String convertNumberToEnglishText(Integer value) {
        String words = '';
        String[] unitsArray = new String[]{
                'zero', 'one', 'two', 'three', 'four', 'five', 'six',
                'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve',
                'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen',
                'eighteen', 'nineteen'
        };
        String[] tensArray = new String[]{
                'zero', 'ten', 'twenty', 'thirty', 'forty', 'fifty',
                'sixty', 'seventy', 'eighty', 'ninety'
        };

        if (value == null) {
            return '';
        }

        if (value == 0) {
            return 'zero';
        }

        if (value < 0) {
            value *= (-1);
            return 'minus ' + convertNumberToEnglishText(value);
        }

        // check if value is divisible by 1 million
        if ((Math.floor(value / 1000000)) > 0) {
            words += convertNumberToEnglishText((Integer)Math.floor(value / 1000000)) + ' million ';
            value = Math.mod(value, 1000000);
        }

        // check if number is divisible by 1 thousand
        if ((Math.floor(value / 1000)) > 0) {
            words += convertNumberToEnglishText((Integer)Math.floor(value / 1000)) + ' thousand ';
            value = Math.mod(value, 1000);
        }

        // check if number is divisible by 1 hundred
        if ((Math.floor(value / 100)) > 0) {
            words += convertNumberToEnglishText((Integer)Math.floor(value / 100)) + ' hundred ';
            value = Math.mod(value, 100);
        }

        if (value > 0) {
            // check if number is within teens
            if (value < 20) {
                // fetch the appropriate value from unit array
                words += unitsArray[(Integer)value];
            } else {
                // fetch the appropriate value from tens array
                words += tensArray[(Integer)value / 10];
                if ((Math.mod(value, 10)) > 0) {
                    words += ' ' + unitsArray[(Integer)Math.mod(value, 10)];
                }
            }
        }

        return words;
    }
}