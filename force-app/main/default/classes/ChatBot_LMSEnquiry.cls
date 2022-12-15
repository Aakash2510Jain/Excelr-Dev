public class ChatBot_LMSEnquiry {
    @InvocableMethod(label='LMS Enquiry')
    public static List<Account> getProductlist(List<string> custId){
        system.debug('custId--'+custId);
        List<Account> accList = [select LMS_Password__c,LMS_Username__c,LMS_Activation_Status__c from Account where Account_Number__c IN:custId];
        system.debug('accList---'+accList);
        return accList;
    }
}