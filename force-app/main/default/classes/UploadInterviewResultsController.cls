public class UploadInterviewResultsController {
    
    @AuraEnabled
    
    public static Upload_Interview_Results__mdt uploadResultCSVFormat(){
        
        List<Upload_Interview_Results__mdt> uploadCSVFileFormat = [SELECT Field_API_Name__c,Id,Label,Sequence__c FROM Upload_Interview_Results__mdt];
        system.debug('uploadCSVFileFormat'+uploadCSVFileFormat);
        return uploadCSVFileFormat[0];
    } 

}