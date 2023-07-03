({
    fetchOpportunities: function(component) {
        var action = component.get("c.getOpportunities");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opportunities = response.getReturnValue();
                var opportunityOptions = opportunities.map(function(opportunity) {
                    return { label: opportunity.Name, value: opportunity.Id };
                });
                component.set("v.opportunityOptions", opportunityOptions);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchUsers: function(component, searchTerm) {
        var action = component.get("c.getUsers");
        action.setParams({
            searchTerm: searchTerm
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var users = response.getReturnValue();
                component.set("v.users", users);
            }
        });
        $A.enqueueAction(action);
    },
    
    assignOpportunitiesToUser: function(component, opportunityIds, userId) {
        var action = component.get("c.assignOpportunitiesToUser");
        action.setParams({
            opportunityIds: opportunityIds,
            userId: userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Perform any additional actions or display success message here
                alert("Opportunities assigned successfully!");
                
                // Close the quick action modal
                $A.get("e.force:closeQuickAction").fire();
                
                // Refresh the current list view to reflect the changes
                $A.get("e.force:refreshView").fire();
            } else {
                // Handle any errors returned by the server
                var errors = response.getError();
                console.error("Error assigning opportunities:", errors);
                alert("An error occurred while assigning opportunities. Please try again.");
            }
        });
        $A.enqueueAction(action);
    }
})