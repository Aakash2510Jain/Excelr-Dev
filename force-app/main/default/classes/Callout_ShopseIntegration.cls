public without sharing class Callout_ShopseIntegration{
    public static void OrderDetailsTotransfer(String OppOId){
        ShopseWrapper Shopwarp = new ShopseWrapper();

        Map<String, invoice__c> InvoicewithOppId = new Map<String, invoice__c>();

        try{
            if (OppOId != null) {
                list<Opportunity> opportunityDetails = [SELECT AccountId, Amount, CID__c, CloseDate, Course__c, CreatedDate, Due_Amount__c, GCLID__c, GST_State__c, Id, Loan_Amount__c, Loan_Tenure__c, 
                                                        Loan_Type__c, Loss_Reason__c, Name, NBFCPartner__c, OID__c, OwnerId, Payment_Captured__c, Payment_Id__c, Payment_Initiated_Date_Time__c, Payment_Initiated__c, 
                                                        Payment_Mode__c, Payment_Status__c, Payment_Type__c, Pricebook2Id, Reason_For_On_Hold__c, Seek_Loan__c, StageName, Type, Upfront_Amount__c, 
                                                        (SELECT CreatedDate, Description, Discount, Id, ListPrice, Mode__c, Name, Opportunities_Owner_s_Manager_Id__c, OpportunityId, Payment_Initiated_Date_Time__c, PricebookEntryId, 
                                                        Product2Id,Product2.Family,Product2.Name,Product2.Offer__c,Product2.ProductCode,Product2.QuantityUnitOfMeasure,Product2.StockKeepingUnit, Product2.Type__c,
                                                        ProductCode, Quantity, TotalPrice, Type__c, UnitPrice
                                                         FROM OpportunityLineItems),
                                                         (SELECT Amount__c,CreatedDate,Due_Amount__c,Due_Date__c,GCLID__c,Id,Initiated_Date__c,Invoice_Due_Date__c,LeadInvoice__c,Lead_ManagerId__c,Mode_Terms_of_Payment__c,Opportunity__c,Status__c,
                                                         TranactionId__c,Type__c FROM Invoices__r)
                                                        FROM Opportunity 
                                                        Where Id = :OppOId];
                                                    

                if (opportunityDetails.size() > 0 && !opportunityDetails.isEmpty()){

                    Shopwarp.amount = Double.valueof(opportunityDetails[0].Amount);
                    Shopwarp.orderId = String.valueOf(opportunityDetails[0].OID__c);
                    List<Account> OppAccountDetails = [SELECT AccountSource, Address__c, BillingAddress, BillingCity, BillingCountry, BillingPostalCode, BillingState,
                                                         BillingStreet, City__c, Country__c, Course__c, CreatedDate, Current_Domain__c, Date_of_Enrollment__c, Description, Designation__c, Email__c, Id, Name,Profession__c, 
                                                         Qualification__c,ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, Source__c, Specialization__c, State__c, 
                                                         Type_of_Course__c, Website
                                                        FROM Account
                                                        where id = :opportunityDetails[0].AccountId];
                     Shopwarp.consumerName = String.valueOf(OppAccountDetails[0].Name);
                     Shopwarp.mobile = String.valueOf(OppAccountDetails[0].Name);
                     Shopwarp.email = String.valueOf(OppAccountDetails[0].Email__c);
                     Shopwarp.returnUrl = '';
                     Shopwarp.webhookUrl = '';


                     // ========================================= For Address Details ====================================================
                     Address addwrap = new Address();

                     addwrap.line1 = String.valueOf(OppAccountDetails[0].BillingStreet);
                     addwrap.line2 = '';

                     addwrap.city = String.valueOf(OppAccountDetails[0].BillingCity);
                     addwrap.state = String.valueOf(OppAccountDetails[0].BillingState);
                     addwrap.country = String.valueOf(OppAccountDetails[0].BillingCountry);
                     addwrap.pincode = String.valueOf(OppAccountDetails[0].BillingPostalCode);

                     Shopwarp.address = addwrap;

                     // ========================================= For Address Details Completed====================================================


                     // ============================================ Custom Params Details ==========================================================

                     CustomParams CustParWrap = new CustomParams();
                     CustParWrap.salesPersonEmail = '';
                     CustParWrap.salesPersonMobile = '';
                     CustParWrap.MyKey3 = '';
                     CustParWrap.MyKey4 = '';
                     CustParWrap.MyKey5 = '';

                     Shopwarp.customParams = CustParWrap;


                     // ============================================ Custom Params Details  Completed==========================================================
 

                }


                // ================================================= Invoice details ===================================================================
                if (!(opportunityDetails[0].Invoices__r).isempty() && (opportunityDetails[0].Invoices__r).size() > 0) {
                    for (Invoice__c inv : opportunityDetails[0].Invoices__r) {
                        InvoicewithOppId.put(inv.Opportunity__c, inv);
                    }

                }



                // ================================================= Product  Details ===================================================================

                list<Products> prodWraplist = new List<Products>();
                if (!(opportunityDetails[0].OpportunityLineItems).isempty() && (opportunityDetails[0].OpportunityLineItems).size() > 0) {

                   for (OpportunityLineItem OLI : opportunityDetails[0].OpportunityLineItems) {
                       Products prodWrap = new Products();
                       prodWrap.amount = String.valueof(OLI.UnitPrice);
                       prodWrap.name = String.valueOf(OLI.Name);
                       prodWrap.code = String.valueOf(OLI.ProductCode);
                       prodWrap.quantity = String.valueOf(OLI.Quantity);
                       prodWrap.skuCode = String.valueOf(OLI.Product2.StockKeepingUnit);
                       prodWrap.productId = String.valueOf(OLI.Product2Id);
                       prodWrap.category = '';
                       prodWrap.serialNo = '';
                       prodWrap.manufacturer = '';
                       prodWrap.subCategory = '';
                       prodWrap.model = String.valueOf(OLI.Product2.Family);
                       prodWrap.imeiNo = '';
                       if (!InvoicewithOppId.isEmpty()) {
                        if (InvoicewithOppId.containsKey(OLI.OpportunityId)) {
                            prodWrap.invoiceNumber = InvoicewithOppId.get(OLI.OpportunityId).Name;
                        }
                        
                       }
                       prodWraplist.add(prodWrap);
                   }
                   
                }

                Shopwarp.products = prodWraplist;
                                     
                // ============================================= Product  Details Completed ===================================================================
                string SerializedWrap = Json.serialize(Shopwarp);
                System.debug('SerializedWrap ====> ' + SerializedWrap);
                
            }
        } catch (Exception e){

        }
    }

    public class ShopseWrapper{
        public Double amount;
        public String mobile;
        public String orderId;
        public String email;
        public String consumerName;
        public String returnUrl;
        public String webhookUrl;
        public Address address;
        public CustomParams customParams;
        public List<Products> products;
        // public static JSON2Apex parse(String json) {
        //     return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
        // }
    }

    public class Address {
        public String line1;
        public String line2;
        public String city;
        public String state;
        public String country;
        public String pincode;
    }

    public class CustomParams {
        public String salesPersonEmail;
        public String salesPersonMobile;
        public String MyKey3;
        public String MyKey4;
        public String MyKey5;
    }

    public class AdditionalInfo {
        public String MyKey1;
        public String MyKey2;
        public String MyKey3;
        public String MyKey4;
        public String MyKey5;
    }

    public class Products {
        public String productId;
        public String name;
        public String invoiceNumber;
        public String catalogProductId;
        public String code;
        public String amount;
        public String quantity;
        public String skuCode;
        public String serialNo;
        public String manufacturer;
        public String category;
        public String subCategory;
        public String model;
        public String imeiNo;
        public AdditionalInfo additionalInfo;
    }

}