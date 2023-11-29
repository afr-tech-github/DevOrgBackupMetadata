global with sharing class FormattingController {
    global Decimal value {get; set;}
    global String locale {get; set;}
    global Boolean roundUp {get; set;}
    global Integer decimalPlaces {get; set;}

    global String getFormattedValue() {
        if (roundUp == null) {
            roundUp = true;
        }
        return NumbericUtils.formatNumberByLocale(value, locale, roundUp, decimalPlaces);
    }
}