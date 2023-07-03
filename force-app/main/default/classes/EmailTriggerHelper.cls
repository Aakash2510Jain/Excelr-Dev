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
            Map<Id,Lead> leadIdByLeadRecMap = new Map<Id, Lead>();
            Map<String, EmailMessage> leadIdBYEmailMessageRecordMap = new Map<String, EmailMessage>();
            List<Lead> leadsListwithEmail = new List<Lead>();
            List<Lead> leadsListToUpdate = new List<Lead>();
            List<task> taskListToInsert = new List<Task>();
            Map<String,List<Lead>> leadEmailByLeadList = new Map<String, List<Lead>>();
            
            for(EmailMessage emailMessageRec : emailMessageList){
                if(emailMessageRec.ToAddress != null){
                    emailList.add(emailMessageRec.ToAddress);
                }
            }
            system.debug('emailList--->'+emailList);
            if(!emailList.isEmpty()){
                leadsListwithEmail = [select id,Name,Email,Alternate_email__c,OwnerId from Lead where (email in : emailList or Alternate_email__c in: emailList) AND isConverted = False and ownerId =: UserInfo.getUserId() limit 80];
                system.debug('leadsListwithEmail--->'+leadsListwithEmail);
                if(!leadsListwithEmail.isEmpty()){
                    for(Lead leadRec : leadsListwithEmail){
                        system.debug('leadRec--->'+leadRec.Id);
                        system.debug('leadRec.Email--->'+leadRec.Email);
                        system.debug('leadEmailByLeadList--->'+leadEmailByLeadList);
                        if(leadEmailByLeadList.containsKey(leadRec.Email)){
                            List<Lead> leadList = leadEmailByLeadList.get(leadRec.Email);
                            leadList.add(leadRec);
                            leadEmailByLeadList.put(leadRec.Email,leadList);
                        }else{
                            leadEmailByLeadList.put(leadRec.Email, new List<Lead>{ leadRec});
                        }
                        
                        system.debug('leadRec.Alternate_email__c--->'+leadRec.Alternate_email__c);
                        system.debug('leadEmailByLeadList--->'+leadEmailByLeadList);
                        
                        if(leadEmailByLeadList.containsKey(leadRec.Alternate_email__c)){
                            List<Lead> leadList = leadEmailByLeadList.get(leadRec.Alternate_email__c);
                            leadList.add(leadRec);
                            leadEmailByLeadList.put(leadRec.Alternate_email__c,leadList);
                        }else{
                            leadEmailByLeadList.put(leadRec.Alternate_email__c, new List<Lead>{ leadRec});
                        }
                    }
                    system.debug('leadEmailByLeadList--->'+leadEmailByLeadList);
                    if(!leadEmailByLeadList.isEmpty()){
                        for(EmailMessage emailMessageRec : emailMessageList){
                            system.debug('emailMessageRec.ToAddress--->'+emailMessageRec.ToAddress);
                            if(leadEmailByLeadList.containsKey(emailMessageRec.ToAddress)){
                                system.debug('leadEmailByLeadList.get(emailMessageRec.ToAddress)--->'+leadEmailByLeadList.get(emailMessageRec.ToAddress));
                                for(Lead leadRecords : leadEmailByLeadList.get(emailMessageRec.ToAddress)){
                                    leadIdByLeadRecMap.put(leadRecords.Id, leadRecords);
                                    leadIdBYEmailMessageRecordMap.put(leadRecords.Id, emailMessageRec);
                                }
                            }
                        }
                        if(!leadIdByLeadRecMap.isEmpty()){
                            for(Lead leadRec: leadIdByLeadRecMap.values()){
                                Lead leadRecToUpdate  = new Lead();
                                leadRecToUpdate.Id = leadRec.Id;
                                leadRecToUpdate.Email_Conversation_Done__c = true;
                                leadsListToUpdate.add(leadRecToUpdate);
                                
                                Task taskLeadRec = new Task();
                                if(leadIdBYEmailMessageRecordMap.containsKey(leadRec.Id))
                                    taskLeadRec.Email__c = leadIdBYEmailMessageRecordMap.get(leadRec.Id).ToAddress;
                                taskLeadRec.Subject = 'Email: '+leadRec.Name;
                                taskLeadRec.WhoId = leadRec.Id;
                                taskLeadRec.Status = 'Completed';
                                taskLeadRec.OwnerId = leadRec.OwnerId;
                                if(leadIdBYEmailMessageRecordMap.containsKey(leadRec.Id))
                                    taskLeadRec.Description = 'To: '+leadIdBYEmailMessageRecordMap.get(leadRec.Id).ToAddress+'\n CC: '+leadIdBYEmailMessageRecordMap.get(leadRec.Id).CcAddress+'\n BCC: '+leadIdBYEmailMessageRecordMap.get(leadRec.Id).BccAddress+'\n\n Subject: '+leadIdBYEmailMessageRecordMap.get(leadRec.Id).Subject+'\n Body: '+leadIdBYEmailMessageRecordMap.get(leadRec.Id).TextBody;
                                taskListToInsert.add(taskLeadRec);
                            }
                            if(!leadsListToUpdate.isEmpty()){
                                Update leadsListToUpdate;
                            }
                            if(!taskListToInsert.isEmpty()){
                                system.debug('taskListToInsert--->'+taskListToInsert);
                                insert taskListToInsert;
                            }
                        }
                    }
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
            Map<String, opportunity> emailByOpportunityRec = new Map<String, opportunity>();
            Set<String> setToAddressSet = new Set<String>();
            
            if(emailList.size()> 0){
                for(EmailMessage email : emailList){
                    setToAddressSet.add(email.toAddress);
                }
                System.debug('setToAddressSet ==>'+setToAddressSet);
                if(setToAddressSet.size() > 0){
                    OpportunityRecordBasedSetToAddress = [SELECT Id,Name,Email__c,Alternate_Email__c FROM Opportunity WHERE Email__c IN:setToAddressSet or Alternate_Email__c In :setToAddressSet  order by lastModifiedDate DESC limit 80];
                    if(OpportunityRecordBasedSetToAddress.size() > 0){
                        for(Opportunity oppRec : OpportunityRecordBasedSetToAddress){
                            emailByOpportunityRec.put(oppRec.Email__c, oppRec);
                            emailByOpportunityRec.put(oppRec.Alternate_Email__c, oppRec);
                        }
                        if(!emailByOpportunityRec.isEmpty()){
                            for(EmailMessage email : emailList){
                                if(email.RelatedToId == null){
                                    if(emailByOpportunityRec.containsKey(email.toAddress))   
                                        email.RelatedToId = emailByOpportunityRec.get(email.toAddress).Id;
                                }
                            }
                        }
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