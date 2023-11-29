({
	findFieldCmps : function(cmp) {
        var cmps = cmp.find('field'), formattedCmps = [];
        
        if(!cmps) return {};
        if ($A.util.isArray(cmps)) {
            formattedCmps = cmps;
        } else {
            formattedCmps = [cmps];
        }
        return formattedCmps;
	},
	onToggleSpinner: function(cmp){
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})