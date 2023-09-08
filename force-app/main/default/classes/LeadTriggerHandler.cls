public without sharing class LeadTriggerHandler{
    static LeadTriggerHandler handlerInstance;
    
    public static LeadTriggerHandler getInstance(){
        if (handlerInstance == null)
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }
    
    public void beforeInsert(List<Lead> leadList){
        try{
            List<String> emailList = new List<String>();
            List<String> alternateEmailList = new List<String>();
            List<String> phoneList = new List<String>();
            List<String> alternatePhoneList = new List<String>();
            List<Lead> duplicateExistingLeadList = new List<Lead>();
            List<Opportunity> OpportunityExistingList = new List<opportunity>();
            List<Lead> duplicateConvertedLeadList = new List<Lead>();
            
            Map<string, Lead> existingLeadByEmail = new Map<string, Lead>();
            Map<string, Lead> existingLeadByAlternateEmail = new Map<string, Lead>();
            Map<string, Lead> existingLeadByPhone = new Map<string, Lead>();
            Map<string, Lead> existingLeadByAlternatePhone = new Map<string, Lead>();
            
            Map<string, Lead> convertedLeadByEmail = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByAlternateEmail = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByPhone = new Map<string, Lead>();
            Map<string, Lead> convertedLeadByAlternatePhone = new Map<string, Lead>();
            
            // =======================================Opportunity Maps =========================================
            Map<string, Opportunity> ExistingOppByEmail = new Map<string, Opportunity>();
            Map<string, Opportunity> ExistingOppByAlternateEmail = new Map<string, Opportunity>();
            Map<string, Opportunity> ExistingOppByPhone = new Map<string, Opportunity>();
            Map<string, Opportunity> ExistingOppByAlternatePhone = new Map<string, Opportunity>();
            
            
            List<opportunity> opportunityListToInsert = new List<Opportunity>();
            List<Lead> leadListToInsert = new List<Lead>();
            List<Application__c> applicationListToInsert = new List<Application__C>();
            List<Customers__c> customersListToInsert = new List<Customers__c>();
            List<task> taskListToInsert = new List<task>();
            
            List<Opportunity> OpportunityToUpdate = new List<Opportunity>();
            List<Lead> LeadListTObeUpdated = new List<Lead>();
            List<Lead> deadLeadsTOUpdateOwnership = new List<Lead>();
            
            map<String, Lead> NewLeadEmailwithLead = new map<String, Lead>();
            map<String, Lead> NewLeadAlternateEmailwithLead = new map<String, Lead>();
            map<String, Lead> NewLeadPhonewithLead = new map<String, Lead>();
            map<String, Lead> NewLeadAlternatePhonewithLead = new map<String, Lead>();
            
            for (Lead ld : leadList){
                system.debug('ld.OwnerId--->' + ld.OwnerId);
                ld.Next_follow_up_date_time__c = system.now().addHours(2);
                if (ld.Enter_UTM_Link__c != null && ld.Lead_Generation_Method__c != null && (ld.Lead_Generation_Method__c == 'Chat Form' || ld.Lead_Generation_Method__c == 'Generic Form')){
                    Utility.UTMLinkParams(ld);
                }
                
                //handle necessary fields
                system.debug('ld.RecordTypeId ==> '+ld.RecordTypeId);
                if (!string.isEmpty(ld.FirstName) && !string.isBlank(ld.LastName) && ld.RecordTypeId != '012N0000003t1cfIAA'){
                    ld.Company = ld.FirstName + ' ' + ld.LastName;
                }
                if (string.isEmpty(ld.FirstName) && !string.isBlank(ld.LastName) && ld.RecordTypeId != '012N0000003t1cfIAA'){
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
                if (string.isEmpty(ld.UTM_Medium__c) || string.isBlank(ld.UTM_Medium__c)){
                    ld.UTM_Medium__c = 'NA';
                }
                if (string.isEmpty(ld.Type_of_Course__c) || string.isBlank(ld.Type_of_Course__c)){
                    ld.Type_of_Course__c = 'Single';
                }
                if(ld.Email != null){
                    ld.Email_To_be_Mapped__c = ld.Email;
                }
                if(ld.Phone != null){
                    ld.Phone_to_be_Mapped__c = ld.Phone;
                }
                // quality of Leads
                system.debug('ld.LeadSource--->' + ld.LeadSource);
                system.debug('ld.UTM_Medium__c--->' + ld.UTM_Medium__c);
                if (ld.LeadSource != null && ld.UTM_Medium__c != null){
                    if ((ld.LeadSource == 'Reference' && ld.UTM_Medium__c == 'NA') || (ld.LeadSource == 'Walkin' && ld.UTM_Medium__c == 'NA') || (ld.LeadSource == 'LMS References' && ld.UTM_Medium__c == 'NA') || (ld.LeadSource == 'GoogleAds' && ld.UTM_Medium__c == 'Search') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'GoogleOrganic') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'GoogleLocal') || (ld.LeadSource == 'BingAds' && ld.UTM_Medium__c == 'Search') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'BingOrganic') || (ld.LeadSource == 'SEO' && ld.UTM_Medium__c == 'BingLocal') || (ld.LeadSource == 'NA' && ld.UTM_Medium__c == 'Direct')){
                        system.debug('Inside PLM');
                        ld.Quality_of_Lead__c = 'PLM';
                    } else if ((ld.LeadSource == 'Google' && ld.UTM_Medium__c == 'Discovery') || (ld.LeadSource == '3rd Party' && ld.UTM_Medium__c == 'Referral') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Lead form') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Conversion campaign') || (ld.LeadSource == 'Facebook' && ld.UTM_Medium__c == 'Boost Post') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Lead form') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Conversion campaign') || (ld.LeadSource == 'Instagram' && ld.UTM_Medium__c == 'Boost Post') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Lead Generation') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Website conversions') || (ld.LeadSource == 'LinkedIn' && ld.UTM_Medium__c == 'Sponsored Content')){
                        system.debug('Inside SLM');
                        ld.Quality_of_Lead__c = 'SLM';
                    } else{
                        system.debug('Inside TLM');
                        ld.Quality_of_Lead__c = 'TLM';
                    }
                }
                
                system.debug('ld.OwnerId--->' + ld.OwnerId);
                
                if (ld.Email != null){
                    emailList.add(ld.Email);
                    NewLeadEmailwithLead.put(ld.email, ld);
                }
                if (ld.Alternate_Email__c != null){
                    alternateEmailList.add(ld.Alternate_Email__c);
                    NewLeadAlternateEmailwithLead.put(ld.Alternate_Email__c, ld);
                }
                if (ld.Phone != null){
                    //phoneSet.add('%'+ld.Phone);
                    phoneList.add(ld.Phone);
                    NewLeadPhonewithLead.put(ld.Phone, ld);
                }
                if (ld.Alternate_Phone__c != null){
                    //alternatePhoneSet.add('%'+ld.Alternate_Phone__c);
                    alternatePhoneList.add(ld.Alternate_Phone__c);
                    NewLeadAlternatePhonewithLead.put(ld.Alternate_Phone__c, ld);
                }
                if (ld.Course__c != null){
                    ld.Enquired_Course__c = ld.Course__c;
                }
                ld.Enquired_Type_of_Course__c = !String.isBlank(ld.Type_of_Course__c) ? ld.Type_of_Course__c : 'Single';
            }
            string queryStringForNonConvertedLead = 'select DeadDateTime__c,CreatedDate, Id, Email, status, course__c, CID__c,Customers__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead';
            String queryStringForConvertedLead = 'select DeadDateTime__c,CreatedDate, Id, Email, status, course__c,CID__c,ConvertedAccountId, Customers__c,LID__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead ';
            String queryStringforOpportunityLead = 'SELECT  ClosedLostDateTime__c, AccountId,LID__c, Customers__c, CreatedDate,OwnerId,Alternate_Email__c,Alternate_Phone__c,Course__c,Email__c,Id,Lead_Gen_Path__c,Loan_Amount__c,Name,Phone__c,StageName FROM Opportunity';
            
            String whereClauses = '( ';
            String whereClausesForOpp = '( ';
            
            if (!emailList.isEmpty()){
                System.debug(' string.isBlank(whereClauses) ====> ' + string.isBlank(whereClauses));
                whereClauses = whereClauses + '( Email IN : emailList  OR Alternate_Email__c IN: emailList) ';
                
                whereClausesForOpp = whereClausesForOpp + '( Email__c IN : emailList ) ';
            }
            if (!alternateEmailList.isEmpty()){
                System.debug(' string.isBlank(whereClauses) ====> ' + string.isBlank(whereClauses));
                if (!string.isBlank(whereClauses) && whereClauses.length() > 2)
                    whereClauses = whereClauses + 'OR  (Alternate_Email__c IN : alternateEmailList OR Email IN: alternateEmailList ) ';
                else
                    whereClauses = whereClauses + ' (Alternate_Email__c IN : alternateEmailList OR Email IN: alternateEmailList) ';
                //whereClauses.add(' AND Alternate_Email__c IN : alternateEmailSet');
                
                if (!string.isBlank(whereClausesForOpp) && whereClausesForOpp.length() > 2){
                    whereClausesForOpp = whereClausesForOpp + 'OR ( Alternate_Email__c IN : alternateEmailList OR Email__c IN: alternateEmailList ) ';
                } else{
                    whereClausesForOpp = whereClausesForOpp + ' ( Alternate_Email__c IN : alternateEmailList OR Email__c IN: alternateEmailList) ';
                }
            }
            if (!phoneList.isEmpty()){
                System.debug(' string.isBlank(whereClauses) ====> ' + string.isBlank(whereClauses));
                if (!string.isBlank(whereClauses) && whereClauses.length() > 2)
                    whereClauses = whereClauses + 'OR  (Phone LIKE : phoneList  OR Phone LIKE : alternatePhoneList) ';
                else
                    whereClauses = whereClauses + ' (Phone LIKE : phoneList OR Phone LIKE : alternatePhoneList) ';
                //whereClauses.add('AND (Phone IN : phoneSet');
                
                if (!string.isBlank(whereClausesForOpp) && whereClausesForOpp.length() > 2){
                    whereClausesForOpp = whereClausesForOpp + ' OR ( Phone__c LIKE : phoneList OR Phone__c LIKE : alternatePhoneList) ';
                } else{
                    whereClausesForOpp = whereClausesForOpp + '( Phone__c  LIKE : phoneList OR Phone__c LIKE : alternatePhoneList) ';
                }
            }
            if (!alternatePhoneList.isEmpty()){
                System.debug(' string.isBlank(whereClauses) ====> ' + string.isBlank(whereClauses));
                if (!string.isBlank(whereClauses) && whereClauses.length() > 2)
                    whereClauses = whereClauses + 'OR  (Alternate_Phone__c LIKE : alternatePhoneList OR Alternate_Phone__c LIKE: phoneList ) ';
                else
                    whereClauses = whereClauses + ' (Alternate_Phone__c LIKE : alternatePhoneList OR Alternate_Phone__c LIKE: phoneList) ';
                //whereClauses.add('Alternate_Phone__c IN : alternatePhoneSet');
                
                if (!string.isBlank(whereClausesForOpp) && whereClausesForOpp.length() > 2){
                    whereClausesForOpp = whereClausesForOpp + ' OR ( Alternate_Phone__c LIKE : alternatePhoneList OR Alternate_Phone__c LIKE: phoneList) ';
                    
                } else{
                    whereClausesForOpp = whereClausesForOpp + ' ( Alternate_Phone__c LIKE : alternatePhoneList OR Alternate_Phone__c LIKE: phoneList) ';
                }
            }
            
            system.debug('whereClauses' + whereClauses);
            system.debug('whereClauses' + whereClauses.length());
            if (whereClauses.length() > 2){
                queryStringForNonConvertedLead = queryStringForNonConvertedLead + ' Where ' + whereClauses + ' )  and isConverted = false order by CreatedDate Desc';
                queryStringForConvertedLead = queryStringForConvertedLead + ' Where ' + whereClauses + ' ) and isConverted = true order by CreatedDate Desc';
                duplicateExistingLeadList = Database.query(queryStringForNonConvertedLead);
                duplicateConvertedLeadList = Database.query(queryStringForConvertedLead);
            }
            system.debug('whereClausesForOpp   ====> ' + whereClausesForOpp);
            system.debug('whereClausesForOpp  length ====> ' + whereClausesForOpp.length());
            if (whereClausesForOpp.length() > 2){
                queryStringforOpportunityLead = queryStringforOpportunityLead + ' Where ' + whereClausesForOpp + ' ) ORDER BY CreatedDate DESC LIMIT 1';
                System.debug('queryStringforOpportunityLead ===> ' + queryStringforOpportunityLead);
                OpportunityExistingList = Database.query(queryStringforOpportunityLead);
            }
            
            System.debug('queryStringForNonConvertedLead ====> ' + queryStringForNonConvertedLead);
            System.debug('queryStringForConvertedLead =====> ' + queryStringForConvertedLead);
            System.debug('OpportunityExistingList ====> ' + OpportunityExistingList);
            
            if (!duplicateExistingLeadList.isEmpty()){
                for (Lead leadrec : duplicateExistingLeadList){
                    if (!string.isEmpty(leadrec.Email)){
                        if (!existingLeadByEmail.ContainsKey(leadrec.Email)){
                            existingLeadByEmail.put(leadrec.Email, leadrec);
                        }
                    }
                    if (!string.isEmpty(leadrec.Alternate_Email__c)){
                        if (!existingLeadByAlternateEmail.ContainsKey(leadrec.Alternate_Email__c)){
                            existingLeadByAlternateEmail.put(leadrec.Alternate_Email__c, leadrec);
                        }
                    }
                    if (!string.isEmpty(leadrec.Phone)){
                        if (!existingLeadByPhone.ContainsKey(leadrec.Phone)){
                            existingLeadByPhone.put(leadrec.Phone, leadrec);
                        }
                    }
                    if (!string.isEmpty(leadrec.Alternate_Phone__c)){
                        if (!existingLeadByAlternatePhone.ContainsKey(leadrec.Alternate_Phone__c)){
                            existingLeadByAlternatePhone.put(leadrec.Alternate_Phone__c, leadrec);
                        }
                    }
                }
            }
            if (!duplicateConvertedLeadList.isEmpty()){
                for (Lead leadrec : duplicateConvertedLeadList){
                    if (!string.isEmpty(leadrec.Email)){
                        if (!convertedLeadByEmail.ContainsKey(leadrec.Email)){
                            convertedLeadByEmail.put(leadrec.Email, leadrec);
                        }
                    }
                    if (!string.isEmpty(leadrec.Alternate_Email__c)){
                        if (!convertedLeadByAlternateEmail.ContainsKey(leadrec.Alternate_Email__c)){
                            convertedLeadByAlternateEmail.put(leadrec.Alternate_Email__c, leadrec);
                        }
                    }
                    if (!string.isEmpty(leadrec.Phone)){
                        if (!convertedLeadByPhone.ContainsKey(leadrec.Phone)){
                            convertedLeadByPhone.put(leadrec.Phone, leadrec);
                        }
                    }
                    if (!string.isEmpty(leadrec.Alternate_Phone__c)){
                        if (!convertedLeadByAlternatePhone.ContainsKey(leadrec.Alternate_Phone__c)){
                            convertedLeadByAlternatePhone.put(leadrec.Alternate_Phone__c, leadrec);
                        }
                    }
                }
            }
            
            if (!OpportunityExistingList.isEmpty()){
                for (Opportunity opp : OpportunityExistingList){
                    if (!string.isEmpty(opp.Email__c)){
                        if (!ExistingOppByEmail.ContainsKey(opp.Email__c)){
                            ExistingOppByEmail.put(opp.Email__c, opp);
                        }
                    }
                    if (!string.isEmpty(opp.Alternate_Email__c)){
                        if (!ExistingOppByAlternateEmail.ContainsKey(opp.Alternate_Email__c)){
                            ExistingOppByAlternateEmail.put(opp.Alternate_Email__c, opp);
                        }
                    }
                    if (!string.isEmpty(opp.Phone__c)){
                        if (!ExistingOppByPhone.ContainsKey(opp.Phone__c)){
                            ExistingOppByPhone.put(opp.Phone__c, opp);
                        }
                    }
                    if (!string.isEmpty(opp.Alternate_Phone__c)){
                        if (!ExistingOppByAlternatePhone.ContainsKey(opp.Alternate_Phone__c)){
                            ExistingOppByAlternatePhone.put(opp.Alternate_Phone__c, opp);
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
            
            for (Lead leadRec : leadList){
                system.debug('leadRec---->' + leadRec);
                
                Utility.ApplicationtaskWrapper ApptaskWrap = new Utility.ApplicationtaskWrapper();
                DateTime Currentdate = System.now();
                Long currentdatetimeMilisec = System.now().getTime();
                //Datetime onemonthdatetime = System.now().addMonths(1);
                if (!OpportunityExistingList.isEmpty()){
                    string course = '';
                    string leadId = '';
                    string accountId = '';
                    Opportunity opp = new Opportunity();
                    string LID = '';
                    String CustomerId = '';
                    
                    if (ExistingOppByEmail.containsKey(leadRec.Email)){
                        if (ExistingOppByEmail.get(leadRec.Email).Stagename != Constants.OPP_STAGENAME_CLOSE_LOST){
                            //
                            leadRec.To_Be_Deleted__c = true;
                            opp = ExistingOppByEmail.get(leadRec.Email);
                            accountId = ExistingOppByEmail.get(leadRec.Email).AccountId;
                            LID = ExistingOppByEmail.get(leadRec.Email).LID__c;
                            CustomerId = ExistingOppByEmail.get(leadRec.Email).Customers__c;
                            course = leadRec.Course__c;
                            
                        } else if (ExistingOppByEmail.get(leadRec.Email).Stagename == Constants.OPP_STAGENAME_CLOSE_LOST){
                            //transferring Lost opp to Umesh
                            Opportunity updatedopp = new Opportunity();
                            updatedopp.Id = ExistingOppByEmail.get(leadRec.Email).Id;
                            updatedopp.OwnerId = Constants.UmeshUserId; //UmeshUserId
                            OpportunityToUpdate.add(updatedopp);
                            
                            if (((currentdatetimeMilisec - (ExistingOppByEmail.get(leadRec.Email).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) < 30){
                                // assign lead to same ISM
                                leadRec.ownerId = ExistingOppByEmail.get(leadRec.Email).ownerId;
                                leadRec.Is_Lead_Assigned_to_User__c = true;
                                leadRec.Customers__c = ExistingOppByEmail.get(leadRec.Email).Customers__c;
                                leadRec.Next_follow_up_date_time__c = system.now().addHours(2);
                                
                            } else if (((currentdatetimeMilisec - (ExistingOppByEmail.get(leadRec.Email).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) > 30){
                                // Assign Lead via RR
                                leadRec.ownerId = constants.queueId;
                            }
                        }
                    }
                    else if (ExistingOppByAlternateEmail.containsKey(leadRec.Alternate_Email__c)){
                        if (ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).Stagename != Constants.OPP_STAGENAME_CLOSE_LOST){
                            leadRec.To_Be_Deleted__c = true;
                            opp = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c);
                            accountId = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).AccountId;
                            LID = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).LID__c;
                            CustomerId = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).Customers__c;
                            course = leadRec.Course__c;
                            
                        } else if (ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).Stagename == Constants.OPP_STAGENAME_CLOSE_LOST){
                            Opportunity updatedopp = new Opportunity();
                            updatedopp.Id = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).Id;
                            updatedopp.OwnerId = Constants.UmeshUserId; //UmeshUserId
                            OpportunityToUpdate.add(updatedopp);
                            if (((currentdatetimeMilisec - (ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) < 30){
                                leadRec.ownerId = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).ownerId;
                                leadRec.Is_Lead_Assigned_to_User__c = true;
                                leadRec.Customers__c = ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).Customers__c;
                                leadRec.Next_follow_up_date_time__c = system.now().addHours(2);
                                
                            } else if (((currentdatetimeMilisec - (ExistingOppByAlternateEmail.get(leadRec.Alternate_Email__c).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) > 30){
                                leadRec.ownerId = constants.queueId;
                                
                            }
                        }
                    }
                    else if (ExistingOppByPhone.containsKey(leadRec.Phone)){
                        if (ExistingOppByPhone.get(leadRec.Phone).Stagename != Constants.OPP_STAGENAME_CLOSE_LOST){
                            leadRec.To_Be_Deleted__c = true;
                            opp = ExistingOppByPhone.get(leadRec.Phone);
                            accountId = ExistingOppByPhone.get(leadRec.Phone).AccountId;
                            LID = ExistingOppByPhone.get(leadRec.Phone).LID__c;
                            CustomerId = ExistingOppByPhone.get(leadRec.Phone).Customers__c;
                            course = leadRec.Course__c;
                            
                        } else if (ExistingOppByPhone.get(leadRec.Phone).Stagename == Constants.OPP_STAGENAME_CLOSE_LOST){
                            Opportunity updatedopp = new Opportunity();
                            updatedopp.Id = ExistingOppByPhone.get(leadRec.Phone).Id;
                            updatedopp.OwnerId = Constants.UmeshUserId; //UmeshUserId
                            OpportunityToUpdate.add(updatedopp);
                            
                            if (((currentdatetimeMilisec - (ExistingOppByPhone.get(leadRec.Phone).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) < 30){
                                leadRec.ownerId = ExistingOppByPhone.get(leadRec.Phone).ownerId;
                                leadRec.Is_Lead_Assigned_to_User__c = true;
                                leadRec.Customers__c = ExistingOppByPhone.get(leadRec.Phone).Customers__c;
                                leadRec.Next_follow_up_date_time__c = system.now().addHours(2);
                                
                            } else if (((currentdatetimeMilisec - (ExistingOppByPhone.get(leadRec.Phone).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) > 30){
                                leadRec.ownerId = constants.queueId;
                            }
                            
                        }
                    }
                    else if (ExistingOppByAlternatePhone.containsKey(leadRec.Alternate_Phone__c)){
                        if (ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).Stagename != Constants.OPP_STAGENAME_CLOSE_LOST){
                            leadRec.To_Be_Deleted__c = true;
                            opp = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c);
                            accountId = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).AccountId;
                            LID = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).LID__c;
                            CustomerId = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).Customers__c;
                            course = leadRec.Course__c;
                            
                        } else if (ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).Stagename == Constants.OPP_STAGENAME_CLOSE_LOST){
                            
                            Opportunity updatedopp = new Opportunity();
                            updatedopp.Id = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                            updatedopp.OwnerId = Constants.UmeshUserId; //UmeshUserId
                            OpportunityToUpdate.add(updatedopp);
                            if (((currentdatetimeMilisec - (ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) < 30){
                                leadRec.ownerId = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).ownerId;
                                leadRec.Is_Lead_Assigned_to_User__c = true;
                                leadRec.Customers__c = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).Customers__c;
                                //leadRec.Is_User_Assigned__c == 'Assigned';
                                leadRec.Next_follow_up_date_time__c = system.now().addHours(2);
                                
                            } else if (((currentdatetimeMilisec - (ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).ClosedLostDateTime__c).getTime()) / (60000 * 60 * 24)) > 30){
                                leadRec.ownerId = constants.queueId;
                                // Opportunity updatedopp = new Opportunity();
                                // updatedopp.Id = ExistingOppByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                                // updatedopp.OwnerId = Constants.syedUserId;
                                // OpportunityToUpdate.add(updatedopp);
                            }
                        }
                    }
                    
                    if (AccountId != null){
                        //Opportunity opportunityRec = new Opportunity(Name = course, AccountId = accountId, CloseDate = Date.today().addDays(2), StageName = 'Proposal', LID__c = LID, Customers__c = CustomerId);
                    }
                    if (opp.Id != null && Course != null && Course != ''){
                        ApptaskWrap = Utility.returnApplicationorTask(opp, Course);
                        if (ApptaskWrap.app != null){
                            applicationListToInsert.add(ApptaskWrap.app);
                        }
                        if (ApptaskWrap.TaskRec != null){
                            taskListToInsert.add(ApptaskWrap.TaskRec);
                        }
                        
                    }
                    
                    
                } 
                else{
                    system.debug('Non-Converted Lead doesnot exist');
                    system.debug('duplicateExistingLeadList--->' + duplicateExistingLeadList);
                    
                    if (!duplicateExistingLeadList.isEmpty()){
                        
                        //Long currentdatetimeMilisec = System.now().getTime();
                        system.debug('existingLeadByEmail.ContainsKey(leadRec.Email)-->' + existingLeadByEmail.ContainsKey(leadRec.Email));
                        system.debug('existingLeadByAlternateEmail.ContainsKey(leadRec.Alternate_Email__c)--->' + existingLeadByAlternateEmail.ContainsKey(leadRec.Alternate_Email__c));
                        system.debug('existingLeadByPhone.ContainsKey(leadRec.Phone)--->' + existingLeadByPhone.ContainsKey(leadRec.Phone));
                        system.debug('existingLeadByPhone.ContainsKey(leadRec.Alternate_Phone__c)--->' + existingLeadByPhone.ContainsKey(leadRec.Alternate_Phone__c));
                        
                        
                        if (existingLeadByEmail.ContainsKey(leadRec.Email)){
                            if ((existingLeadByEmail.get(leadRec.Email).status == 'Dead' || existingLeadByEmail.get(leadRec.Email).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByEmail.get(leadRec.Email).Customers__c;
                                Lead leadtoBeupdated = new Lead();
                                leadtoBeupdated.id = existingLeadByEmail.get(leadRec.Email).Id;
                                leadtoBeupdated.OwnerId = Constants.UmeshUserId;
                                LeadListTObeUpdated.add(leadtoBeupdated);
                                system.debug('existingLeadByEmail.get(leadRec.Email)--->'+existingLeadByEmail.get(leadRec.Email));
                                if(existingLeadByEmail.get(leadRec.Email).DeadDateTime__c != null){
                                    Lead leadRecToUpdate = new Lead();
                                    system.debug('existingLeadByEmail.get(leadRec.Email).Id--->'+existingLeadByEmail.get(leadRec.Email).Id);
                                    leadRecToUpdate.Id = existingLeadByEmail.get(leadRec.Email).Id;
                                    leadRecToUpdate.OwnerId = Constants.UmeshUserId;
                                    deadLeadsTOUpdateOwnership.add(leadRecToUpdate);
                                    if (((currentdatetimeMilisec - (existingLeadByEmail.get(leadRec.Email).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) < 30 &&  existingLeadByEmail.get(leadRec.Email).status == 'Dead'){
                                        leadRec.ownerId = existingLeadByEmail.get(leadRec.Email).ownerId;   
                                        leadRec.Is_Lead_Assigned_to_User__c = true; 
                                    } else if (((currentdatetimeMilisec - (existingLeadByEmail.get(leadRec.Email).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) > 30 && existingLeadByEmail.get(leadRec.Email).status == 'Dead'){
                                        leadRec.ownerId = constants.queueId;                                
                                    }
                                }
                            } else if ((existingLeadByEmail.get(leadRec.Email).status != 'Dead' && existingLeadByEmail.get(leadRec.Email).Status != 'Junk') && existingLeadByEmail.get(leadRec.Email).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Email).Id;
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByEmail.get(leadRec.Email)));
                            } else if ((existingLeadByEmail.get(leadRec.Email).status != 'Dead' && existingLeadByEmail.get(leadRec.Email).Status != 'Junk') && existingLeadByEmail.get(leadRec.Email).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByEmail.get(leadRec.Email).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(NewLeadEmailwithLead.get(leadRec.Email), existingLeadByEmail.get(leadRec.Email)));
                            }
                        } else if (existingLeadByAlternateEmail.ContainsKey(leadRec.Alternate_Email__c)){
                            
                            if ((existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status == 'Dead' || existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Customers__c;
                                
                                Lead leadtoBeupdated = new Lead();
                                leadtoBeupdated.id = existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Id;
                                leadtoBeupdated.OwnerId = Constants.UmeshUserId;
                                LeadListTObeUpdated.add(leadtoBeupdated);
                                //system.debug('existingLeadByEmail.get(leadRec.Alternate_Email__c).DeadDateTime__c--->'+existingLeadByEmail.get(leadRec.Alternate_Email__c).DeadDateTime__c);
                                if(existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).DeadDateTime__c != null){
                                    //system.debug('existingLeadByEmail.get(leadRec.Alternate_Email__c).Id--->'+existingLeadByEmail.get(leadRec.Alternate_Email__c).Id);
                                    
                                    Lead leadRecToUpdate = new Lead();
                                    leadRecToUpdate.Id = existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Id;
                                    leadRecToUpdate.OwnerId = Constants.UmeshUserId;
                                    deadLeadsTOUpdateOwnership.add(leadRecToUpdate);
                                    if (((currentdatetimeMilisec - (existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) < 30 &&  existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status == 'Dead'){
                                        leadRec.ownerId = existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).ownerId;
                                        leadRec.Is_Lead_Assigned_to_User__c = true;  
                                    } else if (((currentdatetimeMilisec - (existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) > 30 && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status == 'Dead'){
                                        leadRec.ownerId = constants.queueId;                                    
                                    }
                                }
                            } else if ((existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status != 'Dead' && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Status != 'Junk') && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Id;
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c)));
                            } else if ((existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).status != 'Dead' && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Status != 'Junk') && existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(NewLeadAlternateEmailwithLead.get(leadRec.Alternate_Email__c), existingLeadByAlternateEmail.get(leadRec.Alternate_Email__c)));
                            }
                        } else if (existingLeadByPhone.ContainsKey(leadRec.Phone)){
                            if ((existingLeadByPhone.get(leadRec.Phone).Status == 'Dead' || existingLeadByPhone.get(leadRec.Phone).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByPhone.get(leadRec.Phone).Customers__c;
                                
                                Lead leadtoBeupdated = new Lead();
                                leadtoBeupdated.id = existingLeadByPhone.get(leadRec.Phone).Id;
                                leadtoBeupdated.OwnerId = Constants.UmeshUserId;
                                LeadListTObeUpdated.add(leadtoBeupdated);
                                
                                //system.debug('existingLeadByEmail.get(leadRec.Phone).DeadDateTime__c--->'+existingLeadByEmail.get(leadRec.Phone).DeadDateTime__c);
                                if(existingLeadByPhone.get(leadRec.Phone).DeadDateTime__c != null){
                                    //system.debug('existingLeadByEmail.get(leadRec.Phone).Id--->'+existingLeadByEmail.get(leadRec.Phone).Id);
                                    Lead leadRecToUpdate = new Lead();
                                    leadRecToUpdate.Id = existingLeadByPhone.get(leadRec.Phone).Id;
                                    leadRecToUpdate.OwnerId = Constants.UmeshUserId;
                                    deadLeadsTOUpdateOwnership.add(leadRecToUpdate);
                                    
                                    if (((currentdatetimeMilisec - (existingLeadByPhone.get(leadRec.Phone).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) < 30 &&  existingLeadByPhone.get(leadRec.Phone).status == 'Dead'){
                                        leadRec.ownerId = existingLeadByPhone.get(leadRec.Phone).ownerId;   
                                        leadRec.Is_Lead_Assigned_to_User__c = true; 
                                    } else if (((currentdatetimeMilisec - (existingLeadByPhone.get(leadRec.Phone).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) > 30 && existingLeadByPhone.get(leadRec.Phone).status == 'Dead'){
                                        leadRec.ownerId = constants.queueId;
                                        
                                    }
                                }
                            } else if ((existingLeadByPhone.get(leadRec.Phone).Status != 'Dead' && existingLeadByPhone.get(leadRec.Phone).Status != 'Junk') && existingLeadByPhone.get(leadRec.Phone).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByPhone.get(leadRec.Phone).Id;
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByPhone.get(leadRec.Phone)));
                            } else if ((existingLeadByPhone.get(leadRec.Phone).Status != 'Dead' && existingLeadByPhone.get(leadRec.Phone).Status != 'Junk') && existingLeadByPhone.get(leadRec.Phone).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByPhone.get(leadRec.Phone).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(NewLeadPhonewithLead.get(leadRec.Phone), existingLeadByPhone.get(leadRec.Phone)));
                            }
                        } else if (existingLeadByAlternatePhone.ContainsKey(leadRec.Alternate_Phone__c)){
                            if ((existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status == 'Dead' || existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status == 'Junk')){
                                system.debug('dead or junk and course is same');
                                system.debug('Create new Lead');
                                leadRec.Customers__c = existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Customers__c;
                                
                                Lead leadtoBeupdated = new Lead();
                                leadtoBeupdated.id = existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                                leadtoBeupdated.OwnerId = Constants.UmeshUserId;
                                LeadListTObeUpdated.add(leadtoBeupdated);
                                //system.debug('existingLeadByEmail.get(leadRec.Alternate_Phone__c).DeadDateTime__c--->'+existingLeadByEmail.get(leadRec.Alternate_Phone__c).DeadDateTime__c);
                                if(existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).DeadDateTime__c != null){
                                    //system.debug('existingLeadByEmail.get(leadRec.Alternate_Phone__c).Id--->'+existingLeadByEmail.get(leadRec.Alternate_Phone__c).Id);
                                    Lead leadRecToUpdate = new Lead();
                                    leadRecToUpdate.Id = existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                                    leadRecToUpdate.OwnerId = Constants.UmeshUserId;
                                    deadLeadsTOUpdateOwnership.add(leadRecToUpdate);
                                    
                                    if (((currentdatetimeMilisec - (existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) < 30 &&  existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).status == 'Dead'){
                                        leadRec.ownerId = existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).ownerId;    
                                        leadRec.Is_Lead_Assigned_to_User__c = true;
                                    } else if (((currentdatetimeMilisec - (existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).DeadDateTime__c).getTime()) / (60000 * 60 * 24)) > 30 && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).status == 'Dead'){
                                        leadRec.ownerId = constants.queueId;                              
                                    }
                                }
                            } else if ((existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Dead' && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Junk') && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Course__c == leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is same');
                                system.debug('Create Task');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                                taskListToInsert.add(Utility.returnTaskInstance(existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c)));
                            } else if ((existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Dead' && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Status != 'Junk') && existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Course__c != leadRec.Course__c){
                                system.debug('Status is not Dead/Junk and course is different');
                                system.debug('Create Application');
                                leadRec.To_Be_Deleted__c = true;
                                leadRec.Parent_Lead_Id__c = existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c).Id;
                                applicationListToInsert.add(Utility.returnApplicationInstance(NewLeadAlternatePhonewithLead.get(leadRec.Alternate_Phone__c), existingLeadByAlternatePhone.get(leadRec.Alternate_Phone__c)));
                            }
                        } 
                    } else{
                        Customers__c insertedCustomerRec = Utility.returnCustomerInstance(leadRec);
                        leadRec.Customers__c = insertedCustomerRec.Id;
                        //applicationListToInsert.add(Utility.returnApplicationInstance(accountId, course));
                    }
                }
                
                System.debug('leadRec.Email ====> ' + leadRec.Email);
                System.debug('leadRec.Alternate_Email__c ====> ' + leadRec.Alternate_Email__c);
                System.debug('leadRec.Phone ====> ' + leadRec.Phone);
                System.debug('leadRec.Alternate_Phone__c ====> ' + leadRec.Alternate_Phone__c);
                
                
                if (leadRec.LeadSource == 'Reference' || leadRec.Lead_Gen_Path__c == 'Reference'){
                    leadRec.Is_Lead_Assigned_to_User__c = true;
                    leadRec.Next_follow_up_date_time__c = system.now().addHours(2);
                    //asign lead to creator
                } else if (((leadRec.Lead_Generation_Method__c == 'Voice Form' && leadRec.Is_Lead_Assigned_to_User__c == false) || (leadRec.Lead_Generation_Method__c == 'Chat Form' && leadRec.Is_Lead_Assigned_to_User__c == false) || (leadRec.Lead_Generation_Method__c == 'Generic Form' && leadRec.Is_User_Assigned__c == 'Not-Assigned') || (leadRec.Lead_Generation_Method__c == 'Walk-in Form' && leadRec.Is_User_Assigned__c == 'Not-Assigned'))){
                    system.debug('Owner is Queue');
                    leadRec.Is_Lead_Assigned_to_User__c = false;
                    leadRec.OwnerId = constants.queueId;
                } else if ((leadRec.Lead_Generation_Method__c == 'Generic Form' && leadRec.Is_User_Assigned__c == 'Assigned') || (leadRec.Lead_Generation_Method__c == 'Walk-in Form' && leadRec.Is_User_Assigned__c == 'Assigned')){
                    leadRec.Is_Lead_Assigned_to_User__c = true;
                    leadRec.Next_follow_up_date_time__c = system.now().addHours(2);
                } else if (leadRec.To_Be_Deleted__c == true){
                    
                } else if(leadRec.Is_Lead_Assigned_to_User__c == false){
                    leadRec.Is_Lead_Assigned_to_User__c = false;
                    leadRec.OwnerId = constants.queueId;
                }
            }
            if (!opportunityListToInsert.isEmpty()){
                insert opportunityListToInsert;
            }
            system.debug('deadLeadsTOUpdateOwnership--->'+deadLeadsTOUpdateOwnership);
            if(!deadLeadsTOUpdateOwnership.isEMpty()){
                Map<Id,Lead> leadIdByLeadRecMap = new Map<Id, Lead>();
                
                for(Lead leadRec : deadLeadsTOUpdateOwnership){
                    leadIdByLeadRecMap.put(leadRec.id, leadRec);
                }
                system.debug('leadIdByLeadRecMap--->'+leadIdByLeadRecMap);
                if(!leadIdByLeadRecMap.isEmpty()){
                    update leadIdByLeadRecMap.values();
                }
            }
            System.debug('applicationListToInsert =====> ' + applicationListToInsert);
            if (!applicationListToInsert.isEmpty()){
                insert applicationListToInsert;
            }
            if (!taskListToInsert.isEmpty()){
                insert taskListToInsert;
            }
            if (!OpportunityToUpdate.isEmpty()) {
                update OpportunityToUpdate;
                
            }
            if (!LeadListTObeUpdated.isEmpty()) {
                update LeadListTObeUpdated;
                
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Insert', e, null);
        }
    }
    
    public void afterInsert(List<Lead> leadList){
        List<Application__c> applicationtobeinserted = new List<Application__c>();
        try{
            set<String> leadIds = new set<String>();
            
            for (Lead ld : leadList){
                //Application__c LeadApp = Utility.createApplicationInstance(ld.Id, ld.Course__c, null);
                Application__c LeadApp = Utility.createApplicationInstanceForLead(ld, null);
                applicationtobeinserted.add(LeadApp);
                if (ld.To_Be_Deleted__c){
                    leadIds.add(ld.Id);
                }
            }
            if (!applicationtobeinserted.isEmpty()){
                //insert applicationtobeinserted;
            }
            if (!leadIds.isEmpty()){
                DeleteDuplicateLeads.deleteLeads();
            }
        } 
        catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Insert', e, null);
        }
    }
    
    public void beforeUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            system.debug('Before Update');
            List<lead> duplicateLeadsByEmail = new List<Lead>();
            List<lead> duplicateLeadsByPhone = new List<Lead>();
            List<opportunity> duplicateOpportunitysByEmail = new List<opportunity>();
            List<opportunity> duplicateOpportunityByPhone = new List<opportunity>();
            Set<String> emailSet = new Set<String>();
            Set<String> PhoneSet = new Set<String>();
            
            string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Excelr Default Queue' limit 1].Id;
            
            for (Lead ld : newLeadMap.values()){
                if(ld.OwnerId != oldLeadMap.get(ld.Id).OwnerId && oldLeadMap.get(ld.Id).OwnerId == queueId && ld.OwnerId != queueId ){
                    DateTime startTime = ld.CreatedDate;
                    DateTime endTime = system.now();
                    ld.queue_spent_time__c = endTime.getTime() - startTime.getTime();
                }
                if (ld.Enter_UTM_Link__c != null && ld.Lead_Generation_Method__c != null && (ld.Lead_Generation_Method__c == 'Chat Form' || ld.Lead_Generation_Method__c == 'Generic Form')){
                    Utility.UTMLinkParams(ld);
                }
                if(ld.Email != null && ld.Email != oldLeadMap.get(ld.Id).Email){
                    ld.Email_To_be_Mapped__c = ld.Email;
                }
                if(ld.Phone != null && ld.Phone != oldLeadMap.get(ld.Id).Phone){
                    ld.Phone_to_be_Mapped__c = ld.Phone;
                }
                
                if ((ld.LeadSource != oldLeadMap.get(ld.Id).LeadSource || ld.UTM_Medium__c != oldLeadMap.get(ld.Id).UTM_Medium__c) && ld.LeadSource != null && ld.UTM_Medium__c != null){
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
                if (ld.Profession__c != null && ld.Profession__c != oldLeadMap.get(ld.Id).Profession__c){
                    addValidationForProfilling(ld, oldLeadMap);
                }
                addValidationForProfilling(ld, oldLeadMap);
                if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Open' && (ld.status == 'ATC' || ld.status == 'Request a Call Back' || ld.status == 'In Conversation' || ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false)){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Open' && (ld.status == 'In Conversation' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && ld.Profession__c == null){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'ATC' && (ld.status == 'In Conversation' || ld.status == 'Request a Call Back' || ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false)){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'ATC' && (ld.status == 'In Conversation' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && ld.Profession__c == null){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'In Conversation' && (ld.status == 'Dead' || ld.status == 'On Hold' || ld.status == 'Deferred' || ld.status == 'Promote') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false)){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'In Conversation' && (ld.status == 'Promote') && ld.Profession__c == null){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'On Hold' && (ld.status == 'Deferred' || ld.status == 'Promote' || ld.status == 'Dead' || ld.status == 'In Conversation') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false)){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'On Hold' && (ld.status == 'Promote') && (ld.Profession__c == null)){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Deferred' && (ld.status == 'Promote' || ld.status == 'Dead' || ld.status == 'In Conversation') && (ld.Email_Conversation_Done__c == false && ld.Telephonic_Conversation__c == false)){
                    ld.status.addError('Email or Telephonic conversation is required to proceed');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && oldLeadMap.get(ld.Id).status == 'Deferred' && (ld.status == 'Promote') && (ld.Profession__c == null)){
                    ld.Profession__c.addError('Profiling Details are required to proceed (Profession,Experience...)');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && ld.status == 'Junk' && (ld.Is_Email_Invalid__c == false)){
                    ld.Profession__c.addError('Lead Email should be Invalid to mark lead as Junk');
                } else if (ld.status != oldLeadMap.get(ld.Id).status && ld.status == 'Junk' && (ld.Is_Phone_Invalid__c == false)){
                    ld.Profession__c.addError('Lead Phone should be Invalid to mark lead as Junk');
                }
                if (ld.Next_follow_up_date_time__c != oldLeadMap.get(ld.Id).Next_follow_up_date_time__c && ld.Next_follow_up_date_time__c == null){
                    ld.Next_follow_up_date_time__c.addError('Next Followup Date cannot be Empty!!');
                }
                //Validation for data null points
                if (ld.Email != oldLeadMap.get(ld.Id).Email && ld.Email == null){
                    //ld.Email.addError('Email cannot be Empty!!');
                }
                if (ld.Alternate_Email__c != oldLeadMap.get(ld.Id).Alternate_Email__c && ld.Alternate_Email__c == null){
                    //ld.Alternate_Email__c.addError('Alternate Email cannot be Empty!!');
                }
                if (ld.Alternate_Phone__c != oldLeadMap.get(ld.Id).Alternate_Phone__c && ld.Alternate_Phone__c == null){
                    //ld.Alternate_Phone__c.addError('Alternate Phone cannot be Empty!!');
                }
                if (ld.Profession__c != oldLeadMap.get(ld.Id).Profession__c && ld.Profession__c == null){
                    ld.Profession__c.addError('Profession cannot be Empty!!');
                }
                if (ld.Qualification__c != oldLeadMap.get(ld.Id).Qualification__c && ld.Qualification__c == null){
                   // ld.Qualification__c.addError('Qualification cannot be Empty!!');
                }
                if (ld.Branch__c != oldLeadMap.get(ld.Id).Branch__c && ld.Branch__c == null){
                   // ld.Branch__c.addError('Branch cannot be Empty!!');
                }
                if (ld.Specialization__c != oldLeadMap.get(ld.Id).Specialization__c && ld.Specialization__c == null){
                    //ld.Specialization__c.addError('Specialization cannot be Empty!!');
                }
                if (ld.Year_of_Graduation__c != oldLeadMap.get(ld.Id).Year_of_Graduation__c && ld.Year_of_Graduation__c == null){
                   // ld.Year_of_Graduation__c.addError('Year of Graduation cannot be Empty!!');
                }
                if (ld.Why_This_Course__c != oldLeadMap.get(ld.Id).Why_This_Course__c && ld.Why_This_Course__c == null){
                    ld.Why_This_Course__c.addError('Why This Course cannot be Empty!!');
                }
                if (ld.Organisation__c != oldLeadMap.get(ld.Id).Organisation__c && ld.Organisation__c == null){
                    ld.Organisation__c.addError('Organisation cannot be Empty!!');
                }
                if (ld.Designation__c != oldLeadMap.get(ld.Id).Designation__c && ld.Designation__c == null){
                    ld.Designation__c.addError('Designation cannot be Empty!!');
                }
                if (ld.Year_of_Experience__c != oldLeadMap.get(ld.Id).Year_of_Experience__c && ld.Year_of_Experience__c == null){
                    ld.Year_of_Experience__c.addError('Year of Experience cannot be Empty!!');
                }
                if (ld.Current_Domain__c != oldLeadMap.get(ld.Id).Current_Domain__c && ld.Current_Domain__c == null){
                    ld.Current_Domain__c.addError('Current Domain cannot be Empty!!');
                }
                if (ld.Relevant_Experience__c != oldLeadMap.get(ld.Id).Relevant_Experience__c && ld.Relevant_Experience__c == null){
                    ld.Relevant_Experience__c.addError('Relevant Experience cannot be Empty!!');
                }
                
                if (ld.status != oldLeadMap.get(ld.Id).status && (ld.Status == 'On Hold')){
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postThreeMonth = system.now().addMonths(3);
                    if (ld.Next_follow_up_date_time__c < postOneMonth || ld.Next_follow_up_date_time__c > postThreeMonth){
                        ld.Next_follow_up_date_time__c.addError('Follow up date should be > 1 month & < 3 month to park it in On Hold Stage');
                    }
                }
                if (ld.status != oldLeadMap.get(ld.Id).status && (ld.Status == 'Deferred')){
                    dateTime currentDateTime = system.now();
                    dateTime postThreeMonth = system.now().addMonths(3);
                    dateTime postsixMonth = system.now().addMonths(6);
                    if (ld.Next_follow_up_date_time__c < postThreeMonth  || postsixMonth < ld.Next_follow_up_date_time__c ){
                        ld.Next_follow_up_date_time__c.addError('Follow up date should be greater than 3 month and less than 6 month to park it in Deferred Stage');
                    }
                }
                if (ld.status != oldLeadMap.get(ld.Id).status && (ld.status != 'Deferred' && ld.status != 'Dead' && ld.status != 'Junk') && (oldLeadMap.get(ld.Id).status == 'On Hold')){
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    if (ld.Next_follow_up_date_time__c > postOneMonth){
                        ld.Next_follow_up_date_time__c.addError('Follow up date should be < 1 month to change Stage');
                    }
                }
                if (ld.status != oldLeadMap.get(ld.Id).status && (ld.Status == 'Request a Call Back')){
                    dateTime currentDateTime = system.now();
                    dateTime postThreeDay = system.now().addDays(3);
                    if (ld.Next_follow_up_date_time__c == null || ld.Next_follow_up_date_time__c > postThreeDay){
                        ld.Next_follow_up_date_time__c.addError('Follow up date should be less than 3 days to park it in Request a Call Back Stage');
                    }
                }
                if (ld.Alternate_Email__c != oldLeadMap.get(ld.Id).Alternate_Email__c && ld.Alternate_Email__c != null){
                    emailSet.add(ld.Alternate_Email__c);
                    if (!emailSet.isEmpty()){
                        duplicateLeadsByEmail = [Select Id, Email, Alternate_Email__c
                                                 From Lead
                                                 Where (Email In:emailSet or Alternate_Email__c In:emailSet) and Id !=: ld.Id and IsConverted = false limit 1];
                        duplicateOpportunitysByEmail = [Select Id,Email__c,Alternate_Email__c from Opportunity where (Email__c In:emailSet or Alternate_Email__c In:emailSet) and Id !=: ld.Id limit 1];
                        
                        system.debug('duplicateLeadsByEmail-->' + duplicateLeadsByEmail);
                        if (!duplicateLeadsByEmail.isEmpty()){
                            ld.Alternate_Email__c.addError('Other Leads exists with Same Email');
                        }
                        if (!duplicateOpportunitysByEmail.isEmpty()){
                            ld.Alternate_Email__c.addError('Other Opportunity exists with Same Email');
                        }
                    }
                } 
                if (ld.Email != oldLeadMap.get(ld.Id).Email && ld.Email != null){
                    emailSet.add(ld.Email);
                    if (!emailSet.isEmpty()){
                        duplicateLeadsByEmail = [Select Id, Email, Alternate_Email__c
                                                 From Lead
                                                 Where (Email In:emailSet or Alternate_Email__c In:emailSet ) and Id !=: ld.Id and IsConverted = false
                                                 limit 1];
                        duplicateOpportunitysByEmail = [Select Id,Email__c,Alternate_Email__c from Opportunity where (Email__c In:emailSet or Alternate_Email__c In:emailSet ) and Id !=: ld.Id limit 1];
                        
                        system.debug('duplicateLeadsByEmail-->' + duplicateLeadsByEmail);
                        if (!duplicateLeadsByEmail.isEmpty()){
                            ld.Email.addError('Other Leads exists with Same Email');
                        }
                        if (!duplicateOpportunitysByEmail.isEmpty()){
                            ld.Email.addError('Other Opportunity exists with Same Email');
                        }
                    }
                }
                if (ld.Alternate_Phone__c != oldLeadMap.get(ld.Id).Alternate_Phone__c && ld.Alternate_Phone__c != null ){
                    
                    PhoneSet.add('%' + (ld.Alternate_Phone__c).replaceAll('\\+', ''));
                    system.debug('PhoneSet-->' + PhoneSet);
                    if (!PhoneSet.isEmpty()){
                        duplicateLeadsByPhone = [Select Id, Phone, Alternate_Phone__c
                                                 From Lead
                                                 Where (Phone Like:PhoneSet or Alternate_Phone__c Like:PhoneSet) and Id !=: ld.Id
                                                 limit 1];
                        duplicateOpportunityByPhone = [Select Id,Phone__c,Alternate_Phone__c From Opportunity where ( Phone__c Like:PhoneSet or Alternate_Phone__c Like:PhoneSet ) and Id !=: ld.Id limit 1];
                        if (!duplicateLeadsByPhone.isEmpty()){
                            ld.Alternate_Phone__c.addError('Other Leads exists with Same Phone No.');
                        }
                        if (!duplicateOpportunityByPhone.isEmpty()){
                            ld.Alternate_Phone__c.addError('Other Opportunity exists with Same Phone No.');
                        }
                    }
                }
                if (ld.Phone != oldLeadMap.get(ld.Id).Phone && ld.Phone != null ){
                    
                    PhoneSet.add('%' + (ld.Phone).replaceAll('\\+', ''));
                    system.debug('PhoneSet-->' + PhoneSet);
                    if (!PhoneSet.isEmpty()){
                        duplicateLeadsByPhone = [Select Id, Phone, Alternate_Phone__c
                                                 From Lead
                                                 Where (Phone Like:PhoneSet or Alternate_Phone__c Like:PhoneSet ) and Id !=: ld.Id and isConverted = False
                                                 limit 1];
                        duplicateOpportunityByPhone = [Select Id,Phone__c,Alternate_Phone__c From Opportunity where (Phone__c Like:PhoneSet or Alternate_Phone__c Like:PhoneSet ) and Id !=: ld.Id limit 1];
                        if (!duplicateLeadsByPhone.isEmpty()){
                            system.debug('duplicateLeadsByPhone-->'+duplicateLeadsByPhone);
                            
                            ld.Phone.addError('Other Leads exists with Same Phone No.');
                        }
                        if (!duplicateOpportunityByPhone.isEmpty()){
                            system.debug('duplicateOpportunityByPhone-->'+duplicateOpportunityByPhone);
                            ld.Phone.addError('Other Opportunity exists with Same Phone No.');
                        }
                    }
                }
                if (ld.Next_follow_up_date_time__c != oldLeadMap.get(ld.Id).Next_follow_up_date_time__c && ld.Next_follow_up_date_time__c != null && ld.status == 'In Conversation'){
                    dateTime currentDateTime = system.now();
                    dateTime postThirtyDays = system.now().addDays(30);
                    if (ld.Next_follow_up_date_time__c > postThirtyDays){
                        ld.Next_follow_up_date_time__c.addError('Next Followup Date cannot be more than 30 days!!');
                    }
                }
                if (ld.Next_follow_up_date_time__c != oldLeadMap.get(ld.Id).Next_follow_up_date_time__c && ld.Next_follow_up_date_time__c != null && ld.status == 'On Hold'){
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postThreeMonth = system.now().addMonths(3);
                    if (ld.Next_follow_up_date_time__c < postOneMonth || ld.Next_follow_up_date_time__c > postThreeMonth){
                        ld.Next_follow_up_date_time__c.addError('Next Followup Date should be greater than 1 month & less than 3 months!');
                    }
                }
                if (ld.Next_follow_up_date_time__c != oldLeadMap.get(ld.Id).Next_follow_up_date_time__c && ld.Next_follow_up_date_time__c != null && ld.status == 'ATC'){
                    dateTime currentDateTime = system.now();
                    dateTime postFiveDays = system.now().addDays(5);
                    if (ld.Next_follow_up_date_time__c > postFiveDays){
                        ld.Next_follow_up_date_time__c.addError('Next Followup Date cannot be more than 5 days!!');
                    }
                }
                if (ld.Next_follow_up_date_time__c != oldLeadMap.get(ld.Id).Next_follow_up_date_time__c && ld.Next_follow_up_date_time__c != null){
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postThreeMonth = system.now().addMonths(3);
                    if (ld.Next_follow_up_date_time__c > postOneMonth && ld.Next_follow_up_date_time__c < postThreeMonth){
                        ld.status = Constants.OPP_STAGENAME_ON_HOLD;
                    }
                    if (ld.Next_follow_up_date_time__c > postThreeMonth){
                        ld.status = Constants.OPP_STAGENAME_DEFERRED;
                    }
                }
                if (ld.status != oldLeadMap.get(ld.Id).status && ld.status != Null && (oldLeadMap.get(ld.Id).status == Constants.LEAD_STATUS_ON_HOLD ||oldLeadMap.get(ld.Id).status == Constants.LEAD_STATUS_DEFERRED || oldLeadMap.get(ld.Id).status == Constants.LEAD_STATUS_DEAD )) {
                    dateTime postOneMonth = system.now().addMonths(1);
                    if (ld.status == Constants.LEAD_STATUS_IN_CONVERSATION) {
                        if (ld.Next_follow_up_date_time__c  == Null) {
                            ld.Next_follow_up_date_time__c.addError('Please Fill follow Up date!!!');
                        }
                        if (ld.Next_follow_up_date_time__c  == Null && ld.Next_follow_up_date_time__c  >postOneMonth ) {
                            string errormessage = 'Next Follow up date cannot be greater 30 days if you park from ' + oldLeadMap.get(ld.Id).status + ' to ' + ld.status;
                            ld.Next_follow_up_date_time__c.addError(errormessage);
                        }
                    }
                    if ((ld.status == Constants.LEAD_STATUS_ATC || ld.status == Constants.LEAD_STATUS_DEAD || ld.status == Constants.LEAD_STATUS_JUNK || ld.status == Constants.LEAD_STATUS_OPEN ||  ld.status == Constants.LEAD_STATUS_PROMOTE)) {
                        string errormessage = 'you cannot park Lead From ' + oldLeadMap.get(ld.Id).status + ' to ' + ld.status;
                        // ld.Next_follow_up_date_time__c.addError(errormessage);
                    }
                    
                }
                if (oldLeadMap.get(ld.Id).status == Constants.LEAD_STATUS_ATC && ld.status == Constants.LEAD_STATUS_OPEN) {
                    string errormessage = 'you cannot park Lead From ' + oldLeadMap.get(ld.Id).status + ' to ' + ld.status;
                    ld.status.addError(errormessage);
                }
                if (oldLeadMap.get(ld.Id).status == Constants.LEAD_STATUS_REQUEST_CALL_BACK && (ld.status == Constants.LEAD_STATUS_OPEN || ld.status == Constants.LEAD_STATUS_ATC)) {
                    string errormessage = 'you cannot park Lead From ' + oldLeadMap.get(ld.Id).status + ' to ' + ld.status;
                    ld.status.addError(errormessage);
                }
                if (oldLeadMap.get(ld.Id).status == Constants.LEAD_STATUS_IN_CONVERSATION && (ld.status == Constants.LEAD_STATUS_OPEN || ld.status == Constants.LEAD_STATUS_ATC || ld.status == Constants.LEAD_STATUS_REQUEST_CALL_BACK)) {
                    string errormessage = 'you cannot park Lead From ' + oldLeadMap.get(ld.Id).status + ' to ' + ld.status;
                    ld.status.addError(errormessage);
                }
            }
            
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Update', e, null);
        }
    }
    
    public void afterUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadTriggerHandler', 'After Lead Update', e, null);
        }
    }
    
    public void addValidationForProfilling(Lead ld, Map<id, Lead> oldLeadMap){
        if((ld.Qualification__c != oldLeadMap.get(ld.Id).Qualification__c || ld.Qualification__c != null) && (ld.Qualification__c == 'Btech' || ld.Qualification__c == 'MBA')){
            if (ld.Branch__c == null){
                ld.Branch__c.addError('Branch can not be Empty');
            }
        }
        if (ld.Profession__c == 'Student'){
            if (ld.Year_of_Graduation__c == null ){
                if(ld.Qualification__c != '10th' && ld.Qualification__c != '12th'){
                    ld.Year_of_Graduation__c.addError('Year of Graduation can not be Empty');
                }
            }
            if (ld.Branch__c == null){
               // ld.Branch__c.addError('Branch can not be Empty');
            }
            if (ld.Qualification__c == null){
                ld.Qualification__c.addError('Qualification can not be Empty');
            }
            
        } else if (ld.Profession__c == 'Working Professional'){
            if (ld.Relevant_Experience__c == null){
                //ld.Relevant_Experience__c.addError('Relevant Experience can not be Empty');
            }
            if (ld.Current_Domain__c == null){
                ld.Current_Domain__c.addError('Current Domain can not be Empty');
            }
            if (ld.Year_of_Experience__c == null){
                ld.Year_of_Experience__c.addError('Year of Experience can not be Empty');
            }
            if (ld.Designation__c == null){
                ld.Designation__c.addError('Designation can not be Empty');
            }
            if (ld.Organisation__c == null){
                ld.Organisation__c.addError('Organisation can not be Empty');
            }
           
            if (ld.Branch__c == null){
               // ld.Branch__c.addError('Branch can not be Empty');
            }
            if (ld.Qualification__c == null){
                ld.Qualification__c.addError('Qualification can not be Empty');
            }
        }
    }
    
    public class ApplicationtaskWrapper{
        public Application__c app{ get; set; }
        
        public Task TaskRec{ get; set; }
        
    }
    
}