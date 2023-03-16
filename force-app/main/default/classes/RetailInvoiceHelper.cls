global class RetailInvoiceHelper {
    global static CustomInformation__c getcustomData {get;set;} 
    global static Invoice__c getinvoiceData {get;set;}
    global static Opportunity getoppData {get;set;} 
    global static Account getAccData {get;set;} 
    global static List<OpportunityLineItem> getOLIData {get;set;} 
    global static Decimal PercentageTotal {get;set;}
    global static Decimal TotalAmountWithPercentage {get;set;}
    global static Decimal TotalTaXAmount {get;set;}
    global static String TotalTaXAmountInword {get;set;}
    global static String AmountTotalAmountWithPercentageInWords {get;set;}
    global static Integer wordAmount {get;set;}
    global static List<GST_State_Code__c> gstdata {get;set;}
    global static Decimal StateCode {get;set;}
    global static String currentState {get;set;}
    
    global String getOLIDataName {get;set;}
    global Decimal getInvoiceQuantity {get;set;}
    global Decimal getInvoiceTotalPrice {get;set;}
     
    global RetailInvoiceHelper(ApexPages.StandardController controller) {
        try{
        String recordId = '';
        String oppId = '';
        String AccId = '';
        Decimal TotalPrice = 0.0;
        Decimal Rate = 0.0;
         
        recordId = ApexPages.currentPage().getParameters().get('Id');

        getcustomData=[Select Name,Address__c,City__c,Pin_Code__c,State_Code__c,GSTIN__c,State_Name__c,EMail__c,Central_GST__c,State_GST__c,HSN_SAC__c,Rate__c from CustomInformation__c LIMIT 1];
        getinvoiceData = [Select Id,Name,Initiated_Date__c,Opportunity__c,Delivery_Note__c,Mode_Terms_of_Payment__c,Reference_No__c,Other_References__c,Amount__c from Invoice__c where Id=:recordId  LIMIT 1];
        

        if (getinvoiceData.Amount__c != null) {
            getInvoiceTotalPrice = ((getinvoiceData.Amount__c) * 100)/118;
            getInvoiceTotalPrice = getInvoiceTotalPrice.setScale(2);
            PercentageTotal = (getInvoiceTotalPrice *9)/100;
            PercentageTotal = PercentageTotal.setScale(2);
            AmountTotalAmountWithPercentageInWords = NumberToText.convert(Integer.valueOf(getInvoiceTotalPrice));
            TotalTaXAmount = (PercentageTotal * 2);
            TotalTaXAmountInword = NumberToText.convert(Integer.valueOf(TotalTaXAmount));
        }
        else{
            getInvoiceTotalPrice = 0.0;
            getInvoiceQuantity  = 0.0;
        }
        if(getinvoiceData.Opportunity__c != null)
            oppId= getinvoiceData.Opportunity__c;
        if(!string.isBlank(oppId) && !string.isEmpty(oppId))
            getoppData= [Select Id,AccountId,GST_State__c FROM Opportunity where Id=: oppId LIMIT 1];
        if(getoppData.AccountId != null){
            AccId= getoppData.AccountId;
            currentState = getoppData.GST_State__c;
        }
        
        
        gstdata = [SELECT Id,Name,State_Code__c	 FROM GST_State_Code__c];
        for(GST_State_Code__c gst : gstdata){
            if(gst.Name == currentState){
                System.debug('Name ::'+gst.Name);
                StateCode = gst.State_Code__c;
                System.debug('StateCode ::'+StateCode);
            }
        }
        if(!string.isBlank(AccId) && !string.isEmpty(AccId))
            getAccData= [Select Id,Name,Email__c,City__c,ShippingState,ShippingPostalCode,(Select Name,Email From Contacts) FROM Account where Id=: AccId LIMIT 1];     
        if(!string.isBlank(oppId) && !string.isEmpty(oppId)){
            getOLIData= [Select OpportunityId,Name,Quantity,Product2Id,TotalPrice,Product2.Name from OpportunityLineItem where OpportunityId =: oppId LIMIT 1];
            if(!getOLIData.isEmpty()){
                TotalPrice = getOLIData[0].TotalPrice;
                Rate = getcustomData.Rate__c;
                TotalAmountWithPercentage = TotalPrice + (PercentageTotal * 2);
                wordAmount =Integer.valueOf(TotalAmountWithPercentage);
                getOLIDataName = getOLIData[0].Product2.Name;
            }else{
                getOLIDataName = '';
            }
            
        }
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RetailInvoiceHelper', 'RetailInvoiceHelper', e , null);
       
    }
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
                
                Opportunity oppToMarkClosedWon = new Opportunity();
                oppToMarkClosedWon.Id = [Select Opportunity__c From Invoice__c where id =: recordId].Opportunity__c ;
                oppToMarkClosedWon.Can_Convert__c = true; 
                oppToMarkClosedWon.StageName = 'Closed Won';
                update oppToMarkClosedWon;
                
                pdfPage = Page.RetailInvoice_Attachment;
                pdfPage.getParameters().put('id', recordId);
               // pdfBlob = pdfPage.getContent();
                pdfBlob = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
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
            
        } catch (exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('RetailInvoiceHelper','attachPdf', e, null);
        }
    }
}