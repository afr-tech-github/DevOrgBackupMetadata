/**
 * Created by khanhpham on 6/17/17.
 */

public with sharing class DataLoadingController {
    public Blob csvFileBody { get; set; }
    public String fileName { get; set; }
    public List<Container_Info__c> containerInfoList { get; set; }
    public List<SelectOption> uploadOptionList { get; private set; }
    public String uploadOption { get; set; }
    public Map<String, String> translations { get; private set; }
    public Container_Info__c dummyContainer { get; set; }
    private static Set<String> availableContainerSize;
    public String shipmentId { get; private set; }

    public DataLoadingController() {
        initialize();
    }

    public PageReference save() {
        PageReference returnPage = null;

        if (PermissionValidationUtil.isEditableHBL()) {
            try {
                if (dummyContainer.HBL_SHIPMENT__c != null) {
                    for (Container_Info__c containerInfo : containerInfoList) {
                        if (containerInfo.HBL_SHIPMENT__c == null) {
                            containerInfo.HBL_SHIPMENT__c = dummyContainer.HBL_SHIPMENT__c;
                        }
                    }
                }
				
                FlsService.doInsert(containerInfoList);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Container Info uploading was completed successfully'));
			
                if (!String.isEmpty(shipmentId)) {
                    returnPage = new PageReference('/' + shipmentId);
                    returnPage.setRedirect(true);
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to upload: ' + e.getMessage()));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient permissions. Please contact your System Administrator.'));
        }

        return returnPage;
    }

    public PageReference cancel() {
        PageReference returnPage = new PageReference('/' + shipmentId);
        returnPage.setRedirect(true);
        return returnPage;
    }

    public void loadData() {
        String fileContent = null;
        containerInfoList = new List<Container_Info__c>();

        try {
            fileContent = csvFileBody.toString();
        } catch (StringException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your file content has problem. Please remove all spaces'));
            return;
        }

        String[] lines = fileContent.split('\n');
        //Get headers from Line[0]
        String[] headers = normalize(lines[0]).split(',');
        List<String> finalHeaders = new List<String>();
        //Set final headers = toUppercase and trim()
        for(String header: headers) {
            header = header.trim().toUppercase();
            finalHeaders.add(header);
        }
        List<String> lstNameFields = new List<String>{'CONTAINER NUMBER', 'CONTAINER SIZE', 'GROSS WEIGHT', 'NET WEIGHT (KG)', 'CARGO TYPE UNIT', 'QUANTITY (PACKAGES)', 'MEASUREMENT (CBM)', 'SEAL NUMBER', 'VERIFIED GROSS WEIGHT (KG)', 'EMPTY/FULL'};
        Map<String, integer> mapFieldToIndex = new Map<String, integer>();
        //Set map for Field with index of uploaded file
        for(String fieldName: lstNameFields) {
            mapFieldToIndex.put(fieldName, finalHeaders.indexOf(fieldName));
        }
        for (Integer i = 1; i < lines.size(); i++) {
            String line = normalize(lines[i]);
            String[] tokens = line.split(',');
            Container_Info__c ci = new Container_Info__c();
            if (tokens != null && tokens.size() >= 1 && String.isNotBlank(tokens[0])) {
                ci.HBL_SHIPMENT__c = null;
                
                if(mapFieldToIndex.get('CONTAINER NUMBER') != -1) {
                    ci.Container_NO__c = tokens[mapFieldToIndex.get('CONTAINER NUMBER')];
                } else {
                    ci.Container_NO__c = null;
                }
                
                if(mapFieldToIndex.get('CONTAINER SIZE') != -1) {
                    ci.Container__c = determinContainerSize(tokens[mapFieldToIndex.get('CONTAINER SIZE')]);
                } else {
                    ci.Container__c = null;
                }
                
                if(mapFieldToIndex.get('GROSS WEIGHT') != -1 && !String.isBlank(tokens[mapFieldToIndex.get('GROSS WEIGHT')])) {
                    ci.GROSS_WEIGHT__c = Decimal.valueOf(tokens[mapFieldToIndex.get('GROSS WEIGHT')].trim());
                } else {
                    ci.GROSS_WEIGHT__c = null;
                }
                
                if(mapFieldToIndex.get('NET WEIGHT (KG)') != -1 && !String.isBlank(tokens[mapFieldToIndex.get('NET WEIGHT (KG)')])) {
                    ci.NET_WEIGHT__c = Decimal.valueOf(tokens[mapFieldToIndex.get('NET WEIGHT (KG)')].trim());
                } else {
                    ci.NET_WEIGHT__c = null;
                }
                
                if(mapFieldToIndex.get('CARGO TYPE UNIT') != -1 && !String.isBlank(tokens[mapFieldToIndex.get('CARGO TYPE UNIT')])) {
    
                    ci.CargoTypeUnit__c = tokens[mapFieldToIndex.get('CARGO TYPE UNIT')];
                } else {
                    ci.CargoTypeUnit__c = null;
                }

                if(mapFieldToIndex.get('QUANTITY (PACKAGES)') != -1 && !String.isBlank(tokens[mapFieldToIndex.get('QUANTITY (PACKAGES)')])) {
                    
                    ci.QUANTITY_PACKAGES__c = Decimal.valueOf(tokens[mapFieldToIndex.get('QUANTITY (PACKAGES)')].trim());
                } else {
                    ci.QUANTITY_PACKAGES__c = null;
                }
                
                if(mapFieldToIndex.get('MEASUREMENT (CBM)') != -1 && !String.isBlank(tokens[mapFieldToIndex.get('MEASUREMENT (CBM)')])) {
                    ci.MEASUREMENT_CBM__c = Decimal.valueOf(tokens[mapFieldToIndex.get('MEASUREMENT (CBM)')].trim());
                } else {
                    ci.MEASUREMENT_CBM__c = null;
                }
                
                if(mapFieldToIndex.get('SEAL NUMBER') != -1) {
                    ci.Seal_No__c = tokens[mapFieldToIndex.get('SEAL NUMBER')];
                } else {
                    ci.Seal_No__c = null;
                }

                if(mapFieldToIndex.get('VERIFIED GROSS WEIGHT (KG)') != -1 && !String.isBlank(tokens[mapFieldToIndex.get('VERIFIED GROSS WEIGHT (KG)')])) {
                    ci.Verified_Gross_Weight__c = Decimal.valueOf(tokens[mapFieldToIndex.get('VERIFIED GROSS WEIGHT (KG)')].trim());
                } else {
                    ci.Verified_Gross_Weight__c = null;
                }

                if(mapFieldToIndex.get('EMPTY/FULL') != -1) {
                    ci.Empty_Full_Container_Identification__c = tokens[mapFieldToIndex.get('EMPTY/FULL')];
                } else {
                    ci.Empty_Full_Container_Identification__c = null;
                }
                containerInfoList.add(ci);
            } else {
                break;
            }
        }
    }

    private String determinContainerSize(String origValue) {
        if (String.isNotBlank(origValue)) {
            if (availableContainerSize.contains(origValue)) {
                return origValue;
            }
			
            // if (origValue.contains('20')) {
            //     return '20\'DC';
            // } else if (origValue.contains('40')) {
            //     return '40\'DC';
            // }
        }

        return origValue;
    }

    private void initialize() {
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');

        dummyContainer = new Container_Info__c();
        if (!StringUtils.isEmpty(shipmentId)) {
            dummyContainer.HBL_SHIPMENT__c = shipmentId;
        }

        uploadOptionList = new List<SelectOption>();
        uploadOptionList.add(new SelectOption('ContainerInfo', 'CONTAINER'));

        TranslationService translationService = new TranslationService('MassiveUpdate', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    private String normalize(String value) {
        String result = '';
        Integer index = 0;

        while (true) {
            Integer firstIndex = value.indexOf('"', index);
            if (firstIndex > 0) {
                Integer secondIndex = value.indexOf('"', firstIndex + 1);

                if (secondIndex > 0) {
                    result += value.substring(index, firstIndex) + value.substring(firstIndex + 1, secondIndex - 1).replaceAll(',', '');
                    index = secondIndex + 1;
                } else {
                    break;
                }
            } else {
                result += value.substring(index);
                break;
            }
        }

        return result;
    }

    static {
        availableContainerSize = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Container_Info__c.Container__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : ple) {
            availableContainerSize.add(entry.getValue());
        }
    }
}