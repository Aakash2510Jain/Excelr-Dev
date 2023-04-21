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
global without sharing class API_CreateAccount{
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
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', 'Response Captured Successfully')));
            
        } else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Some Error has Occured')));
            RestContext.response.statusCode = 400;
        }
    }
    
    public static Lead insertLead(Lead leadRec, string requestString){
        try{
            system.debug('--- leadRec ' + leadRec);
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