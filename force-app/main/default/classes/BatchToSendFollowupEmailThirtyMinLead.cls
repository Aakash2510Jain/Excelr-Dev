/**
 * @author Aakash Jain
 * @email aakash.jain@utilitarianlab.com
 * @create date 19-05-2023 12:07:23
 * @modify date 19-05-2023 12:07:23
 * @desc [description]
 */
global class BatchToSendFollowupEmailThirtyMinLead implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Excelr Default Queue' limit 1].Id;
        Datetime now = Datetime.now().addMinutes(15);
        Datetime cutoffTime = now.addMinutes(40);
        return Database.getQueryLocator([SELECT Id, Name,LastName,Lead_URL__c,Email, Next_follow_up_date_time__c,Owner.Name,Owner.LastName,Owner.Email,OwnerId FROM Lead WHERE Next_follow_up_date_time__c >= :now AND Next_follow_up_date_time__c < :cutoffTime and IsConverted = false and OwnerId != : queueId]);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadList) {
        try{
            
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FollowUpTaskReminder'];
            EmailTemplate emailTemplateRec = [Select Id,HtmlValue,Subject From EmailTemplate where Name ='LeadFollowUpBeforeThirtyMin'];

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Lead leadRec : leadList) {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ leadRec.Owner.Email });
                email.setSubject(emailTemplateRec.Subject);
                email.setReplyTo(system.label.emailForReminders);
                Id orgId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where address =: system.label.emailForReminders].Id;
                email.setOrgWideEmailAddressId(orgId);
                string emailHtmlValue = emailTemplateRec.HtmlValue;

                emailHtmlValue = emailHtmlValue.replace('{!Lead.OwnerFullName}', leadRec.Owner.LastName);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Name}', leadRec.LastName);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Next_follow_up_date_time__c}', String.valueOf(leadRec.Next_follow_up_date_time__c));
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Lead_URL__c}', String.valueOf(leadRec.Lead_URL__c));

                email.setHtmlBody(emailHtmlValue);
                emails.add(email);
                
                if(notificationType != null){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Followup in 30 Mins');
                    notification.setBody('The following lead is scheduled for a follow-up within the next 30 minutes');
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(leadRec.id);
                    notification.send(new Set<String> {leadRec.OwnerId});
                }
            }
            if(!emails.isEmpty())
                Messaging.sendEmail(emails);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BatchToSendFollowupEmailThirtyMinLead', 'BatchToSendFollowupEmailThirtyMinLead', e, null);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}