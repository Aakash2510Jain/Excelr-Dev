public with sharing class ProductUpdateOnOppApexController{

    @AuraEnabled(Cacheable=True)
    Public static Opportunity GetOppDetail(string recordId){
        Opportunity Opp=[select Id,Expected_Revenue__c From Opportunity Where Id=:recordId];

        return Opp;
    }

    @AuraEnabled(Cacheable = True)
    Public static List<City__c> fetchCities(){
        List<City__c> citylist = [Select Name
                                  From City__c];
        system.debug('citylist=' + citylist);
        return citylist;
    }

    @AuraEnabled
    Public static List<Product2> ProdList(string mode, string typevalue, string city, list<Product2> ProdRec){
        system.debug('ProdRec===' + ProdRec);
        system.debug('mode===' + mode);
        system.debug('city===' + city);
        system.debug('typevalue===' + typevalue);
        List<Product2> ProdList = new List<Product2>();
        String CourseOne;
        String CourseThree;
        String ModeOne;
        String ModeThree;
        String CourseTwo;
        String ModeTwo;


        if (typevalue == 'Single'){
            system.debug('typevalue Inside If===' + typevalue);
            if (mode != null && city != null){
                ProdList = [Select Id, Name, Mode__c, Type__c, City__c, Description, ProductCode, (Select UnitPrice
                                                                                                   From PricebookEntries
                                                                                                   where IsActive = true)
                            From Product2
                            Where (IsActive = true AND Mode__c = :mode AND Type__c = :typevalue) OR City__c = :city];
            } else if (mode != null){
                ProdList = [Select Id, Name, Mode__c, Type__c, City__c, Description, ProductCode, (Select UnitPrice
                                                                                                   From PricebookEntries
                                                                                                   where IsActive = true)
                            From Product2
                            Where IsActive = true AND Mode__c = :mode AND Type__c = :typevalue];
            }
        } else if (typevalue == 'Combo'){

            system.debug('typevalue Inside Else===' + typevalue);
            for (Product2 Prod : ProdRec){
                system.debug('Prod=' + Prod);
                if ((Prod.Course_1__c != null && Prod.Mode_One__c != null)){
                    CourseOne = Prod.Course_1__c;
                    ModeOne = Prod.Mode_One__c;
                    system.debug('CourseOne==' + CourseOne);
                    system.debug('ModeOne==' + ModeOne);
                } else if ((Prod.Course_2__c != null && Prod.Mode_Two__c != null)){
                    CourseTwo = Prod.Course_2__c;
                    ModeTwo = Prod.Mode_Two__c;
                    system.debug('CourseTwo==' + CourseTwo);
                    system.debug('ModeTwo==' + ModeTwo);
                } else if ((Prod.Mode_Three__c != null && Prod.Course_3__c != null)){
                    CourseThree = Prod.Course_3__c;
                    ModeThree = Prod.Mode_Three__c;
                    system.debug('CourseThree==' + CourseThree);
                    system.debug('ModeThree==' + ModeThree);
                }
            }
            if (CourseOne != null && CourseTwo != null && ModeOne != null && ModeTwo != null && CourseThree == null && ModeThree == null){
                system.debug('CourseOne-->' + CourseOne);
                system.debug('CourseTwo-->' + CourseTwo);
                system.debug('ModeOne-->' + ModeOne);
                system.debug('ModeTwo-->' + ModeTwo);
                system.debug('I am Searching For Two Course');

                ProdList = [SELECT City__c, Course_1__c, Course_2__c, Discount__c, Description, Family, Id, IsActive, Mode_One__c, Mode_Two__c, Mode__c, Name, Offer__c, ProductCode, Type__c, (Select UnitPrice
                                                                                                                                                                                                From PricebookEntries
                                                                                                                                                                                                where IsActive = true)
                            From Product2
                            Where IsActive = true AND (Course_3__c = null AND Mode_Three__c = null) AND ((Course_1__r.Name = :CourseOne AND Mode_One__c = :ModeOne) OR (Course_2__r.Name = :CourseOne AND Mode_Two__c = :ModeOne)) AND ((Course_1__r.Name = :CourseTwo AND Mode_One__c = :ModeTwo) OR (Course_2__r.Name = :CourseTwo AND Mode_Two__c = :ModeTwo))];
            } else if (CourseOne != null && CourseTwo != null && ModeOne != null && ModeTwo != null && CourseThree != null && ModeThree != null){
                system.debug('I am Searching For Three Course');
                system.debug('CourseOne-->' + CourseOne);
                system.debug('CourseTwo-->' + CourseTwo);
                system.debug('CourseThree==' + CourseThree);
                system.debug('ModeOne-->' + ModeOne);
                system.debug('ModeTwo-->' + ModeTwo);
                system.debug('ModeThree-->' + ModeThree);

                ProdList = [SELECT City__c, Course_1__c, Course_2__c, Course_3__c, Discount__c, Description, Family, Id, IsActive, Mode_One__c, Mode_Three__c, Mode_Two__c, Mode__c, Name, Offer__c, ProductCode, Type__c, (Select UnitPrice
                                                                                                                                                                                                                            From PricebookEntries
                                                                                                                                                                                                                            where IsActive = true)
                            From Product2
                            Where IsActive = true AND ((Course_1__r.Name = :CourseOne AND Mode_One__c = :ModeOne) OR (Course_2__r.Name = :CourseOne AND Mode_Two__c = :ModeOne) OR (Course_3__r.Name = :CourseOne AND Mode_Three__c = :ModeOne)) AND ((Course_1__r.Name = :CourseTwo AND Mode_One__c = :ModeTwo) OR (Course_2__r.Name = :CourseTwo AND Mode_Two__c = :ModeTwo) OR (Course_3__r.Name = :CourseTwo AND Mode_Three__c = :ModeTwo)) AND ((Course_1__r.Name = :CourseThree AND Mode_One__c = :ModeThree) OR (Course_2__r.Name = :CourseThree AND Mode_Two__c = :ModeThree) OR (Course_3__r.Name = :CourseThree AND Mode_Three__c = :ModeThree))];
            }

        }
        system.debug('ProdList--->' + ProdList);
        return ProdList;
    }

    @AuraEnabled(Cacheable = True)
    Public static List<Product_Bundle__c> CourseList(){
        List<Product_Bundle__c> CourseRec = [Select Name
                                             From Product_Bundle__c];

        return CourseRec;
    }

    @AuraEnabled
    Public Static List<Add_On__c> FetchAddOns(String ProdId){
        List<Add_On__c> AddOnRecList = [Select Id, Name, Price__c, Addon_Product__c, Addon_Product__r.Name
                                        From Add_On__c
                                        Where ProductId__c = :ProdId];
        system.debug('AddOnRecList==' + AddOnRecList);
        return AddOnRecList;
    }

    @AuraEnabled
    Public static string InsertOppLineItem(List<Product2> Prodlist, List<Add_On__c> AddOnList, string oppId){

        system.debug('Prodlist=' + Prodlist);
        system.debug('AddOnList=' + AddOnList);
        List<OpportunityLineItem> oppLitemList = new List<OpportunityLineItem>();
        string message = '';
        string productName = '';
        try{
            for (Product2 prodRec : Prodlist){

                PricebookEntry PBentryRec = [Select Id, UnitPrice
                                             From PricebookEntry
                                             where Pricebook2.Name = 'Standard Price Book' AND Product2Id = :prodRec.Id];
                system.debug('PBentryRec==' + PBentryRec);
                OpportunityLineItem oppLitemRec = new OpportunityLineItem();
                oppLitemRec.Product2Id = prodRec.Id;
                oppLitemRec.Mode__c = prodRec.Mode__c;
                oppLitemRec.Type__c = prodRec.Type__c;
                //oppLitemRec.UnitPrice=prodRec.Amount__c;
                oppLitemRec.Discount = prodRec.Discount__c;
                oppLitemRec.OpportunityId = oppId;
                oppLitemRec.PricebookEntryId = PBentryRec.Id;
                if (prodRec.Discount__c != null){
                    oppLitemRec.TotalPrice = PBentryRec.UnitPrice - (PBentryRec.UnitPrice * (prodRec.Discount__c / 100));
                } else{
                    oppLitemRec.TotalPrice = PBentryRec.UnitPrice;
                }

                system.debug('oppLitemRec.TotalPrice===' + oppLitemRec.TotalPrice);
                oppLitemRec.Quantity = 1;
                oppLitemList.add(oppLitemRec);
                if(!string.isBlank(productName) )
                    productName = productName +' - '+prodRec.Name;
                else
                    productName = prodRec.Name;
            }

            for (Add_On__c AddOnRec : AddOnList){
                PricebookEntry PBentryRec = [Select Id, UnitPrice
                                             From PricebookEntry
                                             where Pricebook2.Name = 'Standard Price Book' AND Product2Id = :AddOnRec.Addon_Product__c];
                OpportunityLineItem oppLineitemRec = new OpportunityLineItem();
                oppLineitemRec.Product2Id = AddOnRec.Addon_Product__c;
                oppLineitemRec.Discount = AddOnRec.Discount__c;
                oppLineitemRec.OpportunityId = oppId;
                oppLineitemRec.PricebookEntryId = PBentryRec.Id;
                if (AddOnRec.Discount__c != null){
                    oppLineitemRec.TotalPrice = PBentryRec.UnitPrice - (PBentryRec.UnitPrice * (AddOnRec.Discount__c / 100));
                } else{
                    oppLineitemRec.TotalPrice = PBentryRec.UnitPrice;
                }

                system.debug('oppLitemRec.TotalPrice===' + oppLineitemRec.TotalPrice);
                oppLineitemRec.Quantity = 1;
                oppLitemList.add(oppLineitemRec);
                productName = productName +' - '+AddOnRec.Name;
            }
            if (!oppLitemList.IsEmpty()){

                Database.SaveResult[] results = Database.insert (oppLitemList, false);
                for (Integer i = 0, s = results.size(); i < s; i++){
                    if (!results[i].isSuccess()){
                        // report an error here //

                        // You can tell if it was an approval lock by: //
                        for (Database.Error e : results[i].getErrors()){
                            if (e.getStatusCode() == StatusCode.ENTITY_IS_LOCKED){
                                System.debug('Entity is locked !!!!');
                                // Record was locked by an approval process
                            }
                        }
                    }
                }
                Opportunity oppRec = new Opportunity();
                oppRec.Id = oppId;
                oppRec.Product_Name__c = productName;
                update oppRec;
               // insert oppLitemList;
            }
            message = 'SUCCESS';
            return message;

        } catch (Exception e){
            System.debug(' the error occure due to ' + e.getMessage());
            System.debug(' the error occure at line ' + e.getLineNumber());
            System.debug(' the error tack string  ' + e.getStackTraceString());
            return null;

        }
    }

}