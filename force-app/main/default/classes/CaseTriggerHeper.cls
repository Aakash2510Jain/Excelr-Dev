public without sharing class CaseTriggerHeper {
    static CaseTriggerHeper handlerInstance;
    public static CaseTriggerHeper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new CaseTriggerHeper();
        return handlerInstance;
    }
    
    public void onAfterInsert(List<Case> newCaseList, Map<id, Case> newCaseMap) {
        try{
            system.debug('newCaseMap :: ' + newCaseMap);
            Map<Id,Case> freshCaseMap = new Map<Id,Case>([SELECT Id, Owner.UserRoleId FROM Case WHERE Id IN:newCaseMap.keySet()]);
            system.debug('freshCaseMap :: ' + freshCaseMap);
            Utility.ApprovalWrapper approvalQAWrapper = Utility.getParentUserMap();
            
            for(Case caseRec : newCaseList){
                Id caseOwnersRoleId = freshCaseMap.get(caseRec.Id).Owner.UserRoleId;
                system.debug('caseOwnersRoleId :: ' + caseOwnersRoleId);
                Id approverId = approvalQAWrapper.smToManagerMap.containsKey(caseOwnersRoleId) && approvalQAWrapper.managerRoleToUserIdMap.containsKey(approvalQAWrapper.smToManagerMap.get(caseOwnersRoleId)) ? approvalQAWrapper.managerRoleToUserIdMap.get(approvalQAWrapper.smToManagerMap.get(caseOwnersRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                system.debug('approverId :: ' + approverId);
                
                if(approverId != null){
                    createTask('Define Severity on Case Number ' + caseRec.CaseNumber, approverId, caseRec.Id);
                }
            }
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'onAfterInsert', e, null);
        }
    }
    
    public void onAfterUpdate(List<Case> newCaseList, Map<id, Case> oldCaseMap) {
        try{            
            List<Refund__c> refundListToBeInserted = new List<Refund__c>();
            List<Account> accListToBeInserted = new List<Account>();
            List<Bank_Details__c> bnkDetListToBeInserted = new List<Bank_Details__c>();
            Map<Id,Case> freshCaseMap = new Map<Id,Case>([SELECT Id, Owner.UserRoleId, Account.OwnerId, Account.Owner.ManagerId, Account.Owner.Name, Account.Email__c,
                                                          Account.Owner.Email, Account.Owner.Manager.Email, Account.Owner.Manager.Name, Account.Owner.UserRoleId, Account.Name, AccountId
                                                          FROM Case WHERE Id IN:oldCaseMap.keySet()]);
            List<ProcessInstance> recordUnderApprovalList = [Select ID, Status,TargetObjectID, TargetObject.Name From ProcessInstance Where Status =: Constants.PENDING AND TargetObjectID IN :oldCaseMap.keySet()];
            Set<Id> underApprovalCaseSet = new Set<Id>();
            //Id financeUserId = [SELECT Id, Name FROM User WHERE Profile.Name = 'Finance' LIMIT 1].Id;
            for(ProcessInstance approvalOpp : recordUnderApprovalList) {
                underApprovalCaseSet.add(approvalOpp.TargetObjectID);
            }
            
            Utility.ApprovalWrapper approvalBHWrapper = Utility.getUserBHMap();
            Utility.ApprovalWrapper approvalAppWrapper = Utility.getParentUserMap();
            
            set<Id> caseIdSet = new set<Id>();
            
            for(Case csRec : newCaseList){
                
                if(oldCaseMap.get(csRec.Id).Status != csRec.Status && csRec.Status != null && !String.isBlank(csRec.Status)){
                    caseIdSet.add(csRec.Id);
                }
                
                if(underApprovalCaseSet.contains(csRec.Id)) {
                    csRec.addError(Constants.UNDER_APPROVAL_PROCESS_ERR_MSG); 
                    continue;
                }
                if(csRec.Severity__c != oldCaseMap.get(csRec.Id).Severity__c && csRec.Severity__c != NULL && freshCaseMap.get(csRec.Id).Account.OwnerId != null){
                    
                    if(csRec.Severity__c == 'L1'){
                                               
                        createTask('L1 Severity Case assigned!', freshCaseMap.get(csRec.Id).Account.OwnerId, csRec.AccountId);
                        
                        String emailBody = 'Dear ' + freshCaseMap.get(csRec.Id).Account.Owner.Name;
                        emailBody += ' <br> <br> L1 Case has been assigned to you. Click on the below link to access the record.<br>';
                        emailBody += ' <a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+csRec.Id+'">'+ csRec.CaseNumber +'</a><br>' ; 
                        emailBody += '<br> With Regards';
                        emailBody += '<br> ExcelR';
                        List <String> toAddresses = new List <String>{freshCaseMap.get(csRec.Id).Account.Owner.Email};
                        List <String> toCcAddresses = new List <String>();
                        if(freshCaseMap.get(csRec.Id).Account.Owner.Manager.Email != null){
                            toCcAddresses = new List <String>{freshCaseMap.get(csRec.Id).Account.Owner.Manager.Email};
                        }
                        else{
                            toCcAddresses = new List <String>{};
                        }
                        sendEmail(emailBody, toAddresses, toCcAddresses, 'Case assigned');
                        
                        Id approverId;
                        Id caseOwnersRoleId = freshCaseMap.get(csRec.Id).Account.Owner.UserRoleId;
                        if(freshCaseMap.get(csRec.Id).Account.Owner.ManagerId != null){
                            approverId = freshCaseMap.get(csRec.Id).Account.Owner.ManagerId;
                        }
                        else{
                            approverId = approvalAppWrapper.smToManagerMap.containsKey(caseOwnersRoleId) && approvalAppWrapper.managerRoleToUserIdMap.containsKey(approvalAppWrapper.smToManagerMap.get(caseOwnersRoleId)) ? approvalAppWrapper.managerRoleToUserIdMap.get(approvalAppWrapper.smToManagerMap.get(caseOwnersRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                        
                        if(approverId != null){
                            doApproval(csRec.AccountId, approverId);
                        }
                    }
                    
                    if(csRec.Severity__c == 'L2'){
                        Id approverId;
                        Id caseOwnersRoleId = freshCaseMap.get(csRec.Id).Account.Owner.UserRoleId;
                        if(freshCaseMap.get(csRec.Id).Account.Owner.ManagerId != null){
                            approverId = freshCaseMap.get(csRec.Id).Account.Owner.ManagerId;
                        }
                        else{
                            approverId = approvalAppWrapper.smToManagerMap.containsKey(caseOwnersRoleId) && approvalAppWrapper.managerRoleToUserIdMap.containsKey(approvalAppWrapper.smToManagerMap.get(caseOwnersRoleId)) ? approvalAppWrapper.managerRoleToUserIdMap.get(approvalAppWrapper.smToManagerMap.get(caseOwnersRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                        
                        if(approverId != null){
                            createTask('L2 Severity Case assigned!', approverId, csRec.AccountId);
                            doApproval(csRec.AccountId, approverId);
                        }
                        String name;
                        if(freshCaseMap.get(csRec.Id).Account.Owner.ManagerId == null){
                            name = freshCaseMap.get(csRec.Id).Account.Owner.Name;
                        }
                        else{
                            name = freshCaseMap.get(csRec.Id).Account.Owner.Manager.Name;
                        }
                        String emailBody = 'Dear ' + name;
                        emailBody += ' <br> <br> L2 Case has been assigned to you. Click on the below link to access the record. <br>';
                        emailBody += ' <a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+csRec.Id+'">'+ csRec.CaseNumber +'</a><br>' ; 
                        emailBody += '<br> With Regards';
                        emailBody += '<br> ExcelR';
                        
                        String addrss ;
                        if(freshCaseMap.get(csRec.Id).Account.Owner.Manager.Email == null){
                            addrss = freshCaseMap.get(csRec.Id).Account.Owner.Email;
                        }
                        else{
                            addrss = freshCaseMap.get(csRec.Id).Account.Owner.Manager.Email;
                        }
                        
                        List <String> toAddresses = new List <String>{addrss};
                        List <String> toCcAddresses = new List <String>();
                        if(addrss == freshCaseMap.get(csRec.Id).Account.Owner.Email){
                            toCcAddresses = new List <String>{};
                        }
                        else{
                            toCcAddresses = new List <String>{freshCaseMap.get(csRec.Id).Account.Owner.Email};
                        }                        
                        sendEmail(emailBody, toAddresses, toCcAddresses, 'Case assigned');
                    }
                    
                    if(csRec.Severity__c == 'L3'){
                        Id caseOwnersRoleId = freshCaseMap.get(csRec.Id).Account.Owner.UserRoleId;
                        system.debug('caseOwnersRoleId :: ' + caseOwnersRoleId);
                        Id BHId = approvalBHWrapper.smToManagerMap.containsKey(caseOwnersRoleId) && approvalBHWrapper.managerRoleToUserIdMap.containsKey(approvalBHWrapper.smToManagerMap.get(caseOwnersRoleId)) ? approvalBHWrapper.managerRoleToUserIdMap.get(approvalBHWrapper.smToManagerMap.get(caseOwnersRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        system.debug('BHId :: ' + BHId);
                        if(BHId!= null){ 
                            createTask('L3 Severity Case assigned!', BHId, csRec.AccountId);
                            
                            String bhEmail = [SELECT Id, Email FROM User WHERE Id =: BHId].Email;
                            String bhName = [SELECT Id, Name FROM User WHERE Id =: BHId].Name;
                            
                            String emailBody = 'Dear ' + bhName;
                            emailBody += ' <br> <br> L3 Case has been assigned to you. Click on the below link to access the record. <br>';
                            emailBody += ' <a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+csRec.Id+'">'+ csRec.CaseNumber +'</a><br>' ; 
                            emailBody += '<br> With Regards';
                            emailBody += '<br> ExcelR';
                            List <String> toAddresses = new List <String>{bhEmail};
                            List <String> toCcAddresses = new List <String>(); 
                            
                            if(freshCaseMap.get(csRec.Id).Account.Owner.Manager.Email == null){
                                toCcAddresses = new List <String>{freshCaseMap.get(csRec.Id).Account.Owner.Email};
                            }
                            else{
                                toCcAddresses = new List <String>{freshCaseMap.get(csRec.Id).Account.Owner.Manager.Email, freshCaseMap.get(csRec.Id).Account.Owner.Email};
                            }
                            sendEmail(emailBody, toAddresses, toCcAddresses, 'Case assigned');
                            doApproval(csRec.AccountId, BHId);
                        }
                    }
                }
                /*if(csRec.Approval_Status__c != oldCaseMap.get(csRec.Id).Approval_Status__c && csRec.Approval_Status__c == 'Approved'){
                    String emailBody = 'Dear ' + freshCaseMap.get(csRec.Id).Account.Name;
                    emailBody += ' <br> <br> This is the Refund Form. <br>';
                    emailBody += '<br> With Regards';
                    emailBody += '<br> ExcelR';
                    if(freshCaseMap.get(csRec.Id).Account.Email__c != null){
                        List <String> toAddresses = new List <String>{freshCaseMap.get(csRec.Id).Account.Email__c};
                        List <String> toCcAddresses = new List <String>{};
                        sendEmail(emailBody, toAddresses, toCcAddresses, 'Refund Form');
                    }
                    Refund__c newRefund = new Refund__c();
                    newRefund.Account__c = freshCaseMap.get(csRec.Id).AccountId ;
                    newRefund.Refund_Status__c = 'Initiated';
                    refundListToBeInserted.add(newRefund);
                    
                    Bank_Details__c newBnkDet = new Bank_Details__c();
                    newBnkDet.Account__c = freshCaseMap.get(csRec.Id).AccountId ;
                    newBnkDet.Account_No__c = '30292728782';
                    newBnkDet.Bank_Name__c = 'State Bank of India';
                    newBnkDet.IFSC_Code__c = 'SBIN00000';
                    bnkDetListToBeInserted.add(newBnkDet);
                    if(!bnkDetListToBeInserted.isEmpty() && !refundListToBeInserted.isEmpty()){
                        insert refundListToBeInserted;
                        insert bnkDetListToBeInserted;
                        if(financeUserId != null){
                            createTask('Refund record assigned!', financeUserId, csRec.AccountId);
                        }
                    }
                } */
            }
            
            system.debug('caseIdSet -- ' + caseIdSet);
            if(caseIdSet.size()>0){
                //callStatusUpdateAPI(caseIdSet);
            }
            
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'onAfterUpdate', e, null);
        }
    }
    
    @future(callout=true)
    public static void callStatusUpdateAPI(set<Id> caseIdSet){
        LMS_ApiCallouts.doInvoiceStatusUpdate(caseIdSet);
    }
    
    private static void sendEmail(String emailBody, List <String> toAddresses, List <String> toCcAddresses, String subject){
        try{
            Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress limit 1];
            system.debug('owea::'+owea);
            List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
            sendEmail.setSubject(subject);
            sendEmail.setToAddresses(toAddresses);
            if(toCcAddresses != null){
                sendEmail.setCcAddresses(toCcAddresses);
            }
            sendEmail.setReplyTo(owea.Address);
            sendEmail.setHtmlBody(emailBody);
            emailsList.add(sendEmail);
            if(!emailsList.isEmpty()) {
                Messaging.sendEmail(emailsList);     
            }
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'sendEmail', e, null);
        }        
    }
    
    private static void createTask(String sub, Id ownerID, Id whatID){
        try{
            List<Task> tskListToBeInserted = new List<Task>();
            Task newTsk = new Task();
            newTsk.Subject = sub;
            newTsk.OwnerId = ownerID;
            newTsk.WhatId = whatID;
            newTsk.Status = 'Open';
            tskListToBeInserted.add(newTsk);
            if(!tskListToBeInserted.isEmpty()){
                insert tskListToBeInserted;
            }
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'createTask', e, null);
        }           
    }
    
    private static void doApproval(Id objId, Id approverId){
        try{
            Map<Id, Approval.ProcessSubmitRequest> caseToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Submitting for Case Severity Approval');
            approvalRequest.setObjectId(objId);
            approvalRequest.setProcessDefinitionNameOrId('Account_Approval');
            approvalRequest.setNextApproverIds(new List<Id> {approverId});
            caseToapprovalRequestMap.put(objId, approvalRequest);
            
            if(!caseToapprovalRequestMap.isEmpty())
                List<Approval.ProcessResult> result = Approval.process(caseToapprovalRequestMap.values());
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'doApproval', e, null);
        }           
    }
}