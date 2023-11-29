({
	onInit : function(c, e, h) {
		h.invokeActionAsync(c, h, 'c.getInfo', { recordId: c.get('v.recordId') })
			.then($A.getCallback(function(result) {
				c.set('v.entWorkOrder', result.workOrder);
				c.set('v.picklistStatus', result.picklistStatus);
                c.set('v.picklistWorker', result.picklistWorker);

				var mapRecordTypes = {};
				result.serviceRecordTypes.forEach(function (item) { mapRecordTypes[item.DeveloperName] = item; });
				c.set('v.mapRecordTypes', mapRecordTypes);

				try {
					h.createTemplateMassive(c);
				}
				catch(ex) {
					console.error(ex);
				}
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},
    handleLoad : function(component, event, helper) {
	}
})