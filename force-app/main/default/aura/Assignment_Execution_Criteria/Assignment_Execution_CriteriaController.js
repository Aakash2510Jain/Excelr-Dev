({
    doInit : function(component, event, helper) {
        
        helper.getPicklistValue(component, event);
        
        var action = component.get('c.checkExercListData');
        $A.enqueueAction(action);
        
    },
    createObjectData : function(component, event, helper) {
        var RowItemList = component.get("v.Exereclst");
        var length = RowItemList.length;
        var tempObj = {'Name' : '','RelatedObject' : component.get("v.objectName"),'FieldName':'','fieldValue' : '','MatchingType' : '','MatchingValue' : '','Sequence' : '','Id' : ''};
        RowItemList.push(tempObj);    
        component.set("v.Exereclst", RowItemList);
        helper.getAllFields(component, event,component.get("v.objectName"),length);
       },
    removeRow : function(component, event, helper) {
      helper.removeExcRow(component, event);    
    },
    checkExercListData : function(component, event, helper){
       component.set("v.spinner",true); 
       var RowItemList = component.get("v.Exereclst");
        if(RowItemList.length === 0){
        	helper.getScoreExecution(component, event);    
        }else{
        	component.set("v.spinner",false);     
        }
    },
    selectObjectName : function(component, event, helper){
        var idx = event.target.name;
    	var a= component.get("v.Exereclst");
        console.log(a);
        var obj= a[idx].RelatedObject;
        helper.getAllFields(component, event, obj, idx);
    },
    saveExecutionCriteria : function(component, event, helper){
     	helper.saveScoreExecution(component, event);   
     },
    selectFieldName : function(component, event, helper){
        debugger;
    	var idx = event.target.name;
        var a= component.get("v.Exereclst");
        var fieldName = a[idx].fieldValue;
    	helper.getMatchingValue(component, event,fieldName,idx);
    },
    // handleChangeforMultiSelectPicklist : function (component, event, helper) {
    //     debugger;
    //     var attrval = component.get('v.Exereclst');
    //     var selectedItem = event.currentTarget;


    //     var index = selectedItem.dataset.record;
    //     var index = event.target.name;
    //     //var index = event.currentTarget.id;

    //     var auridvalue = component.find("valueVal");

    //     var selectedOptionValueForMP = event.getParam("value");
    //     //alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
    //     component.set("v.selectedMultiSelectPickValues",selectedOptionValueForMP); 

    //     var tempplvalues = selectedOptionValueForMP.join(',');
    //         attrval[index].MatchingValue = tempplvalues; 
    //         component.set("v.Exereclst", attrval);
    // },

    handleComponentEvent : function(component, event) { 
        debugger;
        var message = event.getParam("message"); 
        var attrval = component.get('v.Exereclst');
        attrval[message.indextoAdd].MatchingValue = message.multiselectpicklist; 
        component.set("v.Exereclst", attrval);

        
        // set the handler attributes based on event data 
        
        //component.set("v.messageFromEvent", message); 
        
    } 
})