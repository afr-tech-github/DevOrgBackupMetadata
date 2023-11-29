({
    insertBillings: function (cmp, MeiList) {
        var thisHelper = this;
        var cloneCmp = cmp;
        var action = cloneCmp.get("c.insert1MeiData");
        console.log("MeiList: ", MeiList);

        for (var i = 0; i < MeiList.length; i++) {
            var b = MeiList[i];

            window.setTimeout(
                $A.getCallback(function () {
                    thisHelper.insertOneBilling(action, b);
                }), i * 10000
            );
        }
    },
    insertOneBilling: function (action, billing) {
        console.log(billing);
        action.setParams({ meiDataJson: JSON.stringify(billing) });
        $A.enqueueAction(action);
    }
})