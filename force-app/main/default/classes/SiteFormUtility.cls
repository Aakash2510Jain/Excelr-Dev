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
    public static PicklistWrapperWrapper getallPicklistvlaues(){

        Map<String, List<String>> pickValByField = new Map<String, List<String>>();

        Map<String, Map<String, List<String>>> AllformsMap = new Map<String, Map<String, List<String>>>();

        PicklistWrapperWrapper picklistwrap = new PicklistWrapperWrapper();


        // ======================================== Lead Related Picklist Values ========================================

        pickValByField.put('Courses', getPicklistValues('Lead', 'Course__c'));
        pickValByField.put('Sources', getPicklistValues('Lead', 'LeadSource'));
        pickValByField.put('LeadGenPath', getPicklistValues('Lead', 'Lead_Gen_Path__c'));
        pickValByField.put('Medium', getPicklistValues('Lead', 'UTM_Medium__c'));
        pickValByField.put('TypeofCourse', getPicklistValues('Lead', 'Type_of_Course__c'));


        // ======================================== task Related Picklist Values ========================================
        pickValByField.put('TaskStatus', getPicklistValues('task', 'Status'));
        pickValByField.put('TaskPriority', getPicklistValues('task', 'Priority'));


        // ======================================= Lead Picklists from Metadata Type ======================================


        String type = 'Forms_Picklist__mdt';

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType FormPicklistSchema = schemaMap.get(type) ;
        Map<String, Schema.SObjectField> fieldMap = FormPicklistSchema.getDescribe().fields.getMap();

        Map<string, string> customformpicklistfieldsmap = new Map<string, string>();
        for (String fieldName : fieldMap.keySet()){
            System.debug('fieldMap.get(fieldName).getDescribe().getLabel() ====> ' + fieldMap.get(fieldName).getDescribe().getLabel());
            if (fieldMap.get(fieldName).getDescribe().isCustom() || fieldName == 'MasterLabel' || fieldName == 'DeveloperName'){
                customformpicklistfieldsmap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
            }
        }
        System.debug('customformpicklistfieldsmap ======> ' + customformpicklistfieldsmap);

        List<Forms_Picklist__mdt> formspicklists = [SELECT course_names__c, DeveloperName, form_type__c, Id, Label, lead_gen_path__c, MasterLabel, medium__c, source__c
                                                    FROM Forms_Picklist__mdt];
                                                    
        String s = JSON.serialize(formspicklists[0]);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(s);
        System.debug('m ======> ' + m);

        map<string, Forms_Picklist__mdt> formpicklistmetadataMap = new map<string, Forms_Picklist__mdt>();
        System.debug('formspicklists ====> ' + formspicklists);
        for (Forms_Picklist__mdt Formpicklistrec : formspicklists){

            String formpicklistsstring = JSON.serialize(Formpicklistrec);
            Map<String, Object> formpicklistmap = (Map<String, Object>)JSON.deserializeUntyped(formpicklistsstring);
            
            Map<String, List<String>> SingleformpicklistMap = new Map<String, List<String>>();

            for (String str : formpicklistmap.keySet()){
                System.debug('str ===> ' + str);
                if (customformpicklistfieldsmap.containsKey(str)){

                    System.debug('str inside if condition ===> ' + str);
                    
                   // list<string> Leadgenpath = (Formpicklistrec.Lead_Gen_Path__c).split(',');
                    List<string> StringList = String.valueOf(formpicklistmap.get(str)).split(',');
                    SingleformpicklistMap.put(str,StringList);

                }
            }

            AllformsMap.put(Formpicklistrec.form_type__c, SingleformpicklistMap);
            

        }
        picklistwrap.AllformsMapwrapper = AllformsMap;
        picklistwrap.pickValByFieldWrapper = pickValByField;
        System.debug('AllformsMap ====> ' + AllformsMap);

        System.debug('pickValByField ======> ' + pickValByField);
        return picklistwrap;
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<Country__c> FetchCountryRec(){
        List<Country__c> countryRecordList = [Select name, Id
                                              From Country__c
                                              ORDER BY Name ASC];

        return countryRecordList;
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<State__c> FetchStateRec(string countryid){
        List<State__c> statesList = [Select name, Id
                                     From State__c
                                     where Country__c = :countryid
                                     ORDER BY Name ASC];

        return statesList;
    }

    @AuraEnabled
    public static List<City_Big_Object__b> GetCityFromBigobject(string SelectedCountryId, string SelectedStateId){
        system.debug('SelectedCountryId--' + SelectedCountryId);
        system.debug('SelectedStateId--' + SelectedStateId);
        string compositekey = SelectedCountryId + SelectedStateId;
        List<City_Big_Object__b> cityList = [Select Id, City__c
                                             from City_Big_Object__b
                                             where CountryStateCompositeKey__c = :compositekey];
        system.debug('cityList--->' + cityList.size());
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

    public class PicklistWrapperWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickValByFieldWrapper{get;set;}
        @AuraEnabled
        public Map<String, Map<String, List<String>>> AllformsMapwrapper{get;set;}
    }

}