public without sharing class Invoice_Receipt_PDF_Controller {
    public Receipt__c receiptRecord {get; set;} 
    public string studentname {get; set;} 
    public string phone {get; set;} 
    public string email {get; set;} 
    public string courseName {get; set;} 
    public string receiptNumber {get; set;} 
    public string invoiceNo {get; set;} 
    public String amount {get; set;} 
    public String previouslyPaidAmount {get; set;}
    public String totalPaidAmount {get; set;}
    public String dueAmount {get; set;}
    public string amountinwords {get; set;}
    public Date  receiptCreationDate {get; set;}
    
    
    public Invoice_Receipt_PDF_Controller() {
        try{
            id receiptId =  ApexPages.CurrentPage().getparameters().get('id');
            
            receiptRecord = [Select Invoice__r.Name,Invoice__r.Down_Payment__c,Amount__c,Invoice__r.Realized_Amount__c,Invoice__r.Due_Amount__c,Invoice__r.Opportunity__c,createdDate,Invoice__r.Opportunity__r.Amount, Invoice__r.Opportunity__r.Product_Name__c,Name,Invoice__r.Opportunity__r.Name, Invoice__r.Opportunity__r.Phone__c, Invoice__r.Opportunity__r.Email__c FROM Receipt__c where Id =: receiptId limit 1] ;
            studentname = receiptRecord.Invoice__r.Opportunity__r.Name ;
            phone = receiptRecord.Invoice__r.Opportunity__r.Phone__c ;
            email = receiptRecord.Invoice__r.Opportunity__r.Email__c ;
            courseName = receiptRecord.Invoice__r.Opportunity__r.Product_Name__c;
            invoiceNo = receiptRecord.Invoice__r.Name;
            receiptNumber = (receiptRecord.Name).split('-')[1];
            receiptCreationDate = (receiptRecord.CreatedDate).date();
            system.debug('receiptRecord.Amount__c--->'+receiptRecord.Amount__c);
            amount = String.ValueOf(receiptRecord.Amount__c);
            amountinwords = ConvertNumberInToWords.english_number(receiptRecord.Amount__c);
            if(receiptRecord.Invoice__r.Realized_Amount__c == null || receiptRecord.Invoice__r.Realized_Amount__c <=0 )
                previouslyPaidAmount = 'Nil';
            else
                previouslyPaidAmount = string.valueOf(receiptRecord.Invoice__r.Realized_Amount__c);
            totalPaidAmount = receiptRecord.Invoice__r.Realized_Amount__c != null ? String.ValueOf(receiptRecord.Invoice__r.Realized_Amount__c + receiptRecord.Amount__c) : string.valueOf(receiptRecord.Amount__c);
            dueAmount = string.valueOf(receiptRecord.Invoice__r.Opportunity__r.Amount - integer.valueOf(totalPaidAmount));	
        } catch(Exception e){
            System.debug('Error--'+e.getMessage() +' Line No ::'+e.getLineNumber());
        } 
    }
    
    @future(callout = true)
    public static void attachReceiptUnderRecord(set<Id> receiptIds){
        system.debug('receiptIds--->'+receiptIds);
        Map<Id, Blob> attachmentByReceiptid = new Map<Id, Blob>();
        List<Attachment> attachmentListToInsert = new List<Attachment>();
        List<Receipt__c> updatedReceiptsList = new List<Receipt__c>();
        List<Invoice__c> invoiceRecordsToUpdate = new List<Invoice__c>();
        
        if(!receiptIds.isEmpty()){
            updatedReceiptsList = [Select Id, Invoice__c,Invoice__r.Realized_Amount__c,Invoice__r.Due_Amount__c,Invoice__r.Amount__c,Amount__c From Receipt__c where Id in: receiptIds];
            for(Id receiptId : receiptIds){
                PageReference pdfPage = Page.Invoice_Receipt_PDFpage;
                pdfPage.getParameters().put('id', receiptId);
                Blob pdfBlob = pdfPage.getContent();
                attachmentByReceiptid.put(receiptId, pdfBlob);
            } 
            system.debug('attachmentByReceiptid-->'+attachmentByReceiptid);
            if(!attachmentByReceiptid.isEmpty()){
                for(Id receiptId : attachmentByReceiptid.keySet()){
                    system.debug('receiptId-->'+receiptId);
                    Attachment attachmentRecord = new Attachment(parentId = receiptId, Name = 'Receipt.pdf', body = attachmentByReceiptid.get(receiptId));
                    attachmentListToInsert.add(attachmentRecord);
                }
                system.debug('attachmentListToInsert--->'+attachmentListToInsert);
                if(!attachmentListToInsert.isEmpty()){
                    insert attachmentListToInsert;
                    if(!updatedReceiptsList.isEmpty()){
                        for(Receipt__c receiptRec : updatedReceiptsList){
                            system.debug('receiptRec.Invoice__r.Realized_Amount__c--->'+receiptRec.Invoice__r.Realized_Amount__c);
                            Invoice__c invoiceToUpdate = new Invoice__c();
                            invoiceToUpdate.Id = receiptRec.Invoice__c;
                            invoiceToUpdate.Realized_Amount__c = receiptRec.Invoice__r.Realized_Amount__c != null? receiptRec.Invoice__r.Realized_Amount__c + receiptRec.Amount__c : receiptRec.Amount__c;
                            invoiceToUpdate.Due_Amount__c = receiptRec.Invoice__r.Amount__c - invoiceToUpdate.Realized_Amount__c ;
                            invoiceRecordsToUpdate.add(invoiceToUpdate);
                        }
                        system.debug('invoiceRecordsToUpdate--->'+invoiceRecordsToUpdate);
                        if(!invoiceRecordsToUpdate.isEmpty()){
                            update invoiceRecordsToUpdate;
                        }
                    }
                }
                //sendReceiptForPayment(attachmentByReceiptid.keySet());
            }
        }
    }
    
    
    
    @future(callout = true)
    public static void attachSecondReceiptUnderRecord(set<Id> receiptIds){
        system.debug('receiptIds--->'+receiptIds);
        Map<Id, Blob> attachmentByReceiptid = new Map<Id, Blob>();
        List<Attachment> attachmentListToInsert = new List<Attachment>();
        List<Receipt__c> updatedReceiptsList = new List<Receipt__c>();
        List<Invoice__c> invoiceRecordsToUpdate = new List<Invoice__c>();
        
        if(!receiptIds.isEmpty()){
            updatedReceiptsList = [Select Id, Invoice__c,Invoice__r.Realized_Amount__c,Invoice__r.Due_Amount__c,Invoice__r.Amount__c,Amount__c From Receipt__c where Id in: receiptIds];
            for(Id receiptId : receiptIds){
                PageReference pdfPage = Page.Invoice_Receipt_PDFpage;
                pdfPage.getParameters().put('id', receiptId);
                Blob pdfBlob = pdfPage.getContent();
                attachmentByReceiptid.put(receiptId, pdfBlob);
            } 
            system.debug('attachmentByReceiptid-->'+attachmentByReceiptid);
            if(!attachmentByReceiptid.isEmpty()){
                for(Id receiptId : attachmentByReceiptid.keySet()){
                    system.debug('receiptId-->'+receiptId);
                    Attachment attachmentRecord = new Attachment(parentId = receiptId, Name = 'Receipt.pdf', body = attachmentByReceiptid.get(receiptId));
                    attachmentListToInsert.add(attachmentRecord);
                }
                system.debug('attachmentListToInsert--->'+attachmentListToInsert);
                if(!attachmentListToInsert.isEmpty()){
                    insert attachmentListToInsert;
                    if(!updatedReceiptsList.isEmpty()){
                        for(Receipt__c receiptRec : updatedReceiptsList){
                            system.debug('receiptRec.Invoice__r.Realized_Amount__c--->'+receiptRec.Invoice__r.Realized_Amount__c);
                            Invoice__c invoiceToUpdate = new Invoice__c();
                            invoiceToUpdate.Id = receiptRec.Invoice__c;
                            invoiceToUpdate.Realized_Amount__c = receiptRec.Invoice__r.Realized_Amount__c != null? receiptRec.Invoice__r.Realized_Amount__c + receiptRec.Amount__c : receiptRec.Amount__c;
                            invoiceToUpdate.Due_Amount__c = receiptRec.Invoice__r.Amount__c - invoiceToUpdate.Realized_Amount__c ;
                           // invoiceToUpdate.Do_Not_Send_Invoice__c = true;
                            invoiceRecordsToUpdate.add(invoiceToUpdate);
                        }
                        system.debug('invoiceRecordsToUpdate--->'+invoiceRecordsToUpdate);
                        if(!invoiceRecordsToUpdate.isEmpty()){
                            update invoiceRecordsToUpdate;
                        }
                    }
                }
                //sendReceiptForPayment(attachmentByReceiptid.keySet());
            }
        }
    }
    
    public static void sendReceiptForPayment(set<id> receiptsIds){
        try{
            system.debug('receiptsIds-->'+receiptsIds);
            List<Receipt__c> receiptList = new List<Receipt__c>();
            Map<Id,Attachment> attachmentByReceiptId = new Map<Id, Attachment>();
            EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name = 'Razorpay Success Receipt'];
            List<Attachment> attachmentUnderReceipts = [SELECT Name, Body, ContentType,createdDate,ParentId FROM Attachment WHERE ParentId in :receiptsIds];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Receipt__c> updateReceiptsList = new List<Receipt__c>();
            List<Invoice__c> invoiceRecordsToUpdate = new List<Invoice__c>();
            
            receiptList = [Select Id,Email__c, Invoice__r.Opportunity__r.Name,Invoice__r.Opportunity__r.Email__c,Amount__c From Receipt__c where Id in : receiptsIds];
            system.debug('receiptList--->'+receiptList);
            if(!attachmentUnderReceipts.isEmpty()){
                for(Attachment attachmentRec : attachmentUnderReceipts){
                    if(attachmentByReceiptId.containsKey(attachmentRec.ParentId)){
                        if(attachmentByReceiptId.get(attachmentRec.ParentId).CreatedDate < attachmentRec.CreatedDate){
                            attachmentByReceiptId.put(attachmentRec.ParentId, attachmentRec);
                        }
                    }else{
                        attachmentByReceiptId.put(attachmentRec.ParentId, attachmentRec);
                    }
                }
            }
            system.debug('receiptList--->'+receiptList);
            if (!receiptList.isEmpty()){
                for(Receipt__c receiptRecord : receiptList){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(attachmentByReceiptId.get(receiptRecord.Id).Name);
                    efa.setBody(attachmentByReceiptId.get(receiptRecord.Id).Body);
                    efa.setContentType(attachmentByReceiptId.get(receiptRecord.Id).ContentType);
                    system.debug('setBody -->'+attachmentByReceiptId.get(receiptRecord.Id).Body);
                    List<String> recipients = new List<String>();
                    system.debug('receiptRecord.Email__c-->'+receiptRecord.Email__c);
                    if(receiptRecord.Email__c != null){
                        recipients.add(receiptRecord.Email__c);
                        mail.setToAddresses(recipients);
                        mail.setReplyTo('test@email.com');
                        mail.setSenderDisplayName('Excelr');
                        String subject = et.Subject;
                        String htmlBody = et.HtmlValue;
                        htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
                        
                        if (htmlBody.contains('{!Opportunity.Account}')){
                            htmlBody = htmlBody.replace('{!Opportunity.Account}', receiptRecord.Invoice__r.Opportunity__r.Name);
                        }
                        
                        if (htmlBody.contains('{!Receipt.Amount__c}')){
                            htmlBody = htmlBody.replace('{!Receipt.Amount__c}', String.ValueOf(receiptRecord.Amount__c));
                        }
                        mail.setSubject(subject);
                        mail.setHtmlBody(htmlBody);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });
                        mails.add(mail);
                    }
                }
                system.debug('mails--->'+mails);
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            }
        } catch (Exception e){
            System.debug('Error Line==>' + e.getLineNumber() + 'Error Message==>' + e.getMessage());
        }
    }
}