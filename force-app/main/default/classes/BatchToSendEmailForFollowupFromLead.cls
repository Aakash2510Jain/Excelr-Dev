global class BatchToSendEmailForFollowupFromLead implements Database.Batchable<SObject> {
  
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all leads with follow-up date and time within the next 15 minutes
        Datetime now = Datetime.now();
        Datetime cutoffTime = now.addMinutes(20);
        String query = 'SELECT Id, Name, Email, Next_follow_up_date_time__c FROM Lead WHERE Next_follow_up_date_time__c >= :now AND Next_follow_up_date_time__c < :cutoffTime';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Lead l : scope) {
            // Create email message with recipient, subject, and body
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ l.Email });
            email.setSubject('Reminder: Follow-up with ' + l.Name);
            email.setPlainTextBody('This is a friendly reminder to follow up with ' + l.Name + ' at ' + l.Next_follow_up_date_time__c.format('MM/dd/yyyy hh:mm a') + '.');
            emails.add(email);
        }
        // Send email messages
        Messaging.sendEmail(emails);
    }
    
    global void finish(Database.BatchableContext bc) {
        // Do nothing
    }
}