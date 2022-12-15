public class ChatBot_AccountDetails {
   @InvocableMethod(label='Get Account Info')
    public static List<Account> getAccountInfo(List<String> accountId){
        List<Account> accList = [select name,id from Account where Account_Number__c IN:accountId];
        return accList;
    }
}