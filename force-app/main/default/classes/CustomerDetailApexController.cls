public class CustomerDetailApexController {
    
    @AuraEnabled(Cacheable=True)
    Public static List<Lead> ShowAllLeads(string recordId){
        List<Lead> LeadRecList=new List<Lead>();
        List<Lead> LeadList=[Select Name,LID__c,CreatedDate,Email,MobilePhone,LeadSource,Course__c,Status From Lead Where Customers__c=:recordId];
        
        return LeadList;
    }

}