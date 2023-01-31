({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.fetchUser");   
        action.setCallback(this, function(response) {
            console.log(response.getError());
            if ( response.getState() === "SUCCESS") {  
                var data = response.getReturnValue();
                component.set("v.userList", data); 
                // helper.helpermethod1(component);         
            }
        });
        $A.enqueueAction(action);
    },
     doSave:function(component,event,helper)
    {
        debugger;
       var action=component.get("c.UpdateUser");
        action.setParams({ 
             "maxleadperday":  component.get("v.maxLeadPerDay"),
             "maxleadpermonth":  component.get("v.maxLeadPerMonth") 
        });
          action.setCallback(this,function(response){
            var state=response.getState();     
            if(state==='SUCCESS')
            {               
                var result=response.getReturnValue();
                component.set("v.userList",result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":'success',
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();    
            }
            else
            {
                console.log('Some Error occurred during fetching the data');
            }
           
        });
        $A.enqueueAction(action);
    },
   docancel : function(component, helper, event)
    {
        debugger;
         $A.get("e.force:closeQuickAction").fire(); 
    },
    
})