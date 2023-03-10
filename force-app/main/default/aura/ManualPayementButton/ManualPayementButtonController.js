({
    doInit : function(component, event, helper) {
        debugger;
        var today = new Date();
        component.set("v.todayDate", today.toISOString().slice(0,10));
        helper.getCurrentInoiceRecord(component, event);
    },
    onChangeHandler : function(component, event, helper) {
        debugger
        var enterAmount = component.find('actualamount').get('v.value');
        var desc = component.find('desc').get('v.value');
        var dueAmount = component.get("v.oppAmount") - enterAmount;
        if(enterAmount >  component.get("v.oppAmount")){
            alert("Actual Amount can not be greater then Opportunity Amount");
            component.find('actualamount').set('v.value', 0);
            component.set("v.partialPayment",false);
            component.set("v.dueAmountRemaning", component.get("v.oppAmount"));
            return;
        }
        if(dueAmount >0 ){
            component.set("v.partialPayment",true);
        }
        component.set("v.enteredAmount", enterAmount);
        component.set("v.description", desc);
        component.set("v.dueAmountRemaning", dueAmount);
        
    },
    handleFilesChange: function(component, event, helper) {
        debugger;
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    
    
    Save: function (component, event, helper) {
        debugger;
        component.set("v.disableSave",true);
        if(component.find('actualamount').get('v.value') <=0 || component.find('actualamount').get('v.value') == null || component.find('actualamount').get('v.value') == "" || component.find('actualamount').get('v.value') == "undefined"){
            alert("Please provide the Amount");
            component.set("v.disableSave",false);
            return;
        }
        if(component.find('actualamount').get('v.value') < component.get("v.oppAmount") ){
            if(component.get("v.selectedDate") == null || component.get("v.selectedDate") == "undefined"){
                alert("Please Select a next followup date");
                component.set("v.disableSave",false);
                return;
            }
        }
        if(component.find("fileuplod").get("v.files")== null){
            alert("Please Select a File");
            component.set("v.disableSave",false);
            return;
        }
        var action = component.get("c.insertInvoiceBasedOppAmount");
        action.setParams({
            "insertingInvAmount": component.get("v.enteredAmount"),
            "oppId": component.get("v.recordId"),
            "description" : component.get("v.description"),
            "nextPaymentDueDate" : component.get("v.selectedDate")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'SUCCESS',
                    message: 'Details Saved Successfully !',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var data = response.getReturnValue();
                component.set("v.fileParentId", data.Id);
                let thirdAction = component.get('c.handleSave');
                $A.enqueueAction(thirdAction);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error message',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSave : function(component, event, helper) {
        debugger;
        if (component.find("fileuplod").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
    cancelFile: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        
    },
})