trigger PE_Invoice_Approval on Invoice_Approval__e (after insert) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('PEInvoiceApproval');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        PE_Invoice_Approval_Helper handlerInstance = PE_Invoice_Approval_Helper.getInstance();
        
        system.debug('After Insert');
        if(trigger.isAfter && trigger.isInsert){
            handlerInstance.submitForApproval(trigger.new);
        }
    }
}