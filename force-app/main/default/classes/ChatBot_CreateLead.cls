public without sharing class ChatBot_CreateLead {
    @InvocableMethod(label='Create Lead from Chatbot')
    public static void insertLeadRec(List<string> leadData){
        try{
            system.debug('leadData-->'+leadData);
            /*Lead leadRec = new Lead();
            leadRec.FirstName = firstName;
            leadRec.LastName = LastName;
            leadRec.email = email;
            leadRec.phone = phone;
            leadRec.company = '--';
            insert leadRec;*/
        } catch (Exception e){
          system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
          HandleBusinessException.captureError('ChatBot_CreateLead', 'insertLeadRec', e , null);
           
        }
}
}