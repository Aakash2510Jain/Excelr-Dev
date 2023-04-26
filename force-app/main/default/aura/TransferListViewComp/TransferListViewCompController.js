({
	doInit : function(component, event, helper) {  
        debugger;
    var myPageRef = component.get("v.pageReference");
        var label = $A.get("$Label.c.AllLead");
        var leads = myPageRef.state.c__listofLeads;
        console.log('listofAccounts', JSON.stringify(leads));
        helper.GetAssignmentgroup(component, event);
         if(leads.length < 1 || leads == ""){
            //alert("Please Select Task")
            helper.showWarning(component, event);
            var navEvent = $A.get("e.force:navigateToList");
             navEvent.setParams({
             "listViewId": label,
             "listViewName": "All Lead",
             "scope": "Lead"
         });
         //toastEvent.fire();
         navEvent.fire();
            
        }
        else{
            var leadsArr = leads.split(',');
            component.set("v.ListofLeads", leadsArr);
            //var AssignmentGroupList = [];
            //component.set("v.isModalOpen", true);
            //split the account ids by comma and continue logic
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                    title: 'Success',
                    message: 'Lead has been Assigned to the Selected Group successFully!!!!!',
                    duration: ' 50',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
             var navEvent = $A.get("e.force:navigateToList");
             navEvent.setParams({
             "listViewId": label,
             "listViewName": "All Lead",
             "scope": "Lead"
         });
         //toastEvent.fire();
         navEvent.fire();
            
        }

        /*var leadsArr = leads.split(',');
        cmp.set("v.ListofLeads", leadsArr);
        //var AssignmentGroupList = [];
        helper.GetAssignmentgroup(cmp, event);
        
        cmp.set("v.isModalOpen", true);*/
        //split the account ids by comma and continue logic
    },
    /* closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        var LeadListView = component.get("v.AllLeadListview");
        component.set("v.isModalOpen", false);
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": LeadListView.Id,
            "listViewName": LeadListView.Name,
            "scope": "Lead"
        });
        navEvent.fire();
    },
    
    submitDetails: function (component, event, helper) {
      debugger;
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
      //  var selectedAssignGroupForJs = component.get("v.SelectedAssignGroup");
        var leadlist = component.get("v.ListofLeads");
          var jsonString = JSON.stringify(leadlist);
        
        var action = component.get('c.getLeadListViewID');
        action.setParams({
            'leadListId' : jsonString
           // SelectedAssignGroup: selectedAssignGroupForJs
        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            var Data = response.getReturnValue();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var serverResponse = response.getReturnValue();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'Lead has been Assigned to the Selected Group successFully!!!!!',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();

                var LeadListView = component.get("v.AllLeadListview");
                component.set("v.isModalOpen", false);
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": LeadListView.Id,
                   "listViewName": LeadListView.Name,
                    "scope": "Lead"
                });
                navEvent.fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },*/
})