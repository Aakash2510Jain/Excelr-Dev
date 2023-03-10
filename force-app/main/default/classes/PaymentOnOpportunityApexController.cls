public class PaymentOnOpportunityApexController {
    public PaymentOnOpportunityApexController() {
        
    }
    
    @AuraEnabled(Cacheable=true)
    Public Static Opportunity ShowOppAmount(string recordId){
        try{
            Opportunity OppRec=[Select Id, Amount From Opportunity Where Id=:recordId];
            
            return OppRec;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowOppAmount', e , null);
            return null;
        }
    }
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
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowNbfcPartners', e , null);
            return null;
        }
    }
    
    @AuraEnabled(Cacheable = True)
    Public Static Decimal ShowAmount(String ProductName){
        try{
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
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowAmount', e , null);
            return null;
        }
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
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowPriceIncludingGST', e , null);
            return null;
        }
    }
    
    
    
    @AuraEnabled
    Public Static string UpdateOPPforFullPayment(string recordId,Decimal Amount, String paymentType,String PaymentOptiontype){
        try{
            Opportunity OppRec=new Opportunity();
            OppRec.Id=recordId;
            OppRec.Payment_Mode__c=paymentType;
            OppRec.Payment_Type__c=PaymentOptiontype;
            update OppRec;
            
            
            
            Invoice__c invRec=new Invoice__c();
            invRec.Opportunity__c=recordId;
            invRec.Status__c='Initiated';
            invRec.Amount__c=Amount;
            invRec.Type__c = 'Payment';
            invRec.Mode_Terms_of_Payment__c='Online';
            invRec.Initiated_Date__c=System.Today();
            invRec.Invoice_Due_Date__c=System.Today() + 2;
            
            insert invRec;
            
            if(paymentType=='razorpay'){
                
                return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);
                
            }else{
                
                ccAvenueLwcController.initateCCAvenuePayment(invRec.id);
            }
            
            return 'Success';
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'UpdateOPPforFullPayment', e , null);
            return null;
        }
    }
    
    @AuraEnabled
    Public Static string UpdateOPPforPartialPayment(string recordId,Decimal Amount,Decimal PendingAmount, String paymentType,String PaymentOptiontype,Date nextPaymentDueDate){
        
        try{
            List<Invoice__c> invoiceListToInsert = new List<Invoice__c>();
            
            Opportunity OppRec=new Opportunity();
            OppRec.Id=recordId;
            OppRec.Payment_Mode__c=paymentType;
            OppRec.Payment_Type__c = 'Partial Payment';
            OppRec.Loan_Amount__c=PendingAmount;
            OppRec.Seek_Loan__c = 'No';
            OppRec.Payment_Status__c = 'Initiated';
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            OppRec.Payment_Initiated__c = true;
            OppRec.Upfront_Amount__c=Amount;
            oppRec.Due_Amount__c =PendingAmount-Amount;
            
            
            update OppRec;
            
            Invoice__c invRec=new Invoice__c();
            invRec.Opportunity__c=recordId;
            invRec.Status__c='Initiated';
            invRec.Amount__c=Amount;
            invRec.Type__c = 'Payment';
            invRec.Mode_Terms_of_Payment__c='Online';
            invRec.Initiated_Date__c=System.Today();
            invRec.Invoice_Due_Date__c=System.Today() + 2;
            invoiceListToInsert.add(invRec);
            
            Invoice__c invRecord=new Invoice__c();
            invRecord.Opportunity__c=recordId;
            invRecord.Status__c='Pending';
            invRec.Type__c = 'Payment';
            invRecord.Mode_Terms_of_Payment__c='Online';
            invRecord.Amount__c=PendingAmount;
            invRecord.Initiated_Date__c=System.Today();
            
            Time myTime = Time.newInstance(11, 0, 0, 0); // 11:00 AM
            
            invRecord.Next_Followup_Date_Time__c = DateTime.newInstance(nextPaymentDueDate.year(), nextPaymentDueDate.month(), nextPaymentDueDate.day(), myTime.hour(), myTime.minute(), myTime.second());
            invRecord.Invoice_Due_Date__c=nextPaymentDueDate + 2;
            invoiceListToInsert.add(invRecord);
            
            if(!invoiceListToInsert.isEmpty())
                insert invoiceListToInsert;
            
            if(paymentType=='razorpay'){
                system.debug('invRec Id-'+invRec.Id);
                return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);
                
            }else{
                ccAvenueLwcController.initateCCAvenuePayment(invRec.id);
            }
            
            return 'Success';
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'UpdateOPPforPartialPayment', e , null);
            return null;
        }
    }
    
    @AuraEnabled
    Public Static string OppUpdateOnFullLoan(string recordId,integer FullTenureValue,String FullNBFCValue,Integer Quantity,String ProductName,Decimal Amount,String LoanType ){
        try{
            system.debug('recordId='+recordId+'FullTenureValue='+FullTenureValue);
            system.debug('FullNBFCValue='+FullNBFCValue+'Amount='+Amount);
            system.debug('Quantity='+Quantity+'Product__c='+ProductName);
            system.debug('LoanType--->'+LoanType);
            
            Opportunity OppRec=new Opportunity();
            OppRec.Id=recordId;
            OppRec.Loan_Tenure__c=FullTenureValue;
            OppRec.Loan_Amount__c=Amount;
            OppRec.Loan_Type__c =LoanType;
            OppRec.Seek_Loan__c = 'Yes';
            OppRec.Payment_Type__c = 'Full Payment';
            OppRec.Payment_Status__c = 'Initiated';
            OppRec.Payment_Mode__c = 'Loan';
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            OppRec.Payment_Initiated__c = true;
            OppRec.Upfront_Amount__c = 0;
            OppRec.Due_Amount__c = 0;
            OppRec.NBFCPartner__c=FullNBFCValue;
            Update OppRec;
            
            Invoice__c invRec=new Invoice__c();
            invRec.Opportunity__c=recordId;
            invRec.Status__c='Initiated';
            invRec.Amount__c=Amount;
            invRec.Type__c = 'Loan';
            invRec.Due_Amount__c = 0;
            invRec.Mode_Terms_of_Payment__c = 'Full Loan';
            invRec.Initiated_Date__c=System.Today();
            invRec.Invoice_Due_Date__c=System.Today() + 2;
            
            insert invRec;
            
            return 'success';
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'OppUpdateOnFullLoan', e , null);
            return null;
        }
    }
    
    @AuraEnabled
    Public Static String OppUpdateOnPartialLoan(string recordId,integer PartialTenureValue,String partialNBFCValue,Integer PartialUpfrontValue,Integer Quantity,String ProductName,Decimal Amount,String paymentType,String LoanType){
        try{      
            List<Invoice__c> invoiceListToUpdate = new List<Invoice__c>();
            
            Opportunity OppRec=new Opportunity();
            OppRec.Id=recordId;
            OppRec.Loan_Tenure__c=PartialTenureValue;
            OppRec.Loan_Amount__c=Amount - PartialUpfrontValue;
            OppRec.Loan_Type__c =LoanType;
            OppRec.NBFCPartner__c=partialNBFCValue;
            OppRec.Upfront_Amount__c=PartialUpfrontValue;
            oppRec.Due_Amount__c = Amount - PartialUpfrontValue;
            OppRec.Seek_Loan__c = 'Yes';
            OppRec.Payment_Type__c = 'Partial Payment';
            OppRec.Payment_Status__c = 'Initiated';
            OppRec.Payment_Mode__c = 'Loan';
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            OppRec.Payment_Initiated__c = true;
            
            
            Update OppRec;
            
            Invoice__c invRec=new Invoice__c();
            invRec.Opportunity__c=recordId;
            invRec.Status__c='Initiated';
            invRec.Amount__c=PartialUpfrontValue;
            invRec.Type__c = 'Payment';
            invRec.Mode_Terms_of_Payment__c = 'Online';
            invRec.Initiated_Date__c=System.Today();
            invRec.Invoice_Due_Date__c=System.Today() + 2;
            invoiceListToUpdate.add(invRec);
            
            Invoice__c invRecLoan = new Invoice__c();
            invRecLoan.Opportunity__c = recordId;
            invRecLoan.Status__c = 'Pending';
            invRecLoan.Type__c = 'Loan';
            invRecLoan.Mode_Terms_of_Payment__c = 'Partial Loan';
            invRecLoan.Amount__c = Amount - PartialUpfrontValue;
            invRecLoan.Initiated_Date__c = System.Today();
            invRecLoan.Invoice_Due_Date__c = System.Today() + 2;
            invoiceListToUpdate.add(invRecLoan);
            
            if(!invoiceListToUpdate.isEmpty())
                insert invoiceListToUpdate;
            
            
            if(paymentType=='razorpay'){
                return RazorpayPaymentHandler.initateRazorpayPament(invRec.id);
            }else{
                ccAvenueLwcController.initateCCAvenuePayment(invRec.id);
            }           
            return 'Success';
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'OppUpdateOnPartialLoan', e , null);
            return null;
        }
    }
    
    /*@AuraEnabled
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
}*/
    
}