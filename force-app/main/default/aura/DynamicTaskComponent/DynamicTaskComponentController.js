({
    doInit : function(component, event, helper) {
        debugger;
        var compName = '';
        var recordId = component.get("v.recordId");
        var action = component.get("c.getCurrentTaskRecord");
        action.setParams({ 
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                if(responseValue.Component_Name__c === undefined){
                    var dismissMethod = component.get('c.dismissPopUp');
                    $A.enqueueAction(dismissMethod);
                }
                else{
                    compName = 'c:'+responseValue.Component_Name__c;
                    var relatedRecordId= responseValue.WhatId;
                    var comp = compName;
                    $A.createComponent(
                        comp,{recordId : component.get("v.recordId"), prgrmId : relatedRecordId,status :responseValue.Status} ,
                        function(lwcCmp, status, errorMessage) {
                            if (status === "SUCCESS") {
                                var body = component.get("v.body");
                                body.push(lwcCmp);
                                component.set("v.body", body);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.");
                            }
                            else if (status === "ERROR") {
                                console.error("Error: " + errorMessage);
                            }
                        }
                    );
                }
            } 
        });
        $A.enqueueAction(action);        
    },
    
    dismissPopUp : function(component){
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'No such components found!!',
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'pester'
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
        
        var dismissPanel = $A.get("e.force:closeQuickAction");
        dismissPanel.fire();
    }
})