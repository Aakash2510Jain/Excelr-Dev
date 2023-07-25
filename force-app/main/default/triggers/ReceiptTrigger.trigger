trigger ReceiptTrigger on Receipt__c (after update, before update) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Receipt');
    system.debug('triggerConfig:: ' + triggerConfig);
    system.debug('Inside Receipt Trigger');
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        ReceiptTriggerHelper handlerInstance = ReceiptTriggerHelper.getInstance();
        
        if(trigger.isAfter && trigger.isUpdate){
            system.debug('After Update of Receipt');
            handlerInstance.afterUpdate(trigger.newMap, trigger.oldmap);
           // handlerInstance.handleSecondReceipt(trigger.newMap, trigger.oldmap); 
        }
        if(trigger.isBefore && trigger.isUpdate){
            system.debug('Before Update of Receipt');
            handlerInstance.beforeUpdate(trigger.newMap, trigger.oldmap);
        }
    }
}