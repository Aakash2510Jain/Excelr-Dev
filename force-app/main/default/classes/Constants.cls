public without Sharing class Constants{
    public static final string PENDING = 'Pending';
    public static final String UNDER_APPROVAL_PROCESS_ERR_MSG = 'Record is Under Approval';
    public static Id queueId = [select Id
                                from Group
                                where Name = 'Excelr Default Queue' and Type = 'Queue'].Id;
    
    public static Id ExcelrGuestUserId = [Select id, name from user where Name = 'ExcelR Site Guest User' ].Id;
    public static Id AdminUserId = system.label.Admin_User_Id;
    // queue name
    public static final string PRIVATE_LEAD_QUEUE = 'Org Default Queue';
    public static final String CALLYZER_CALL_HISTORY_ENDPOINT = System.Label.CALLYZER_CALL_HISTORY_ENDPOINT;
    public static final string taskSubjectViaLeadCreationAPI = 'Candidate has applied again for the Same Course';
    public static final string PAYMENT_STATUS_SUCCESS = 'Success';
    public static final string PAYMENT_STATUS_FAILURE = 'Failure';

    public static final string PAYMENT_STATUS_PAYMENT_DONE = 'Payment Successful';
    public static final string PAYMENT_STATUS_PAYMENT_FAILED = 'Payment Failed';

    // ============================================= Sobject Name ============================
    public static final string SOBJECT_ACCOUNT = 'Account';
    public static final string SOBJECT_LEAD = 'Lead';
    public static final string SOBJECT_OPPORTUNITY = 'Opportunity';

    // ===================================================Lead Status =========================================
    public static final string LEAD_STATUS_OPEN = 'Open';
    public static final string LEAD_STATUS_ATC = 'ATC';
    public static final string LEAD_STATUS_REQUEST_CALL_BACK = 'Request a Call Back';
    public static final string LEAD_STATUS_IN_CONVERSATION = 'In Conversation';
    public static final string LEAD_STATUS_DEAD = 'Dead';
    public static final string LEAD_STATUS_JUNK = 'Junk';
    public static final string LEAD_STATUS_ON_HOLD = 'On Hold';
    public static final string LEAD_STATUS_DEFERRED = 'Deferred';
    public static final string LEAD_STATUS_PROMOTE = 'Promote';


    // ============================================== Opportunity Stage Constanst ============================================

    public static final string OPP_STAGENAME_ON_HOLD = 'On Hold';
    public static final string OPP_STAGENAME_DEFERRED = 'Deferred';
    public static final string OPP_STAGENAME_CLOSE_LOST = 'Closed-Lost'; //Prospect Hot Awaiting Confirmation
    public static final string OPP_STAGENAME_PROSPECT = 'Prospect';
    public static final string OPP_STAGENAME_HOT = 'Hot';
    public static final string OPP_STAGENAME_AWAITING_CONFIRMATION = 'Awaiting Confirmation';
    public static final string OPP_STAGENAME_CLOSE_WON = 'Closed-Won';
    

    // ============================================== Opportunity Payment Status ============================================
    public static final string OPP_PAYMENT_STATUS_LINK_SENT = 'Link Sent';
    public static final string OPP_PAYMENT_STATUS_LINK_PENDING = 'Pending';
    public static final string OPP_PAYMENT_STATUS_LINK_RECEIVED_PAID = 'Received / Paid';
    public static final string OPP_PAYMENT_STATUS_LINK_FAILED = 'Failed';

    // ================================================= User Id ===========================================================
    Public static final string UmeshUserId = [Select Id from User where name = 'Umesh'].Id;
    
    // ================================================= Task Subject ===========================================================
    Public static final string TASKSUBJECTCANDIDATEAPPLIEDAGAIN = 'Candidate has applied again for the Same Course';


    // ============================================== Invoice Payment Type Constant ============================================

        public static final string INVOICE_PAYMENT_TYPE_FULLPAYMENT = 'Full Payment';
        public static final string INVOICE_PAYMENT_TYPE_PARTIALPAYMENT = 'Partial Payment';

    // ============================================== Invoice status Constant ============================================
    public static final string INVOICE_STATUS_LINKSENT = 'Initiated';
    public static final string INVOICE_STATUS_PENDING = 'Pending';
    public static final string INVOICE_STATUS_RECEIVED_PAID = 'Realized'; 
    public static final string INVOICE_STATUS_FAILED = 'Not Realized';
    public static final string INVOICE_STATUS_PARTIALLYPENDING = 'Partially Pending';

    // ============================================== Receipt Status Constant ============================================

    public static final string RECEIPT_STATUS_LINKSENT = 'Link Sent';
    public static final string RECEIPT_STATUS_PENDING = 'Pending';
    public static final string RECEIPT_STATUS_RECEIVED_PAID = 'Received/Paid'; 
    public static final string RECEIPT_STATUS_FAILED = 'Failed';



}