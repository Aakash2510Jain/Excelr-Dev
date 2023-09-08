public without sharing class InterviewApplicationController {
    
    @RemoteAction
    public static string saveStudentDetails(Contact studentDetails, string programId,string collegeName){
        try{
            system.debug('programId ==> '+programId);
            system.debug('studentDetails ==> '+studentDetails);
           
            List<Program__c> exitingProgramList = New List<Program__c>();
            if(!String.isBlank(programId)){
                exitingProgramList = [SELECT Id, Name, stage__C, Account__c, Account__r.Name, Stream__c, Program_Start_Date_Time__c, Account__r.ShippingCountry, Account__r.ShippingCity,Account__r.ShippingState,Account__r.ShippingStreet,Account__r.ShippingPostalcode FROM Program__c WHERE Id =: programId];
                exitingProgramList[0].stage__C = 'Confirmed/Registration';
                update exitingProgramList;
            }
            system.debug('exitingProgramList[0].Account__c ==> '+exitingProgramList[0].Account__c);
            if(!String.isBlank(exitingProgramList[0].Account__c)){
                Stream__c streamRec = [SELECT Id, Total_No_Of_Years__c FROM Stream__c WHERE Id =: exitingProgramList[0].Stream__c];
                List<Contact> conList = [SELECT Id, Name, Email From Contact WHERE AccountId =: exitingProgramList[0].Account__c AND Email=: studentDetails.Email];
                if(conList.size() > 0){
                    return 'Email already Exists';
                }else{
                    studentDetails.AccountId = exitingProgramList[0].Account__c;
                    system.debug('studentDetails ==> '+studentDetails);
                    insert studentDetails;
                    Utility.sendRegistrationEmail(studentDetails.Id, exitingProgramList[0].Name, exitingProgramList[0].Account__r.Name, exitingProgramList[0].Program_Start_Date_Time__c, exitingProgramList[0].Account__r.ShippingCountry, exitingProgramList[0].Account__r.ShippingCity,exitingProgramList[0].Account__r.ShippingState,exitingProgramList[0].Account__r.ShippingStreet,exitingProgramList[0].Account__r.ShippingPostalcode);
                }
                
                Student_Academic_Year__c stuAcademicYearToInsert = New Student_Academic_Year__c();
                stuAcademicYearToInsert.Account__c = exitingProgramList[0].Account__c;
                stuAcademicYearToInsert.Current_Year__c = streamRec.Total_No_Of_Years__c;
                stuAcademicYearToInsert.Student__c = studentDetails.Id;
                insert stuAcademicYearToInsert;
                
                Placement_Application__c placementAppliRecordToInsert = New Placement_Application__c();
                placementAppliRecordToInsert.Contact__c = studentDetails.Id;
                placementAppliRecordToInsert.Program__c = exitingProgramList[0].Id;
                placementAppliRecordToInsert.Student_Academic_Year__c = stuAcademicYearToInsert.Id;
                insert placementAppliRecordToInsert;
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

    @RemoteAction
    public static String getAccountDetails(string programId){
        try{
            String getProgramAccName = [SELECT Id,Account__r.Name From Program__c WHERE Id =: programId].Account__r.Name;
            return getProgramAccName;
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }

    @RemoteAction
    public static Program__c getProgramDate(String programId){
        try{
            List<Program__c> listOfExistingProgram = [SELECT Id,Name,Program_Start_Date_Time__c FROM Program__c WHERE Id =: programId LIMIT 1];
            return listOfExistingProgram[0];
        }catch(Exception e){
            return null;
        }
    }
    
}