({
	onInit : function(c, e, h) {
		h.getWorkOrderStatus(c);		
		h.getWorkOrderWarehouseId(c);		
	},

	handleLocatorChange: function (c, e) {
		c.set(e.getParam('ref'), e.getParam('value'));
		if (!e.getParam('value')) {
			return;
		}
		let workerId = e.getParam('record').MainOperator__c;
		if (!workerId) {
			return;
		}
		console.log(workerId);
		c.get('v.parent').addWorker(workerId);
	}
})