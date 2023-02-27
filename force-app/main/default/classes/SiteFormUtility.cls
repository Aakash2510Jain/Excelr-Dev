public without sharing class SiteFormUtility{
    @AuraEnabled(cacheable = true)
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){

        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();

        for (Schema.PicklistEntry a : pick_list_values){

            lstPickvals.add(String.ValueOf(a.getLabel()).trim());
        }
        return lstPickvals;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, List<String>> getallPicklistvlaues(){

        Map<String, List<String>> pickValByField = new Map<String, List<String>>();

        // ======================================== Lead Related Picklist Values ========================================

        pickValByField.put('Courses', getPicklistValues('Lead', 'Course__c'));
        pickValByField.put('Sources', getPicklistValues('Lead', 'LeadSource'));
        pickValByField.put('LeadGenPath', getPicklistValues('Lead', 'Lead_Gen_Path__c'));
        pickValByField.put('Medium', getPicklistValues('Lead', 'UTM_Medium__c'));


        // ======================================== task Related Picklist Values ========================================
        pickValByField.put('TaskStatus', getPicklistValues('task', 'Status'));
        pickValByField.put('TaskPriority', getPicklistValues('task', 'Priority'));

        System.debug('pickValByField ======> ' + pickValByField);
        return pickValByField;
    }


    @AuraEnabled(Cacheable = True)
    Public Static List<Country__c> FetchCountryRec(){
        List<Country__c> countryRecordList = [Select name,Id
                                                  From Country__c
                                                  ORDER BY Name ASC];

        return countryRecordList;
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<State__c> FetchStateRec(string countryid){
        List<State__c> statesList = [Select name,Id
                                                  From State__c where Country__c =: countryid
                                                  ORDER BY Name ASC];

        return statesList;
    }

   
    @AuraEnabled
    public static List <City_Big_Object__b> GetCityFromBigobject(string SelectedCountryId,string SelectedStateId){
        system.debug('SelectedCountryId--'+SelectedCountryId);
        system.debug('SelectedStateId--'+SelectedStateId);
        string compositekey=SelectedCountryId+SelectedStateId;
       List <City_Big_Object__b> cityList = [Select Id,City__c from City_Big_Object__b where CountryStateCompositeKey__c =:compositekey];
       system.debug('cityList--->'+cityList.size());
       //Select City__c from City_Big_Object__b where CountryStateCompositeKey__c = 'a0aN000000BcX3TIAVa0bN000000Es3saIAB'
       return cityList;
    }

    @AuraEnabled(Cacheable = True)
    public static Map<String, List<String>> ReferralFormPicklists(){
        Map<String, List<String>> pickValByField = new Map<String, List<String>>();
        //try {
        // ======================================== Lead Related Picklist Values ========================================

        pickValByField.put('Courses', getPicklistValues('Lead', 'Course__c'));
        pickValByField.put('typeofCourses', getPicklistValues('Lead', 'Type_of_Course__c'));

            
        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
        return pickValByField;
    }

    @AuraEnabled(Cacheable = True)
    public static List<Country_CountryCode__c> fetchCountryAndCountryCode(){
        try{
            List<Country_CountryCode__c> CCodeList = [SELECT CountryCode__c, Id, Name
                                                      FROM Country_CountryCode__c];

            return CCodeList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

}