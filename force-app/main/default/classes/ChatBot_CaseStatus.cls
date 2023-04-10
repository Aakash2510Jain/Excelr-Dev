public without sharing class ChatBot_CaseStatus {
@InvocableMethod(label='Get Case Status')
    public static List<string> getCaseStatus(List<String> caseNum){
        try{
        case cs = [select id,CaseNumber,Status from case where CaseNumber =:caseNum[0]];
        List<String> str = new list<String>{cs.Status};
        return str;
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('ChatBot_CaseStatus', 'getCaseStatus', e , null);
       return null;
    }
}
}