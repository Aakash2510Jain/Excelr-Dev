trigger AGMTrigger on Assignment_Group_Member__c (before update,after update, after insert, after delete,before delete) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('AGM');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        AGMTriggerHelper handlerInstance = AGMTriggerHelper.getInstance();
        
        if (trigger.isUpdate && trigger.isbefore){
            //Validate max lead per day from AGM to max lead per month on User
            // handlerInstance.beforeUpdate(Trigger.newMap, trigger.oldMap);
        }
        if (trigger.isUpdate && trigger.isafter) {
            handlerInstance.reassignAssignmentAfterDeactivation( trigger.oldMap, Trigger.newMap);
        }
        if (trigger.isafter && trigger.isInsert){
            handlerInstance.afterInsert(Trigger.newMap, trigger.oldMap);
        }
        if(trigger.isafter && trigger.isDelete){
            system.debug('After Delete');
            handlerInstance.afterDelete( trigger.oldMap);
        }
        
    }
}