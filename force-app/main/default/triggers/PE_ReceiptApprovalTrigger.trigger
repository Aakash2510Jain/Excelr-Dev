trigger PE_ReceiptApprovalTrigger on Receipt_Approval__e (after insert) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('PE_Receipt_Approval');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        PE_ReceiptApprovalTriggerHelper handlerInstance = PE_ReceiptApprovalTriggerHelper.getInstance();
        
        if(trigger.isAfter && trigger.isInsert){
            handlerInstance.afterInsert(trigger.new);
        }
    }
}