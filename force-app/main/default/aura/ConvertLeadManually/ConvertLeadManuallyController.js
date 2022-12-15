({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.convertLead");
        action.setCallback(this, function(a){
            //component.set("v.contactRows", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})