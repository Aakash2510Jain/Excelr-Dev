public without Sharing class BuildMaps{
    /*Condition Map*/
    public static map<string, integer> mapofMemIdByExceedCount = new map<string, integer>();
    public static map<string, Integer> mapofMemidByTodayLeadCount = new map<string, integer>();
    public static map<string, Integer> mapofMemIdByMaxLeadCountPerDay = new map<string, integer>();
    public static map<string, Integer> mapofMemIdByMaxLeadCountByGroupPerDay = new map<String, integer>();
    public static map<string, Integer> mapofMemidbyMaxleadCountFromUser = new map<string, integer>();
    public static map<string, Integer> mapofMemidByPendingLeads = new map<string, integer>();
    public static map<string, Integer> mapofMemidByMinLeadsCount = new map<string, integer>();
    public static map<string, integer> mapofMemidByTodayNewLead = new map<string, integer>();
    public static map<string, integer> mapofMemidByAssignedLead = new map<string, integer>();
    public static map<string, integer> mapofMemidByMaxLeadPerMonthFromUser = new map<string, integer>();
    public static map<string, integer> mapofMemidByMaxLeadPerDayFromAG = new map<string, integer>();
    public static map<string, integer> mapofMemidByLeadAssignedThisMonth = new map<string, integer>();
    public static map<string, integer> mapofMemidByLeadsAssignedInThisTransaction = new map<string, integer>();
    public static map<string, Integer> mapofMemidByLeadsToAssignInSIngleShot = new map<string, integer>();
    public static map<String, map<String, Integer>> mapofAGIdWithMapOfMemIdAssignedLead = new map<String, map<String, Integer>>();
    public static map<string, String> mapofAssignGroupNameById = new map<string, String>();

    public static map<string, String> mapofAllocatedIdByMaxLeadCap = new map<string, String>();
    public static map<string, String> mapofOwnerIdByTodaysLeadAssignedCount = new map<string, String>();
    public static map<string, String> mapofAllocatedIdByOwnerId = new map<string, String>();
    


    public static void mapsForUserCapacity(string assignmentGroupName){
        try{
            system.debug('assignmentGroupName--->'+assignmentGroupName);
                
            List<Assignment_Group_Member__c> agmList = new List<Assignment_Group_Member__c>();
            List<Lead> leadsAssignedToday = new List<Lead>();

            if(!string.isBlank(assignmentGroupName)){
                agmList = [Select Id, Assignment_Id__c,Max_Lead_Per_Day__c,Group_Member__c From Assignment_Group_Member__c where Assignment_Group__r.name  = : assignmentGroupName];
                if(!agmList.isEmpty()){
                    for(Assignment_Group_Member__c agm : agmList){
                        mapofAllocatedIdByMaxLeadCap.put(string.valueOf(agm.Assignment_Id__c), string.valueOf(agm.Max_Lead_Per_Day__c));
                        mapofAllocatedIdByOwnerId.put(string.valueOf(agm.Assignment_Id__c), string.valueOf(agm.Group_Member__c));
                    }
                    if(!mapofAllocatedIdByOwnerId.isEmpty()){

                         List<AggregateResult> results = [SELECT OwnerId, COUNT(Id) leadCount FROM Lead WHERE Lead_Assigned_Date__c = today and OwnerId in : mapofAllocatedIdByOwnerId.values() GROUP BY OwnerId];
                        
                         System.debug('results =====> ' + results);
                        for (AggregateResult result : results) {
                            Id ownerId = (Id) result.get('OwnerId');
                            Integer leadCount = (Integer) result.get('leadCount');
                            mapofOwnerIdByTodaysLeadAssignedCount.put(string.valueOf(ownerId), string.valueOf(leadCount));
                        }
                    }
                }
                System.debug('mapofOwnerIdByTodaysLeadAssignedCount ======> ' + mapofOwnerIdByTodaysLeadAssignedCount);
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'makeQNameToLastAssignedQmemberRRid', e, null);
        }
    }

    /* Condition map end*/
    public static boolean CheckBusinessHours(){
        try{
            Datetime toBeChecked = System.now();
            BusinessHours hours = [SELECT ID, TimeZoneSidKey
                                   FROM BusinessHours
                                   WHERE IsDefault = true];
            Datetime targetTime = Datetime.newInstance(toBeChecked.year(), toBeChecked.month(), toBeChecked.day(), toBeChecked.hour(), toBeChecked.minute(), toBeChecked.second());


            if (BusinessHours.isWithin(hours.id, targetTime)){
                system.debug('inside ');
                return true;
            }
            return false;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'CheckBusinessHours', e, null);
            return null;
        }
    }

    public static Map<String, Integer> makeQNameToLastAssignedQmemberRRid(){
        try{
            Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
            List<Assignment_Group__c> allExistingQueue = new List<Assignment_Group__c>([SELECT id, name, Last_Allocated_RRid__c
                                                                                        from Assignment_Group__c]);
            for (Assignment_Group__c q : allExistingQueue){
                if (q.Last_Allocated_RRid__c != null){
                    qNameToLastAssignedQmemberRRid.put(q.name, Integer.valueOf(q.Last_Allocated_RRid__c));
                } else
                    qNameToLastAssignedQmemberRRid.put(q.name, null);
            }
            return qNameToLastAssignedQmemberRRid;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'makeQNameToLastAssignedQmemberRRid', e, null);
            return null;
        }
    }
    
    public static void validateUserCapacity(String groupName, set<String> leadIdList){
        try{
            system.debug('groupName::' + groupName);
            list<Assignment_Group_Member__c> listOfGroupMember = new list<Assignment_Group_Member__c>();
            list<lead> listOfTodayLeads = new list<lead>();
            list<lead> listOfNewLeads = new list<lead>();
            list<lead> listOfAssignedTodayLeads = new list<lead>();
            list<lead> listOfAssignedThisMonth = new list<lead>();

            listOfGroupMember = [select id, Max_Lead_Per_Day__c, Assignment_Group__r.Minimum_Lead_Volume__c, Assignment_Group__r.Name, Group_Member__r.Id, Group_Member__r.Max_Lead_Per_Month__c, Group_Member__r.Max_Lead_Per_Day__c, Assignment_Group__r.Max_Lead_Per_Day__c, Assignment_Group__r.Lead_Stage__c, Assignment_Group__r.Lead_Stage_Exceed_Count__c
                                 from Assignment_Group_Member__c
                                 where active__c = true and assignment_group__r.name = :groupName];
            listOfTodayLeads = [select id, Lead_Assigned_Date__c, ownerId, status, AG_Related_to__c, AG_Related_to__r.Name, AGM_Related_to__c, AGM_Related_to__r.Name
                                from lead
                                where Lead_Assigned_Date__c = today];
            listOfNewLeads = [select id, Lead_Assigned_Date__c, ownerId, status, AG_Related_to__c, AG_Related_to__r.Name, AGM_Related_to__c, AGM_Related_to__r.Name
                              from lead
                              where status = 'Open'];
            listOfAssignedTodayLeads = [select id, Lead_Assigned_Date__c, ownerId, status, AG_Related_to__c, AG_Related_to__r.Name, AGM_Related_to__c, AGM_Related_to__r.Name
                                        from lead
                                        where Lead_Assigned_Date__c = today];
            listOfAssignedThisMonth = [select id, Lead_Assigned_Date__c, ownerId, status, AG_Related_to__c, AG_Related_to__r.Name, AGM_Related_to__c, AGM_Related_to__r.Name
                                       from lead
                                       where Lead_Assigned_Date__c = This_Month];

            System.debug('listOfAssignedTodayLeads ====> ' + listOfAssignedTodayLeads);

            if (!listOfNewLeads.isEmpty()){
                for (lead ld : listOfNewLeads){
                    if (mapofMemidByPendingLeads.containsKey(ld.OwnerId)){
                        integer count = mapofMemidByPendingLeads.get(ld.OwnerId);
                        mapofMemidByPendingLeads.put(ld.OwnerId, count + 1);
                    } else{
                        mapofMemidByPendingLeads.put(ld.OwnerId, 1);
                    }
                }
            }
            for (Assignment_Group_Member__c agm : listOfGroupMember){
                mapofAssignGroupNameById.put(agm.Assignment_Group__r.Name, agm.Assignment_Group__c);
                mapofMemIdByExceedCount.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Assignment_Group__r.Lead_Stage_Exceed_Count__c));
                mapofMemIdByMaxLeadCountPerDay.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Max_Lead_Per_Day__c));
                mapofMemIdByMaxLeadCountByGroupPerDay.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Max_Lead_Per_Day__c));
                mapofMemidbyMaxleadCountFromUser.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Group_Member__r.Max_Lead_Per_Day__c));
                mapofMemidByMinLeadsCount.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Assignment_Group__r.Minimum_Lead_Volume__c));
                mapofMemidByMaxLeadPerMonthFromUser.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Group_Member__r.Max_Lead_Per_Month__c));
                mapofMemidByMaxLeadPerDayFromAG.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Group_Member__r.Max_Lead_Per_Day__c));
                mapofMemidByLeadsToAssignInSIngleShot.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Assignment_Group__r.Minimum_Lead_Volume__c));
            }

            System.debug('listOfAssignedTodayLeads ====> ' + listOfAssignedTodayLeads);

            if (!listOfAssignedTodayLeads.isEmpty()){
                for (lead ld : listOfAssignedTodayLeads){
                    if (mapofMemidByAssignedLead.containsKey(ld.ownerId)){
                        integer count = mapofMemidByAssignedLead.get(ld.ownerId);
                        mapofMemidByAssignedLead.put(ld.ownerId, count + 1);
                    } else{
                        mapofMemidByAssignedLead.put(ld.ownerId, 1);
                    }
                }
            }
            System.debug('listOfAssignedTodayLeads ====> ' + listOfAssignedTodayLeads);

            if (!listOfAssignedTodayLeads.isEmpty()){
                for (lead ld : listOfAssignedTodayLeads){
                    System.debug('ld.AG_Related_to__r.Name ====> ' + ld.AG_Related_to__r.Name);
                    if (ld.AG_Related_to__r.Name != null){
                        if (mapofAGIdWithMapOfMemIdAssignedLead.containsKey(ld.AG_Related_to__r.Name)){

                            System.debug('ld.AG_Related_to__r.Name ====> ' + ld.AG_Related_to__r.Name);
                            map<String, integer> ExistingmapMediDbyAssignedlead = mapofAGIdWithMapOfMemIdAssignedLead.get(ld.AG_Related_to__r.Name);
                            System.debug('ExistingmapMediDbyAssignedlead ====> ' + ExistingmapMediDbyAssignedlead);
                            map<String, integer> returnmapped = createMapMemidForAssignedLead(ld, ExistingmapMediDbyAssignedlead);

                            System.debug('returnmapped ======> ' + returnmapped);
                            mapofAGIdWithMapOfMemIdAssignedLead.put(ld.AG_Related_to__r.Name, returnmapped);
                            System.debug('mapofAGIdWithMapOfMemIdAssignedLead ====> ' + mapofAGIdWithMapOfMemIdAssignedLead);

                        }
                        else{
                            map<String, integer> NewmapofMemidByAssignedLead = new map<String, integer>();
                            mapofAGIdWithMapOfMemIdAssignedLead.put(ld.AG_Related_to__r.Name, createMapMemidForAssignedLead(ld, NewmapofMemidByAssignedLead));
                        }

                        System.debug('mapofAGIdWithMapOfMemIdAssignedLead =====> '+ mapofAGIdWithMapOfMemIdAssignedLead);

                    } 
                }
            }

            System.debug('mapofAGIdWithMapOfMemIdAssignedLead =====> ' + mapofAGIdWithMapOfMemIdAssignedLead);

            for (lead ld : listOfTodayLeads){
                if (mapofMemidByTodayLeadCount.containsKey(ld.ownerId)){
                    integer count = mapofMemidByTodayLeadCount.get(ld.ownerId);
                    mapofMemidByTodayLeadCount.put(ld.ownerId, count + 1);
                } else{
                    mapofMemidByTodayLeadCount.put(ld.ownerId, 1);
                }
                if (ld.status == 'New'){
                    if (mapofMemidByTodayNewLead.containsKey(ld.ownerId)){
                        integer count = mapofMemidByTodayNewLead.get(ld.ownerId);
                        mapofMemidByTodayNewLead.put(ld.ownerId, count + 1);
                    } else{
                        mapofMemidByTodayNewLead.put(ld.ownerId, 1);
                    }
                }
            }
            if (!listOfAssignedThisMonth.isEmpty()){
                for (Lead ld : listOfAssignedThisMonth){
                    if (mapofMemidByLeadAssignedThisMonth.containsKey(ld.OwnerId)){
                        integer count = mapofMemidByLeadAssignedThisMonth.get(ld.ownerId);
                        mapofMemidByLeadAssignedThisMonth.put(ld.ownerId, count + 1);
                    } else{
                        mapofMemidByLeadAssignedThisMonth.put(ld.ownerId, 1);
                        if (ld.status == 'New'){
                            if (mapofMemidByTodayNewLead.containsKey(ld.ownerId)){
                                integer count = mapofMemidByTodayNewLead.get(ld.ownerId);
                                mapofMemidByTodayNewLead.put(ld.ownerId, count + 1);
                            } else{
                                mapofMemidByTodayNewLead.put(ld.ownerId, 1);
                            }
                        }
                    }
                }
            }

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
           // HandleBusinessException.captureError('BuildMaps', 'validateUserCapacity', e, null);

        }
    }

    public static map<String, integer> createMapMemidForAssignedLead(lead ld, map<String, integer> mapofMemidByAssignedLeadofExistingMap){

        try{
            if (mapofMemidByAssignedLeadofExistingMap != null){
                if (mapofMemidByAssignedLeadofExistingMap.containsKey(ld.ownerId)){
                    integer count = mapofMemidByAssignedLeadofExistingMap.get(ld.ownerId);
                    mapofMemidByAssignedLeadofExistingMap.put(ld.ownerId, count + 1);
                } else{
                    mapofMemidByAssignedLeadofExistingMap.put(ld.ownerId, 1);
                }

            } else{
                mapofMemidByAssignedLeadofExistingMap.put(ld.ownerId, 1);
            }


        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            //HandleBusinessException.captureError('BuildMaps', 'createMapMemidForAssignedLead', e, null);

        }
        System.debug('mapofMemidByAssignedLeadofExistingMap ====> ' + mapofMemidByAssignedLeadofExistingMap);
        return mapofMemidByAssignedLeadofExistingMap;
    }

    public static void makeAllMemberOOF(){
        try{
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            agmList = [select id, Out_Of_Office__c
                       from Assignment_Group_Member__c
                       where active__c = true and Out_Of_Office__c = false];
            if (!agmList.isEmpty()){
                for (Assignment_Group_Member__c agm : agmList){
                    agm.Out_Of_Office__c = true;
                }

                update agmList;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'makeAllMemberOOF', e, null);
            
        }
    }
    public static string processAGMId(string assignmentGroupId, integer lastAllocatedRRId){
        // as per the assignemtn group name , last allocated rr id and max lead capacity and return agm Id to which lead is going to assign
        system.debug('assignmentGroupId-->'+assignmentGroupId);
        system.debug('lastAllocatedRRId--->'+lastAllocatedRRId);
            
        set<id> userIds = new Set<Id>();
        List<Lead> leadListAssignedToday = new List<Lead>();
        Map<String, integer> leadOwnerByLeadsAssignedToday = new Map<String, Integer>();
        Map<String, integer> finalleadOwnerByLeadsAssignedToday = new Map<String, Integer>();
        string assignmentGroupMemberIdToAssignLead = '';
        List<Assignment_Group_Member__c> agmByLastRRidInASCOrder = new List<Assignment_Group_Member__c>();
        List<Assignment_Group_Member__c> dummyAGMlist = new List<Assignment_Group_Member__c>();
        
        List<Assignment_Group_Member__c> agmList = [Select Id,Max_Lead_Per_Day__c,Group_Member__c,Assignment_Id__c From Assignment_Group_Member__c where Assignment_Group__c =: assignmentGroupId order by Assignment_Id__c Asc]; //and Assignment_Id__c >=: lastAllocatedRRId 
        system.debug('agmList-->'+agmList);
        if(!agmList.isEmpty()){
            for(Assignment_Group_Member__c agmRec : agmList){
                userIds.add(agmRec.Group_Member__c);
                if(lastAllocatedRRId == agmList.size()){
                    if(lastAllocatedRRId == agmRec.Assignment_Id__c){
                        agmByLastRRidInASCOrder.add(agmRec);
                    }else{
                        dummyAGMlist.add(agmRec);
                    }
                }else{
                    if(lastAllocatedRRId <= agmRec.Assignment_Id__c){
                        agmByLastRRidInASCOrder.add(agmRec);
                    }else{
                        dummyAGMlist.add(agmRec);
                    }
                }
            }
            system.debug('agmByLastRRidInASCOrder--->'+agmByLastRRidInASCOrder);
            system.debug('dummyAGMlist-->'+dummyAGMlist);
            system.debug('userIds--->'+userIds);
            
            if(!dummyAGMlist.isEmpty())
                agmByLastRRidInASCOrder.addAll(dummyAGMlist);
            system.debug('agmByLastRRidInASCOrder--->'+agmByLastRRidInASCOrder);
            if(!userIds.isEmpty()){
                leadListAssignedToday = [Select Id,OwnerId from Lead where OwnerId in : userIds and Lead_Assigned_Date__c = today];
                system.debug('leadListAssignedToday--->'+leadListAssignedToday);
                if(!leadListAssignedToday.isEmpty()){
                    for(Lead leadRec : leadListAssignedToday){
                        if(leadOwnerByLeadsAssignedToday.containsKey(leadRec.OwnerId)){
                            leadOwnerByLeadsAssignedToday.put(leadRec.OwnerId, leadOwnerByLeadsAssignedToday.get(leadRec.OwnerId) + 1);
                        }else{
                            leadOwnerByLeadsAssignedToday.put(leadRec.OwnerId, 1);
                        }
                    }
                }
                for(Id userId : userIds){
                    if(leadOwnerByLeadsAssignedToday.containsKey(userId)){
                        finalleadOwnerByLeadsAssignedToday.put(userId, finalleadOwnerByLeadsAssignedToday.get(userId));
                    }else{
                        finalleadOwnerByLeadsAssignedToday.put(userId, 0);
                    }
                }
                if(!finalleadOwnerByLeadsAssignedToday.isEmpty()){
                    
                    if(!finalleadOwnerByLeadsAssignedToday.isEmpty()){
                        for(Assignment_Group_Member__c agmRec : agmList){
                            system.debug('finalleadOwnerByLeadsAssignedToday.get(agmRec.Group_Member__c)-->'+finalleadOwnerByLeadsAssignedToday.get(agmRec.Group_Member__c));
                            system.debug('agmRec.Max_Lead_Per_Day__c-->'+agmRec.Max_Lead_Per_Day__c);
                                
                            if(finalleadOwnerByLeadsAssignedToday.get(agmRec.Group_Member__c) < agmRec.Max_Lead_Per_Day__c){
                                assignmentGroupMemberIdToAssignLead = agmRec.Id;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return assignmentGroupMemberIdToAssignLead;
    }
}