public without sharing class InterviewApplicationController {

    @RemoteAction
    public static string saveStudentDetails(Contact studentDetails, string opportunityId,string collegeName){
        try{
            List<Opportunity> existingOppRecord = New List<Opportunity>();
            if(!String.isBlank(opportunityId)){
                existingOppRecord = [SELECT Id,Name,AccountId From Opportunity WHERE Id=: opportunityId];
            }
               existingOppRecord[0].College_Name__c = collegeName;
            update  existingOppRecord[0];
            if(!String.isBlank(existingOppRecord[0].AccountId)){
                List<Contact> conList = [SELECT Id,Name,Email From Contact WHERE AccountId =: existingOppRecord[0].AccountId AND Email=: studentDetails.Email];
                if(conList.size() > 0){
                    return 'Email already Exists';
                }else{
                    studentDetails.AccountId = existingOppRecord[0].AccountId;
                    insert studentDetails;
                }
            }
            return studentDetails.Id;
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
    
    @RemoteAction
    public Static  List<College__c> getAllCollegeRecords(){
         List<College__c> collegeList;
        try{
            
            collegeList = [SELECT Id,Name from College__c];
            System.debug('College List--->'+collegeList);
            
        }catch(Exception e){
            
            system.debug('Exception Line Number--->'+e.getLineNumber());
            System.debug('Exception Message--->'+e.getMessage());
        }
        return collegeList;
    }

}