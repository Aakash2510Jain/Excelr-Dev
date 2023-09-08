public class BatchForPendingInvoiceReminder implements Database.Batchable<sobject>{
    public static Database.QueryLocator start(Database.BatchableContext bc){
        DateTime currentTime = system.now();
        DateTime currentTimePlusFifteenMins = currentTime.addMinutes(15);
        
        return database.getQueryLocator([Select Id,Next_Followup_Date_Time__c,Owner.Email,Owner.Id from Invoice__c where Next_Followup_Date_Time__c >= : currentTime and Next_Followup_Date_Time__c <= : currentTimePlusFifteenMins]);
    }
    public void execute(Database.BatchableContext bc, List<Invoice__c> invoiceList){
        EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name = 'Pending Invoice Reminder'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        if(!invoiceList.isEmpty()){
           /* for(Invoice__c invoiceRec : invoiceList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> recipients = new List<String>();
                recipients.add(invoiceRec.Owner.Email);
                system.debug('recipients------' + recipients);
                mail.setToAddresses(recipients);
                mail.setReplyTo('test@email.com');
                mail.setSenderDisplayName('Excelr');
                String subject = et.Subject;
                String htmlBody = et.HtmlValue;
                htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
                
                
                    if(objName == 'Opportunity')
                        htmlBody = htmlBody.replace('{!Account.Name}', invoiceDetails[0].Opportunity__r.Account.Name);
                    if(objName == 'Lead')
                        htmlBody = htmlBody.replace('{!Account.Name}', leadList[0].Name);
                }
                
                if (htmlBody.contains('{!Opportunity.Amount}')){
                    htmlBody = htmlBody.replace('{!Opportunity.Amount}', String.ValueOf(invoiceDetails[0].Opportunity__r.Amount) != null ? String.ValueOf(invoiceDetails[0].Opportunity__r.Amount) : '');
                }
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                system.debug('efa--->'+efa);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });
                mails.add(mail);
                system.debug('mails :: ' + mails);
                
            }*/
        }
    }
    public void finish(Database.BatchableContext bc){
        
    }
}