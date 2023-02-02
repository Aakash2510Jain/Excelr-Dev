@RestResource(urlMapping = '/create_Account')
/*
* {
"Name": "Aakash Jain",
"Phone": "9560635420",
"Email__c": "aakash.jain123@gmail.com ",
"Course__c": "Data Science",
"Type_of_Course__c": "combo",
"City__c": "Delhi",
"Form_Names__c": "Live Virtual",
"Source__c": "Youtube",
"UTM_Medium__c": "Direct",
"UTM_Campaign__c": "Campaign Name",
"UTM_Device__c": "Device Name",
"UTM_AdGroup__c": "Ad Group",
"UTM_Term__c": "Term",
"UTM_Channel__c": "Channel",
"UTM_Type__c": "RMKT",
"Location_UTM__c": "Location",
"UTM_Variety__c": "Variety",
"UTM_Experiment__c": "Experiment",
"Enter_UTM_Link__c": "Link"
}
*/
global class API_CreateAccount{
    @HttpPost
    global static void doPost(){
         
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString' + requestString);
        List<Lead> existingLeadByEmail = new List<Lead>();
        List<Lead> convertedLeadByEmail = new List<Lead>();
        
        if (!String.isEmpty(requestString)){
            Account newAccount = (Account) JSON.deserialize(requestString, Account.class);
            if (newAccount != null){
                existingLeadByEmail = [Select Id, Email
                                       From Lead
                                       where Email = :newAccount.Email__c and isConverted = false
                                       limit 1];
                convertedLeadByEmail = [Select Id, Email
                                        From Lead
                                        where Email = :newAccount.Email__c and isConverted = true
                                        limit 1];
                
                if (!convertedLeadByEmail.isEmpty()){
                    Utility.createApplicationInstance(string.valueOf(convertedLeadByEmail[0].ConvertedAccountId), newAccount.Course__c,requestString);
                    Opportunity opportunityRec = new Opportunity(Name = newAccount.Course__c, AccountId = convertedLeadByEmail[0].ConvertedAccountId, CloseDate = Date.today().addDays(2), StageName = 'Proposal');
                    insert opportunityRec;
                    
                } else{
                    
                    if (!existingLeadByEmail.isEmpty()){
                        //update Lead course
                        //Insert application
                        
                        Utility.createApplicationInstance(existingLeadByEmail[0].Id, newAccount.Course__c, requestString);
                        
                    } else{
                        //Insert Lead
                        //Insert Application
                        Lead leadRec = new Lead();
                        leadRec.Email = newAccount.Email__c;
                        leadRec.Phone = newAccount.Phone;
                        leadRec.LastName = newAccount.Name;
                        leadRec.LeadSource = newAccount.Source__c;
                        //leadRec.Form_Source__c = newAccount.Form_Source__c;
                        leadRec.Enter_UTM_Link__c = newAccount.Enter_UTM_Link__c;
                        
                        leadRec.Course__c = newAccount.Course__c != null ? newAccount.Course__c : 'NA';
                        leadRec.City__c = newAccount.City__c != null ? newAccount.City__c : 'NA';
                        leadRec.Form_Names__c = newAccount.Form_Names__c;                        
                        leadRec.UTM_Campaign__c = newAccount.UTM_Campaign__c;
                        leadRec.UTM_Device__c = newAccount.UTM_Device__c;
                        leadRec.UTM_AdGroup__c = newAccount.UTM_AdGroup__c;
                        leadRec.UTM_Term__c = newAccount.UTM_Term__c;
                        leadRec.UTM_Channel__c = newAccount.UTM_Channel__c;
                        leadRec.UTM_Type__c = newAccount.UTM_Type__c;
                        leadRec.UTM_Location__c = newAccount.Location_UTM__c;
                        leadRec.UTM_Variety__c = newAccount.UTM_Variety__c;
                        leadRec.UTM_Experiment__c = newAccount.UTM_Experiment__c;
                        leadRec.UTM_Medium__c = newAccount.UTM_Medium__c;
                        leadRec.Type_of_Course__c = newAccount.Type_of_Course__c;
                        leadRec.Lead_Gen_Path__c = newAccount.Lead_Gen_Path__c != null ? newAccount.Lead_Gen_Path__c:'NA';
                        leadRec.GCLID__c = newAccount.GCLID__c;
                        
                        String leadid = insertLead(leadRec, requestString);
                        system.debug('leadRec-->'+leadRec);
                        system.debug('leadid-->'+leadid);
                        if (leadRec != null){
                            system.debug('Inside If');
                            system.debug('leadid-->'+leadid);
                            
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', 'Account created successfully ref Id:' + leadId)));
                        }else{
                            system.debug('Inside Else');
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Could not create Account')));
                        }
                    }
                }
            }
        } else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Bad Request')));
            RestContext.response.statusCode = 400;
        }
    
    }
    
    public static string insertLead(Lead leadRec, string requestString){
        try{
            system.debug('--- leadRec ' + leadRec);
            insert leadRec;
            return leadRec.id;
        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount', 'insertLead', e, requestString);
            return null;
        }
    }
    
    public static string updateLead(Lead leadRec ){
        try{
            system.debug('--- leadRec ' + leadRec);
            update leadRec;
            return leadRec.id;
        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount', 'updateLead', e, null);
            return null;
        }
    }
    
    public static string insertApplication(Application__c appRec, String requestString){
        try{
            system.debug('--- leadRec ' + appRec);
            insert appRec;
            return appRec.Id;
        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount', 'insertApplication', e, requestString);
            return null;
        }
    }
    
}