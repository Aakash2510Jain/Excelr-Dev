public without sharing class InvoiceTriggerHelper{
    static InvoiceTriggerHelper handlerInstance;
    
    public static InvoiceTriggerHelper getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new InvoiceTriggerHelper();
        return handlerInstance;
    }
    
    public void afterUpdate(Map<Id, Invoice__c> newMap, Map<Id, Invoice__c> oldMap){
        try{
            system.debug('After Update Invoice');
            set<id> invoiceIds = new set<Id>();
            set<Id> opportunityIds = new set<Id>();
            List<opportunity> opportunityToUpdateAsWon = new List<Opportunity>();
            List<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :newMap.keySet() AND Status = 'Pending'];
            Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            string AdminUsers = [ Select Id from User where Profile.Name = 'Admin Head' limit 1].Id; 
            List<Receipt__c> receiptListToInsert  = new List<Receipt__c>();
            Map<string, Invoice__c> invoiceRecByInvoiceIdMap = new map<string, Invoice__c>();
            
            for ( Invoice__c invoiceRec : newMap.values() ){
                if ( (invoiceRec.Status__c != oldMap.get(invoiceRec.Id).Status__c && invoiceRec.Status__c == 'Realized') ||(invoiceRec.No_of_time_Realized_amount_Updated__c != oldMap.get(invoiceRec.Id).No_of_time_Realized_amount_Updated__c) ){
                    invoiceIds.add(invoiceRec.Id);
                }
                
                if(existingApprovals.isEmpty()){
                    if(invoiceRec.Credit_Note_Amount__c != null && invoiceRec.Credit_Note_Amount__c > 0 && invoiceRec.Credit_Note_Amount__c != oldMap.get(invoiceRec.Id).Credit_Note_Amount__c){
                        Id approverId;
                        String userRoleId;
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting Credit Note Amount for Manager Approval');
                        approvalRequest.setObjectId(invoiceRec.Id);
                        approvalRequest.setProcessDefinitionNameOrId('Invoice_Credit_Note_Amount_Approval');
                        approvalRequest.setSkipEntryCriteria(true);
                        userRoleId = invoiceRec.Opportunity__r.Owner.UserRoleId;
                        if(invoiceRec.Opportunity_s_Manager__c != null){
                            approverId = invoiceRec.Opportunity_s_Manager__c;
                        }
                        else{
                            approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                        if(approverId == null || string.isBlank(approverId) || string.isEmpty(approverId)){
                            approverId = AdminUsers;
                        }
                        approvalRequest.setNextApproverIds(new List<Id> {approverId});
                        cdToapprovalRequestMap.put(invoiceRec.Id, approvalRequest);                       
                    }
                }
                if (invoiceRec.Credit_Note_Approval_Status__c != oldMap.get(invoiceRec.Id).Credit_Note_Approval_Status__c && invoiceRec.Credit_Note_Approval_Status__c !=null && invoiceRec.Credit_Note_Approval_Status__c == 'Approved' ){
                    invoiceRecByInvoiceIdMap.put(invoiceRec.id, invoiceRec);
                }
                if(!invoiceRecByInvoiceIdMap.isEmpty()){
                    for(String invoiceId : invoiceRecByInvoiceIdMap.keyset()){
                        Receipt__c receiptRecToInsert = new Receipt__c();
                        receiptRecToInsert.Amount__c = invoiceRecByInvoiceIdMap.get(invoiceId).Credit_Note_Amount__c;
                        receiptRecToInsert.Receipt_Status__c = 'Pending';
                        receiptRecToInsert.Type__c = 'Credit Note';
                        receiptRecToInsert.Invoice__c = invoiceId;
                        receiptListToInsert.add(receiptRecToInsert);
                    }
                    if(!receiptListToInsert.isEmpty()){
                        insert receiptListToInsert;
                    }
                }
            }
            if(!cdToapprovalRequestMap.isEmpty()){
                Approval.ProcessResult[] result = Approval.process(cdToapprovalRequestMap.values());
            }
            system.debug('invoiceIds--->'+invoiceIds);
            if ( !invoiceIds.isEmpty() ){
                List<Invoice_Attachment__e> invAttList = new List<Invoice_Attachment__e>();
                for ( Id invoiceId : invoiceIds ){
                    system.debug('invoiceId--->'+invoiceId);
                    //1. First Approach - FAILED
                    //Have to call this but attachpdf is not future so error to get content in pdf and if making it future
                    // then future can not be called from future
                    //RetailInvoiceHelper.attachPdf(invoiceId);
                    //2. Second Approach - FAILED
                    //Used a platform event but process is running from automated user i.e not working for gmail customers
                    /* Invoice_Attachment__e invAtt = new Invoice_Attachment__e();
                    invAtt.Invoice__c = invoiceId;
                    invAttList.add(invAtt);*/
                    //3. Third Approcah 
                    //Calling a queueable method
                    system.debug('Calling queable');
                    InvoiceAndReceiptFlowHandler queueable = new InvoiceAndReceiptFlowHandler(invoiceId);
                    System.enqueueJob(queueable);
                }
                system.debug('invAttList--->'+invAttList);
                if(!invAttList.isEmpty()){
                    Database.SaveResult[] results = EventBus.publish(invAttList);
                }
            }
        } catch ( exception ex ){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'After Update', ex, null);
        }
    }
    public void beforeUpdate(Map<Id, Invoice__c> newMap, Map<Id, Invoice__c> oldMap){
        try{
             
            for ( Invoice__c invoiceRec : newMap.values() ){
                if (invoiceRec.Realized_Amount__c != oldMap.get(invoiceRec.Id).Realized_Amount__c && invoiceRec.Realized_Amount__c != 0){// && invoiceRec.Do_Not_Send_Invoice__c == false){
                    system.debug('Updating Invoice Status as realized');
                    invoiceRec.Status__c = 'Realized';
                    if(invoiceRec.No_of_time_Realized_amount_Updated__c == null	)
                        invoiceRec.No_of_time_Realized_amount_Updated__c = 0;
                    invoiceRec.No_of_time_Realized_amount_Updated__c = invoiceRec.No_of_time_Realized_amount_Updated__c + 1;
                }
                if (invoiceRec.Credit_Note_Approval_Status__c != oldMap.get(invoiceRec.Id).Credit_Note_Approval_Status__c && invoiceRec.Credit_Note_Approval_Status__c !=null && invoiceRec.Credit_Note_Approval_Status__c == 'Approved' ){
                    invoiceRec.Due_Amount__c = invoiceRec.Due_Amount__c - invoiceRec.Credit_Note_Amount__c;
                }
            }
            
        }catch ( exception ex ){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'Before Update', ex, null);
        }
    }
    public void sendforApproval(list<Invoice__c> invoiceList){
        System.debug('invoiceList =====> ' + invoiceList);
        set<id> invoiceIds = new Set<Id>();
        Set<Id> underApprovalCaseSet = new Set<Id>();
        list<task> TaskListTobeCreated = new List<task>();
        try{
            if ( !invoiceList.isEmpty() ){
                for ( invoice__c inv : invoiceList ){
                    if(inv.Type__c == 'Credit Note')
                        invoiceIds.add(inv.Id);
                }
                Id financeUserId = [SELECT Id, Name
                                    FROM User
                                    WHERE Profile.Name = 'Finance'
                                    LIMIT 1].Id;
                
                List<ProcessInstance> recordUnderApprovalList = [Select ID, Status, TargetObjectID, TargetObject.Name
                                                                 From ProcessInstance
                                                                 Where Status = :Constants.PENDING AND TargetObjectID IN:invoiceIds];
                for ( ProcessInstance approvalOpp : recordUnderApprovalList ){
                    underApprovalCaseSet.add(approvalOpp.TargetObjectID);
                }
                
                for ( invoice__c inv : invoiceList ){
                    if ( underApprovalCaseSet.contains(inv.Id) ){
                        inv.addError(Constants.UNDER_APPROVAL_PROCESS_ERR_MSG);
                    }
                    if ( !underApprovalCaseSet.contains(inv.Id) ){
                        SendforApprovalProcess(inv.Id, '005N000000CSOuaIAH');
                    }
                    
                    task tsk = new Task();
                    tsk.Subject = 'Release Credit Note';
                    tsk.Status = 'Open';
                    tsk.Priority = 'Medium';
                    tsk.WhatId = inv.Opportunity__c;
                    tsk.OwnerId = financeUserId;
                    TaskListTobeCreated.add(tsk);
                }
                if ( !TaskListTobeCreated.isEmpty() ){
                    insert TaskListTobeCreated;
                }
            }
            
            
        }
        catch ( Exception ex ){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'Tax Invoice', ex, null);
        }
    }
    
    public void SendforApprovalProcess(Id objId, Id approverId){
        try{
            system.debug('objId-->'+objId);
            system.debug('approverId-->'+approverId);
            /* Map<Id, Approval.ProcessSubmitRequest> InvoiceToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest(  );
approvalRequest.setComments('Submitting for Referral Approval');
approvalRequest.setObjectId(objId);
approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
approvalRequest.setNextApproverIds(new List<Id>{ approverId });
InvoiceToapprovalRequestMap.put(objId, approvalRequest);

if ( !InvoiceToapprovalRequestMap.isEmpty() ){
List<Approval.ProcessResult> result = Approval.process( InvoiceToapprovalRequestMap.values() );
}

*/
            // Create an approval request for the Opportunity
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            req1.setObjectId(objId);
            req1.setNextApproverIds(new Id[] {approverId});
            
            // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(req1);
            
            
        }
        catch ( Exception e ){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'doApproval', e, null);
        }
    }
    
    public void sendReferralFormViaEmail(map<id, Invoice__c> InvoiceOldMap, map<id, Invoice__c> InvoiceNewMap){
        
        set<String> ReferrarEmailList = new Set<string>();
        map<String, String> ReferrarNameWithEmail = new Map<String,String>();
        map<id,Invoice__c> ApprovedReferrarMap = new map<id,Invoice__c>();
        
        try{
            if ( !InvoiceNewMap.isEmpty() ){
                for ( Invoice__c invRec : InvoiceNewMap.values() ){
                    if ( invRec.Approval_Status__c != null && invRec.Approval_Status__c != InvoiceOldMap.get(invRec.id).Approval_Status__c && invRec.Approval_Status__c == 'Approved' && invRec.Referrer_Email__c != null && invRec.Referral_Name__c != null){
                        //ReferrarNameWithEmail.put(invRec.Referrer_Email__c, invRec.Referral_Name__c);
                        ApprovedReferrarMap.put(invRec.Id, invRec);
                    }
                }
                
                if (!ApprovedReferrarMap.isEmpty()) {
                    //https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/CaptureBankDetails
                    //EmailIUtility.SendReferralFormToReferrar(ApprovedReferrarMap);
                }
                
            }
        }
        catch ( Exception e ){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'doApproval', e, null);
            
        }
    }
    
}