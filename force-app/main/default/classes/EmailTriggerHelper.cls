public class EmailTriggerHelper {
    public static void attachEmailToLead(List<EmailMessage> emailMessageList){
        List<EmailMessageRelation> emailMsgRelationList = new List<EmailMessageRelation>();
        set<String> emailList = new Set<String>();
        List<Lead> leadsListwithEmail = new List<Lead>();
        List<task> taskListToInsert = new List<Task>();
        Map<String,Lead> leadIdbyEmail = new Map<String,Lead>();
        Map<String,Lead> opportunityIdbyEmail = new Map<String,Lead>();
        
        for(EmailMessage emailMessageRec : emailMessageList){
            system.debug('emailMessageRec--->'+emailMessageRec);
            emailList.add(emailMessageRec.ToAddress);
        }
        if(!emailList.isEmpty()){
            leadsListwithEmail = [select id,Name,ConvertedOpportunity.Name,ConvertedOpportunityId,ConvertedOpportunity.Email__C,ConvertedOpportunity.Alternate_email__c,Email,Alternate_email__c from Lead where email in : emailList or Alternate_email__c in: emailList];
            
            if(!leadsListwithEmail.isEmpty()){
                for(Lead leadRec : leadsListwithEmail){
                    leadIdbyEmail.put(leadRec.Email, leadRec);
                    leadIdbyEmail.put(leadRec.Alternate_email__c, leadRec);
                    opportunityIdbyEmail.put(leadRec.ConvertedOpportunity.Email__C, leadRec);
                    opportunityIdbyEmail.put(leadRec.ConvertedOpportunity.Alternate_email__c, leadRec);
                }
                for(EmailMessage emailMessageRec : emailMessageList){
                    if(leadIdbyEmail.containsKey(emailMessageRec.ToAddress) || opportunityIdbyEmail.containsKey(emailMessageRec.ToAddress) ){
                        Task taskRec = new Task();
                        
                        if(leadIdbyEmail.containsKey(emailMessageRec.ToAddress)){
                            EmailMessageRelation emailRelation = new EmailMessageRelation();
                            emailRelation.RelationId = leadIdbyEmail.get(emailMessageRec.ToAddress).Id;
                            emailRelation.EmailMessageId = emailMessageRec.Id;
                            emailRelation.RelationType = 'ToAddress';
                            emailMsgRelationList.add(emailRelation);
                            
                            taskRec.Subject = 'Email: '+leadIdbyEmail.get(emailMessageRec.ToAddress).Name;
                            taskRec.WhoId = leadIdbyEmail.get(emailMessageRec.ToAddress).Id;
                            taskRec.Status = 'Completed';
                            taskRec.Description = 'To: '+emailMessageRec.ToAddress+'\n CC: '+emailMessageRec.CcAddress+'\n BCC: '+emailMessageRec.BccAddress+'\n\n Subject: '+emailMessageRec.Subject+'\n Body: '+emailMessageRec.TextBody;
                        }
                        if(opportunityIdbyEmail.containsKey(emailMessageRec.ToAddress)){
                            EmailMessageRelation emailRelation = new EmailMessageRelation();
                            emailRelation.RelationId = opportunityIdbyEmail.get(emailMessageRec.ToAddress).ConvertedOpportunityId;
                            emailRelation.EmailMessageId = emailMessageRec.Id;
                            emailRelation.RelationType = 'ToAddress';
                            emailMsgRelationList.add(emailRelation);
                            
                            taskRec.Subject = 'Email: '+opportunityIdbyEmail.get(emailMessageRec.ToAddress).ConvertedOpportunity.Name;
                            taskRec.WhatId = opportunityIdbyEmail.get(emailMessageRec.ToAddress).ConvertedOpportunityId;
                            taskRec.Status = 'Completed';
                            taskRec.Description = 'To: '+emailMessageRec.ToAddress+'\n CC: '+emailMessageRec.CcAddress+'\n BCC: '+emailMessageRec.BccAddress+'\n\n Subject: '+emailMessageRec.Subject+'\n Body: '+emailMessageRec.TextBody;
                       
                        }
                        taskListToInsert.add(taskRec);
                    }
                   
                }
                if(!emailMsgRelationList.isEmpty()){
                    insert emailMsgRelationList;
                }
                if(!taskListToInsert.isEmpty()){
                    insert taskListToInsert;
                }
            }
        }
    }
}