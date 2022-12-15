public class ChatBot_CreateLead {
    @InvocableMethod(label='Create Lead from Chatbot')
    public static void insertLeadRec(List<string> leadData){
        system.debug('leadData-->'+leadData);
        /*Lead leadRec = new Lead();
        leadRec.FirstName = firstName;
        leadRec.LastName = LastName;
        leadRec.email = email;
        leadRec.phone = phone;
        leadRec.company = '--';
        insert leadRec;*/
    }
}