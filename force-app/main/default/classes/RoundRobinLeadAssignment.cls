public without sharing class RoundRobinLeadAssignment{
    public static boolean reccuringTrigger = true;
    public static string groupName = '';
    public static set<String> leadIds = new Set<String>();
    public static map<string, string> mapofCouseByGroupName = new map<string, string>();
    @future
    public static void assignLeadsToBDS(String courseName){
        system.debug('courseName::' + courseName);
        boolean withinWorkingHour = false;
        List<lead> updateLeadList = new List<lead>();
        List<Assignment_Group__c> QtoBeUpdated = new List<Assignment_Group__c>();
        Map<String, List<String>> QueueNameToQmemberIdList = new Map<String, List<String>>();
        Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();
        Map<String, List<Lead>> qNameToListOfLeadsMap = new map<String, List<lead>>();
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
        Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();

        //withinWorkingHour = BuildMaps.CheckBusinessHours();
        qNameToListOfLeadsMap = makeQueueNameToListOfAssignedLeadsMap(courseName);//Group wise leads based on source intent
        system.debug('mapofCouseByGroupName::' + mapofCouseByGroupName);
        QueueNameToQmemberIdList = makeCustomQueueNameToListOfUserId(mapofCouseByGroupName.get(courseName)); // group by group member
        userIdToUserAvailablityMap = makeuserIdToUserAvailablityMap(mapofCouseByGroupName.get(courseName)); // group by group member availability

        //qNameAndMemberIdTORoundRobinIDMaP = makeqNameAndMemberIdTORoundRobinIDMaP(courseName);
        qNameToLastAssignedQmemberRRid = BuildMaps.makeQNameToLastAssignedQmemberRRid(); // qname with last allocated ID
        QnameAndRRidToMemberIDMap = makeQnameAndRRidToMemberID(mapofCouseByGroupName.get(courseName)); // qname with qname+rrid
        BuildMaps.validateUserCapacity(mapofCouseByGroupName.get(courseName), courseName);
        BuildMaps.validateUserCapacityForRM(courseName, leadIds);
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
                        if (assignmentConditionSatisfied(qName, qMemberID, ld.email)){
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
                                ld.Status = 'Open';
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
        System.debug('updateLeadList---' + updateLeadList);
        if (!updateLeadList.isEmpty()){
            reccuringTrigger = false;
            update updateLeadList;
        }

        if (!QtoBeUpdated.isEmpty())
            Update QtoBeUpdated;
    }

    public static boolean assignmentConditionSatisfied(string qName, string qMemberID, string learnerUid){
        system.debug('qMemberID-->'+qMemberID);
        system.debug('learnerUid-->'+learnerUid);

        boolean isconditionapproved = false;
        if (qMemberID != null && learnerUid != null && learnerUid.contains(qMemberID) != null && learnerUid.contains(qMemberID)){
            return false;
        }

        system.debug('BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID)::' + BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID));
        system.debug('BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)::' + BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID));

        if (BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null){
            isconditionapproved = true;
        } else if (BuildMaps.mapofMemidByAssignedLead.get(qMemberID) != null && BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) != null && BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)){
            if (BuildMaps.mapofMemidByPendingLeads.get(qMemberID) == null || (BuildMaps.mapofMemidByPendingLeads.get(qMemberID) != null && BuildMaps.mapofMemIdByExceedCount.get(qMemberID) != null && BuildMaps.mapofMemidByPendingLeads.get(qMemberID) < BuildMaps.mapofMemIdByExceedCount.get(qMemberID))){
                system.debug('inside pendingmap');
                if (BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) == null || (BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) != null && BuildMaps.mapofMemidByMinLeadsCount.get(qMemberID) != null && BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) < BuildMaps.mapofMemidByMinLeadsCount.get(qMemberID) && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) != null && BuildMaps.mapofMemIdByMaxLeadCountPerDay.get(qMemberID) != null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountPerDay.get(qMemberID))){
                    system.debug('inside minumum section');
                    isconditionapproved = true;
                } else if (BuildMaps.mapofMemIdByMaxLeadCountPerDay.get(qMemberID) == null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) != null && BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) != null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)){
                    isconditionapproved = true;
                } else if (BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) == null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) != null && BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) != null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) < BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)){
                    isconditionapproved = true;
                }
            } else{
                isconditionapproved = false;
            }
        }

        system.debug('isconditionapproved::' + isconditionapproved);
        return isconditionapproved;
    }

    public static map<String, List<lead>> makeQueueNameToListOfAssignedLeadsMap(string courseName){
        system.debug('courseName::' + courseName);
        system.debug('courseName::' + courseName);
        map<String, string> sourceIntentByGroupMap = new map<String, String>();
        Map<String, List<lead>> groupNameByLeads = new Map<String, List<lead>>();
        string queueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'Excelr Default Queue'
                          limit 1].Id;
        string groupName = [Select Name
                                From Assignment_Group__c where Name =: courseName
                                limit 1].Name;
        List<Lead> leadsInQueue = [SELECT ID,  OWNERID, Lead_Assigned_Date__c, Lead_Assigned_Time__c, Status,Email
                                   FROM Lead
                                   WHERE Ownerid = :queueId and (status != 'Junk' AND Status != 'Converted') limit 50000];
        mapofCouseByGroupName.put(groupName,groupName);
        /*list<Source_Intent_And_Group_Name__mdt> groupNameSourceIntent = [select id,Group_Name__c,Source_Intent__c from Source_Intent_And_Group_Name__mdt ];
         if(!groupNameSourceIntent.isEmpty()){
         system.debug('Inside source');
         system.debug('courseName::'+courseName);
         for(Source_Intent_And_Group_Name__mdt signMeta : groupNameSourceIntent){
         sourceIntentByGroupMap.put(signMeta.Source_Intent__c,signMeta.Group_Name__c);
         if(signMeta.Source_Intent__c == courseName){
         mapofCouseByGroupName.put(signMeta.Source_Intent__c,signMeta.Group_Name__c);
         }
         }
         }
         */
        // Inserting QueueId and list of case assigned to the queue id into the map:-QueueNameToListOfAssignedCasesMap
        system.debug('leadsInQueue-->'+leadsInQueue.size());
        if (!leadsInQueue.isEmpty()){
            system.debug('inside putting Leads');
            groupNameByLeads.put(courseName, leadsInQueue);
            system.debug('groupNameByLeads-->'+groupNameByLeads);
            system.debug('groupNameByLeads.Values()'+groupNameByLeads.values().size());
            for(Lead ld: leadsInQueue){
                leadIds.add(ld.Id);
            }
            /*for(Lead ld: leadsInQueue){
             if(ld.Category__c != null){
             if(groupNameByLeads.containsKey(sourceIntentByGroupMap.get(ld.Category__c)))
             {
             groupNameByLeads.get(sourceIntentByGroupMap.get(ld.Category__c)).add(ld);
             }else{
             groupNameByLeads.put(sourceIntentByGroupMap.get(ld.Category__c),new List<lead>{ld});
             }
             }
             System.debug('QueueNameToListOfAssignedCasesMap::'+groupNameByLeads);
             }*/
        }
        return groupNameByLeads;
    }

    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(string assignmentGroupName){
        Map<String, List<String>> customQueueNameToListOfUserId = new Map<String, List<String>>();
        List<Assignment_Group__c> queueWithQueueMembers = new List<Assignment_Group__c>();
        Map<String, Id> queueNameToQueueIdMap = new Map<String, Id>();

        List<Assignment_Group__c> listOfExistingQueue = new List<Assignment_Group__c>();
        listOfExistingQueue = [select id, name, Max_Lead_Per_Day__c
                               from Assignment_Group__c];
        List<Assignment_Group_Member__c> listOfExistingQueueMembers = new List<Assignment_Group_Member__c>();
        system.debug('assignmentGroupName-->'+assignmentGroupName);
        listOfExistingQueueMembers = [select id, name, Out_Of_Office__c, Assignment_Group__c, Assignment_Group__r.name__c,Assignment_Group__r.name, Assignment_Id__c, Leave_End_Date__c, Leave_Start_Date__c, Group_Member__c, Group_Member__r.Id
                                      from Assignment_Group_Member__c
                                      where Assignment_Group__r.name = :assignmentGroupName];
        Set<Id> existingQueueMembersQueueId = new Set<Id>();

        if (!listOfExistingQueueMembers.isEmpty()){
            for (Assignment_Group_Member__c agm : listOfExistingQueueMembers){
                if (customQueueNameToListOfUserId.containsKey(agm.Assignment_Group__r.name)){
                    customQueueNameToListOfUserId.get(agm.Assignment_Group__r.name).add(agm.Group_Member__r.Id);
                } else{
                    customQueueNameToListOfUserId.put(agm.Assignment_Group__r.name, new list<string>{ agm.Group_Member__r.Id });
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
        agentAvailablity = [select id, Out_Of_Office__c, Group_Member__r.Id, Assignment_Group__r.name, Assignment_Group__r.name__c
                            from Assignment_Group_Member__c
                            where Assignment_Group__r.name = :assignmentGroupName and Out_Of_Office__c = false];
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
        agmList = [select id, Assignment_Group__r.name,Assignment_Group__r.name__c, Assignment_Id__c, Group_Member__r.Id
                   from Assignment_Group_Member__c
                   where Assignment_Group__r.name = :groupName];

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
    }

    public static Map<String, String> makeQnameAndRRidToMemberID(String groupName){
        //Map<String, Map<String, Integer>> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Map<String, Integer>>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();

        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        agmList = [select id, Assignment_Group__r.name, Assignment_Id__c, Assignment_Group__r.name__c,Group_Member__r.Id, Out_Of_Office__c
                   from Assignment_Group_Member__c
                   where Assignment_Group__r.name = :groupName and Out_Of_Office__c = false];
        system.debug('agmList::' + agmList);
        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name;
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