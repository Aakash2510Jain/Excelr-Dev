global class BatchToSendEmailForFollowupFromLead implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all leads with follow-up date and time within the next 15 minutes
        Datetime now = Datetime.now();
        Datetime cutoffTime = now.addMinutes(20);
        String query = '';
        return Database.getQueryLocator([SELECT Id, Name,LastName, Email, Next_follow_up_date_time__c,Owner.Name,Owner.LastName,Owner.Email FROM Lead WHERE Next_follow_up_date_time__c >= :now AND Next_follow_up_date_time__c < :cutoffTime and IsConverted = false]);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadList) {
        try{
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FollowUpTaskReminder'];

            
            system.debug('leadList--->'+leadList);
            EmailTemplate emailTemplateRec = [Select Id,HtmlValue,Subject From EmailTemplate where Name ='LeadFollowUpBeforeFifteenMin'];
            system.debug('emailTemplateRec--->'+emailTemplateRec);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Lead leadRec : leadList) {
                // Create email message with recipient, subject, and body
                system.debug('leadRec.Owner.Email--->'+leadRec.Owner.Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ leadRec.Owner.Email });
                email.setSubject(emailTemplateRec.Subject);
                string emailHtmlValue = emailTemplateRec.HtmlValue;
                Id orgWideEmailAddressId = '0D2N00000004HvgKAE';
                email.setOrgWideEmailAddressId(orgWideEmailAddressId);

                system.debug('');
                emailHtmlValue = emailHtmlValue.replace('{!Lead.OwnerFullName}', leadRec.Owner.LastName);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Name}', leadRec.LastName);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Next_follow_up_date_time__c}', String.valueOf(leadRec.Next_follow_up_date_time__c));
                
                email.setHtmlBody(emailHtmlValue);
                emails.add(email);
                
                  if(notificationType != null){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Followup in 15 Mins');
                    notification.setBody('The following lead is scheduled for a follow-up within the next 15 minutes');
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(leadRec.id);
                    notification.send(new Set<String> {leadRec.OwnerId});
                }
            }
            system.debug('emails--->'+emails);
            
            // Send email messages
            if(!emails.isEmpty())
                Messaging.sendEmail(emails);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BatchToSendEmailForFollowupFromLead', 'BatchToSendEmailForFollowupFromLead', e, null);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Do nothing
    }
}