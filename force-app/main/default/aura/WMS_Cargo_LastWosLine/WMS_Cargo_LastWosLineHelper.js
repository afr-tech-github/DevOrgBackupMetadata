({
	invokeActionAsync : function(c, h, actionName, params) {
		return new Promise($A.getCallback(function(resolve, reject) {
            try {
				c.set('v.isLoading', true);
                var action = c.get(actionName);
				if (params != null) {
	                action.setParams(params);
				}
                action.setCallback(this, function (response) {
					c.set('v.isLoading', false);
                    if (response.getState() !== "SUCCESS") {
						console.log(response.getError()[0].message);
                        if (reject)
                            reject(response.getError()[0].message);
                        else
                            console.log(response.getError()[0].message);
                        return;
                    }

                    if (resolve) {
						console.log(response.getReturnValue());
						resolve(response.getReturnValue());
					}
                });

                $A.enqueueAction(action);
            }
            catch (e) {
                console.log(e);
            }
        }));
	}
})