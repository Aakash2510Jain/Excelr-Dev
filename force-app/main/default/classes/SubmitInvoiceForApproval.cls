public class SubmitInvoiceForApproval {
    public static void submitForApproval(Set<Id> opportunityIds){
        
        if(!opportunityIds.isEmpty()){
            Map<Id,Invoice__c> invoiceRecordById  = new Map<Id,Invoice__c>([Select Id,Opportunity__r.Owner.UserRoleId, Opportunity_s_Manager__c From Invoice__c where Opportunity__C in : opportunityIds And Status__c = 'Initiated' order by CreatedDate Desc limit 1]);
            if(!invoiceRecordById.isEmpty()){
                for(Invoice__c invoiceRec : invoiceRecordById.values()){
                    
                    Id approverId;
                    String userRoleId;
                    Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
                    Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
                    
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting for Manager Approval post Payment is done');
                    approvalRequest.setObjectId(invoiceRec.Id);
                    approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
                    userRoleId = invoiceRec.Opportunity__r.Owner.UserRoleId;
                    if(invoiceRec.Opportunity_s_Manager__c != null){
                        approverId = invoiceRec.Opportunity_s_Manager__c;
                    }
                    else{
                        approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                    }
                    approvalRequest.setNextApproverIds(new List<Id> {approverId});
                    cdToapprovalRequestMap.put(invoiceRec.Id, approvalRequest);
                    
                    if(!cdToapprovalRequestMap.isEmpty())
                        List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                    
                } 
            }
            
        }
    }
}