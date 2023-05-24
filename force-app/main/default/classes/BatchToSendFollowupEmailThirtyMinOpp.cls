/**
 * @author Aakash Jain
 * @email aakash.jain@utilitarianlab.com
 * @create date 19-05-2023 12:07:30
 * @modify date 19-05-2023 12:07:30
 * @desc [description]
 */
global class BatchToSendFollowupEmailThirtyMinOpp implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now().addMinutes(15);
        Datetime cutoffTime = now.addMinutes(40);
        return Database.getQueryLocator([SELECT Id, Name,Email__C,Opportunity_URL__c, Next_follow_up_date_time__c,Owner.Name,Owner.LastName,Owner.Email,ownerid FROM Opportunity WHERE Next_follow_up_date_time__c >= :now AND Next_follow_up_date_time__c < :cutoffTime ]);
    }
    
    global void execute(Database.BatchableContext bc, List<opportunity> opportunityList) {
        try{
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FollowUpTaskReminder'];
            EmailTemplate emailTemplateRec = [Select Id,HtmlValue,Subject From EmailTemplate where Name ='OppFollowUpBeforeThirtyMin'];

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Opportunity oppRec : opportunityList) {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ oppRec.Owner.Email });
                email.setSubject(emailTemplateRec.Subject);
                email.setReplyTo(system.label.emailForReminders);
                Id orgId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where address =: system.label.emailForReminders].Id;
                email.setOrgWideEmailAddressId(orgId);
                string emailHtmlValue = emailTemplateRec.HtmlValue;
                
                emailHtmlValue = emailHtmlValue.replace('{!Lead.OwnerFullName}', oppRec.Owner.LastName);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Name}', oppRec.Name);
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Next_follow_up_date_time__c}', String.valueOf(oppRec.Next_follow_up_date_time__c));
                emailHtmlValue = emailHtmlValue.replace('{!Lead.Lead_URL__c}', String.valueOf(oppRec.Opportunity_URL__c));

                email.setHtmlBody(emailHtmlValue);
                emails.add(email);
                if(notificationType != null){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Followup in 30 Mins');
                    notification.setBody('The following lead is scheduled for a follow-up within the next 30 minutes');
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
            HandleBusinessException.captureError('BatchToSendFollowupEmailThirtyMinOpp', 'BatchToSendFollowupEmailThirtyMinOpp', e, null);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}