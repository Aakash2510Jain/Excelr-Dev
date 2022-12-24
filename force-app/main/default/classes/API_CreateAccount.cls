@RestResource(urlMapping = '/create_Account')
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
                    Utility.createApplicationInstance(string.valueOf(convertedLeadByEmail[0].ConvertedAccountId), newAccount.Course__c);
                    Opportunity opportunityRec = new Opportunity(Name = newAccount.Course__c, AccountId = convertedLeadByEmail[0].ConvertedAccountId, CloseDate = Date.today().addDays(2), StageName = 'Proposal');
                    insert opportunityRec;

                } else{
                    Lead leadRec = new Lead();

                    if (!existingLeadByEmail.isEmpty()){
                        //update Lead course
                        //Insert application

                        Utility.createApplicationInstance(existingLeadByEmail[0].Id, newAccount.Course__c);

                    } else{
                        //Insert Lead
                        //Insert Application

                        leadRec.Email = newAccount.Email__c;
                        leadRec.Phone = newAccount.Phone;
                        leadRec.LastName = newAccount.Name;
                        leadRec.LeadSource = newAccount.Source__c;
                        leadRec.Form_Source__c = newAccount.Form_Source__c;
                        leadRec.Enter_UTM_Link__c = newAccount.Enter_UTM_Link__c;
                        //leadRec.Company = newAccount.Company != null?newAccount.Company :'--';
                        String leadid = insertLead(leadRec);
                        //string appRecId = Utility.createApplicationInstance(existingLeadByEmail[0].Id, '');
                    }
                    if (leadRec != null)
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', 'Account created successfully ref Id:' + leadRec.id)));
                    else
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Could not create Account')));
                }
            }
        } else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Bad Request')));
            RestContext.response.statusCode = 400;
        }
    }

    public static string insertLead(Lead leadRec){
        try{
            system.debug('--- leadRec ' + leadRec);
            insert leadRec;
            return leadRec.id;
        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount', 'insertAccount', e);
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
            HandleBusinessException.captureError('API_CreateAccount', 'insertAccount', e);
            return null;
        }
    }

    public static string insertApplication(Application__c appRec){
        try{
            system.debug('--- leadRec ' + appRec);
            insert appRec;
            return appRec.Id;
        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount', 'insertAccount', e);
            return null;
        }
    }

}