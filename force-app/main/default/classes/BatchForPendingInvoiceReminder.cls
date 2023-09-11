public class BatchForPendingInvoiceReminder implements Database.Batchable<sobject>{
    public static Database.QueryLocator start(Database.BatchableContext bc){
        DateTime currentTime = system.now();
        DateTime currentTimePlusFifteenMins = currentTime.addMinutes(15);
        
        return database.getQueryLocator([Select Id,Next_Followup_Date_Time__c,Owner.Email,Owner.Id,Owner.Name,Invoice_Url__c,Due_Amount__c,Reminder_Email_Send__c from Invoice__c where Next_Followup_Date_Time__c >= : currentTime and Next_Followup_Date_Time__c <= : currentTimePlusFifteenMins AND Due_Amount__c > 1]);
    }
    public void execute(Database.BatchableContext bc, List<Invoice__c> invoiceList){
        EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name = 'Pending Invoice Reminder'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Invoice__c> invoiceListToUpdate = new List<Invoice__c>();
        
        if(!invoiceList.isEmpty()){
            for(Invoice__c invoiceRec : invoiceList){
                Invoice__c invoiceRecToUpdate = new Invoice__c();
                invoiceRecToUpdate.Reminder_Email_Send__c = true;
                invoiceListToUpdate.add(invoiceRecToUpdate);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> recipients = new List<String>();
                recipients.add(invoiceRec.Owner.Email);
                system.debug('recipients------' + recipients);
                mail.setToAddresses(recipients);
                mail.setReplyTo('test@email.com');
                mail.setSenderDisplayName('Excelr');
                String subject = et.Subject;
                String htmlBody = et.HtmlValue;

                htmlBody = htmlBody.replace('{!Invoice.OwnerName}', invoiceRec.Owner.Name);
                htmlBody = htmlBody.replace('{!invoice.Link}', invoiceRec.Invoice_Url__c);
                if(invoiceRec.Due_Amount__c != null){
                    htmlBody = htmlBody.replace('{!Invoice.DueAmount}', string.valueOf(invoiceRec.Due_Amount__c));
                }

                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                
                mails.add(mail);
                system.debug('mails :: ' + mails);
                
            }
            if(!mails.isEMpty()){
                Messaging.sendEmail(mails);
            }
            if(!invoiceListToUpdate.isEmpty()){
                update invoiceListToUpdate;
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        
    }
}