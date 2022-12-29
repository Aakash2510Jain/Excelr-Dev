global class RetailInvoiceHelper {
    global CustomInformation__c getcustomData {get;set;} 
    global Invoice__c getinvoiceData {get;set;}
    global Opportunity getoppData {get;set;} 
    global Account getAccData {get;set;} 
    global OpportunityLineItem getOLIData {get;set;} 
    global Decimal PercentageTotal {get;set;}
    global Decimal TotalAmountWithPercentage {get;set;}
    global Decimal TotalTaXAmount {get;set;}
    global String AmountTotalAmountWithPercentageInWords {get;set;}
    global Integer wordAmount {get;set;}
    global List<GST_State_Code__c> gstdata {get;set;}
    global Decimal StateCode {get;set;}
    global String currentState {get;set;}
    global RetailInvoiceHelper(ApexPages.StandardController controller) {
        
        getcustomData=[Select Name,Address__c,City__c,Pin_Code__c,State_Code__c,GSTIN__c,State_Name__c,EMail__c,Central_GST__c,State_GST__c,HSN_SAC__c,Rate__c from CustomInformation__c LIMIT 1];
        String recordId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('recordId:'+recordId);
        
       
        
        getinvoiceData = [Select Id,Name,Initiated_Date__c,Opportunity__c,Delivery_Note__c,Mode_Terms_of_Payment__c,Reference_No__c,Other_References__c from Invoice__c where Id=:recordId LIMIT 1];
        String oppId= getinvoiceData.Opportunity__c;
        system.debug('oppId ::'+oppId);
        
        getoppData= [Select Id,AccountId,GST_State__c FROM Opportunity where Id=: oppId LIMIT 1];
        String AccId= getoppData.AccountId;
        currentState = getoppData.GST_State__c;
        
         gstdata = [SELECT Id,Name,State_Code__c	 FROM GST_State_Code__c];
        for(GST_State_Code__c gst : gstdata){
            if(gst.Name == currentState){
                System.debug('Name ::'+gst.Name);
                StateCode = gst.State_Code__c;
                System.debug('StateCode ::'+StateCode);
            }
        }
        
        getAccData= [Select Id,Name,Email__c,ShippingState,ShippingPostalCode FROM Account where Id=: AccId LIMIT 1];     
        
        getOLIData= [Select OpportunityId,Name,Quantity,Product2Id,TotalPrice from OpportunityLineItem where OpportunityId=:oppId LIMIT 1];
              
        Decimal TotalPrice = getOLIData.TotalPrice;
        Decimal Rate = getcustomData.Rate__c;
        PercentageTotal = (TotalPrice) * (Rate) / 100;
        TotalAmountWithPercentage = TotalPrice + (PercentageTotal * 2);
        wordAmount =Integer.valueOf(TotalAmountWithPercentage);
        AmountTotalAmountWithPercentageInWords = NumberToText.convert(wordAmount);
        TotalTaXAmount = (PercentageTotal * 2);
      
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
                pdfPage = Page.RetailInvoice_Attachment;
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