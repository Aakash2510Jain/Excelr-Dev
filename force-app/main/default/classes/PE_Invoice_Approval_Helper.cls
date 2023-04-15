public without sharing class PE_Invoice_Approval_Helper {
    static PE_Invoice_Approval_Helper handlerInstance;
    public static PE_Invoice_Approval_Helper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new PE_Invoice_Approval_Helper();
        return handlerInstance;
    }
    public void submitForApproval(List<Invoice_Approval__e> invoiceApprovalList){
        Set<Id> opportunityIds = new Set<Id>();
        
        if(!invoiceApprovalList.isEmpty()){
            for(Invoice_Approval__e invoiceApprovalRec : invoiceApprovalList){
                if(!String.isEmpty(invoiceApprovalRec.Invoice_Id__c)){
                    opportunityIds.add(invoiceApprovalRec.Invoice_Id__c);
                }
            }
            system.debug('opportunityIds--->'+opportunityIds);
            if(!opportunityIds.isEmpty()){
                SubmitInvoiceForApproval.submitForApprovalforReceipt(opportunityIds);
            }
        }
    }
}