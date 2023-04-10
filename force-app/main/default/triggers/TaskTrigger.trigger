trigger TaskTrigger on Task (before update, after insert) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Task');
    system.debug('triggerConfig:: ' + triggerConfig);

    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        TaskTriggerHelper handlerInstance = TaskTriggerHelper.getInstance();
        
        if(trigger.isBefore && trigger.isUpdate){
           // handlerInstance.beforeUpdate(trigger.newMap, trigger.oldMap);
        }
         if(trigger.isAfter && trigger.isInsert){
            handlerInstance.afterInsert(trigger.new);
        }
    }
}