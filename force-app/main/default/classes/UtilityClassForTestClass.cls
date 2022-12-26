public class UtilityClassForTestClass {
    public Static Account insertAccRec(string name,string phone,string email,string source,string formsource,string utmlink,string cource){
         Account newAcc = new Account();
            newAcc.Name = name;
            newAcc.Phone = phone;
            newAcc.Email__c =email;
            newAcc.Source__c =source;
            newAcc.Form_Source__c = formsource;
            newAcc.Enter_UTM_Link__c = utmlink;
            newAcc.Course__c = cource;  
            return newAcc;
    }
    public Static Lead insertLead(string firstname,string lastName,string email,string phone,string source,string formsource,string utmlink,string cource){
        Lead leadRec = new Lead();
        leadRec.FirstName = firstname;
        leadRec.LastName = lastName;
        leadRec.Email = email;
        leadRec.Phone = phone;
        leadRec.Source__c = source;
        leadRec.Form_Source__c = formsource;
        leadRec.Enter_UTM_Link__c = utmlink;   
        leadRec.Course__c = cource;
        return leadRec;
    }
    public static Opportunity insertOpp(string name,string dates,string stagename,ID accid){
        Opportunity opp = new Opportunity();
        opp.AccountId = accid;
        opp.Name = name;
        opp.CloseDate = date.valueOf(dates);
        opp.StageName = stagename;
        return opp;
    }
    
}