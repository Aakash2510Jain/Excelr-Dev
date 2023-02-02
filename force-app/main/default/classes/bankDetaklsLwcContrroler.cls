public with sharing class bankDetaklsLwcContrroler {
    @auraenabled
    public static void createBankDetails(String AcNum,String Bname,String ifseCode,String CandidateEmail, String Phone){
        try{
        List<Account> accList = new List<Account>();

        accList = [Select Id From Account where Email__c = : CandidateEmail limit 1];

        if(!accList.isEmpty()){
            system.debug('YES');
            Bank_Details__c  bankRec  = new Bank_Details__c ();
            bankRec.Account_No__c=AcNum;
            bankRec.Bank_Name__c=Bname;
            bankRec.IFSC_Code__c=ifseCode;
            bankRec.Candidate_Email__c=CandidateEmail;
            bankRec.Candidate_Phone__c=Phone;
            bankRec.Account__c=accList[0].Id;
            system.debug('bankRec:::'+bankRec);
            insert bankRec;        
        }
        
        else {
            system.debug('NO');
            Bank_Details__c  bankRec  = new Bank_Details__c ();
            bankRec.Account_No__c=AcNum;
            bankRec.Bank_Name__c=Bname;
            bankRec.IFSC_Code__c=ifseCode;
            bankRec.Candidate_Email__c=CandidateEmail;
            bankRec.Candidate_Phone__c=Phone;
            system.debug('bankRec:::'+bankRec);
           insert bankRec;  
            
        }
        
        /*

// accList = [Select Id From Account where Email__c = : CandidateEmail];
if(!accList.isEmpty()){
Bank_Details__c  bankRec  = new Bank_Details__c ();
bankRec.Account_No__c=AcNum;
bankRec.Bank_Name__c=Bname;
bankRec.IFSC_Code__c=ifseCode;
bankRec.Account__c = accList[0].Id;
bankRec.Candidate_Email__c=CandidateEmail;
bankRec.Candidate_Phone__c=Phone;
// bankRec.Account_No__c=AcNum;
system.debug('bankRec:::'+bankRec);
insert bankRec;
}else{
Bank_Details__c  bankRec  = new Bank_Details__c ();
bankRec.Account_No__c=AcNum;
bankRec.Bank_Name__c=Bname;
bankRec.IFSC_Code__c=ifseCode;
bankRec.Candidate_Email__c=CandidateEmail;
bankRec.Candidate_Phone__c=Phone;
// bankRec.Account_No__c=AcNum;
system.debug('bankRec:::'+bankRec);
insert bankRec;
}*/
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('bankDetaklsLwcContrroler', 'createBankDetails', e , null);
      
    }
}
}