public class ContentDocumentLinkTrigger {
    
    static ContentDocumentLinkTrigger handlerInstance;
    public static ContentDocumentLinkTrigger getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new ContentDocumentLinkTrigger();
        return handlerInstance;
    }
    
    public void onAfterInsert(List<ContentDocumentLink> cdlList) {
        try{
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Set<ID> parentIds = new Set<ID>();
            
            for ( ContentDocumentLink cdl : cdlList ) {
                parentIds.add( cdl.LinkedEntityId );
            }
            List<Invoice__c> invList = [SELECT Id, LeadInvoice__c, LeadInvoice__r.Payment_Type__c, LeadInvoice__r.Owner.UserRoleId, Opportunity__c, Opportunity__r.Owner.managerid, Opportunity__r.Payment_Type__c, Lead_ManagerId__c, Opportunity__r.Owner.UserRoleId, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Invoice__c WHERE Id IN :parentIds];
            system.debug('invList :: ' + invList);
            
            Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
            
            for (Invoice__c iRec : invList) {
                system.debug('iRec.Opportunity__r.Payment_Type__c--> '+iRec.Opportunity__r.Payment_Type__c);
                if(iRec.Opportunity__r.Payment_Type__c == 'Cash' || iRec.Opportunity__r.Payment_Type__c == 'Cheque' || iRec.Opportunity__r.Payment_Type__c == 'POS' || iRec.Opportunity__r.Payment_Type__c == 'Manual Payment' || iRec.Opportunity__r.Payment_Type__c == 'Full Payment' || iRec.Opportunity__r.Payment_Type__c == '100% Loan'){
                    Id approverId;
                    String userRoleId;
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting for Manager Approval');
                    approvalRequest.setObjectId(iRec.Id);
                    approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
                    if(iRec.LeadInvoice__c != null){
                        userRoleId = iRec.LeadInvoice__r.Owner.UserRoleId;
                        if(iRec.Lead_ManagerId__c != null){
                            approverId = iRec.Lead_ManagerId__c;
                        }
                        else{
                            approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                    }
                    else if(iRec.Opportunity__c != null ){
                        userRoleId = iRec.Opportunity__r.Owner.UserRoleId;
                        if(iRec.Opportunity__r.Owner.managerid != null){
                            approverId = iRec.Opportunity__r.Owner.managerid;
                        }
                        else{
                            approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                    }
                    system.debug('userRoleId -- ' + userRoleId);
                    system.debug('approverId -- ' + approverId);
                    approvalRequest.setNextApproverIds(new List<Id> {approverId});
                    cdToapprovalRequestMap.put(iRec.Id, approvalRequest);
                    
                    if(!cdToapprovalRequestMap.isEmpty())
                        List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                }
            }
        }
        catch (Exception e){
            system.debug('Error :: ' + e.getMessage() + 'At Line Number :: ' + e.getLineNumber());
        }
    }
}