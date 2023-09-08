({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getCurrentProgramRecord");
        action.setParams({
            programId : component.get("v.prgrmId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.prgrm", data);
               // if(data.Stage__c != 'Completed'){
               //     showComponent = true;
               // }
            }
            
        });
        $A.enqueueAction(action);
	},
    
     
    hideQuickAction :  function(component, event, helper) {
         debugger;
          var dismissActionPanel = $A.get("e.force:closeQuickAction");
           dismissActionPanel.fire();   
    },
    handleSave : function(component, event, helper) {
        debugger;
        
         let  program = component.get("v.prgrm");
         console.log('JSON STRINGIFY----->',JSON.stringify(program));
        
        if(program.Aptitude_Test_Date_Time__c != null && program.GD_Date_Time__c != null && program.Personal_Interview_Date_Time__c != null ){
            
        var action = component.get("c.updateProgramTask");
        action.setParams({
            prgrm :component.get("v.prgrm"),
            taskId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result === 'no Prods'){
                    helper.showToastEvent(component, event, 'ERROR', 'Please add Program Products first!', 'error');
                }
                else if(result === 'success'){
                    helper.showToastEvent(component, event, 'SUCCESS', 'Program Updated Successfully !', 'success');
                    helper.hideQuickAction(component, event, helper);
                    
                    /*$A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                    /*var hideMethod = component.get('c.hideQuickAction');
                    $A.enqueueAction(hideMethod);*/
                }
                else{
                     helper.showToastEvent(component, event, 'ERROR', result, 'error');
                }
            } 
            else{
                $A.get('e.force:refreshView').fire();
            }
            
        });       
            $A.enqueueAction(action);
        }else{
            window.alert('Aptitude GD Personal Datetime are Mandatory');
        }
    }    
    
})