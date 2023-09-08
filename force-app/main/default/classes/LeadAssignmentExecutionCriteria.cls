public without sharing class LeadAssignmentExecutionCriteria {
    public Static Boolean runLeadAssignment = true;
    
    public static void validateEntryCriteria(){
        
        try{
            Set<Lead> assignedLead = new Set<Lead>();
            Boolean IsLeadAssigned = False;
            list<lead> newLeadListTemp                                              = new list<lead>();
            list<lead> DefaultQueueList                                             = new list<lead>();
            list<String> matchedCriterias                                           = new list<String>();
            map<string,list<Lead>> mapofExecutionIdByListLead                       = new map<String,List<Lead>>();
            map<String,integer> mapofExeIdByEntryCount                              = new map<string,Integer>();
            map<String,String> mapofExeIdByEvaluaationExp                           = new map<string,String>();
            map<String,List<String>> mapByallFields                                 = new map<String,List<String>>();
            map<String,List<String>> mapofFieldsWithPossibleValues                  = new map<String,List<String>>();
            map<String,map<String,Map<String,String>>> matchingTypeFieldByCriteria  = new map<String,map<String,Map<String,String>>>();
            map<string,map<string,List<String>>> multipleCriteriasForFields         = new map<string,map<string,List<String>>>();
            map<string,map<string,List<Decimal>>> allotedFieldbySequenceList        = new map<string, map<string,List<Decimal>>>();
            map<String,List<Lead>> mapofRMGroupNameByLeadList                       = new map<String,List<Lead>>();
            map<string,map<string,String>> expectedValuebyCriteria                  = new map<string,map<string,String>>();
            map<String,String> leadIdByMatchedCriterias                             = new map<String,String>();
            map<string,map<string,Decimal>> allotedFieldbySequence                  = new map<string,map<string,Decimal>>();
            map<string,String> criteriaNameById                                     = new Map<String,String>();
            map<String,map<string,list<String>>> fieldByMatchingType                = new map<String,map<string,list<String>>>();
            map<String,map<string,String>> fieldByFieldType                         = new map<String,map<string,String>>();
            map<string,String> leadValueForFields                                   = new Map<String,String>();
            map<String,List<Lead>> mapofCriteriaIdByLeadList                        = new map<String,List<Lead>>();
            map<String,List<Lead>> mapofFbGroupNameByLeadList                       = new map<String,List<Lead>>();
            map<string,Decimal> allotedMarksbySequence                              = new Map<String,Decimal>();
            set<String> newLeadsSet                                                 = new set<String>();
            
            string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Excelr Default Queue' limit 1].Id;
            list<Default_Assignment_Group__mdt> defaultGroupName = [select id,Group_Name__c from Default_Assignment_Group__mdt];
            List<Execution_Criteria__c> AvailableCriterias = [SELECT Enabled__c,Evaluation_Expression_For_Execution__c,Id,Name ,(SELECT Execution_Criteria__c,serial__c,Field_Name__c,Field_Type__c,Matching_Type__c,Matching_Value__c,Related_Object__c,Scorecard_Execution_Criteria_Name__c,Scorecard__c,Sequence__c FROM Execution_Criteria_Entry__r WHERE Execution_Criteria__c != null ORDER BY Sequence__c ASC)FROM Execution_Criteria__c where Enabled__c = true];
            string leadAssignmentQuery = [Select Id,Query__c From LeadAssignmentQuery__mdt].Query__c;
            
            list<lead> queueLeads = database.query(leadAssignmentQuery);
                /*[SELECT Address,AD_Set_Id__c,AD_Set_Name__c,Assignment_Group__c,
                                     Branch__c,Capture_NBFC_Partner__c,Capture_Tenure__c,Capture_Upfront_payment__c,
                                     CID_of_Referer__c,City,City__c,Comments__c,Company,Confidence_Level__c
                                     ,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,Country,Country__c,
                                     Course_Interested_Rating__c,Course__c,CreatedById,CreatedDate,Current_Domain__c,Date_of_Enrollment__c,
                                     Description,Designation__c,Do_you__c,Email,EmailBouncedDate,EmailBouncedReason,Email_Conversation_Done__c,
                                     Enter_UTM_Link__c,ExcelR_Training_User__c,Facebook_Ad_Id__c,Facebook_Ad_Name__c,Facebook_Platform__c,
                                     FirstName,Form_Names__c,GCLID__c,GeocodeAccuracy,Id,Industry,IsConverted,IsDeleted,ISM_Name__c,ISM__c,
                                     IsUnreadByOwner,Is_Email_Invalid__c,Is_Phone_Invalid__c,Jigsaw,JigsawContactId,
                                     LastActivityDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,Latitude,LeadSource,
                                     Lead_Assigned_Date_TIme__c,Lead_Assigned_Date__c,Lead_Assigned_Time__c,Lead_Create_Date__c,Lead_Generation_Method__c,
                                     Lead_Generation_Team_Member_Name__c,Lead_Gen_Form_Id__c,Lead_Gen_Path__c,Lead_Id_FB__c,Lead_Name__c,Longitude,
                                     MasterRecordId,Medium__c,MiddleName,MobilePhone,Name,Next_follow_up_date_time__c,NumberOfEmployees,OwnerId,
                                     Owner_Email__c,Payment_Initiated_Date_Time__c,Payment_Type__c,Phone,PhotoUrl,PostalCode,
                                     Prior_Status__c,Profession__c,Qualification__c,Quality_of_Lead__c,Rating,Reason_For_Dead__c,
                                     Reason_for_On_Hold__c,Referral_Email__c,Referral_Phone__c,referrer__c,Refree_Mob_No__c,Relevant_Experience__c,Salutation,
                                    Specialization__c,State,State__c,Status,Street,Suffix,
                                     SyncedInCallyzer__c,SystemModstamp,Telephonic_Conversation__c,Title,Total_Applications_Submitted__c,
                                     Total_Calls__c,Total_Call_Duration__c,Total_Connected_Call__c,Total_Conversation_Duration__c,Total_Course_Interests__c,
                                     Total_Emails__c,Type_of_Course__c,UTM_AdGroup__c,UTM_Campaign__c,UTM_Channel__c,UTM_Device__c,
                                     UTM_Experiment__c,UTM_Location__c,UTM_Medium__c,UTM_Term__c,UTM_Type__c,UTM_Variety__c,Visitor_ID__c,Website,
                                     Whatsapp_Opt_in__c,Why_This_Course__c,Year_of_Experience__c 
                                     FROM Lead 
                                     where ownerId =: queueId and Is_Lead_Assigned_to_User__c = false And To_Be_Deleted__c = false order by CreatedDate DESC limit 1];
*/
            System.debug('queueLeads ==> ' + queueLeads);
            if(!queueLeads.isEmpty()){
                newLeadListTemp.addAll(queueLeads);
                System.debug(queueLeads.size()); 
            }

            System.debug('AvailableCriterias ====> ' + AvailableCriterias);
            
            for(Execution_Criteria__c scr:AvailableCriterias){
                map<string,string> fieldNameByMatching                                  = new Map<String,string>();
                map<string,List<Decimal>> allotedFieldbySequenceListMap                 = new Map<String,List<Decimal>>();
                map<string,Decimal> allotedFieldbySequenceMap                           = new Map<String,Decimal>();
                map<string,List<String>> fieldByMatchingTypeMap                        = new map<string,List<String>>();
                map<string,String>fieldByFieldTypeMap                                 = new map<string,String>();
                map<String,Map<String,String>> matchingTypeAndValuesByField             = new map<String,Map<String,String>>();
                List<String> allFields                                                  = new List<String>();  
                
                for(Execution_Criteria_Entry__c exe:scr.Execution_Criteria_Entry__R){
                    
                    if(mapofFieldsWithPossibleValues.containsKey(exe.Field_Name__c)){
                        mapofFieldsWithPossibleValues.get(exe.Field_Name__c).add(exe.Matching_Value__c);
                    }else{ 
                        mapofFieldsWithPossibleValues.put(exe.Field_Name__c,new list<string>{exe.Matching_Value__c});
                    }
                    
                    if(fieldByMatchingTypeMap.containsKey(exe.Field_Name__c)){
                        fieldByMatchingTypeMap.get(exe.Field_Name__c).add(exe.Matching_Type__c);
                    }else{ 
                        fieldByMatchingTypeMap.put(exe.Field_Name__c,new list<string>{exe.Matching_Type__c});
                    }
                    
                    if(matchingTypeAndValuesByField.containsKey(exe.Field_Name__c)){
                        matchingTypeAndValuesByField.get(exe.Field_Name__c).put(exe.Matching_Type__c,exe.Matching_Value__c);
                    }else{ 
                        map<string,String> matchingTypeAndValues = new  map<string,String>();
                        matchingTypeAndValues.put(exe.Matching_Type__c,exe.Matching_Value__c);
                        matchingTypeAndValuesByField.put(exe.Field_Name__c,matchingTypeAndValues);
                    }
                    
                    if(allotedFieldbySequenceMap.containsKey(exe.Field_Name__c)){
                        allotedFieldbySequenceListMap.get(exe.Field_Name__c).add(exe.Sequence__c);
                    }else{ 
                        allotedFieldbySequenceListMap.put(exe.Field_Name__c,new list<Decimal>{exe.Sequence__c});
                    }
                    allotedFieldbySequenceMap.put(exe.Field_Name__c,exe.Sequence__c);
                    fieldNameByMatching.put(exe.Field_Name__c,exe.Matching_Value__c);
                    fieldByFieldTypeMap.put(exe.Field_Name__c,exe.Field_Type__c);
                    allFields.add(exe.Field_Name__c);
                }
                
                fieldByMatchingType.put(scr.Name,fieldByMatchingTypeMap);
                fieldByFieldType.put(scr.Name,fieldByFieldTypeMap);
                mapByallFields.put(scr.Name,allFields);
                allotedFieldbySequence.put(scr.Name,allotedFieldbySequenceMap);
                allotedFieldbySequenceList.put(scr.Name,allotedFieldbySequenceListMap);
                matchingTypeFieldByCriteria.put(scr.Name,matchingTypeAndValuesByField);
                mapofExeIdByEntryCount.put(scr.Id,scr.Execution_Criteria_Entry__r.size());
                mapofExeIdByEvaluaationExp.put(scr.Name,scr.Evaluation_Expression_For_Execution__c);
                expectedValuebyCriteria.put(scr.Name,fieldNameByMatching);
                multipleCriteriasForFields.put(scr.Name,mapofFieldsWithPossibleValues);
                criteriaNameById.put(scr.Name,scr.Id);
                
            }

            System.debug('fieldByMatchingType ===> ' + fieldByMatchingType);
            System.debug('fieldByFieldType ===> ' + fieldByFieldType);

            System.debug('mapByallFields ===> ' + mapByallFields);
            System.debug('allotedFieldbySequence ===> ' + allotedFieldbySequence);
            System.debug('allotedFieldbySequenceList ===> ' + allotedFieldbySequenceList);
            System.debug('matchingTypeFieldByCriteria ===> ' + matchingTypeFieldByCriteria);

            System.debug('mapofExeIdByEntryCount ===> ' + mapofExeIdByEntryCount);
            System.debug('mapofExeIdByEvaluaationExp ===> ' + mapofExeIdByEvaluaationExp);
            System.debug('expectedValuebyCriteria ===> ' + expectedValuebyCriteria);
            System.debug('multipleCriteriasForFields ===> ' + multipleCriteriasForFields);
            System.debug('criteriaNameById ===> ' + criteriaNameById);



            String logicalValues = '';
            
            System.debug('newLeadListTemp ====> ' + newLeadListTemp);
            for(Lead ld:newLeadListTemp){
                System.debug('ld =====> ' + ld);
                boolean leadTemp = false;
                List<String> matchedCriteriasName = new List<String>();
                for(String criteriaName : expectedValuebyCriteria.keyset()){

                    System.debug('criteriaName ====> ' +criteriaName);
                    String Booleanvalues = mapofExeIdByEvaluaationExp.get(criteriaName);
                    integer matchedValues = 0;
                    Decimal recursionValue = 0;
                    
                    for(String field:mapByallFields.get(criteriaName))  {

                        System.debug('field ====> ' + field);
                        recursionValue = allotedFieldbySequence.get(criteriaName).get(field);
                        System.debug('recursionValue ====> ' + recursionValue);


                        System.debug('matchingTypeFieldByCriteria.get(criteriaName).get(field).size() =====> ' + matchingTypeFieldByCriteria.get(criteriaName).get(field).size());
                        if(matchingTypeFieldByCriteria.get(criteriaName).get(field).size() <= 1){
                            if(fieldByFieldType.get(criteriaName).get(field) == 'Number'){
                                System.debug('I am Number dude @123');

                                for(String str : fieldByMatchingType.get(criteriaName).get(field)){

                                    System.debug('str =====> ' + str);

                                    if ((ld.get(field)) != null) {
                                        if(str == '<' || str == '<='){
                                            if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) >= Integer.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            } 
                                        }else if(str == '>' || str == '>='){
                                            if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) <= Integer.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }
                                        }else{
                                            if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) == Integer.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }
                                        }
                                    }
                                    else {
                                        Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                    }
                                }
                            }
                            else if(fieldByFieldType.get(criteriaName).get(field) == 'Checkbox'){
                                System.debug('I am Checkbox Bro @true/False');
                                if ((ld.get(field)) != null){
                                    if(ld.get(field) == Boolean.valueOf(expectedValuebyCriteria.get(criteriaName).get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                        matchedCriteriasName.add(getLabelNameOfField(field)+' '+'== '+expectedValuebyCriteria.get(criteriaName).get(field));
                                    }else{
                                        Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                    }
                                }
                                else {
                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                }
                                
                            }
                            else{
                                for(String str : fieldByMatchingType.get(criteriaName).get(field)){
                                    
                                    if(str == '=='){
                                        if(expectedValuebyCriteria.get(criteriaName).get(field).contains(',')){
                                            List<String> commaSeparatedValues = expectedValuebyCriteria.get(criteriaName).get(field).split(',');
                                            for(String Str1:commaSeparatedValues){
                                                if(Str1 == String.valueOf(ld.get(field))){
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                                    break;
                                                } 
                                            }
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'false');
                                        }else{
                                            if(expectedValuebyCriteria.get(criteriaName).get(field) == String.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }   
                                        }    
                                    }else if(str == '!='){
                                        if(expectedValuebyCriteria.get(criteriaName).get(field) == 'null'){
                                            if(ld.get(field) == null){
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }else{
                                                if(expectedValuebyCriteria.get(criteriaName).get(field) != ld.get(field)){
                                                    matchedValues++;
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                                }else{
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                                }    
                                            }
                                        }else{
                                            if(expectedValuebyCriteria.get(criteriaName).get(field) != String.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }     
                                        }
                                    }else if(str == 'CONTAINS'){
                                        if(String.valueOf(ld.get(field)) != null){
                                            if(String.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)).contains(String.valueOf(ld.get(field)))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }   
                                        }else{
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                        }
                                        
                                    }
                                    else if(str == 'DOES NOT CONTAIN'){

                                        if (String.valueOf(ld.get(field)) != null) {
                                            if(!expectedValuebyCriteria.get(criteriaName).get(field).contains(String.valueOf(ld.get(field)))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                            }                                            
                                        }
                                        else {
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False'); 
                                        }
                                        
                                    }else{
                                        Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                    }
                                }
                                
                            }
                            
                        }
                        else{
                            integer start = 0;
                            
                            for(String str : matchingTypeFieldByCriteria.get(criteriaName).get(field).keyset()){
                                if(fieldByFieldType.get(criteriaName).get(field) == 'Number'){
                                    if(str == '<' || str == '<='){
                                        if(Integer.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str)) >= Integer.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                            matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                        }else{
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                        } 
                                    }else if(str == '>' || str == '>='){
                                        if(Integer.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str)) <= Integer.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                            matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                        }else{
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                        }
                                    }else{
                                        if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) == Integer.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'True');
                                            matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                        }else{
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                        }
                                    }
                                }
                                else if(fieldByFieldType.get(criteriaName).get(field) == 'Checkbox'){
                                    if(ld.get(field) == Boolean.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                        
                                    }else{
                                        Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'false');
                                    }
                                }
                                
                                else{
                                    if(str == '=='){
                                        if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str).contains(',')){
                                            List<String> commaSeparatedValues = expectedValuebyCriteria.get(criteriaName).get(field).split(',');
                                            for(String Str1:commaSeparatedValues){
                                                if(Str1 == String.valueOf(ld.get(field))){
                                                    matchedValues++;
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                                } else{
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                                    
                                                }
                                            }
                                        }else{
                                            if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) == String.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                                
                                            }   
                                        }    
                                    }
                                    else if(str == '!='){
                                        if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) == 'null'){
                                            if(ld.get(field) == null){
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                                
                                            }else{
                                                if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) != ld.get(field)){
                                                    matchedValues++;
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                                }else{
                                                    Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                                }    
                                            }
                                        }else{
                                            if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) != String.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                            }     
                                        }
                                    }
                                    else if(str == 'CONTAINS'){
                                        if(String.valueOf(ld.get(field)) != null){
                                            if(String.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str)).contains(String.valueOf(ld.get(field)))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                                matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                            }else{
                                                Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                            }   
                                        }else{
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(recursionValue),'False');
                                        }
                                        
                                    }
                                    else if(str == 'DOES NOT CONTAIN'){
                                        if(!matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str).contains(String.valueOf(ld.get(field)))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                            matchedCriteriasName.add(getLabelNameOfField(field)+' '+str+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                        }
                                        else{
                                            Booleanvalues = Booleanvalues.replaceFirst(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                        }
                                    }
                                }
                                start++;
                            }
                        }
                    }
                    if(Booleanvalues == 'false'){
                        leadTemp = False;
                    }else if(Booleanvalues == 'true'){
                        leadTemp = True;
                    }else{
                        leadTemp = BooleanExpressionCalculation.evaluateExpression(Booleanvalues);    
                    }
                    
                    System.debug('leadTemp ===> ' +leadTemp);
                    if(leadTemp == true){
                        assignedLead.add(ld);
                        matchedCriterias.add(criteriaName);
                        if(mapofExecutionIdByListLead.containsKey(criteriaNameById.get(criteriaName))){
                            mapofExecutionIdByListLead.get(criteriaNameById.get(criteriaName)).add(ld);
                        }else{
                            mapofExecutionIdByListLead.put(criteriaNameById.get(criteriaName),new list<lead>{ld});
                        }
                        break;
                    }
                }

                System.debug('mapofExecutionIdByListLead ====> ' + mapofExecutionIdByListLead);
                System.debug('assignedLead ===> ' + assignedLead);
                if(assignedLead.contains(ld)){
                }else{
                    DefaultQueueList.add(ld);    
                }
            }
            
            map<String,List<Lead>> mapofGlobalGroupNameByLeadList = new map<String,List<Lead>>();
            DefaultGroupAssignment__c dgc = [Select id,Name,Group_Id__c from DefaultGroupAssignment__c where name = 'TLM'][0];
            
            if(DefaultQueueList.size() > 0 && DefaultQueueList != null){
                mapofGlobalGroupNameByLeadList.put(dgc.Name,DefaultQueueList);
            }
            getGroupNameByLeads(mapofExecutionIdByListLead,mapofGlobalGroupNameByLeadList);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadAssignmentExecutionCriteria', 'validateEntryCriteria', e , null);
            
        }
    }
    
    public static void getGroupNameByLeads(map<string,list<lead>> mapofExecutionIdByLeadList,map<String,List<Lead>> mapofGlobalGroupNameByLeadList){

        System.debug('mapofExecutionIdByLeadList ===> ' + mapofExecutionIdByLeadList);
        System.debug('mapofGlobalGroupNameByLeadList ===> ' + mapofGlobalGroupNameByLeadList);
        try{
            
            list<Assignment_Group__c> agList = [SELECT id,name,Lead_Assigning_Criteria__c from assignment_group__c where Lead_Assigning_Criteria__c in: mapofExecutionIdByLeadList.keySet()];
            map<string,list<lead>> mapOfGroupNameByListLead = new map<string,list<lead>>();
            System.debug('agList ===> ' + agList);
            
            if(!agList.isEmpty()){
                System.debug('agList is not Empty !!');
                for(assignment_group__c assGroup : agList){
                    mapOfGroupNameByListLead.put(assGroup.name, mapofExecutionIdByLeadList.get(assGroup.Lead_Assigning_Criteria__c));
                }
                list<String> leadIdList = new list<String>();
                map<string,list<String>> mapofGroupnameByLeadIdList = new map<String,list<String>>();
                for(String mapKey : mapOfGroupNameByListLead.keySet()){
                    for(lead ld : mapOfGroupNameByListLead.get(mapKey)){
                        if(mapofGroupnameByLeadIdList.containsKey(mapKey)){
                            mapofGroupnameByLeadIdList.get(mapKey).add(ld.Id);
                        }else{
                            mapofGroupnameByLeadIdList.put(mapKey,new list<String>{ld.Id});
                        }
                    }
                    Set<string> tempId = new Set<String>(mapofGroupnameByLeadIdList.get(mapKey));
                    System.debug('RR about to Start when agList Is not Empty!!');
                    System.debug('mapKey ====> ' + mapKey);
                    System.debug('tempId ====> ' + tempId);
                    RoundRobinLeadAssignment.assignLeadsToBDS(mapKey,tempId);
                }
            }
            //this is else Part.....
            System.debug('mapofGlobalGroupNameByLeadList ======> ' + mapofGlobalGroupNameByLeadList);
            if(!mapofGlobalGroupNameByLeadList.isEmpty()){
                System.debug('mapofGlobalGroupNameByLeadList is not Empty !!');
                set<String> tempId = new set<String>();
                for(string mapKey : mapofGlobalGroupNameByLeadList.keySet()){
                    for(Lead ld : mapofGlobalGroupNameByLeadList.get(mapKey)){
                        tempId.add(ld.id);
                    }
                    System.debug('RR about to Start when mapofGlobalGroupNameByLeadList Is not Empty!!');
                    System.debug('mapKey ====> ' + mapKey);
                    System.debug('tempId ====> ' + tempId);
                    RoundRobinLeadAssignment.assignLeadsToBDS(mapKey,tempId);
                }
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadAssignmentExecutionCriteria', 'getGroupNameByLeads', e , null);
            
        }
    }
    
    public  static List<Lead> validatemanuallyCreatedLead(List<Lead> newLeads){
        try{
            List<Lead> leadsToBeProcessedForAssignment = new List<Lead>();
            for(Lead ld:newLeads){
                if(true){
                    leadsToBeProcessedForAssignment.add(ld);
                }
            }
            if(!leadsToBeProcessedForAssignment.isEmpty()){
                return leadsToBeProcessedForAssignment;
            }
            else{
                return null;
            }
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('LeadAssignmentExecutionCriteria', 'getGroupNameByLeads', e , null);
            return null;
        }
    }
    public static void assignDefaultQueue(list<lead> newLeadList){
        try{
            List<Lead>  LeadsToBeUpdated= new List<Lead>();
            List<Lead> UpdatedLeads = [Select id,Name,OwnerID from Lead where ID IN:newLeadList];
            string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Lead Default Queue' limit 1].Id;
            
            for(Lead ld : UpdatedLeads) {
                ld.ownerId = queueId;
                LeadsToBeUpdated.add(ld);
            }
            update LeadsToBeUpdated;
        }catch(exception ex ){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>@@'+ex.getLineNumber());
        }
    }
    
    public static string getLabelNameOfField(string apiName){
        try{
            String type='Lead';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            return fieldMap.get(apiName).getDescribe().getLabel();
        } catch(exception ex ){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>@@'+ex.getLineNumber());
            return null;
        }
    }
}