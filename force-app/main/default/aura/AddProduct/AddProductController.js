({
    doinit : function(component, event, helper) {
        var action=  component.get('c.getAllData'); 
        action.setCallback(this,function(response){
            var state=response.getState();            
            if(state==='SUCCESS')
            {
                debugger;
                
                console.log(response.getReturnValue());
                
                component.set("v.type",response.getReturnValue().pickValByField.Type__c);
                component.set("v.mode",response.getReturnValue().pickValByField.Mode__c);
                component.set("v.city",response.getReturnValue().pickValByField.City__c);
            }            
        });
        $A.enqueueAction(action);
    },
    onModeChange : function(component, event, helper) {
        debugger;
        var selectedValue= event.getSource().get("v.value");
        console.log(selectedValue);
        if(selectedValue == 'Classroom'){
            component.set("v.modeClassroom",true);
        }else{
            component.set("v.modeClassroom",false);
        }
    },
    onTypeChange : function(component, event, helper) {
        debugger;
        var selectedValue= event.getSource().get("v.value");
        console.log(selectedValue);
        if(selectedValue == 'Combo'){
            component.set("v.typeCombo",true);
            component.set("v.typeSingle",false);
        }else{
            component.set("v.typeCombo",false);
            component.set("v.typeSingle",true);
        }
    },
    
})