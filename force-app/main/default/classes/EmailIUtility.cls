public without sharing class EmailIUtility{
    public static void sendEmailForPaymentSuccess(string email, String templateName, String objName, string invoiceId){
        try{
            //Invoice__c invDetails = [select name,Due_Date__c from Invoice__c where Account__r.id =:accId ORDER BY lastmodifieddate DESC limit 1];
            List<Invoice__c> invoiceDetails = new List<Invoice__c>();
            List<Lead> leadList = new List<Lead>();
            system.debug('email-->' + email);
            system.debug('invoiceId-->' + invoiceId);
            EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue
                                from EmailTemplate
                                where name = :templateName];
            Attachment files = [SELECT Name, Body, ContentType
                                FROM Attachment
                                WHERE ParentId = :invoiceId
                                ORDER BY lastmodifieddate DESC
                                limit 1];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            system.debug('mails' + mails);
            if (objName == 'Opportunity'){
                invoiceDetails = [Select Id, Opportunity__r.Account.Name, Opportunity__r.Account.Email__c, Amount__c, Opportunity__r.Amount
                                  FROM Invoice__c
                                  Where Id = :invoiceId
                                  limit 1];
            } else if (objName == 'Lead'){
                leadList = [SELECT Id, Name, Email
                            FROM Lead
                            WHERE Id = :invoiceId];
            }
            if (!String.isBlank(email)){
                // Step 1
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(files.Name);
                efa.setBody(files.Body);
                efa.setContentType(files.ContentType);

                List<String> recipients = new List<String>();
                recipients.add(email);
                system.debug('recipients------' + recipients);
                mail.setToAddresses(recipients);
                mail.setReplyTo('test@email.com');
                mail.setSenderDisplayName('Excelr');
                String subject = et.Subject;
                String htmlBody = et.HtmlValue;
                htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());

                if (htmlBody.contains('{!Account.Name}')){
                    htmlBody = htmlBody.replace('{!Account.Name}', invoiceDetails[0].Opportunity__r.Account.Name);
                }

                if (htmlBody.contains('{!Opportunity.Amount}')){
                    htmlBody = htmlBody.replace('{!Opportunity.Amount}', String.ValueOf(invoiceDetails[0].Opportunity__r.Amount) != null ? String.ValueOf(invoiceDetails[0].Opportunity__r.Amount) : '');
                }
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });
                mails.add(mail);
                system.debug('mails :: ' + mails);
            }
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Error Line==>' + e.getLineNumber() + 'Error Message==>' + e.getMessage());
        }
    }

    public static void SendReferralFormToReferrar(map<id,Invoice__c> ReferrarNameWithEmail){

        System.debug('ReferrarNameWithEmail ====> ' + ReferrarNameWithEmail);
        try{
            if (!ReferrarNameWithEmail.isEmpty()){
                EmailTemplate BankDetailsEmailTemp = [Select id, Name, DeveloperName, Subject, Body, HtmlValue
                                                      from EmailTemplate
                                                      where name = 'Bank Detail Link Send To Referrar'];

                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                //List<String> allrecipients = new List<String>();
                for (Invoice__c Inv : ReferrarNameWithEmail.values()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> recipients = new List<String>();
                    recipients.add(Inv.Referrer_Email__c);
                    System.debug('recipients ====> ' + recipients);
                    mail.setToAddresses(recipients);
                    mail.setReplyTo('Excelr@info.com');
                    mail.setSenderDisplayName('Excelr');
                    String subject = BankDetailsEmailTemp.Subject;
                    String htmlBody = BankDetailsEmailTemp.HtmlValue;
                    System.debug('htmlBody ====> ' + htmlBody);
                    System.debug('referrar Name ===>' + ReferrarNameWithEmail.get(Inv.id).Referral_Name__c);

                    if (htmlBody.contains('{!Invoice__c.Referral_Name__c}')){
                        htmlBody = htmlBody.replace('{!Invoice__c.Referral_Name__c}', ReferrarNameWithEmail.get(Inv.id).Referral_Name__c);
                    }
                    if (htmlBody.contains('{!referrarinvoiceId}')){
                        htmlBody = htmlBody.replace('{!referrarinvoiceId}', ReferrarNameWithEmail.get(Inv.Id).Id);
                    }
                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlBody);
                    mails.add(mail);
                    System.debug('mails =====> ' + mails);
                }

                if (!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }


            }

        } catch (Exception e){

        }
    }

    public static void sendExceptions(Exceptions__c exceps){
        //Error Template
        try{
        EmailTemplate ErrorEmailtemplate = [Select id, Name, DeveloperName, Subject, Body, HtmlValue
                                            from EmailTemplate
                                            where name = 'Error Template'];
        String Email = 'aakash.jain@utilitarianLab.com';
        String Email2 = 'mukesh.chawla@utilitarianLab.com';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> recipients = new List<String>();
        recipients.add(Email);
        recipients.add(Email2);
        System.debug('recipients ====> ' + recipients);
        mail.setToAddresses(recipients);
        mail.setReplyTo('Excelr@info.com');
        mail.setSenderDisplayName('Excelr');
        String subject = ErrorEmailtemplate.Subject;
        String htmlBody = ErrorEmailtemplate.HtmlValue;
        //System.debug('htmlBody ====> ' + htmlBody);
        //System.debug('referrar Name ===>' + ReferrarNameWithEmail.get(Email));

        if (htmlBody.contains('{!Exceptions__c.Class_Name__c}')){
            htmlBody = htmlBody.replace('{!Exceptions__c.Class_Name__c}', exceps.Class_Name__c);
        }
        if (htmlBody.contains('{!Exceptions__c.Error_Message__c}')){
            htmlBody = htmlBody.replace('{!Exceptions__c.Error_Message__c}', exceps.Error_Message__c);
        }
        if (htmlBody.contains('{!Exceptions__c.Error_Line_No__c}')){
            htmlBody = htmlBody.replace('{!Exceptions__c.Error_Line_No__c}', String.valueof(exceps.Error_Line_No__c));
        }
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        System.debug('mails =====> ' + mails);

        if (!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('EmailIUtility', 'sendExceptions', e , null);
       
    }
}

}