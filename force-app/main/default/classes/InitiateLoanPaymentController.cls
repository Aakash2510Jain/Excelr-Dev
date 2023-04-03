public class InitiateLoanPaymentController {
    @AuraEnabled
    public static opportunityWrapper getOpportunityData(String opportunityId){
        system.debug('opportunityId--->'+opportunityId);
        Opportunity oppRecordToBeReturned = new Opportunity();
        List<NBFC__c> NBFCPartnerList = new List<NBFC__c>();
        List<Down_Payment_Type__c> downPaymentTypeList = new List<Down_Payment_Type__c>();
        
        oppRecordToBeReturned = [Select Id,Name,Amount From Opportunity where Id =:opportunityId];
        NBFCPartnerList = [Select Interest_Rate__c,NBFC_Name__c,GST_on_Subvention__c,Processing_Fee__c,Tenure__c From NBFC__c order by NBFC_Name__c ASC];
        downPaymentTypeList = [Select Name From Down_Payment_Type__c where isActive__c = true order by name Asc];
        opportunityWrapper opportunityWrapperInstance = new opportunityWrapper(oppRecordToBeReturned,NBFCPartnerList, downPaymentTypeList);

        return opportunityWrapperInstance;
    }
    @auraEnabled
    public static void handleLoanPayment(integer opportunityAmount, integer downPayment, integer loanAmount, string loanPartner, integer loanTenure,string downPaymentType,string expiryDate){
        system.debug('opportunityAmount---->'+opportunityAmount);
        system.debug('downPayment---->'+downPayment);
        system.debug('loanAmount---->'+loanAmount);
        system.debug('loanPartner---->'+loanPartner);
        system.debug('loanTenure---->'+loanTenure);
        system.debug('downPaymentType---->'+downPaymentType);
        system.debug('expiryDate---->'+expiryDate);

    }
    
    public static void capturePaymentStats(integer opportunityAmount, integer downPayment, integer loanAmount, string loanPartner, integer loanTenure,string loanFileName, String loanBase64Data, String loanContentType, string downPaymentFileName, String downPaymentBase64Data, String downPaymentContentType, string downPaymentType, date linkExpiryDate){
        
    }    
    
    public class opportunityWrapper{
        @AuraEnabled
        public Opportunity opportunityRecord;
        @AuraEnabled
        public List<NBFC__c> NBFCPartnerList;
        @AuraEnabled
        public List<Down_Payment_Type__c> downPaymentTypeList;
        
        public opportunityWrapper(Opportunity opportunityRecord, List<NBFC__c> NBFCPartnerList, List<Down_Payment_Type__c> downPaymentTypeList){
            this.opportunityRecord = opportunityRecord; 
            this.NBFCPartnerList = NBFCPartnerList;
            this.downPaymentTypeList = downPaymentTypeList;
        }
    }
}