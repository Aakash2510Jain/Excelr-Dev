import { LightningElement, track, api, wire } from 'lwc';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import COURSE_FIELD from '@salesforce/schema/Lead.Course__c'; 
//import TYPE_OF_COURSE_FIELD from '@salesforce/schema/Lead.Type_of_Course__c';
import SubmitReferralDetails from '@salesforce/apex/ReferralFormController.SubmitReferralDetails';
//import QueryCityList from '@salesforce/apex/ReferralFormController.QueryCityList';
import Fetchcities from '@salesforce/apex/voiceFormLWCcontroller.Fetchcities';

import getallPicklistvlaues from '@salesforce/apex/SiteFormUtility.ReferralFormPicklists';

import GettingCountries from '@salesforce/apex/SiteFormUtility.FetchCountryRec';
import GettingStates from '@salesforce/apex/SiteFormUtility.FetchStateRec';
import GettingCities from '@salesforce/apex/SiteFormUtility.GetCityFromBigobject';
import fetchCountryAndCountryCode from '@salesforce/apex/SiteFormUtility.fetchCountryAndCountryCode';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import LEAD_OBJECT from '@salesforce/schema/Lead';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';

import LightningAlert from 'lightning/alert';
import LightningConfirm from "lightning/confirm";

export default class ReferralForm extends LightningElement {
    imageurl = EXCELR_LOGO;

    @track LeadTobeCreated = {};

    @wire(getallPicklistvlaues)
    wiredResponsePicklist({ data, error }) {
        debugger;
        if (data) {

            if (data.Courses.length > 0) {

                let tempcoursearr = [];
                for (let i = 0; i < data.Courses.length; i++) {
                    tempcoursearr.push({ label: data.Courses[i], value: data.Courses[i] });
                }
                this.CoursePicklistValues = tempcoursearr;
                this.CoursePicklistValues.sort((a, b) => (a.label > b.label) ? 1 : -1);

            }
            if (data.typeofCourses.length > 0) {

                let tempcoursearr = [];
                for (let i = 0; i < data.typeofCourses.length; i++) {
                    tempcoursearr.push({ label: data.typeofCourses[i], value: data.typeofCourses[i] });
                }
                this.TypeofCoursePicklistValues = tempcoursearr;
                this.TypeofCoursePicklistValues.sort((a, b) => (a.label > b.label) ? 1 : -1);

            }
        }
        else if (error) {
            console.log('error=', error);
        }
    }


   // =========================================================Fetch Countries States with ISDCODe And Handle =================================================
   
    //====================fetch Country

    @track countryList = [];
    @wire(GettingCountries)
    wiredCountries({ data, error }) {
        debugger;
        if (data) {

            let arr = [];
            for (let i = 0; i < data.length; i++) {
                arr.push({ label: data[i].Name, value: data[i].Id });
            }
            this.countryList = arr;
            console.log('Picklistvalue=', this.countryList);
        }
        else if (error) {
            console.log('error=', error);
        }

    }

    // handle Country Change and get States list

    @track statesList = [];
    @track DefaultCountryCode;
    @track selectedcountryname;
    HandleCountryChange(event) {
        debugger;
        //let selectedCountry=event.detail.value;
       
        let SelectedcountryId = event.detail.value;
        this.SelectedcountryId = SelectedcountryId;

        var SelectedCountry = this.countryList.find(item => item.value == this.SelectedcountryId);
        console.log('SelectedCountry',SelectedCountry);
        console.log('SelectedCountry.label--',SelectedCountry.label);
        this.selectedcountryname = SelectedCountry.label;

        //console.log('selectedcountryname--',this.selectedcountryname);
        this.LeadTobeCreated.Country__c = this.selectedcountryname;

        if(SelectedCountry.label=='India'){
            this.DefaultCountryCode="91";
             this.CountryCode="91";
             this.CountryCodeAlt="91";
             this.selectedcountryname='India';
        }else if(SelectedCountry.label=='United Kingdom'){
            this.DefaultCountryCode="44";
            this.CountryCode="44";
            this.CountryCodeAlt="44";
            this.selectedcountryname='United Kingdom';
        }else if(SelectedCountry.label=='United States'){
            this.DefaultCountryCode="1";
            this.CountryCode="1";
            this.CountryCodeAlt="1";
            this.selectedcountryname='United States';
        }

        GettingStates({
            countryid: this.SelectedcountryId
        })
            .then(result => {
                debugger;
                let arr = [];
                for (let i = 0; i < result.length; i++) {
                    arr.push({ label: result[i].Name, value: result[i].Id });
                }
                this.statesList = arr;
                this.StateDisable = false;

            // var SelectedCountry = this.countryList.find(item => item.value == this.SelectedcountryId);
            // this.selectedcountryname = SelectedCountry.label;
            // this.LeadTobeCreated.Country__c = this.selectedcountryname;

                if(this.SelectedStateId!=null){
                    this.selectedresultValue='';
                    this.booleanValue=false;

                }

            }
           

            );
            
    }




    //getting States List
    @track stateList = [];
    

    @track FetchedcityList=[];
    @track cityList=[];
    @track CityDisable=true;
    @track searchResults=[];
    @track disableInput=true;
    @track selectedstatename;

    HandleChangeState(event) {
        debugger;

        this.SelectedStateId = event.detail.value;
        var SelectedState = this.statesList.find(item => item.value == this.SelectedStateId);
        this.selectedstatename = SelectedState.label;
        this.LeadTobeCreated.State__c = this.selectedstatename;
        this.StateDisable = false;
        console.log('SelectedStateId-',this.SelectedStateId);
        console.log('SelectedcountryId-',this.SelectedcountryId);
        
        GettingCities({
            SelectedStateId: this.SelectedStateId, SelectedCountryId: this.SelectedcountryId
        })
            .then(result => {
                debugger;
                console.log('PicklistvalueCityresult=', result);
                let arr = [];
                for (let i = 0; i < result.length; i++) {
                    arr.push({ label: result[i].City__c, value: result[i].City__c });
                }
                this.FetchedcityList = arr;
                this.disableInput=false;
                this.CityDisable=false;

                console.log('PicklistvalueCity=', this.cityList);
            }

            );
    }

    @track selectedValue
    @track booleanValue=false;
    search(event){
        debugger;
        let value=event.target.value;

        let TempValue;
        if(value){
            TempValue=value;
        }

        let arr=[];
        if(TempValue){
            TempValue = TempValue.charAt(0).toUpperCase() + TempValue.slice(1);
            console.log('TempValue=',TempValue);
            const results = this.FetchedcityList.filter(product => product.value.includes(TempValue));
          
            console.log('results====',results);
            results.forEach(element => {
                arr.push({label:element.value,value:element.value});
            });
            
            
            console.log('arr====',arr);
        }

        this.searchResults=arr;
        if(this.searchResults.length>0){
            this.booleanValue=true;
        }else{
            this.booleanValue=false;
        }
        console.log('this.searchResults====',this.searchResults);
    }

  

    @track selectedSearchResult ;
    @track selectedresultValue;

    selectSearchResult(event){
        debugger;
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedresultValue=selectedValue;
        this.LeadTobeCreated.City__c = selectedValue;
        console.log('selectedValue--',selectedValue);
        this.selectedSearchResult = this.searchResults.find(
            (picklistOption) => picklistOption.value === selectedValue
          );
          console.log('selectedSearchResult--',this.selectedSearchResult);
          console.log('selectedresultValue--',this.selectedresultValue);
          
          this.clearSearchResults();
          this.booleanValue = false;
        }
        
        clearSearchResults() {
          this.searchResults = null;
        }

    

    /*@track selectedCityValue;
    HandleCityValue(event) {
        debugger;
        this.selectedCityValue = event.detail.value;
        this.LeadTobeCreated.City__c = event.detail.value;
    }*/

    @track StateCountryValue = [];
   

    @track countryCodeList = [];
    @wire(fetchCountryAndCountryCode)
    wiredcountryCountrycode({ data, error }) {
        debugger;
        if (data) {

            let arr = [];
                for (let i = 0; i < data.length; i++) {
                    arr.push({ label: data[i].CountryCode__c, value: data[i].CountryCode__c });
                }
            this.countryCodeList = arr;
        }
        else if (error) {
            console.log('error=', error);
        }

    }


    // ======================================================= Fetch Countries States with ISDCODe And Handle End Here ==================================================== 

    ReferralFormInputHandler(event) {
        debugger;

        var InputName = event.currentTarget.name;
        let Textvalue = event.target.value;
        if (InputName == 'FN') {
            this.FirstName = Textvalue;
        }
        else if (InputName == 'LN') {
            //this.Lastname = Textvalue;
            this.LeadTobeCreated.LastName = event.target.value;
        }
        else if (InputName == 'EM') {
            //this.Email = Textvalue
            this.LeadTobeCreated.Email = event.target.value;
        }
        else if (InputName == 'AltEm') {
            this.LeadTobeCreated.Alternate_Email__c = event.target.value;
        }
        else if (InputName == 'PH') {
           // this.Phone = Textvalue;
            this.LeadTobeCreated.Phone = event.target.value;
        }
        else if (InputName == 'AltPH') {
             
                this.LeadTobeCreated.Alternate_Phone__c = event.target.value;
           
        }
        else if (InputName == 'CountryISDcode') {
            // this.LeadTobeCreated.Alternate_Email__c = event.target.value;
            this.CountryCode = event.target.value;
        }
        else if (InputName == 'CountryISDcodeAlt') {
            this.CountryCodeAlt = event.target.value;
        }
        else if (InputName == 'CR') {
           // this.Coursevalue = Textvalue; 
            this.LeadTobeCreated.Course__c = event.target.value;
        } else if (InputName == 'CID') {
            //this.CID_of_Referer = Textvalue;
            this.LeadTobeCreated.CID_of_Referer__c = event.target.value;
        } else if (InputName == 'ReferenceLocation') {
            //this.location_of_reference = Textvalue;
            this.LeadTobeCreated.City__c = event.target.value;
        }else if (InputName == 'TOCR') {
            //this.type_of_Course = Textvalue; 
            this.LeadTobeCreated.Type_of_Course__c = event.target.value;
        }

    }

    @track HandleLeadCreatedisable = false;
    SaveReferralFormDetails() {
        debugger;
        this.handleSpinner();

        //&& (this.LeadTobeCreated.Email != undefined && this.LeadTobeCreated.Email != null && this.LeadTobeCreated.Email != '') && (this.LeadTobeCreated.Phone != undefined && this.LeadTobeCreated.Phone != null && this.LeadTobeCreated.Phone != '') && (this.LeadTobeCreated.Type_of_Course__c != undefined && this.LeadTobeCreated.Type_of_Course__c != null) 
        if ((this.LeadTobeCreated.LastName != undefined && this.LeadTobeCreated.LastName != null && this.LeadTobeCreated.LastName != '') 
            && (this.LeadTobeCreated.Course__c != undefined && this.LeadTobeCreated.Course__c != null && this.LeadTobeCreated.Course__c != '')  && (this.LeadTobeCreated.CID_of_Referer__c != undefined && this.LeadTobeCreated.CID_of_Referer__c != null   && this.LeadTobeCreated.CID_of_Referer__c != '') 
            &&(this.selectedresultValue!=null && this.selectedresultValue!=undefined && this.selectedresultValue!='')) {


                if (this.LeadTobeCreated.Email != null) {
                    var returnvalue = this.handleIncorrectEmail(this.LeadTobeCreated.Email)
                }
                if (this.LeadTobeCreated.Phone != null) {
                    var phoneReturnvalue = this.handleCorrectPhone(this.LeadTobeCreated.Phone);
                }
    
                if (this.LeadTobeCreated.Email != null && (this.LeadTobeCreated.Phone == null || this.LeadTobeCreated.Phone == '' || this.LeadTobeCreated.Phone == undefined  )) {
                    if ( returnvalue == true) {
                        this.createLeadFromJS();
                        
                    }
                    else{
                        alert('Incorrect Email Pattern');
                        this.HandleLeadCreatedisable = false;
    
                    }
                    
                }
                else if ( this.LeadTobeCreated.Phone != null && (this.LeadTobeCreated.Email == null || this.LeadTobeCreated.Email == '' || this.LeadTobeCreated.Email == undefined  )) {
                    if (phoneReturnvalue == true) {
                        this.createLeadFromJS();
                    }
                    else{
                        alert('Incorrect Phone Pattern');
                        this.HandleLeadCreatedisable = false;
                    }
                    
                }
                else if (this.LeadTobeCreated.Email != null && this.LeadTobeCreated.Phone != null) {
                    if (returnvalue == true && phoneReturnvalue == true) {
                        this.HandleLeadCreatedisable = true;
                        this.createLeadFromJS();
                       
    
                    }
                    else {
                        alert('Incorrect Email or Phone Pattern');
                        this.HandleLeadCreatedisable = false;
                    }
                }
                else{
                    this.createLeadFromJS();
                }

                /*var returnvalue = this.handleIncorrectEmail(this.LeadTobeCreated.Email);
                if (returnvalue == true && this.handleCorrectPhone(this.LeadTobeCreated.Phone)) {
                    this.HandleLeadCreatedisable = true;
                    SubmitReferralDetails({ Leadrec: this.LeadTobeCreated, countrycode : this.CountryCode, countrycodealternate :this.CountryCodeAlt })
                    .then(data => {

                        if (data == 'SUCCESS') {
                            this.handleConfirm('Lead Created Successfully');
                            console.log(data)
                            //alert('Lead Record created successfully');
                            this.LeadTobeCreated = {};
                            this.CountryCode = '';
                            this.CountryCodeAlt = '';
                            this.searchResults = [];
                            this.handleSpinner();
                            this.HandleLeadCreatedisable = false;
                            eval("$A.get('e.force:refreshView').fire();");

                        }
                        else if (data == 'Referral CID does not found in the system') {
                            this.handleAlert(data);
                            this.HandleLeadCreatedisable = false;
                            this.handleSpinner();
                            
                        }
                        else if (data == 'FAIL') {
                            this.handleSpinner();
                            this.HandleLeadCreatedisable = false;
                        }

                    })
                    .catch(error => {
                        this.handleSpinner();
                        this.handleAlert('Error updating or reloading records');
                        this.HandleLeadCreatedisable = false;
                    })
                }
                else{
                    alert('Incorrect Email or Phone Pattern');
                    this.HandleLeadCreatedisable = false;
                    this.handleSpinner();

                }*/

            }
            else{
                this.handleAlert('Some of the Required Fields are Empty!');
                this.handleSpinner();
                this.HandleLeadCreatedisable = false;

            }
    }

    createLeadFromJS() {
        SubmitReferralDetails({ Leadrec: this.LeadTobeCreated, countrycode: this.CountryCode, countrycodealternate: this.CountryCodeAlt })
            .then(data => {

                if (data == 'SUCCESS') {
                    this.handleConfirm('Lead Created Successfully');
                    console.log(data)
                    //alert('Lead Record created successfully');
                    this.LeadTobeCreated = {};
                    this.CountryCode = '';
                    this.CountryCodeAlt = '';
                    this.searchResults = [];
                    this.handleSpinner();
                    this.HandleLeadCreatedisable = false;
                    eval("$A.get('e.force:refreshView').fire();");

                }
                else if (data == 'Referral CID does not found in the system') {
                    this.handleAlert(data);
                    this.HandleLeadCreatedisable = false;
                    this.handleSpinner();

                }
                else if (data == 'Lead is already existing with Other person') {
                    this.handleAlert(data);
                    this.HandleLeadCreatedisable = false;
                    this.handleSpinner();

                }
                else if (data == 'FAIL') {
                    this.handleAlert('Please Provide Correct Data!!!!');
                    this.handleSpinner();
                    this.HandleLeadCreatedisable = false;
                }
                else{
                    this.handleSpinner();
                    this.HandleLeadCreatedisable = false;
                }

            })
            .catch(error => {
                this.handleSpinner();
                this.handleAlert('Error updating or reloading records');
                this.HandleLeadCreatedisable = false;
            })

    }
    handleClick(event) {
        debugger;
    }
    handleIncorrectEmail(emailtocheck) {
        debugger;

        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (emailtocheck.match(regExpEmailformat)) {
            return true;
        }
        else {
            return false;
        }

    }

    handleCorrectPhone(PhoneToverify) {
        //var regExpPhoneformat = /^[0-9]{1,10}$/g;
        var regExpPhoneformat = /^[0-9]*$/;
        if (PhoneToverify.match(regExpPhoneformat)) {
            return true;
        }
        else {
            return false;
        }
    }

    async handleConfirm(msg) {

        await LightningAlert.open({
            message: msg,
            theme: "Success",
            label: "Success"
        }).then(() => {
            console.log("###Alert Closed");
        });
        console.log("🚀 ~ result", result);
    }

    async handleAlert(msg) {
        await LightningAlert.open({
            message: msg,
            theme: "error",
            label: "Alert"
        }).then(() => {
            console.log("###Alert Closed");
        });
    }

    @track spinnerLoading = false;
    handleSpinner() {
        this.spinnerLoading = !this.spinnerLoading;
    }
}