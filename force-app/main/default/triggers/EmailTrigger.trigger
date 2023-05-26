trigger EmailTrigger on EmailMessage (after insert,before insert) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('EmailTrigger');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        EmailTriggerHelper handlerInstance = EmailTriggerHelper.getInstance();
        
        if(trigger.isBefore && trigger.isInsert){
            handlerInstance.AttacheRelated_SetWhatId(trigger.new);
        }
        if(trigger.isAfter && trigger.isInsert){
            handlerInstance.attachEmailToLead(trigger.new);
        }
        
    }
}