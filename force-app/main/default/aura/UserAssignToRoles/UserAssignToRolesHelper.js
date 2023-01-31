({
	 helpermethod1: function(component, event, helper) {
        debugger;
        var action = component.get("c.UpdateUser");
        action.setParams({
            "userId": component.get("v.userId"),
             "fname": component.get("v.userList.fName "),
             "lname": component.get("v.userList.lName"),
             "maxleadperday": component.get("v.userList.maxLeadPerDay"),
             "maxleadpermonth": component.get("v.userList.maxLeadPerMonth")
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                component.set("v.userList",data);
            }
                      
        });
        console.log('2nd method is called');
      
    }    
})