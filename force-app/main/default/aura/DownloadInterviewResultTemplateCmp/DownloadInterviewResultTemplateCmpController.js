({
    doInit : function(component, event, helper) {
        var action=component.get('c.getpAppList');   
        action.setParams({
            programId : component.get("v.recordId"),
        })
        action.setCallback(this,function(response){   
            if(response.getState()=='SUCCESS'){
                component.set("v.pApplist",response.getReturnValue());                
            }
        });
        $A.enqueueAction(action); 
    },
    
    downloadFormat : function(component, event, helper){
        
        var csvMetaData = component.get("v.uploadCSVFileFormat");  
        var recordsList = component.get("v.pApplist");
        var csv = helper.convertArrayToCSV(component, csvMetaData, recordsList);    
        if (csv == null){return;}
        
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'UploadInterviewResultFormat.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
        
    }
})