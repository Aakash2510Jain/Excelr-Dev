public class PaymentProcessOnOpportunityController {
    
    @AuraEnabled(Cacheable=True)
    Public Static List<NBFC__c> ShowNbfcPartners(){
        list<NBFC__c> NBFCList=[Select Name,Interest_Rate__c,GST_on_Subvention__c,Processing_Fee__c,Tenure__c From NBFC__c];
        system.debug('NBFCList='+NBFCList);
        return NBFCList;
    }
    
    @AuraEnabled(Cacheable=True)
    Public Static Decimal ShowAmount(String ProductName){
        Decimal Amount;
        Product2 PrdRec=[Select Id,Name,(Select Id,Name,UnitPrice From PricebookEntries) From Product2 where id=:ProductName ];

        System.debug('Product----'+PrdRec);
        if(PrdRec==null || PrdRec.PricebookEntries!=null && PrdRec.PricebookEntries.size()==0) return null;
        return PrdRec.PricebookEntries[0].UnitPrice;

        
    }
    
     @AuraEnabled
    Public Static string CreateOppLineItem(string recordId,Integer Quantity,String ProductName,integer Amount, String paymentType){

        Product2 PrdRec=[Select Id,Name,(Select Id,Name,UnitPrice From PricebookEntries ) From Product2 where id=:ProductName ];
        
        
        OpportunityLineItem oppLineItemRec=new OpportunityLineItem();
        
        oppLineItemRec.OpportunityId=recordId;
        oppLineItemRec.Quantity=Quantity;
        oppLineItemRec.Product2Id=PrdRec.id;
        oppLineItemRec.TotalPrice=Amount;
        oppLineItemRec.PricebookEntryId=PrdRec.PricebookEntries[0].Id;
        
        insert oppLineItemRec;
        
        
        Invoice__c invRec=new Invoice__c();
        invRec.Opportunity__c=recordId;
        invRec.Status__c='Initiated';
        invRec.Amount__c=Amount;
        invRec.Initiated_Date__c=System.Today();
        invRec.Invoice_Due_Date__c=System.Today() + 2;
            
        insert invRec;

        if(paymentType=='razorpay'){

            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);

        }else{

             ccAvenueLwcController.initateCCAvenuePayment(invRec.id);
        }
       
        return 'Success';
       
    }
    
     @AuraEnabled
    Public Static string OppUpdateOnFullLoan(string recordId,integer FullTenureValue,String FullNBFCValue,Integer Quantity,String ProductName,Decimal Amount,String LoanType ){
        
        system.debug('recordId='+recordId+'FullTenureValue='+FullTenureValue);
         system.debug('FullNBFCValue='+FullNBFCValue+'Amount='+Amount);
          system.debug('Quantity='+Quantity+'Product__c='+ProductName);
        
        product2 PrdRec=[Select Id,Name,(Select Id,Name,UnitPrice From PricebookEntries) From Product2 where id=:ProductName ];
        
         OpportunityLineItem oppLineItemRec=new OpportunityLineItem();
        
        oppLineItemRec.OpportunityId=recordId;
        oppLineItemRec.Quantity=Quantity;
        oppLineItemRec.Product2Id=PrdRec.id;
        oppLineItemRec.TotalPrice=Amount;
        oppLineItemRec.PricebookEntryId=PrdRec.PricebookEntries[0].Id;
        
        insert oppLineItemRec;
        
         Opportunity OppRec=new Opportunity();
         OppRec.Id=recordId;
         OppRec.Loan_Tenure__c=FullTenureValue;
         OppRec.Loan_Amount__c=Amount;
         OppRec.Loan_Type__c =LoanType;
         OppRec.NBFCPartner__c=FullNBFCValue;
        
         Update OppRec;
        
        Invoice__c invRec=new Invoice__c();
        invRec.Opportunity__c=recordId;
        invRec.Status__c='Initiated';
        invRec.Amount__c=Amount;
        invRec.Initiated_Date__c=System.Today();
        invRec.Invoice_Due_Date__c=System.Today() + 2;
            
        insert invRec;
       
        return 'success';
       
    }
    
    @AuraEnabled
    Public Static String OppUpdateOnPartialLoan(string recordId,integer PartialTenureValue,String partialNBFCValue,Integer PartialUpfrontValue,Integer Quantity,String ProductName,Decimal Amount,String paymentType,String LoanType){
             
        product2 PrdRec=[Select Id,Name,(Select Id,Name,UnitPrice From PricebookEntries) From Product2 where id=:ProductName ];
        
         OpportunityLineItem oppLineItemRec=new OpportunityLineItem();
        
        oppLineItemRec.OpportunityId=recordId;
        oppLineItemRec.Quantity=Quantity;
        oppLineItemRec.Product2Id=PrdRec.id;
        oppLineItemRec.TotalPrice=Amount;
        oppLineItemRec.PricebookEntryId=PrdRec.PricebookEntries[0].Id;
        
        insert oppLineItemRec;
        
         Opportunity OppRec=new Opportunity();
         OppRec.Id=recordId;
         OppRec.Loan_Tenure__c=PartialTenureValue;
         OppRec.Loan_Amount__c=Amount;
         OppRec.Loan_Type__c =LoanType;
         OppRec.NBFCPartner__c=partialNBFCValue;
         OppRec.Upfront_Amount__c=PartialUpfrontValue;
        
         Update OppRec;
        
        Invoice__c invRec=new Invoice__c();
        invRec.Opportunity__c=recordId;
        invRec.Status__c='Initiated';
        invRec.Amount__c=PartialUpfrontValue;
        invRec.Initiated_Date__c=System.Today();
        invRec.Invoice_Due_Date__c=System.Today() + 2;
            
        
        insert invRec;


        if(paymentType=='razorpay'){
            
            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);

        }else{
            
             ccAvenueLwcController.initateCCAvenuePayment(invRec.id);

        }
        
       
        return 'Success';
    }

}