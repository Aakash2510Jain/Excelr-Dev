public class PE_ReceiptApprovalTriggerHelper {
    static PE_ReceiptApprovalTriggerHelper handlerInstance;
    
    public static PE_ReceiptApprovalTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new PE_ReceiptApprovalTriggerHelper();
        return handlerInstance;
    }
    
    public void afterInsert(List<Receipt_Approval__e> receiptApprovalList){
        
        Set<Id> opportunityIds = new Set<Id>();
        
        if(!receiptApprovalList.isEmpty()){
            for(Receipt_Approval__e receiptApprovalRec : receiptApprovalList){
                if(!String.isEmpty(receiptApprovalRec.Opportunity_Id__c)){
                    opportunityIds.add(receiptApprovalRec.Opportunity_Id__c);
                }
            }
            system.debug('opportunityIds--->'+opportunityIds);
            if(!opportunityIds.isEmpty()){
                SubmitInvoiceForApproval.submitreceiptForApprovalFromCCavenue(opportunityIds);
            }
        }
    }
}