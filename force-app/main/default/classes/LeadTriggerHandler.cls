public class LeadTriggerHandler{
    static LeadTriggerHandler handlerInstance;

    public static LeadTriggerHandler getInstance(){
        if (handlerInstance == null)
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }

    public void beforeInsert(List<Lead> leadList){
        try{
            for (Lead ld : leadList){
                if (ld.ExcelR_Training_User__c == null){
                    ld.OwnerId = constants.queueId;
                }
                if (ld.Enter_UTM_Link__c != null){
                    //Utility.UTMLinkParams(ld);
                }
                if (string.isEmpty(ld.Company) || string.isBlank(ld.Company)){
                    ld.Company = 'NA';
                }
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Insert', e);
        }
    }

    public void afterInsert(List<Lead> leadList){
        try{
            for (Lead ld : leadList){
                if (ld.LeadSource != null || ld.Course__c != null || ld.Quality_of_Lead__c != null || ld.Quality_of_Lead__c != null || ld.Location__c != null ){
                    LeadAssignmentExecutionCriteria.validateEntryCriteria();
                }
                Utility.createApplicationInstance(ld.Id, ld.Course__c);
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Insert', e);
        }
    }

    public void beforeUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            for (Lead ld : newLeadMap.values()){
                if (ld.Enter_UTM_Link__c != null && ld.Enter_UTM_Link__c != oldLeadMap.get(ld.Id).Enter_UTM_Link__c){
                    //Utility.UTMLinkParams(ld);
                }
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Update', e);
        }
    }

    public void afterUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            system.debug('After Update');
            for (Lead ld : newLeadMap.values()){
                system.debug('Lead Course' + ld.Course__c);
                 if (ld.LeadSource != null || ld.Course__c != null || ld.Quality_of_Lead__c != null || ld.Quality_of_Lead__c != null || ld.Location__c != null ){
                   // LeadAssignmentExecutionCriteria.validateEntryCriteria();
                }
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Update', e);
        }
    }

}