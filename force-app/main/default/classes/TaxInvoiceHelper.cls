global without sharing class TaxInvoiceHelper{
    public String InvoiceId{ get; set; }

    public Opportunity oppDetails{ get; set; }

    public Invoice__c invoiceRecord{ get; set; }

    public Company_Specifications__c companyDetails{ get; set; }

    public Lead leadDetails{ get; set; }

    global TaxInvoiceHelper(){
        InvoiceId = ApexPages.CurrentPage().getparameters().get('id');
        system.debug('InvoiceId-->' + InvoiceId);


        companyDetails = [Select Name__c, Address__c, SAC__c, CIN__c, Email__c, GSTIN__c, PAN__c, Phone__c
                          From Company_Specifications__c];
        system.debug('companyDetails-->' + companyDetails);
        invoiceRecord = [Select Opportunity__c, Name, Initiated_Date__c, Invoice_Due_Date__c, Amount__c, Opportunity__r.Description, Opportunity__r.Amount, LeadInvoice__c, LeadInvoice__r.Total_Amount__c, LeadInvoice__r.Product__r.ProductCode
                         From Invoice__c
                         where Id = :InvoiceId];
        system.debug('invoiceRecord-->' + invoiceRecord);

        if (invoiceRecord.Opportunity__c != null){
            oppDetails = [Select Id, Name, Account.Name, Account.Phone, Account.Email__c, Account.BillingStreet, Description, Amount, Account.BillingCity, Account.BillingState, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.BillingPostalCode, Account.BillingCountry, (Select Name, TotalPrice
                                                                                                                                                                                                                                                                                                                                      From OpportunityLineItems
                                                                                                                                                                                                                                                                                                                                      limit 1)
                          From Opportunity 
                          where id = :invoiceRecord.Opportunity__c];
        } else{

        }
        system.debug('oppDetails-->' + oppDetails);
    }

    @future(callout = true)
    global static void attachPdf(string recordId){

        try{
            String reciepientEmail;
            string userId = [Select Id
                             from User
                             where Name = 'RazorPayWebHookAPI Site Guest User'].Id;
            PageReference pdfPage;
            Blob pdfBlob;
            system.debug('UserInfo.getUserId()-->'+UserInfo.getUserId());
            
            if (UserInfo.getUserId() == userId){
                system.debug('Site User');

                Invoice_Attachment__e invAtt = new Invoice_Attachment__e();
                invAtt.Invoice__c = recordId;
                Database.SaveResult results = EventBus.publish(invAtt);
                if (results.isSuccess()){
                    System.debug('Successfully published event.');
                } else{
                    for (Database.Error err : results.getErrors()){
                        System.debug('Error returned: ' + err.getStatusCode() + 
                             ' - ' + err.getMessage());
                    }
                }
            } else{
                system.debug('Internal User');
                //internal user
                pdfPage = Page.TaxInvoice;
                pdfPage.getParameters().put('id', recordId);
                pdfBlob = pdfPage.getContent();

                Attachment attach = new Attachment(parentId = recordId, Name = 'PaymentReceipt.pdf', body = pdfBlob);
                insert attach;
                reciepientEmail = [Select LeadInvoice__r.Email
                                   From Invoice__c
                                   where Id = :recordId].LeadInvoice__r.Email;
                system.debug('reciepientEmail :: ' + reciepientEmail);
                if (!string.isBlank(reciepientEmail)){
                    EmailIUtility.sendEmailForPaymentSuccess(reciepientEmail, 'Razor Pay Success Status Opportunity', 'Opportunity', recordId);
                }
            }

        } catch (exception ex){
            system.debug('Error-->' + ex.getLineNumber());
            system.debug('Error-->>' + ex.getMessage());
        }
    }

}