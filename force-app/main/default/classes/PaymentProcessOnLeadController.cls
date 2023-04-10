public without sharing class PaymentProcessOnLeadController{
    @AuraEnabled(Cacheable = True)
    Public Static Map<String, List<Decimal>> ShowNbfcPartners(){
        try{
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
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('PaymentProcessOnLeadController', 'ShowNbfcPartners', e , null);
       return null;
    }
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
    try{
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
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('PaymentProcessOnLeadController', 'ShowPriceIncludingGST', e , null);
       return null;
    }
}

    @AuraEnabled
    Public Static string InsertProduct(string recordId, Integer Quantity, String ProductName, integer Amount, String paymentType){
        datetime datetimevalueCurrentDT = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        long unixtimestamp = datetimevalueCurrentDT.getTime();
        System.debug('unixtimestamp ===> ' + unixtimestamp);
        //string strunixtime = '1691097057';
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));
        try{
        system.debug('Inserting Product');
        Product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                             From PricebookEntries)
                           From Product2 
                           where id = :ProductName];

        Lead ld = new Lead();
        //ld.Product__c = PrdRec.Id;
        //ld.Total_Amount__c = Amount;
        //ld.Quantity__c = Quantity;
        ld.Payment_Initiated_Date_Time__c = System.now();
        ld.Id = recordId;

        Update ld;

        Invoice__c invRec = new Invoice__c();
        invRec.LeadInvoice__c = recordId;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = Amount;
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today() + 2;

        insert invRec;

        if (paymentType == 'razorpay'){

            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id, longUnixTimeStamp);

        } else{

            ccAvenueLwcController.initateCCAvenuePayment(invRec.id, longUnixTimeStamp);
        }

        return 'Success';
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('PaymentProcessOnLeadController', 'InsertProduct', e , null);
       return null;
    }
}

    @AuraEnabled
    Public Static string LeadUpdateOnFullLoan(string recordId, integer FullTenureValue, String FullNBFCValue, Integer Quantity, String ProductName, Decimal Amount){
       try{
        product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                             From PricebookEntries)
                           From Product2 
                           where id = :ProductName];
        
        Lead LeadRec = new Lead();
        LeadRec.Id = recordId;
        LeadRec.Capture_Tenure__c = FullTenureValue;
        LeadRec.Capture_NBFC_Partner__c = FullNBFCValue;
        //LeadRec.Total_Amount__c = Amount;
        //LeadRec.Quantity__c = Quantity;
        LeadRec.Payment_Initiated_Date_Time__c = System.now();
        //LeadRec.Product__c = PrdRec.Id;
        string leadCourse = PrdRec.name.substringBefore('-');
        leadCourse = leadCourse.trim();
        LeadRec.Course__c = leadCourse;
        
        Update LeadRec;

        Invoice__c invRec = new Invoice__c();
        invRec.LeadInvoice__c = recordId;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = Amount;
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today() + 2;

        insert invRec;

        return 'success';
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('PaymentProcessOnLeadController', 'LeadUpdateOnFullLoan', e , null);
       return null;
    }
}

    @AuraEnabled
    Public Static String leadUpdateOnPartialLoan(string recordId, integer PartialTenureValue, String partialNBFCValue, Integer PartialUpfrontValue, Integer Quantity, String ProductName, Decimal Amount, String paymentType){
        datetime datetimevalueCurrentDT = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        long unixtimestamp = datetimevalueCurrentDT.getTime();
        System.debug('unixtimestamp ===> ' + unixtimestamp);
        //string strunixtime = '1691097057';
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));
        system.debug('Partial Loan');
        try{
            product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                                 From PricebookEntries)
                               From Product2 
                               where id = :ProductName];
            
            system.debug('PrdRec.name -->' +PrdRec.name);
            Lead LeadRec = new Lead();
            LeadRec.Id = recordId;
            LeadRec.Capture_Tenure__c = PartialTenureValue;
            LeadRec.Capture_NBFC_Partner__c = partialNBFCValue;
            LeadRec.Capture_Upfront_payment__c = PartialUpfrontValue;
            //LeadRec.Total_Amount__c = Amount;
            //LeadRec.Quantity__c = Quantity;
            LeadRec.Payment_Initiated_Date_Time__c = System.now();
            LeadRec.Payment_Type__c = paymentType;
            //LeadRec.Product__c = PrdRec.Id;
            string leadCourse = PrdRec.name.substringBefore('-');
            leadCourse = leadCourse.trim();
            LeadRec.Course__c = leadCourse;
            Update LeadRec;
            
            
            Invoice__c invRec = new Invoice__c();
            invRec.LeadInvoice__c = recordId;
            invRec.Status__c = 'Initiated';
            invRec.Amount__c = PartialUpfrontValue;
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;
            
            insert invRec;
            
            Utility.createApplicationInstance(recordId,leadCourse,null);
            
            if (paymentType == 'razorpay'){
                
                return RazorpayPaymentHandler.initateRazorpayPament(invRec.id, longUnixTimeStamp);
                
            } else{
                
                ccAvenueLwcController.initateCCAvenuePayment(invRec.id, longUnixTimeStamp);
                
            }
            
            
            return 'Success';
        }catch(exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentProcessOnLeadController','leadUpdateOnPartialLoan', e, null);
            return 'Error';
        }
    }

    @AuraEnabled
    Public Static String CreateInvoice(String recordId, Decimal FinalAmount, integer PartialTenureValue, String partialNBFCValue, Integer PartialUpfrontValue, Integer Quantity, String ProductName, Decimal Amount, String paymentType){
      try{
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
            invRec.LeadInvoice__c = recordId;
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


            Lead LeadRec = new Lead();
            LeadRec.Id = recordId;
            LeadRec.Capture_Tenure__c = PartialTenureValue;
            LeadRec.Capture_NBFC_Partner__c = partialNBFCValue;
            LeadRec.Capture_Upfront_payment__c = PartialUpfrontValue;
            //LeadRec.Total_Amount__c = Amount;
            //LeadRec.Quantity__c = Quantity;
            LeadRec.Payment_Initiated_Date_Time__c = System.now();
            LeadRec.Payment_Type__c = paymentType;
            //LeadRec.Product__c = PrdRec.Id;
            string leadCourse = PrdRec.name.substringBefore('-');
            leadCourse = leadCourse.trim();
            LeadRec.Course__c = leadCourse;
            Update LeadRec;

            List<Invoice__c> invoiceList = new List<Invoice__c>();
            Invoice__c invRec = new Invoice__c();
            invRec.LeadInvoice__c = recordId;
            invRec.Status__c = 'Initiated';
            invRec.Amount__c = PartialUpfrontValue;
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;

            invoiceList.add(invRec);

            Invoice__c invRecLoan = new Invoice__c();
            invRecLoan.LeadInvoice__c = recordId;
            invRecLoan.Status__c = 'Initiated';
            invRecLoan.Amount__c = Amount - PartialUpfrontValue;
            invRecLoan.Initiated_Date__c = System.Today();
            invRecLoan.Invoice_Due_Date__c = System.Today() + 2;
            invoiceList.add(invRecLoan);

            insert invoiceList;
        }

        return 'Success';
    }
    catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPICallout', 'getEmployeeDetails', e , null);
       return null;
    }
}

}