/**
 * See https://github.com/dhoechst/Salesforce-Test-Factory/blob/master/src/classes/TestFactory.cls#L137
 */
//@isTest
public class TestDataFactory {
    public static SObject createSObject(SObject sObj, Map<String, Object> additionalFields) {
        String objectName = String.valueOf(sObj.getSObjectType());
        objectName = objectName.replace(Constants.NAMESPACE, '');
        String defaultClassName = 'TestDataFactory.' + objectName.replace('__c', '') + 'Defaults';

        if (Type.forName(defaultClassName) != null) {
            sObj = createSObject(sObj, defaultClassName, additionalFields);
        }
        System.assert(true);
        return sObj;
    }

    public static SObject createSObject(SObject sObj, Boolean doInsert, Map<String, Object> additionalFields) {
        SObject retObject = createSObject(sObj, additionalFields);

        if (doInsert) {
            FlsService.doInsert(retObject);
        }
        System.assert(true);
        return retObject;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName, Map<String, Object> additionalFields) {
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            Throw new TestFactoryException('Invalid defaults class.');
        }

        FieldDefaults defaults = (FieldDefaults) t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults());

        if (additionalFields != null && additionalFields.size() > 0) {
            addOveriddenFields(sObj, additionalFields);
        }
        System.assert(true);
        return sObj;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert, Map<String, Object> additionalFields) {
        SObject retObject = createSObject(sObj, defaultClassName, additionalFields);
        if (doInsert) {
            FlsService.doInsert(retObject);
        }
        System.assert(true);
        return retObject;
    }

    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
        return createSObjectList(sObj, numberOfObjects, (String) null);
    }

    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, (String) null);
        if (doInsert) {
            FlsService.doInsert(retList);
        }
        System.assert(true);
        return retList;
    }

    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
        if (doInsert) {
            FlsService.doInsert(retList);
        }
        System.assert(true);
        return retList;
    }

    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
        SObject[] sObjs = new SObject[]{
        };
        SObject newObj;

        // Get one copy of the object
        if (defaultClassName == null) {
            newObj = createSObject(sObj, null);
        } else {
            newObj = createSObject(sObj, defaultClassName, null);
        }

        // Get the name field for the object
        String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
        if (nameField == null) {
            nameField = 'Name';
        }

        // Clone the object the number of times requested. Increment the name field so each record is unique
        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);
            clonedSObj.put(nameField, (String) clonedSObj.get(nameField) + ' ' + i);
            sObjs.add(clonedSObj);
        }
        return sObjs;
    }

    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        // Loop through the map of fields and if they are null on the object, fill them.
        for (String field : defaults.keySet()) {
            if (sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        }
    }

    private static void addOveriddenFields(SObject sObj, Map<String, Object> overriddenFields) {
        // Loop through the map of fields and override the value.
        for (String field : overriddenFields.keySet()) {
            sObj.put(field, overriddenFields.get(field));
        }
    }

    // When we create a list of SObjects, we need to
    private static Map<String, String> nameFieldMap = new Map<String, String>{
            'Contact' => 'LastName',
            'Case' => 'Subject'
    };

    public class TestFactoryException extends Exception {
    }

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }

    // To specify defaults for objects, use the naming convention [ObjectName]Defaults.
    // For custom objects, omit the __c from the Object Name

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            String accountName = 'Test Account ' + (new UUIDUtil()).generateUUID();
            return new Map<String, Object>{
                    'Name' => accountName,
                    'EnglishCompanyName__c' => accountName
            };
        }
    }

    public class ContactDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'FirstName' => 'First',
                    'LastName' => 'Last'
            };
        }
    }

    public class OpportunityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'Name' => 'Test Opportunity',
                    'StageName' => 'Closed Won',
                    'CloseDate' => System.today()
            };
        }
    }

    public class TariffMasterDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'Name' => 'Service Master'
            };
        }
    }

    public class Tax_RatioDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            Date startDate = system.today();
            Date endDate = startDate.addDays(5);

            return new Map<String, Object>{
                    'Currency__c' => 'USD',
                    'Selling_Tax_Ratio__c' => 8,
                    'Buying_Tax_Ratio__c' => 6,
                    'Start_Date__c' => startDate,
                    'End_Date__c' => endDate,
                    'Active__c' => true
            };
        }
    }

    public class CustomObject1Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'FlgCopy__c' => 'true'
            };
        }
    }

    public class AnkenMeisaiDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'curr__c' => 'JPY'
            };
        }
    }

    public class MasterAnkenDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'Name' => 'Name ' + System.now()
            };
        }
    }

    public class LoadLocationDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'Name' => 'Load Location ' + System.now()
            };
        }
    }

    public class MasterAnkenMeisaiDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class MgmtMasterDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'Mgmt_Exrate_Validity__c' => true
            };
        }
    }

    public class Non_Standard_Exchange_RateDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class Container_InfoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class CONTAINER_INFO_MAPPINGSDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class Site_Custom_SettingsDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class SLA_Calendar_SettingsDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class HolidayDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class PortDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class Common_SettingsDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class TranslationDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class Custom_ClearanceDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class HS_CodeDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class Cargo_DeliveryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class Carrier_CodeDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class VAT_INVOICEDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class INVOICING_VATDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class FORWARDING_VATDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class MANIFESTDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class TruckFleetDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class RouteDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class LoadingLocationDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class PurchasingOrderDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class PurchasingInvoiceDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class CASH_BOOKDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class ConnectPurchasingInvoiceCashDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class ConnectInvoicingAndCashDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class TimeEntryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class TransitDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class KickbackDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class ConnectKickabckCashDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
            };
        }
    }

    public class UUIDUtil {
        private String kHexChars = '0123456789abcdef';

        public String generateUUID() {

            String returnValue = '';
            Integer nextByte = 0;

            for (Integer i = 0; i < 16; i++) {

                if (i == 4 || i == 6 || i == 8 || i == 10)
                    returnValue += '-';

                nextByte = (Math.round(Math.random() * 255) - 128) & 255;

                if (i == 6) {
                    nextByte = nextByte & 15;
                    nextByte = nextByte | (4 << 4);
                }

                if (i == 8) {
                    nextByte = nextByte & 63;
                    nextByte = nextByte | 128;
                }

                returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
                returnValue += getCharAtIndex(kHexChars, nextByte & 15);
            }

            return returnValue;
        }

        private String getCharAtIndex(String str, Integer index) {

            if (str == null) return null;

            if (str.length() <= 0) return str;

            if (index == str.length()) return null;

            return str.substring(index, index + 1);
        }
    }
}