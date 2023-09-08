/*
Author : Esha Raaz
*/

@RestResource(urlMapping = '/trainerinvoice')
global without sharing class API_LMSTrainerInvoices {
    public API_LMSTrainerInvoices() {}
    global static List<String> listOfConIds = New List<String>();

    @HttpPost
    global static void postLMS_createTrainerInvoice(){
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        List<API_LMSTrainerInvoicesWrapper> rWrapperList = (List<API_LMSTrainerInvoicesWrapper>)JSON.deserialize(requestString, List<API_LMSTrainerInvoicesWrapper>.class);
        System.debug('--- rWrapperList'+ rWrapperList);    
        String responseBody;

        if(!rWrapperList.isEmpty()){
            String getResponse = processTrainerInvoiceRequest(rWrapperList);

            if(getResponse == 'Success'){
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/trainerinvoice', 'POST', 200, processingStartTime, System.now(),listOfConIds); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }else{
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/trainerinvoice', 'POST', 400, processingStartTime, System.now(),listOfConIds); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }

    private static string processTrainerInvoiceRequest(List<API_LMSTrainerInvoicesWrapper> trainerInvoiceWrapperList){
        try{
            system.debug('trainerInvoiceWrapperList ==> '+trainerInvoiceWrapperList);
            set<string> setOfLMSStuId = New set<string>();
            set<string> setOfProductId = New set<string>();
            set<string> setOfbatchId = New set<string>();
            set<string> setOfInvoiceNumber = New set<string>();
            Map<String,String> mapOfProductIdByLMSExternalId = New Map<String,String>();
            Map<String,String> mapOfBatchIdByExternalBatchId = New Map<String,String>();
            Map<String,String> mapOfStudentIdByLMSId = New Map<String,String>();
            List<Contact> listOfContactToUpsert = New List<Contact>();
            Map<String,Id> mapOfUpdatedConIdByLMSId = New Map<String,Id>();
            Map<String, Trainer_Invoice__c> InvoiceNumberByExistingInvoiceRec= new Map<String, Trainer_Invoice__c>();
            List<Trainer_Invoice__c> listOfInvoicesToUpsert = New List<Trainer_Invoice__c>();
            if(!trainerInvoiceWrapperList.isEmpty()){
                for(API_LMSTrainerInvoicesWrapper singleTrainerInv : trainerInvoiceWrapperList){
                    setOfLMSStuId.add(singleTrainerInv.trainer_lms_id);
                    for(API_LMSTrainerInvoicesWrapper.invoice_list singleInv : singleTrainerInv.invoice_list){
                        setOfProductId.add(singleInv.product_id);
                        setOfbatchId.add(singleInv.batch_id);
                        setOfInvoiceNumber.add(singleInv.invoice_number);
                    }
                }
                system.debug('setOfLMSStuId ==> '+setOfLMSStuId);
                system.debug('setOfProductId ==> '+setOfProductId);
                system.debug('setOfbatchId ==> '+setOfbatchId);

                List<Product2> listOfExistingProductBtExtId = [SELECT Id,LMS_ExternalId__c FROM Product2 WHERE LMS_ExternalId__c IN : setOfProductId];
                system.debug('listOfExistingProductBtExtId ==> '+listOfExistingProductBtExtId);
                List<Batch__c> listOfExistingBatchByBatchId = [SELECT Id,Batch_Id__c FROM Batch__c WHERE Batch_Id__c IN : setOfbatchId];
                system.debug('listOfExistingBatchByBatchId ==> '+listOfExistingBatchByBatchId);
                List<Contact> listOfExistingStudentByLMSId = [SELECT Id,Name,LMS_Student_Id__c FROM Contact WHERE LMS_Student_Id__c IN : setOfLMSStuId];
                system.debug('listOfExistingStudentByLMSId ==> '+listOfExistingStudentByLMSId);

                /* Map Of Product Id By External Id */
                if(!listOfExistingProductBtExtId.isEmpty()){
                    for(Product2 prod : listOfExistingProductBtExtId){
                        mapOfProductIdByLMSExternalId.put(prod.LMS_ExternalId__c, prod.Id);
                    }
                    system.debug('mapOfProductIdByLMSExternalId ==> '+mapOfProductIdByLMSExternalId);
                }

                /* Map Of Batch Id By Batch Id */
                if(!listOfExistingBatchByBatchId.isEmpty()){
                    for(Batch__c batch : listOfExistingBatchByBatchId){
                        mapOfBatchIdByExternalBatchId.put(batch.Batch_Id__c, batch.Id);
                    }
                    system.debug('mapOfBatchIdByExternalBatchId ==> '+mapOfBatchIdByExternalBatchId);
                }

                /* Map Of Student Id By Student LMS Id */
                if(!listOfExistingStudentByLMSId.isEmpty()){
                    for(Contact cont : listOfExistingStudentByLMSId){
                        mapOfStudentIdByLMSId.put(cont.LMS_Student_Id__c, cont.Id);
                    }
                    system.debug('mapOfStudentIdByLMSId ==> '+mapOfStudentIdByLMSId);
                }
            }

            if(!trainerInvoiceWrapperList.isEmpty()){
                for(API_LMSTrainerInvoicesWrapper singleTrainerInv : trainerInvoiceWrapperList){
                    Contact conRecToUpsert = New Contact();
                    if(mapOfStudentIdByLMSId.containsKey(singleTrainerInv.trainer_lms_id)){
                        conRecToUpsert.Id = mapOfStudentIdByLMSId.get(singleTrainerInv.trainer_lms_id);
                    }
                    if(!String.isBlank(singleTrainerInv.first_name)){
                        conRecToUpsert.FirstName = singleTrainerInv.first_name;
                    }
                    if(!String.isBlank(singleTrainerInv.last_name)){
                        conRecToUpsert.LastName = singleTrainerInv.last_name;
                    }
                    if(!String.isBlank(singleTrainerInv.email)){
                        conRecToUpsert.Email = singleTrainerInv.email;
                    }
                    if(!String.isBlank(singleTrainerInv.trainer_lms_id)){
                        conRecToUpsert.LMS_Student_Id__c = singleTrainerInv.trainer_lms_id;
                    }
                    if(!String.isBlank(singleTrainerInv.phone)){
                        conRecToUpsert.Phone = singleTrainerInv.phone;
                    }
                    listOfContactToUpsert.add(conRecToUpsert);
                }
                upsert listOfContactToUpsert;
                system.debug('listOfContactToUpsert ==> '+listOfContactToUpsert);
            }

            if(!listOfContactToUpsert.isEmpty()){
                for(Contact con : listOfContactToUpsert){
                    mapOfUpdatedConIdByLMSId.put(con.LMS_Student_Id__c, con.Id);
                    listOfConIds.add(con.Id);
                }
                system.debug('mapOfUpdatedConIdByLMSId ==> '+mapOfUpdatedConIdByLMSId);
            }

            List<Trainer_Invoice__c> listOfExistingTrainerInvoices = New List<Trainer_Invoice__c>();
            if(!setOfInvoiceNumber.isEmpty()){
                listOfExistingTrainerInvoices = [SELECT Id,Invoice_Number__c FROM Trainer_Invoice__c WHERE Invoice_Number__c IN : setOfInvoiceNumber];
                system.debug('listOfExistingTrainerInvoices ==> '+listOfExistingTrainerInvoices);
            }
            if(!listOfExistingTrainerInvoices.isEmpty()){
                for(Trainer_Invoice__c singleInvoiceRec : listOfExistingTrainerInvoices){
                    InvoiceNumberByExistingInvoiceRec.put(singleInvoiceRec.Invoice_Number__c, singleInvoiceRec);
                }
            }
            system.debug('InvoiceNumberByExistingInvoiceRec ==> '+InvoiceNumberByExistingInvoiceRec);

            if(!trainerInvoiceWrapperList.isEmpty()){
                for(API_LMSTrainerInvoicesWrapper singleTrainerInv : trainerInvoiceWrapperList){
                    if(!singleTrainerInv.invoice_list.isEmpty()){
                        for(API_LMSTrainerInvoicesWrapper.invoice_list singleInv : singleTrainerInv.invoice_list){
                            Trainer_Invoice__c invoiceRecToUpsert = New Trainer_Invoice__c();

                            if(InvoiceNumberByExistingInvoiceRec.containsKey(singleInv.invoice_number)){
                                invoiceRecToUpsert.Id = InvoiceNumberByExistingInvoiceRec.get(singleInv.invoice_number).Id;
                            }
                            if(!String.isBlank(singleTrainerInv.trainer_lms_id)){
                                if (mapOfUpdatedConIdByLMSId.containsKey(singleTrainerInv.trainer_lms_id)){
                                    invoiceRecToUpsert.Trainer__c = mapOfUpdatedConIdByLMSId.get(singleTrainerInv.trainer_lms_id);
                                }
                            }
                            if(!String.isBlank(singleInv.product_id)){
                                if (mapOfProductIdByLMSExternalId.containsKey(singleInv.product_id)){
                                    invoiceRecToUpsert.Product__c = mapOfProductIdByLMSExternalId.get(singleInv.product_id);
                                }
                            }
                            if(!String.isBlank(singleInv.batch_id)){
                                if (mapOfBatchIdByExternalBatchId.containsKey(singleInv.batch_id)){
                                    invoiceRecToUpsert.Batch__c = mapOfBatchIdByExternalBatchId.get(singleInv.batch_id);
                                }
                            }
                            if(!String.isBlank(singleInv.invoice_number)){
                                invoiceRecToUpsert.Invoice_Number__c = singleInv.invoice_number;
                            }
                            if(singleInv.amount != null){
                                invoiceRecToUpsert.Amount__c = singleInv.amount;
                            }
                            if(!String.isBlank(singleInv.status)){
                                invoiceRecToUpsert.Status__c = singleInv.status;
                            }
                            if(singleInv.initiated_date != null){
                                invoiceRecToUpsert.Initiated_Date__c = (Date)JSON.deserialize('"' + String.valueOf(singleInv.initiated_date) + '"', Date.class);
                            }
                            if(singleInv.total_no_of_hours != null){
                                invoiceRecToUpsert.Total_No_Of_Hours__c = singleInv.total_no_of_hours;
                            }
                            if(!String.isBlank(singleInv.contract_type)){
                                invoiceRecToUpsert.Contract_Type__c = singleInv.contract_type;
                            }
                            listOfInvoicesToUpsert.add(invoiceRecToUpsert);
                        }
                    }
                }
                system.debug('listOfInvoicesToUpsert ==> '+listOfInvoicesToUpsert);
                upsert listOfInvoicesToUpsert;
                system.debug('listOfInvoicesToUpsert ==> '+listOfInvoicesToUpsert);
            }
            return 'Success';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
}