public class SubmitInvoiceForApproval {
    public static void submitForApproval(Set<Id> invoiceIds){
       List<Invoice__c> invoiceist = new List<Invoice__c>();
        
        if(!invoiceIds.isEmpty()){
            Map<Id,Invoice__c> invoiceRecordById  = new Map<Id,Invoice__c>([Select Id,Opportunity__r.Owner.UserRoleId, Opportunity_s_Manager__c From Invoice__c where Id in:invoiceIds]);
            
            for(Id invoiceId : invoiceIds){
                
                Id approverId;
                String userRoleId;
                Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
                Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
                
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitting for Manager Approval');
                approvalRequest.setObjectId(invoiceId);
                approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
                if(invoiceRecordById.containsKey(invoiceId)){
                    userRoleId = invoiceRecordById.get(invoiceId).Opportunity__r.Owner.UserRoleId;
                    if(invoiceRecordById.get(invoiceId).Opportunity_s_Manager__c != null){
                        approverId = invoiceRecordById.get(invoiceId).Opportunity_s_Manager__c;
                    }
                    else{
                        approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                    }
                    approvalRequest.setNextApproverIds(new List<Id> {approverId});
                    cdToapprovalRequestMap.put(invoiceId, approvalRequest);
                    
                    if(!cdToapprovalRequestMap.isEmpty())
                        List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                    
                }
                /*  else if(invoiceRec.Opportunity__c != null ){
                    userRoleId = invoiceRec.Opportunity__r.Owner.UserRoleId;
                    if(invoiceRec.Opportunity__r.Owner.managerid != null){
                        approverId = invoiceRec.Opportunity__r.Owner.managerid;
                    }
                    else{
                        approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                    }
                } */
            }
        }
    }
}