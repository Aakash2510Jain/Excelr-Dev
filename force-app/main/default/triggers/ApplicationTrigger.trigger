trigger ApplicationTrigger on Application__c (after insert) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Application');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
         ApplicationTriggerHelper handlerInstance = ApplicationTriggerHelper.getInstance();
        
        if (trigger.isInsert && trigger.isBefore){
        }
        if (trigger.isInsert && trigger.isAfter){
            handlerInstance.afterInsert(Trigger.new);
        }
        if (trigger.isUpdate && trigger.isBefore){            
        }
        if (trigger.isUpdate && trigger.isAfter){
        }
    }
}