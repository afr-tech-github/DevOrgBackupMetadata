({
    init: function (cmp, event, helper) {
        console.log('init MassEditQuote');
        //helper.initData(cmp);

        var getRecordTypeId = cmp.get("c.getRecordTypeId");

        getRecordTypeId.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.recordTypeId', response.getReturnValue() || '');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors);
            }
        });
        $A.enqueueAction(getRecordTypeId);

        var getDescribeSobjectResult = cmp.get("c.getDescribeSobjectResult");

        getDescribeSobjectResult.setCallback(this, function (response) {
            var state = response.getState();
            console.log('getDescribeSobjectResult: ', response);
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var resArr = res.split('_');
                console.log('getDescribeSobjectResult: ', res);
                if(resArr.length == 4){
                    cmp.set('v.isCreateable', resArr[0] == 'true');
                    cmp.set('v.isUpdateable', resArr[1] == 'true');
                    cmp.set('v.isAccessible', resArr[2] == 'true');
                    cmp.set('v.isDeletable', resArr[3] == 'true');
                }
                helper.initData(cmp);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + errors);
            }
        });
        $A.enqueueAction(getDescribeSobjectResult);
    },
    onUpdateFieldChange: function (cmp, event, helper) {
        var value = event.getSource().get('v.value');
        var fieldName = event.getSource().get('v.fieldName');
        // var changedFields = [{ 'key': fieldName, 'value': value }];
        var changedFields = JSON.parse(JSON.stringify(cmp.get('v.changedFields'))) || [];
        var existedField = changedFields.find(x => x.key == fieldName);
        if (existedField) {
            existedField.value = value;
        } else {
            changedFields.push({ 'key': fieldName, 'value': value });
        }
        console.log('changedFields: ', changedFields);
        cmp.set('v.changedFields', changedFields);
    },
    onUnselectAll: function (cmp, event, helper) {
        helper.onToggleSelect(cmp, false);
    },
    onSelectAll: function (cmp, event, helper) {
        helper.onToggleSelect(cmp, true);
    },
    resetUpdate: function (cmp, event, helper) {
        cmp.set('v.showMassUpdateRow', false);
        cmp.set('v.showMassUpdateRow', true);
        cmp.set('v.changedFields', []);
    },
    onUpdate: function (cmp, event, helper) {
        //console.log('MASS UPDATE');
        // var cmps = cmp.find('massEditBillingItem'), formattedCmps = [];
        var changedFields = cmp.get('v.changedFields') || [];

        console.log('onUpdate changedFields: ', changedFields);

        helper.onSave(cmp, changedFields);
        /*if(!cmps) return;
        if ($A.util.isArray(cmps)) {
            formattedCmps = cmps;
        } else {
            formattedCmps = [cmps];
        }
        
        for(var i=0; i < formattedCmps.length; i++){
            formattedCmps[i].updateFields(changedFields);
        }
        */
        cmp.set('v.showMassUpdateRow', false);
        cmp.set('v.showMassUpdateRow', true);
        cmp.set('v.changedFields', []);
    },
    onSaveAll: function (cmp, event, helper) {
        var changedFields = cmp.get("v.changedFields");
        helper.onSave(cmp,changedFields);
    },
    onAdd: function (cmp, event, helper) {
        helper.onToggleSpinner(cmp);
    },
    onSuccess: function (cmp, event, helper) {
        helper.onToggleSpinner(cmp);
        cmp.set('v.numberOfDisplayRecord', cmp.get('v.numberOfDisplayRecord') + 1);
        var record = event.getParam("response");
        //TODO: check first record here
        helper.createComponent(cmp, { Id: record.id }, false);
        cmp.set('v.showForm', false);
        cmp.set('v.showForm', true);
    },
    onError: function (cmp, event, helper) {
        helper.onToggleSpinner(cmp);
        var error = event.getParams();
        console.log("error: ", JSON.stringify(error));

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: "error",
            message: error.detail || error.message
        });
        toastEvent.fire();
    },
    changeNumberOfDisplayRecord: function (cmp, event, helper) {
        var numberOfDisplayRecord = cmp.get('v.numberOfDisplayRecord');
        console.log('numberOfDisplayRecord: ', numberOfDisplayRecord);
        cmp.set('v.overflowY', numberOfDisplayRecord >= 8);
    },
    onDelete: function (cmp, event, helper) {
        cmp.set('v.numberOfDisplayRecord', cmp.get('v.numberOfDisplayRecord') - 1);
    },
    // onClone: function(cmp, event, helper){
    //     console.log('o day khong log');
    //     console.log('jgjgjgjgjg');
    //     helper.onRefresh1(cmp);

    // },
    onRefresh: function (cmp, event, helper) {
        var cmps = cmp.find('massUpdateBillingItem');
        if ($A.util.isArray(cmps)) {
            for (var i = 0; i < cmps.length; i++) {
                cmps[i].set('v.isShow', false);
            }
        } else {
            cmps.set('v.isShow', false);
        }

        cmp.set('v.isShowTable', false);
        cmp.set('v.body', []);
        cmp.set('v.isShowTable', true);
        helper.initData(cmp);
    },
    onChangeMultiCurrency: function(cmp, event, helper) {
        helper.onToggleMultiCurrency(cmp, cmp.get('v.isMultiCurrency'));
        console.log('isMultiCurrency'+ cmp.get('v.isMultiCurrency'));
    }
})