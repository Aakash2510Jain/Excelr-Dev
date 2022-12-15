public class ChatBot_CaseStatus {
@InvocableMethod(label='Get Case Status')
    public static List<string> getCaseStatus(List<String> caseNum){
        case cs = [select id,CaseNumber,Status from case where CaseNumber =:caseNum[0]];
        List<String> str = new list<String>{cs.Status};
        return str;
    }
}