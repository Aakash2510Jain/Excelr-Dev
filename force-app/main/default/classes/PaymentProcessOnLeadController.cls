public class PaymentProcessOnLeadController{
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
    Public Static Decimal ShowPriceIncludingGST(String NbfcValue, integer tenure, integer originalAmount){

        Decimal finalPriceWithGST;
        NBFC__c nbfcRec = [Select Processing_Fee__c, Interest_Rate__c, GST_on_Subvention__c
                           From NBFC__c
                           Where NBFC_Name__c = :NbfcValue AND Tenure__c = :tenure];

        if (nbfcRec.Processing_Fee__c != 0){

            Decimal basePlusProcessing = originalAmount + nbfcRec.Processing_Fee__c;
            Decimal basePlusProcessingPlusInter = basePlusProcessing + basePlusProcessing * (nbfcRec.Interest_Rate__c / 100);
            Decimal finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter * (nbfcRec.GST_on_Subvention__c / 100);
            finalPriceWithGST = finalWithGST;
        } else{

            Decimal basePrice = originalAmount;
            Decimal basePlusProcessingPlusInter = basePrice + basePrice * (nbfcRec.Interest_Rate__c / 100);
            Decimal finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter * (nbfcRec.GST_on_Subvention__c / 100);
            finalPriceWithGST = finalWithGST;
        }

        return finalPriceWithGST.setScale(2);
    }

    @AuraEnabled
    Public Static string InsertProduct(string recordId, Integer Quantity, String ProductName, integer Amount, String paymentType){

        Product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                             From PricebookEntries)
                           From Product2 
                           where id = :ProductName];

        Lead ld = new Lead();
        ld.Product__c = PrdRec.Id;
        ld.Total_Amount__c = Amount;
        ld.Quantity__c = Quantity;
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

            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);

        } else{

            ccAvenueLwcController.initateCCAvenuePayment(invRec.id);
        }

        return 'Success';
    }

    @AuraEnabled
    Public Static string LeadUpdateOnFullLoan(string recordId, integer FullTenureValue, String FullNBFCValue, Integer Quantity, String ProductName, Decimal Amount){

        system.debug('recordId=' + recordId + 'FullTenureValue=' + FullTenureValue);
        system.debug('FullNBFCValue=' + FullNBFCValue + 'Amount=' + Amount);
        system.debug('Quantity=' + Quantity + 'Product__c=' + ProductName);

        product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                             From PricebookEntries)
                           From Product2 
                           where id = :ProductName];

        Lead LeadRec = new Lead();
        LeadRec.Id = recordId;
        LeadRec.Capture_Tenure__c = FullTenureValue;
        LeadRec.Capture_NBFC_Partner__c = FullNBFCValue;
        LeadRec.Total_Amount__c = Amount;
        LeadRec.Quantity__c = Quantity;
        LeadRec.Payment_Initiated_Date_Time__c = System.now();
        LeadRec.Product__c = PrdRec.Id;

        system.debug('recordId=' + recordId + 'FullTenureValue=' + FullTenureValue);
        system.debug('FullNBFCValue=' + FullNBFCValue + 'Amount=' + Amount);
        system.debug('Quantity=' + Quantity + 'Product__c=' + PrdRec.Id);


        Update LeadRec;

        Invoice__c invRec = new Invoice__c();
        invRec.LeadInvoice__c = recordId;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = Amount;
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today() + 2;

        insert invRec;

        return 'success';
    }

    @AuraEnabled
    Public Static String leadUpdateOnPartialLoan(string recordId, integer PartialTenureValue, String partialNBFCValue, Integer PartialUpfrontValue, Integer Quantity, String ProductName, Decimal Amount, String paymentType){

        product2 PrdRec = [Select Id, Name, (Select Id, Name, UnitPrice
                                             From PricebookEntries)
                           From Product2 
                           where id = :ProductName];


        Lead LeadRec = new Lead();
        LeadRec.Id = recordId;
        LeadRec.Capture_Tenure__c = PartialTenureValue;
        LeadRec.Capture_NBFC_Partner__c = partialNBFCValue;
        LeadRec.Capture_Upfront_payment__c = PartialUpfrontValue;
        LeadRec.Total_Amount__c = Amount;
        LeadRec.Quantity__c = Quantity;
        LeadRec.Payment_Initiated_Date_Time__c = System.now();
        LeadRec.Payment_Type__c = paymentType;
        LeadRec.Product__c = PrdRec.Id;

        Update LeadRec;


        Invoice__c invRec = new Invoice__c();
        invRec.LeadInvoice__c = recordId;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = PartialUpfrontValue;
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today() + 2;

        insert invRec;


        if (paymentType == 'razorpay'){

            return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);

        } else{

            ccAvenueLwcController.initateCCAvenuePayment(invRec.id);

        }


        return 'Success';
    }

    @AuraEnabled
    Public Static String CreateInvoice(String recordId, Decimal FinalAmount, integer PartialTenureValue, String partialNBFCValue, Integer PartialUpfrontValue, Integer Quantity, String ProductName, Decimal Amount, String paymentType){

        if (PartialTenureValue == null && partialNBFCValue == null && PartialUpfrontValue == null && Quantity == null && ProductName == null && Amount == null && paymentType == null){


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
            LeadRec.Total_Amount__c = Amount;
            LeadRec.Quantity__c = Quantity;
            LeadRec.Payment_Initiated_Date_Time__c = System.now();
            LeadRec.Payment_Type__c = paymentType;
            LeadRec.Product__c = PrdRec.Id;

            Update LeadRec;


            Invoice__c invRec = new Invoice__c();
            invRec.LeadInvoice__c = recordId;
            invRec.Status__c = 'Initiated';
            invRec.Amount__c = PartialUpfrontValue;
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;

            insert invRec;
        }

        return 'Success';
    }

}