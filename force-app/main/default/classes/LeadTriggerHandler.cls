public without sharing class LeadTriggerHandler{
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
                system.debug('ld.OwnerId--->'+ld.OwnerId);
                if ( (ld.Lead_Generation_Method__c == 'Voice Form' || ld.Lead_Generation_Method__c == 'Chat Form' || (ld.Lead_Generation_Method__c == 'Generic Form' && ld.Is_User_Assigned__c == 'Not-Assigned' ) || (ld.Lead_Generation_Method__c == 'Walk-in Form' && ld.Is_User_Assigned__c == 'Not-Assigned' ) ) && (ld.LeadSource != 'Reference' || ld.Lead_Gen_Path__c != 'Reference')){
                    system.debug('Owner is Queue');
                    ld.OwnerId = constants.queueId;
                }
                if (ld.Enter_UTM_Link__c != null && ld.Lead_Generation_Method__c != null && (ld.Lead_Generation_Method__c == 'Chat Form' || ld.Lead_Generation_Method__c == 'Generic Form' )){
                    Utility.UTMLinkParams(ld);
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
                
                //handle necessary fields
                if (!string.isEmpty(ld.FirstName) && !string.isBlank(ld.LastName)){
                    ld.Company = ld.FirstName +' '+ld.LastName;
                }
                if (string.isEmpty(ld.FirstName) && !string.isBlank(ld.LastName)){
                    ld.Company = ld.LastName;
                }
                
                if (string.isEmpty(ld.City__c) || string.isBlank(ld.City__c)){
                    ld.City__c = 'NA';
                }
                if (string.isEmpty(ld.LeadSource) || string.isBlank(ld.LeadSource)){
                    ld.LeadSource = 'NA';
                }
                /*if (string.isEmpty(ld.UTM_Medium__c) || string.isBlank(ld.UTM_Medium__c)){
                    ld.UTM_Medium__c = 'NA';
                }*/
                if (string.isEmpty(ld.Lead_Gen_Path__c) || string.isBlank(ld.Lead_Gen_Path__c)){
                    ld.Lead_Gen_Path__c = 'NA';
                }
                if (string.isEmpty(ld.Course__c) || string.isBlank(ld.Course__c)){
                    ld.Course__c = 'NA';
                }
                system.debug('ld.OwnerId--->'+ld.OwnerId);
                
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Insert', e, null);
        }
    }
    
    public void afterInsert(List<Lead> leadList){
        try{
            for (Lead ld : leadList){
                Utility.createApplicationInstance(ld.Id, ld.Course__c,null);
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Insert', e, null);
        }
    }
    
    public void beforeUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            system.debug('Before Update');
            
            for (Lead ld : newLeadMap.values()){
                if (ld.Enter_UTM_Link__c != null && ld.Lead_Generation_Method__c != null && (ld.Lead_Generation_Method__c == 'Chat Form' || ld.Lead_Generation_Method__c == 'Generic Form' )){
                    Utility.UTMLinkParams(ld);
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
                 if(ld.Profession__c != null && ld.Profession__c != oldLeadMap.get(ld.Id).Profession__c){
                    addValidationForProfilling(ld, oldLeadMap);
                 }
                 if(ld.status != oldLeadMap.get(ld.Id).status && ld.Email_Conversation_Done__c == false ){
                    ld.addError('Email conversation is required to proceed');
                 }
                 if(ld.status != oldLeadMap.get(ld.Id).status && ld.Profession__c == null ){
                    ld.addError('Profiling Details are required to proceed (Profession,Experience...)');
                 }
                 
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Update', e, null);
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
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Update', e, null);
        }
    }

    public void addValidationForProfilling(Lead ld, Map<id,Lead> oldLeadMap){
            if(ld.Profession__c == 'Student'){
                if(ld.Year_of_Graduation__c == null){
                    ld.Year_of_Graduation__c.addError('Year of Graduation can not be Empty');
                }
                if(ld.Specialization__c == null){
                    ld.Specialization__c.addError('Specialization can not be Empty');
                }
                if(ld.Branch__c == null){
                    ld.Branch__c.addError('Branch can not be Empty');
                }
                if(ld.Qualification__c == null){
                    ld.Qualification__c.addError('Qualification can not be Empty');
                }
            }else if(ld.Profession__c == 'Working Professional'){
                if(ld.Relevant_Experience__c == null){
                    ld.Relevant_Experience__c.addError('Relevant Experience can not be Empty');
                }
                if(ld.Current_Domain__c == null){
                    ld.Current_Domain__c.addError('Current Domain can not be Empty');
                }
                if(ld.Year_of_Experience__c == null){
                    ld.Year_of_Experience__c.addError('Year of Experience can not be Empty');
                }
                if(ld.Designation__c == null){
                    ld.Designation__c.addError('Designation can not be Empty');
                }
                if(ld.Organisation__c == null){
                    ld.Organisation__c.addError('Organisation can not be Empty');
                }
                if(ld.Year_of_Graduation__c == null){
                    ld.Year_of_Graduation__c.addError('Year of Graduation can not be Empty');
                }
                if(ld.Specialization__c == null){
                    ld.Specialization__c.addError('Specialization can not be Empty');
                }
                if(ld.Branch__c == null){
                    ld.Branch__c.addError('Branch can not be Empty');
                }
                if(ld.Qualification__c == null){
                    ld.Qualification__c.addError('Qualification can not be Empty');
                }
            }
    }
    
}