trigger PE_Delete_Leads on Delete_Lead__e (after insert) {
    
    system.debug('After Insert');
    if(trigger.isAfter && trigger.isInsert){
        //PE_Invoice_Approval_Helper.submitForApproval(trigger.new);
        PE_Delete_Lead_elper.deleteLeadRecords(trigger.new);
    }

}