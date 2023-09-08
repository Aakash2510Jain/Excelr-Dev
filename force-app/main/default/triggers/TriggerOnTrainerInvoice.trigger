trigger TriggerOnTrainerInvoice on Trainer_Invoice__c (after update) {
    
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Trainer_Invoice');
    system.debug('triggerConfig:: ' + triggerConfig);
    system.debug('Inside Contact Trigger');
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        TrainerInvoiceTriggerHandler handlerInstance = TrainerInvoiceTriggerHandler.getInstance();
        if (trigger.isAfter && trigger.isUpdate) {
            handlerInstance.afterUpdate(trigger.new, trigger.oldMap);            
        }
    }
    
}