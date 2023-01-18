public without sharing class RoundRobinLeadAssignment{
    
    public static boolean reccuringTrigger = true;
    public static string groupName = '';
    public static set<String> leadIds = new Set<String>();
    public static map<string, string> mapofCouseByGroupName = new map<string, string>();
    
    public static void assignLeadsToBDS(String qualityOfLead, List<Lead> leadsListToBeAssigned){
        system.debug('qualityOfLead::' + qualityOfLead);
        system.debug('leadsListToBeAssigned::' + leadsListToBeAssigned.size());
        boolean withinWorkingHour = false;
        List<lead> updateLeadList = new List<lead>();
        List<Assignment_Group__c> QtoBeUpdated = new List<Assignment_Group__c>();
        Map<String, List<String>> QueueNameToQmemberIdList = new Map<String, List<String>>();
        Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();
        Map<String, List<Lead>> qNameToListOfLeadsMap = new map<String, List<lead>>();
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
        Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        map<string, integer> mapofMemidByMaxLeadPerMonthFromUser = new map<string, integer>();
        
        qNameToListOfLeadsMap = makeQueueNameToListOfAssignedLeadsMap(qualityOfLead, leadsListToBeAssigned);//Group wise leads based on source intent
        system.debug('mapofCouseByGroupName::' + mapofCouseByGroupName);
        QueueNameToQmemberIdList = makeCustomQueueNameToListOfUserId(mapofCouseByGroupName.get(qualityOfLead)); // group by group member
        userIdToUserAvailablityMap = makeuserIdToUserAvailablityMap(mapofCouseByGroupName.get(qualityOfLead)); // group by group member availability
        
        qNameToLastAssignedQmemberRRid = BuildMaps.makeQNameToLastAssignedQmemberRRid(); // qname with last allocated ID
        system.debug('qNameToLastAssignedQmemberRRid-->' + qNameToLastAssignedQmemberRRid);
        QnameAndRRidToMemberIDMap = makeQnameAndRRidToMemberID(mapofCouseByGroupName.get(qualityOfLead)); // qname with qname+rrid
        BuildMaps.validateUserCapacity(mapofCouseByGroupName.get(qualityOfLead), qualityOfLead);
        
        system.debug('BuildMaps.mapofMemIdByExceedCount::' + BuildMaps.mapofMemIdByExceedCount);//member id with exceed count
        system.debug('BuildMaps.mapofMemidByTodayLeadCount::' + BuildMaps.mapofMemidByTodayLeadCount);//member id with today's lead count
        system.debug('BuildMaps.mapofMemIdByMaxLeadCountPerDay::' + BuildMaps.mapofMemIdByMaxLeadCountPerDay);// member id with max lead count per day(AGM)
        system.debug('BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay::' + BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay);// member id with max lead count per day(GM)
        system.debug('BuildMaps.mapofMemidbyMaxleadCountFromUser::' + BuildMaps.mapofMemidbyMaxleadCountFromUser);//member id with max lead count from user
        system.debug('BuildMaps.mapofMemidByPendingLeads::' + BuildMaps.mapofMemidByPendingLeads);//member id with new leads count.
        
        for (String qName : qNameToListOfLeadsMap.keySet()){
            system.debug('qName---' + qName);
            if (qName != null){
                for (lead ld : qNameToListOfLeadsMap.get(qName)){
                    Boolean isAssigned = false;
                    Integer qMemberSize = 1;
                    system.debug('QueueNameToQmemberIdList::' + QueueNameToQmemberIdList);
                    system.debug('QueueNameToQmemberIdList.get(qName)::' + QueueNameToQmemberIdList.get(qName));
                    system.debug('qMemberSize-->' + qMemberSize);
                    system.debug('QueueNameToQmemberIdList.get(qName).size()-->' + QueueNameToQmemberIdList.get(qName).size());
                    While (QueueNameToQmemberIdList != null && qMemberSize != null && QueueNameToQmemberIdList.get(qName) != null && isAssigned == false && qMemberSize <= QueueNameToQmemberIdList.get(qName).size()){
                        Integer currentRRid, LastRRid;
                        String QnameAndRRid, qMemberID;
                        if (qNameToLastAssignedQmemberRRid.get(qName) != null)
                            LastRRid = qNameToLastAssignedQmemberRRid.get(qName);
                        System.debug('LastRRid-------+++++' + LastRRid);
                        if (LastRRid == null || LastRRid < 1){
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, 0);
                            currentRRid = 1;
                            System.debug('Inside 1  currentRRid' + currentRRid);
                        }
                        system.debug('LastRRid::' + LastRRid);
                        system.debug('QueueNameToQmemberIdList.get(qName).size()::' + QueueNameToQmemberIdList.get(qName).size());
                        if (LastRRid < QueueNameToQmemberIdList.get(qName).size()){
                            currentRRid = LastRRid + 1;
                            System.debug('Inside 2  currentRRid' + currentRRid);
                        } else{
                            currentRRid = 1;
                            LastRRid = 0;
                            System.debug('Inside 3  currentRRid' + currentRRid);
                        }
                        QnameAndRRid = qName + String.valueOf(currentRRid);
                        system.debug('QnameAndRRid::' + QnameAndRRid);
                        system.debug('QnameAndRRidToMemberIDMap::' + QnameAndRRidToMemberIDMap);
                        qMemberID = QnameAndRRidToMemberIDMap.get(QnameAndRRid);
                        System.debug('QnameAndRRid::' + QnameAndRRid);
                        System.debug('qMemberID::' + qMemberID);
                        boolean test = true;
                        if (assignmentConditionSatisfied(qName, qMemberID)){
                            //qName,qMemberID,userIdbyLeadcount,ld.Learner_Uid__c,assignmentConditionSatisfied(true)
                            system.debug('userIdToUserAvailablityMap.get(qMemberID):' + userIdToUserAvailablityMap.get(qMemberID));
                            if (userIdToUserAvailablityMap.get(qMemberID) == true){
                                system.debug('inside avaibility');
                                ld.ownerId = Id.valueOf(qMemberID);
                                if (ld.Lead_Assigned_Date__c == null){
                                    ld.Lead_Assigned_Date__c = system.today();
                                }
                                if (ld.Lead_Assigned_Time__c == null){
                                    ld.Lead_Assigned_Time__c = Time.newInstance(Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second(), 0);
                                }
                                updateLeadList.add(ld);
                                isAssigned = true;
                                //BuildMaps.memberIdbypendingLeadCount.put(qMemberID,BuildMaps.memberIdbypendingLeadCount.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID, 0);
                                BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID, BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByPendingLeads.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByPendingLeads.put(qMemberID, 0);
                                BuildMaps.mapofMemidByPendingLeads.put(qMemberID, BuildMaps.mapofMemidByPendingLeads.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByTodayNewLead.put(qMemberID, 0);
                                BuildMaps.mapofMemidByTodayNewLead.put(qMemberID, BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByAssignedLead.put(qMemberID, 0);
                                BuildMaps.mapofMemidByAssignedLead.put(qMemberID, BuildMaps.mapofMemidByAssignedLead.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByLeadAssignedThisMonth.put(qMemberID, 0);
                                BuildMaps.mapofMemidByLeadAssignedThisMonth.put(qMemberID, BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);
                                BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) + 1);
                                
                            }
                            LastRRid = LastRRid + 1;
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                            System.debug('qNameToLastAssignedQmemberRRid::' + qNameToLastAssignedQmemberRRid);
                            qMemberSize++;
                            system.debug('qMemberSize::' + qMemberSize);
                        } else{
                            LastRRid = LastRRid + 1;
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                            qMemberSize++;
                        }
                    }
                }
            }
        }
        system.debug('qNameToLastAssignedQmemberRRid.keySet().isEmpty()-->' + qNameToLastAssignedQmemberRRid.keySet().isEmpty());
        if (!qNameToLastAssignedQmemberRRid.keySet().isEmpty()){
            system.debug('Inside Last RRId');
            List<Assignment_Group__c> updateQrId = new List<Assignment_Group__c>();
            updateQrId = [Select id, name, Last_Allocated_RRid__c, Name__c
                          from Assignment_Group__c
                          where Name__c IN:qNameToLastAssignedQmemberRRid.keySet()];
            system.debug('updateQrId-->' + updateQrId);
            for (Assignment_Group__c Q : updateQrId){
                Q.Last_Allocated_RRid__c = qNameToLastAssignedQmemberRRid.get(Q.Name__c);
                system.debug('Q.Last_Allocated_RRid__c -->' + Q.Last_Allocated_RRid__c);
                QtoBeUpdated.add(q);
            }
            system.debug('QtoBeUpdated-->' + QtoBeUpdated);
        }
        System.debug('updateLeadList---' + updateLeadList);
        if (!updateLeadList.isEmpty()){
            reccuringTrigger = false;
            update updateLeadList;
        }
        
        if (!QtoBeUpdated.isEmpty())
            Update QtoBeUpdated;
    }
    
    public static boolean assignmentConditionSatisfied(string qName, string qMemberID){
        system.debug('qName-->' + qName);
        system.debug('qMemberID-->' + qMemberID);
        boolean isconditionapproved = false;
        if (qMemberID == null){
            return false;
        }
        system.debug('BuildMaps.mapofMemidByAssignedLead.get(qMemberID)--->' + BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
        system.debug('BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)--->' + BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID));
        if (BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null){
            system.debug('Inside If');
            isconditionapproved = true;
        } else{
            system.debug('BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID)--->'+BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID));
            system.debug('BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID)--->'+BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID));
            if (BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) != null && BuildMaps.mapofMemidByLeadAssignedThisMonth.get(qMemberID) < BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID)){
                system.debug('BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)-->'+BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID));
                system.debug('BuildMaps.mapofMemidByAssignedLead.get(qMemberID)--->'+BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
                if (BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)){
                    system.debug('BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID)--->'+BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID));
                    if (BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID)){
                        system.debug('BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)--->'+BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID));
                        if (BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)){
                            System.debug('BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID)-->'+BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID));
                            system.debug('BuildMaps.mapofMemidByAssignedLead.get(qMemberID)-->'+BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
                            if(BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID)){
                                system.debug('Finally inside true');
                                isconditionapproved = true;
                            }
                        }
                    }
                }
            } else{
                isconditionapproved = false;
            }
        }
        
        system.debug('isconditionapproved::' + isconditionapproved);
        return isconditionapproved;
    }
    
    public static map<String, List<lead>> makeQueueNameToListOfAssignedLeadsMap(string qualityOfLead, List<Lead> LeadListToAssign){
        system.debug('qualityOfLead::' + qualityOfLead);
        system.debug('qualityOfLead::' + qualityOfLead);
        map<String, string> sourceIntentByGroupMap = new map<String, String>();
        Map<String, List<lead>> groupNameByLeads = new Map<String, List<lead>>();
        string queueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'Excelr Default Queue'
                          limit 1].Id;
        string groupName = [Select Name, name__c
                            From Assignment_Group__c
                            where name__c = :qualityOfLead
                            limit 1].name__c;
        
        mapofCouseByGroupName.put(groupName, groupName);
        
        // Inserting QueueId and list of case assigned to the queue id into the map:-QueueNameToListOfAssignedCasesMap
        system.debug('LeadListToAssign-->' + LeadListToAssign.size());
        if (!LeadListToAssign.isEmpty()){
            system.debug('inside putting Leads');
            groupNameByLeads.put(qualityOfLead, LeadListToAssign);
            system.debug('groupNameByLeads-->' + groupNameByLeads);
            system.debug('groupNameByLeads.Values()' + groupNameByLeads.values().size());
            for (Lead ld : LeadListToAssign){
                leadIds.add(ld.Id);
            }
        }
        return groupNameByLeads;
    }
    
    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(string assignmentGroupName){
        system.debug('assignmentGroupName-->' + assignmentGroupName);
        Map<String, List<String>> customQueueNameToListOfUserId = new Map<String, List<String>>();
        List<Assignment_Group__c> queueWithQueueMembers = new List<Assignment_Group__c>();
        Map<String, Id> queueNameToQueueIdMap = new Map<String, Id>();
        
        List<Assignment_Group__c> listOfExistingQueue = new List<Assignment_Group__c>();
        listOfExistingQueue = [select id, name, Max_Lead_Per_Day__c
                               from Assignment_Group__c WHERE isActive__c = true];
        List<Assignment_Group_Member__c> listOfExistingQueueMembers = new List<Assignment_Group_Member__c>();
        listOfExistingQueueMembers = [select id, name, Out_Of_Office__c, Assignment_Group__c, Assignment_Group__r.name__c, Assignment_Id__c, Leave_End_Date__c, Leave_Start_Date__c, Group_Member__c, Group_Member__r.Id
                                      from Assignment_Group_Member__c
                                      where Assignment_Group__r.name__c = :assignmentGroupName];
        Set<Id> existingQueueMembersQueueId = new Set<Id>();
        
        if (!listOfExistingQueueMembers.isEmpty()){
            for (Assignment_Group_Member__c agm : listOfExistingQueueMembers){
                if (customQueueNameToListOfUserId.containsKey(agm.Assignment_Group__r.name__c)){
                    customQueueNameToListOfUserId.get(agm.Assignment_Group__r.name__c).add(agm.Group_Member__r.Id);
                } else{
                    customQueueNameToListOfUserId.put(agm.Assignment_Group__r.name__c, new list<string>{ agm.Group_Member__r.Id });
                }
            }
        }
        system.debug('customQueueNameToListOfUserId::' + customQueueNameToListOfUserId);
        return customQueueNameToListOfUserId;
    }
    
    public static Map<String, Boolean> makeuserIdToUserAvailablityMap(string assignmentGroupName){
        //Need to  handle leave
        Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();
        List<Assignment_Group_Member__c> agentAvailablity = new List<Assignment_Group_Member__c>();
        agentAvailablity = [select id, Out_Of_Office__c, Group_Member__r.Id, Assignment_Group__r.name__c
                            from Assignment_Group_Member__c
                            where Assignment_Group__r.name__c = :assignmentGroupName and Out_Of_Office__c = false];
        system.debug('agentAvailablity::' + agentAvailablity);
        for (Assignment_Group_Member__c Aa : agentAvailablity){
            userIdToUserAvailablityMap.put(aa.Group_Member__r.Id, true);
        }
        System.debug('userIdToUserAvailablityMap-----' + userIdToUserAvailablityMap);
        return userIdToUserAvailablityMap;
    }
    
    public static Map<String, Integer> makeqNameAndMemberIdTORoundRobinIDMaP(String groupName){
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        agmList = [select id, Assignment_Group__r.name__c, Assignment_Id__c, Group_Member__r.Id
                   from Assignment_Group_Member__c
                   where Assignment_Group__r.name__c = :groupName];
        
        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name__c;
                String qMember = agm.Group_Member__r.Id;
                if (!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName + qMember;
                    qNameAndMemberIdTORoundRobinIDMaP.put(qNameAndQmamber, Integer.valueOf(agm.Assignment_Id__c));
                }
            }
        }
        return qNameAndMemberIdTORoundRobinIDMaP;
    }
    
    public static Map<String, String> makeQnameAndRRidToMemberID(String groupName){
        //Map<String, Map<String, Integer>> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Map<String, Integer>>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        agmList = [select id, Assignment_Group__r.name__c, Assignment_Id__c, Group_Member__r.Id, Out_Of_Office__c
                   from Assignment_Group_Member__c
                   where Assignment_Group__r.name__c = :groupName and Out_Of_Office__c = false];
        system.debug('agmList::' + agmList);
        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name__c;
                String qMember = string.valueOf(agm.Assignment_Id__c);
                system.debug('qName::' + qName);
                system.debug('qMember::' + qMember);
                if (!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName + qMember;
                    system.debug('qNameAndQmamber::' + qNameAndQmamber);
                    QnameAndRRidToMemberIDMap.put(qNameAndQmamber, String.valueOf(agm.Group_Member__r.Id));
                }
            }
        }
        
        //System.debug('QnameAndRRidToMemberIDMap---'+QnameAndRRidToMemberIDMap);
        return QnameAndRRidToMemberIDMap;
    }
    
}