public without sharing class RoundRobinLeadAssignment{
    public static boolean reccuringTrigger = true;
    public static string groupName = '';
    public static map<string, string> mapofCouseByGroupName = new map<string, string>();
    @future
    public static void assignLeadsToBDS(String courseName, set<String> leadIdList){
        
        System.debug('courseName ===> ' + courseName);
        System.debug('leadIdList ===> ' + leadIdList);
        try{
            boolean withinWorkingHour = false;
            string queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = 'Excelr Default Queue'
                              limit 1].Id;
            List<lead> updateLeadList = new List<lead>();
            List<lead> DefaultQueueLeadList = new List<lead>();
            List<Assignment_Group__c> QtoBeUpdated = new List<Assignment_Group__c>();
            Map<String, List<String>> QueueNameToQmemberIdList = new Map<String, List<String>>();
            Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();
            Map<String, List<Lead>> qNameToListOfLeadsMap = new map<String, List<lead>>();
            Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
            Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
            Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
          
            
            Assignment_Group__c ag = [select id,Name,Last_Allocated_RRid__c,(select id from Assignment_Group_Members__r) from Assignment_Group__c where name =: courseName for update];
            integer lastRRIdFinal = 0;
             
            if(ag.Assignment_Group_Members__r.size() != ag.Last_Allocated_RRid__c){
                lastRRIdFinal = Integer.valueOf(ag.Last_Allocated_RRid__c);//2
            }
            System.debug('lastRRIdFinal before while ===> ' + lastRRIdFinal);
            
            BuildMaps.mapsForUserCapacity(courseName);
            System.debug('BuildMaps.mapofOwnerIdByTodaysLeadAssignedCount  ===> ' + BuildMaps.mapofOwnerIdByTodaysLeadAssignedCount);
            Boolean continueFlag = true;
            integer RR_Iteration = 0;
            While(continueFlag){
                system.debug('continueFlag-->'+continueFlag);
                system.debug('RR_Iteration-->'+RR_Iteration);  
                system.debug('lastRRIdFinal-->'+lastRRIdFinal);  
                
                RR_Iteration = RR_Iteration + 1;
                if(RR_Iteration <= ag.Assignment_Group_Members__r.size()){
                   system.debug('Inside If');
                    lastRRIdFinal = lastRRIdFinal + 1;
                    if(lastRRIdFinal > ag.Assignment_Group_Members__r.size()){
                        system.debug('inside reintializing rrid to 1');
                        lastRRIdFinal = 1;
                    }
                    system.debug('BuildMaps.mapofOwnerIdByTodaysLeadAssignedCount.get(BuildMaps.mapofAllocatedIdByOwnerId.get(string.valueOf(lastRRIdFinal)))-->'+BuildMaps.mapofOwnerIdByTodaysLeadAssignedCount.get(BuildMaps.mapofAllocatedIdByOwnerId.get(string.valueOf(lastRRIdFinal))));
                    system.debug('BuildMaps.mapofAllocatedIdByMaxLeadCap.get(string.valueOf(lastRRIdFinal))--->'+BuildMaps.mapofAllocatedIdByMaxLeadCap.get(string.valueOf(lastRRIdFinal)));
                    if(BuildMaps.mapofOwnerIdByTodaysLeadAssignedCount.get(BuildMaps.mapofAllocatedIdByOwnerId.get(string.valueOf(lastRRIdFinal))) == null ){
                        continueFlag = false;
                    }
                    else if(integer.valueOf(BuildMaps.mapofOwnerIdByTodaysLeadAssignedCount.get(BuildMaps.mapofAllocatedIdByOwnerId.get(string.valueOf(lastRRIdFinal)))) < integer.valueOf(BuildMaps.mapofAllocatedIdByMaxLeadCap.get(string.valueOf(lastRRIdFinal)))){
                        system.debug('check max cap');
                        continueFlag = false;
                    } 
                }else{
                    system.debug('Return');
                    return;
                }
            }
                /*if(lastRRIdFinal > ag.Assignment_Group_Members__r.size()){
//lastRRIdFinal = lastRRIdFinal + 1;
continueFlag = false;
//if(lastRRIdFinal > ag.Assignment_Group_Members__r.size()){
//     continueFlag = false;
//     lastRRIdFinal = 0;

// }
return;
}*/
            
            System.debug('lastRRIdFinal before while ===> ' + lastRRIdFinal);

            Assignment_Group_Member__c agmTemp= [select id,Group_Member__c from Assignment_Group_Member__c where Assignment_Id__c =: lastRRIdFinal and Assignment_Group__c =:ag.Id];
            system.debug('agmTemp::'+agmTemp);
            // ================================================= for Application Creation ========================================================
            Map<Id, Lead> LeadListMap = new Map<Id, Lead>();
            List<Application__c> ApplicationTobeInserted = new List<Application__c>();
            
            String Assignee = '';
            If (leadIdList.size() > 0){
                List<Lead> LeadData = [SELECT ID, Lead_Assigned_Date__c, OWNERID, Status, Course__c
                                       FROM Lead
                                       WHERE id IN:leadIdList
                                       limit 50000];
                qNameToListOfLeadsMap.put(courseName, LeadData);
            }
            QueueNameToQmemberIdList = makeCustomQueueNameToListOfUserId(courseName);
            userIdToUserAvailablityMap = makeuserIdToUserAvailablityMap(courseName);
            qNameToLastAssignedQmemberRRid = BuildMaps.makeQNameToLastAssignedQmemberRRid();
            QnameAndRRidToMemberIDMap = makeQnameAndRRidToMemberID(courseName);
            BuildMaps.validateUserCapacity(courseName, leadIdList);
            String finalMemberId = '';
            for (String qName : qNameToListOfLeadsMap.keySet()){
                System.debug('qName ====> ' + qName);
                if (qName != null){
                    for (lead ld : qNameToListOfLeadsMap.get(qName)){
                        LeadListMap.put(ld.id, ld);
                        System.debug('ld =====> ' + ld.id);
                        Boolean isAssigned = false;
                        Integer qMemberSize = 1;
                        While (QueueNameToQmemberIdList != null && qMemberSize != null && QueueNameToQmemberIdList.get(qName) != null && isAssigned == false && qMemberSize <= QueueNameToQmemberIdList.get(qName).size()){
                            Assignee = QueueNameToQmemberIdList.get(qName)[0];
                            Integer currentRRid, LastRRid = lastRRIdFinal;
                            String QnameAndRRid, qMemberID;
                            if (qNameToLastAssignedQmemberRRid.get(qName) != null)
                                LastRRid = qNameToLastAssignedQmemberRRid.get(qName);
                            if (LastRRid == null || LastRRid < 1){
                                qNameToLastAssignedQmemberRRid.remove(qName);
                                qNameToLastAssignedQmemberRRid.put(qName, 0);
                                currentRRid = 1;
                            }
                            if (LastRRid < QueueNameToQmemberIdList.get(qName).size()){
                                currentRRid = LastRRid + 1;
                            } else{
                                currentRRid = 1;
                                LastRRid = 0;
                            }
                            QnameAndRRid = qName + String.valueOf(currentRRid);
                            qMemberID = QnameAndRRidToMemberIDMap.get(QnameAndRRid);
                            boolean flagConsideration = true;
                            if(flagConsideration){
                                if(flagConsideration){
                                    // if (assignmentConditionSatisfied(qName, qMemberID, '123', courseName )){
                                    //    if (userIdToUserAvailablityMap.get(qMemberID) == true){
                                    finalMemberId = Id.valueOf(qMemberID);
                                    ld.ownerId = agmTemp.Group_Member__c;
                                    ld.Lead_Assigned_Date__c = system.today();
                                    ld.Lead_Assigned_Date_TIme__c = system.now();
                                    ld.Lead_Assigned_Time__c = Time.newInstance(Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second(), 0);
                                    ld.status = 'Open';
                                    ld.Assignment_Group__c = qName;
                                    if (BuildMaps.mapofAssignGroupNameById.get(qName) != null) {
                                        ld.AG_related_to__c = BuildMaps.mapofAssignGroupNameById.get(qName);                                        
                                    }
                                    ld.Is_Lead_Assigned_to_User__c = true;
                                    ld.Next_follow_up_date_time__c = system.now().addHours(2);
                                    updateLeadList.add(ld);
                                    System.debug('updateLeadList ====> ' + updateLeadList);
                                    isAssigned = true;
                                    if (BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID, BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByTodayLeadCount ===> ' + BuildMaps.mapofMemidByTodayLeadCount);
                                    
                                    if (BuildMaps.mapofMemidByPendingLeads.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByPendingLeads.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByPendingLeads.put(qMemberID, BuildMaps.mapofMemidByPendingLeads.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByPendingLeads =====> ' + BuildMaps.mapofMemidByPendingLeads);
                                    
                                    if (BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByTodayNewLead.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByTodayNewLead.put(qMemberID, BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByTodayNewLead ======> ' + BuildMaps.mapofMemidByTodayNewLead);
                                    
                                    if (BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByAssignedLead.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByAssignedLead.put(qMemberID, BuildMaps.mapofMemidByAssignedLead.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByAssignedLead =====> ' + BuildMaps.mapofMemidByAssignedLead);
                                    if (BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.put(qMemberID, BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByMaxLeadPerMonthFromUser ======> ' + BuildMaps.mapofMemidByMaxLeadPerMonthFromUser);
                                    
                                    if (BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByMaxLeadPerDayFromAG.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByMaxLeadPerDayFromAG.put(qMemberID, BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByMaxLeadPerDayFromAG ====> ' + BuildMaps.mapofMemidByMaxLeadPerDayFromAG);
                                    
                                    if (BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null)
                                        BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);
                                    BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) + 1);
                                    System.debug('BuildMaps.mapofMemidByLeadsAssignedInThisTransaction =====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction);
                                    
                                    
                                    System.debug('BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.get(qName) ====> ' + BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.get(qName));
                                    
                                    if (BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.get(qName) != null ) {
                                        map<String, Integer> MapofMemberIdWithLeadAssigned = BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.get(qName);
                                        if (MapofMemberIdWithLeadAssigned.containsKey(qMemberID) ) {
                                            if (Integer.valueOf(MapofMemberIdWithLeadAssigned.get(qMemberID)) == 0) {
                                                MapofMemberIdWithLeadAssigned.put(qMemberID, 1);
                                            }
                                            else if(Integer.valueOf(MapofMemberIdWithLeadAssigned.get(qMemberID)) > 0){
                                                integer leadAssignedCount = Integer.valueOf(MapofMemberIdWithLeadAssigned.get(qMemberID)) + 1;
                                                MapofMemberIdWithLeadAssigned.put(qMemberID,leadAssignedCount );
                                                
                                            }
                                            
                                        }
                                        else if(!MapofMemberIdWithLeadAssigned.containsKey(qMemberID)){
                                            MapofMemberIdWithLeadAssigned.put(qMemberID,1 );
                                        }
                                        BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.put(qName, MapofMemberIdWithLeadAssigned);
                                    }
                                    
                                } else{
                                    ld.OwnerId = queueId;
                                    DefaultQueueLeadList.add(ld);
                                }
                                LastRRid = LastRRid + 1;
                                qNameToLastAssignedQmemberRRid.remove(qName);
                                qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                                qMemberSize++;
                            } else{
                                LastRRid = LastRRid + 1;
                                qNameToLastAssignedQmemberRRid.remove(qName);
                                qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                                qMemberSize++;
                                ld.OwnerId = queueId;
                                DefaultQueueLeadList.add(ld);
                            }
                        }
                    }
                }
            }
            
            System.debug('qNameToLastAssignedQmemberRRid ====> ' + qNameToLastAssignedQmemberRRid);
            
            if (!qNameToLastAssignedQmemberRRid.keySet().isEmpty()){
                List<Assignment_Group__c> updateQrId = new List<Assignment_Group__c>();
                updateQrId = [Select id, name, Last_Allocated_RRid__c
                              from Assignment_Group__c
                              where Name IN:qNameToLastAssignedQmemberRRid.keySet()];
                for (Assignment_Group__c Q : updateQrId){
                    Q.Last_Allocated_RRid__c = qNameToLastAssignedQmemberRRid.get(Q.Name);
                    QtoBeUpdated.add(q);
                }
            }
            
            System.debug('updateLeadList ====> ' + updateLeadList);
            if (!updateLeadList.isEmpty()){
                reccuringTrigger = false;
                try{
                    //update updateLeadList;
                    
                    Database.SaveResult[] results = Database.update (updateLeadList, false);
                    // Iterate SaveResult array
                    for (Database.SaveResult result : results){
                        if (result.isSuccess()){
                            ApplicationTobeInserted.add(Utility.createApplicationInstanceForLead(LeadListMap.get(result.getId()), null));
                            
                            System.debug('Lead Successfully Updated, Lead Id is: ' + result.getId());
                        } else{
                            //Error ecountered
                            for (Database.Error error : result.getErrors()){
                                //Handle error
                                System.debug(error.getStatusCode() + ': ' + error.getMessage() + ' Fields that affected the error: ' + error.getFields());
                                
                            }
                        }
                    }
                    
                    if (!ApplicationTobeInserted.isEmpty()) {
                        insert ApplicationTobeInserted;
                        
                    }
                    
                } catch (exception e){
                    System.debug(' the Error has occured due to =====> ' + e.getMessage());
                    System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
                    HandleBusinessException.captureError('RoundRobinLeadAssignment', 'assignLeadsToBDS', e, null);
                }
            }
            System.debug('QtoBeUpdated ====> ' + QtoBeUpdated);
            if (!QtoBeUpdated.isEmpty()){
                Update QtoBeUpdated;
            }
            
            System.debug('DefaultQueueLeadList ====> ' + DefaultQueueLeadList);
            if (!DefaultQueueLeadList.isEmpty()){
                Set<Lead> myset = new Set<Lead>();
                List<Lead> result = new List<Lead>();
                myset.addAll(DefaultQueueLeadList);
                result.addAll(myset);
                update result;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RoundRobinLeadAssignment', 'assignLeadsToBDS', e, null);
            
        }
    }
    
    public static boolean assignmentConditionSatisfied(string qName, string qMemberID, string learnerUid, String courseName){
        System.debug('courseName ===> ' + courseName);
        try{
            boolean isconditionapproved = false;
            
            if (BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null){
                isconditionapproved = true;
            } else{
                
                System.debug('BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) ======> ' + BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) + 'BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID) ======> ' + BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID));
                if (BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) != null && BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID) < BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID)){
                    
                    System.debug('BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) ======> ' + BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) + 'BuildMaps.mapofMemidByAssignedLead.get(qMemberID) ======> ' + BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
                    if (BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)){
                        
                        System.debug('BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) ======> ' + BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) + 'BuildMaps.mapofMemidByAssignedLead.get(qMemberID) ======> ' + BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
                        
                        System.debug('BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead =======> ' + BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead);
                        map<String, Integer> mapofMemidByAssignedLeadToday = new map<String, Integer>();
                        mapofMemidByAssignedLeadToday = BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.get(courseName);
                        System.debug('mapofMemidByAssignedLeadToday ======> ' + mapofMemidByAssignedLeadToday);
                        if ( mapofMemidByAssignedLeadToday != null) {
                            
                            if (BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) != null && mapofMemidByAssignedLeadToday.get(qMemberID) < BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID)){
                                
                                System.debug('BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) ======> ' + BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) + 'mapofMemidByAssignedLeadToday.get(qMemberID) ======> ' + mapofMemidByAssignedLeadToday.get(qMemberID));
                                if (BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) != null && mapofMemidByAssignedLeadToday.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)){
                                    
                                    System.debug('BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) ====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));
                                    if (BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null){
                                        BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);
                                        
                                    }
                                    
                                    System.debug('BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) =====> ' + BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) + 'BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) =====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));
                                    
                                    if (BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) != null && BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) < BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID)){
                                        
                                        isconditionapproved = true;
                                    }
                                }
                            }    
                        }
                        else {
                            map<String, Integer> NewmapofMemidByAssignedLeadToday = new map<String, Integer>();
                            NewmapofMemidByAssignedLeadToday.put(qMemberID, 0);
                            BuildMaps.mapofAGIdWithMapOfMemIdAssignedLead.put(courseName, NewmapofMemidByAssignedLeadToday);
                            if (BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) != null && NewmapofMemidByAssignedLeadToday.get(qMemberID) < BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID)){
                                if (BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) != null && NewmapofMemidByAssignedLeadToday.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)){
                                    
                                    System.debug('BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) ====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));
                                    if (BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null){
                                        BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);
                                    }
                                    
                                    System.debug('BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) =====> ' + BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) + 'BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) =====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));
                                    
                                    if (BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) != null && BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) < BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID)){
                                        
                                        isconditionapproved = true;
                                    }
                                }
                            }
                            
                        }
                        /*if (BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID)){

System.debug('BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) ======> ' + BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) + 'BuildMaps.mapofMemidByAssignedLead.get(qMemberID) ======> ' + BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
if (BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)){

System.debug('BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) ====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));
if (BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null){
BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);

}

System.debug('BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) =====> ' + BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) + 'BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) =====> ' + BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));

if (BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) != null && BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) < BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID)){

isconditionapproved = true;
}
}
}*/
                    }
                }
            }
            
            return isconditionapproved;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            //HandleBusinessException.captureError('RoundRobinLeadAssignment', 'assignmentConditionSatisfied', e, null);
            return null;
        }
    }
    
    public static map<String, List<lead>> makeQueueNameToListOfAssignedLeadsMap(string courseName, set<String> leadId){
        try{
            
            map<String, string> sourceIntentByGroupMap = new map<String, String>();
            Map<String, List<lead>> groupNameByLeads = new Map<String, List<lead>>();
            List<Lead> leadsInQueue = [SELECT ID, Lead_Assigned_Date__c, OWNERID, Status
                                       FROM Lead
                                       WHERE id in:leadId
                                       limit 50000
                                       FOR  UPDATE ];
            
            if (!leadsInQueue.isEmpty()){
                for (Lead ld : leadsInQueue){
                    if (ld.status != null){
                        if (groupNameByLeads.containsKey(courseName)){
                            groupNameByLeads.get(courseName).add(ld);
                        } else{
                            groupNameByLeads.put(courseName, new List<lead>{ ld });
                        }
                    }
                }
            }
            return groupNameByLeads;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeQueueNameToListOfAssignedLeadsMap', e, null);
            return null;
        }
    }
    
    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(string assignmentGroupName){
        
        System.debug('assignmentGroupName ====> ' + assignmentGroupName);
        try{
            Map<String, List<String>> customQueueNameToListOfUserId = new Map<String, List<String>>();
            List<Assignment_Group__c> queueWithQueueMembers = new List<Assignment_Group__c>();
            Map<String, Id> queueNameToQueueIdMap = new Map<String, Id>();
            List<Assignment_Group__c> listOfExistingQueue = new List<Assignment_Group__c>();
            listOfExistingQueue = [select id, name, Max_Lead_Per_Day__c
                                   from Assignment_Group__c];
            List<Assignment_Group_Member__c> listOfExistingQueueMembers = new List<Assignment_Group_Member__c>();
            listOfExistingQueueMembers = [select id, name, Out_Of_Office__c, Assignment_Group__c, Assignment_Group__r.name, Assignment_Id__c, Leave_End_Date__c, Leave_Start_Date__c, Group_Member__c, Group_Member__r.Id
                                          from Assignment_Group_Member__c
                                          where Assignment_Group__r.name = :assignmentGroupName AND Active__c = true];
            Set<Id> existingQueueMembersQueueId = new Set<Id>();
            
            System.debug('listOfExistingQueueMembers ===> ' + listOfExistingQueueMembers);
            if (!listOfExistingQueueMembers.isEmpty()){
                for (Assignment_Group_Member__c agm : listOfExistingQueueMembers){
                    if (customQueueNameToListOfUserId.containsKey(agm.Assignment_Group__r.name)){
                        customQueueNameToListOfUserId.get(agm.Assignment_Group__r.name).add(agm.Group_Member__r.Id);
                    } else{
                        customQueueNameToListOfUserId.put(agm.Assignment_Group__r.name, new list<string>{ agm.Group_Member__r.Id });
                    }
                }
            }
            return customQueueNameToListOfUserId;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeCustomQueueNameToListOfUserId', e, null);
            return null;
        }
    }
    
    public static Map<String, Boolean> makeuserIdToUserAvailablityMap(string assignmentGroupName){
        try{
            Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();
            List<Assignment_Group_Member__c> agentAvailablity = new List<Assignment_Group_Member__c>();
            agentAvailablity = [select id, Out_Of_Office__c, Group_Member__r.Id, Assignment_Group__r.name
                                from Assignment_Group_Member__c
                                where Assignment_Group__r.name = :assignmentGroupName and Out_Of_Office__c = false AND Active__c = true];
            
            for (Assignment_Group_Member__c Aa : agentAvailablity){
                userIdToUserAvailablityMap.put(aa.Group_Member__r.Id, true);
            }
            return userIdToUserAvailablityMap;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeuserIdToUserAvailablityMap', e, null);
            return null;
        }
    }
    
    public static Map<String, Integer> makeqNameAndMemberIdTORoundRobinIDMaP(String groupName){
        try{
            Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            agmList = [select id, Assignment_Group__r.name, Assignment_Id__c, Group_Member__r.Id
                       from Assignment_Group_Member__c
                       where Assignment_Group__r.name = :groupName AND Active__c = true ];
            
            if (!agmList.isEmpty()){
                for (Assignment_Group_Member__c agm : agmList){
                    String qName = agm.Assignment_Group__r.name;
                    String qMember = agm.Group_Member__r.Id;
                    if (!string.isBlank(qName) && !String.isBlank(qMember)){
                        String qNameAndQmamber = qName + qMember;
                        qNameAndMemberIdTORoundRobinIDMaP.put(qNameAndQmamber, Integer.valueOf(agm.Assignment_Id__c));
                    }
                }
            }
            return qNameAndMemberIdTORoundRobinIDMaP;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeqNameAndMemberIdTORoundRobinIDMaP', e, null);
            return null;
        }
    }
    
    public static Map<String, String> makeQnameAndRRidToMemberID(String groupName){
        try{
            Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            agmList = [select id, Assignment_Group__r.name, Assignment_Id__c, Group_Member__r.Id, Out_Of_Office__c
                       from Assignment_Group_Member__c
                       where Assignment_Group__r.name = :groupName and Out_Of_Office__c = false AND Active__c = true];
            if (!agmList.isEmpty()){
                for (Assignment_Group_Member__c agm : agmList){
                    String qName = agm.Assignment_Group__r.name;
                    String qMember = string.valueOf(agm.Assignment_Id__c);
                    if (!string.isBlank(qName) && !String.isBlank(qMember)){
                        String qNameAndQmamber = qName + qMember;
                        QnameAndRRidToMemberIDMap.put(qNameAndQmamber, String.valueOf(agm.Group_Member__r.Id));
                    }
                }
            }
            return QnameAndRRidToMemberIDMap;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeQnameAndRRidToMemberID', e, null);
            return null;
        }
    }
    
}