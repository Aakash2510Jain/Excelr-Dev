trigger PE_Invoice_Approval on Invoice_Approval__e (after insert) {
    system.debug('After Insert');
    if(trigger.isAfter && trigger.isInsert){
        PE_Invoice_Approval_Helper.submitForApproval(trigger.new);
    }
}