public with sharing class ShippingInstructionController {
    public static clofor_com_cfs__CustomObject1__c sobj {get; set;}
    public static totalContainerInfo sobjTotal {get; set;}
    public static List<clofor_com_cfs__Container_Info__c> listContainerInfo {get; set;}
    
    public ShippingInstructionController() {
        sobj = getColorComCfsCustomObjet1();

        if (sobj != null) {
            Decimal quantity = 0;
            Decimal grossWeight = 0;
            Decimal measurementCBM = 0;
            listContainerInfo = getCloforComCfsContainerInfo(sobj.Id);
            for (clofor_com_cfs__Container_Info__c sobjContainerInfo : listContainerInfo) {
                quantity += sobjContainerInfo.clofor_com_cfs__QUANTITY_PACKAGES__c == null ? 0 : sobjContainerInfo.clofor_com_cfs__QUANTITY_PACKAGES__c;
                grossWeight += sobjContainerInfo.clofor_com_cfs__GROSS_WEIGHT__c == null ? 0 : sobjContainerInfo.clofor_com_cfs__GROSS_WEIGHT__c;
                measurementCBM += sobjContainerInfo.clofor_com_cfs__MEASUREMENT_CBM__c == null ? 0 : sobjContainerInfo.clofor_com_cfs__MEASUREMENT_CBM__c;
            }

            sobjTotal = new  totalContainerInfo();
            sobjTotal.quantityTotal = quantity;
            sobjTotal.grossWeightTotal = grossWeight;
            sobjTotal.cbmTotal = measurementCBM;
        }
    }

    public class totalContainerInfo {
        public Decimal quantityTotal {get; set;}
        public Decimal codePackageTotal {get; set;}
        public Decimal grossWeightTotal {get; set;}
        public Decimal cbmTotal {get; set;}
        public Decimal vgmTotal {get; set;}
    }

    // clofor_com_cfs__HSCode__c

    private static clofor_com_cfs__CustomObject1__c getColorComCfsCustomObjet1() {
        List<clofor_com_cfs__CustomObject1__c> listSobj = [SELECT Id
                                                                ,clofor_com_cfs__BookingNo__c
                                                                ,clofor_com_cfs__VESSEL_FLIGHT__c
                                                                ,clofor_com_cfs__wkRecordType__c
                                                                ,clofor_com_cfs__ADDRESS_ON_B_L__c
                                                                ,clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c
                                                                ,clofor_com_cfs__NOTIFY_ADDRESS_ON_B_L__c
                                                                ,clofor_com_cfs__Item__c
                                                                //,clofor_com_cfs__HSCode__c
                                                                ,clofor_com_cfs__POL__c
                                                                ,clofor_com_cfs__POD__c
                                                                ,clofor_com_cfs__Place_Of_Delivery__c
                                                                ,clofor_com_cfs__Remarks__c
                                                        FROM clofor_com_cfs__CustomObject1__c
                                                        LIMIT 1
                                                        ];

        clofor_com_cfs__CustomObject1__c sobj = new clofor_com_cfs__CustomObject1__c();
        if (!listSobj.isEmpty()) {
            sobj = listSobj[0];
        }

        return sobj;
    }

    private static List<clofor_com_cfs__Container_Info__c> getCloforComCfsContainerInfo(String customObject1Id) {
        List<clofor_com_cfs__Container_Info__c> listSobj = [SELECT Id
                                                                ,clofor_com_cfs__Container_NO__c
                                                                ,clofor_com_cfs__Seal_No__c
                                                                ,clofor_com_cfs__QUANTITY_PACKAGES__c
                                                                ,clofor_com_cfs__GROSS_WEIGHT__c
                                                                ,clofor_com_cfs__MEASUREMENT_CBM__c
                                                            FROM clofor_com_cfs__Container_Info__c
                                                            WHERE clofor_com_cfs__HBL_SHIPMENT__c = :customObject1Id
                                                            ];

        return listSobj;
    }
    
}