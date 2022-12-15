({
    onChangeOfSeekLoan : function(component, event, helper) {
        debugger;
        var seekingLoan = event.getSource().get("v.value");
        if(seekingLoan == 'Yes'){
            component.set("v.paymentType", true);
            component.set("v.paymentMode", false);
        }
        if(seekingLoan == 'No'){
            component.set("v.paymentType", false);
            component.set("v.paymentMode", true);
        }
    },
    
    onPaymentTypeChange : function(component, event, helper) {
        debugger;
        var paymentType = event.getSource().get("v.value");
        if(paymentType == 'Full Payment'){
            component.set("v.paymentMode", true);
            component.set("v.loanType", false);
        }
        if(paymentType == 'Partial Payment'){
            component.set("v.loanType", true);
            component.set("v.paymentMode", false);
        }
    },
    onLoanTypeChange : function(component, event, helper) {
        debugger;
        var loanType = event.getSource().get("v.value");
        if(loanType == 'Full Loan'){
            component.set("v.paymentMode", true);
        }
        if(loanType == 'Partial Loan'){
            component.set("v.partialLoanDetail", true);
            component.set("v.paymentMode", false);
        }
    },
    onLoanAmountChange : function(component, event, helper) {
        debugger;
        var loanAmount = event.getSource().get("v.value");
        if(loanAmount > 0){
            component.set("v.paymentMode", true);
        }
    },
    handleOnLoad : function(component, event, helper) {
        debugger;
        var opportunityId = component.get("v.recordId");
        if(opportunityId != ""){
            component.set("v.oppId",opportunityId);
            component.set("v.recordId","");
        }
    },
    
    handleOnSubmit : function(component, event, helper) {
        debugger;
        var oppId = component.get("v.oppId")
        component.set("v.recordId",oppId);
        var action = component.get("c.updatePaymentStatus");
        debugger;
        action.setParams({
            oppId: oppId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Payment Info has been updated',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else{
                debugger;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Some error occured',
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
    },
    
    handleOnSuccess : function(component, event, helper) {
       
    },
    
    handleOnError : function(component, event, helper) {
        
    },
    
})