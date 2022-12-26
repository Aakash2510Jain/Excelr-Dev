({
	doInit : function(component, event, helper) {
		debugger;
        component.set("v.siteURL", 'https://excelr2--dev--c.sandbox.vf.force.com/apex/RetailInvoice_Attachment?Id=' +component.get("v.recordId"));
	},
    SavePdf: function(component, event, helper) {
         var action = component.get("c.convertLead");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
              var Data = response.getReturnValue();   
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Invoice pdf downloaded Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Some error Occured',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        
        $A.enqueueAction(action);	
    }    
})