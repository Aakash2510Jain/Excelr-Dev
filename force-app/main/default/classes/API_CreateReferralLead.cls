@RestResource(urlMapping = '/create_Referral_Lead')
global without sharing class API_CreateReferralLead{
    @HttpPost
    global static void InsertreferralLead(){
        try{
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString' + requestString);
        if ( !String.isEmpty(requestString) ){
            Lead newLead = ( Lead )JSON.deserialize(requestString, Lead.class);
            System.debug('newLead ====> ' + newLead);
            if ( newLead != null ){
                if ( newLead.Referral_Email__c != null ){
                    List<Lead> LeadList = [Select id, ownerId, email
                                           From Lead
                                           Where Email = :newLead.Referral_Email__c
                                           LIMIT 1];
                    if ( LeadList.size() > 0 ){
                        newLead.referrer__c = LeadList[0].Id;
                        newLead.OwnerId = LeadList[0].OwnerId;
                        String leadId = insertLead(newLead, requestString);
                        if ( leadId != null ){
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', 'Lead created successfully ref Id:' + leadId)));
                        }
                        else{
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Could not create Lead')));
                        }

                    }
                    else{
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Referral Lead Email Does not Exist In the System!!!! Please Provide Correct Referral Email!!!!')));

                    }
                }
                else{
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Bad Request')));
                    RestContext.response.statusCode = 400;
                }


            }

        }
        else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Bad Request')));
            RestContext.response.statusCode = 400;
        }
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateReferralLead', 'InsertreferralLead', e, null);
             
        }
    }

    private static String insertLead(Lead leadRec, String requestString){
        try{
            system.debug('--- leadRec ' + leadRec);
            insert leadRec;
            return leadRec.Id;
        }
        catch ( Exception e ){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
           HandleBusinessException.captureError('API_CreateReferralLead', 'insertLead', e, requestString);
            return null;
        }
    }

}