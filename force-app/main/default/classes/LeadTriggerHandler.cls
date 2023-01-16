public class LeadTriggerHandler{
    static LeadTriggerHandler handlerInstance;

    public static LeadTriggerHandler getInstance(){
        if (handlerInstance == null)
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }

    public void beforeInsert(List<Lead> leadList){
        try{
            set<String> leadQuality = new set<String>();

            for (Lead ld : leadList){
                if (ld.ExcelR_Training_User__c == null && (ld.LeadSource != 'Reference' || ld.Lead_Gen_Path__c != 'Reference')){
                    system.debug('Owner is Queue');
                    ld.OwnerId = constants.queueId;
                }
                if (ld.Enter_UTM_Link__c != null){
                    //Utility.UTMLinkParams(ld);
                }
                if (string.isEmpty(ld.Company) || string.isBlank(ld.Company)){
                    ld.Company = 'NA';
                }
                // quality of Leads
                if (ld.LeadSource != null && ld.UTM_Medium__c != null){
                    if ((ld.LeadSource == 'Reference' && ld.UTM_Medium__c == 'NA') || (ld.LeadSource == 'Walkin' && ld.UTM_Medium__c == 'NA') || (ld.LeadSource == 'LMS References' && ld.UTM_Medium__c == 'NA') || (ld.LeadSource == 'GoogleAds' && ld.UTM_Medium__c == 'Search') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'GoogleOrganic') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'GoogleLocal') || (ld.LeadSource == 'BingAds' && ld.UTM_Medium__c == 'Search') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'BingOrganic') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'BingLocal') || (ld.LeadSource == 'NA' && ld.UTM_Medium__c == 'Direct')){
                        ld.Quality_of_Lead__c = 'PLM';
                    } else if ((ld.LeadSource == 'Google' && ld.UTM_Medium__c == 'Discovery') || (ld.LeadSource == '3rd Party' && ld.UTM_Medium__c == 'Referral') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Lead form') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Conversion campaign') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Boost Post') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Lead form') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Conversion campaign') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Boost Post') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Lead Generation') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Website conversions') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Sponsored Content')){
                        ld.Quality_of_Lead__c = 'SLM';
                    } else{
                        ld.Quality_of_Lead__c = 'TLM';
                    }
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
                Utility.createApplicationInstance(ld.Id, ld.Course__c);
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Insert', e);
        }
    }

    public void beforeUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            system.debug('Before Update');
            for (Lead ld : newLeadMap.values()){
                if (ld.Enter_UTM_Link__c != null && ld.Enter_UTM_Link__c != oldLeadMap.get(ld.Id).Enter_UTM_Link__c){
                    //Utility.UTMLinkParams(ld);
                }
                if (ld.LeadSource != null && ld.UTM_Medium__c != null){
                    if ((ld.LeadSource == 'Reference' && ld.UTM_Medium__c == 'NA' && ld.Lead_Gen_Path__c == 'NA') || (ld.LeadSource == 'Walkin' && ld.UTM_Medium__c == 'NA' && ld.Lead_Gen_Path__c == 'NA') || (ld.LeadSource == 'LMS References' && ld.UTM_Medium__c == 'NA' && ld.Lead_Gen_Path__c == 'NA') || (ld.LeadSource == 'GoogleAds' && ld.UTM_Medium__c == 'Search') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'GoogleOrganic') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'GoogleLocal') || (ld.LeadSource == 'BingAds' && ld.UTM_Medium__c == 'Search') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'BingOrganic') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'BingLocal') || (ld.LeadSource == 'NA' && ld.UTM_Medium__c == 'Direct')){
                        system.debug('PLM');
                        ld.Quality_of_Lead__c = 'PLM';
                    } else if ((ld.LeadSource == 'Google' && ld.UTM_Medium__c == 'Discovery') || (ld.LeadSource == '3rd Party' && ld.UTM_Medium__c == 'Referral') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Lead form') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Conversion campaign') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Boost Post') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Lead form') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Conversion campaign') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Boost Post') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Lead Generation') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Website conversions') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Sponsored Content')){
                        system.debug('SLM');
                        ld.Quality_of_Lead__c = 'SLM';
                    } else{
                        system.debug('TLM');
                        ld.Quality_of_Lead__c = 'TLM';
                    }
                }
                system.debug('ld.Quality_of_Lead__c-->' + ld.Quality_of_Lead__c);
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Update', e);
        }
    }

    public void afterUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            system.debug('After Update');
            set<String> leadQuality = new set<String>();
            for (Lead ld : newLeadMap.values()){

            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Update', e);
        }
    }

}