trigger InvoiceTrigger on Invoice__c(after update, before insert,After insert,before update ){
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Invoice');
    system.debug('triggerConfig:: ' + triggerConfig);
    system.debug('Inside Invoice Trigger');
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        InvoiceTriggerHelper handlerInstance = InvoiceTriggerHelper.getInstance();
        
        if (trigger.isafter && trigger.isUpdate){
            handlerInstance.afterUpdate(trigger.newMap, trigger.oldMap);
            //handlerInstance.sendReferralFormViaEmail(trigger.oldMap, trigger.newMap);
        }
 
        if (trigger.isbefore && trigger.isUpdate) {
            handlerInstance.beforeUpdate(trigger.newMap, trigger.oldMap);
        }
    }
}