public class TransferLeadListViewID_Class {
    public List<Lead> selLeadLst;
    public String LeadIds;
    public TransferLeadListViewID_Class(ApexPages.StandardSetController cntlr){
         selLeadLst = cntlr.getSelected(); //get selected records from account list view

        system.debug('selLeadLst :: ' + selLeadLst);
        LeadIds = '';
        for ( Lead ld : selLeadLst ){
            LeadIds += ld.Id + ','; //build list of ids string concatenated with comma
        }
       
        LeadIds = LeadIds.removeEnd(',');
         system.debug('LeadIds :: ' + LeadIds);
        
    }

    public PageReference redirectToLC(){
        String returnUrl = '/lightning/cmp/c__TransferListViewComp?c__listofLeads=' + LeadIds;
        system.debug('return===>>' +LeadIds);
        PageReference pgReturnPage = new PageReference( returnUrl );
        pgReturnPage.setRedirect(true);
        
        system.debug('pgReturnPage====>' +pgReturnPage);
        return pgReturnPage;
    }
     @AuraEnabled
    public static string getLeadListViewID(List<String> leadlist){
         Set<String> LeadIds = new Set<String>();
        system.debug('SelctedleadIds====>>' +leadlist);
         LeadIds.addAll(leadlist);
        if (  LeadIds != null ){
          //TransferLeadAssignmentRR.assignLeadsToBDS(LeadIds, true, false);   
        }
           
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static void QueryAssignmentGroup(){
       // AssignGroupWrapper AGWrap = new AssignGroupWrapper();
        try{
 
            ListView listviews = [SELECT Id, Name
                                  FROM ListView
                                  WHERE SobjectType = 'Lead' and name = 'All Lead'];
           // AGWrap.AllLeadlistview = listviews;
          //  system.debug('AGWrap :: ' + AGWrap);
           // return AGWrap;
          
       
        }
        catch ( DmlException e ){
            System.debug('The following exception has occurred: ' + e.getMessage() + ' at lin number :: ' + e.getLineNumber());
        }
      //  return AGWrap;
    }

}