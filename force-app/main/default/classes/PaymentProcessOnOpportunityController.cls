public without sharing class PaymentProcessOnOpportunityController {
    
    @AuraEnabled(Cacheable = True)
    Public Static Map<String, List<Decimal>> ShowNbfcPartners(){
        Map<String, List<Decimal>> nbfcName = new Map<String, List<Decimal>>();

        list<NBFC__c> NBFCList = [Select NBFC_Name__c, Tenure__c
                                  From NBFC__c
                                  ORDER BY Tenure__c ASC];
        system.debug('NBFCList=' + NBFCList);

        for (NBFC__c nbfc : NBFCList){

            if (nbfcName.containsKey(nbfc.NBFC_Name__c)){
                List<Decimal> tenurelist = nbfcName.get(nbfc.NBFC_Name__c);
                system.debug('tenurelist=' + tenurelist);
                tenurelist.add(nbfc.Tenure__c);
            } else{
                List<Decimal> newtenurelist = new List<Decimal>();
                newtenurelist.add(nbfc.Tenure__c);
                system.debug('newtenurelist=' + newtenurelist);
                nbfcName.put(nbfc.NBFC_Name__c, newtenurelist);
            }
        }
        system.debug('nbfcName=' + nbfcName);

        return nbfcName;
    }

    @AuraEnabled(Cacheable = True)
    Public Static Decimal ShowAmount(String ProductName){
        system.debug('ProductName-->'+ProductName);
        Decimal Amount;
        Product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                             From PricebookEntries)
                           From Product2 
                           where id = :ProductName];

        System.debug('Product----' + PrdRec);
        if (PrdRec == null || PrdRec.PricebookEntries != null && PrdRec.PricebookEntries.size() == 0)
            return null;
        return PrdRec.PricebookEntries[0].UnitPrice;
    }

    @AuraEnabled
    Public Static Decimal ShowPriceIncludingGST(String NbfcValue, integer tenure, Decimal originalAmount){

        system.debug('originalAmount='+originalAmount);
        Decimal finalPriceWithGST;
        NBFC__c nbfcRec = [Select Processing_Fee__c, Interest_Rate__c, GST_on_Subvention__c
                           From NBFC__c
                           Where NBFC_Name__c = :NbfcValue AND Tenure__c = :tenure];

        if (nbfcRec.Processing_Fee__c != 0){

            Decimal basePlusProcessing = originalAmount + nbfcRec.Processing_Fee__c;
            Decimal basePlusProcessingPlusInter = basePlusProcessing + basePlusProcessing * (nbfcRec.Interest_Rate__c / 100);
            Decimal finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter * (nbfcRec.GST_on_Subvention__c / 100);
            finalPriceWithGST = finalWithGST;
            system.debug('finalPriceWithGST='+finalPriceWithGST);
        } else{

            Decimal basePrice = originalAmount;
            Decimal basePlusProcessingPlusInter = basePrice + basePrice * (nbfcRec.Interest_Rate__c / 100);
            Decimal finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter * (nbfcRec.GST_on_Subvention__c / 100);
            finalPriceWithGST = finalWithGST;
            system.debug('finalPriceWithGST='+finalPriceWithGST);
        }

        return finalPriceWithGST.setScale(2);
    }


    
     @AuraEnabled
    Public Static string CreateOppLineItem(string recordId,Integer Quantity,String ProductName,integer Amount, String paymentType){
        datetime datetimevalueCurrentDT = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        long unixtimestamp = datetimevalueCurrentDT.getTime();
        System.debug('unixtimestamp ===> ' + unixtimestamp);
        //string strunixtime = '1691097057';
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));

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

            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id, longUnixTimeStamp);

        }else{

             ccAvenueLwcController.initateCCAvenuePayment(invRec.id, longUnixTimeStamp);
        }
       
        return 'Success';
       
    }
    
     @AuraEnabled
    Public Static string OppUpdateOnFullLoan(string recordId,integer FullTenureValue,String FullNBFCValue,Integer Quantity,String ProductName,Decimal Amount,String LoanType ){
        
        system.debug('recordId='+recordId+'FullTenureValue='+FullTenureValue);
         system.debug('FullNBFCValue='+FullNBFCValue+'Amount='+Amount);
         // system.debug('Quantity='+Quantity+'Product__c='+ProductName);
        
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
         string OppCourse = PrdRec.name.substringBefore('-');
         OppCourse = OppCourse.trim();
         OppRec.Course__c = OppCourse;
        
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
             
        datetime datetimevalueCurrentDT = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        long unixtimestamp = datetimevalueCurrentDT.getTime();
        System.debug('unixtimestamp ===> ' + unixtimestamp);
        //string strunixtime = '1691097057';
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));
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
         string OppCourse = PrdRec.name.substringBefore('-');
         OppCourse = OppCourse.trim();
         OppRec.Course__c = OppCourse;
         Update OppRec;
        
        Invoice__c invRec=new Invoice__c();
        invRec.Opportunity__c=recordId;
        invRec.Status__c='Initiated';
        invRec.Amount__c=PartialUpfrontValue;
        invRec.Initiated_Date__c=System.Today();
        invRec.Invoice_Due_Date__c=System.Today() + 2;
            
        
        insert invRec;


        if(paymentType=='razorpay'){
            
            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id, longUnixTimeStamp);

        }else{
            
             ccAvenueLwcController.initateCCAvenuePayment(invRec.id, longUnixTimeStamp);

        }
        
       
        return 'Success';
    }

    @AuraEnabled
    Public Static String CreateInvoice(String recordId, Decimal FinalAmount, integer PartialTenureValue, String partialNBFCValue, Integer PartialUpfrontValue, Integer Quantity, String ProductName, Decimal Amount, String paymentType){

        System.debug('FinalAmount ===> ' + FinalAmount);
        System.debug('PartialTenureValue ===> ' + PartialTenureValue);
        System.debug('partialNBFCValue ===> ' + partialNBFCValue);
        System.debug('PartialUpfrontValue ===> ' + PartialUpfrontValue);
        System.debug('Quantity ===> ' + Quantity);
        System.debug('ProductName ===> ' + ProductName);
        System.debug('Amount ===> ' + Amount);
        System.debug('paymentType ===> ' + paymentType);

        system.debug('Create Invoice');
        if (PartialTenureValue == null && partialNBFCValue == null && PartialUpfrontValue == null && Quantity != null && ProductName != null && Amount == null && paymentType != null){


            Invoice__c invRec = new Invoice__c();
            invRec.Opportunity__c = recordId;
            invRec.Status__c = 'Initiated';
            invRec.Amount__c = FinalAmount;
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;

            insert invRec;
        } else if (PartialTenureValue != null && partialNBFCValue != null && PartialUpfrontValue != null && Quantity != null && ProductName != null && Amount != null && paymentType != null){

            product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                                 From PricebookEntries)
                               From Product2 
                               where id = :ProductName];


            Opportunity OppRec=new Opportunity();
            OppRec.Id = recordId;
            OppRec.Loan_Tenure__c = PartialTenureValue;
            OppRec.NBFCPartner__c = partialNBFCValue;
            OppRec.Upfront_Amount__c = PartialUpfrontValue;
            OppRec.Loan_Amount__c = Amount;
            OppRec.TotalOpportunityQuantity = Quantity;
            OppRec.Payment_Initiated_Date_Time__c = System.now();
            OppRec.Payment_Mode__c = paymentType;
            //OppRec.Product__c = PrdRec.Id;
            string OppCourse = PrdRec.name.substringBefore('-');
            OppCourse = OppCourse.trim();
            OppRec.Course__c = OppCourse;
            Update OppRec;

            List<Invoice__c> invoiceList = new List<Invoice__c>();
            Invoice__c invRec = new Invoice__c();
            invRec.Opportunity__c = recordId;
            invRec.Status__c = 'Initiated';
            invRec.Amount__c = PartialUpfrontValue;
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;

            invoiceList.add(invRec);

            Invoice__c invRecLoan = new Invoice__c();
            invRecLoan.Opportunity__c = recordId;
            invRecLoan.Status__c = 'Initiated';
            invRecLoan.Amount__c = Amount - PartialUpfrontValue;
            invRecLoan.Initiated_Date__c = System.Today();
            invRecLoan.Invoice_Due_Date__c = System.Today() + 2;
            invoiceList.add(invRecLoan);

            insert invoiceList;
        }

        return 'Success';
    }

}