({
	onInit : function(c, e, h) {
		if (c.get('v.recordId') != null) {
			h.getInfo(c,h);
		}
	},

	onWarehouse_Changed: function (c,e,h) {
		h.getInfo(c,h);
	},

	doCreateWorkOrder: function (c,e,h) {
		$A.get("e.force:createRecord")
		    .setParams({
				"entityApiName": "clofor_com_cfs__WorkOrder__c",
				"recordTypeId": c.get('v.recordTypeId'),
				"defaultFieldValues": {
					'RecordTypeId' : c.get('v.recordTypeId'),
			        'clofor_com_cfs__WarehouseID__c' : c.get('v.warehouseId'),
			        'clofor_com_cfs__DestinationWarehouse__c' : e.getSource().get("v.name")
			    }
		    })
		    .fire();
	},

	doCombineService: function (c,e,h) {
		h.invokeActionAsync(c, h, 'c.combineService', {
				recordId: c.get('v.recordId'),
				payload: c.get('v.listDestinations')[0].records
					.filter(function (item) {
						return item.isSelected == true && item.isDisabled != true;
					})
					.map(function (item) {
						return item.Id;
					})
			})
			.then(function(result) {
				$A.get('e.force:refreshView').fire();
			})
			.catch(function(ex) {
				$A.get("e.force:showToast").setParams({ message: ex, type: "error" }).fire();
			});
	}
})