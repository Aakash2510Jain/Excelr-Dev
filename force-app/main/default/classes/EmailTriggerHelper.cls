public without sharing class EmailTriggerHelper {
      static EmailTriggerHelper handlerInstance;
    
    public static EmailTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new EmailTriggerHelper();
        return handlerInstance;
    }
    
    public void attachEmailToLead(List<EmailMessage> emailMessageList){
        try {
            List<EmailMessageRelation> emailMsgRelationList = new List<EmailMessageRelation>();
            set<String> emailList = new Set<String>();
            List<Lead> leadsListwithEmail = new List<Lead>();
            List<Opportunity> opportunityListwithEmail = new List<Opportunity>();
            
            List<Lead> leadsListToUpdate = new List<Lead>();
            List<task> taskListToInsert = new List<Task>();
            Map<String,Lead> leadIdbyEmail = new Map<String,Lead>();
            Map<String,Opportunity> opportunityIdbyEmail = new Map<String,Opportunity>();
            
            for(EmailMessage emailMessageRec : emailMessageList){
                system.debug('emailMessageRec--->'+emailMessageRec);
                if(emailMessageRec.ToAddress != null){
                    system.debug('emailMessageRec.ToAddress--->'+emailMessageRec.ToAddress);
                    emailList.add(emailMessageRec.ToAddress);
                }
            }
            if(!emailList.isEmpty()){
                leadsListwithEmail = [select id,Name,Email,Alternate_email__c from Lead where (email in : emailList or Alternate_email__c in: emailList) AND isConverted = False];
                opportunityListwithEmail = [select id,Name,Email__c,Alternate_email__c from Opportunity where email__c in : emailList or Alternate_email__c in: emailList];
                
                if(!leadsListwithEmail.isEmpty()){
                    for(Lead leadRec : leadsListwithEmail){
                        leadIdbyEmail.put(leadRec.Email, leadRec);
                        leadIdbyEmail.put(leadRec.Alternate_email__c, leadRec);
                    }
                }
                if(!opportunityListwithEmail.isEmpty()){
                    for(Opportunity opportunityRec : opportunityListwithEmail){
                        opportunityIdbyEmail.put(opportunityRec.Email__c, opportunityRec);
                        opportunityIdbyEmail.put(opportunityRec.Alternate_email__c, opportunityRec);
                    }
                }
                
                for(EmailMessage emailMessageRec : emailMessageList){
                    
                    if(leadIdbyEmail.containsKey(emailMessageRec.ToAddress)){
                        Lead leadRecToUpdate  = new Lead();
                        leadRecToUpdate.Id = leadIdbyEmail.get(emailMessageRec.ToAddress).Id;
                        leadRecToUpdate.Email_Conversation_Done__c = true;
                        leadsListToUpdate.add(leadRecToUpdate);
                        
                        Task taskLeadRec = new Task();
                        taskLeadRec.Subject = 'Email: '+leadIdbyEmail.get(emailMessageRec.ToAddress).Name;
                        taskLeadRec.WhoId = leadIdbyEmail.get(emailMessageRec.ToAddress).Id;
                        taskLeadRec.Status = 'Completed';
                        taskLeadRec.Description = 'To: '+emailMessageRec.ToAddress+'\n CC: '+emailMessageRec.CcAddress+'\n BCC: '+emailMessageRec.BccAddress+'\n\n Subject: '+emailMessageRec.Subject+'\n Body: '+emailMessageRec.TextBody;
                        taskListToInsert.add(taskLeadRec);
                    }
                    if(opportunityIdbyEmail.containsKey(emailMessageRec.ToAddress)){
                        Task taskOpportunityRec = new Task();
                        taskOpportunityRec.Subject = 'Email: '+opportunityIdbyEmail.get(emailMessageRec.ToAddress).Name;
                        taskOpportunityRec.WhatId = opportunityIdbyEmail.get(emailMessageRec.ToAddress).Id;
                        taskOpportunityRec.Status = 'Completed';
                        taskOpportunityRec.Description = 'To: '+emailMessageRec.ToAddress+'\n CC: '+emailMessageRec.CcAddress+'\n BCC: '+emailMessageRec.BccAddress+'\n\n Subject: '+emailMessageRec.Subject+'\n Body: '+emailMessageRec.TextBody;
                        taskListToInsert.add(taskOpportunityRec);
                    }
                }
                
                if(!leadsListToUpdate.isEmpty()){
                    Update leadsListToUpdate;
                }
                if(!taskListToInsert.isEmpty()){
                    insert taskListToInsert;
                }
            }
        }catch (Exception e) {
            HandleBusinessException.captureError('EmailTriggerHelper','attachEmailToLead', e, null);
            
        }
    }

    public  void AttacheRelated_SetWhatId(List<EmailMessage> emailList){
        System.debug('emailList ===> '+emailList);
     try{
        List<Lead> leadRecordBasedSetToAddress = new List<Lead>();
        List<Opportunity> OpportunityRecordBasedSetToAddress = new List<Opportunity>();
        Set<String> setToAddressSet = new Set<String>();
        String RelatedIdForLead;
        String SetWhatIdForOpp;
        if(emailList.size()> 0){
            for(EmailMessage email : emailList){
                setToAddressSet.add(email.toAddress);
            }
            System.debug('setToAddressSet ==>'+setToAddressSet);
            if(setToAddressSet.size() > 0){
                leadRecordBasedSetToAddress = [SELECT id,Name,Email FROM Lead WHERE Email IN:setToAddressSet order by lastModifiedDate DESC];
                if(leadRecordBasedSetToAddress.size() > 0){
                    RelatedIdForLead = leadRecordBasedSetToAddress[0].Id;
                }
                OpportunityRecordBasedSetToAddress = [SELECT Id,Name,Email__c FROM Opportunity WHERE Email__c IN:setToAddressSet order by lastModifiedDate DESC];
                if(OpportunityRecordBasedSetToAddress.size() > 0){
                    SetWhatIdForOpp = OpportunityRecordBasedSetToAddress[0].Id;
                }
            }
            
            for(EmailMessage email : emailList){
                
                if(!String.isBlank(SetWhatIdForOpp)){
                    email.RelatedToId = SetWhatIdForOpp;
                }else  if(!String.isBlank(RelatedIdForLead)){
                    email.RelatedToId = RelatedIdForLead;
                } 
            }
            
        }
     }catch(Exception e){
         System.debug('The Error '+e.getMessage());
         System.debug('Erron Line '+e.getLineNumber());
         HandleBusinessException.captureError('EmailTriggerHelper','AttacheRelated_SetWhatId', e, null);
         
        }
    }
}