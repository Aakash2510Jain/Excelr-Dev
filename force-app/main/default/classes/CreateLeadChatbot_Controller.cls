public without sharing class CreateLeadChatbot_Controller {
    
    public static String coursePickValues  {get;set;}
    public Static Map<String, String> pageMap {get;set;}
    public Static List<String> getCityList {get;set;}
    public CreateLeadChatbot_Controller(){
        coursePickValues = JSON.serialize(Utility.getPicklistValues('Lead','Course__c'));
        getCityList = CreateLeadChatbot_Controller.getAllCities();
    }

    
 public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){
     
    try{
       
        List<String> lstPickvals                        = new List<String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_name).getDescribe().getPicklistValues();
       
        for (Schema.PicklistEntry a : pick_list_values) {
           
            lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
        }
        return lstPickvals;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CreateLeadChatbot_Controller', 'getPicklistValues', e , null);
       return null;
    }
}
    
    @RemoteAction
    public static string saveLeadDetails (lead lead){
        try{
        insert lead;
        return lead.Id;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CreateLeadChatbot_Controller', 'saveLeadDetails', e , null);
       return null;
    }
}
    
     @RemoteAction
    public Static List<String> getAllCities(){
        try{
        List<String> cityList = new List<String>();
       List<City_State_Country__c> custSetList = [SELECT Id,Country__c,City__c,State__c FROM City_State_Country__c];
        for(City_State_Country__c cus : custSetList){
            cityList.add(cus.City__c);
        }
        System.debug('cityList 1 :'+cityList);
        getCityList = cityList;
        return cityList;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CreateLeadChatbot_Controller', 'getAllCities', e , null);
       return null;
    }
}
    
     @RemoteAction
    public Static Map<String,String> getStateCustomSetting( String cityName){
        try{
       List<City_State_Country__c> custSetList = [SELECT Id,Country__c,City__c,State__c FROM City_State_Country__c Where City__c =:cityName];
        Map<String,String> StateCounytyMap = new Map<String,String>();
        for(City_State_Country__c cus : custSetList){
            StateCounytyMap.put(cus.State__c,cus.Country__c);
        }
        System.debug(' State ::'+StateCounytyMap.keySet() + ' Country ::'+StateCounytyMap.values());
        pageMap = StateCounytyMap;
        return StateCounytyMap;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CreateLeadChatbot_Controller', 'getStateCustomSetting', e , null);
       return null;
    }
}
}