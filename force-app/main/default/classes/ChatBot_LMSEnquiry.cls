public without sharing class ChatBot_LMSEnquiry {
    @InvocableMethod(label='LMS Enquiry')
    public static List<Account> getProductlist(List<string> custId){
     try{   
            system.debug('custId--'+custId);
            List<Account> accList = [select LMS_Password__c,LMS_Username__c,LMS_Activation_Status__c from Account ];
            system.debug('accList---'+accList);
            return accList;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatBot_LMSEnquiry', 'getProductlist', e , null);
            return null;
            }
}
}