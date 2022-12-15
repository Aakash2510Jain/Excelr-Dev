public without sharing class ExcelRTrainingUserLoginController {
    

    @RemoteAction
    public static String excelRTrainerLogIn(string userName, string password){
        try{
            System.debug('userName ===> ' + userName);
            System.debug('password ===> ' + password);
            List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Email__c,First_Name__c,HashCode__c,Id,Last_Name__c,Name,OwnerId,Password__c,Username__c 
                                        FROM ExcelR_Training_User__c 
                                        WHERE Email__c =:userName AND Password__c =:password LIMIT  1];
            system.debug('ExcelRTrainUser----'+ExcelRTrainUser);
            if(ExcelRTrainUser.size() > 0 ){
                //String currentReviewId;
                String hasCode;
                ExcelR_Training_User__c ExcelRUsr = new ExcelR_Training_User__c();
                ExcelRUsr.HashCode__c = HashcodeGenerator.generateRandomString();
                ExcelRUsr.Id = ExcelRTrainUser[0].id;
                hasCode = String.valueOf(ExcelRTrainUser) ;
                System.debug('The Hash Code Value');
                update ExcelRUsr;
                return ExcelRUsr.Id;
            }else{
                return null; 
            }
        }catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            return null;
        }   
    }
}