trigger ReceiptTrigger on Receipt__c (after update) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Receipt');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        ReceiptTriggerHelper handlerInstance = ReceiptTriggerHelper.getInstance();
        
        if(trigger.isAfter && trigger.isUpdate){
            handlerInstance.afterUpdate(trigger.newMap, trigger.oldmap);
        }
    }
}