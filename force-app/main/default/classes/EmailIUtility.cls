public without sharing class EmailIUtility{
    public static void sendEmailForPaymentSuccess(string email, String templateName, String objName, string invoiceId){
        try{
            //Invoice__c invDetails = [select name,Due_Date__c from Invoice__c where Account__r.id =:accId ORDER BY lastmodifieddate DESC limit 1];
            List<Invoice__c> invoiceDetails = new List<Invoice__c>();
            List<Lead> leadList = new List<Lead>();
            system.debug('email-->' + email);
            system.debug('invoiceId-->' + invoiceId);
            system.debug('objName---<>'+objName);
            EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name = :templateName];
            Attachment files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId = :invoiceId ORDER BY lastmodifieddate DESC limit 1];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            system.debug('files' + files);
            if (objName == 'Opportunity'){
                invoiceDetails = [Select Id, Opportunity__r.Name, Opportunity__r.Email__c,Opportunity__r.Account.Name, Amount__c, Opportunity__r.Amount FROM Invoice__c Where Id = :invoiceId limit 1];
            } else if (objName == 'Lead'){
                leadList = [SELECT Id, Name, Email FROM Lead WHERE Id = :invoiceId];
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
            }
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Error Line==>' + e.getLineNumber() + 'Error Message==>' + e.getMessage());
        }
    }
    
    public static void sendEmailWithReceiptAndInvoice(Set<Id> opportunityIds, String templateName){
        try{
            system.debug('opportunityIds--->'+opportunityIds);
            Set<Id> invoiceIds = new Set<Id>();
            Set<Id> receiptIds = new Set<Id>();
            List<Attachment> attachmentList = new List<Attachment>();
            List<Invoice__c> invoiceListToBeForwarded = new List<Invoice__c>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Map<string, Attachment> attachmentByParentId = new Map<String, Attachment>();
            
            invoiceListToBeForwarded = [Select Id,Opportunity__r.Email__c,Opportunity__r.Amount,Opportunity__r.Account.Name,(Select Id from Receipts__r where Receipt_Status__c = 'Received/Paid') From Invoice__c where Id in : opportunityIds];
            EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name = :templateName];
            
            if(!invoiceListToBeForwarded.isEmpty()){
                for(Invoice__c invoiceRec : invoiceListToBeForwarded){
                    invoiceIds.add(invoiceRec.Id);
                    for(Receipt__c receiptRec : invoiceRec.Receipts__r){
                        receiptIds.add(receiptRec.Id);
                    }
                }
                attachmentList = [SELECT Name, Body, ParentId,ContentType FROM Attachment WHERE ParentId IN :invoiceIds or ParentId IN :receiptIds];
                if(!attachmentList.isEmpty()){
                    for(Attachment attachmentRec : attachmentList){
                        attachmentByParentId.put(attachmentRec.ParentId, attachmentRec);
                    }
                    for(Invoice__c invoiceRec : invoiceListToBeForwarded){
                        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        Messaging.EmailFileAttachment attachment1 = new Messaging.EmailFileAttachment();
                        attachment1.setFileName(attachmentByParentId.get(invoiceRec.Id).Name);
                        attachment1.setBody(attachmentByParentId.get(invoiceRec.Id).Body);
                        attachment1.setContentType(attachmentByParentId.get(invoiceRec.Id).ContentType);
                        attachments.add(attachment1);
                        
                        Messaging.EmailFileAttachment attachment2 = new Messaging.EmailFileAttachment();
                        attachment2.setFileName(attachmentByParentId.get(invoiceRec.Receipts__r[0].Id).Name);
                        attachment2.setBody(attachmentByParentId.get(invoiceRec.Receipts__r[0].Id).Body);
                        attachment2.setContentType(attachmentByParentId.get(invoiceRec.Receipts__r[0].Id).ContentType);
                        attachments.add(attachment2);
                        
                        mail.setFileAttachments(attachments);
                        List<String> recipients = new List<String>();
                        recipients.add(invoiceRec.Opportunity__r.Email__c);
                        mail.setToAddresses(recipients);
                        mail.setReplyTo('test@email.com');
                        mail.setSenderDisplayName('Excelr');
                        String subject = et.Subject;
                        String htmlBody = et.HtmlValue;
                        htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
                        
                        if (htmlBody.contains('{!Account.Name}')){
                            htmlBody = htmlBody.replace('{!Account.Name}', invoiceRec.Opportunity__r.Account.Name);
                        }
                        
                        mail.setSubject(subject);
                        mail.setHtmlBody(htmlBody);
                        mails.add(mail);
                        system.debug('mails :: ' + mails);
                    }
                    if(!mails.isEMpty()){
                        Messaging.sendEmail(mails);
                    }
                }
            }
        }catch (Exception e){
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
            String Email3 = 'anjali.singh@utilitarianlab.com';
            String Email4 = 'himanshu.tripathi@utilitarianLab.com';
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> recipients = new List<String>();
            recipients.add(Email);
            recipients.add(Email2);
            recipients.add(Email3);
            recipients.add(Email4);
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
    public static void sendInvoiceAndReceiptAsAttach(Set<Id> opportunityIds, String templateName){
        try{
            system.debug('opportunityIds--->'+opportunityIds);
            Set<Id> invoiceIds = new Set<Id>();
            Set<Id> receiptIds = new Set<Id>();
            List<Attachment> attachmentList = new List<Attachment>();
            List<Attachment> attachmentListUnderReceipt = new List<Attachment>();
            List<Invoice__c> invoiceListToBeForwarded = new List<Invoice__c>();
            List<Receipt__c> receiptListToBeForwarded = new List<Receipt__c>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Map<string, Attachment> attachmentByParentId = new Map<String, Attachment>();
            Map<String, Attachment> opportunityIdByInvoiceAttachment = new Map<String, Attachment>();
            Map<String, string> opportunityIdByInvoiceId = new Map<String, String>();
            Map<String, Receipt__c> opportunityIdByReceiptRecord = new Map<String, Receipt__c>();
            Map<Id, Opportunity> opportunityRecordMap = new Map<Id,Opportunity>([Select Id,Email__c,Account.Name,Owner.Name FRom Opportunity where Id in:opportunityIds]);
            
            invoiceListToBeForwarded = [Select Id,Opportunity__r.Email__c,Opportunity__r.Amount,Opportunity__r.Account.Name From Invoice__c where Opportunity__c in : opportunityIds order by CreatedDate DESC];
            receiptListToBeForwarded = [Select Id,Invoice__r.Opportunity__c,LastModifiedDate from Receipt__c where Receipt_Status__c = 'Received/Paid' AND Opportunity_Id__c in : opportunityIds order by CreatedDate DESC];
            EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name = :templateName];
            
            system.debug('invoiceListToBeForwarded-->'+invoiceListToBeForwarded);
            system.debug('receiptListToBeForwarded-->'+receiptListToBeForwarded);
                        
            if(!invoiceListToBeForwarded.isEmpty()){
                for(Invoice__c invoiceRec : invoiceListToBeForwarded){
                    opportunityIdByInvoiceId.put(invoiceRec.Opportunity__c , invoiceRec.Id);
                }
            }
            if(!receiptListToBeForwarded.isEmpty()){
                for(Receipt__c receiptRec : receiptListToBeForwarded){
                    system.debug('receiptRec--->'+receiptRec);
                    receiptIds.add(receiptRec.Id);
                    if(opportunityIdByReceiptRecord.containsKey(receiptRec.Invoice__r.Opportunity__c) && opportunityIdByReceiptRecord.get(receiptRec.Invoice__r.Opportunity__c).LastModifiedDate < receiptRec.LastModifiedDate)
                        opportunityIdByReceiptRecord.put(receiptRec.Invoice__r.Opportunity__c,receiptRec);
                    else
                        opportunityIdByReceiptRecord.put(receiptRec.Invoice__r.Opportunity__c,receiptRec);
                }
            }
            system.debug('opportunityIdByInvoiceId--->'+opportunityIdByInvoiceId);
            system.debug('opportunityIdByReceiptRecord--->'+opportunityIdByReceiptRecord);
            system.debug('receiptIds--->'+receiptIds);

            attachmentList = [SELECT Name, Body, ParentId,ContentType,createdDate FROM Attachment WHERE ParentId IN :opportunityIdByInvoiceId.values() or ParentId IN :receiptIds order By CreatedDate ASC];
            system.debug('attachmentList--->'+attachmentList);
            
            if(!attachmentList.isEmpty()){
                for(Attachment attachmentRec : attachmentList){
                    system.debug('attachmentRec--->'+attachmentRec);
                    if(attachmentByParentId.containsKey(attachmentRec.ParentId) && attachmentByParentId.get(attachmentRec.ParentId).createdDate < attachmentRec.createdDate)
                        attachmentByParentId.put(attachmentRec.ParentId, attachmentRec);
                    else
                        attachmentByParentId.put(attachmentRec.ParentId, attachmentRec);
                  
                    system.debug('attachmentByParentId.containsKey(attachmentRec.ParentId).Name-->'+attachmentByParentId.get(attachmentRec.ParentId).Name);
                    system.debug('attachmentByParentId.get(attachmentRec.ParentId).createdDate-->'+attachmentByParentId.get(attachmentRec.ParentId).createdDate);
                    system.debug('attachmentRec.createdDate-->'+attachmentRec.createdDate);

                }
                
            }
            for(Id oppId : opportunityIds){
                system.debug('oppId--->'+oppId);
                system.debug('opportunityIdByInvoiceId.get(oppId)---->'+opportunityIdByInvoiceId.get(oppId));
                system.debug('attachmentByParentId.get(opportunityIdByInvoiceId.get(oppId)).Name--->'+attachmentByParentId.get(opportunityIdByInvoiceId.get(oppId)).Name);
                
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                Messaging.EmailFileAttachment invoiceAttach = new Messaging.EmailFileAttachment();
                invoiceAttach.setFileName( attachmentByParentId.get(opportunityIdByInvoiceId.get(oppId)).Name);
                invoiceAttach.setBody(attachmentByParentId.get(opportunityIdByInvoiceId.get(oppId)).Body);
                invoiceAttach.setContentType(attachmentByParentId.get(opportunityIdByInvoiceId.get(oppId)).ContentType);
                attachments.add(invoiceAttach);
                
                Messaging.EmailFileAttachment receiptAttachment = new Messaging.EmailFileAttachment();
                receiptAttachment.setFileName(attachmentByParentId.get(opportunityIdByReceiptRecord.get(oppId).Id).Name);
                receiptAttachment.setBody(attachmentByParentId.get(opportunityIdByReceiptRecord.get(oppId).Id).Body);
                receiptAttachment.setContentType(attachmentByParentId.get(opportunityIdByReceiptRecord.get(oppId).Id).ContentType);
                attachments.add(receiptAttachment);
                
                mail.setFileAttachments(attachments);
                List<String> recipients = new List<String>();
                recipients.add(opportunityRecordMap.get(oppId).Email__c);
                mail.setToAddresses(recipients);
                mail.setReplyTo('test@email.com');
                mail.setSenderDisplayName('Excelr');
                String subject = et.Subject;
                String htmlBody = et.HtmlValue;
                htmlBody = htmlBody.replace('{!Opportunity.OwnerName}', opportunityRecordMap.get(oppId).Owner.Name);
                
                if (htmlBody.contains('{!Account.Name}')){
                    htmlBody = htmlBody.replace('{!Account.Name}', opportunityRecordMap.get(oppId).Account.Name);
                }
                
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mails.add(mail);
                system.debug('mails :: ' + mails);
            }
            if(!mails.isEMpty()){
                Messaging.sendEmail(mails);
            }
        }catch (Exception e){
            System.debug('Error Line==>' + e.getLineNumber() + 'Error Message==>' + e.getMessage());
        }
    }
}