global without sharing class RetailInvoiceHelper {
    global static CustomInformation__c getcustomData {get;set;} 
    global static Invoice__c getinvoiceData {get;set;}
    global static Opportunity getoppData {get;set;} 
    global static Account getAccData {get;set;} 
    global static List<OpportunityLineItem> getOLIData {get;set;} 
    global static Decimal PercentageTotal {get;set;}
    global static Decimal PercentageTotalInterstate {get;set;}
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
    
    global String opportunityName {get;set;}
    global String opportunityEmail {get;set;}
    global String opportunityGSTState {get;set;}
    global Date invoiceInitiatedDate {get;set;}
    global String invoiceTotalAmount {get;set;}
    
    global static List<Receipt__c> receiptList {get;set;}
    //global static List<wrapReceipt> wrapReceiptList {get;set;}

    global RetailInvoiceHelper(ApexPages.StandardController controller) {
        try{
            String recordId;
            String oppId;
            String AccId;
            Decimal TotalPrice = 0.0;
            Decimal Rate = 0.0;
            
            recordId = ApexPages.currentPage().getParameters().get('Id');
            
            getcustomData=[Select Name,InterState_Rate__c,Address__c,InterState_GST__c,City__c,Pin_Code__c,State_Code__c,GSTIN__c,State_Name__c,EMail__c,Central_GST__c,State_GST__c,HSN_SAC__c,Rate__c from CustomInformation__c LIMIT 1];
            getinvoiceData = [Select Id,Opportunity__r.Email__c,Opportunity__r.Amount,Due_Amount__c,Opportunity__r.GST_State__c,Opportunity__r.Product_Name__c,Opportunity__r.Name,Name,Initiated_Date__c,Opportunity__c,Delivery_Note__c,Mode_Terms_of_Payment__c,Reference_No__c,Other_References__c,Amount__c from Invoice__c where Id=:recordId  LIMIT 1];
            gstdata = [SELECT Id,Name,State_Code__c	 FROM GST_State_Code__c];
            system.debug('getinvoiceData.Opportunity__c--->'+getinvoiceData.Opportunity__c);
                
            receiptList = [Select Id,Name,Receipt_Created_Date__c,Invoice__r.Name,Invoice_Created_Date__c,Amount__c,Type__c,Custom_Auto_Number__c From Receipt__c Where Opportunity_Id__c =: getinvoiceData.Opportunity__c AND Receipt_Status__c = 'Received/Paid'];
            system.debug('receiptList--->'+receiptList);
            opportunityName = getinvoiceData.Opportunity__r.Name;
            opportunityEmail = getinvoiceData.Opportunity__r.Email__c;
            opportunityGSTState = getinvoiceData.Opportunity__r.GST_State__c;
            invoiceInitiatedDate = getinvoiceData.Initiated_Date__c;
            
       // code for wrappper Receipt Object    
       /*     if(wrapReceiptList == null){
                wrapReceiptList = new List<wrapReceipt>();
                for(Receipt__c  r :[Select Id,Name,Receipt_Created_Date__c,Invoice__r.Name,Invoice_Created_Date__c,Amount__c,Type__c From Receipt__c Where Opportunity_Id__c =: getinvoiceData.Opportunity__c AND Receipt_Status__c = 'Received/Paid']){
                    wrapReceiptList.add(new wrapReceipt(r));
                }
            }*/
                    
            if (getinvoiceData.Amount__c != null) {
                invoiceTotalAmount = string.valueOf(getinvoiceData.Amount__c);
                getInvoiceTotalPrice = ((getinvoiceData.Amount__c) * 100)/118;
                getInvoiceTotalPrice = getInvoiceTotalPrice.setScale(2);
                PercentageTotal = (getInvoiceTotalPrice *9)/100;
                PercentageTotal = PercentageTotal.setScale(2);
                PercentageTotalInterstate = (getInvoiceTotalPrice *18)/100;
                PercentageTotalInterstate = PercentageTotalInterstate.setScale(2);
                AmountTotalAmountWithPercentageInWords = NumberToText.convert(Integer.valueOf(getinvoiceData.Amount__c));
                TotalTaXAmount = (PercentageTotal * 2);
                TotalTaXAmountInword = NumberToText.convert(Integer.valueOf(TotalTaXAmount));
            }else{
                getInvoiceTotalPrice = 0.0;
                getInvoiceQuantity  = 0.0;
            }
            currentState = getinvoiceData.Opportunity__r.GST_State__c != null ?getinvoiceData.Opportunity__r.GST_State__c:'' ;
            
            for(GST_State_Code__c gst : gstdata){
                if(gst.Name == currentState){
                    StateCode = gst.State_Code__c;
                }
            }
            TotalPrice = getinvoiceData.Opportunity__r.Amount;
            Rate = getcustomData.Rate__c;
            TotalAmountWithPercentage = TotalPrice + (PercentageTotal * 2);
            wordAmount =Integer.valueOf(getinvoiceData.Amount__c);
            getOLIDataName = getinvoiceData.Opportunity__r.Product_Name__c!= null ?getinvoiceData.Opportunity__r.Product_Name__c:'';
            
        }
        catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RetailInvoiceHelper', 'RetailInvoiceHelper', e , null);
            
        }
    }
    @future(callout=true)
    global static void attachPdf(string recordId){
        system.debug('recordId---->'+recordId);
        try{
            String reciepientEmail;
            PageReference pdfPage;
            Blob pdfBlob;
            string userId = [Select Id from User where Name = 'RazorPayWebHookAPI Site Guest User'].Id;
            
            system.debug('UserInfo.getUserId()-->'+UserInfo.getUserId());
            system.debug('userId--->'+userId);
            
            if (UserInfo.getUserId() == userId){
                system.debug('Site User');
                Invoice_Attachment__e invAtt = new Invoice_Attachment__e();
                invAtt.Invoice__c = recordId;
                Database.SaveResult results = EventBus.publish(invAtt);
                
            } else{
                system.debug('Internal User');
                //internal user
                
                pdfPage = Page.RetailInvoice_Attachment;
                pdfPage.getParameters().put('id', recordId);
                pdfBlob = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
                Attachment attach = new Attachment(parentId = recordId, Name = 'PaymentReceipt.pdf', body = pdfBlob);
                insert attach;
                system.debug('recordId---->'+recordId);
                Opportunity oppToMarkClosedWon = new Opportunity();
                oppToMarkClosedWon.Id = [Select Opportunity__c From Invoice__c where id =: recordId].Opportunity__c ;
                oppToMarkClosedWon.Latest_Invoice_Id__c = recordId;
                oppToMarkClosedWon.Can_Convert__c = true; 
                oppToMarkClosedWon.StageName = 'Closed-Won';
                dateTime nextFollowupdate = [Select Opportunity__r.Next_follow_up_date_time__c From Invoice__c where id =: recordId].Opportunity__r.Next_follow_up_date_time__c;
                if(nextFollowupdate == null){
                    nextFollowupdate = system.now().addDays(1);
                } else if(nextFollowupdate < system.now()){
                    nextFollowupdate = system.now().addDays(1);
                }
                oppToMarkClosedWon.Next_follow_up_date_time__c = nextFollowupdate;
                decimal expectedRevenue = [Select Opportunity__r.Expected_Revenue__c From Invoice__c where id =: recordId].Opportunity__r.Expected_Revenue__c;
                if(expectedRevenue == null || expectedRevenue < 0 )
                    expectedRevenue = 1;
                oppToMarkClosedWon.Expected_Revenue__c = expectedRevenue;
                system.debug('oppToMarkClosedWon-->'+oppToMarkClosedWon);
                update oppToMarkClosedWon;
                
                /*reciepientEmail = [Select Opportunity__r.Email__c
From Invoice__c
where Id = :recordId].Opportunity__r.Email__c;
system.debug('reciepientEmail :: ' + reciepientEmail);
if (!string.isBlank(reciepientEmail)){
//EmailIUtility.sendEmailForPaymentSuccess(reciepientEmail, 'Razor Pay Success Status Opportunity', 'Opportunity', recordId);
}*/
                Set<Id> opportunityIds = new Set<Id>();
                opportunityIds.add([Select Opportunity__c From Invoice__c where id =: recordId].Opportunity__c);
                EmailIUtility.sendInvoiceAndReceiptAsAttach(opportunityIds,'Payment Success Email');

            }
            
        } catch (exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('RetailInvoiceHelper','attachPdf', e, null);
        }
    }
    
    
    //Wrapper For Receipt Object
   /* public class wrapReceipt {
        Public String RecepitName{get;set;}
        Public Date ReceiptCreatedDate{get;set;}
        Public String InvoiceName{get;set;}
        Public Date InvoiceCreatedDate{get;set;}
        Public Integer Amount{get;set;}
        
        public Receipt__c receipt {get;set;}
        
        public wrapReceipt(Receipt__c recp){
            receipt = recp;
        }
    }  */
}