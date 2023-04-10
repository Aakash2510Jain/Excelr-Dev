@RestResource(urlMapping='/create_contact')
global without sharing class API_CreateContact {
  @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        if(!String.isEmpty(requestString)) {
            List<string> newEmailIds = (List<String>)System.JSON.deserialize(requestString, List<String>.class);
            system.debug('newEmailIds--'+newEmailIds);
            if(newEmailIds != null) {
				string message = insertContacts(newEmailIds);
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', message)));

                //system.debug('insertLead :: ' + insertLead(leadWrapper));
               }
        }else {
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Bad Request')));
            RestContext.response.statusCode = 400;
        }
    }
    
    public static string insertContacts(List<string> emailIds){
      try{
       if(emailIds.size() <= 0)
            return 'no email id\'s recieved';
        List<contact> contactList = [select name,id from contact where email In: emailIds];
        Map<string,string> emailXconId = New Map<string,string>();
        for(contact con:contactList){
            if(con.email != null)
               emailXconId.put(con.email, con.Id); 
        }
        list<contact> contactsToInsert = New List<contact>();
        for(string emailId:emailIds){
            if(!emailXconId.containsKey(emailId)){
                contactsToInsert.add(New Contact(lastName=emailId,email=emailId));
            }
        }
        insert contactsToInsert;
        return 'contacts inserted';
    }  catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
        HandleBusinessException.captureError('API_CreateContact', 'insertContacts', e, null);
        return Null;
    }
    }
    
    
}