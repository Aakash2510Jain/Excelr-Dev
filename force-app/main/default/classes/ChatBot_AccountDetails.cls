public without sharing class ChatBot_AccountDetails {
   @InvocableMethod(label='Get Account Info')
    public static List<Account> getAccountInfo(List<String> accountId){
        try{
            List<Account> accList = [select name,id from Account];
            return accList;
           }catch (Exception e){
           system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
           HandleBusinessException.captureError('ChatBot_AccountDetails', 'getAccountInfo', e , null);
           return null;
    }
}
}