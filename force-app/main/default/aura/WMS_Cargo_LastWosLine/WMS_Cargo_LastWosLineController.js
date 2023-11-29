({
	onInit : function(c, e, h) {

		h.invokeActionAsync(c, h, 'c.getWosLines', { cargoId: c.get('v.recordId') })
			.then($A.getCallback(function(result) {
				if (result != null && result.length > 0) {
					c.set('v.objWosLine', result[0]);
				}
			}))
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	},
})