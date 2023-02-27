public without sharing class LeadTriggerHandler{
    static LeadTriggerHandler handlerInstance;
    
    public static LeadTriggerHandler getInstance(){
        if (handlerInstance == null)
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }
    
    public  void beforeInsert(List<Lead> leadList){
        try{
            List<String> emailSet = new List<String>();
            List<String> alternateEmailSet = new List<String>();
            List<String> phoneSet = new List<String>();
            List<String> alternatePhoneSet = new List<String>();
            List<Lead> existingLeadByEmail = new List<Lead>();
            List<Lead> convertedLeadByEmail = new List<Lead>();
            Map<String, lead> leadByEmail = new Map<String, Lead>();
            Map<String, lead> leadByAlternateEmail = new Map<String, Lead>();
            Map<String, lead> leadByPhone = new Map<String, Lead>();
            Map<String, lead> leadByAlternatePhone = new Map<String, Lead>();
            
            List<opportunity> opportunityListToInsert = new List<Opportunity>();
            
            for (Lead ld : leadList){
                system.debug('ld.OwnerId--->'+ld.OwnerId);
                if(ld.LeadSource == 'Reference' && ld.Lead_Gen_Path__c == 'Reference'){
                    // lead owner will be the creator
                }else if ((ld.Lead_Generation_Method__c == 'Voice Form' || ld.Lead_Generation_Method__c == 'Chat Form' || (ld.Lead_Generation_Method__c == 'Generic Form' && ld.Is_User_Assigned__c == 'Not-Assigned' ) || (ld.Lead_Generation_Method__c == 'Walk-in Form' && ld.Is_User_Assigned__c == 'Not-Assigned' ) )){
                    system.debug('Owner is Queue');
                    ld.Is_Lead_Assigned_to_User__c = false;
                    ld.OwnerId = constants.queueId;
                }else{
                    ld.Is_Lead_Assigned_to_User__c = false;
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
                if (string.isEmpty(ld.Lead_Gen_Path__c) || string.isBlank(ld.Lead_Gen_Path__c)){
                    ld.Lead_Gen_Path__c = 'NA';
                }
                if (string.isEmpty(ld.Course__c) || string.isBlank(ld.Course__c)){
                    ld.Course__c = 'NA';
                }
                system.debug('ld.OwnerId--->'+ld.OwnerId);
                
                if(ld.Email != null){
                    emailSet.add(ld.Email);
                    leadByEmail.put(ld.Email, ld);
                }
                
                if(ld.Alternate_Email__c != null){
                    alternateEmailSet.add(ld.Alternate_Email__c);
                    leadByAlternateEmail.put(ld.Alternate_Email__c, ld);
                }
                if(ld.Phone != null){
                    //phoneSet.add('%'+ld.Phone);
                    phoneSet.add(ld.Phone); 
                    leadByPhone.put(ld.Phone, ld);
                }
                if(ld.Alternate_Phone__c != null){
                    //alternatePhoneSet.add('%'+ld.Alternate_Phone__c);
                    alternatePhoneSet.add(ld.Alternate_Phone__c); 
                    leadByAlternatePhone.put(ld.Alternate_Phone__c, ld);
                }
            }
            /*
            string queryStringForNonConvertedLead = 'select Id, Email, status, course__c, Customers__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead';
            String queryStringForConvertedLead = 'select Id, Email, status, course__c, Customers__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead ';
            
            // dynamic query part :              
            String whereClauses  = '( ';
            
            if (!emailSet.isEmpty()) {
                whereClauses = whereClauses + '( Email IN : emailSet )';
            }
            if (!alternateEmailSet.isEmpty()) {
                if(!string.isBlank(whereClauses))
                    whereClauses = whereClauses + 'OR  (Alternate_Email__c IN : alternateEmailSet)';
                else
                    whereClauses = whereClauses + ' (Alternate_Email__c IN : alternateEmailSet)';
                //whereClauses.add(' AND Alternate_Email__c IN : alternateEmailSet');
            }
            if (!alternatePhoneSet.isEmpty()) {
                if(!string.isBlank(whereClauses))
                    whereClauses = whereClauses + 'OR  (Alternate_Phone__c Like : alternatePhoneSet)';
                else
                    whereClauses = whereClauses + ' (Alternate_Phone__c Like : alternatePhoneSet)';
                //whereClauses.add('Alternate_Phone__c IN : alternatePhoneSet');
            }
            if (!phoneSet.isEmpty()) {
                if(!string.isBlank(whereClauses))
                    whereClauses = whereClauses + 'OR  (Phone Like : phoneSet)';
                else                       
                    whereClauses = whereClauses + ' (Phone Like : phoneSet)';
                
                //whereClauses.add('AND (Phone IN : phoneSet');
            }
            
            system.debug('whereClauses'+whereClauses);   
            
            queryStringForNonConvertedLead = queryStringForNonConvertedLead +' Where '+ whereClauses+ ' )  and isConverted = false order by CreatedDate Desc limit 1';
            queryStringForConvertedLead = queryStringForConvertedLead +' Where '+ whereClauses+ ' ) and isConverted = true order by CreatedDate Desc limit 1';
            
            existingLeadByEmail = Database.query(queryStringForNonConvertedLead);
            convertedLeadByEmail = Database.query(queryStringForConvertedLead);
            
            
            for(Lead leadRec : leadList){
                if (!convertedLeadByEmail.isEmpty()){
                    string course = '';
                    Utility.createApplicationInstance(string.valueOf(convertedLeadByEmail[0].ConvertedAccountId), leadRec.Course__c, null);
                    Opportunity opportunityRec = new Opportunity(Name = leadRec.Course__c, AccountId = convertedLeadByEmail[0].ConvertedAccountId, CloseDate = Date.today().addDays(2), StageName = 'Proposal');
                    opportunityListToInsert.add(opportunityRec);
                }
                else{
                    system.debug('Non-Converted Lead doesnot exist');
                    if (!existingLeadByEmail.isEmpty()){
                        
                        system.debug('leadRec.Status--->'+existingLeadByEmail[0].Status);
                        system.debug('leadRec.Course__c--->'+existingLeadByEmail[0].Course__c);
                        
                        if ((existingLeadByEmail[0].Status == 'Dead' || existingLeadByEmail[0].Status == 'Junk') && existingLeadByEmail[0].Course__c == leadRec.Course__c){
                            system.debug('dead or junk and course is same');
                            system.debug('Create new Lead');
                            Lead insertedLeadRec = API_CreateAccount.insertLead(leadRec, NULL, existingLeadByEmail[0].Customers__c);
                        } else if ((existingLeadByEmail[0].Status == 'Dead' || existingLeadByEmail[0].Status == 'Junk') && existingLeadByEmail[0].Course__c != leadRec.Course__c){
                            system.debug('dead or junk and course is different');    
                            system.debug('Create new Lead');
                            Lead insertedLeadRec = API_CreateAccount.insertLead(leadRec, NULL, existingLeadByEmail[0].Customers__c);
                        } else if ((existingLeadByEmail[0].Status != 'Dead' && existingLeadByEmail[0].Status != 'Junk') && existingLeadByEmail[0].Course__c == leadRec.Course__c){
                            leadRec.To_Be_Deleted__c = true;
                            system.debug('Status is not Dead/Junk and course is same');
                            system.debug('Create Task');
                            string taskId = Utility.createTaskViaLeadCreationAPI(existingLeadByEmail[0]);
                        } else if ((existingLeadByEmail[0].Status != 'Dead' && existingLeadByEmail[0].Status != 'Junk') && existingLeadByEmail[0].Course__c != leadRec.Course__c){
                            leadRec.To_Be_Deleted__c = true;
                            system.debug('Status is not Dead/Junk and course is different');
                            system.debug('Create Application');
                            string applicationId = Utility.createApplicationViaLeadCreationAPI(existingLeadByEmail[0]);
                        }
                    } else{
                        String customerId = Utility.createCustomer(leadRec);
                        Lead insertedLeadRec = API_CreateAccount.insertLead(leadRec, null, customerId);
                        string applicationId = Utility.createApplicationViaLeadCreationAPI(insertedLeadRec);
                        system.debug('leadid-->' + insertedLeadRec.Id);
                    }
                }
                
            }
            if(!opportunityListToInsert.isEmpty()){
                insert opportunityListToInsert;
            }*/
        }
        catch (Exception e){
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