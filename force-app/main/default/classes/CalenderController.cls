public without sharing class CalenderController {
    
    @AuraEnabled
    public static Map<String,Object> getUserEvents(String userId){
        try {
            Map<String,Object> responseMap = new Map<String,Object>();

            List<Availability__c> avList = [Select Id,Name From Availability__c Where OwnerId=:userId];
            User u = [Select Id,Name,Email From User Where Id=:userId];

            responseMap.put('events',avList);
            responseMap.put('user',u);

            return responseMap;
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','getUserEvents', e, null);
            throw new AuraHandledException(e.getMessage());
            
        }
    }


    @AuraEnabled
    public static Map<String,Object> getCalendarType(String userId){
        try {
            Map<String,Object> responseMap = new Map<String,Object>();

            List<Calender_Type__c> avList = [Select Id,Name,Calendar_Link__c,Slot_Duration__c,Start_Time__c,End_Time__c  From Calender_Type__c Where OwnerId=:userId];
            User u = [Select Id,Name,Email,My_Calendar__c From User Where Id=:userId];
            
            responseMap.put('events',avList);
            responseMap.put('user',u);

            return responseMap;
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','getCalendarType', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getCalendarsUserInfo(String userId){
        try {
            return getCalendarType(userId);
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','getCalendarsUserInfo', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> checkAvailibility(String cId){
        try {
            Map<String,Object> respMap = new Map<String,Object>();

            Calender_Type__c cType = [Select Id,Name,Start_Time__c,End_Time__c,Calendar_Link__c,Slot_Duration__c,Before_Gap__c,After_Gap__c,Owner.Name,OwnerId From Calender_Type__c Where Id=:cId];

            List<Availability__c> avList = [Select Id,Name,Date__c,Start_Time__c,End_Time__c From Availability__c Where OwnerId=:cType.OwnerId];

            User user = [Select Id,Name,Start_Date__c,End_Date__c From User Where Id=:cType.OwnerId];

            respMap.put('availibility',avList);
            respMap.put('cdetails',cType);
            respMap.put('user',user);
            respMap.put('startTime',String.valueOf(cType.Start_Time__c));
            respMap.put('endTime',String.valueOf(cType.End_Time__c));

            return respMap;
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','checkAvailibility', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static string createBookSlot(Booked_Slot__c bookedSlot, Long sLongTime, Long eLongTime){
        try {

            System.debug('sLongTime----'+sLongTime);
            System.debug('eLongTime----'+eLongTime);
            
            Availability__c av = [Select Id,Date__c From Availability__c Where Id=:bookedSlot.Availability__c];

            Time startTime = createTime(sLongTime);
            Time endTime = createTime(eLongTime);

            bookedSlot.Start_Time__c = startTime;
            bookedSlot.End_Time__c = endTime;
            bookedSlot.Date__c = av.Date__c;

            insert bookedSlot;

           GMeetAPIHandler.generateMeetLink_V2(bookedSlot.Id);
            return 'Success';

        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','createBookSlot', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }


    public static Time createTime(Long lTime){
        Long milliseconds = lTime;
        Long mins = milliseconds / 60000;
        Long hours = mins / 60;
        Long remainingMins = mins - (hours * 60);

        return Time.newInstance(hours.intValue(),remainingMins.intValue(),0,0);
        //String totalTime = String.valueOf(hours) + ' hrs ' +  String.valueOf(remainingMins) +' mins';
    }



    @AuraEnabled
    public static List<Booked_Slot__c> getBookedSlotForParticularDate(String cId, integer year, integer month, integer day){
        try {
            Date lookingOn = Date.newInstance(year, month, day);

            Calender_Type__c cType = [Select Id,Name,Start_Time__c,End_Time__c,Calendar_Link__c,Slot_Duration__c,Before_Gap__c,After_Gap__c,Owner.Name,OwnerId From Calender_Type__c Where Id=:cId];
            return [Select Id,Name,Date__c,Start_Time__c,End_Time__c From Booked_Slot__c Where OwnerId=:cType.OwnerId And Date__c =: lookingOn];
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','getBookedSlotForParticularDate', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createEvent(Calender_Type__c ct, String startTime, String endTime){
        try {
            Integer sHours = Integer.valueOf(startTime.split(':')[0]);
            Integer sMins = Integer.valueOf(startTime.split(':')[1]);

            Integer eHours = Integer.valueOf(endTime.split(':')[0]);
            Integer eMins = Integer.valueOf(endTime.split(':')[1]);

            ct.Start_Time__c = Time.newInstance(sHours,sMins,0,0);
            ct.End_Time__c = Time.newInstance(eHours,eMins,0,0);
            insert ct;
            return 'Success';
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','createEvent', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> getPicklistFieldsValues(String objName, List<String> fieldList){
        try {
            Map<String,List<String>> fieldMap = new Map<String,List<String>>();

            for(String f : fieldList){
                List<String> fList = getPicklistValues(objName,f);
                fieldMap.put(f,fList);
            }
            return fieldMap;
        } catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('CalenderController','getPicklistFieldsValues', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }


    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        try{
        
        List<String> lstPickvals                        = new List<String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            
            lstPickvals.add(String.ValueOf(a.getValue()));  
        }
        return lstPickvals;
    }catch (Exception e) {
        System.debug(' the Error has occured due to =====> ' + e.getMessage());
        System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
        HandleBusinessException.captureError('CalenderController','getPicklistValues', e, null);
         return null;
    }
}
}