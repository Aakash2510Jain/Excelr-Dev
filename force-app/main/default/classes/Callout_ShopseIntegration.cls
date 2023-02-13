public with sharing class Callout_ShopseIntegration{
    public static void OrderDetailsTotransfer(String OppOId){
        ShopseWrapper Shopwarp = new ShopseWrapper();

        try{
            if (OppOId != null) {
                list<Opportunity> opportunityDetails = [SELECT AccountId, Amount, CID__c, CloseDate, Course__c, CreatedDate, Due_Amount__c, GCLID__c, GST_State__c, Id, Loan_Amount__c, Loan_Tenure__c, Loan_Type__c, Loss_Reason__c, Name, NBFCPartner__c, OID__c, OwnerId, Payment_Captured__c, Payment_Id__c, Payment_Initiated_Date_Time__c, Payment_Initiated__c, Payment_Mode__c, Payment_Status__c, Payment_Type__c, Pricebook2Id, Reason_For_On_Hold__c, Seek_Loan__c, StageName, Type, Upfront_Amount__c, (SELECT CreatedDate, Description, Discount, Id, ListPrice, Mode__c, Name, Opportunities_Owner_s_Manager_Id__c, OpportunityId, Payment_Initiated_Date_Time__c, PricebookEntryId, Product2Id, ProductCode, Quantity, TotalPrice, Type__c, UnitPrice
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                FROM OpportunityLineItems)
                                                    FROM Opportunity 
                                                    Where Id = :OppOId];

                if (opportunityDetails.size() > 0 && !opportunityDetails.isEmpty()){
                    List<Account> OppAccountDetails = [SELECT AccountSource, Account_Number__c, Address__c, BillingAddress, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode, BillingStreet, City__c, Country__c, Course__c, CreatedDate, Current_Domain__c, Date_of_Enrollment__c, Description, Designation__c, Email__c, Id, Name, Product__c, Profession__c, Qualification__c, Quantity__c, ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStateCode, Source__c, Specialization__c, State__c, Type, Type_of_Course__c, Type__c, Website
                                                    FROM Account
                                                    where id = :opportunityDetails[0].AccountId];

                }
                
            }
            

        } catch (Exception e){

        }
    }

    public class ShopseWrapper{
        public String consumerName;
        public String firstName;
        public String middleName;
        public String lastName;
        public String amount;
        public String mobile;
        public String email;

        public String Address;
        public CustomParams customParams;
        public List<Products> products;
        public String pan;
        public String dob;
        public String gender;
        public String annualIncome;
        // public static JSON2Apex parse(String json) {
        //     return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
        // }
    }

    public class Address{
        public String line1;
        public String line2;
        public String city;
        public String state;
        public String country;
        public String pincode;
    }

    public class CustomParams{
        public String salesPersonEmail;
        public String salesPersonMobile;
        public String MyKey3;
        public String MyKey4;
        public String MyKey5;
    }

    public class AdditionalInfo{
        public String MyKey1;
        public String MyKey2;
        public String MyKey3;
        public String MyKey4;
        public String MyKey5;
    }

    public class Products{
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