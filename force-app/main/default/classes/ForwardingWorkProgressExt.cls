/**
 * Next number: 14
 */
public with sharing class ForwardingWorkProgressExt {
    private ApexPages.StandardController stdController;
    public List<WorkProgressItemWrapper> workProgressItems { get; private set; }
    private CustomObject1__c shipment;
    private Map<String, Integer> mapStatusPosition;
    private Integer currentStatusPosition;
    public Map<String, String> translations { get; private set; }
    private String localCurrency;

    private static Map<String, String> currencyNameToSymbol;

    static {
        currencyNameToSymbol = new Map<String, String>();
        currencyNameToSymbol.put('USD','$');
        currencyNameToSymbol.put('JPY','¥');
        currencyNameToSymbol.put('VND','đ');
        currencyNameToSymbol.put('KRW','₩');
        currencyNameToSymbol.put('KHR','៛');
        currencyNameToSymbol.put('PHP','₱');
    }

    public ForwardingWorkProgressExt(ApexPages.StandardController controller) {
        initializeTranslation();

        if (PermissionValidationUtil.isAccessibleHBL()) {
            this.stdController = controller;
            if (!Test.isRunningTest()) {
                controller.addFields(new List<String>{
                        'RecordTypeId', Constants.NAMESPACE + 'Custom__c'
                        , Constants.NAMESPACE + 'DeliveryService_required__c'
                        , Constants.NAMESPACE + 'NyukinzandakaJPY__c'
                        , Constants.NAMESPACE + 'BuyDifferentiation_sum2__c'
                        , Constants.NAMESPACE + 'Status__c'
                        , Constants.NAMESPACE + 'Fowarding__c'
                        , Constants.NAMESPACE + 'UNPAID_BALANCE_OF_SELLING_USD__c'
                        , Constants.NAMESPACE + 'UNPAID_BALANCE_OF_BUYING_USD__c'
                        // Khanh：「WorkProcessで作ったStatus Barに新しい値を追加すること」Start
                        , Constants.NAMESPACE + 'SellInTaxAmountJPY_sum__c'
                        , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c'
                        , Constants.NAMESPACE + 'BuyInTaxAmountJPY_sum__c'
                        , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c'
                        // Khanh：「WorkProcessで作ったStatus Barに新しい値を追加すること」End
                });
            }

            shipment = (CustomObject1__c) controller.getRecord();
            initializeStatusPosition();

            if (ObjectClassificationUtils.isImportHBL(shipment)) {
                initImportWorkProgressList();
            } else if (ObjectClassificationUtils.isExportHBL(shipment) || ObjectClassificationUtils.isCrossBoarder(shipment)) {
                initExportWorkProgressList();
            } else if (ObjectClassificationUtils.isDomesticTransportation(shipment) || ObjectClassificationUtils.isCrossBoarder(shipment)) {
                initDomesticTransportationWorkProgressList();
            }
        }
    }

    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('ProgressBar', UserInfo.getLanguage());
        translations = translationService.getTranslations();

        Site_Custom_Settings__c settings = Site_Custom_Settings__c.getOrgDefaults();
        localCurrency = currencyNameToSymbol.get(settings.Local_Currency__c);
    }

    private void initializeStatusPosition() {
        List<String> statusList = new List<String>();
        currentStatusPosition = -1;

        if (ObjectClassificationUtils.isOceanHBL(shipment) && ObjectClassificationUtils.isImportHBL(shipment)) {
            statusList = getOceanImportStatuses();
        } else if ((ObjectClassificationUtils.isOceanHBL(shipment) && ObjectClassificationUtils.isExportHBL(shipment))
                || ObjectClassificationUtils.isCrossBoarder(shipment)) {
            statusList = getOceanExportStatuses();
        } else if (ObjectClassificationUtils.isAirHBL(shipment) && ObjectClassificationUtils.isImportHBL(shipment)) {
            statusList = getAirImportStatuses();
        } else if (ObjectClassificationUtils.isAirHBL(shipment) && ObjectClassificationUtils.isExportHBL(shipment)) {
            statusList = getAirExportStatuses();
        } else if (ObjectClassificationUtils.isDomesticTransportation(shipment) || ObjectClassificationUtils.isCrossBoarder(shipment)) {
            statusList = getDomesticTransportationStatuses();
        }

        mapStatusPosition = new Map<String, Integer>();
        Integer position = 0;

        for (String status : statusList) {
            mapStatusPosition.put(status, position++);
        }

        if (mapStatusPosition.containsKey(shipment.Status__c)) {
            currentStatusPosition = mapStatusPosition.get(shipment.Status__c);
        }
    }

    private void initImportWorkProgressList() {
        workProgressItems = new List<WorkProgressItemWrapper>();
        Boolean hasInCompletedStep = false;

        hasInCompletedStep = addImportBooking(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addImportDocument(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addImportCustomClearance(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addImportDelivery(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addInvoice(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addCancellation(hasInCompletedStep);
        hasInCompletedStep = addReceivables(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addPayment(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addCompletion(workProgressItems, hasInCompletedStep);
    }

    private void initExportWorkProgressList() {
        workProgressItems = new List<WorkProgressItemWrapper>();
        Boolean hasInCompletedStep = false;

        hasInCompletedStep = addExportBooking(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addExportDelivery(workProgressItems, hasInCompletedStep);

        if (ObjectClassificationUtils.isCrossBoarder(shipment)) {
            Integer option = determineCrossBoarderCustomClearance();

            if (option == 3) {
                hasInCompletedStep = addImportCustomClearance(workProgressItems, hasInCompletedStep);
                hasInCompletedStep = addExportCustomClearance(workProgressItems, hasInCompletedStep);
            } else if (option == 2) {
                hasInCompletedStep = addExportCustomClearance(workProgressItems, hasInCompletedStep);
            } else if (option == 1) {
                hasInCompletedStep = addImportCustomClearance(workProgressItems, hasInCompletedStep);
            }
        } else {
            hasInCompletedStep = addExportCustomClearance(workProgressItems, hasInCompletedStep);
        }

        hasInCompletedStep = addExportDocument(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addExportInvoice(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addCancellation(hasInCompletedStep);
        hasInCompletedStep = addReceivables(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addPayment(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addCompletion(workProgressItems, hasInCompletedStep);
    }

    private void initDomesticTransportationWorkProgressList() {
        workProgressItems = new List<WorkProgressItemWrapper>();
        Boolean hasInCompletedStep = false;

        hasInCompletedStep = addExportBooking(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addExportDelivery(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addOutboundDocument(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addInboundDocument(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addImportDelivery(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addInvoice(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addCancellation(hasInCompletedStep);
        hasInCompletedStep = addReceivables(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addPayment(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addCompletion(workProgressItems, hasInCompletedStep);
    }

    private Boolean addImportBooking(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.FORWARDING_SERVICE_PROVIDER_US.equalsIgnoreCase(shipment.Fowarding__c)) {
            List<String> inProgressStatuses = new List<String>{
                    PicklistReference.CARGO_INFO_RECEIVED_ST, PicklistReference.BOOKING_INFO_CHANGED_ST
            };
            List<String> completedStatuses = new List<String>{
                    PicklistReference.DEPARTURED_ST
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_1'));
        }

        return hasInCompletedStep;
    }

    private Boolean addImportDocument(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.FORWARDING_SERVICE_PROVIDER_US.equalsIgnoreCase(shipment.Fowarding__c)) {
            List<String> inProgressStatuses = new List<String>{
                    PicklistReference.ON_VOYAGE_ST, PicklistReference.BB_REQUESTED_ST
            };
            List<String> completedStatuses = new List<String>{
                    PicklistReference.DO_ISSUED_ST
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_2'));
        }

        return hasInCompletedStep;
    }

    private Boolean addImportCustomClearance(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(shipment.Custom__c)) {
            List<String> inProgressStatuses = new List<String>{
                    PicklistReference.APP_FOR_CUSTOMS_CLEARANCE_ST, PicklistReference.CUSTOMS_INSPECTION_ST
            };
            List<String> completedStatuses = new List<String>{
                    PicklistReference.IMPORT_PERMITTED_ST
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_3'));
        }

        return hasInCompletedStep;
    }

    private Boolean addImportDelivery(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (shipment.DeliveryService_required__c != null && !'0'.equals(shipment.DeliveryService_required__c)) {
            List<String> inProgressStatuses = new List<String>{
                    PicklistReference.CARGO_PICKED_UP_ST, PicklistReference.ON_DELIVERY_ST
            };
            List<String> completedStatuses = new List<String>{
                    PicklistReference.DELIVERY_COMPLETED_ST
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_4'));
        }

        return hasInCompletedStep;
    }

    private Boolean addInvoice(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        List<String> inProgressStatuses = new List<String>{
                PicklistReference.IMPORT_PERMIT_INVOICE_ISSUED_ST, PicklistReference.IMPORT_REVISED_INVOICE_ISSUED_ST
        };
        List<String> completedStatuses = new List<String>{
                PicklistReference.IMPORT_ORIGINAL_INVOICE_AND_STATEMENT_OF_PAYMENT_ISSUED_ST
        };

        return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_5'));
    }

    private Boolean addExportBooking(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.FORWARDING_SERVICE_PROVIDER_US.equalsIgnoreCase(shipment.Fowarding__c)) {
            List<String> inProgressStatuses = new List<String>{
                    '輸出 出荷情報入手(Cargo Info Received)', '輸出 ブッキング情報入手(Booking Info Received)'
            };
            List<String> completedStatuses = new List<String>{
                    '輸出 ブッキング済(Booking Confirmed)'
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_1'));
        }

        return hasInCompletedStep;
    }

    private Boolean addExportDocument(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.FORWARDING_SERVICE_PROVIDER_US.equalsIgnoreCase(shipment.Fowarding__c)) {
            List<String> inProgressStatuses = new List<String>{
                    '輸出 船積指示書情報登録済み(SI Data Registered)', '輸出 チェックB/L送付済(Check B/L Issued)',
                    '輸出 船積指示書(SI Issued)', '輸出 フレイトメモ情報登録済み(Freight Memo Data Registered)', '輸出 フレイトメモ送付済(Freight Memo Issued)',
                    '輸出 B/L情報登録済み(B/L Data Registered)'
            };
            List<String> completedStatuses = new List<String>{
                    '輸出 船荷証券送付済(B/L Issued)'
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_6'));
        }

        return hasInCompletedStep;
    }

    private Boolean addExportDelivery(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (shipment.DeliveryService_required__c != null && !'0'.equals(shipment.DeliveryService_required__c)) {
            List<String> inProgressStatuses = new List<String>{
                    '輸出 貨物集荷済(Cargo Picked Up)', '輸出 配送出発済(On Delivery)'
            };
            List<String> completedStatuses = new List<String>{
                    '輸出 入庫済(In Storage)'
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_7'));
        }

        return hasInCompletedStep;
    }

    private Boolean addExportCustomClearance(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES.equalsIgnoreCase(shipment.Custom__c)) {
            List<String> inProgressStatuses = new List<String>{
                    '輸出 通関申告書作成中(Application for Customs Clearance)', '輸出 税関検査予定(Customs Inspection)'
            };
            List<String> completedStatuses = new List<String>{
                    '輸出 輸出許可(Export Permitted)'
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_8'));
        }

        return hasInCompletedStep;
    }

    private Boolean addExportInvoice(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        List<String> inProgressStatuses = new List<String>{
                '輸出 許可書/請求書メール・ファクス送信済(An Export Permit/Invoice Issued)', '輸出 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)'
        };
        List<String> completedStatuses = new List<String>{
                '輸出 請求書送付済(Original Invoice Issued)'
        };

        return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_5'));
    }

    private Boolean addReceivables(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (hasInCompletedStep) {
           /* workProgressItems.add(new WorkProgressItemWrapper('collect_receivable', Constants.WORK_PROGRESS_INCOMPLETE, '#', translations.get('PR_9') + '<br/>'
                    + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                    + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));*/
            // カン：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'SellInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c'
            
            workProgressItems.add(new WorkProgressItemWrapper('collect_receivable'
                                                               , Constants.WORK_PROGRESS_INCOMPLETE
                                                               , '#'
                                                               , translations.get('PR_14') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.SellInTaxAmountJPY_sum__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c, 'vi', false, null)
                                                               + '<br/>' + translations.get('PR_9') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));
            // カン：【修正】WorkProcessで作ったStatus Barに新しい値を追加すること　End
        } else if (shipment.NyukinzandakaJPY__c != 0
                || mapStatusPosition.get(PicklistReference.CANCELLED_ST) == currentStatusPosition
                || mapStatusPosition.get('輸入 請求書/納付書原本送付済(Original Invoice and Statement of Payment issued)') == currentStatusPosition
                || mapStatusPosition.get('輸入 立替金入金確認') == currentStatusPosition
                || mapStatusPosition.get('輸入 諸請求入金確認(Receipt of payment Confirmed)') == currentStatusPosition
                || mapStatusPosition.get('輸入 支払確認(Payment Confirmed)') == currentStatusPosition
                || mapStatusPosition.get('輸入 入金・支払確認(Deposit・Payment Confirmed)') == currentStatusPosition) {
            markPreviousStepsCompleted(workProgressItems);
            /*workProgressItems.add(new WorkProgressItemWrapper('collect_receivable', Constants.WORK_PROGRESS_CURRENT, '#', translations.get('PR_9') + '<br/>'
                    + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                    + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));*/
            
            // カン：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'SellInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c'
            
            workProgressItems.add(new WorkProgressItemWrapper('collect_receivable'
                                                               , Constants.WORK_PROGRESS_CURRENT
                                                               , '#'
                                                               , translations.get('PR_14') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.SellInTaxAmountJPY_sum__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c, 'vi', false, null)
                                                               + '<br/>' + translations.get('PR_9') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));
            // カン：【修正】WorkProcessで作ったStatus Barに新しい値を追加すること　End
            hasInCompletedStep = true;
        } else if (shipment.NyukinzandakaJPY__c == 0) {
            markPreviousStepsCompleted(workProgressItems);
            // カン：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'SellInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c'
            
            workProgressItems.add(new WorkProgressItemWrapper('collect_receivable'
                                                               , Constants.WORK_PROGRESS_COMPLETE
                                                               , '#'
                                                               , translations.get('PR_14') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.SellInTaxAmountJPY_sum__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c, 'vi', false, null)
                                                               + '<br/>' + translations.get('PR_9') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));
            // カン：【修正】WorkProcessで作ったStatus Barに新しい値を追加すること　End
            /*workProgressItems.add(new WorkProgressItemWrapper('collect_receivable', Constants.WORK_PROGRESS_COMPLETE, '#', translations.get('PR_9') + '<br/>'
                    + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                    + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));*/
        } else {
            // カン：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'SellInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c'
            
            workProgressItems.add(new WorkProgressItemWrapper('collect_receivable'
                                                               , Constants.WORK_PROGRESS_INCOMPLETE
                                                               , '#'
                                                               , translations.get('PR_14') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.SellInTaxAmountJPY_sum__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_SELLING_WITH_TAX_USD__c, 'vi', false, null)
                                                               + '<br/>' + translations.get('PR_9') + '<br/>'
                                                               + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                                                               + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));
            // カン：【修正】WorkProcessで作ったStatus Barに新しい値を追加すること　End
            /*workProgressItems.add(new WorkProgressItemWrapper('collect_receivable', Constants.WORK_PROGRESS_INCOMPLETE, '#', translations.get('PR_9') + '<br/>'
                    + NumbericUtils.formatNumberByLocale(shipment.NyukinzandakaJPY__c, 'vi', true, null) + localCurrency + ' &amp; $'
                    + NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_SELLING_USD__c, 'vi', false, null), null, '#'));*/
            hasInCompletedStep = true;
        }

        return hasInCompletedStep;
    }

    private Boolean addOutboundDocument(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.FORWARDING_SERVICE_PROVIDER_US.equalsIgnoreCase(shipment.Fowarding__c)) {
            List<String> inProgressStatuses = new List<String>{
                    '輸出 船積指示書情報登録済み(SI Data Registered)', '輸出 チェックB/L送付済(Check B/L Issued)',
                    '輸出 船積指示書(SI Issued)', '輸出 フレイトメモ情報登録済み(Freight Memo Data Registered)', '輸出 フレイトメモ送付済(Freight Memo Issued)',
                    '輸出 B/L情報登録済み(B/L Data Registered)'
            };
            List<String> completedStatuses = new List<String>{
                    '輸出 船荷証券送付済(B/L Issued)'
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_10'));
        }

        return hasInCompletedStep;
    }

    private Boolean addInboundDocument(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (PicklistReference.FORWARDING_SERVICE_PROVIDER_US.equalsIgnoreCase(shipment.Fowarding__c)) {
            List<String> inProgressStatuses = new List<String>{
                    PicklistReference.ON_VOYAGE_ST, PicklistReference.BB_REQUESTED_ST
            };
            List<String> completedStatuses = new List<String>{
                    PicklistReference.DO_ISSUED_ST
            };

            return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, '', translations.get('PR_11'));
        }

        return hasInCompletedStep;
    }

    private Boolean addPayment(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (hasInCompletedStep) {
            /*workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12'), Constants.WORK_PROGRESS_INCOMPLETE, '#', translations.get('PR_12') + '<br/>'
                    + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                    + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));*/
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'BuyInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c'
            workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12')
                                                              , Constants.WORK_PROGRESS_INCOMPLETE, '#'
                                                              ,  translations.get('PR_15') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyInTaxAmountJPY_sum__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c, 'vi', false, null))
                                                              +  '<br/>' + translations.get('PR_12') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
        } else if (shipment.BuyDifferentiation_sum2__c != 0) {
            markPreviousStepsCompleted(workProgressItems);
            /*workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12'), Constants.WORK_PROGRESS_CURRENT, '#', translations.get('PR_12') + '<br/>'
                    + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                    + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));*/
            
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'BuyInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c'
            workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12')
                                                              , Constants.WORK_PROGRESS_CURRENT, '#'
                                                              , translations.get('PR_15') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyInTaxAmountJPY_sum__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c, 'vi', false, null))
                                                              +  '<br/>' + translations.get('PR_12') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            hasInCompletedStep = true;
        } else if (shipment.BuyDifferentiation_sum2__c == 0) {
            markPreviousStepsCompleted(workProgressItems);
            /*workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12'), Constants.WORK_PROGRESS_COMPLETE, '#', translations.get('PR_12') + '<br/>'
                    + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                    + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));*/
            
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'BuyInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c'
            workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12')
                                                              , Constants.WORK_PROGRESS_COMPLETE, '#'
                                                              , translations.get('PR_15') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyInTaxAmountJPY_sum__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c, 'vi', false, null))
                                                              +  '<br/>' + translations.get('PR_12') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
        } else {
            /*workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12'), Constants.WORK_PROGRESS_INCOMPLETE, '#', translations.get('PR_12') + '<br/>'
                    + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                    + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));*/
            
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            // , Constants.NAMESPACE + 'BuyInTaxAmountJPY_sum__c'
            // , Constants.NAMESPACE + 'TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c'
            workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_12')
                                                              , Constants.WORK_PROGRESS_INCOMPLETE, '#'
                                                              , translations.get('PR_15') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyInTaxAmountJPY_sum__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.TOTAL_AMOUT_OF_BUYING_WITH_TAX_USD__c, 'vi', false, null))
                                                              +  '<br/>' + translations.get('PR_12') + '<br/>'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.BuyDifferentiation_sum2__c, 'vi', true, null)) + localCurrency + ' &amp; $'
                                                              + (NumbericUtils.formatNumberByLocale(shipment.UNPAID_BALANCE_OF_BUYING_USD__c, 'vi', false, null)), null, '#'));
            // Khanh：修正】WorkProcessで作ったStatus Barに新しい値を追加すること　Start
            hasInCompletedStep = true;
        }

        return hasInCompletedStep;
    }

    private Boolean addCompletion(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        if (mapStatusPosition.get(PicklistReference.COMPLETED_ST) <= currentStatusPosition) {
            markPreviousStepsCompleted(workProgressItems);
            workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_13'), Constants.WORK_PROGRESS_COMPLETE, '#', translations.get('PR_13'), null, '#'));
        } else {
            workProgressItems.add(new WorkProgressItemWrapper(translations.get('PR_13'), Constants.WORK_PROGRESS_INCOMPLETE, '#', translations.get('PR_13'), null, '#'));
            hasInCompletedStep = true;
        }

        return hasInCompletedStep;
    }

    private Boolean addCancellation(Boolean hasInCompletedStep) {
        /*
        if (mapStatusPosition.get(PicklistReference.CANCELLED_ST) <= currentStatusPosition) {
            markPreviousStepsCompleted(workProgressItems);
            hasInCompletedStep = true;
        }*/

        return hasInCompletedStep;
    }

    private Boolean addStatusBasedSteps(Integer currentStatusPosition, List<String> inProgressStatuses, List<String> completedStatus, Boolean hasInCompletedStep, String openUrl, String caption) {
        if (hasInCompletedStep) {
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_INCOMPLETE, openUrl, caption, null, '#'));
        } else if (isCurrentStep(inProgressStatuses, completedStatus, currentStatusPosition)) {
            markPreviousStepsCompleted(workProgressItems);
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_CURRENT, openUrl, caption, null, '#'));
            hasInCompletedStep = true;
        } else if (isCompletedStep(completedStatus, currentStatusPosition)) {
            markPreviousStepsCompleted(workProgressItems);
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_COMPLETE, openUrl, caption, null, '#'));
        } else {
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_INCOMPLETE, openUrl, caption, null, '#'));
            hasInCompletedStep = true;
        }

        return hasInCompletedStep;
    }

    private Boolean isCurrentStep(List<String> inProgressStatuses, List<String> completedStatuses, Integer currentStatusPosition) {
        for (String status : inProgressStatuses) {
            if (mapStatusPosition.get(status) == currentStatusPosition) {
                return true;
            }
        }

        if (mapStatusPosition.get(inProgressStatuses.get(0)) < currentStatusPosition
                && mapStatusPosition.get(completedStatuses.get(0)) > currentStatusPosition) {
            return true;
        }

        return false;
    }

    private Boolean isCompletedStep(List<String> completedStatuses, Integer currentStatusPosition) {
        for (String status : completedStatuses) {
            if (mapStatusPosition.get(status) <= currentStatusPosition) {
                return true;
            }
        }

        return false;
    }

    private void markPreviousStepsCompleted(List<WorkProgressItemWrapper> workProgressItems) {
        for (WorkProgressItemWrapper item : workProgressItems) {
            item.status = Constants.WORK_PROGRESS_COMPLETE;
        }
    }

    private static List<String> getOceanImportStatuses() {
        List<String> statuses = new List<String>();
        statuses.add('輸入 出荷情報入手(Cargo Info Received)');
        statuses.add('輸入 最初メール受付返事済み(First Contact Reply Email Sent to Parnter)');
        statuses.add('輸入 Pre-Alertデータ入力済み(Pre-Alert Data Registered)');
        statuses.add('輸入 AFRデータファイリング済み(AFR Data Filed)');
        statuses.add('輸入 B/L情報登録済み(B/L Data Registered)');
        statuses.add('輸入 SWITCH B/L情報待ち(Waiting for Switch B/L Data)');
        statuses.add('輸入 SWITCH B/L情報登録済み(Switch B/L Data Registered)');
        statuses.add('輸入 ブッキング情報入手(Booking Info Received)');
        statuses.add('輸入 ブッキング情報変更(Booking Info Changed)');
        statuses.add('輸入 本船/フライト出発済(Departured)');
        statuses.add('輸入 本船/フライト運行中(On Voyage)');
        statuses.add('輸入 本船/フライト遅延(Delayed)');
        statuses.add('輸入 トランジット本船/フライト出発済(Transit Departured)');
        statuses.add('輸入 本船/フライト到着済(Arrived)');
        statuses.add('輸入 A/N情報登録済み(A/N Data Registered)');
        statuses.add('輸入 到着案内済(A/N Issued)');
        statuses.add('輸入 出荷指図書発行済(D/O Issued)');
        statuses.add('輸入 お客様入金処理/業者支払処理済(Deposit Processed)');
        statuses.add('輸入 通関申告書作成中(Application for Customs Clearance)');
        statuses.add('輸入 税関審査中(Customs Examination)');
        statuses.add('輸入 税関審査終了(Cunstoms Declared)');
        statuses.add('輸入 税関検査予定(Customs Inspection)');
        statuses.add('輸入 輸入許可(Import Permitted)');
        statuses.add('輸入 貨物引取済/配送中(On Delivery)');
        statuses.add('輸入 納品完了(Delivery Completed)');
        statuses.add('輸入 許可書/請求書メール・ファクス送信済(An Import Permit/Invoice Issued)');
        statuses.add('輸入 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)');
        statuses.add('輸入 DEBIT/CREDITノート送付済み(Debit/Credit Note Issued)');
        statuses.add('輸入 請求書/納付書原本送付済(Original Invoice and Statement of Payment issued)');
        statuses.add('輸入 立替金入金確認');
        statuses.add('輸入 諸請求入金確認(Receipt of payment Confirmed)');
        statuses.add('輸入 支払確認(Payment Confirmed)');
        statuses.add('輸入 入金・支払確認(Deposit・Payment Confirmed)');
        statuses.add('キャンセル(Cancelled)');
        statuses.add('完了(Completed)');
        statuses.add('計上のための一時的なロック解除(Temporary Unlock)');

        return statuses;
    }

    private static List<String> getOceanExportStatuses() {
        List<String> statuses = new List<String>();
        statuses.add('輸出 出荷情報入手(Cargo Info Received)');
        statuses.add('輸出 ブッキング情報入手(Booking Info Received)');
        statuses.add('輸出 ブッキング情報変更(Booking Info Changed)');
        statuses.add('輸出 ブッキング済(Booking Confirmed)');
        statuses.add('輸出 貨物集荷済(Cargo Picked Up)');
        statuses.add('輸出 配送出発済(On Delivery)');
        statuses.add('輸出 入庫済(In Storage)');

        statuses.add('輸入 通関申告書作成中(Application for Customs Clearance)');
        statuses.add('輸入 税関審査中(Customs Examination)');
        statuses.add('輸入 税関審査終了(Cunstoms Declared)');
        statuses.add('輸入 税関検査予定(Customs Inspection)');
        statuses.add('輸入 輸入許可(Import Permitted)');

        statuses.add('輸出 通関申告書作成中(Application for Customs Clearance)');
        statuses.add('輸出 税関審査中(Customs Examination)');
        statuses.add('輸出 税関検査予定(Customs Inspection)');
        statuses.add('輸出 輸出許可(Export Permitted)');
        statuses.add('輸出 船積指示書情報登録済み(SI Data Registered)');
        statuses.add('輸出 船積指示書(SI Issued)');
        statuses.add('輸出 フレイトメモ情報登録済み(Freight Memo Data Registered)');
        statuses.add('輸出 フレイトメモ送付済(Freight Memo Issued)');
        statuses.add('輸出 B/L情報登録済み(B/L Data Registered)');
        statuses.add('輸出 チェックB/L送付済(Check B/L Issued)');
        statuses.add('輸出 船荷証券送付済(B/L Issued)');
        statuses.add('輸出 データファイリング済み(Data Filed)');
        statuses.add('輸出 本船/フライト遅延(Delayed)');
        statuses.add('輸出 本船/フライト出発済(Departured)');
        statuses.add('輸出  お客様入金処理/業者支払処理済');
        statuses.add('輸出 許可書/請求書メール・ファクス送信済(An Export Permit/Invoice Issued)');
        statuses.add('輸出 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)');
        statuses.add('輸出 請求書送付済(Original Invoice Issued)');
        statuses.add('輸出 入金確認(Receipt of payment Confirmed)');
        statuses.add('輸出 支払確認(Payment Confirmed)');
        statuses.add('輸出 DEBIT/CREDITノート送付済み(Debit/Credit Note Issued)');
        statuses.add('輸出 入金・支払確認(Deposit・Payment Confirmed)');
        statuses.add('輸出 本船/フライト到着済(Arrived)');
        statuses.add('キャンセル(Cancelled)');
        statuses.add('完了(Completed)');
        statuses.add('計上のための一時的なロック解除(Temporary Unlock)');

        return statuses;
    }

    private static List<String> getAirImportStatuses() {
        List<String> statuses = new List<String>();
        statuses.add('輸入 出荷情報入手(Cargo Info Received)');
        statuses.add('輸入 最初メール受付返事済み(First Contact Reply Email Sent to Parnter)');
        statuses.add('輸入 Pre-Alertデータ入力済み(Pre-Alert Data Registered)');
        statuses.add('輸入 AFRデータファイリング済み(AFR Data Filed)');
        statuses.add('輸入 B/L情報登録済み(B/L Data Registered)');
        statuses.add('輸入 SWITCH B/L情報待ち(Waiting for Switch B/L Data)');
        statuses.add('輸入 SWITCH B/L情報登録済み(Switch B/L Data Registered)');
        statuses.add('輸入 ブッキング情報入手(Booking Info Received)');
        statuses.add('輸入 ブッキング情報変更(Booking Info Changed)');
        statuses.add('輸入 本船/フライト出発済(Departured)');
        statuses.add('輸入 本船/フライト運行中(On Voyage)');
        statuses.add('輸入 本船/フライト遅延(Delayed)');
        statuses.add('輸入 トランジット本船/フライト出発済(Transit Departured)');
        statuses.add('輸入 本船/フライト到着済(Arrived)');
        statuses.add('輸入 A/N情報登録済み(A/N Data Registered)');
        statuses.add('輸入 到着案内済(A/N Issued)');
        statuses.add('輸入 BB依頼済み(BB Requested)-航空のみ(For AIR)');
        statuses.add('輸入 出荷指図書発行済(D/O Issued)');
        statuses.add('輸入 お客様入金処理/業者支払処理済(Deposit Processed)');
        statuses.add('輸入 通関申告書作成中(Application for Customs Clearance)');
        statuses.add('輸入 税関審査中(Customs Examination)');
        statuses.add('輸入 税関審査終了(Cunstoms Declared)');
        statuses.add('輸入 税関検査予定(Customs Inspection)');
        statuses.add('輸入 輸入許可(Import Permitted)');
        statuses.add('輸入 貨物引取済/配送中(On Delivery)');
        statuses.add('輸入 納品完了(Delivery Completed)');
        statuses.add('輸入 許可書/請求書メール・ファクス送信済(An Import Permit/Invoice Issued)');
        statuses.add('輸入 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)');
        statuses.add('輸入 DEBIT/CREDITノート送付済み(Debit/Credit Note Issued)');
        statuses.add('輸入 請求書/納付書原本送付済(Original Invoice and Statement of Payment issued)');
        statuses.add('輸入 立替金入金確認');
        statuses.add('輸入 諸請求入金確認(Receipt of payment Confirmed)');
        statuses.add('輸入 支払確認(Payment Confirmed)');
        statuses.add('輸入 入金・支払確認(Deposit・Payment Confirmed)');
        statuses.add('キャンセル(Cancelled)');
        statuses.add('完了(Completed)');
        statuses.add('計上のための一時的なロック解除(Temporary Unlock)');
        return statuses;
    }

    private static List<String> getAirExportStatuses() {
        List<String> statuses = new List<String>();
        statuses.add('輸出 出荷情報入手(Cargo Info Received)');
        statuses.add('輸出 ブッキング情報入手(Booking Info Received)');
        statuses.add('輸出 ブッキング情報変更(Booking Info Changed)');
        statuses.add('輸出 ブッキング済(Booking Confirmed)');
        statuses.add('輸出 貨物集荷済(Cargo Picked Up)');
        statuses.add('輸出 配送出発済(On Delivery)');
        statuses.add('輸出 入庫済(In Storage)');
        statuses.add('輸出 通関申告書作成中(Application for Customs Clearance)');
        statuses.add('輸出 税関審査中(Customs Examination)');
        statuses.add('輸出 税関検査予定(Customs Inspection)');
        statuses.add('輸出 輸出許可(Export Permitted)');
        statuses.add('輸出 船積指示書(SI Issued)');
        statuses.add('輸出 フレイトメモ送付済(Freight Memo Issued)');
        statuses.add('輸出 チェックB/L送付済(Check B/L Issued)');
        statuses.add('輸出 船荷証券送付済(B/L Issued)');
        statuses.add('輸出 データファイリング済み(Data Filed)');
        statuses.add('輸出 本船/フライト遅延(Delayed)');
        statuses.add('輸出 本船/フライト出発済(Departured)');
        statuses.add('輸出  お客様入金処理/業者支払処理済');
        statuses.add('輸出 許可書/請求書メール・ファクス送信済(An Export Permit/Invoice Issued)');
        statuses.add('輸出 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)');
        statuses.add('輸出 請求書送付済(Original Invoice Issued)');
        statuses.add('輸出 入金確認(Receipt of payment Confirmed)');
        statuses.add('輸出 支払確認(Payment Confirmed)');
        statuses.add('輸出 DEBIT/CREDITノート送付済み(Debit/Credit Note Issued)');
        statuses.add('輸出 入金・支払確認(Deposit・Payment Confirmed)');
        statuses.add('輸出 本船/フライト到着済(Arrived)');
        statuses.add('キャンセル(Cancelled)');
        statuses.add('完了(Completed)');
        statuses.add('計上のための一時的なロック解除(Temporary Unlock)');

        return statuses;
    }

    private static List<String> getDomesticTransportationStatuses() {
        List<String> statuses = new List<String>();
        statuses.add('輸出 出荷情報入手(Cargo Info Received)');
        statuses.add('輸出 ブッキング情報入手(Booking Info Received)');
        statuses.add('輸出 ブッキング情報変更(Booking Info Changed)');
        statuses.add('輸出 ブッキング済(Booking Confirmed)');
        statuses.add('輸出 貨物集荷済(Cargo Picked Up)');
        statuses.add('輸出 配送出発済(On Delivery)');
        statuses.add('輸出 入庫済(In Storage)');
        statuses.add('輸出 船積指示書情報登録済み(SI Data Registered)');
        statuses.add('輸出 船積指示書(SI Issued)');
        statuses.add('輸出 フレイトメモ情報登録済み(Freight Memo Data Registered)');
        statuses.add('輸出 フレイトメモ送付済(Freight Memo Issued)');
        statuses.add('輸出 B/L情報登録済み(B/L Data Registered)');
        statuses.add('輸出 チェックB/L送付済(Check B/L Issued)');
        statuses.add('輸出 船荷証券送付済(B/L Issued)');
        statuses.add('輸出 データファイリング済み(Data Filed)');
        statuses.add('輸出 本船/フライト遅延(Delayed)');
        statuses.add('輸出 本船/フライト出発済(Departured)');
        statuses.add('輸入 本船/フライト運行中(On Voyage)');
        statuses.add('輸入 本船/フライト遅延(Delayed)');
        statuses.add('輸入 トランジット本船/フライト出発済(Transit Departured)');
        statuses.add('輸入 本船/フライト到着済(Arrived)');
        statuses.add('輸入 A/N情報登録済み(A/N Data Registered)');
        statuses.add('輸入 到着案内済(A/N Issued)');
        statuses.add('輸入 出荷指図書発行済(D/O Issued)');
        statuses.add('輸入 お客様入金処理/業者支払処理済(Deposit Processed)');
        statuses.add('輸入 貨物引取済/配送中(On Delivery)');
        statuses.add('輸入 納品完了(Delivery Completed)');
        statuses.add('輸入 許可書/請求書メール・ファクス送信済(An Import Permit/Invoice Issued)');
        statuses.add('輸入 請求書訂正有メール・ファクス再送信済(Revised Invoice Issued)');
        statuses.add('輸入 DEBIT/CREDITノート送付済み(Debit/Credit Note Issued)');
        statuses.add('輸入 請求書/納付書原本送付済(Original Invoice and Statement of Payment issued)');
        statuses.add('輸入 立替金入金確認');
        statuses.add('輸入 諸請求入金確認(Receipt of payment Confirmed)');
        statuses.add('輸入 支払確認(Payment Confirmed)');
        statuses.add('輸入 入金・支払確認(Deposit・Payment Confirmed)');
        statuses.add('キャンセル(Cancelled)');
        statuses.add('完了(Completed)');
        statuses.add('計上のための一時的なロック解除(Temporary Unlock)');


        return statuses;
    }

    /**
     * - BOTH import & export: 3
     * - ONLY export: 2
     * - ONLY import: 1
     * - NONE: 0
     */
    private Integer determineCrossBoarderCustomClearance() {
        List<Custom_Clearance__c> customClearances = [SELECT Id, RecordType.DeveloperName FROM Custom_Clearance__c WHERE HBL_SHIPMENT__c = :shipment.Id];
        Boolean hasImport = false;
        Boolean hasExport = false;

        if (!customClearances.isEmpty()) {
            for (Custom_Clearance__c cc : customClearances) {
                if (Constants.CC_AIR_EXPORT_RT.equals(cc.RecordType.DeveloperName)
                        || Constants.CC_INLAND_EXPORT_RT.equals(cc.RecordType.DeveloperName)
                        || Constants.CC_OCEAN_EXPORT_RT.equals(cc.RecordType.DeveloperName)) {
                    hasExport = true;
                }

                if (Constants.CC_AIR_IMPORT_RT.equals(cc.RecordType.DeveloperName)
                        || Constants.CC_OCEAN_IMPORT_RT.equals(cc.RecordType.DeveloperName)
                        || Constants.CC_INLAND_IMPORT_RT.equals(cc.RecordType.DeveloperName)) {
                    hasImport = true;
                }
            }
        }

        return ((hasExport && hasImport) ? 3 : (hasExport ? 2 : (hasImport ? 1 : 0)));
    }
}