({	doInit : function(component, event, helper) {
		helper.initialization(component, event);
	},
	onLoad: function (c, e, h) {
		try {
			var eventParams = e.getParams();
			if(eventParams.changeType === "LOADED") {
			} else if(eventParams.changeType === "CHANGED") {
				// record is changed
			} else if(eventParams.changeType === "REMOVED") {
				// record is deleted
			} else if(eventParams.changeType === "ERROR") {
				// there’s an error while loading, saving, or deleting the record
				console.error(JSON.parse(JSON.stringify(c.get('v.recordLoadError'))));
			}
		}
		catch (ex) {
			console.error(ex);
		}
	},

	doCalculateQuantity: function (c, e, h) {
		try {
			h.invokeActionAsync(c, h, 'c.updateWoProdFinalQtyFromWos', { setWoIds: [c.get('v.recordId')] }).then($A.getCallback(function(result) {
				$A.get('e.force:showToast').setParams({ type: 'success', message: 'Information updated successfully'}).fire();
				$A.get('e.force:refreshView').fire();
			}));
		}
		catch (ex) {
			console.error(ex);
		}
	}, 

	doSyncFromPo: function (c, e, h) {
		try {
			h.invokeActionAsync(c, h, 'c.sync_WoProd_Po', { setWoIds: [c.get('v.recordId')], directionToWo: true }).then($A.getCallback(function(result) {
				$A.get('e.force:showToast').setParams({ type: 'success', message: 'Information updated successfully'}).fire();
				$A.get('e.force:refreshView').fire();
			}));
		}
		catch (ex) {
			console.error(ex);
		}
	},

	doSyncToPo: function (c, e, h) {
		try {
			h.invokeActionAsync(c, h, 'c.sync_WoProd_Po', { setWoIds: [c.get('v.recordId')], directionToWo: false }).then($A.getCallback(function(result) {
				$A.get('e.force:showToast').setParams({ type: 'success', message: 'Information updated successfully'}).fire();
				$A.get('e.force:refreshView').fire();
			}));
		}
		catch (ex) {
			console.error(ex);
		} 
	},

	doSyncFromSo: function (c, e, h) {
		try {
			h.invokeActionAsync(c, h, 'c.sync_WoProd_So', { setWoIds: [c.get('v.recordId')], directionToWo: true }).then($A.getCallback(function(result) {
				$A.get('e.force:showToast').setParams({ type: 'success', message: 'Information updated successfully'}).fire();
				$A.get('e.force:refreshView').fire();
			}));
		}
		catch (ex) {
			console.error(ex);
		}
	},
	
	doSyncToSo: function (c, e, h) {
		try {
			h.invokeActionAsync(c, h, 'c.sync_WoProd_So', { setWoIds: [c.get('v.recordId')], directionToWo: false }).then($A.getCallback(function(result) {
				$A.get('e.force:showToast').setParams({ type: 'success', message: 'Information updated successfully'}).fire();
				$A.get('e.force:refreshView').fire();
			}));
		}
		catch (ex) {
			console.error(ex);
		}
	},
})