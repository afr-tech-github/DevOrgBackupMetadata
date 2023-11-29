public with sharing class NavigationFlowController {
    public Map<String, String> translations { get; private set; }
    public List<WorkProgressItemWrapper> initialSettings { get; private set; }
    public List<WorkProgressItemWrapper> referenceData { get; private set; }
    public List<WorkProgressItemWrapper> quotation { get; private set; }
    public List<WorkProgressItemWrapper> forwarding { get; private set; }
    public List<WorkProgressItemWrapper> trucking { get; private set; }
    public List<WorkProgressItemWrapper> accounting { get; private set; }
    public List<WorkProgressItemWrapper> managementProcess { get; private set; }
    public List<WorkProgressItemWrapper> governance { get; private set; }
    public List<WorkProgressItemWrapper> consolidation { get; private set; }
    public List<WorkProgressItemWrapper> expenses { get; private set; }
    public List<WorkProgressItemWrapper> clofil { get; private set; }
    public List<WorkProgressItemWrapper> cloApps { get; private set; }
    public List<WorkProgressItemWrapper> managementOperations { get; private set; }
    public List<WorkProgressItemWrapper> mySetup { get; private set; }
    public List<WorkProgressItemWrapper> pcSetup { get; private set; }
    public List<WorkProgressItemWrapper> tutorial { get; private set; }
    public List<WorkProgressItemWrapper> serviceAndContracts { get; private set; }
    public List<WorkProgressItemWrapper> logisticManagement { get; private set; }
    public List<WorkProgressItemWrapper> consultingServices { get; private set; }
    public List<WorkProgressItemWrapper> chatting { get; private set; }
    public List<WorkProgressItemWrapper> financialReports { get; private set; }
    public List<WorkProgressItemWrapper> cloHRM { get; private set; }

    public NavigationFlowController() {
        initializeTranslation();

        setUpInitialSettings();
        setUpReferenceData();
        setUpQuotation();
        setUpForwarding();
        setUpAccounting();
        setUpTrucking();
        setUpManagementProcess();
        setUpGovernances();
        setUpConsolidation();
        setUpExpenses();
        setUpCloFil();
        setUpCloApps();
        setUpManagementOperation();
        setUpMySetup();
        setUpTutorial();
        setUpPCSetup();
        setUpServiceAndContracts();
        setUpLogisticManagement();
        setUpConsultingServices();
        setUpChatting();
        setUpFinancialReports();
        setUpCloHRM();
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('NavigationFlow', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }

    ///////////////////////
    // Next NF: 152
    // Next NF PRB: 23
    //////////////////////

    private void setUpCloHRM() {
        Report_Mappings__c reportMappings = Report_Mappings__c.getOrgDefaults();
        cloHRM = new List<WorkProgressItemWrapper>();
        cloHRM.add(new WorkProgressItemWrapper('hr_standard', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'HRStandard__c'), translations.get('NF_122'), '/CloHRM/HR_Standard.jpeg', getNewRecordUrl(Constants.NAMESPACE + 'HRStandard__c', null)));
        cloHRM.add(new WorkProgressItemWrapper('employee_management', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Employee__c'), translations.get('NF_123'), '/CloHRM/Emp_Management.png', getNewRecordUrl(Constants.NAMESPACE + 'Employee__c', null)));
        cloHRM.add(new WorkProgressItemWrapper('payroll_order', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'PayrollOrder__c'), translations.get('NF_124'), '/CloHRM/Payroll_Order.png', getNewRecordUrl(Constants.NAMESPACE + 'PayrollOrder__c', null)));
        cloHRM.add(new WorkProgressItemWrapper('payroll_slip', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'PayrollSlip__c'), translations.get('NF_125'), '/CloHRM/Payroll_Slip.jpeg', getNewRecordUrl(Constants.NAMESPACE + 'PayrollSlip__c', null)));
        cloHRM.add(new WorkProgressItemWrapper('hsu_insurance', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'HSUInsurance__c'), translations.get('NF_126'), '/CloHRM/HSU_Insurance.png', getNewRecordUrl(Constants.NAMESPACE + 'HSUInsurance__c', null)));
        cloHRM.add(new WorkProgressItemWrapper('personal_income_tax', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'PersonalIncomeTax__c'), translations.get('NF_127'), '/CloHRM/PIT.jpeg', getNewRecordUrl(Constants.NAMESPACE + 'PersonalIncomeTax__c', null)));
    }

    private void setUpFinancialReports() {
        Report_Mappings__c reportMappings = Report_Mappings__c.getOrgDefaults();
        financialReports = new List<WorkProgressItemWrapper>();
        financialReports.add(new WorkProgressItemWrapper('profit_loss_sheet', Constants.WORK_PROGRESS_INCOMPLETE, '/' + reportMappings.ProfitLossSheet__c, translations.get('NF_113'), '/Reports/Profit_Loss_Sheet.png', null));
        financialReports.add(new WorkProgressItemWrapper('cash_flow_statement', Constants.WORK_PROGRESS_INCOMPLETE, '/' + reportMappings.CashFlowSheet__c, translations.get('NF_115'), '/Reports/Cash_Flow.png', null));
    }

    private void setUpChatting() {
        chatting = new List<WorkProgressItemWrapper>();
        chatting.add(new WorkProgressItemWrapper('chatter', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/core/chatter/ui/ChatterPage', translations.get('NF_17_8'), '/Tools/Chatter.png', null));
        chatting.add(new WorkProgressItemWrapper('people', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/core/chatter/people/PeopleListPage', translations.get('NF_116'), '/Tools/People.jpg', null));
        chatting.add(new WorkProgressItemWrapper('group', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/core/chatter/groups/GroupListPage', translations.get('NF_117'), '/Tools/Group.jpg', null));
        chatting.add(new WorkProgressItemWrapper('file_97', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/core/chatter/files/FileTabPage', translations.get('NF_97'), '/Tools/File.png', null));
    }

    private void setUpConsultingServices() {
        consultingServices = new List<WorkProgressItemWrapper>();
        consultingServices.add(new WorkProgressItemWrapper('backup_continuity_plan_94', Constants.WORK_PROGRESS_INCOMPLETE, 'http://www.dropbox.com/sh/xf20xvcisslmykp/AABUmfrEUXRZ7UKzgeU4jrcBa?dl=0', translations.get('NF_94'), '/Consulting/Business_Continuity.png', getNewRecordUrl(Constants.NAMESPACE + 'Custom_Clearance__c', null)));
    }

    private void setUpLogisticManagement() {
        logisticManagement = new List<WorkProgressItemWrapper>();
        /*
         * Add Custom Clearance
         */
        WorkProgressItemWrapper customClearance = new WorkProgressItemWrapper('custom_clearance', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Custom_Clearance__c'), translations.get('NF_14_9'), '/Forwarding/customs_clearance.jpg', getNewRecordUrl(Constants.NAMESPACE + 'Custom_Clearance__c', null));
        customClearance.hasSubFlow = true;
        customClearance.subFlowItems.addAll(setupCustomClearanceOptions());
        logisticManagement.add(customClearance);

        /*
         * Add Cargo Delivery
         */
        WorkProgressItemWrapper cargoDelivery = new WorkProgressItemWrapper('delivery', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Cargo_Delivery__c'), translations.get('NF_14_10'), '/Forwarding/delivery.jpg', getNewRecordUrl(Constants.NAMESPACE + 'Cargo_Delivery__c', null));
        cargoDelivery.hasSubFlow = true;
        cargoDelivery.subFlowItems.addAll(setupCargoDeliveryOptions());
        logisticManagement.add(cargoDelivery);
    }

    private List<WorkProgressItemWrapper> setupCustomClearanceOptions() {
        List<WorkProgressItemWrapper> ffSubFlowItems = new List<WorkProgressItemWrapper>();
        ffSubFlowItems.add(setUpOptionPerRecordType('cc_ocean_import', Constants.CC_OCEAN_IMPORT_RT, translations.get('NF_99'), Custom_Clearance__c.SObjectType, Constants.NAMESPACE + 'Custom_Clearance__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cc_ocean_export', Constants.CC_OCEAN_EXPORT_RT, translations.get('NF_100'), Custom_Clearance__c.SObjectType, Constants.NAMESPACE + 'Custom_Clearance__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cc_air_import', Constants.CC_AIR_IMPORT_RT, translations.get('NF_101'), Custom_Clearance__c.SObjectType, Constants.NAMESPACE + 'Custom_Clearance__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cc_air_export', Constants.CC_AIR_EXPORT_RT, translations.get('NF_14_4'), Custom_Clearance__c.SObjectType, Constants.NAMESPACE + 'Custom_Clearance__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cc_inland_import', Constants.CC_INLAND_IMPORT_RT, translations.get('NF_102'), Custom_Clearance__c.SObjectType, Constants.NAMESPACE + 'Custom_Clearance__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cc_inland_export', Constants.CC_INLAND_EXPORT_RT, translations.get('NF_120'), Custom_Clearance__c.SObjectType, Constants.NAMESPACE + 'Custom_Clearance__c'));
        return ffSubFlowItems;
    }

    private List<WorkProgressItemWrapper> setupCargoDeliveryOptions() {
        List<WorkProgressItemWrapper> ffSubFlowItems = new List<WorkProgressItemWrapper>();
        ffSubFlowItems.add(setUpOptionPerRecordType('cd_chatter_truck_im', Constants.CD_CHATTER_TRUCK_IMPORT_RT, translations.get('NF_103'), Cargo_Delivery__c.SObjectType, Constants.NAMESPACE + 'Cargo_Delivery__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cd_chatter_truck_ex', Constants.CD_CHATTER_TRUCK_EXPORT_RT, translations.get('NF_104'), Cargo_Delivery__c.SObjectType, Constants.NAMESPACE + 'Cargo_Delivery__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cd_consol_truck_im', Constants.CD_CONSOL_TRUCK_IMPORT_RT, translations.get('NF_105'), Cargo_Delivery__c.SObjectType, Constants.NAMESPACE + 'Cargo_Delivery__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cd_consol_ex', Constants.CD_CONSOL_TRUCK_EXPORT_RT, translations.get('NF_106'), Cargo_Delivery__c.SObjectType, Constants.NAMESPACE + 'Cargo_Delivery__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cd_drayage_im', Constants.CD_DRAYAGE_IMPORT_RT, translations.get('NF_107'), Cargo_Delivery__c.SObjectType, Constants.NAMESPACE + 'Cargo_Delivery__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cd_drayage_ex', Constants.CD_DRAYAGE_EXPORT_RT, translations.get('NF_108'), Cargo_Delivery__c.SObjectType, Constants.NAMESPACE + 'Cargo_Delivery__c'));
        return ffSubFlowItems;
    }


    private void setUpServiceAndContracts() {
        serviceAndContracts = new List<WorkProgressItemWrapper>();
        serviceAndContracts.add(new WorkProgressItemWrapper('price_list_95', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/n27r0y9eicpf1rf/AAAlep7Jlq0d7ZeZRrLpY0tKa?dl=0', translations.get('NF_95'), '/Services/List_Price.jpg', null));
        serviceAndContracts.add(new WorkProgressItemWrapper('special_offer_96', Constants.WORK_PROGRESS_INCOMPLETE, 'http://www.dropbox.com/sh/zz5cqkykwqo9a4b/AADmxK_weidlO8POVvZIPhTSa?dl=0', translations.get('NF_96'), '/Services/Special_Offer.png', null));
        serviceAndContracts.add(new WorkProgressItemWrapper('master_subscription', Constants.WORK_PROGRESS_INCOMPLETE, 'https://afrs-developer-edition.ap2.force.com/afr/s/CloFor_Master_Subscription_Agreement.pdf?v=1?lang=en', translations.get('NF_1_1'), '/Services/Master_Subscription.png', null));
        serviceAndContracts.add(new WorkProgressItemWrapper('sfdc_service', Constants.WORK_PROGRESS_INCOMPLETE, 'https://afrs-developer-edition.ap2.force.com/afr/s/SFDC_Service_Agreement.pdf?v=1?lang=en', translations.get('NF_1_2'), '/Services/SFDC_Service.png', null));
    }

    private void setUpTutorial() {
        tutorial = new List<WorkProgressItemWrapper>();
        tutorial.add(new WorkProgressItemWrapper('new_release', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/awwk0qu4mu3q7o8/AAAIfM5uUjYVTFykpcupzkV1a?dl=0', translations.get('NF_2_1'), '/Tutorial/New_Release.png', null));
        tutorial.add(new WorkProgressItemWrapper('process_schema', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/navi0138axyyoxg/AABFm4nbBjuRUDCW4wuq3Gema?dl=0', translations.get('NF_98'), '/Tutorial/Process_Schema.png', null));
        tutorial.add(new WorkProgressItemWrapper('sop', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'SOP__c'), translations.get('NF_114'), '/Tutorial/SOP.jpg', null));
        tutorial.add(new WorkProgressItemWrapper('user_manual', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/1jxzif6vbocvj94/AABosHaCDMZfmetYK5Ulw6jka?dl=0', translations.get('NF_2_2'), '/Tutorial/user_manual.png', null));
        tutorial.add(new WorkProgressItemWrapper('video_manual', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.youtube.com/channel/UC3q08W0yiKF_f8N0SaszBQA', translations.get('NF_2_3'), '/Tutorial/video_manual.png', null));
        tutorial.add(new WorkProgressItemWrapper('peronal_online_training', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/yhmj6gjs56zfy1u/AACvKmWLxgQ6rLL3Vv0nHIMLa?dl=0', translations.get('NF_111'), '/Tutorial/personal_online_training.jpeg', null));
        tutorial.add(new WorkProgressItemWrapper('scenario', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/wv8b6f3xzj3ssmu/AABK_2KWiPb-LER_r01z4onCa?dl=0', translations.get('NF_2_4'), '/Tutorial/Learning_Scenarios.gif', null));
        tutorial.add(new WorkProgressItemWrapper('ideas', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/x6x6j0kemf19yya/AABBPaEc0pE-jhHisbmiyXtUa?dl=0', translations.get('NF_2_5'), '/Tutorial/Ideas.png', null));
    }

    private void setUpPCSetup() {
        pcSetup = new List<WorkProgressItemWrapper>();
        pcSetup.add(new WorkProgressItemWrapper('khmer_font', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/ect54aa036x98hk/AAAMoLWDStWMcybKIPPkfz7Qa?dl=0', translations.get('NF_3_1'), null, null));
        pcSetup.add(new WorkProgressItemWrapper('vietnamese_font', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/ldzbr5ytsr1gvcq/AAA10W4O-xDoATBJPug0i30Pa?dl=0', translations.get('NF_3_2'), null, null));
        pcSetup.add(new WorkProgressItemWrapper('data_upload_template', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/xh60o6ao4awf5da/AACX6ApOUt5Ks3XkrTm5nvBka?dl=0', translations.get('NF_3_3'), null, null));
        pcSetup.add(new WorkProgressItemWrapper('workbench', Constants.WORK_PROGRESS_INCOMPLETE, 'https://workbench.developerforce.com/login.php', 'Workbench', null, null));
    }

    private void setUpMySetup() {
        mySetup = new List<WorkProgressItemWrapper>();
        mySetup.add(new WorkProgressItemWrapper('personal_information', Constants.WORK_PROGRESS_INCOMPLETE, '/' + getUserId() + '?noredirect=1&isUserEntityOverride=1&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalInfo&setupid=PersonalInformation', translations.get('NF_4_1'), null, null));
        mySetup.add(new WorkProgressItemWrapper('language_timezone_93', Constants.WORK_PROGRESS_INCOMPLETE, '/setup/languageAndTimeZoneSetup.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalInfo&setupid=LanguageAndTimeZone', translations.get('NF_93'), null, null));
        mySetup.add(new WorkProgressItemWrapper('reset_password', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/system/security/ChangePassword?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalInfo&setupid=ChangePassword', translations.get('NF_4_2'), null, null));
        mySetup.add(new WorkProgressItemWrapper('grant_access', Constants.WORK_PROGRESS_INCOMPLETE, '/partnerbt/grantLoginAccess.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalInfo&setupid=GrantLoginAccess', translations.get('NF_132'), null, null));
        mySetup.add(new WorkProgressItemWrapper('tab', Constants.WORK_PROGRESS_INCOMPLETE, '/p/setup/layout/ConfigureMyTabs?retURL=%2Fui%2Fsetup%2Fuser%2FCustomizeMyDisplayPage%3Fsetupid%3DCustomizeDisplay%26retURL%3D%252Fui%252Fsetup%252FSetup%253Fsetupid%253DPersonalInfo&setupid=CustomizeTabs', translations.get('NF_4_3'), null, null));
        mySetup.add(new WorkProgressItemWrapper('home', Constants.WORK_PROGRESS_INCOMPLETE, '/setup/ui/customizeyourhomepage.jsp?retURL=%2Fui%2Fsetup%2Fuser%2FCustomizeMyDisplayPage%3Fsetupid%3DCustomizeDisplay%26retURL%3D%252Fui%252Fsetup%252FSetup%253Fsetupid%253DPersonalInfo', translations.get('NF_4_4'), null, null));
        mySetup.add(new WorkProgressItemWrapper('email', Constants.WORK_PROGRESS_INCOMPLETE, '/p/email/UserEmailPrefEdit?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DEmailSetup&setupid=EmailSettings', translations.get('NF_4_5'), null, null));
        mySetup.add(new WorkProgressItemWrapper('holiday', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/core/feeds/notification/FeedsNotificationPrefEdit?setupid=CollaborationEmailSettings&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalCollaboration', translations.get('NF_4_6'), null, null));
        mySetup.add(new WorkProgressItemWrapper('personal_email_template', Constants.WORK_PROGRESS_INCOMPLETE, '/00X?setupid=EmailTemplates&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DEmailSetup', translations.get('NF_4_7'), null, null));
        mySetup.add(new WorkProgressItemWrapper('chatter_feeds', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/core/chatter/ui/MyFeedsSettingsPage?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DPersonalCollaboration&setupid=CollaborationMyFeedsSettings', translations.get('NF_4_8'), null, null));
        mySetup.add(new WorkProgressItemWrapper('email_to_clofor', Constants.WORK_PROGRESS_INCOMPLETE, '/email-admin/services/emailToSalesforceUserEdit.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DEmailSetup&setupid=EmailToSalesforceUserSetup', translations.get('NF_4_9'), null, null));
    }

    private void setUpManagementOperation() {
        managementOperations = new List<WorkProgressItemWrapper>();
        managementOperations.add(new WorkProgressItemWrapper('users', Constants.WORK_PROGRESS_INCOMPLETE, '/005?isUserEntityOverride=1&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DUsers&setupid=ManageUsers', translations.get('NF_5_1'), null, null));
        managementOperations.add(new WorkProgressItemWrapper('profiles', Constants.WORK_PROGRESS_INCOMPLETE, '/00e?setupid=EnhancedProfiles&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DUsers', translations.get('NF_5_2'), null, null));
        managementOperations.add(new WorkProgressItemWrapper('roles', Constants.WORK_PROGRESS_INCOMPLETE, '/ui/setup/user/RoleViewPage', translations.get('NF_130'), null, null));
        managementOperations.add(new WorkProgressItemWrapper('company_info', Constants.WORK_PROGRESS_INCOMPLETE, '/' + getOrgId() + '?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DCompanyProfile&setupid=CompanyProfileInfo', translations.get('NF_5_3'), null, null));
        managementOperations.add(new WorkProgressItemWrapper('fiscal_year', Constants.WORK_PROGRESS_INCOMPLETE, '/setup/org/orgfyedit.jsp?id=' + getOrgId() + '&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DCompanyProfile&setupid=ForecastFiscalYear', translations.get('NF_5_4'), null, null));
        managementOperations.add(new WorkProgressItemWrapper('business_hour', Constants.WORK_PROGRESS_INCOMPLETE, '/01m?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DCompanyProfile&setupid=BusinessHours', translations.get('NF_5_5'), null, null));
        managementOperations.add(new WorkProgressItemWrapper('holiday', Constants.WORK_PROGRESS_INCOMPLETE, '/p/case/HolidayList?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DCompanyProfile&setupid=Holiday', translations.get('NF_5_6'), null, null));
    }

    private void setUpCloApps() {
        cloApps = new List<WorkProgressItemWrapper>();
        cloApps.add(new WorkProgressItemWrapper('cloapp_cargo_tracking', Constants.WORK_PROGRESS_INCOMPLETE, '/apex/' + Constants.NAMESPACE + 'OrderTracking', translations.get('NF_6_1'), '/CloApp/cargotracking.png', null));
        cloApps.add(new WorkProgressItemWrapper('search_link', Constants.WORK_PROGRESS_INCOMPLETE, '/search/SearchResults', translations.get('NF_6_2'), '/CloApp/search_link.jpg', null));
    }

    private void setUpCloFil() {
        clofil = new List<WorkProgressItemWrapper>();
        clofil.add(new WorkProgressItemWrapper('clofil_system', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.plism.com/websquare/websquare.html?w2xPath=/sq5/com/uat/Index.xml', translations.get('NF_7_1'), '/CloFil/plism.jpg', null));
        clofil.add(new WorkProgressItemWrapper('filing_system', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'AdvancedFilingSystem__c'), translations.get('NF_7_2'), '/CloFil/naacs.gif', getNewRecordUrl(Constants.NAMESPACE + 'AdvancedFilingSystem__c', null)));
    }

    private void setUpExpenses() {
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();
        expenses = new List<WorkProgressItemWrapper>();
        expenses.add(new WorkProgressItemWrapper('purchasing_order', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'PurchasingOrder__c'), translations.get('NF_8_1'), '/Expense/po.png', getNewRecordUrl(Constants.NAMESPACE + 'PurchasingOrder__c', null)));
        expenses.add(new WorkProgressItemWrapper('purchasing_invoice', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'PurchasingInvoice__c'), translations.get('NF_8_2'), '/Expense/invoice.png', getNewRecordUrl(Constants.NAMESPACE + 'PurchasingInvoice__c', null)));
        expenses.add(new WorkProgressItemWrapper('resource', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Resource__c'), translations.get('NF_8_3'), '/Expense/resources.png', getNewRecordUrl(Constants.NAMESPACE + 'Resource__c', null)));
        expenses.add(new WorkProgressItemWrapper('expense_payable', Constants.WORK_PROGRESS_INCOMPLETE, getListViewUrl(setting.ExpensePayableViewName__c, 'PurchasingInvoice__c'), translations.get('NF_8_4'), '/Expense/sales_payable.png', null));

        WorkProgressItemWrapper cashWrapper = new WorkProgressItemWrapper('cash', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'CASH_BOOK__c'), translations.get('NF_15_6'), '/Accounting/cash.png', getNewRecordUrl(Constants.NAMESPACE + 'CASH_BOOK__c', null));
        cashWrapper.hasSubFlow = true;
        cashWrapper.subFlowItems.addAll(setupCashOptions());
        expenses.add(cashWrapper);

        expenses.add(new WorkProgressItemWrapper('bank_balance', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'BANK_BALANCE__c'), translations.get('NF_15_7'), '/Accounting/bank.png', getNewRecordUrl(Constants.NAMESPACE + 'BANK_BALANCE__c', null)));
    }

    private List<WorkProgressItemWrapper> setupCashOptions() {
        List<WorkProgressItemWrapper> ffSubFlowItems = new List<WorkProgressItemWrapper>();
        ffSubFlowItems.add(setUpOptionPerRecordType('cash_in', Constants.CASH_IN_RT, translations.get('NF_143'), CASH_BOOK__c.SObjectType, Constants.NAMESPACE + 'CASH_BOOK__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('cash_out', Constants.CASH_OUT_RT, translations.get('NF_144'), CASH_BOOK__c.SObjectType, Constants.NAMESPACE + 'CASH_BOOK__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('transaction', Constants.TRANSACTION_RT, translations.get('NF_151'), CASH_BOOK__c.SObjectType, Constants.NAMESPACE + 'CASH_BOOK__c'));
        return ffSubFlowItems;
    }

    private void setUpConsolidation() {
        consolidation = new List<WorkProgressItemWrapper>();
        consolidation.add(new WorkProgressItemWrapper('consolidation', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'MasterAnken__c'), translations.get('NF_9_1'), '/Consolidation/consolidation.jpg', getNewRecordUrl(Constants.NAMESPACE + 'MasterAnken__c', null)));
        consolidation.add(new WorkProgressItemWrapper('consolidation_buying', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'MasterAnkenMeisai__c'), translations.get('NF_9_2'), '/Consolidation/consolidation_buying.png', getNewRecordUrl(Constants.NAMESPACE + 'MasterAnkenMeisai__c', null)));
    }

    private void setUpInitialSettings() {
        initialSettings = new List<WorkProgressItemWrapper>();
        initialSettings.add(new WorkProgressItemWrapper('initial_setup', Constants.WORK_PROGRESS_INCOMPLETE, '/apex/' + Constants.NAMESPACE + 'AFRSettings', translations.get('NF_10_1'), '/Setup/setup.jpg', null));
        initialSettings.add(new WorkProgressItemWrapper('initial_setup_info', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.dropbox.com/sh/uiywj2uuw2rkizr/AADJEX4tNfCI9KkwFwGD870va?dl=0', translations.get('NF_10_2'), '/Setup/required_info.png', null));
        initialSettings.add(new WorkProgressItemWrapper('bank_account', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'BankAccount__c'), translations.get('NF_110'), '/Setup/bank_account.jpeg', getNewRecordUrl(Constants.NAMESPACE + 'BankAccount__c', null)));
        initialSettings.add(new WorkProgressItemWrapper('vat_tax_rate', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Tax_Ratio__c'), translations.get('NF_10_3'), '/Setup/tax_ratio.jpg', getNewRecordUrl(Constants.NAMESPACE + 'Tax_Ratio__c', null)));
        initialSettings.add(new WorkProgressItemWrapper('exchange_rate', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'MgmtMaster__c'), translations.get('NF_10_4'), '/Setup/ex_rate.png', getNewRecordUrl(Constants.NAMESPACE + 'MgmtMaster__c', null)));
        initialSettings.add(new WorkProgressItemWrapper('warehouse', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'LoadLocation__c'), translations.get('NF_10_5'), '/Setup/warehouse.jpg', getNewRecordUrl(Constants.NAMESPACE + 'LoadLocation__c', null)));
    }

    private void setUpGovernances() {
        governance = new List<WorkProgressItemWrapper>();
        governance.add(new WorkProgressItemWrapper('health_check', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/security/dashboard/aura/SecurityDashboardAuraContainer?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DSecurity&setupid=HealthCheck', translations.get('NF_11_1'), null, null));
        governance.add(new WorkProgressItemWrapper('password_policies', Constants.WORK_PROGRESS_INCOMPLETE, '/secur/orgloginsettingedit.jsp?id=' + getOrgId() + '&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DSecurity&setupid=SecurityPolicies', translations.get('NF_11_2'), null, null));
        governance.add(new WorkProgressItemWrapper('login_access', Constants.WORK_PROGRESS_INCOMPLETE, '/0Ya?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DUsers&setupid=OrgLoginHistory', translations.get('NF_11_3'), null, null));
        governance.add(new WorkProgressItemWrapper('session_security', Constants.WORK_PROGRESS_INCOMPLETE, '/_ui/system/security/SessionSettings?id=' + getOrgId() + '&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DSecurity&setupid=SecuritySession', translations.get('NF_11_4'), null, null));
        governance.add(new WorkProgressItemWrapper('user_session', Constants.WORK_PROGRESS_INCOMPLETE, '/setup/secur/session/SessionManagementPage.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DSecurity&setupid=SessionManagementPage', translations.get('NF_11_5'), null, null));
        governance.add(new WorkProgressItemWrapper('network_access', Constants.WORK_PROGRESS_INCOMPLETE, '/05G?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DSecurity&setupid=NetworkAccess', translations.get('NF_11_6'), null, null));
        governance.add(new WorkProgressItemWrapper('domain', Constants.WORK_PROGRESS_INCOMPLETE, '/domainname/DomainName.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DDomains&setupid=OrgDomain', translations.get('NF_11_7'), null, null));
        governance.add(new WorkProgressItemWrapper('backup', Constants.WORK_PROGRESS_INCOMPLETE, '/ui/setup/export/DataExportPage/d?setupid=DataManagementExport&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DDataManagement', translations.get('NF_11_8'), null, null));
        governance.add(new WorkProgressItemWrapper('verification_history', Constants.WORK_PROGRESS_INCOMPLETE, '/setup/secur/VerificationHistory.apexp?setupid=VerificationHistory&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DUsers', translations.get('NF_11_9'), null, null));

        /**
            Setup Server Status link
         */
        String instanceName = Util.getServerInstance();
        if (StringUtils.isEmpty(instanceName)) {
            governance.add(new WorkProgressItemWrapper('server_status', Constants.WORK_PROGRESS_INCOMPLETE, 'https://status.salesforce.com/status', translations.get('NF_11_10'), null, null));
        } else {
            governance.add(new WorkProgressItemWrapper('server_status', Constants.WORK_PROGRESS_INCOMPLETE, 'https://status.salesforce.com/status/' + instanceName, translations.get('NF_11_10'), null, null));
        }

        governance.add(new WorkProgressItemWrapper('data_center_security', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.trust.salesforce.com/en/security', translations.get('NF_11_11'), null, null));
        governance.add(new WorkProgressItemWrapper('compliance', Constants.WORK_PROGRESS_INCOMPLETE, 'https://www.trust.salesforce.com/en/compliance/', translations.get('NF_11_12'), null, null));
        governance.add(new WorkProgressItemWrapper('data_storage_limit', Constants.WORK_PROGRESS_INCOMPLETE, 'https://help.salesforce.com/articleView?id=overview_storage.htm&type=5', translations.get('NF_131'), null, null));
        governance.add(new WorkProgressItemWrapper('storage_usage', Constants.WORK_PROGRESS_INCOMPLETE, '/setup/org/orgstorageusage.jsp?id=' + getOrgId() + '&setupid=CompanyResourceDisk&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DDataManagement', translations.get('NF_11_13'), null, null));
    }

    private void setUpReferenceData() {
        referenceData = new List<WorkProgressItemWrapper>();
        referenceData.add(new WorkProgressItemWrapper('ac_code', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Accounting_Code__c'), translations.get('NF_12_1'), '/Codes/ac.png', getNewRecordUrl(Constants.NAMESPACE + 'Accounting_Code__c', null)));
        referenceData.add(new WorkProgressItemWrapper('hs_code', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'HS_Code__c'), translations.get('NF_12_2'), '/Codes/hs.jpg', getNewRecordUrl(Constants.NAMESPACE + 'HS_Code__c', null)));
        referenceData.add(new WorkProgressItemWrapper('carrier_code', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Carrier_Code__c'), translations.get('NF_12_3'), '/Codes/carrier.png', getNewRecordUrl(Constants.NAMESPACE + 'Carrier_Code__c', null)));
        referenceData.add(new WorkProgressItemWrapper('port_code', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Port__c'), translations.get('NF_12_4'), '/Codes/port.jpg', getNewRecordUrl(Constants.NAMESPACE + 'Port__c', null)));
        referenceData.add(new WorkProgressItemWrapper('manifest_code', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'MANIFEST__c'), translations.get('NF_12_5'), '/Codes/manifest.png', getNewRecordUrl(Constants.NAMESPACE + 'MANIFEST__c', null)));
    }

    private void setUpQuotation() {
        String quotationRecortTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.QUOTATION_RT);
        Map<String, String> additionalParams = new Map<String, String>();
        additionalParams.put('RecordType', quotationRecortTypeId);

        quotation = new List<WorkProgressItemWrapper>();
        quotation.add(new WorkProgressItemWrapper('account', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Account'), translations.get('NF_13_1'), '/CRM/customer.jpg', getNewRecordUrl('Account', null)));
        quotation.add(new WorkProgressItemWrapper('contact', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Contact'), translations.get('NF_13_3'), '/CRM/contact.png', getNewRecordUrl('Contact', null)));
        quotation.add(new WorkProgressItemWrapper('quote', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'CustomObject1__c'), translations.get('NF_13_4'), '/CRM/quote.png', getNewRecordUrl(Constants.NAMESPACE + 'CustomObject1__c', additionalParams)));
    }

    private void setUpForwarding() {
        forwarding = new List<WorkProgressItemWrapper>();
        String openUrl = getTabUrl(Constants.NAMESPACE + 'CustomObject1__c');
        WorkProgressItemWrapper ff = new WorkProgressItemWrapper('freight_forwarding', Constants.WORK_PROGRESS_INCOMPLETE, openUrl, translations.get('NF_14_6'), '/Forwarding/freight_forwarding.jpg', openUrl);
        ff.hasSubFlow = true;
        ff.subFlowItems.addAll(setupShipmentOrderOptions());
        forwarding.add(ff);

        forwarding.add(new WorkProgressItemWrapper('container', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Container_Info__c'), translations.get('NF_14_7'), '/Forwarding/container.jpg', getNewRecordUrl(Constants.NAMESPACE + 'Container_Info__c', null)));
        forwarding.add(new WorkProgressItemWrapper('data_loader', Constants.WORK_PROGRESS_INCOMPLETE, '/apex/' + Constants.NAMESPACE + 'DataLoader', translations.get('NF_14_8'), '/CloApp/dataloader.png', null));
        forwarding.add(new WorkProgressItemWrapper('transit', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Transit__c'), translations.get('NF_112'), '/CloApp/transit.png', getNewRecordUrl(Constants.NAMESPACE + 'Transit__c', null)));
        forwarding.add(new WorkProgressItemWrapper('carrier_links', Constants.WORK_PROGRESS_INCOMPLETE, '/apex/' + Constants.NAMESPACE + 'ShippingLineLinks', translations.get('NF_13_2'), '/CRM/schedule.png', null));
    }

    private List<WorkProgressItemWrapper> setupShipmentOrderOptions() {
        List<WorkProgressItemWrapper> ffSubFlowItems = new List<WorkProgressItemWrapper>();
        ffSubFlowItems.add(setUpOptionPerRecordType('ff_ocean_import_new', Constants.OCEAN_IMPORT_RT, translations.get('NF_14_1'), CustomObject1__c.SObjectType, Constants.NAMESPACE + 'CustomObject1__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('ff_ocean_export_new', Constants.OCEAN_EXPORT_RT, translations.get('NF_14_2'), CustomObject1__c.SObjectType, Constants.NAMESPACE + 'CustomObject1__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('ff_air_import_new', Constants.AIR_IMPORT_RT, translations.get('NF_14_3'), CustomObject1__c.SObjectType, Constants.NAMESPACE + 'CustomObject1__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('ff_air_export_new', Constants.AIR_EXPORT_RT, translations.get('NF_14_4'), CustomObject1__c.SObjectType, Constants.NAMESPACE + 'CustomObject1__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('ff_domestic_transportation_new', Constants.DOMESTIC_TRANSPORTATION_RT, translations.get('NF_14_5'), CustomObject1__c.SObjectType, Constants.NAMESPACE + 'CustomObject1__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('ff_cross_boarder_new', Constants.CROSS_BOARDER_RT, translations.get('NF_109'), CustomObject1__c.SObjectType, Constants.NAMESPACE + 'CustomObject1__c'));
        return ffSubFlowItems;
    }

    private void setUpAccounting() {
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();
        accounting = new List<WorkProgressItemWrapper>();
        WorkProgressItemWrapper pricingWrapper = new WorkProgressItemWrapper('pricing', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'TariffMaster__c'), translations.get('NF_15_5'), '/Setup/pricing.jpg', getNewRecordUrl(Constants.NAMESPACE + 'TariffMaster__c', null));
        pricingWrapper.hasSubFlow = true;
        pricingWrapper.subFlowItems.addAll(setUpPricingOptions());
        accounting.add(pricingWrapper);
        accounting.add(new WorkProgressItemWrapper('invoicing', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'AnkenMeisai__c'), translations.get('NF_14_11'), '/Forwarding/invoice.png', getNewRecordUrl(Constants.NAMESPACE + 'AnkenMeisai__c', null)));
        accounting.add(new WorkProgressItemWrapper('exchange_rate', Constants.WORK_PROGRESS_INCOMPLETE, getListViewUrl(setting.ExchangeRateViewName__c, 'AnkenMeisai__c'), translations.get('NF_146'), '/Accounting/exchangerate.jpeg', null));
        accounting.add(new WorkProgressItemWrapper('statement', Constants.WORK_PROGRESS_INCOMPLETE, '/apex/' + Constants.NAMESPACE + 'page_outstandingstatementreport', translations.get('NF_15_2'), '/Accounting/statement.png', null));
        accounting.add(new WorkProgressItemWrapper('vat_invoice', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'VAT_INVOICE__C'), translations.get('NF_15_1'), '/Accounting/vat_invoice.png', getNewRecordUrl(Constants.NAMESPACE + 'VAT_INVOICE__C', null)));
        accounting.add(new WorkProgressItemWrapper('vat_invoice', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Kickback__c'), translations.get('NF_133'), '/Accounting/kickback.png', getNewRecordUrl(Constants.NAMESPACE + 'Kickback__c', null)));

        String listViewUrl = getListViewUrl(setting.ReceivableViewName__c, 'AnkenMeisai__c');
        accounting.add(new WorkProgressItemWrapper('receivable', Constants.WORK_PROGRESS_INCOMPLETE, listViewUrl, translations.get('NF_15_3'), '/Accounting/receivable.png', null));

        listViewUrl = getListViewUrl(setting.PayableViewName__c, 'AnkenMeisai__c');
        accounting.add(new WorkProgressItemWrapper('payable', Constants.WORK_PROGRESS_INCOMPLETE, listViewUrl, translations.get('NF_15_4'), '/Accounting/payable.jpg', null));
    }

    private List<WorkProgressItemWrapper> setUpPricingOptions() {
        List<WorkProgressItemWrapper> ffSubFlowItems = new List<WorkProgressItemWrapper>();
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_air', Constants.PRICING_AIR_RT, translations.get('NF_134'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_custom_clearance', Constants.PRICING_CUSTOM_CLEARANCE_RT, translations.get('NF_136'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_consolidation', Constants.PRICING_CONSOLIDATION_RT, translations.get('NF_135'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_empty', Constants.PRICING_EMPTY_CONTAINER_RT, translations.get('NF_137'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_fcl', Constants.PRICING_FLC_RT, translations.get('NF_138'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_full_container_truck', Constants.PRICING_FULL_CONTAINER_TRUCK_RT, translations.get('NF_139'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_lcl', Constants.PRICING_LCL_RT, translations.get('NF_140'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_trucking', Constants.PRICING_TRUCKING_RT, translations.get('NF_141'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('pri_warehousing', Constants.PRICING_WAREHOUSING_RT, translations.get('NF_142'), TariffMaster__c.SObjectType, Constants.NAMESPACE + 'TariffMaster__c'));

        return ffSubFlowItems;
    }

    private WorkProgressItemWrapper setUpOptionPerRecordType(String optionKey, String recordType, String label, SObjectType sObjectType, String objectName) {
        Map<String, String> additionalParams = new Map<String, String>();
        String recortTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(sObjectType, recordType);
        additionalParams.put('RecordType', recortTypeId);
        return (new WorkProgressItemWrapper(optionKey, Constants.WORK_PROGRESS_INCOMPLETE, getNewRecordUrl(objectName, additionalParams), '+ ' + label, '', null));
    }

    private void setUpTrucking() {
        trucking = new List<WorkProgressItemWrapper>();

        trucking.add(new WorkProgressItemWrapper('route_load', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'Route__c'), translations.get('NF_16_1'), '/Truck/location.jpg', getNewRecordUrl(Constants.NAMESPACE + 'Route__c', null)));

        WorkProgressItemWrapper ff = new WorkProgressItemWrapper('truck_fleet', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'TruckFleet__c'), translations.get('NF_16_2'), '/Truck/truck.jpg', getNewRecordUrl(Constants.NAMESPACE + 'TruckFleet__c', null));
        ff.hasSubFlow = true;
        ff.subFlowItems.addAll(setupTruckFleetOptions());
        trucking.add(ff);

        trucking.add(new WorkProgressItemWrapper('driver', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'WORKER__c'), translations.get('NF_16_3'), '/Truck/driver.jpg', getNewRecordUrl(Constants.NAMESPACE + 'WORKER__c', null)));
        trucking.add(new WorkProgressItemWrapper('maintenance_repair', Constants.WORK_PROGRESS_INCOMPLETE, getTabUrl(Constants.NAMESPACE + 'MAINTENANCE_REPAIR__c'), translations.get('NF_16_4'), '/Truck/repair.png', getNewRecordUrl(Constants.NAMESPACE + 'MAINTENANCE_REPAIR__c', null)));
    }

    private List<WorkProgressItemWrapper> setupTruckFleetOptions() {
        List<WorkProgressItemWrapper> ffSubFlowItems = new List<WorkProgressItemWrapper>();
        ffSubFlowItems.add(setUpOptionPerRecordType('tf_full_container_chassi', Constants.TF_CONTAINER_CHASSI_RT, translations.get('NF_147'), TruckFleet__c.SObjectType, Constants.NAMESPACE + 'TruckFleet__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('tf_full_container_trucj', Constants.TF_CONTAINER_TRUCK_RT, translations.get('NF_148'), TruckFleet__c.SObjectType, Constants.NAMESPACE + 'TruckFleet__c'));
        ffSubFlowItems.add(setUpOptionPerRecordType('tf_truck', Constants.TF_TRUCK_RT, translations.get('NF_149'), TruckFleet__c.SObjectType, Constants.NAMESPACE + 'TruckFleet__c'));
        return ffSubFlowItems;
    }

    private void setUpManagementProcess() {
        Site_Custom_Settings__c setting = Site_Custom_Settings__c.getOrgDefaults();
        managementProcess = new List<WorkProgressItemWrapper>();
        managementProcess.add(new WorkProgressItemWrapper('custom_dashboard', Constants.WORK_PROGRESS_INCOMPLETE, '/01Z/o', translations.get('NF_17_1'), '/Process/Dashboard.jpg', null));
        managementProcess.add(new WorkProgressItemWrapper('custom_report', Constants.WORK_PROGRESS_INCOMPLETE, '/00O/o', translations.get('NF_17_2'), '/Process/Report.jpg', null));
        managementProcess.add(new WorkProgressItemWrapper('custom_approval_process', Constants.WORK_PROGRESS_INCOMPLETE, '/p/process/ProcessDefinitionSetup?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DWorkflow&setupid=ApprovalProcesses', translations.get('NF_17_3'), '/Process/ApprovalProcess.jpg', null));
        managementProcess.add(new WorkProgressItemWrapper('custom_workflow_rules', Constants.WORK_PROGRESS_INCOMPLETE, '/01Q?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DWorkflow&setupid=WorkflowRules&sdtd=1', translations.get('NF_17_4'), '/Process/Workflow_Rules.png', null));
        managementProcess.add(new WorkProgressItemWrapper('custom_documents', Constants.WORK_PROGRESS_INCOMPLETE, '/01H?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DCommunicationTemplates&setupid=CommunicationTemplatesWord', translations.get('NF_17_5'), '/Process/Document.jpg', null));
        managementProcess.add(new WorkProgressItemWrapper('file_converter', Constants.WORK_PROGRESS_INCOMPLETE, (StringUtils.isEmpty(setting.FileConverterURL__c) ? '#' : 'https://' + setting.FileConverterURL__c), translations.get('NF_150'), '/Process/FileConverter.jpeg', null));
        managementProcess.add(new WorkProgressItemWrapper('custom_emails', Constants.WORK_PROGRESS_INCOMPLETE, '/00X?setupid=EmailTemplates&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DEmailSetup', translations.get('NF_17_6'), '/Process/EmailTemplate.jpg', null));
        managementProcess.add(new WorkProgressItemWrapper('printed_document', Constants.WORK_PROGRESS_INCOMPLETE, '/015/o', translations.get('NF_17_7'), '/Process/PrintedDocument.png', null));
        managementProcess.add(new WorkProgressItemWrapper('translation', Constants.WORK_PROGRESS_INCOMPLETE, '/ui/setup/Setup?setupid=LabelWorkbench', translations.get('NF_118'), '/Process/Translation.jpg', null));
    }

    public static String getNewRecordUrl(String objectType, Map<String, String> additionalParams) {
        String openUrl = '/' + getObjectTypeId(objectType) + '/e';

        if (additionalParams != null && additionalParams.size() > 0) {
            String paramString = null;

            for (String key : additionalParams.keySet()) {
                if (StringUtils.isEmpty(paramString)) {
                    paramString = '?' + key + '=' + additionalParams.get(key);
                } else {
                    paramString += '&' + key + '=' + additionalParams.get(key);
                }
            }
            openUrl += paramString;
        }

        return openUrl;
    }

    public static String getTabUrl(String objectType) {
        return '/' + getObjectTypeId(objectType) + '/o';
    }

    public static String getRecordTypeSelectionPage(final String objectName) {
        String openUrl = null;
        String objectTypeId = getObjectTypeId(Constants.NAMESPACE + objectName + '__c');
        Id forwardingObjectId = getCustomObjectId(objectName);
        if (forwardingObjectId != null) {
            openUrl = '/setup/ui/recordtypeselect.jsp?ent=' + forwardingObjectId + '&retURL=%2F' + objectTypeId + '%2Fo&save_new_url=%2F' + objectTypeId + '%2Fe%3FretURL%3D%252F' + objectTypeId + '%252Fo';
                /*+ 
                + 'retURL=' + EncodingUtil.urlEncode('/' + objectTypeId + '/o', 'UTF-8')
                + '&save_new_url=' + EncodingUtil.urlEncode('/' + objectTypeId + '/e', 'UTF-8')
                + EncodingUtil.urlEncode('?', 'UTF-8') + 'retURL='
                + EncodingUtil.urlEncode('%/' + objectTypeId, 'UTF-8')
                + EncodingUtil.urlEncode('%/' + objectTypeId + '/o', 'UTF-8');*/
        }

        return openUrl;
    }

    public static String getCustomObjectId(String objectName) {
        Id customObjectId = null;

        try {
            String query = 'SELECT Id From CustomObject Where DeveloperName = \'' + objectName + '\'';
            String endpoint = Url.getSalesforceBaseUrl().toExternalForm();
            endpoint += '/services/data/v29.0/tooling/query/?q=';
            endpoint += EncodingUtil.urlEncode(query, 'UTF-8');

            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setEndpoint(endpoint);

            if (!Test.isRunningTest()) {
                HttpResponse response = new Http().send(request);
                customObjectId = response.getBody().substringAfter('"Id":"').substringBefore('"');
            }
        } catch (Exception e) {
        }

        return customObjectId;
    }

    public static String getListViewId(final String viewName, final String objectName) {
        if (PermissionValidationUtil.isAccessibleHBLBuying()) {
            String q = 'SELECT Name FROM ' + objectName + ' LIMIT 1';
            ApexPages.StandardSetController ACC = new ApexPages.StandardSetController(Database.getQueryLocator(q));
            List<SelectOption> ListViews = ACC.getListViewOptions();

            for (SelectOption w : ListViews) {
                String listViewId = w.getValue().left(15);
                if (w.getLabel().equals(viewName)) {
                    return listViewId;
                }
            }
        }

        return null;
    }

    public static String getListViewUrl(final String viewName, final String objectName) {
        String listViewId = getListViewId(viewName, objectName);
        String objectId = getObjectTypeId(Constants.NAMESPACE + objectName);
        String openUrl = '/#';

        if (!StringUtils.isEmpty(objectId) && !StringUtils.isEmpty(listViewId)) {
            openUrl = '/' + objectId + '?fcf=' + listViewId;
        }

        return openUrl;
    }

    public static String getObjectTypeId(final String objectType) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = schemaMap.get(objectType);
        String objectTypeId = sObjectType.getDescribe().getKeyPrefix();

        return objectTypeId;
    }

    public static String getUserId() {
        return UserInfo.getUserId();
    }

    public static String getOrgId() {
        return UserInfo.getOrganizationId();
    }
}