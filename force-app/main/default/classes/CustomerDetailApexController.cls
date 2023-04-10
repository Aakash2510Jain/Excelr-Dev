public without sharing class CustomerDetailApexController{
    @AuraEnabled(Cacheable = True)
    Public static leadOpportunityWrap getAllData(string recordId){
        try{
            Customers__c customerRec = [Select Id, CID__c,Email__c,Phone__c
                                        From Customers__c
                                        where Id = :recordId];
            List<Lead> LeadList = [Select Name, LID__c, Lead_URL__c, CreatedDate, Email, Phone, LeadSource, Course__c, Status
                                   From Lead
                                   Where Customers__c = :recordId];
            List<Opportunity> opportunityList = [Select Name, OID__c, Opportunity_URL__c, CID__c, CreatedDate, Account.Email__c, Account.Phone, LeadSource, Course__c, StageName
                                                 From Opportunity
                                                 Where CID__c = :customerRec.CID__c];
            leadOpportunityWrap leadOpportunityWrapInstance = new leadOpportunityWrap(LeadList, opportunityList);

            return leadOpportunityWrapInstance;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CustomerDetailApexController', 'ShowAllLeads', e, null);
            return null;
        }
    }

    @AuraEnabled(Cacheable = True)
    Public Static Map<String, String> GetAllFieldsLabelXValue(string recordId){
        //string recordId
        try{
            Customers__c CustomerRec = [Select Alternate_Email__c,Alternate_Phone__c,Branch__c,CID__c,Company__c,CreatedById,CreatedDate,Current_Domain__c,Designation__c,Email__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,Name__c,OwnerId,Phone__c,Profession__c,Qualification__c,Relevant_Experience__c,Specialization__c,SystemModstamp,Why_This_Course__c,Year_of_Experience__c,Year_of_Graduation__c FROM Customers__c
                                        Where Id = :recordId];//Where Id=:a0XN0000009rprxMAA
            Map<String, Object> customerRecMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(CustomerRec));

            system.debug('CustomerRec=' + CustomerRec);
            system.debug('customerRecMap=' + customerRecMap);

            String objectName = 'Customers__c';

            Map<String, String> GetObjectFields = new Map<String, String>();

            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            SObjectType objType = objectMap.get(objectName);
            system.debug('objType=' + objType);

            Map<String, Schema.SObjectField> RelatedFields = objType.getDescribe().fields.getMap();
            system.debug('RelatedFields ====> ' + RelatedFields);

            for (Schema.SObjectField Related : RelatedFields.values()){
                system.debug('Related ====> ' + Related);
                if (String.valueOf(Related) == 'CID__c'){
                    GetObjectFields.put('CID__c', 'CID__c');
                }
                if (Related.getDescribe().isUpdateable()){
                    system.debug('Related +++++' + Related);
                    GetObjectFields.put(Related.getDescribe().getName(), Related.getDescribe().getLabel());
                }

            }
            system.debug('GetObjectFields =====> ' + GetObjectFields);
            string LabelValue;
            String Value;
            Map<String, String> FieldLabelXFieldValue = new Map<String, String>();

            for (String key : GetObjectFields.keyset()){

                if (GetObjectFields.get(key) != 'Owner ID' && GetObjectFields.get(key) != 'Name'){
                    if (customerRecMap.containskey(key)){

                        LabelValue = GetObjectFields.get(key);
                        Value = String.valueOf(customerRecMap.get(key));
                        system.debug('LabelValue=' + LabelValue);
                        system.debug('Value=' + Value);
                        FieldLabelXFieldValue.put(LabelValue, Value);
                        system.debug('FieldLabelXFieldValueInIF=' + FieldLabelXFieldValue);
                    } else{
                        LabelValue = GetObjectFields.get(key);
                        Value = '';
                        FieldLabelXFieldValue.put(LabelValue, Value);
                        system.debug('FieldLabelXFieldValueInelse=' + FieldLabelXFieldValue);
                    }
                }
            }
            system.debug('FieldLabelXFieldValue=' + FieldLabelXFieldValue);
            //system.debug('GetObjectFields='+GetObjectFields);
            return FieldLabelXFieldValue;

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CustomerDetailApexController', 'GetAllFieldsLabelXValue', e, null);
            return null;
        }
    }

    public class leadOpportunityWrap{
        @AuraEnabled
        public List<Lead> leadsList;
        @AuraEnabled
        public List<Opportunity> opportunityList;
        public leadOpportunityWrap(List<Lead> leadsList, List<Opportunity> opportunityList){
            this.leadsList = leadsList;
            this.opportunityList = opportunityList;
        }

    }

}