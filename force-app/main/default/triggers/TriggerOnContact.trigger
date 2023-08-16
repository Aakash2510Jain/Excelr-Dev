trigger TriggerOnContact on Contact (before insert) {
    
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Contact');
    system.debug('triggerConfig:: ' + triggerConfig);
    system.debug('Inside Contact Trigger');
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        ContactTriggerHandler handlerInstance = ContactTriggerHandler.getInstance();
        if (trigger.isAfter && trigger.isInsert) {
            handlerInstance.afterCreate(trigger.new);            
        }
    }

}