public without sharing class ContentDocumentLinkTrigger {
    
    static ContentDocumentLinkTrigger handlerInstance;
    public static ContentDocumentLinkTrigger getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new ContentDocumentLinkTrigger();
        return handlerInstance;
    }
    
    public void onAfterInsert(List<ContentDocumentLink> cdlList) {
        try{
            Set<ID> parentIds = new Set<ID>();
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
            List<Receipt__c> receiptList = new List<Receipt__c>();
            
            for ( ContentDocumentLink cdl : cdlList ) {
                parentIds.add( cdl.LinkedEntityId );
            }
            if(!parentIds.isEmpty()){
                receiptList = [SELECT Id,Invoice__r.Opportunity_s_Manager__c,Invoice__r.Opportunity__r.Owner.UserRoleId,Receipt_Status__c,Type__c, Invoice__r.Opportunity__r.Owner.managerid, Invoice__r.Opportunity__r.Payment_Type__c, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Receipt__c WHERE Id IN :parentIds and type__c != 'Online'];
                system.debug('receiptList :: ' + receiptList);
                if(!receiptList.isEmpty()){
                    for (Receipt__c receiptRec : receiptList) {
                        Id approverId;
                        String userRoleId;
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting for Manager Approval post Payment is done');
                        approvalRequest.setObjectId(receiptRec.Id);
                        approvalRequest.setProcessDefinitionNameOrId('Receipt_Payment_Approval');
                        userRoleId = receiptRec.Invoice__r.Opportunity__r.Owner.UserRoleId;
                        if(receiptRec.Invoice__r.Opportunity_s_Manager__c != null){
                            approverId = receiptRec.Invoice__r.Opportunity_s_Manager__c;
                        }
                        else{
                            approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                        system.debug('approverId--->'+approverId);
                        approvalRequest.setNextApproverIds(new List<Id> {approverId});
                        cdToapprovalRequestMap.put(receiptRec.Id, approvalRequest);                   
                    } 
                    if(!cdToapprovalRequestMap.isEmpty()){
                        List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                    }
                }
            }
        } catch (Exception e){
            system.debug('Error :: ' + e.getMessage() + 'At Line Number :: ' + e.getLineNumber());
        }
    }
}