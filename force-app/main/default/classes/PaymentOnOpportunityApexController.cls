public without sharing class PaymentOnOpportunityApexController{
    public PaymentOnOpportunityApexController(){
    }

    @AuraEnabled(Cacheable = true)
    Public Static Opportunity ShowOppAmount(string recordId){
        try{
            Opportunity OppRec = [Select Id, Amount, Due_Amount__c,Email__c,Phone__c,
                                    (SELECT Amount__c,Total_Reciepts__c, Due_Amount__c FROM Invoices__r )
                                  From Opportunity
                                  Where Id = :recordId];

            return OppRec;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowOppAmount', e, null);
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
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowNbfcPartners', e, null);
            return null;
        }
    }

    @AuraEnabled(Cacheable = True)
    Public Static Decimal ShowAmount(String ProductName){
        try{
            system.debug('ProductName-->' + ProductName);
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
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowAmount', e, null);
            return null;
        }
    }

    @AuraEnabled
    Public Static Decimal ShowPriceIncludingGST(String NbfcValue, integer tenure, Decimal originalAmount){
        try{
            system.debug('originalAmount=' + originalAmount);
            Decimal finalPriceWithGST;
            NBFC__c nbfcRec = [Select Processing_Fee__c, Interest_Rate__c, GST_on_Subvention__c
                               From NBFC__c
                               Where NBFC_Name__c = :NbfcValue AND Tenure__c = :tenure];

            if (nbfcRec.Processing_Fee__c != 0){

                Decimal basePlusProcessing = originalAmount + nbfcRec.Processing_Fee__c;
                Decimal basePlusProcessingPlusInter = basePlusProcessing + basePlusProcessing * (nbfcRec.Interest_Rate__c / 100);
                Decimal finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter * (nbfcRec.GST_on_Subvention__c / 100);
                finalPriceWithGST = finalWithGST;
                system.debug('finalPriceWithGST=' + finalPriceWithGST);
            } else{

                Decimal basePrice = originalAmount;
                Decimal basePlusProcessingPlusInter = basePrice + basePrice * (nbfcRec.Interest_Rate__c / 100);
                Decimal finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter * (nbfcRec.GST_on_Subvention__c / 100);
                finalPriceWithGST = finalWithGST;
                system.debug('finalPriceWithGST=' + finalPriceWithGST);
            }

            return finalPriceWithGST.setScale(2);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'ShowPriceIncludingGST', e, null);
            return null;
        }
    }

    @AuraEnabled
    Public Static string UpdateOPPforFullPayment(string recordId, Decimal Amount, String paymentType, String PaymentOptiontype, date LinkexpiryDate){
        System.debug('recordId ===> ' + recordId);
        System.debug('Amount ===> ' + Amount);
        System.debug('paymentType ===> ' + paymentType);
        System.debug('PaymentOptiontype ===> ' + PaymentOptiontype);
        System.debug('LinkexpiryDate ====> ' + LinkexpiryDate);

        datetime datetimevalueCurrentDT = DateTime.newInstance(LinkexpiryDate.year(), LinkexpiryDate.month(), LinkexpiryDate.day());
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        long unixtimestamp = datetimevalueCurrentDT.getTime();
        System.debug('unixtimestamp ===> ' + unixtimestamp);
        //string strunixtime = '1691097057';
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));
        string invoiceRecId;
        Time myTime = Time.newInstance(11, 0, 0, 0); // 11:00 AM

        try{
            Opportunity OppRec = new Opportunity();
            OppRec.Id = recordId;
            OppRec.Payment_Mode__c = paymentType;
            OppRec.Payment_Type__c = PaymentOptiontype;
            OppRec.Upfront_Amount__c = Amount;
            update OppRec;

            if (recordId != null){
                List<Invoice__c> invoiceRecList = [Select Id, Do_Not_Send_Invoice__c, Status__c, LeadInvoice__c, LeadInvoice__r.Owner.UserRoleId, Lead_ManagerId__c, Opportunity__c, Opportunity__r.Owner.UserRoleId, Amount__c, LeadInvoice__r.Owner.Name, LeadInvoice__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.Owner.Name, Payment_Type__c, Realized_Amount__c, Due_Amount__c
                                               From Invoice__c
                                               Where Opportunity__c = :recordId
                                               ORDER BY CreatedDate DESC
                                               limit 1];
                system.debug('invoiceRecList -- ' + invoiceRecList);
                if (!invoiceRecList.isEmpty()){

                    system.debug('Invoice Found -- ');
                    invoiceRecId = invoiceRecList[0].Id;

                    Invoice__c invRec = new Invoice__c();
                    invRec.Id = invoiceRecList[0].Id;
                    invRec.Initiated_Amount__c = Amount;
                    invRec.Do_Not_Send_Invoice__c = true;
                    update invRec;

                    if (!invoiceRecList.isEmpty()){
                        Receipt__c receipt = new Receipt__c();
                        receipt.Invoice__c = invoiceRecList[0].id;
                        receipt.amount__c = Amount;
                        receipt.Type__c = paymentType;
                        receipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                        receipt.Is_Pending_Receipt__c = true;
                        insert receipt;
                    }
                } else{
                    system.debug('Invoice Not Found -- ');
                    Invoice__c invRec = new Invoice__c();
                    invRec.Opportunity__c = recordId;
                    invRec.Status__c = 'Initiated';
                    invRec.Amount__c = Amount ;
                    invRec.Initiated_Amount__c = Amount;
                    invRec.Type__c = 'Payment';
                    invRec.Payment_Type__c = Constants.INVOICE_PAYMENT_TYPE_FULLPAYMENT;
                    invRec.Down_Payment_Type__c = paymentType; 
                    invRec.Mode_Terms_of_Payment__c = 'Online';
                    invRec.Initiated_Date__c = System.Today();
                    invRec.Invoice_Due_Date__c = System.Today() + 2;
                    //invRec.Next_Followup_Date_Time__c = DateTime.newInstance(nextPaymentDueDate.year(), nextPaymentDueDate.month(), nextPaymentDueDate.day(), myTime.hour(), myTime.minute(), myTime.second());
                    //invRec.Invoice_Due_Date__c = nextPaymentDueDate + 2;
                    //invRec.Due_Amount__c = Amount + PendingAmount;
                    insert invRec;
                    invoiceRecId = invRec.Id;

                    if (invRec.id != null){
                        Receipt__c receipt = new Receipt__c();
                        receipt.Invoice__c = invRec.id;
                        receipt.amount__c = Amount;
                        receipt.Type__c = paymentType;
                        receipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                        insert receipt;
                    }
                }
            }


            if (paymentType == 'razorpay'){

                return RazorpayPaymentHandler.initateRazorpayPament(invoiceRecId, longUnixTimeStamp);

            } else if (paymentType == 'CC Avenue'){

                ccAvenueLwcController.initateCCAvenuePayment(invoiceRecId, longUnixTimeStamp);
            }

            return 'Success';

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'UpdateOPPforFullPayment', e, null);
            return null;
        }
    }

    @AuraEnabled
    Public Static string UpdateOPPforPartialPayment(string recordId, Decimal Amount, Decimal PendingAmount, String paymentType, String PaymentOptiontype, Date nextPaymentDueDate, date LinkexpiryDate){

        System.debug('LinkexpiryDate ====> ' + LinkexpiryDate);
        System.debug('recordId ====> ' + recordId);
        System.debug('Amount ====> ' + Amount);

        System.debug('PendingAmount ====> ' + PendingAmount);
        System.debug('paymentType ====> ' + paymentType);
        System.debug('PaymentOptiontype ====> ' + PaymentOptiontype);
        System.debug('nextPaymentDueDate ====> ' + nextPaymentDueDate);

        datetime datetimevalueCurrentDT = DateTime.newInstance(LinkexpiryDate.year(), LinkexpiryDate.month(), LinkexpiryDate.day());
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));
        
        string invoiceRecId;
        try{
            List<Invoice__c> invoiceListToInsert = new List<Invoice__c>();

            Opportunity OppRec = new Opportunity();
            OppRec.Id = recordId;
            //OppRec.Payment_Mode__c = paymentType;
            OppRec.Payment_Type__c = 'Partial Payment';
            //OppRec.Loan_Amount__c = null;
            OppRec.Seek_Loan__c = 'No';
            OppRec.Payment_Status__c = 'Initiated';
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            //OppRec.Payment_Initiated__c = true;


            update OppRec;

            Time myTime = Time.newInstance(11, 0, 0, 0); // 11:00 AM

            if (recordId != null){
                List<Invoice__c> invoiceRecList = [Select Id, Do_Not_Send_Invoice__c, Status__c, LeadInvoice__c, LeadInvoice__r.Owner.UserRoleId, Lead_ManagerId__c, Opportunity__c, Opportunity__r.Owner.UserRoleId, Amount__c, LeadInvoice__r.Owner.Name, LeadInvoice__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.Owner.Name, Payment_Type__c, Realized_Amount__c, Due_Amount__c
                                               From Invoice__c
                                               Where Opportunity__c = :recordId
                                               ORDER BY CreatedDate DESC
                                               limit 1];
                system.debug('invoiceRecList -- ' + invoiceRecList);
                if (!invoiceRecList.isEmpty()){

                    system.debug('Invoice Found -- ');
                    invoiceRecId = invoiceRecList[0].Id;

                    Invoice__c invRec = new Invoice__c();
                    invRec.Id = invoiceRecList[0].Id;
                    invRec.Initiated_Amount__c = Amount;
                    invRec.Do_Not_Send_Invoice__c = true;
                    update invRec;

                    if (!invoiceRecList.isEmpty()){
                        Receipt__c receipt = new Receipt__c();
                        receipt.Invoice__c = invoiceRecList[0].id;
                        receipt.amount__c = Amount;
                        receipt.Type__c = paymentType;
                        receipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                        receipt.Is_Pending_Receipt__c = true;
                        insert receipt;
                    }
                } else{
                    system.debug('Invoice Not Found -- ');
                    Invoice__c invRec = new Invoice__c();
                    invRec.Opportunity__c = recordId;
                    invRec.Status__c = 'Initiated';
                    invRec.Amount__c = Amount + PendingAmount;
                    invRec.Initiated_Amount__c = Amount;
                    invRec.Down_Payment_Type__c = paymentType; 
                    invRec.Type__c = 'Payment';
                    invRec.Payment_Type__c = Constants.INVOICE_PAYMENT_TYPE_PARTIALPAYMENT;
                    invRec.Mode_Terms_of_Payment__c = 'Online';
                    invRec.Initiated_Date__c = System.Today();
                    invRec.Invoice_Due_Date__c = System.Today() + 2;
                    invRec.Next_Followup_Date_Time__c = DateTime.newInstance(nextPaymentDueDate.year(), nextPaymentDueDate.month(), nextPaymentDueDate.day(), myTime.hour(), myTime.minute(), myTime.second());
                    invRec.Invoice_Due_Date__c = nextPaymentDueDate + 2;
                    invRec.Due_Amount__c = Amount + PendingAmount;
                    insert invRec;
                    invoiceRecId = invRec.Id;

                    if (invRec.id != null){
                        Receipt__c receipt = new Receipt__c();
                        receipt.Invoice__c = invRec.id;
                        receipt.amount__c = Amount;
                        receipt.Type__c = paymentType;
                        receipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                        insert receipt;
                    }
                }
            }


            if (paymentType == 'razorpay'){
                system.debug('invRec Id-' + invoiceRecId);
                return RazorpayPaymentHandler.initateRazorpayPament(invoiceRecId, longUnixTimeStamp);

            } else{
                ccAvenueLwcController.initateCCAvenuePayment(invoiceRecId, longUnixTimeStamp);
            }

            return 'Success';

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'UpdateOPPforPartialPayment', e, null);
            return null;
        }
    }

    @AuraEnabled
    Public Static string OppUpdateOnFullLoan(string recordId, integer FullTenureValue, String FullNBFCValue, Integer Quantity, String ProductName, Decimal Amount, String LoanType, integer actualcost, Decimal DownPayment){
        System.debug('actualcost ===> ' + actualcost);
        try{
            system.debug('recordId=' + recordId + 'FullTenureValue=' + FullTenureValue);
            system.debug('FullNBFCValue=' + FullNBFCValue + 'Amount=' + Amount);
            system.debug('Quantity=' + Quantity + 'Product__c=' + ProductName);
            system.debug('LoanType--->' + LoanType);
            List<Invoice__c> InvoiceList = new List<Invoice__c>();

            Opportunity OppRec = new Opportunity();
            OppRec.Id = recordId;
            OppRec.Loan_Tenure__c = FullTenureValue;
            OppRec.Loan_Amount__c = Amount;
            OppRec.Loan_Type__c = LoanType;
            OppRec.Seek_Loan__c = 'Yes';
            OppRec.Payment_Type__c = '100% Loan';
            OppRec.Payment_Status__c = 'Initiated';
            OppRec.Payment_Mode__c = 'Loan';
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            OppRec.Payment_Initiated__c = true;
            OppRec.Upfront_Amount__c = 0;
            OppRec.Due_Amount__c = 0;
            OppRec.NBFCPartner__c = FullNBFCValue;
            Update OppRec;

            if (DownPayment != null){
                Invoice__c inv = new Invoice__c();
                inv.Opportunity__c = recordId;
                inv.Status__c = 'Initiated';
                inv.Type__c = 'Loan';
                inv.Due_Amount__c = 0;
                inv.Mode_Terms_of_Payment__c = 'Full Loan';
                inv.Initiated_Date__c = System.Today();
                inv.Invoice_Due_Date__c = System.Today() + 2;
                InvoiceList.add(inv);
            }

            Invoice__c invRec = new Invoice__c();
            invRec.Opportunity__c = recordId;
            invRec.Status__c = 'Initiated';
            // if (DownPayment != null && DownPayment != '') {
            //     invRec.Amount__c = actualcost;
            // }
            // else {
            //     invRec.Amount__c = actualcost - DownPayment;
            // }

            invRec.Amount__c = actualcost;
            invRec.Down_Payment__c = DownPayment;
            invRec.Actual_Loan_Amount__c = actualcost - DownPayment;
            invRec.Type__c = 'Loan';
            invRec.Due_Amount__c = 0;
            invRec.Mode_Terms_of_Payment__c = 'Full Loan';
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;

            insert invRec;

            return 'success';

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'OppUpdateOnFullLoan', e, null);
            return null;
        }
    }

    @AuraEnabled
    Public Static String OppUpdateOnPartialLoan(string recordId, integer PartialTenureValue, String partialNBFCValue, Integer PartialUpfrontValue, Integer Quantity, String ProductName, Decimal Amount, String paymentType, String LoanType, date LinkexpiryDate){
        System.debug('LinkexpiryDate ====> ' + LinkexpiryDate);


        datetime datetimevalueCurrentDT = DateTime.newInstance(LinkexpiryDate.year(), LinkexpiryDate.month(), LinkexpiryDate.day());
        String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
        System.debug('String UnixTimeStamp is ' + strUnixTimeStamp);
        //string strunixtime = '1691097057';
        Long longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
        System.debug('DateTIme conversion of unixtimestamp ==>' + DateTime.newInstance(longUnixTimeStamp));

        try{
            List<Invoice__c> invoiceListToUpdate = new List<Invoice__c>();

            Opportunity OppRec = new Opportunity();
            OppRec.Id = recordId;
            OppRec.Loan_Tenure__c = PartialTenureValue;
            OppRec.Loan_Amount__c = Amount - PartialUpfrontValue;
            OppRec.Loan_Type__c = LoanType;
            OppRec.NBFCPartner__c = partialNBFCValue;
            OppRec.Upfront_Amount__c = PartialUpfrontValue;
            oppRec.Due_Amount__c = Amount - PartialUpfrontValue;
            OppRec.Seek_Loan__c = 'Yes';
            OppRec.Payment_Type__c = 'Partial Payment';
            OppRec.Payment_Status__c = 'Initiated';
            OppRec.Payment_Mode__c = 'Loan';
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            OppRec.Payment_Initiated__c = true;


            Update OppRec;

            Invoice__c invRec = new Invoice__c();
            invRec.Opportunity__c = recordId;
            invRec.Status__c = 'Initiated';
            invRec.Amount__c = PartialUpfrontValue;
            invRec.Type__c = 'Payment';
            invRec.Mode_Terms_of_Payment__c = 'Online';
            invRec.Initiated_Date__c = System.Today();
            invRec.Invoice_Due_Date__c = System.Today() + 2;
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

            if (!invoiceListToUpdate.isEmpty())
                insert invoiceListToUpdate;
            if (paymentType == 'razorpay'){
                return RazorpayPaymentHandler.initateRazorpayPament(invRec.id, longUnixTimeStamp);
            } else{
                ccAvenueLwcController.initateCCAvenuePayment(invRec.id, longUnixTimeStamp);
            }
            return 'Success';
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('PaymentOnOpportunityApexController', 'OppUpdateOnPartialLoan', e, null);
            return null;
        }
    }

}