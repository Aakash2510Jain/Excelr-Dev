public without sharing class LeadTriggerHandler{
    static LeadTriggerHandler handlerInstance;
    
    public static LeadTriggerHandler getInstance(){
        if (handlerInstance == null)
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }
    
    public  void beforeInsert(List<Lead> leadList){
        try{
            List<String> emailList = new List<String>();
            List<String> alternateEmailList = new List<String>();
            List<String> phoneList = new List<String>();
            List<String> alternatePhoneList = new List<String>();
            List<Lead> duplicateExistingLeadList = new List<Lead>();
            List<Lead> duplicateConvertedLeadList = new List<Lead>();
            
            Map<string, Lead> existingLeadByEmail = new Map<string, Lead>();
            Map<string, Lead> existingLeadByAlternateEmail = new Map<string, Lead>();
            Map<string, Lead> existingLeadByPhone = new Map<string, Lead>();
            Map<string, Lead> existingLeadByAlternatePhone = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByEmail = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByAlternateEmail = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByPhone = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByAlternatePhone = new Map<string, Lead>();
            
            List<opportunity> opportunityListToInsert = new List<Opportunity>();
            List<Lead> leadListToInsert = new List<Lead>();
            List<Application__c> applicationListToInsert = new List<Application__C>();
            List<Customers__c> customersListToInsert = new List<Customers__c>();
            List<task> taskListToInsert = new List<task>();
            
            for (Lead ld : leadList){
                system.debug('ld.OwnerId--->'+ld.OwnerId);
                if (ld.LeadSource == 'Reference' || ld.Lead_Gen_Path__c == 'Reference' || ld.To_Be_Deleted__c == true){
                    //asign lead to creator
                }else if ( (ld.Lead_Generation_Method__c == 'Voice Form' || ld.Lead_Generation_Method__c == 'Chat Form' || (ld.Lead_Generation_Method__c == 'Generic Form' && ld.Is_User_Assigned__c == 'Not-Assigned' ) || (ld.Lead_Generation_Method__c == 'Walk-in Form' && ld.Is_User_Assigned__c == 'Not-Assigned' ) )){
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
                    emailList.add(ld.Email);
                }
                if(ld.Alternate_Email__c != null){
                    alternateEmailList.add(ld.Alternate_Email__c);
                }
                if(ld.Phone != null){
                    //phoneSet.add('%'+ld.Phone);
                    phoneList.add(ld.Phone); 
                }
                if(ld.Alternate_Phone__c != null){
                    //alternatePhoneSet.add('%'+ld.Alternate_Phone__c);
                    alternatePhoneList.add(ld.Alternate_Phone__c); 
                }
                if(ld.Course__c != null){
                    ld.Enquired_Course__c = ld.Course__c;
                }
            }
            string queryStringForNonConvertedLead = 'select Id, Email, status, course__c, CID__c,Customers__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead';
            String queryStringForConvertedLead = 'select Id, Email, status, course__c,CID__c,ConvertedAccountId, Customers__c,LID__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead ';
            

            System.debug('emailList ====> ' + emailList);
            System.debug('alternateEmailList ====> ' + alternateEmailList);
            System.debug('phoneList ====> ' + phoneList);
            System.debug('alternatePhoneList ====> ' + alternatePhoneList);

            // dynamic query part :              
            String whereClauses  = '( ';
            
            if (!emailList.isEmpty()) {
                whereClauses = whereClauses + '( Email IN : emailList )';
            }
            if (!alternateEmailList.isEmpty()) {
                if(!string.isBlank(whereClauses))
                    whereClauses = whereClauses + 'OR  (Alternate_Email__c IN : alternateEmailList)';
                else
                    whereClauses = whereClauses + ' (Alternate_Email__c IN : alternateEmailList)';
                //whereClauses.add(' AND Alternate_Email__c IN : alternateEmailSet');
            }
            if (!phoneList.isEmpty()) {
                if(!string.isBlank(whereClauses))
                    whereClauses = whereClauses + 'OR  (Phone Like : phoneList)';
                else                       
                    whereClauses = whereClauses + ' (Phone Like : phoneList)';
                
                //whereClauses.add('AND (Phone IN : phoneSet');
            }
            if (!alternatePhoneList.isEmpty()) {
                if(!string.isBlank(whereClauses))
                    whereClauses = whereClauses + 'OR  (Alternate_Phone__c Like : alternatePhoneList)';
                else
                    whereClauses = whereClauses + ' (Alternate_Phone__c Like : alternatePhoneList)';
                //whereClauses.add('Alternate_Phone__c IN : alternatePhoneSet');
            }
            
            system.debug('whereClauses'+whereClauses);   
            system.debug('whereClauses'+whereClauses.length());
            if (whereClauses.length() > 2 ) {
                queryStringForNonConvertedLead = queryStringForNonConvertedLead +' Where '+ whereClauses+ ' )  and isConverted = false order by CreatedDate Desc';
                queryStringForConvertedLead = queryStringForConvertedLead +' Where '+ whereClauses+ ' ) and isConverted = true order by CreatedDate Desc';
                duplicateExistingLeadList = Database.query(queryStringForNonConvertedLead);
                duplicateConvertedLeadList = Database.query(queryStringForConvertedLead);
            }
            /*else {
                queryStringForNonConvertedLead = queryStringForNonConvertedLead +' Where '+ ' isConverted = false order by CreatedDate Desc';
            //System.debug('queryStringForNonConvertedLead ====> ' + queryStringForNonConvertedLead);
                queryStringForConvertedLead = queryStringForConvertedLead +' Where '+ ' isConverted = true order by CreatedDate Desc';
                
            }*/
            //queryStringForNonConvertedLead = queryStringForNonConvertedLead +' Where '+ whereClauses+ ' )  and isConverted = false order by CreatedDate Desc';
            System.debug('queryStringForNonConvertedLead ====> ' + queryStringForNonConvertedLead);
            //queryStringForConvertedLead = queryStringForConvertedLead +' Where '+ whereClauses+ ' ) and isConverted = true order by CreatedDate Desc';
            System.debug('queryStringForConvertedLead =====> ' + queryStringForConvertedLead);

            
            
            if(!duplicateExistingLeadList.isEmpty()){
                for(Lead leadrec : duplicateExistingLeadList){
                    if(!string.isEmpty(leadrec.Email)){
                        if(!existingLeadByEmail.ContainsKey(leadrec.Email)){
                             existingLeadByEmail.put(leadrec.Email,leadrec);
                        }
                    }
                    if(!string.isEmpty(leadrec.Alternate_Email__c)){
                        if(!existingLeadByAlternateEmail.ContainsKey(leadrec.Alternate_Email__c)){
                            existingLeadByAlternateEmail.put(leadrec.Alternate_Email__c,leadrec);
                        }
                    }
                    if(!string.isEmpty(leadrec.Phone)){
                        if(!existingLeadByPhone.ContainsKey(leadrec.Phone)){
                            existingLeadByPhone.put(leadrec.Phone,leadrec);
                        }
                    }
                    if(!string.isEmpty(leadrec.Alternate_Phone__c)){
                        if(!existingLeadByAlternatePhone.ContainsKey(leadrec.Alternate_Phone__c)){
                            existingLeadByAlternatePhone.put(leadrec.Alternate_Phone__c,leadrec);
                        }
                    }
                }
            }
            if(!duplicateConvertedLeadList.isEmpty()){
                for(Lead leadrec : duplicateConvertedLeadList){
                    if(!string.isEmpty(leadrec.Email)){
                        if(!convertedLeadByEmail.ContainsKey(leadrec.Email)){
                            convertedLeadByEmail.put(leadrec.Email,leadrec);
                        }
                    }
                    if(!string.isEmpty(leadrec.Alternate_Email__c)){
                        if(!convertedLeadByAlternateEmail.ContainsKey(leadrec.Alternate_Email__c)){
                            convertedLeadByAlternateEmail.put(leadrec.Alternate_Email__c,leadrec);
                        }
                    }
                    if(!string.isEmpty(leadrec.Phone)){
                        if(!convertedLeadByPhone.ContainsKey(leadrec.Phone)){
                            convertedLeadByPhone.put(leadrec.Phone,leadrec);
                        }
                    }
                    if(!string.isEmpty(leadrec.Alternate_Phone__c)){
                        if(!convertedLeadByAlternatePhone.ContainsKey(leadrec.Alternate_Phone__c)){
                            convertedLeadByAlternatePhone.put(leadrec.Alternate_Phone__c,leadrec);
                        }
                    }
                }
            }

            System.debug('existingLeadByEmail ====> ' + existingLeadByEmail);
            System.debug('existingLeadByAlternateEmail ====> ' + existingLeadByAlternateEmail);
            System.debug('existingLeadByPhone ====> ' + existingLeadByPhone);            
            System.debug('existingLeadByAlternatePhone ====> ' + existingLeadByAlternatePhone); 


            System.debug('convertedLeadByEmail ====> ' + convertedLeadByEmail); 
            System.debug('convertedLeadByAlternateEmail ====> ' + convertedLeadByAlternateEmail); 
            System.debug('convertedLeadByPhone ====> ' + convertedLeadByPhone); 
            System.debug('convertedLeadByAlternatePhone ====> ' + convertedLeadByAlternatePhone); 

            for(Lead leadRec : leadList){
                system.debug('leadRec---->'+leadRec);
                if (!duplicateConvertedLeadList.isEmpty()){
                    string course = '';
                    string leadId = '';
                    string accountId = '';
                    string LID = '';
                    String CustomerId = '';
                    
                    if(convertedLeadByEmail.containsKey(leadRec.Email)){
                        course = leadRec.course__c;
                        leadId = convertedLeadByEmail.get(leadRec.Email).id;
                        accountId = string.valueOf(convertedLeadByEmail.get(leadRec.Email).ConvertedAccountId);
                        LID = convertedLeadByEmail.get(leadRec.Email).LID__c;
                        CustomerId = convertedLeadByEmail.get(leadRec.Email).Customers__c;
                        leadRec.To_Be_Deleted__c = true;  
                        leadRec.Parent_Lead_Id__c = convertedLeadByEmail.get(leadRec.Email).Id;
                        
                    }else if(convertedLeadByAlternateEmail.containsKey(leadRec.Alternate_Email__c)){
                        course = leadRec.course__c;
                        leadId = convertedLeadByAlternateEmail.get(leadRec.Alternate_Email__c).id;
                        accountId = string.valueOf(convertedLeadByAlternateEmail.get(leadRec.Alternate_Email__c).ConvertedAccountId);
                        LID = convertedLeadByAlternateEmail.get(leadRec.Alternate_Email__c).LID__c;
                        CustomerId = convertedLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Customers__c;
                        leadRec.To_Be_Deleted__c = true;  
                        leadRec.Parent_Lead_Id__c = convertedLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Id;
                        
                    }else if(convertedLeadByPhone.containsKey(leadRec.Phone)){
                        course = leadRec.course__c;
                        leadId = convertedLeadByPhone.get(leadRec.Phone).id;
                        accountId = string.valueOf(convertedLeadByPhone.get(leadRec.Phone).ConvertedAccountId);
                        LID = convertedLeadByPhone.get(leadRec.Phone).LID__c;
                        CustomerId = convertedLeadByPhone.get(leadRec.Phone).Customers__c;
                        leadRec.To_Be_Deleted__c = true;  
                        leadRec.Parent_Lead_Id__c = convertedLeadByPhone.get(leadRec.Phone).Id;
                        
                    }else if(convertedLeadByAlternatePhone.containsKey(leadRec.Alternate_Phone__c)){
                        course = leadRec.course__c;
                        leadId = convertedLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).id;
                        accountId = string.valueOf(convertedLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).ConvertedAccountId);
                        LID = convertedLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).LID__c;
                        CustomerId = convertedLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Customers__c;
                        leadRec.To_Be_Deleted__c = true;  
                        leadRec.Parent_Lead_Id__c = convertedLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                        
                    }
                    System.debug('course ====> ' + course);
                    System.debug('leadId ====> ' + leadId);
                    System.debug('accountId ====> ' + accountId);
                    System.debug('LID ====> ' + LID);
                    System.debug('CustomerId ====> ' + CustomerId);
                    applicationListToInsert.add(Utility.returnApplicationInstance(accountId, course));
                    Opportunity opportunityRec = new Opportunity(Name = course, AccountId = accountId, CloseDate = Date.today().addDays(2), StageName = 'Proposal',LID__c=LID,Customers__c=CustomerId);
                    opportunityListToInsert.add(opportunityRec);
                }
               
                else{
                    system.debug('Non-Converted Lead doesnot exist');
                    system.debug('duplicateExistingLeadList--->'+duplicateExistingLeadList);
                    if (!duplicateExistingLeadList.isEmpty()){
                        
                        system.debug('existingLeadByEmail.ContainsKey(leadRec.Email)-->'+existingLeadByEmail.ContainsKey(leadRec.Email));
                        system.debug('existingLeadByAlternateEmail.ContainsKey(leadRec.Alternate_Email__c)--->'+existingLeadByAlternateEmail.ContainsKey(leadRec.Alternate_Email__c));
                        system.debug('existingLeadByPhone.ContainsKey(leadRec.Phone)--->'+existingLeadByPhone.ContainsKey(leadRec.Phone));
                        system.debug('existingLeadByPhone.ContainsKey(leadRec.Alternate_Phone__c)--->'+existingLeadByPhone.ContainsKey(leadRec.Alternate_Phone__c));

                        if(existingLeadByEmail.ContainsKey(leadRec.Email)){
                            if((existingLeadByEmail.get(leadRec.Email).status == 'Dead' || existingLeadByEmail.get(leadRec.Email).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByEmail.get(leadRec.Email).Customers__c;
                            } else if((existingLeadByEmail.get(leadRec.Email).status != 'Dead' && existingLeadByEmail.get(leadRec.Email).Status != 'Junk') && existingLeadByEmail.get(leadRec.Email).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Email).Id;
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByEmail.get(leadRec.Email)));
                            } else if((existingLeadByEmail.get(leadRec.Email).status != 'Dead' && existingLeadByEmail.get(leadRec.Email).Status != 'Junk') && existingLeadByEmail.get(leadRec.Email).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Email).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(existingLeadByEmail.get(leadRec.Email)));
                            } 
                        }
                        else if(existingLeadByAlternateEmail.ContainsKey(leadRec.Alternate_Email__c)){
                            
                            if((existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status == 'Dead' || existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByEmail.get(leadRec.Alternate_Email__c).Customers__c;
                            }else if((existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status != 'Dead' && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Status != 'Junk') && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;  
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Alternate_Email__c).Id;
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c)));
                            }else if((existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status != 'Dead' && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Status != 'Junk') && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Alternate_Email__c).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c)));
                            }
                        }
                        else if(existingLeadByPhone.ContainsKey(leadRec.Phone)){
                            if ((existingLeadByPhone.get(leadRec.Phone).Status == 'Dead' || existingLeadByPhone.get(leadRec.Phone).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByEmail.get(leadRec.Phone).Customers__c;
                            } else if ((existingLeadByPhone.get(leadRec.Phone).Status != 'Dead' && existingLeadByPhone.get(leadRec.Phone).Status != 'Junk') && existingLeadByPhone.get(leadRec.Phone).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;   
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Phone).Id;                                
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByPhone.get(leadRec.Phone)));
                            }else if ((existingLeadByPhone.get(leadRec.Phone).Status != 'Dead' && existingLeadByPhone.get(leadRec.Phone).Status != 'Junk') && existingLeadByPhone.get(leadRec.Phone).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Phone).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(existingLeadByPhone.get(leadRec.Phone)));
                            }
                        }
                        else if(existingLeadByAlternatePhone.ContainsKey(leadRec.Alternate_Phone__c)){
                            if ((existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status == 'Dead' || existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByEmail.get(leadRec.Alternate_Phone__c).Customers__c;
                            }else if ((existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Dead' && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Junk')&& existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true; 
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Alternate_Phone__c).Id;    
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c)));
                            }else if ((existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Dead' && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Junk')&& existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Alternate_Phone__c).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c)));
                            }
                        }
                    }else{
                        Customers__c insertedCustomerRec = Utility.returnCustomerInstance(leadRec);
                        leadRec.Customers__c = insertedCustomerRec.Id;
                        //applicationListToInsert.add(Utility.returnApplicationInstance(accountId, course));
                    }
                }
            }
            if(!opportunityListToInsert.isEmpty()){
                insert opportunityListToInsert;
            }
            if(!applicationListToInsert.isEmpty()){
                insert applicationListToInsert;
            }
            if(!taskListToInsert.isEmpty()){
                insert taskListToInsert;
            }
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
            List<lead> duplicateLeadsByEmail = new List<Lead>();
            List<lead> duplicateLeadsByPhone = new List<Lead>();
            Set<String> emailSet = new Set<String>();
            Set<String> PhoneSet = new Set<String>();
            
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
                if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Open' && (ld.status == 'ATC' || ld.status == 'In Conversation' || ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false) ){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                }else if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Open' && (ld.status == 'In Conversation' || ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && ld.Profession__c == null ){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                }else  if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'ATC' && ( ld.status == 'In Conversation' || ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false) ){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                }else if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'ATC' && (ld.status == 'In Conversation' || ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && ld.Profession__c == null ){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                }else  if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'In Conversation' && (ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false) ){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                }else if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'In Conversation' && (ld.status == 'Promote') && ld.Profession__c == null ){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                }else  if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'On Hold' && (ld.status == 'Deferred' || ld.status == 'Promote' || ld.status == 'Dead' || ld.status == 'In Conversation') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false) ){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                }else  if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'On Hold' && (ld.status == 'Promote' ) && (ld.Profession__c == null) ){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                }else  if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Deferred' && (ld.status == 'Promote' || ld.status == 'Dead' || ld.status == 'In Conversation') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false) ){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                }else  if(ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Deferred' && (ld.status == 'Promote' ) && (ld.Profession__c == null) ){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                }else if (ld.status != oldLeadMap.get(ld.Id).status &&  ld.status == 'Junk' && (ld.Is_Email_Invalid__c == false)){
                    ld.Profession__c.addError('Lead Email should be Invalid to mark lead as Junk');
                } else if (ld.status != oldLeadMap.get(ld.Id).status &&  ld.status == 'Junk' && (ld.Is_Phone_Invalid__c == false)){
                    ld.Profession__c.addError('Lead Phone should be Invalid to mark lead as Junk');
                }   
                if(ld.status != oldLeadMap.get(ld.Id).status && (ld.Status == 'On Hold' || ld.Status ==  'Deferred') ){
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postThreeMonth = system.now().addMonths(3);
                    if(ld.Next_follow_up_date_time__c < postOneMonth || ld.Next_follow_up_date_time__c > postThreeMonth){
                        ld.Next_follow_up_date_time__c.addError('Follow up date should be > 1 month & < 3 month to park it in On Hold Stage');
                    }
                    
                }
                if(ld.Alternate_Email__c != oldLeadMap.get(ld.Id).Alternate_Email__c && ld.Alternate_Email__c != null){
                    emailSet.add(ld.Alternate_Email__c);
                    if(!emailSet.isEmpty()){
                        duplicateLeadsByEmail = [Select Id,Email,Alternate_Email__c From Lead Where Email In : emailSet or Alternate_Email__c In : emailSet limit 1];
                        if(!duplicateLeadsByEmail.isEmpty()){
                            ld.Alternate_Email__c.addError('Other Leads exists with Same Email');
                        }
                    }
                }
                if(ld.Alternate_Phone__c != oldLeadMap.get(ld.Id).Alternate_Phone__c && ld.Alternate_Phone__c != null){
                    
                    PhoneSet.add('%'+(ld.Alternate_Phone__c).replaceAll('\\+', ''));
                    system.debug('PhoneSet-->'+PhoneSet);
                    if(!PhoneSet.isEmpty()){
                        duplicateLeadsByPhone = [Select Id,Phone,Alternate_Phone__c From Lead Where Phone Like : PhoneSet or Alternate_Phone__c Like : PhoneSet limit 1];
                        if(!duplicateLeadsByPhone.isEmpty()){
                            ld.Alternate_Phone__c.addError('Other Leads exists with Same Phone No.');
                        }
                    }
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