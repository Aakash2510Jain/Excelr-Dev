({
	doInit  : function(component, event, helper) {
        debugger;
        var action = component.get("c.getLeadDetails");
        action.setParams({
            leadid: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null){
                window.location.href = response.getReturnValue().Lead_URL_to_Redirect__c;
                }else{
                    console.log("No Lead to redirect");
                }
            }
            else {
                console.log("Apex method call failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})