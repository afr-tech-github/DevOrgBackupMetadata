/**
 * Created by khanhpham on 6/13/17.
 */

public with sharing class Util {
	public static Map<String, Decimal> WeightConversionRate = new Map<String, Decimal>{
		'g'     => 1,
		'Kg'    => 1000,
		'Ton'   => 1000000
	};
    public static Map<String, Amount_Wording_Setting__mdt> mapWording = new Map<String, Amount_Wording_Setting__mdt>();

	public static Decimal ConvertWeightToBaseUnit(String unit, Decimal weight) {
        if (!WeightConversionRate.containsKey(unit) || weight == null) {
            return weight;
        }
		return weight * WeightConversionRate.get(unit);
	}

	public static Decimal ConvertWeightFromBaseUnit(String unit, Decimal weight) {
        if (!WeightConversionRate.containsKey(unit) || weight == null) {
            return weight;
        }
		return weight / WeightConversionRate.get(unit);
	}

	public static Decimal ConvertWeightToUnit(String fromUnit, String toUnit, Decimal weight) {
        if (fromUnit == toUnit || !WeightConversionRate.containsKey(fromUnit) || !WeightConversionRate.containsKey(toUnit) || weight == null) {
            return weight;
        }
		return weight * (WeightConversionRate.get(fromUnit) / WeightConversionRate.get(toUnit));
	}

    private static final String SF_CUSTOM_DOMAIN_SUFFIX = '.my.salesforce.com';

    public static List<String> getObjectCustomFields(Schema.SObjectType objectType) {
        List<String> customFields = new List<String>();
        Map<String, Schema.sObjectField> fieldMap = objectType.getDescribe().fields.getMap();

        for (String fn : fieldMap.keySet()) {
            if (fn.endswith('__c')) {
                customFields.add(fn);
            }
        }
        return customFields;
    }

    public static String getObjectTypeId(final String objectType) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = schemaMap.get(objectType);
        String objectTypeId = sObjectType.getDescribe().getKeyPrefix();

        return objectTypeId;
    }

    public static String getServerInstance() {
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
        String sessionId = UserInfo.getSessionId();

        PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
        pr.getParameters().put('oauth_token', sessionId);
        pr.getParameters().put('format', 'json');

        String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
        Map<String,Object> result = (Map<String,Object>)Json.deserializeUntyped(data);
        Map<String,Object> urls = (Map<String,Object>)result.get('urls');

        Url rest = new Url((String)urls.get('rest'));
        String baseURL = rest.getHost();

        String instanceName = null;

        if (baseURL.contains(SF_CUSTOM_DOMAIN_SUFFIX)) {
            String domainName = getSFDomainFromBaseURL(baseURL);
            instanceName = getServerInstanceByDomainName(domainName);
        } else {
            String sfdcURL = baseURL.remove('https://');
            Integer index = sfdcURL.indexOf('.salesforce.com');
            instanceName = sfdcURL.substring(0, index);
        }

        return instanceName;
    }

    public static String getServerInstanceByDomainName(final String domainName) {
        String instanceName = null;

        try {
            String endpoint = 'https://api.status.salesforce.com/v1/instanceAliases/' + domainName;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText().equalsIgnoreCase('instanceKey')) {
                    parser.nextToken();
                    instanceName = parser.getText();
                }
            }
        } catch (Exception ex) {
        }

        return instanceName;
    }

    public static String getSFDomainFromBaseURL(String baseURL) {
        String domainName = null;

        if (baseURL.contains(SF_CUSTOM_DOMAIN_SUFFIX)) {
            baseURL = baseURL.remove('https://');
            Integer index = baseURL.indexOf(SF_CUSTOM_DOMAIN_SUFFIX);
            domainName = baseURL.substring(0, index);
        }

        return domainName;
    }

    public static Boolean isCashOut(CASH_BOOK__c cashBook) {
        return cashBook.RecordTypeId == Constants.RecordTypeId_CashBook_CashOut;
        // String recordTypeName = RecordTypeUtil.getRecordTypeDeveloperNameById(CASH_BOOK__c.SObjectType, cashBook.RecordTypeId);

        // return (Constants.CASH_OUT_RT.equalsIgnoreCase(recordTypeName));
    }

    public static Boolean isCashIn(CASH_BOOK__c cashBook) {
        return CashBook.RecordTypeId == Constants.RecordTypeId_CashBook_CashIn;
        // String recordTypeName = RecordTypeUtil.getRecordTypeDeveloperNameById(CASH_BOOK__c.SObjectType, cashBook.RecordTypeId);

        // return (Constants.CASH_IN_RT.equalsIgnoreCase(recordTypeName));
    }

    public static Decimal calculateSellingAmount(AnkenMeisai__c record) {
        Decimal chargeUnit = (record.Suryo__c != null ? record.Suryo__c : 0);
        Decimal sellingUnitPrice = (record.SellTankaJPY__c != null ? record.SellTankaJPY__c : 0);

        return (chargeUnit * sellingUnitPrice);
    }

    public static Decimal calculateSellingInTaxAmount(AnkenMeisai__c record) {
        Decimal sellingAmount = calculateSellingAmount(record);
        Decimal taxRatio = (record.TaxInitial__c != null ? record.TaxInitial__c : 0);
        Decimal taxAdjustment = (record.TAX_ADJUSTMENTSELL__c != null ? record.TAX_ADJUSTMENTSELL__c : 0);

        return (sellingAmount * (1 + taxRatio / 100) + taxAdjustment);
    }

    public static Decimal calculateBuyingAmount(AnkenMeisai__c record) {
        Decimal chargeUnit = (record.Suryo__c != null ? record.Suryo__c : 0);
        Decimal buyingUnitPrice = (record.BuyTankaJPY__c != null ? record.BuyTankaJPY__c : 0);
        Decimal taxRatio = (record.BuyTaxInitial__c != null ? record.BuyTaxInitial__c : 0);
        Decimal costAllocationMargin = (record.Cost_Allocation_Margin__c != null ? record.Cost_Allocation_Margin__c : 0);

        return (chargeUnit * buyingUnitPrice + costAllocationMargin/(1 + taxRatio));
    }

    public static Decimal calculateBuyingInTaxAmount(AnkenMeisai__c record) {
        Decimal buyingAMount = calculateBuyingAmount(record);
        Decimal taxRatio = (record.BuyTaxInitial__c != null ? record.BuyTaxInitial__c : 0);
        Decimal taxAdjustment = (record.TAX_ADJUSTMENTSELL__c != null ? record.TAX_ADJUSTMENTSELL__c : 0);
        
        return (buyingAMount * (1 + taxRatio / 100) + taxAdjustment);
    }

  //  public static Map<String, String> listOutWordingForObject(String objectName){
  //      List<Amount_Wording_Setting__mdt> listWordingField = [SELECT 
  //                                                              API_Object_Name__c, 
  //                                                              API_Amount_Field_Name__c, 
  //                                                              API_Wording_Field_Name__c,
  //                                                              Currency_Type__c,
  //                                                              API_En_Wording_Field_Name__c
  //                                                          FROM Amount_Wording_Setting__mdt 
  //                                                          WHERE API_Object_Name__c =: objectName];
  //      Map<String, String> mapWording = new Map<String, String>();
  //      Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
		//Map<String, Schema.SObjectField> object_fields_map = global_describe.get(objectName).getDescribe().fields.getMap();
  //      for(Amount_Wording_Setting__mdt wordingSetting : listWordingField){
  //          if(object_fields_map.containsKey(wordingSetting.API_Amount_Field_Name__c)
  //            && object_fields_map.containsKey(wordingSetting.API_Wording_Field_Name__c)){
  //              mapWording.put(wordingSetting.API_Amount_Field_Name__c, wordingSetting.API_Wording_Field_Name__c);
  //          }
  //      }

  //      return mapWording;
  //  }

    

  //  public static void wordingFields(sobject argSObject, Map<String, String> mapFieldWording){
  //      for(String amountField : mapFieldWording.keySet()){
  //          String wording = '';
  //          Decimal amount = (Decimal)(argSObject.get(amountField) != null? argSObject.get(amountField) : 0);
  //          wording = NumbericUtils.convertNumberToText(amount);
  //          argSObject.put(mapFieldWording.get(amountField), wording) ;
  //      }
  //  }

    public static void listOutFieldsWordingForObject(String objectName){
        List<Amount_Wording_Setting__mdt> listWordingField = [SELECT 
                                                                API_Object_Name__c, 
                                                                API_Amount_Field_Name__c, 
                                                                API_Wording_Field_Name__c,
                                                                Currency_Type__c,
                                                                API_En_Wording_Field_Name__c
                                                            FROM Amount_Wording_Setting__mdt 
                                                            WHERE API_Object_Name__c =: objectName];
        
        for(Amount_Wording_Setting__mdt wordingSetting : listWordingField){
            
            mapWording.put(wordingSetting.API_Amount_Field_Name__c, wordingSetting);
        }
    }
    public static void wordingFields(sobject argSObject, Map<String, Amount_Wording_Setting__mdt> mapFieldWording){
        Schema.SObjectType typeObject = argSObject.getSObjectType();
        Map<String, Schema.SObjectField> object_fields_map = typeObject.getDescribe().fields.getMap();
        //Schema.DescribeSObjectResult  describeObject = typeObject.getDescribe();
        
        for(String amountField : mapFieldWording.keySet()){
            if(object_fields_map.containsKey(amountField.toLowerCase())){
                Amount_Wording_Setting__mdt setting = mapFieldWording.get(amountField);
                String wording = '';

                Decimal amount = (Decimal)(argSObject.get(amountField) != null? argSObject.get(amountField) : 0);
                if(setting.Currency_Type__c == 'VND'){
                    // WORDING IN VI
                    if(!String.isBlank(setting.API_Wording_Field_Name__c)
                        && object_fields_map.containsKey(setting.API_Wording_Field_Name__c)){
                        wording = NumbericUtils.convertNumberToText(amount, setting.Currency_Type__c);
                        argSObject.put(setting.API_Wording_Field_Name__c, wording);
                    }

                    // WORDING IN EN
                    if(!String.isBlank(setting.API_En_Wording_Field_Name__c)
                        && object_fields_map.containsKey(setting.API_En_Wording_Field_Name__c)){
                        wording = NumbericUtils.readVNDAmountInEn(amount);
                        argSObject.put(setting.API_En_Wording_Field_Name__c, wording);
                    }
                }else{
                    // WORDING IN VI
                    if(!String.isBlank(setting.API_Wording_Field_Name__c)
                        && object_fields_map.containsKey(setting.API_Wording_Field_Name__c)){
                        wording = NumbericUtils.convertNumberToText(amount, setting.Currency_Type__c);
                        argSObject.put(setting.API_Wording_Field_Name__c, wording);
                    }

                    // WORDING IN EN
                    if(!String.isBlank(setting.API_En_Wording_Field_Name__c)
                        && object_fields_map.containsKey(setting.API_En_Wording_Field_Name__c)){
                        wording = NumbericUtils.readUSDAmountInEn(amount);
                        argSObject.put(setting.API_En_Wording_Field_Name__c, wording);
                    }
                }
            }
        }
    }
}