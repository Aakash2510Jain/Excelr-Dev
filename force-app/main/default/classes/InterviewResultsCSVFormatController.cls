public class InterviewResultsCSVFormatController {
    
    @AuraEnabled
    public static List<pAppWrapper> getpAppList(Id programId){
        system.debug('programId -- ' + programId);
        List<pAppWrapper> pWrapperList = new List<pAppWrapper>();
        List<Placement_Application__c> pAppList = [SELECT Id, Name, Contact__r.Email FROM Placement_Application__c WHERE Program__c =: programId];
        for(Placement_Application__c pApp : pAppList){
            pAppWrapper pWrap = new pAppWrapper();
            pWrap.Application_Id = pApp.Name;
            pWrap.Student_Email = pApp.Contact__r.Email;
            pWrap.Apti_Marks = null;
            pWrap.Apti_Result = '';
            pWrap.GD_Result = '';
            pWrap.PI_Result = '';
            pWrapperList.add(pWrap);
        }
        return pWrapperList;
    }
    
    @AuraEnabled
    public static Upload_Interview_Results__mdt uploadResultCSVFormat(){
        List<Upload_Interview_Results__mdt> uploadCSVFileFormat = [SELECT Field_API_Name__c, Id, Label, Sequence__c FROM Upload_Interview_Results__mdt];
        system.debug('uploadCSVFileFormat'+uploadCSVFileFormat);
        return uploadCSVFileFormat[0];
    } 
    
    public class pAppWrapper{
        @AuraEnabled
        public string Application_Id;
        @AuraEnabled
        public string Student_Email;
        @AuraEnabled
        public decimal Apti_Marks;
        @AuraEnabled
        public string Apti_Result;
        @AuraEnabled
        public string GD_Result;
        @AuraEnabled
        public string PI_Result;
    }
}