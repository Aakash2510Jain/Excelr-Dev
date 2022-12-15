public class ChatBot_PaymentDetails {
    @InvocableMethod(label='Payment Enquiry')
    public static List<string> getProductlist(List<string> paymentId){
        List<opportunity> oppList = [select name,id,Amount from opportunity where Payment_Id__c IN:paymentId];
        if(oppList.size() >0)
        	return New List<string>{string.valueOf(oppList[0].Amount)};
        else
            return null;
    }
}