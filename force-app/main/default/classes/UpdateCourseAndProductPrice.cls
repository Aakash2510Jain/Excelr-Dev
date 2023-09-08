public without sharing class UpdateCourseAndProductPrice {
    
    @AuraEnabled(cacheable=true)
    public static ProductDetailsWrapper getProductDetails(Id productId) {
        ProductDetailsWrapper result = new ProductDetailsWrapper();
        try {
            Product2 product = [SELECT Id, Name, Family, ProductCode, Type__c, LMS_ExternalId__c,
                                (SELECT Id, UnitPrice, Pricebook2.Name FROM PricebookEntries)
                                FROM Product2 WHERE Id = :productId LIMIT 1];
            
            result.productName = product.Name;
            result.family = product.Family;
            result.productCode = product.ProductCode;
            result.type = product.Type__c;
            result.lmsExternalId = product.LMS_ExternalId__c;
            
            if (product.PricebookEntries != null && !product.PricebookEntries.isEmpty()) {
                PricebookEntry pricebookEntry = product.PricebookEntries[0];
                result.unitPrice = pricebookEntry.UnitPrice;
                result.pricebookName = pricebookEntry.Pricebook2.Name;
                result.pricebookENtryId = pricebookENtry.Id;
            }
        } catch (Exception e) {
            result.errorMessage = e.getMessage();
        }
        
        return result;
    }
        
    @AuraEnabled
    public static String updateProductPrice(Id pricebookEntryId, Decimal newUnitPrice, Id prodId) {
        System.debug('pricebookEntryId--->'+pricebookEntryId);
        System.debug('newUnitPrice--->'+newUnitPrice);
        System.debug('prodId--->'+prodId);
        
        try {
            PricebookEntry pricebookEntryToUpdate = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id =: pricebookEntryId];
            pricebookEntryToUpdate.UnitPrice = newUnitPrice;
            System.debug('pricebookEntryToUpdate--->'+pricebookEntryToUpdate);
            update pricebookEntryToUpdate;
            
            // if(!string.isBlank(prodId) && prodId != null){
            //     Product2 prodRec = [SELECT Id, Type__c FROM Product2 WHERE Id =: prodId];
            //     if(prodRec.Type__c == 'Single')
            //         SingleProdUpdateCallout(prodId);
            //     else if(prodRec.Type__c == 'Combo')
            //         ComboProdPriceUpdateCallout(prodId);
            // }
            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }    
    
    public class ProductDetailsWrapper {
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String family { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String lmsExternalId { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public String pricebookEntryId { get; set; }
        @AuraEnabled public String pricebookName { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }
    
    /* Added By Anjali */
    // @future(callout = true)
    // public static void ComboProdPriceUpdateCallout(Id prodId) {
    //     system.debug('prodId -- ' + prodId);
    //     LMS_ApiCallouts.doProductPriceUpdate(prodId);
    // }
    
    // @future(callout = true)
    // public static void SingleProdUpdateCallout(Id courseId) {
    //     system.debug('courseId -- ' + courseId);
    //     LMS_ApiCallouts.doCoursePriceUpdate(courseId);
    // }
    
}