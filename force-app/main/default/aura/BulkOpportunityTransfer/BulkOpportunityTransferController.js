({
    init: function(component, event, helper) {
        // Fetch the list of opportunities for dual listbox
        helper.fetchOpportunities(component);
    },
    
    handleUserSearchChange: function(component, event, helper) {
        // Get the search term entered by the user
        var searchTerm = component.find("userSearch").get("v.value");
        
        // Fetch the list of users based on the search term
        helper.fetchUsers(component, searchTerm);
    },
    
    selectUser: function(component, event, helper) {
        // Get the selected user from the click event
        var selectedUserId = event.currentTarget.dataset.userid;
        
        // Set the selected user in the component attribute
        component.set("v.selectedUser", selectedUserId);
    },
    
    assignOpportunities: function(component, event, helper) {
        // Get the selected opportunity IDs and the selected user
        var selectedOpportunityIds = component.get("v.selectedOpportunityIds");
        var selectedUser = component.get("v.selectedUser");
        
        // Validate that at least one opportunity is selected and a user is chosen
        if (selectedOpportunityIds.length > 0 && selectedUser) {
            // Call a helper method to assign the opportunities to the selected user
            helper.assignOpportunitiesToUser(component, selectedOpportunityIds, selectedUser);
        } else {
            // Display an error message if required data is missing
            // You can customize this based on your requirements
            alert("Please select at least one opportunity and a user to assign.");
        }
    }
})