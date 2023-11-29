/**
 * Created by khanhpham on 5/21/17.
 */

public with sharing class PurchasingOrderExt {
    private PurchasingOrder__c purchasingOrder;
    public transient List<WorkProgressItemWrapper> workProgressItems { get; private set; }
    private Map<String, Integer> mapStatusPosition;
    private Integer currentStatusPosition;

    public PurchasingOrderExt(ApexPages.StandardController controller) {
        controller.addFields(new List<String>{
                Constants.NAMESPACE + 'Status__c', Constants.NAMESPACE + 'TotalUnpaidBalance__c', Constants.NAMESPACE + 'TotalUnpaidBalanceLocal__c'
        });

        if (PermissionValidationUtil.isAccessiblePurchasingOrder()) {
            purchasingOrder = (PurchasingOrder__c) controller.getRecord();
            setupWorkProgress();
        }
    }

    private void setupWorkProgress() {
        List<String> statusList = getPurchasingOrderStatuses();
        mapStatusPosition = new Map<String, Integer>();
        Integer position = 0;

        for (String status : statusList) {
            mapStatusPosition.put(status, position++);
        }

        if (mapStatusPosition.containsKey(purchasingOrder.Status__c)) {
            currentStatusPosition = mapStatusPosition.get(purchasingOrder.Status__c);
        }

        workProgressItems = new List<WorkProgressItemWrapper>();
        Boolean hasInCompletedStep = false;
        hasInCompletedStep = addRegistrationStep(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addConfirmationStep(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addPaymentProcessingStep(workProgressItems, hasInCompletedStep);
        hasInCompletedStep = addPaymentSettleStep(workProgressItems, hasInCompletedStep);
    }

    private Boolean addRegistrationStep(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        List<String> inProgressStatuses = new List<String>{};
        List<String> completedStatuses = new List<String>{'Registered'};

        return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, null, 'Registation');
    }

    private Boolean addConfirmationStep(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        List<String> inProgressStatuses = new List<String>{};
        List<String> completedStatuses = new List<String>{'Confirmed'};

        return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, null, 'Confirmation');
    }

    private Boolean addPaymentProcessingStep(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        List<String> inProgressStatuses = new List<String>{'Payment Processing'};
        List<String> completedStatuses = new List<String>{'Payment Settled'};

        return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, null, 'Payment Processing <br/>'
                + (NumbericUtils.formatNumberByLocale(purchasingOrder.TotalUnpaidBalanceLocal__c, 'vi', true, null)) + 'đ' + ' &amp; $'
                + (NumbericUtils.formatNumberByLocale(purchasingOrder.TotalUnpaidBalance__c, 'vi', false, null)));
    }

    private Boolean addPaymentSettleStep(List<WorkProgressItemWrapper> workProgressItems, Boolean hasInCompletedStep) {
        List<String> inProgressStatuses = new List<String>{};
        List<String> completedStatuses = new List<String>{'Payment Settled'};

        return addStatusBasedSteps(currentStatusPosition, inProgressStatuses, completedStatuses, hasInCompletedStep, null, 'Payment Settled');
    }

    private List<String> getPurchasingOrderStatuses() {
        List<String> statusList = new List<String>();
        statusList.add('Registered');
        statusList.add('Confirmed');
        statusList.add('Payment Processing');
        statusList.add('Payment Settled');

        return statusList;
    }

    private Boolean addStatusBasedSteps(Integer currentStatusPosition, List<String> inProgressStatuses, List<String> completedStatus, Boolean hasInCompletedStep, String openUrl, String caption) {
        if (hasInCompletedStep) {
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_INCOMPLETE, openUrl, caption, null, null));
        } else if (isCurrentStep(inProgressStatuses, completedStatus, currentStatusPosition)) {
            markPreviousStepsCompleted(workProgressItems);
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_CURRENT, openUrl, caption, null, null));
            hasInCompletedStep = true;
        } else if (isCompletedStep(completedStatus, currentStatusPosition)) {
            markPreviousStepsCompleted(workProgressItems);
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_COMPLETE, openUrl, caption, null, null));
        } else {
            workProgressItems.add(new WorkProgressItemWrapper('dummy', Constants.WORK_PROGRESS_INCOMPLETE, openUrl, caption, null, null));
            hasInCompletedStep = true;
        }

        return hasInCompletedStep;
    }

    private Boolean isCurrentStep(List<String> inProgressStatuses, List<String> completedStatuses, Integer currentStatusPosition) {
        if (inProgressStatuses == null || inProgressStatuses.isEmpty()) {
            return false;
        }

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
}