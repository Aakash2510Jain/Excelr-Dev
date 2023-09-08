public without sharing class ILogRelatedListLwcController {
    
    @AuraEnabled(Cacheable = true)
    public static List<LoggerWrapper> passRecordIds(Id recIds) {
        List<LoggerWrapper> loggersList = new List<LoggerWrapper>();
        system.debug('recIds -- ' + recIds);
        
        try {
            system.debug('recIds -- ----> ' + recIds);
            string recordId = '%'+recIds+'%';
            
            List<utillabs__Integration_Log__c> intRecs = [
                SELECT Id, Name, utillabs__EndPoint__c, utillabs__HTTP_Method__c,
                utillabs__Integration_Type__c, utillabs__Processing_Time_in_MilliSeconds__c,
                Reference_Id__c, utillabs__Request_Body__c, utillabs__Response_Body__c,
                utillabs__Response_Status_Code__c, CreatedDate
                FROM utillabs__Integration_Log__c WHERE Reference_Id__c LIKE: recordId
            ];
            System.debug('intRecs-->'+intRecs);
            
            for (utillabs__Integration_Log__c log : intRecs) {
                LoggerWrapper wrapper = new LoggerWrapper();
                wrapper.id = log.Id;
                wrapper.name = log.Name;
                wrapper.endPoint = log.utillabs__EndPoint__c;
                wrapper.methodType = log.utillabs__HTTP_Method__c;
                wrapper.integrationType = log.utillabs__Integration_Type__c;
                wrapper.processingTimeInMilliseconds = log.utillabs__Processing_Time_in_MilliSeconds__c;
                wrapper.referenceId = log.Reference_Id__c;
                wrapper.requestBody = log.utillabs__Request_Body__c;
                wrapper.responseBody = log.utillabs__Response_Body__c;
                wrapper.responseStatusCode = log.utillabs__Response_Status_Code__c;
                wrapper.createdDate = log.CreatedDate;
                wrapper.nameUrl = '/' + log.Id;
                loggersList.add(wrapper);
            }
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred while processing data.');
        }
        System.debug('loggersList---->'+loggersList);
        
        return loggersList;
    }
    
    public class LoggerWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String endPoint;
        @AuraEnabled
        public String methodType;
        @AuraEnabled
        public String integrationType;
        @AuraEnabled
        public Decimal processingTimeInMilliseconds;
        @AuraEnabled
        public String referenceId;
        @AuraEnabled
        public String requestBody;
        @AuraEnabled
        public String responseBody;
        @AuraEnabled
        public Decimal responseStatusCode;
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public String nameUrl;
    }
}