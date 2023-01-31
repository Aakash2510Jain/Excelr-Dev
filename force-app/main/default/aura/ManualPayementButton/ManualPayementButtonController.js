({
    doInit : function(component, event, helper) {
        debugger;
        // var action = component.get("c.getPickListValuesMethod");
        // action.setParams({
        //     "ObjectApi_name": 'Invoice__c',
        //     "Field_Name": 'Mode_Terms_of_Payment__c'
        // });
        // action.setCallback(this, function (response) {
        //     var State = response.getState();
        //     if (State === "SUCCESS") {
        //         var data = response.getReturnValue();
        //         component.set("v.pickValues", data);
        //         helper.getCurrentInoiceRecord(component, event);
        //     }
        // });
        // $A.enqueueAction(action);
        helper.getCurrentInoiceRecord(component, event);
    },
    onChangeHandler : function(component, event, helper) {
        debugger
       // var selPick = component.find('field').get('v.value');
        var enterAmount = component.find('actualamount').get('v.value');
        var desc = component.find('desc').get('v.value');
        var dueAmount = component.get("v.oppAmount") - enterAmount;
        
       // component.set("v.pickValueSelected", selPick);
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
        var action = component.get("c.insertInvoiceBasedOppAmount");
        action.setParams({
            "insertingInvAmount": component.get("v.enteredAmount"),
            "oppId": component.get("v.recordId"),
            "description" : component.get("v.description")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.fileParentId", data.Id);
                let thirdAction = component.get('c.handleSave');
                $A.enqueueAction(thirdAction);
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
        alert("Cancel")
    },
})