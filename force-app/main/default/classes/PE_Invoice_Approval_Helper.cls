public class PE_Invoice_Approval_Helper {
    public static void submitForApproval(List<Invoice_Approval__e> invoiceApprovalList){
        Set<Id> invoiceIds = new Set<Id>();
        
        if(!invoiceApprovalList.isEmpty()){
            for(Invoice_Approval__e invoiceApprovalRec : invoiceApprovalList){
                if(!String.isEmpty(invoiceApprovalRec.Invoice_Id__c)){
                    invoiceIds.add(invoiceApprovalRec.Invoice_Id__c);
                }
            }
            if(!invoiceIds.isEmpty()){
                SubmitInvoiceForApproval.submitForApproval(invoiceIds);
            }
        }
    }
}