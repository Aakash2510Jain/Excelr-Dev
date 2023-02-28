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
            insertLead(Utility.insertLeadViaAPI(newAccount), requestString);
            /*
            if (newAccount != null){
                
                string queryStringForNonConvertedLead = 'select Id, Email, status, course__c, Customers__c,OwnerId,Alternate_Phone__c,Phone From Lead ';
                String queryStringForConvertedLead = 'select Id, Email, status, course__c, Customers__c,OwnerId,Alternate_Phone__c,Phone From Lead ';
                
                List<String> whereClauses = new List<String>();
                
                if (newAccount.Email__c != null) {
                    whereClauses.add('Email = \'' + newAccount.Email__c+'\'');
                }
                if (newAccount.Alternate_Email__c != null) {
                    whereClauses.add('Alternate_Email__c = \'' + newAccount.Alternate_Email__c+'\'');
                }
                if (newAccount.Phone != null) {
                    whereClauses.add('Phone LIKE \'%'+newAccount.Phone+'\'');
                }
                if (newAccount.Alternate_Phone__c != null) {
                    whereClauses.add('Alternate_Phone__c LIKE \'%'+newAccount.Alternate_Phone__c+'\'');
                }
                
                if (!whereClauses.isEmpty()) {
                    String whereClause = ' WHERE ( ' + String.join(whereClauses, ' OR ');
                    queryStringForNonConvertedLead = queryStringForNonConvertedLead + whereClause+' ) and isConverted = false order by CreatedDate Desc limit 1';
                    queryStringForConvertedLead = queryStringForConvertedLead + whereClause+' ) and isConverted = true order by CreatedDate Desc limit 1';
                }
                system.debug('queryStringForNonConvertedLead---->'+queryStringForNonConvertedLead);
                system.debug('queryStringForConvertedLead-->'+queryStringForConvertedLead);
                
                existingLeadByEmail = Database.query(queryStringForNonConvertedLead);
                
                system.debug('existingLeadByEmail-->'+existingLeadByEmail);
                
                convertedLeadByEmail = Database.query(queryStringForConvertedLead);
                
                system.debug('convertedLeadByEmail-->'+convertedLeadByEmail);
                if (!convertedLeadByEmail.isEmpty()){
                    Utility.createApplicationInstance(string.valueOf(convertedLeadByEmail[0].ConvertedAccountId), newAccount.Course__c, requestString);
                    Opportunity opportunityRec = new Opportunity(Name = newAccount.Course__c, AccountId = convertedLeadByEmail[0].ConvertedAccountId, CloseDate = Date.today().addDays(2), StageName = 'Proposal');
                    insert opportunityRec;
                    
                } else{
                    system.debug('Non-Converted Lead doesnot exist');
                    if (!existingLeadByEmail.isEmpty()){
                        for (Lead leadRec : existingLeadByEmail){
                            system.debug('leadRec.Status--->'+leadRec.Status);
                            system.debug('leadRec.Course__c--->'+leadRec.Course__c);
                            system.debug('newAccount.Course__c---->'+newAccount.Course__c);
                            
                            if ((leadRec.Status == 'Dead' || leadRec.Status == 'Junk') && leadRec.Course__c == newAccount.Course__c){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                Lead insertedLeadRec = insertLead(Utility.insertLeadViaAPI(newAccount), requestString, leadRec.Customers__c);
                            } else if ((leadRec.Status == 'Dead' || leadRec.Status == 'Junk') && leadRec.Course__c != newAccount.Course__c){
                                system.debug('dead or junk and course is different');    
                                system.debug('Create new Lead');
                                Lead insertedLeadRec = insertLead(Utility.insertLeadViaAPI(newAccount), requestString, leadRec.Customers__c);
                            } else if ((leadRec.Status != 'Dead' && leadRec.Status != 'Junk') && leadRec.Course__c == newAccount.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                string taskId = Utility.createTaskViaLeadCreationAPI(leadRec);
                            } else if ((leadRec.Status != 'Dead' && leadRec.Status != 'Junk') && leadRec.Course__c != newAccount.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                string applicationId = Utility.createApplicationViaLeadCreationAPI(leadRec);
                            }
                        }
                    } else{
                        String customerId = Utility.createCustomerViaLeadCreationAPI(newAccount);
                        Lead insertedLeadRec = insertLead(Utility.insertLeadViaAPI(newAccount), requestString, customerId);
                        string applicationId = Utility.createApplicationViaLeadCreationAPI(insertedLeadRec);
                        system.debug('leadid-->' + insertedLeadRec.Id);
                        if (insertedLeadRec.Id != null){
                            system.debug('Inside If');
                            system.debug('insertedLeadRec.Id-->' + insertedLeadRec.Id);
                            
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', 'Account created successfully ref Id:' + insertedLeadRec.Id)));
                        } else{
                            system.debug('Inside Else');
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Could not create Account')));
                        }
                    }
                }
            }*/
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', 'Response Captured Successfully')));

        } else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Some Error has Occured')));
            RestContext.response.statusCode = 400;
        }
    }
    
    public static Lead insertLead(Lead leadRec, string requestString){
        try{
            system.debug('--- leadRec ' + leadRec);
            /*
leadRec.Customers__c = customerId;
leadRec.CID__c = [Select CID__c From Customers__c where id =:customerId ].CID__c;
*/
            insert leadRec;
            return leadRec;
        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount', 'insertLead', e, requestString);
            return null;
        }
    }
    
    public static string updateLead(Lead leadRec){
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