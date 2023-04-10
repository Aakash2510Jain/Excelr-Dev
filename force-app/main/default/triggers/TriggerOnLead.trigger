trigger TriggerOnLead on Lead (before insert, After Insert, Before Update, After Update){
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Lead');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        LeadTriggerHandler handlerInstance = LeadTriggerHandler.getInstance();
        
        if (trigger.isInsert && trigger.isBefore){
            handlerInstance.beforeInsert(Trigger.new );
        }
        if (trigger.isInsert && trigger.isAfter){
            LeadAssignmentExecutionCriteria.validateEntryCriteria();
            handlerInstance.afterInsert(Trigger.new);
            
        }
        
        if (trigger.isUpdate && trigger.isBefore){
            handlerInstance.beforeUpdate(Trigger.newMap, trigger.oldMap);
            
        }
        if (trigger.isUpdate && trigger.isAfter){
            handlerInstance.afterUpdate(Trigger.newMap, trigger.oldMap);
        }
    }
}