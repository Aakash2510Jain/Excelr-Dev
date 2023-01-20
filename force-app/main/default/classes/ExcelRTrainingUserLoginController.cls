public without sharing class ExcelRTrainingUserLoginController {
    

    @RemoteAction
    public static ExcelR_Training_User__c excelRTrainerLogIn(string userName, string password){
        try{
            System.debug('userName ===> ' + userName);
            System.debug('password ===> ' + password);
            List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Email__c,First_Name__c,HashCode__c,Id,Last_Name__c,Name,OwnerId,Password__c,Username__c, Departments__c
                                        FROM ExcelR_Training_User__c 
                                        WHERE Email__c =:userName AND Password__c =:password LIMIT  1];
            system.debug('ExcelRTrainUser----'+ExcelRTrainUser);
            if(ExcelRTrainUser.size() > 0 ){
                //String currentReviewId;
                String hasCode;
                ExcelR_Training_User__c ExcelRUsr = new ExcelR_Training_User__c();
                ExcelRUsr.Email__c = ExcelRTrainUser[0].Email__c;
                ExcelRUsr.First_Name__c = ExcelRTrainUser[0].First_Name__c;
                ExcelRUsr.Last_Name__c = ExcelRTrainUser[0].Last_Name__c;
                ExcelRUsr.Username__c = ExcelRTrainUser[0].Username__c;
                ExcelRUsr.Departments__c = ExcelRTrainUser[0].Departments__c;
                ExcelRUsr.HashCode__c = ExcelRTrainUser[0].id;
                ExcelRUsr.Id = ExcelRTrainUser[0].id;
                hasCode = String.valueOf(ExcelRTrainUser) ;
                System.debug('The Hash Code Value');
                update ExcelRUsr;
                return ExcelRUsr;
            }else{
                return null; 
            }
        }catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            Exceptions__c Exc = new Exceptions__c();
            Exc.Class_Name__c = 'ExcelRTrainingUserLoginController';
			Exc.Error_Message__c = e.getMessage();     
            Exc.Error_Line_No__c = e.getLineNumber();
            Exc.Error_Stack_Trace__c = e.getStackTraceString();
            Exc.Error_Type__c = e.getTypeName();
            Exc.Method_Name__c = 'excelRTrainerLogIn';
            insert Exc;
            
            return null;
        }   
    }
}