/**
 * VF page controller for the page to capture subcriber specific settings which are necessary for the app to function properly.
 * Subscriber specific settings are Company Name, Tel, Address, Logo URL.
 * These settings are stored in "Site Custom Setting" custom setting.
 */
public with sharing class PackSubscriberSettingsController {
    public Site_Custom_Settings__c settings { get; set; }
    public boolean allowedUpdateOperationEmailAlert { get; private set; }
    public boolean allowedUpdateReminderEmailAlert { get; private set; }
    public boolean allowedPopulateReportMappings { get; private set; }
    public String currentHost { get; private set; }
    public List<String> messages { get; private set; }

    public PackSubscriberSettingsController() {
        try {
            this.settings = Site_Custom_Settings__c.getOrgDefaults();
            /*
            settings = [
                    SELECT Company_Address__c, Local_Company_Address__c, Company_Fax__c, Company_Phone__c, Local_Currency__c, BillingDefaultCurrency__c, BL_Issued_Location__c, VAT_Background_Image__c,
                            Logo_URL__c, Website__c, Company_Name__c, Local_Company_Name__c, Company_Address_ZIP__c, Company_Country__c,
                            Company_Signature__c, Company_Email__c, Facebook__c, Ocean_HBL_No_Prefix__c, Air_HBL_No_Prefix__c, Local_Company_Address_ZIP__c,
                            Registration_No_Form__c, Registration_No_Serial__c, Tax_Code__c, Ferry_SLA__c, Container_Vessel_SLA__c, VAT_Running_Number__c,
                            Local_Account_Address_1__c, Local_Account_No_1__c, Local_Bank_1_Other__c, Local_Bank_Account_1__c, Local_Bank_Address_1__c, Local_Bank_Name_1__c,
                            Local_Account_Address_2__c, Local_Account_No_2__c, Local_Bank_2_Other__c, Local_Bank_Account_2__c, Local_Bank_Address_2__c, Local_Bank_Name_2__c,
                            Local_Account_Address_3__c, Local_Account_No_3__c, Local_Bank_3_Other__c, Local_Bank_Account_3__c, Local_Bank_Address_3__c, Local_Bank_Name_3__c,
                            Local_Account_Address_4__c, Local_Account_No_4__c, Local_Bank_4_Other__c, Local_Bank_Account_4__c, Local_Bank_Address_4__c, Local_Bank_Name_4__c,
                            Local_Account_Address_5__c, Local_Account_No_5__c, Local_Bank_5_Other__c, Local_Bank_Account_5__c, Local_Bank_Address_5__c, Local_Bank_Name_5__c,
                            Foreign_Account_Address_1__c, Foreign_Account_No_1__c, Foreign_Bank_1_Other__c, Foreign_Bank_Account_1__c, Foreign_Bank_Address_1__c, Foreign_Bank_Name_1__c,
                            Foreign_Account_Address_2__c, Foreign_Account_No_2__c, Foreign_Bank_2_Other__c, Foreign_Bank_Account_2__c, Foreign_Bank_Address_2__c, Foreign_Bank_Name_2__c,
                            AS_AGENT_FOR_CARRIER_1__c, AS_AGENT_FOR_CARRIER_2__c, My_Domain_Name__c,
                            EnableInvoiceTemplateSet1__c, EnableInvoiceTemplateSet2__c, EnableInvoiceTemplateSet3__c, EnableInvoiceTemplateSet4__c,
                            EnableInvoiceTemplateSet5__c, EnableInvoiceTemplateSet6__c, EnableInvoiceTemplateSet7__c, EnableInvoiceTemplateSet8__c,
                            EnableInvoiceTemplateSet9__c, EnableInvoiceTemplateSet10__c,EnableInvoiceTemplateSet11__c, EnableInvoiceTemplateSet12__c,
                            EnableInvoiceTemplateSet13__c, EnableInvoiceTemplateSet14__c, EnableInvoiceTemplateSet15__c,
                            InvoiceTemplateSet1Name__c, InvoiceTemplateSet2Name__c, InvoiceTemplateSet3Name__c, InvoiceTemplateSet4Name__c,
                            InvoiceTemplateSet5Name__c, InvoiceTemplateSet6Name__c, InvoiceTemplateSet7Name__c, InvoiceTemplateSet8Name__c,
                            InvoiceTemplateSet9Name__c, InvoiceTemplateSet10Name__c, InvoiceTemplateSet11Name__c, InvoiceTemplateSet12Name__c,
                            InvoiceTemplateSet13Name__c, InvoiceTemplateSet14Name__c, InvoiceTemplateSet15Name__c, CustomInvoiceExcelTemplate__c,
                            PayableViewName__c, ReceivableViewName__c, ExchangeRateViewName__c,
                            LogisticAssociationNumber__c, GPSSystem1URL__c, GPSSystem2URL__c, ExpensePayableViewName__c, Custom_Date_Format__c,
                            FileConverterURL__c,
                            ShortCompanyName__c,
                            DebitStartNumber__c,
                            //to set New Unit price calculation, Accounting Lock and client communication by kwon, 16th of sep, 2018
                            ClientCommunication__c, SwitchToNewUnitPriceCalculation__c, TurnOnAccountingClosingLock__c,

                            //to set CloWMS Receivable, Payable, Exchange Rate view by kwon, 18th of sep, 2018
                            CloWMSReceivableViewName__c, CloWMSPayableViewName__c, CloWMSExchangeRateViewName__c

                    FROM Site_Custom_Settings__c
                    LIMIT 1
            ];
            */
        } catch (Exception ex) {
            settings = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'ERROR: The required Site Custom Setting has not been populated yet. ' +
                            'Please contact your System Administrator.'));
        }

        currentHost = URL.getSalesforceBaseUrl().toExternalForm();
        if (!Test.IsRunningTest()) {
            try {
                String operationEmailAlert = Constants.NAMESPACE + 'AnkenMeisai__c.' + Constants.NAMESPACE + 'UNCOLLECTED_ADVANCE_CHARGE_REMINDER';
                allowedUpdateOperationEmailAlert = checkEmailAlert(operationEmailAlert);
            } catch (System.NullPointerException npe) {
                allowedUpdateOperationEmailAlert = true;
            } catch (System.CalloutException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'ERROR: Please make sure ' + currentHost + ' has been added to Remote Site Settings ' +
                                'to proceed update to Workflow Rules and Email Alerts.'));
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'ERROR: Unexpected error occured ' + ex.getMessage()));
            }

            try {
                String reminderEmailAlert = Constants.NAMESPACE + 'CustomObject1__c.' + Constants.NAMESPACE + 'Check_if_Arrival_notice_is_not_sent_1_day_before';
                allowedUpdateReminderEmailAlert = checkEmailAlert(reminderEmailAlert);
            } catch (System.NullPointerException npe) {
                allowedUpdateReminderEmailAlert = true;
            } catch (System.CalloutException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'ERROR: Please make sure ' + currentHost + ' has been added to Remote Site Settings ' +
                                'to proceed update to Workflow Rules and Email Alerts.'));
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'ERROR: Unexpected error occured ' + ex.getMessage()));
            }

            allowedPopulateReportMappings = hasNoReportMappings();
        }
    }

    public PageReference save() {
        try {
            String validationError = validate();
            if (!StringUtils.isEmpty(validationError)) {
                throw new InvalidDataException(validationError);
            }

			FlsService.doUpdate(settings);
            doUpdateMetadata(settings.Company_Address__c);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Settings has been updated successfully'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Failed to update settings. ERROR: ' + e.getMessage()));
        }

        return null;
    }

    @future
    private static void doUpdateMetadata(String companyAddress) {
        //Update Metadata for Company address
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
        metadataFieldValueMap.put('Address__c', companyAddress);
        CustomMetadataUtils.updateCustomMetadata('Site_Metadata_Types__mdt','Arrial_Notice', 'Arrial Notice',metadataFieldValueMap);
    }
    private String validate() {

        if ((settings.EnableInvoiceTemplateSet1__c == true && StringUtils.isEmpty(settings.InvoiceTemplateSet1Name__c))
                || (settings.EnableInvoiceTemplateSet2__c == true && StringUtils.isEmpty(settings.InvoiceTemplateSet2Name__c))
                || (settings.EnableInvoiceTemplateSet3__c == true && StringUtils.isEmpty(settings.InvoiceTemplateSet3Name__c))) {
            return 'Invoice Template name must be set for enabled template';
        }
        return null;
    }

    public PageReference updateOperationAlertRecipients() {
        PageReference pageRef = Page.AFRSettings;

        updateExRateApprovalAlert();
        updateExRateRejectionAlert();
        updateExRateSecondStepApprovalAlert();
        updateTaxRatioApprovalAlert();
        updateTaxRatioRejectionAlert();
        updateUncollectedAdvanceChargeReminder();

        updateOceanImPartnerDCLinkAlert();
        updateOceanImClientCCDocLinkAlert();
        updateOceanImClientDODocLinkAlert();
        updateOceanImportAlert();
        updateAirExClientBLDocLinkAlert();
        updateAirExClientCheckBLLinkAlert();
        updateAirExPartnerDCNoteLinkAlert();
        updateAirImClientCCDocLinkAlert();
        updateAirExClientSIDocLinkAlert();
        updateAirImPartnerDCNoteAlert();
        updateAirExClientFMDocLinkAlert();
        updateOceanExClientCCDocLinkAlert();
        updateAirExClientCCDocLinkAlert();
        updateOceanExClientBLLinkAlert();
        updateOceanExPartnerDBNoteLinkAlert();
        updateOceanExClientCheckBLLinkAlert();
        updateOceanExClientSILinkAlert();
        updateOceanExClientFMLinkAlert();
        updateYusyutuMailSousinAlert();
        updateYusyutuMailSousinDontSendAlert();
        updateYunyuMailPartnerSousinDontSendAlert();
        updateYusyutuMailPartnerSousinAlert();
        updateYusyutuMailPartnerSousinDontSendAlert();
        updateYunyuMailSousinAlert();
        updateYunyuMailSousinDontSendAlert();
        updateYunyuMailPartnerSousinAlert();
        updateMitumoriMailPartnerSousinDoNotSendAlert();
        updateMitumoriMailSousinAlert();
        updateMitumoriMailPartnerSousinAlert();
        updateAirImpMailPtnDontSendAlert();
        updateApprovalRejectedAlert();
        updateHOUSERegisterationAlert();
        updateAirExpMailPtnAlert();
        updateAirImpCustmMailDontSendAlert();
        updateAirImpMailPtnAlert();
        updateAirExpMailPtnDontSendAlert();
        updateAirImpCustmMailAlert();
        updateAirExpMainPartnerAlert();
        updateAirExpMainPartnerDontSendAlert();
        updateUncollectedChargeAlert();
        updateDomesticCustomerRegistAlert();
        updateNewOverseaPartnerRegistAlert();

        pageRef.setRedirect(true);

        return pageRef;
    }

    public PageReference updateReminderAlertRecipients() {
        PageReference pageRef = Page.AFRSettings;

        update1DayAheadETAAlert();
        updateBLCollectionAirAlert();
        updateBLCollectionCustomClearanceAlert();
        updateBLCollectionSeaAlert();
        updateStatusOutOfDateLCLHDSAlert();
        updateStatusOutOfDateLCLAlert();
        updateStatusOutOfDateFCLAlert();
        updateCompleteAirImportShipmentReminderAlert();
        updateCompleteAirExportShipmentReminderAlert();
        updateCompleteOceanImportShipmentReminderAlert();
        updateCompleteOceanExportShipmentReminderAlert();

        pageRef.setRedirect(true);

        return pageRef;
    }

    public PageReference reset() {
        PageReference pageRef = Page.AFRSettings;
        pageRef.setRedirect(true);

        return pageRef;
    }

    public PageReference populateReportMappings() {
        PageReference pageRef = Page.AFRSettings;
        pageRef.setRedirect(true);

        List<Report> reports = [
                SELECT Id, DeveloperName
                FROM Report
                WHERE DeveloperName IN ('Simular_H_BL_Search_Report',
                        'M_allocation_test',
                        'H_BL_Profit_Analysis',
                        'In_out_check',
                        'H_B_L_Duplication_Check_Report',
                        'MANKENREPORT_CUSTOM',
                        'M_CLP',
                        'PaymentDetailCheck',
                        'Unpaid_Receivable',
                        'BEST_BUYING_PRICE',
                        'BANK_BALANCE_RECEIVED_LOCAL',
                        'BANK_BALANCE_RECEIVED_USD',
                        'BANK_BALANCE_PAID_TO_VENDOR_LOCAL',
                        'BANK_BALANCE_PAID_TO_VENDOR_USD')
        ];
        if (!reports.isEmpty()) {
            Report_Mappings__c reportMappings = Report_Mappings__c.getOrgDefaults();

            for (Report report : reports) {
                if ('Simular_H_BL_Search_Report'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.HBL_Search_Report__c = report.Id;
                } else if ('M_allocation_test'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.MBL_Cost_Allocation_Detail__c = report.Id;
                } else if ('H_BL_Profit_Analysis'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.HBL_Profit_Analysis__c = report.Id;
                } else if ('In_out_check'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.HBL_Selling_Buying_Payment__c = report.Id;
                } else if ('H_B_L_Duplication_Check_Report'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.HBL_Duplication_Check__c = report.Id;
                } else if ('MANKENREPORT_CUSTOM'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.MBL_Profit_Analysis__c = report.Id;
                } else if ('M_CLP'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.MBL_Container_Load_Plan__c = report.Id;
                } else if ('PaymentDetailCheck'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.HBL_Buying_Detail__c = report.Id;
                } else if ('Unpaid_Receivable'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.Account_Unpaid_Receivable__c = report.Id;
                } else if ('BEST_BUYING_PRICE'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.Best_Pricing_for_Route__c = report.Id;
                } else if ('BANK_BALANCE_RECEIVED_LOCAL'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.REPORT_FOR_LOCAL_AMOUNT_RECEIVED__c = report.Id;
                } else if ('BANK_BALANCE_RECEIVED_USD'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.REPORT_FOR_USD_AMOUNT_RECEIVED__c = report.Id;
                } else if ('BANK_BALANCE_PAID_TO_VENDOR_LOCAL'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.REPORT_FOR_LOCAL_AMOUNT_PAID__c = report.Id;
                } else if ('BANK_BALANCE_PAID_TO_VENDOR_USD'.equalsIgnoreCase(report.DeveloperName)) {
                    reportMappings.REPORT_FOR_USD_AMOUNT_PAID__c = report.Id;
                }
            }

            FlsService.doUpsert(new Report_Mappings__c[] { reportMappings });
        }

        return pageRef;
    }

    public List<SelectOption> getCountries() {
        List<SelectOption> countries = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Port__c.Country_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : ple) {
            countries.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return countries;
    }

    public List<SelectOption> getCurrencies() {
        List<SelectOption> currencies = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = AnkenMeisai__c.curr__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : ple) {
            currencies.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return currencies;
    }

    public List<SelectOption> getDateFormats() {
        List<SelectOption> dateFormats = new List<SelectOption>();
        dateFormats.add(new SelectOption('dd/MM/yyyy', 'dd/MM/yyyy (i.e: 30/04/1975)'));
        dateFormats.add(new SelectOption('dd-MM-yyyy', 'dd-MM-yyyy (i.e: 30-04-1975)'));
        dateFormats.add(new SelectOption('d/MM/yy', 'd/MM/yy (i.e: 30/4/75)'));
        dateFormats.add(new SelectOption('d-MM-yy', 'd-MM-yy (i.e: 30-4-75)'));
        dateFormats.add(new SelectOption('MM/dd/yyyy', 'MM/dd/yyyy (i.e: 04/30/1975)'));
        dateFormats.add(new SelectOption('MM-dd-yyyy', 'MM-dd-yyyy (i.e: 04-30-1975)'));
        dateFormats.add(new SelectOption('M/d/yy', 'M/d/yy (i.e: 4/30/75)'));
        dateFormats.add(new SelectOption('M-d-yy', 'M-d-yy (i.e: 4-30-75)'));
        dateFormats.add(new SelectOption('d/MMM/yy', 'd/MMM/yy (i.e: 30/Apr/75)'));
        dateFormats.add(new SelectOption('d-MMM-yy', 'd-MMM-yy (i.e: 30-Apr-75)'));
        dateFormats.add(new SelectOption('MMMM dd, yyyy', 'MMMM dd, yyyy (i.e: April 30, 1975)'));

        return dateFormats;
    }



    private boolean checkEmailAlert(String checkedEmailAlert) {
        MetadataService.MetadataPort service = createService();

        MetadataService.WorkflowAlert wfa = (MetadataService.WorkflowAlert) service.readMetadata('WorkflowAlert',
                new String[]{
                        checkedEmailAlert
                }).getRecords()[0];
        MetadataService.WorkflowEmailRecipient[] recipients = wfa.recipients;

        for (MetadataService.WorkflowEmailRecipient recipient : recipients) {
            if ('role'.equalsIgnoreCase(recipient.type_x.trim())) {
                return false;
            }
        }

        return true;
    }

    private boolean hasNoReportMappings() {
        Report_Mappings__c reportMappings = Report_Mappings__c.getOrgDefaults();

        return (reportMappings.HBL_Search_Report__c == null);
    }

    /**
     * Setup Time-Dependent Workflow email alerts
     */
    private static final String RECIPIENT_TYPE_USER = 'user';
    private static final String RECIPIENT_TYPE_ACCOUNT_OWNER = 'accountOwner';
    private static final String RECIPIENT_TYPE_CONTACT_LOOKUP = 'contactLookup';
    private static final String RECIPIENT_TYPE_CREATOR = 'creator';
    private static final String RECIPIENT_TYPE_ROLE = 'role';

    private MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    private MetadataService.WorkflowEmailRecipient createEmailRecipient(String recipientType, String recipientValue) {
        MetadataService.WorkflowEmailRecipient recipient = new MetadataService.WorkflowEmailRecipient();
        recipient.type_x = recipientType;

        if (RECIPIENT_TYPE_USER.equalsIgnoreCase(recipientType)
                || RECIPIENT_TYPE_ROLE.equalsIgnoreCase(recipientType)) {
            recipient.recipient = recipientValue;
        } else if (RECIPIENT_TYPE_CONTACT_LOOKUP.equalsIgnoreCase(recipientType)) {
            recipient.field = recipientValue;
        }

        return recipient;
    }

    private void addAdditionalRecipientsWorkflowAlert(MetadataService.MetadataPort service, String objectType, String alertName,
            MetadataService.WorkflowEmailRecipient[] recipients,
            String[] additionalEmails) {
        objectType = Constants.NAMESPACE + objectType;
        alertName = Constants.NAMESPACE + alertName;

        if (service == null) {
            service = createService();
        }

        try {
            MetadataService.WorkflowAlert workflowAlert = (MetadataService.WorkflowAlert) service.readMetadata('WorkflowAlert',
                    new String[]{
                            objectType + '.' + alertName
                    }).getRecords()[0];

            if (additionalEmails != null && additionalEmails.size() > 0) {
                for (String e : additionalEmails) {
                    workflowAlert.ccEmails.add(e);
                }
            }

            if (recipients != null && recipients.size() > 0) {
                for (MetadataService.WorkflowEmailRecipient r : recipients) {
                    workflowAlert.recipients.add(r);
                }
            }

            MetadataService.Metadata[] metadata = new MetadataService.Metadata[]{
                    workflowAlert
            };
            List<MetadataService.SaveResult> results = service.updateMetadata(metadata);
            handleSaveResults(results);
        } catch (Exception ex) {
            // Catch this to support unit test
        }
    }

    private MetadataService.FilterItem createFilterItem(String objectType, String fieldName, String operation, String value) {
        objectType = Constants.NAMESPACE + objectType;
        fieldName = Constants.NAMESPACE + fieldName;
        MetadataService.FilterItem filter = new MetadataService.FilterItem();
        filter.field = objectType + '.' + fieldName;
        filter.operation = operation;
        filter.value = value;

        return filter;
    }

    private void handleSaveResults(MetadataService.SaveResult[] saveResults) {
        if (saveResults != null) {
            MetadataService.SaveResult saveResult = saveResults.get(0);
            if (saveResult.errors != null) {
                if (messages == null) {
                    messages = new List<String>();
                }

                for (MetadataService.Error error : saveResult.errors) {
                    if (!error.statusCode.contains('DUPLICATE')) {
                        messages.add(error.message + ' (' + error.statusCode + ').'
                                + (error.fields != null && error.fields.size() > 0 ? ' Fields ' + String.join(error.fields, ',') + '.' : ''));
                    }
                }
            }
        }
    }

    private void updateUncollectedAdvanceChargeReminder() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addSeaImportTeam(recipients);
        addAirImoprtTeam(recipients);
        addDomesticSalesTeam(recipients);
        addCustomClearanceTeam(recipients);

        addAdditionalRecipientsWorkflowAlert(null, 'AnkenMeisai__c', 'UNCOLLECTED_ADVANCE_CHARGE_REMINDER', recipients, null);
    }

    private void updateExRateSecondStepApprovalAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addSeaImportTeam(recipients);
        addAirImoprtTeam(recipients);
        addDomesticSalesTeam(recipients);
        addCustomClearanceTeam(recipients);
        addSeaExportTeam(recipients);
        addAirExportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addTruckingTeam(recipients);
        addDataEntryTeam(recipients);
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Top_Executive'));

        addAdditionalRecipientsWorkflowAlert(null, 'MgmtMaster__c', 'Exchange_Rate_Approval_Process_requested_2nd_step', recipients, null);
    }

    private void updateExRateApprovalAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addSeaImportTeam(recipients);
        addAirImoprtTeam(recipients);
        addDomesticSalesTeam(recipients);
        addCustomClearanceTeam(recipients);
        addSeaExportTeam(recipients);
        addAirExportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addTruckingTeam(recipients);
        addDataEntryTeam(recipients);
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Top_Executive'));

        addAdditionalRecipientsWorkflowAlert(null, 'MgmtMaster__c', 'Exchange_Rate_Approval_Process_requested', recipients, null);
    }

    private void updateExRateRejectionAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addSeaImportTeam(recipients);
        addAirImoprtTeam(recipients);
        addDomesticSalesTeam(recipients);
        addCustomClearanceTeam(recipients);
        addSeaExportTeam(recipients);
        addAirExportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addTruckingTeam(recipients);
        addDataEntryTeam(recipients);
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Top_Executive'));

        addAdditionalRecipientsWorkflowAlert(null, 'MgmtMaster__c', 'Exchange_Rate_process_Rejected', recipients, null);
    }

    private void updateTaxRatioRejectionAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'Tax_Ratio__c', 'Tax_Ratio_Activation_process_rejected', recipients, null);
    }

    private void updateTaxRatioApprovalAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addSeaImportTeam(recipients);
        addAirImoprtTeam(recipients);
        addDomesticSalesTeam(recipients);
        addCustomClearanceTeam(recipients);
        addSeaExportTeam(recipients);
        addAirExportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addTruckingTeam(recipients);
        addDataEntryTeam(recipients);
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Top_Executive'));

        addAdditionalRecipientsWorkflowAlert(null, 'Tax_Ratio__c', 'Tax_Ratio_Activation_process_requested', recipients, null);
    }

    private void updateNewOverseaPartnerRegistAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'Account', 'NEW_OVERSEA_PARTNER_REGIST_ALERT', recipients, null);
    }

    private void updateDomesticCustomerRegistAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'Account', 'NEW_DOMESTIC_CUSTOMER_REGIST_ALERT', recipients, null);
    }

    private void updateUncollectedChargeAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAccountingTeam(recipients);
        addDomesticSalesTeam(recipients);
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Top_Executive'));
        addAdditionalRecipientsWorkflowAlert(null, 'AnkenMeisai__c', 'UNCOLLECTED_CHARGE_REMINDER', recipients, null);
    }

    private void updateAirExpMainPartnerDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirExpMailPrtn_DO_NOT_SEND', recipients, null);
    }

    private void updateAirExpMainPartnerAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirExpMailPrtn', recipients, null);
    }

    private void updateAirImpCustmMailAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirImpCustmMail', recipients, null);
    }

    private void updateAirExpMailPtnDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirExpMailPtn_DO_NOT_SEND', recipients, null);
    }

    private void updateAirImpMailPtnAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirImpMailPtn', recipients, null);
    }

    private void updateAirImpCustmMailDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirImpCustmMail_DO_NOT_SEND', recipients, null);
    }

    private void updateAirExpMailPtnAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirExpMailPtn', recipients, null);
    }

    private void updateHOUSERegisterationAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'HOUSE', recipients, null);
    }

    private void updateApprovalRejectedAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addDataEntryTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Approval_has_been_Rejected', recipients, null);
    }

    private void updateAirImpMailPtnDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AirImpMailPtn_DO_NOT_SEND', recipients, null);
    }

    private void updateMitumoriMailPartnerSousinAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'MitumoriMailPartnerSousin', recipients, null);
    }

    private void updateMitumoriMailSousinAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addDomesticSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'MitumoriMailSousin', recipients, null);
    }

    private void updateMitumoriMailPartnerSousinDoNotSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addDomesticSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'MitumoriMailPartnerSousin_DoNotSend', recipients, null);
    }

    private void updateYunyuMailPartnerSousinAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YunyuMailPartnerSousin', recipients, null);
    }

    private void updateYunyuMailSousinDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YunyuMailSousin_DO_NOT_SEND', recipients, null);
    }

    private void updateYunyuMailSousinAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YunyuMailSousin', recipients, null);
    }

    private void updateYusyutuMailPartnerSousinDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YusyutuMailPartnerSousin_DO_NOT_SEND', recipients, null);
    }

    private void updateYusyutuMailPartnerSousinAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YusyutuMailPartnerSousin', recipients, null);
    }

    private void updateYunyuMailPartnerSousinDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YunyuMailPartnerSousin_DO_NOT_SEND', recipients, null);
    }

    private void updateYusyutuMailSousinDontSendAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YusyutuMailSousin_DO_NOT_SEND', recipients, null);
    }

    private void updateYusyutuMailSousinAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'YusyutuMailSousin', recipients, null);
    }

    private void updateOceanExClientFMLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_EXPORT_CLIENT_HTML_FM_LINK', recipients, null);
    }

    private void updateOceanExClientSILinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_EXPORT_CLIENT_HTML_SI_LINK', recipients, null);
    }

    private void updateOceanExClientCheckBLLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_EXPORT_CLIENT_HTML_Check_B_L_LINK', recipients, null);
    }

    private void updateOceanExPartnerDBNoteLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_EXPORT_PARTNER_HTML_Debit_Credit_Note_Link', recipients, null);
    }

    private void updateOceanExClientBLLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_EXPORT_CLIENT_HTML_B_L_LINK', recipients, null);
    }

    private void updateAirExClientCCDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addCustomClearanceTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_EXPORT_CLIENT_HTML_CC_Doc_Link', recipients, null);
    }

    private void updateOceanExClientCCDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addCustomClearanceTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_EXPORT_CLIENT_HTML_CC_DOC_LINK', recipients, null);
    }

    private void updateAirExClientFMDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_EXPORT_CLIENT_HTML_Freight_Memo_Doc_Link', recipients, null);
    }

    private void updateAirImPartnerDCNoteAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_IMPORT_PARTNER_HTML_Debit_Credit_Note', recipients, null);
    }

    private void updateAirExClientSIDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_EXPORT_CLIENT_HTML_SI_Doc_Link', recipients, null);
    }

    private void updateAirImClientCCDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addCustomClearanceTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_IMPORT_CLIENT_HTML_CC_Doc_LInk', recipients, null);
    }

    private void updateAirExPartnerDCNoteLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_EXPORT_PARTNER_HTML_Debit_Credit_Note_Link', recipients, null);
    }

    private void updateAirExClientCheckBLLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_EXPORT_CLIENT_HTML_Check_B_L_Doc_Link', recipients, null);
    }

    private void updateAirExClientBLDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'AIR_EXPORT_CLIENT_HTML_B_L_Doc_Link', recipients, null);
    }

    private void updateOceanImportAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Ocean_Import', recipients, null);
    }

    private void updateOceanImClientDODocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_IMPORT_CLIENT_D_O_DOC_LINK', recipients, null);
    }

    private void updateOceanImClientCCDocLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addCustomClearanceTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_IMPORT_CLIENT_CC_DOC_LINK', recipients, null);
    }

    private void updateOceanImPartnerDCLinkAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addOverseaSalesTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'OCEAN_IMPORT_PARTNER_HTML_Debit_Credit_Link', recipients, null);
    }

    private void update1DayAheadETAAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addSeaImportTeam(recipients);
        addDataEntryTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Check_if_Arrival_notice_is_not_sent_1_day_before', recipients, null);
    }

    private void updateBLCollectionAirAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Original_BL_Collection_Alert_AIR_After_1_week_of_ETA', recipients, null);
    }

    private void updateBLCollectionCustomClearanceAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addCustomClearanceTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Original_BL_Collection_Alert_CUSTOM_CLEARANCE_After_1_week_of_ETA', recipients, null);
    }

    private void updateBLCollectionSeaAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Original_BL_Collection_Alert_SEA_After_1_week_of_ETA', recipients, null);
    }

    private void updateStatusOutOfDateLCLHDSAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Reminding_operation_to_check_if_Arrival_notice_is_sent_successfully_or_not_HSD', recipients, null);
    }

    private void updateStatusOutOfDateLCLAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Reminding_operation_to_check_if_Arrival_notice_is_sent_successfully_or_not_FCL', recipients, null);
    }

    private void updateStatusOutOfDateFCLAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'Reminding_operation_to_check_if_Arrival_notice_is_sent_successfully_or_not_LCL', recipients, null);
    }

    private void updateCompleteAirImportShipmentReminderAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirImoprtTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'COMPLETE_AIR_IMPORT_HBL_SHIPMENT_REMINDER', recipients, null);
    }

    private void updateCompleteAirExportShipmentReminderAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addAirExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'COMPLETE_AIR_EXPORT_HBL_SHIPMENT_REMINDER', recipients, null);
    }

    private void updateCompleteOceanImportShipmentReminderAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaImportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'COMPLETE_OCEAN_IMPORT_HBL_SHIPMENT_REMINDER', recipients, null);
    }

    private void updateCompleteOceanExportShipmentReminderAlert() {
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{
        };
        addSeaExportTeam(recipients);
        addAdditionalRecipientsWorkflowAlert(null, 'CustomObject1__c', 'COMPLETE_OCEAN_EXPORT_HBL_SHIPMENT_REMINDER', recipients, null);
    }

    private void addAccountingTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Accounting_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Accounting_Staff'));
    }

    private void addSeaImportTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Import_Operation_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Import_Operation_Staff'));
    }

    private void addSeaExportTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Export_Operation_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Export_Operation_Staff'));
    }

    private void addAirImoprtTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Air_Import_Operation_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Air_Import_Operation_Staff'));
    }

    private void addAirExportTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Air_Export_Operation_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Air_Export_Operation_Staff'));
    }

    private void addCustomClearanceTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Custom_Clearance_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Custom_Clearance_Staff'));
    }

    private void addOverseaSalesTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Oversea_Sales_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Oversea_Sales_Staff'));
    }

    private void addDomesticSalesTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Domestic_Sales_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Domestic_Sales_Staff'));
    }

    private void addTruckingTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Trucking_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Trucking_Operation_Staff'));
    }

    private void addDataEntryTeam(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Data_Entry_Staff'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Data_Entry_Manager'));
    }

    private void addTopExecutive(MetadataService.WorkflowEmailRecipient[] recipients) {
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Top_Executive'));
    }

    /*
    private static final String WF_TRIGGER_TIME_UNIT_DAY = 'Days';
    private static final String WF_TRIGGER_TIME_UNIT_HOUR = 'Hours';
    private static final String WF_TRIGGER_ACTION_ALERT = 'Alert';
    private static final String FILTER_OPERATION_EQUALS = 'equals';
    private static final String FILTER_OPERATION_NOT_EQUALS = 'notEqual';
    private static final String WF_TRIGGER_EVENT_CREATE_OR_EDIT = 'onCreateOrTriggeringUpdate';
    private static final String WF_TRIGGER_EVENT_CREATE = 'onCreateOnly';
    private static final String WF_TRIGGER_EVENT_ALL = 'onAllChanges';

    public PageReference createWorkflowRules() {
        PageReference pageRef =Page.AFRSettings;
        messages = new List<String>();

        create1DayBeforeETAAlert();

        if (messages.isEmpty()) {
            pageRef.setRedirect(true);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to update settings. \nERROR: ' + messages));
        }

        return pageRef;
    }

    private void create1DayBeforeETAAlert() {
        String templateFolder = 'Alert_Email';
        String emailTemplate = 'oneDay_Ahead_of_ETA';
        String workflowRuleName = '1 day before ETA if Status is not updated';
        String emailAlert = 'Check_if_Arrival_notice_is_not_sent_1_day_before';
        MetadataService.WorkflowEmailRecipient[] recipients = new MetadataService.WorkflowEmailRecipient[]{};
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Export_Operation_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Export_Operation_Staff'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Import_Operation_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Sea_Import_Operation_Staff'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Data_Entry_Manager'));
        recipients.add(createEmailRecipient(RECIPIENT_TYPE_ROLE, 'Data_Entry_Staff'));

        createWorkflowAlert(null, 'CustomObject1__c', emailAlert,
                            templateFolder + '/' + emailTemplate, recipients, null);

        MetadataService.FilterItem[] criteriaItems = new MetadataService.FilterItem[]{};
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Custom__c', FILTER_OPERATION_EQUALS, '×(No)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'CarrierType__c', FILTER_OPERATION_EQUALS, '海上(SEA)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 A/N情報登録済み(A/N Data Registered)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 本船/フライト到着済(Arrived)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 トランジット本船/フライト出発済(Transit Departured)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 本船/フライト遅延(Delayed)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 本船/フライト運行中(On Voyage)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 本船/フライト出発済(Departured)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 ブッキング情報変更(Booking Info Changed)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 ブッキング情報入手(Booking Info Received)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 SWITCH B/L情報登録済み(Switch B/L Data Registered)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 SWITCH B/L情報待ち(Waiting for Switch B/L Data)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 B/L情報登録済み(B/L Data Registered)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 AFRデータファイリング済み(AFR Data Filed)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 Pre-Alertデータ入力済み(Pre-Alert Data Registered)'));
        criteriaItems.add(createFilterItem('CustomObject1__c', 'Status__c', FILTER_OPERATION_EQUALS, '輸入 出荷情報入手(Cargo Info Received)'));

        String booleanFilter = '1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14 OR 15 OR 16)';

        createTimeDependentWorkflowRule(null, 'CustomObject1__c', workflowRuleName, 'ETA__c', -1,
                                        WF_TRIGGER_TIME_UNIT_DAY, WF_TRIGGER_EVENT_CREATE_OR_EDIT,
                                        emailAlert, WF_TRIGGER_ACTION_ALERT, criteriaItems, booleanFilter);

    }

    private void createTimeDependentWorkflowRule(MetadataService.MetadataPort service, String objectType, String ruleName,
                                                 String dependentField, Integer timeLength, String timeUnit,
                                                 String triggerEvent, String actionName, String actionType,
                                                 MetadataService.FilterItem[] filterItems, String booleanFilter) {
        objectType = Constants.NAMESPACE + objectType;
        ruleName = Constants.NAMESPACE + ruleName;
        dependentField = Constants.NAMESPACE + dependentField;

        if (service == null) {
            service = createService();
        }

        MetadataService.WorkflowActionReference workflowActionReference = new MetadataService.WorkflowActionReference();
        MetadataService.WorkflowRule workflowRule = new MetadataService.WorkflowRule();
        MetadataService.WorkflowTimeTrigger workflowTimeTrigger = new MetadataService.WorkflowTimeTrigger();

        workflowActionReference.name = actionName;
        workflowActionReference.type_x = actionType;

        workflowTimeTrigger.offsetFromField = objectType + '.' + dependentField;
        workflowTimeTrigger.timeLength = String.valueOf(timeLength);
        workflowTimeTrigger.workflowTimeTriggerUnit = timeUnit;
        workflowTimeTrigger.actions = new MetadataService.WorkflowActionReference[]{workflowActionReference};

        workflowRule.fullName = objectType + '.' + ruleName;
        workflowRule.active = false;
        workflowRule.description = ruleName;
        workflowRule.criteriaItems = filterItems;
        workflowRule.booleanFilter = (StringUtils.isEmpty(booleanFilter) ? null : booleanFilter);
        workflowRule.triggerType = triggerEvent;
        workflowRule.workflowTimeTriggers = new MetadataService.WorkflowTimeTrigger[]{workflowTimeTrigger};

        MetadataService.Metadata[] metadata = new MetadataService.Metadata[]{workflowRule};
        List<MetadataService.SaveResult> results = service.createMetadata(metadata);
        handleSaveResults(results);
    }

    private void createWorkflowAlert(MetadataService.MetadataPort service, String objectType, String alertName,
                                     String emailTemplate, MetadataService.WorkflowEmailRecipient[] recipients,
                                     String[] additionalEmails) {
        objectType = Constants.NAMESPACE + objectType;
        alertName = Constants.NAMESPACE + alertName;

        if (service == null) {
            service = createService();
        }

        MetadataService.WorkflowAlert workflowAlert = new MetadataService.WorkflowAlert();
        workflowAlert.senderType = 'DefaultWorkflowUser';
        workflowAlert.description = alertName;
        workflowAlert.protected_x = false;
        workflowAlert.fullName = objectType + '.' + alertName;
        workflowAlert.template = emailTemplate;

        if (additionalEmails != null && additionalEmails.size() > 0) {
            workflowAlert.ccEmails = additionalEmails;
        }

        if (recipients != null && recipients.size() > 0) {
            workflowAlert.recipients = recipients;
        }

        MetadataService.Metadata[] metadata = new MetadataService.Metadata[]{workflowAlert};
        List<MetadataService.SaveResult> results = service.createMetadata(metadata);
        handleSaveResults(results);
    }
*/
}