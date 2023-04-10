public without sharing class UtilityClassForTestClass {
    public Static Account insertAccRec(string name,string phone,string email,string source,string formsource,string utmlink,string cource,string city,string fromname,string UTMcam,
                                       string UTMdev,string UTMad,string UTMterm,string UTMchan,string UTMtyp,string UTMloc,string UTMvar,string UTMexp,string UTMmed,string typecource){
                                           Account newAcc = new Account();
                                           newAcc.Name = name;  
                                           newAcc.Phone = phone;
                                           newAcc.Email__c =email;
                                           //newAcc.UTM_Source__c =source;
                                           newAcc.Enter_UTM_Link__c = utmlink;
                                           newAcc.Course__c = cource; 
                                           newAcc.City__c = city;
                                           newAcc.Form_Names__c = fromname;
                                           newAcc.UTM_Campaign__c = UTMcam;
                                           newAcc.UTM_Device__c = UTMad;
                                           newAcc.UTM_Term__c = UTMterm;                            
                                           newAcc.UTM_Channel__c = UTMchan;  
                                           newAcc.UTM_Type__c = UTMtyp;
                                           newAcc.Location_UTM__c = UTMloc;
                                           newAcc.UTM_Variety__c = UTMvar;
                                           newAcc.UTM_Experiment__c = UTMexp;
                                           newAcc.UTM_Medium__c = UTMmed;
                                           newAcc.Type_of_Course__c = typecource;
                                           return newAcc;
                                       }
    public Static Lead insertLead(string firstname,string lastName,string email,string phone,string source,string formsource,string utmlink,string cource,string city,string fromname,string UTMcam,
                                  string UTMdev,string UTMad,string UTMterm,string UTMchan,string UTMtyp,string UTMloc,string UTMvar,string UTMexp,string UTMmed,string typecource){
                                      Lead leadRec = new Lead();
                                      leadRec.FirstName = firstname;
                                      leadRec.LastName = lastName;
                                      leadRec.Email = email;
                                      leadRec.Phone = phone;
                                      //leadRec.UTM_Source__c = source;
                                      leadRec.Enter_UTM_Link__c = utmlink;   
                                      leadRec.City__c = city;
                                      leadRec.Course__c = cource;
                                      leadRec.Form_Names__c = fromname;                        
                                      leadRec.UTM_Campaign__c = UTMcam;
                                      leadRec.UTM_Device__c = UTMdev;
                                      leadRec.UTM_AdGroup__c = UTMad;
                                      leadRec.UTM_Term__c = UTMterm;
                                      leadRec.UTM_Channel__c = UTMchan;
                                      leadRec.UTM_Type__c = UTMtyp;
                                      leadRec.UTM_Location__c = UTMloc;
                                      leadRec.UTM_Variety__c = UTMvar;
                                      leadRec.UTM_Experiment__c =UTMexp;
                                      leadRec.UTM_Medium__c = UTMmed;
                                      leadRec.Type_of_Course__c = typecource;
                                      
                                      return leadRec;
                                  }
    public static Opportunity insertOpp(string name,date dates,string stagename,ID accid ){
        Opportunity opp = new Opportunity();
        opp.AccountId = accid;
        opp.Name = name;
        opp.CloseDate = system.today();
        opp.StageName = stagename;
        return opp;
    }
    
}