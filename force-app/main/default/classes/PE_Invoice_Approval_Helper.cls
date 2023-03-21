public class PE_Invoice_Approval_Helper {
    public static void submitForApproval(List<Invoice_Approval__e> invoiceApprovalList){
        Set<Id> opportunityIds = new Set<Id>();
        
        if(!invoiceApprovalList.isEmpty()){
            for(Invoice_Approval__e invoiceApprovalRec : invoiceApprovalList){
                if(!String.isEmpty(invoiceApprovalRec.Invoice_Id__c)){
                    opportunityIds.add(invoiceApprovalRec.Invoice_Id__c);
                }
            }
            if(!opportunityIds.isEmpty()){
                SubmitInvoiceForApproval.submitForApproval(opportunityIds);
            }
        }
    }
}