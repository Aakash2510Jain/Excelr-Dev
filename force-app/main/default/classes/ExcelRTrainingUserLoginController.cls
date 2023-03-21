public without sharing class ExcelRTrainingUserLoginController{
    public String userName{ get; set; }

    public String password{ get; set; }

    @RemoteAction
    public static ExcelR_Training_User__c excelRTrainerLogIn(string userName, string password){
        try{
            System.debug('userName ===> ' + userName);
            System.debug('password ===> ' + password);
            List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, OwnerId, Password__c, Username__c, Departments__c
                                                             FROM ExcelR_Training_User__c
                                                             WHERE Email__c = :userName AND Password__c = :password
                                                             LIMIT 1];
            system.debug('ExcelRTrainUser----' + ExcelRTrainUser);
            if (ExcelRTrainUser.size() > 0){
                //String currentReviewId;
                String hasCode;
                ExcelR_Training_User__c ExcelRUsr = new ExcelR_Training_User__c();
                ExcelRUsr.Email__c = ExcelRTrainUser[0].Email__c;
                ExcelRUsr.First_Name__c = ExcelRTrainUser[0].First_Name__c;
                ExcelRUsr.Last_Name__c = ExcelRTrainUser[0].Last_Name__c;
                ExcelRUsr.Username__c = ExcelRTrainUser[0].Username__c;
                ExcelRUsr.Departments__c = ExcelRTrainUser[0].Departments__c;
                ExcelRUsr.HashCode__c = ExcelRTrainUser[0].id;
                ExcelRUsr.Id = ExcelRTrainUser[0].id;
                hasCode = String.valueOf(ExcelRTrainUser);
                System.debug('The Hash Code Value');
                update ExcelRUsr;
                return ExcelRUsr;
            } else{
                return null;
            }
        } catch (exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ExcelRTrainingUserLoginController', 'excelRTrainerLogIn', e, null);
            //insert Exc;

            return null;
        }
    }

    public PageReference loginUser(){

        System.debug('userName =====>' + userName);
        System.debug('password =====>' + password);


        //String LoginPageBaseurl = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/';
        //https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/
        String LoginPageBaseurl = System.Label.LoginPageBaseurl;
        string FormPageUrl;


        //string LoginPageBaseurl = '';
        PageReference MyNewPage;

        try{
            List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Departments__c, Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
                                                             FROM ExcelR_Training_User__c
                                                             WHERE Email__c = :userName AND Password__c = :password
                                                             LIMIT 1]; //
            system.debug('ExcelRTrainUser----' + ExcelRTrainUser);
            System.debug('ExcelRTrainUser[0].Departments__c ===> ' + ExcelRTrainUser[0].Departments__c);

            List<String> DepartmentArr = ExcelRTrainUser[0].Departments__c.split(';');
            System.debug('DepartmentArr =====>   ' + DepartmentArr);

            ExcelR_Training_User__c LGEMember = new ExcelR_Training_User__c();
            String LoginHashcode = Apexpages.currentPage().getparameters().get('hascode');
            LGEMember.HashCode__c = LoginHashcode;


            if (ExcelRTrainUser.size() > 0){
                String currentExcelUserID;
                String hasCode;
                currentExcelUserID = ExcelRTrainUser[0].id;

                if (LGEMember.HashCode__c != null){

                    Cookie userHashCodeCookie = new Cookie('userHashCodeCookie', LGEMember.HashCode__c, null, (18000), true);
                    ApexPages.currentPage().setCookies(new Cookie[]{ userHashCodeCookie });
                    System.debug('userHashCodeCookie ====> ' + userHashCodeCookie);

                }

                LGEMember.Id = currentExcelUserID;
                hasCode = String.valueOf(LGEMember.HashCode__c);
                System.debug('The Hash Code Value');
                System.debug('LGEMember ===> ' + LGEMember);
                update LGEMember;

                if (LGEMember.id != null){

                    if (DepartmentArr[0] == 'Walk-In'){
                        FormPageUrl = LoginPageBaseurl + 'walkInLeadPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + LGEMember.HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                    }
                    if (DepartmentArr[0] == 'Voice'){
                        FormPageUrl = LoginPageBaseurl + 'voiceFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + LGEMember.HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                    }
                    if (DepartmentArr[0] == 'Generic'){
                        FormPageUrl = LoginPageBaseurl + 'genericLeadAdditionPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + LGEMember.HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                    }
                    if (DepartmentArr[0] == 'Chat'){
                        FormPageUrl = LoginPageBaseurl + 'chatFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + LGEMember.HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                    }
                    MyNewPage = new PageReference(FormPageUrl);
                    MyNewPage.setRedirect(true);
                }
            } else{
                //LoginPageBaseurl = LoginPageBaseurl + +'?id=' + AabaSoftAgent.HashCode__c + '&Phone=' + PhoneNumber + '&AgentId=' + AgentuniqueID + '&State=Invalid';

                loginPageBaseUrl = LoginPageBaseurl + 'chatFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&hascode=' + LGEMember.HashCode__c + '&State=Invalid';
                MyNewPage = new PageReference(LoginPageBaseurl);
                MyNewPage.setRedirect(true);
            }
            System.debug('--- pg val' + MyNewPage);
            return MyNewPage;
        } catch (exception e){
            system.debug(e.getLineNumber() + '---error Message---' + e.getMessage());
            return null;
        }
    }

    public PageReference checkExistingHashKey(){
        try{

            //String LoginPageBaseurl = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/';
            String LoginPageBaseurl = System.Label.LoginPageBaseurl;
            System.debug('LoginPageBaseurl ===> ' + LoginPageBaseurl);
            String ExistingHashcode = '';
            string FinalPageToRedirect = '';
            Boolean redirecttoLoginPage;
            List<ExcelR_Training_User__c> ExcelLGEUser = new List<ExcelR_Training_User__c>();

            String LoginHashcode = Apexpages.currentPage().getparameters().get('hascode');
            System.debug('LoginHashcode ======> ' + LoginHashcode);

            string headerdata = ApexPages.currentPage().getHeaders().get('Host');
            System.debug('headerdata ====> ' + headerdata);

            string urlvalue = Apexpages.currentPage().getUrl();
            System.debug('urlvalue =====> ' + urlvalue);
            PageReference MyNewPage;


            Cookie userHashCodeCookie = ApexPages.currentPage().getCookies().get('userHashCodeCookie');
            System.debug('userHashCodeCookie ==> ' + userHashCodeCookie);
            if (userHashCodeCookie != null && LoginHashcode != null){
                ExistingHashcode = String.valueOf(userHashCodeCookie.getValue());
                system.debug('userHashCodeCookie' + userHashCodeCookie);
                system.debug('ExistingHashcode' + ExistingHashcode);
                system.debug('LoginHashcode' + LoginHashcode);
                //abasoftUser = [Select Id , Agent_Unique_Id__c, CampaignID__c, HashCode__c From AbbaSoft_User__c Where HashCode__c =: ExistingHashcode  AND Agent_Unique_Id__c =: AgentUniqueCode];
                List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Departments__c, Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
                                                                 FROM ExcelR_Training_User__c
                                                                 WHERE HashCode__c = :ExistingHashcode
                                                                 LIMIT 1];


                List<String> DepartmentArr = new List<String>();

                if (!ExcelRTrainUser.isEmpty()){
                    DepartmentArr = ExcelRTrainUser[0].Departments__c.split(';');
                }
                system.debug('Size is ' + ExcelRTrainUser);
                if (ExcelRTrainUser.size() > 0){


                    if (ExcelRTrainUser[0].id != null){

                        if (DepartmentArr[0] == 'Walk-In'){
                            FinalPageToRedirect = LoginPageBaseurl + 'walkInLeadPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        if (DepartmentArr[0] == 'Voice'){
                            FinalPageToRedirect = LoginPageBaseurl + 'voiceFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        if (DepartmentArr[0] == 'Generic'){
                            FinalPageToRedirect = LoginPageBaseurl + 'genericLeadAdditionPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        if (DepartmentArr[0] == 'Chat'){
                            FinalPageToRedirect = LoginPageBaseurl + 'chatFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + ExcelRTrainUser[0].Departments__c + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        MyNewPage = new PageReference(FinalPageToRedirect);
                        MyNewPage.setRedirect(true);
                        return MyNewPage;
                    }
                    //FinalPageToRedirect = CustomerDetailPageBaseUrl + '?id=' + ExistingHashcode + '&Phone=' + PhoneNumber + '&AgentId=' + AgentUniqueCode;
                    //redirecttoLoginPage = false;
                } else{
                    // if (ExistingHashcode == LoginHashcode){
                    //     System.debug('I am in inside  loginhashcode not equals to ExistingHashcode ');
                        
                    //     System.debug('I am in inside  loginhashcode equals to ExistingHashcode ');
                    //     LoginHashcode = Utility.generateRandomString();
                    //     String LoginPageBaseurlsubstring = LoginPageBaseurl.Substring(0,LoginPageBaseurl.length()-1);
                    //     FinalPageToRedirect = LoginPageBaseurlsubstring + '?hascode=' + LoginHashcode;

                    // } else{
                    // }

                }
                // System.debug('FinalPageToRedirect  ====> ' + FinalPageToRedirect);
                // PageReference FormPage = new PageReference(FinalPageToRedirect);
                // FormPage.setRedirect(true);
                // return FormPage;
            } else if ((LoginHashcode == '' || LoginHashcode == null) && userHashCodeCookie == null){
                LoginHashcode = Utility.generateRandomString();
                System.debug('LoginHashcode =======> ' + LoginHashcode);

                FinalPageToRedirect = LoginPageBaseurl + '?hascode=' + LoginHashcode;
                System.debug('FinalPageToRedirect =====> ' + FinalPageToRedirect);

                PageReference ExcelrUserLoginPage = new PageReference(FinalPageToRedirect);
                ExcelrUserLoginPage.setRedirect(true);
                return ExcelrUserLoginPage;
            } else if (LoginHashcode == null && userHashCodeCookie != null){

                List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Departments__c, Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
                                                                 FROM ExcelR_Training_User__c
                                                                 WHERE HashCode__c = :String.valueOf(userHashCodeCookie.getValue())];



                if (ExcelRTrainUser.size() > 0){

                    String departments = String.valueof(ExcelRTrainUser[0].Departments__c);


                    List<String> DepartmentArr = ExcelRTrainUser[0].Departments__c.split(';');
                    System.debug('DepartmentArr =====>   ' + DepartmentArr);


                    if (ExcelRTrainUser[0].id != null){

                        if (DepartmentArr[0] == 'Walk-In'){
                            FinalPageToRedirect = LoginPageBaseurl + 'walkInLeadPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + departments + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        if (DepartmentArr[0] == 'Voice'){
                            FinalPageToRedirect = LoginPageBaseurl + 'voiceFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + departments + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        if (DepartmentArr[0] == 'Generic'){
                            FinalPageToRedirect = LoginPageBaseurl + 'genericLeadAdditionPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + departments + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        if (DepartmentArr[0] == 'Chat'){
                            FinalPageToRedirect = LoginPageBaseurl + 'chatFormPage' + '?id=' + ExcelRTrainUser[0].Id + '&departments=' + departments + '&hascode=' + ExcelRTrainUser[0].HashCode__c + '&AgentName=' + ExcelRTrainUser[0].First_Name__c + ' ' + ExcelRTrainUser[0].Last_Name__c;
                        }
                        MyNewPage = new PageReference(FinalPageToRedirect);
                        MyNewPage.setRedirect(true);
                    }
                    //FinalPageToRedirect = CustomerDetailPageBaseUrl + '?id=' + ExistingHashcode + '&Phone=' + PhoneNumber + '&AgentId=' + AgentUniqueCode;
                    //redirecttoLoginPage = false;
                } else{
                    LoginHashcode = Utility.generateRandomString();
                    String LoginPageBaseurlsubstring = LoginPageBaseurl.Substring(0,LoginPageBaseurl.length()-1);
                    FinalPageToRedirect = LoginPageBaseurlsubstring + '?hascode=' + LoginHashcode;
                }
                System.debug('FinalPageToRedirect  ====> ' + FinalPageToRedirect);
                PageReference FormPage = new PageReference(FinalPageToRedirect);
                FormPage.setRedirect(true);
                return FormPage;
            }

            // https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage
            return null;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ExcelRTrainingUserLoginController', 'checkExistingHashKey', e, null);
            return null;
        }
    }

}