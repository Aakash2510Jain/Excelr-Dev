public class CustomerDetailApexController {
    
    @AuraEnabled(Cacheable=True)
    Public static List<Lead> ShowAllLeads(string recordId){
        List<Lead> LeadRecList=new List<Lead>();
        List<Lead> LeadList=[Select Name,LID__c,CreatedDate,Email,Phone,LeadSource,Course__c,Status From Lead Where Customers__c=:recordId];
        
        return LeadList;
    }
    
    @AuraEnabled(Cacheable=True)
    Public Static Map<String,String> GetAllFieldsLabelXValue(string recordId){ //string recordId
        
        Customers__c CustomerRec=[Select Profession__c,Qualification__c,Branch__c,Specialization__c,Year_of_Graduation__c,Why_This_Course__c,
                                  Designation__c,Year_of_Experience__c,Current_Domain__c,Relevant_Experience__c,Name__c,Company__c From Customers__c Where Id=:recordId];//Where Id=:a0XN0000009rprxMAA
        Map<String, Object> customerRecMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(CustomerRec));

                 system.debug('CustomerRec='+CustomerRec);
         system.debug('customerRecMap='+customerRecMap);
        
        String  objectName='Customers__c';
        
        Map<String,String> GetObjectFields=new Map<String,String>();
        
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        SObjectType objType = objectMap.get(objectName);
        system.debug('objType='+objType);
        
        Map<String,Schema.SObjectField> RelatedFields = objType.getDescribe().fields.getMap();
        system.debug('RelatedFields ====> ' + RelatedFields);
        
        for( Schema.SObjectField Related :RelatedFields.values()){    
            system.debug('Related ====> ' + Related);
            if(Related.getDescribe().isUpdateable()){
                system.debug('Related +++++' + Related);
                GetObjectFields.put(Related.getDescribe().getName(),Related.getDescribe().getLabel());  
                
            }
                
        }
        system.debug('GetObjectFields =====> ' + GetObjectFields);
        string LabelValue;
        String Value;
        Map<String,String> FieldLabelXFieldValue=new Map<String,String>();
        
           for(String key:GetObjectFields.keyset()){
           
               if(GetObjectFields.get(key)!='Owner ID'&& GetObjectFields.get(key)!='Name'){
                   if(customerRecMap.containskey(key)){
                       
                    LabelValue=GetObjectFields.get(key);
                    Value=String.valueOf(customerRecMap.get(key));
                   system.debug('LabelValue='+LabelValue);
                   system.debug('Value='+Value);
                   FieldLabelXFieldValue.put(LabelValue,Value);
                   system.debug('FieldLabelXFieldValueInIF='+FieldLabelXFieldValue);
                   }
                   else{
                       LabelValue=GetObjectFields.get(key);
                       Value='';
                       FieldLabelXFieldValue.put(LabelValue,Value);
                       system.debug('FieldLabelXFieldValueInelse='+FieldLabelXFieldValue);
                   }
              }
           }
          system.debug('FieldLabelXFieldValue='+FieldLabelXFieldValue);       
        //system.debug('GetObjectFields='+GetObjectFields);
        return FieldLabelXFieldValue;
        
    }
}