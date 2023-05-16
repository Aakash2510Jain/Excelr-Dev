global class BatchToSendFollowupEmailFifteenMinOpp implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all opportunity with follow-up date and time within the next 15 minutes
        Datetime now = Datetime.now();
        Datetime cutoffTime = now.addMinutes(20);
        return Database.getQueryLocator([SELECT Id, Name,Email__C, Next_follow_up_date_time__c,Owner.Name,Owner.LastName,Owner.Email,OwnerId FROM Opportunity WHERE Next_follow_up_date_time__c >= :now AND Next_follow_up_date_time__c < :cutoffTime ]);
    }
    
    global void execute(Database.BatchableContext bc, List<opportunity> opportunityList) {
        try{
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FollowUpTaskReminder'];
            
            system.debug('opportunityList--->'+opportunityList);
            EmailTemplate emailTemplateRec = [Select Id,HtmlValue,Subject From EmailTemplate where Name ='OppFollowUpBeforeFifteenMin'];
            system.debug('emailTemplateRec--->'+emailTemplateRec);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Opportunity oppRec : opportunityList) {
                
                system.debug('oppRec.Owner.Email--->'+oppRec.Owner.Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ oppRec.Owner.Email });
                email.setSubject(emailTemplateRec.Subject);
                string emailHtmlValue = emailTemplateRec.HtmlValue;
                
                emailHtmlValue = emailHtmlValue.replace('{!Lead.OwnerFullName}', oppRec.Owner.LastName);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Name}', oppRec.Name);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Next_follow_up_date_time__c}', String.valueOf(oppRec.Next_follow_up_date_time__c));
                
                email.setHtmlBody(emailHtmlValue);
                emails.add(email);
                
                if(notificationType != null){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Followup in 15 Mins');
                    notification.setBody('The following lead is scheduled for a follow-up within the next 15 minutes');
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(oppRec.id);
                    notification.send(new Set<String> {oppRec.OwnerId});
                }
            }
            system.debug('emails--->'+emails);
            
            if(!emails.isEmpty())
                Messaging.sendEmail(emails);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BatchToSendFollowupEmailFifteenMinOpp', 'BatchToSendFollowupEmailFifteenMinOpp', e, null);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Do nothing
    }
}