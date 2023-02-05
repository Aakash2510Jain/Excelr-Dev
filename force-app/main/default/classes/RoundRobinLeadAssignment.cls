public without sharing class  RoundRobinLeadAssignment{
    
    public static boolean reccuringTrigger = true;
    public static string groupName = '';
    public static map<string,string> mapofCouseByGroupName = new map<string,string>();
    @future
    public static void assignLeadsToBDS(String courseName,set<String> leadIdList){
     try{   
        system.debug('courseName::'+ courseName);
        system.debug('leadIdList::'+leadIdList.size());
        boolean withinWorkingHour = false;
        string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Excelr Default Queue' limit 1].Id;
        List<lead> updateLeadList = new List<lead>();
        List<lead> DefaultQueueLeadList = new List<lead>();
        List<Assignment_Group__c> QtoBeUpdated = new List<Assignment_Group__c>();
        Map<String, List<String>> QueueNameToQmemberIdList = new Map<String, List<String>>();
        Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();
        Map<String, List<Lead>> qNameToListOfLeadsMap = new map<String,List<lead>>();
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
        Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        //In case the Method fails assign to first member 
        String Assignee = '';
        //withinWorkingHour = BuildMaps.CheckBusinessHours();
        //Getting the Leads which are in default queue from this List Lead..
        If(leadIdList.size() > 0){
            List<Lead> LeadData =  [SELECT ID,Lead_Assigned_Date__c,OWNERID,Status FROM Lead WHERE  id IN:leadIdList limit 50000];
            qNameToListOfLeadsMap.put(courseName,LeadData);//makeQueueNameToListOfAssignedLeadsMap(courseName,leadIdList);//Group wise leads based on source intent
        }
        system.debug('qNameToListOfLeadsMap::'+qNameToListOfLeadsMap);
        system.debug('leadIdList::'+leadIdList.size());
        //Getting the Group Members Corresponding to the groups where do not Consider For Lead Assignment = false
        QueueNameToQmemberIdList = makeCustomQueueNameToListOfUserId(courseName); // group by group member
        
        userIdToUserAvailablityMap = makeuserIdToUserAvailablityMap(courseName); // group by group member availability
        
        //qNameAndMemberIdTORoundRobinIDMaP = makeqNameAndMemberIdTORoundRobinIDMaP(courseName);
        qNameToLastAssignedQmemberRRid = BuildMaps.makeQNameToLastAssignedQmemberRRid(); // qname with last allocated ID
        QnameAndRRidToMemberIDMap = makeQnameAndRRidToMemberID(courseName); // qname with qname+rrid
        BuildMaps.validateUserCapacity(courseName,leadIdList);
        
        for(String qName: qNameToListOfLeadsMap.keySet()){
            if(qName != null){
                for(lead ld: qNameToListOfLeadsMap.get(qName)){
                    Boolean isAssigned = false;
                    Integer qMemberSize = 1;
                    While(QueueNameToQmemberIdList != null && qMemberSize != null && QueueNameToQmemberIdList.get(qName) != null && isAssigned == false && qMemberSize <= QueueNameToQmemberIdList.get(qName).size()){
                        Assignee = QueueNameToQmemberIdList.get(qName)[0];
                        Integer currentRRid, LastRRid; 
                        String QnameAndRRid, qMemberID;
                        if(qNameToLastAssignedQmemberRRid.get(qName) != null)
                            LastRRid = qNameToLastAssignedQmemberRRid.get(qName); 
                        if(LastRRid == null || LastRRid < 1){
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, 0);
                            currentRRid = 1;
                        }
                        if(LastRRid < QueueNameToQmemberIdList.get(qName).size()){
                            currentRRid = LastRRid + 1;
                        }
                        else{
                            currentRRid = 1;
                            LastRRid = 0;
                        }
                        QnameAndRRid = qName + String.valueOf(currentRRid);
                        qMemberID = QnameAndRRidToMemberIDMap.get(QnameAndRRid);
                        boolean test = true;
                        if(assignmentConditionSatisfied(qName,qMemberID,'123')){//qName,qMemberID,userIdbyLeadcount,ld.Learner_Uid__c,assignmentConditionSatisfied(true)
                            if(userIdToUserAvailablityMap.get(qMemberID) == true){
                                ld.ownerId = Id.valueOf(qMemberID);
                                ld.Lead_Assigned_Date__c = system.today();
                                ld.Lead_Assigned_Date_TIme__c = system.now();
                                ld.Lead_Assigned_Time__c = Time.newInstance(Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second(), 0);
                                ld.status = 'Open';
                                updateLeadList.add(ld); 
                                isAssigned = true;
                                if(BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID,0);
                                BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID,BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID)+1);
                                if(BuildMaps.mapofMemidByPendingLeads.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByPendingLeads.put(qMemberID,0);
                                BuildMaps.mapofMemidByPendingLeads.put(qMemberID,BuildMaps.mapofMemidByPendingLeads.get(qMemberID) + 1);
                                if(BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByTodayNewLead.put(qMemberID,0);
                                BuildMaps.mapofMemidByTodayNewLead.put(qMemberID,BuildMaps.mapofMemidByTodayNewLead.get(qMemberID)+1);
                                if(BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByAssignedLead.put(qMemberID,0);
                                BuildMaps.mapofMemidByAssignedLead.put(qMemberID,BuildMaps.mapofMemidByAssignedLead.get(qMemberID) + 1);
                                if(BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.put(qMemberID,0);
                                BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.put(qMemberID,BuildMaps.mapofMemidByMaxLeadPerMonthFromUser.get(qMemberID) + 1);
                                if(BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByMaxLeadPerDayFromAG.put(qMemberID,0);
                                BuildMaps.mapofMemidByMaxLeadPerDayFromAG.put(qMemberID,BuildMaps.mapofMemidByMaxLeadPerDayFromAG.get(qMemberID) + 1);
                                if (BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null)
                                    BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);
                                BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) + 1);

                            }else{
                                ld.OwnerId = queueId;
                                DefaultQueueLeadList.add(ld);
                            }
                            LastRRid = LastRRid +1; 
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                            qMemberSize ++;
                        }else{
                            LastRRid = LastRRid +1; 
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                            qMemberSize ++;
                            ld.OwnerId = queueId;
                            DefaultQueueLeadList.add(ld);
                        }
                    }
                }
            }
        }
        
        if(!qNameToLastAssignedQmemberRRid.keySet().isEmpty())
        {
            List<Assignment_Group__c> updateQrId = new List<Assignment_Group__c>();
            updateQrId = [Select id, name, Last_Allocated_RRid__c  from Assignment_Group__c where Name IN: qNameToLastAssignedQmemberRRid.keySet()];
            for(Assignment_Group__c Q: updateQrId)
            {
                Q.Last_Allocated_RRid__c = qNameToLastAssignedQmemberRRid.get(Q.Name);
                QtoBeUpdated.add(q);
            }
        }
        System.debug('updateLeadList---'+updateLeadList);
        if(!updateLeadList.isEmpty()){
            reccuringTrigger = false;
            try{
                system.debug('updateLeadList'+updateLeadList.size());
                update updateLeadList;  
            }catch(exception e){
                System.debug(' the Error has occured due to =====> ' + e.getMessage());
                System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
                HandleBusinessException.captureError('RoundRobinLeadAssignment','assignLeadsToBDS', e, null);
            }
        }
        
        if(!QtoBeUpdated.isEmpty()){
            Update QtoBeUpdated;           
        }
        
        if(!DefaultQueueLeadList.isEmpty()){
            system.debug('DefaultQueueLeadList'+DefaultQueueLeadList.size());
            Set<Lead> myset = new Set<Lead>();
            List<Lead> result = new List<Lead>();
            myset.addAll(DefaultQueueLeadList);
            result.addAll(myset);
            update result;
        }
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'assignLeadsToBDS', e , null);
       
    }
}
    
    public static boolean assignmentConditionSatisfied(string qName,string qMemberID,string learnerUid){
        try{
        boolean isconditionapproved = false;
       
        system.debug('BuildMaps.mapofMemidByAssignedLead.get(qMemberID)::'+BuildMaps.mapofMemidByAssignedLead.get(qMemberID));
        system.debug('BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)::'+BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID));
        if(BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null){
            isconditionapproved = true;
        }else{
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
                            system.debug('BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID)-->'+BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID));
                            if(BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) == null)
                                BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.put(qMemberID, 0);
                            if(BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID) != null && BuildMaps.mapofMemidByLeadsAssignedInThisTransaction.get(qMemberID) < BuildMaps.mapofMemidByLeadsToAssignInSIngleShot.get(qMemberID)){
                                system.debug('Finally inside true');
                                isconditionapproved = true;
                                }
                        }
                    }
                } 
            }
        }
        
        
        /*else if(BuildMaps.mapofMemidByAssignedLead.get(qMemberID) != null && BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) != null &&  BuildMaps.mapofMemidByAssignedLead.get(qMemberID) < BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)){
            if(BuildMaps.mapofMemidByPendingLeads.get(qMemberID) == null || (BuildMaps.mapofMemidByPendingLeads.get(qMemberID) != null && BuildMaps.mapofMemIdByExceedCount.get(qMemberID) != null && BuildMaps.mapofMemidByPendingLeads.get(qMemberID) < BuildMaps.mapofMemIdByExceedCount.get(qMemberID))){
                if(BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) == null ||(BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) != null && BuildMaps.mapofMemidByMinLeadsCount.get(qMemberID) != null && BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) < BuildMaps.mapofMemidByMinLeadsCount.get(qMemberID) && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) != null && BuildMaps.mapofMemIdByMaxLeadCountPerDay.get(qMemberID) != null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountPerDay.get(qMemberID))){
                    isconditionapproved = true;
                }else if(BuildMaps.mapofMemIdByMaxLeadCountPerDay.get(qMemberID) == null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) != null && BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) != null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) < BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID)){
                    isconditionapproved = true;
                }else if(BuildMaps.mapofMemIdByMaxLeadCountByGroupPerDay.get(qMemberID) == null && BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) != null && BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID) != null &&  BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) < BuildMaps.mapofMemidbyMaxleadCountFromUser.get(qMemberID)){
                    isconditionapproved = true;
                }  
            }else{
                isconditionapproved = false;
            }
        }*/
        return isconditionapproved;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'assignmentConditionSatisfied', e , null);
       return null;
    }
    
    }
    
    public static map<String,List<lead>> makeQueueNameToListOfAssignedLeadsMap(string courseName,set<String> leadId){ 
        try{
        system.debug('courseName::'+courseName);
        system.debug('leadId::'+leadId);
        map<String,string> sourceIntentByGroupMap = new map<String,String>();
        Map<String, List<lead>> groupNameByLeads = new Map<String, List<lead>>();
        List<Lead> leadsInQueue = [SELECT ID,Lead_Assigned_Date__c,OWNERID,Status FROM Lead WHERE id in:leadId limit 50000];
        system.debug('leadsInQueue::'+leadsInQueue);
        if(!leadsInQueue.isEmpty()){
            for(Lead ld: leadsInQueue){
                if(ld.status != null){
                    if(groupNameByLeads.containsKey(courseName))
                    {
                        groupNameByLeads.get(courseName).add(ld);    
                    }else{
                        groupNameByLeads.put(courseName,new List<lead>{ld});      
                    }
                }
            }
        }
        System.debug('QueueNameToListOfAssignedCasesMap::'+groupNameByLeads);
        return groupNameByLeads;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeQueueNameToListOfAssignedLeadsMap', e , null);
       return null;
    }
}
    
    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(string assignmentGroupName){
        try{
        Map<String, List<String>> customQueueNameToListOfUserId = new Map<String, List<String>>();
        List<Assignment_Group__c> queueWithQueueMembers = new List<Assignment_Group__c>();
        Map<String, Id> queueNameToQueueIdMap = new Map<String, Id> ();
        
        List<Assignment_Group__c> listOfExistingQueue = new List<Assignment_Group__c>();
        listOfExistingQueue = [select id, name,Max_Lead_Per_Day__c from Assignment_Group__c];
        List<Assignment_Group_Member__c > listOfExistingQueueMembers = new List<Assignment_Group_Member__c >();
        listOfExistingQueueMembers = [select id, name,Out_Of_Office__c,Assignment_Group__c,Assignment_Group__r.name, Assignment_Id__c,Leave_End_Date__c,Leave_Start_Date__c,Group_Member__c,Group_Member__r.Id from Assignment_Group_Member__c where Assignment_Group__r.name =: assignmentGroupName ];
        system.debug('listOfExistingQueueMembers::'+listOfExistingQueueMembers);
        Set<Id> existingQueueMembersQueueId = new Set<Id>();
        
        if(!listOfExistingQueueMembers.isEmpty()){
            for(Assignment_Group_Member__c agm : listOfExistingQueueMembers){
                if(customQueueNameToListOfUserId.containsKey(agm.Assignment_Group__r.name)){
                    customQueueNameToListOfUserId.get(agm.Assignment_Group__r.name).add(agm.Group_Member__r.Id);
                }else{
                    customQueueNameToListOfUserId.put(agm.Assignment_Group__r.name,new list<string>{agm.Group_Member__r.Id});
                }
            }
        }
        system.debug('customQueueNameToListOfUserId::'+customQueueNameToListOfUserId);
        return customQueueNameToListOfUserId;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeCustomQueueNameToListOfUserId', e , null);
       return null;
    }
}
    
    public static Map<String, Boolean> makeuserIdToUserAvailablityMap(string assignmentGroupName){
        try{
        /**Need to  handle leave*/ 
        Map<String, Boolean> userIdToUserAvailablityMap = new Map<String, Boolean>();   
        List<Assignment_Group_Member__c> agentAvailablity = new List<Assignment_Group_Member__c>();  
        agentAvailablity = [select id,Out_Of_Office__c,Group_Member__r.Id,Assignment_Group__r.name from Assignment_Group_Member__c where Assignment_Group__r.name =: assignmentGroupName and Out_Of_Office__c = false];
        system.debug('agentAvailablity::'+agentAvailablity);
        for(Assignment_Group_Member__c Aa: agentAvailablity)
        {
            userIdToUserAvailablityMap.put(aa.Group_Member__r.Id, true);    
        }
        System.debug('userIdToUserAvailablityMap-----'+userIdToUserAvailablityMap);
        return userIdToUserAvailablityMap;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeuserIdToUserAvailablityMap', e , null);
       return null;
    }
}
    public static Map<String, Integer> makeqNameAndMemberIdTORoundRobinIDMaP(String groupName){ 
        try{
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        agmList = [select id,Assignment_Group__r.name,Assignment_Id__c,Group_Member__r.Id from Assignment_Group_Member__c where Assignment_Group__r.name =: groupName];
        
        if(!agmList.isEmpty()){
            for(Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name; String qMember = agm.Group_Member__r.Id;
                if(!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName+qMember;
                    qNameAndMemberIdTORoundRobinIDMaP.put(qNameAndQmamber, Integer.valueOf(agm.Assignment_Id__c));
                } 
            }
        }
        return qNameAndMemberIdTORoundRobinIDMaP;        
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeqNameAndMemberIdTORoundRobinIDMaP', e , null);
       return null;
    }
}
    
    public static Map<String, String> makeQnameAndRRidToMemberID(String groupName){
        try{
        //Map<String, Map<String, Integer>> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Map<String, Integer>>();  
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        agmList = [select id,Assignment_Group__r.name,Assignment_Id__c,Group_Member__r.Id,Out_Of_Office__c from Assignment_Group_Member__c where Assignment_Group__r.name =: groupName and Out_Of_Office__c = false];
        system.debug('agmList::'+agmList);
        if(!agmList.isEmpty()){
            for(Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name; String qMember = string.valueOf(agm.Assignment_Id__c);
                system.debug('qName::'+qName);
                system.debug('qMember::'+qMember);
                if(!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName+qMember;
                    system.debug('qNameAndQmamber::'+qNameAndQmamber);
                    QnameAndRRidToMemberIDMap.put(qNameAndQmamber, String.valueOf(agm.Group_Member__r.Id));
                } 
            }
        }
        
        //System.debug('QnameAndRRidToMemberIDMap---'+QnameAndRRidToMemberIDMap);
        return QnameAndRRidToMemberIDMap;        
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RoundRobinLeadAssignment', 'makeQnameAndRRidToMemberID', e , null);
       return null;
    }
}
}