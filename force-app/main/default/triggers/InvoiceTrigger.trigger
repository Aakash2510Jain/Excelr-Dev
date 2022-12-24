trigger InvoiceTrigger on Invoice__c(after update ){
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Invoice');
    system.debug('triggerConfig:: ' + triggerConfig);

    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        InvoiceTriggerHelper handlerInstance = InvoiceTriggerHelper.getInstance();

        if (trigger.isafter && trigger.isUpdate){
            handlerInstance.beforeUpdate(trigger.newMap, trigger.oldMap);
        }

        if (trigger.isInsert && trigger.isBefore) {
            handlerInstance.sendforApproval(trigger.new);
        }
    }
}