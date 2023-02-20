import { api, LightningElement, track, wire } from 'lwc';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';
import getLead from '@salesforce/apex/ChatFormLWCcontroller.getLead';
import getApplication from '@salesforce/apex/ChatFormLWCcontroller.getApplication';
import EmailIsm from '@salesforce/apex/ChatFormLWCcontroller.EmailIsm';
import getMember from '@salesforce/apex/ChatFormLWCcontroller.getMember';

//import getPickiststatusOfTask from '@salesforce/apex/ChatFormLWCcontroller.getPickiststatusOfTask';
//import getPickistpriorityOfTask from '@salesforce/apex/ChatFormLWCcontroller.getPickistpriorityOfTask';
import createTask from '@salesforce/apex/ChatFormLWCcontroller.createTaskForVoice';


import createLead from '@salesforce/apex/ChatFormLWCcontroller.createLead';
import createApplication from '@salesforce/apex/ChatFormLWCcontroller.CreateApplication';

import FetchStateCounty from '@salesforce/apex/ChatFormLWCcontroller.FetchStateCounty';
import Fetchcities from '@salesforce/apex/ChatFormLWCcontroller.Fetchcities';
import fetchCountryAndCountryCode from '@salesforce/apex/GenericLeadLWCcontroller.fetchCountryAndCountryCode';

import FetchCountriesStateWithISDcode from '@salesforce/apex/voiceFormLWCcontroller.getCountryStateAndISDCode';
import QueryPastLeads from '@salesforce/apex/ChatFormLWCcontroller.QueryPastLeads';
import LightningAlert from 'lightning/alert';
//import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';


// ================================== All Picklist values ==================================

import getallPicklistvlaues from '@salesforce/apex/SiteFormUtility.getallPicklistvlaues';

import GettingCountries from '@salesforce/apex/SiteFormUtility.FetchCountryRec';
import GettingStates from '@salesforce/apex/SiteFormUtility.FetchStateRec';
import GettingCities from '@salesforce/apex/SiteFormUtility.FetchCitiesrec';


const applicationcolumns = [{ label: 'Name', fieldName: 'Name' },
{ label: 'Course', fieldName: 'Course__c' },
{ label: 'Apply Date', fieldName: 'Applied_Date_Time__c', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true } },
{ label: 'LID', fieldName: 'LID__c' },]

const LeadListcolumns = [{ label: 'Name', fieldName: 'Name' },
{ label: 'Course', fieldName: 'Course__c' },
{ label: 'Email', fieldName: 'Email' },
{ label: 'Phone', fieldName: 'Phone' },
{ label: 'Owner', fieldName: 'OwnerName' },
{ label: 'Product', fieldName: 'ProductName' },
{ label: 'Status', fieldName: 'Status' },
{ label: 'Total Call', fieldName: 'Total_Calls__c' },
{ label: 'Total Connected Call', fieldName: 'Total_Connected_Call__c' },
{ label: 'Email', fieldName: 'Email' },
{ label: 'Phone', fieldName: 'Phone' },

]


export default class chatForm extends LightningElement {

    @track LeadTobeCreated = {};
    @track taskTobeCreated = {};
    imageurl = EXCELR_LOGO;
    //feilds from schema
    @track ifdataNotFound = false;
    @track ownerEmail;
    @track ismBTNdisAble = true;


    @track CourceLead;
    @track courseforApp;
    @api recordId;
    @track newBTNdisAble = false;
    @track objectApiName = 'Lead';

    @track gruoMemberId;
    @track ismeId;
    @track inPutValue;
    @track objectList;
    @track columns;
    @track isShowModal = false;
    @track showtaskModal = false;
    @track namValue;
    @track lNameValue;
    @track emailValue;
    @track phoneValue;
    @track lStatus;
    @track compnyValue;
    @track groupMemList = [];
    @track data;
    @api selectedrecordDetails;
    @api agentrecid;
    @api DepartmentListstring;
    @api hashcode;
    @track DepartmentList = [];
    @track mapData = [];
    @track showFromOrEmpty = false;

    @track dataForApp;
    @track Leaddata = [];
    @track showPastLeads = false;
    @track showSearchDetails = true;
    @track LeadrecordsNotFound = false;
    @track LeadrecordsFound = false;

    @track showapplicationMOdal = false;
    @track appbtndisAble = true;
    @track commentsValue;

    connectedCallback() {
        //defined a varibale
        //this.handlecourseList();
        this.convertStringtoList();

    }

    convertStringtoList() {
        this.DepartmentList = this.DepartmentListstring.split(';');
        for (var key in this.DepartmentList) {
            this.mapData.push({ label: this.DepartmentList[key], value: this.DepartmentList[key] }); //Here we are creating the array to show on UI.
        }
    }


    emailHandler(Event) {
        debugger;
        let EmailOrPhone = Event.target.value;
        this.inPutValue = EmailOrPhone;
    }

    @track CaptureOwnerId;
    @track captureownerName;
    @track taskBTNdisAble = true;
    serachLeadBTN() {
        this.handleClick();
        debugger;
        getLead({ EmailOrPhone: this.inPutValue })
            .then(data => {
                debugger;

                this.showFromOrEmpty = true;
                this.data = data;
                if (this.data.length > 0) {
                    //  this.newBTNdisAble = true;
                    this.taskBTNdisAble = false;
                    this.recordId = this.data[0].Id;
                    this.ownerEmail = data[0].Owner_Email__c;
                    this.CaptureOwnerId = data[0].OwnerId;
                    this.captureownerName = data[0].Owner.Name;
                    this.handleClick();
                    console.log(data);
                    console.log(this.data);
                    console.log(this.data[0].Id)
                    this.ismBTNdisAble = false;
                    this.ifdataNotFound = false;
                    this.appbtndisAble = false;
                }
                if (this.data.length == 0) {
                    this.handleClick();
                    this.ifdataNotFound = true;
                    this.taskBTNdisAble = true;
                    //  this.newBTNdisAble = false;
                    this.ismBTNdisAble = true;
                    this.data = false;
                    this.appbtndisAble = true;
                }

            })
            .catch(error => {
                console.log(error);

            })
    }

    @wire(getApplication, { lid: '$recordId' })
    wireResponse(data, error) {
        debugger;
        if (data) {
            this.dataForApp = data;
            console.log(this.dataForApp);
            this.columns = applicationcolumns;

            if (Array.isArray(this.dataForApp.data)) {
                if (this.dataForApp.data.length > 0) {
                    //this.appbtndisAble = false;

                }
                else if (this.dataForApp.data.length == 0) {
                    //this.appbtndisAble = true;
                }
            }
        }
        if (error) {
            this.ifdataNotFound = true;

        }

    }


    @track LeadSourcePicklist = [];
    @track courssweList = [];
    @track LeadGenPathPicklistvalue = [];
    @track LeadMediumPicklist = [];

    @track priorityList = [];
    @track StatusList = [];

    @wire(getallPicklistvlaues)
    wiredResponsePicklist({ data, error }) {
        debugger;
        if (data) {

            if (data.Courses.length > 0) {

                let tempcoursearr = [];
                for (let i = 0; i < data.Courses.length; i++) {
                    tempcoursearr.push({ label: data.Courses[i], value: data.Courses[i] });
                }
                this.courssweList = tempcoursearr;
                this.courssweList.sort((a, b) => (a.label > b.label) ? 1 : -1);

            }

            if (data.Sources.length > 0) {

                let tempSourcearr = [];
                for (let i = 0; i < data.Sources.length; i++) {
                    tempSourcearr.push({ label: data.Sources[i], value: data.Sources[i] });
                }
                this.LeadSourcePicklist = tempSourcearr;
                this.LeadSourcePicklist.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('Picklistvalue=', this.LeadSourcePicklist);

            }

            if (data.LeadGenPath.length > 0) {

                let tempLeadGenPatharr = [];
                for (let i = 0; i < data.LeadGenPath.length; i++) {
                    tempLeadGenPatharr.push({ label: data.LeadGenPath[i], value: data.LeadGenPath[i] });
                }
                this.LeadGenPathPicklistvalue = tempLeadGenPatharr;
                this.LeadGenPathPicklistvalue.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('Picklistvalue=', this.LeadGenPathPicklistvalue);

            }

            if (data.Medium.length > 0) {

                let tempMediumarr = [];
                for (let i = 0; i < data.Medium.length; i++) {
                    tempMediumarr.push({ label: data.Medium[i], value: data.Medium[i] });
                }
                this.LeadMediumPicklist = tempMediumarr;
                this.LeadMediumPicklist.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('Picklistvalue=', this.LeadMediumPicklist);

            }

            if (data.TaskStatus.length > 0) {

                let tempTaskStatusarr = [];
                for (let i = 0; i < data.TaskStatus.length; i++) {
                    tempTaskStatusarr.push({ label: data.TaskStatus[i], value: data.TaskStatus[i] });
                }

                this.StatusList = tempTaskStatusarr;
                this.StatusList.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('statusList--', this.StatusList);

            }

            if (data.TaskPriority.length > 0) {
                let tempTaskPriorityarr = [];
                for (let i = 0; i < data.TaskPriority.length; i++) {
                    tempTaskPriorityarr.push({ label: data.TaskPriority[i], value: data.TaskPriority[i] });
                }

                this.priorityList = tempTaskPriorityarr;
                this.priorityList.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('statusList--', this.priorityList);

            }

        }
        else if (error) {
            console.log('error=', error);
        }
    }


    // =========================================================Fetch Countries States with ISDCODe And Handle =================================================
    //@track CountriesPicklistValue = [];
    // @track countriesSateISDCodelist = [];
    /*@wire(FetchCountriesStateWithISDcode)
    wiredCounstriesStatesWithISD({ data, error }) {
        debugger;
        if (data) {
            this.countriesSateISDCodelist = data;

            let arr = [];
            for (let i = 0; i < data.length; i++) {
                arr.push({ label: data[i].MasterLabel, value: data[i].MasterLabel });
            }
            this.CountriesPicklistValue = arr;
            console.log('Picklistvalue=', this.CountriesPicklistValue);
        }
        else if (error) {
            console.log('error=', error);
        }

    }*/
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
    HandleCountryChange(event) {
        debugger;
        let SelectedcountryId = event.detail.value;
        this.SelectedcountryId = SelectedcountryId;

        var SelectedCountry = this.countryList.find(item => item.value == this.SelectedcountryId);
        this.LeadTobeCreated.Country = SelectedCountry.label;

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

                console.log('Picklistvalue=', this.statesList);
            }

            );
    }




    //getting States List
    @track stateList = [];
    /*@wire(GettingStates)
    wiredCounstriesStatesWithISD({ data, error }) {
        debugger;
        if (data) {

            let arr = [];
            for (let i = 0; i < data.length; i++) {
                arr.push({ label: data[i].Name, value: data[i].Id });
            }
            this.stateList = arr;
            console.log('Picklistvalue=', this.countryList);
        }
        else if (error) {
            console.log('error=', error);
        }

    }*/


    @track SelectedCountryStateList = [];
    @track SelectedCountryISCode;
    /*HandleChangeCountry(event) {
        debugger;
        let Selectedcountry = event.detail.value;
        this.CountryValue = Selectedcountry;
        this.LeadTobeCreated.Country = event.detail.value;

        var SelectedcountryStateISDCode = this.countriesSateISDCodelist.find(item => item.MasterLabel == Selectedcountry);
        this.SelectedCountryISCode = SelectedcountryStateISDCode.Country_Code__c;
        //this.countrycodevalue = countrycode.CountryCode__c;
        let tempStateArr = [];
        var tempStateString = SelectedcountryStateISDCode.States__c;
        var tempStateArrafterCommaSeperated = tempStateString.split(',');
        for (let i = 0; i < tempStateArrafterCommaSeperated.length; i++) {
            tempStateArr.push({ label: tempStateArrafterCommaSeperated[i], value: tempStateArrafterCommaSeperated[i] });
        }
        this.SelectedCountryStateList = tempStateArr;
        this.StateDisable = false;

    }*/

    HandleChangeState(event) {
        debugger;

        this.SelectedStateId = event.detail.value;
        var SelectedState = this.statesList.find(item => item.value == this.SelectedStateId);

        this.LeadTobeCreated.State = SelectedState.label;
        this.StateDisable = false;
        /*GettingCities({
            SelectedStateId: this.SelectedStateId, SelectedCountryId: this.SelectedcountryId
        })
            .then(result => {
                debugger;
                let arr = [];
                for (let i = 0; i < result.length; i++) {
                    arr.push({ label: result[i].Name, value: result[i].Id });
                }
                this.statesList = arr;

                console.log('Picklistvalue=', this.statesList);
            }

            );*/



    }

    HandleCityValue(event) {
        this.cityValue = event.detail.value;
        this.LeadTobeCreated.City = event.detail.value;
    }


    // ======================================================= Fetch Countries States with ISDCODe And Handle End Here ==================================================== 


    @track StateCountryValue = [];
    /*@wire(FetchStateCounty)
    WiredResponse({ data, error }) {
        debugger;
        if (data) {
            console.log('StateCountryValuedata=', data);
            this.StateCountryValue = data;
            console.log('StateCountryValue=', this.StateCountryValue);
        }
        else if (error) {
            console.log('error=', error);
        }

    }*/

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

    /* handleCountrycode(country) {
         debugger;
         let countrycode;
         country = country.toLowerCase();
         country = country.charAt(0).toUpperCase() + country.slice(1);
         countrycode = this.countryCodeList.find(item => item.Name == country);
         if (countrycode != undefined) {
             this.countrycodevalue = countrycode.CountryCode__c;
         }
         else {
             this.countrycodevalue = '';
         }
 
 
     }*/

   

    @track MediumValue;

    HandleMedium(event) {
        debugger;
        let Medium = event.target.value;
        this.MediumValue = Medium;
    }

    @track CityPicklistValue = [];
    @track cityValue;
    /*@wire(Fetchcities)
    WiredResponsecities({ data, error }) {
        debugger;
        if (data) {
            console.log('CityValuedata=', data);
            let arr = [];
            for (let i = 0; i < data.length; i++) {
                arr.push({ label: data[i].City__c, value: data[i].City__c });
            }
            this.CityPicklistValue = arr;
            console.log('Picklistvalue=', this.CityPicklistValue);
        }
        else if (error) {
            console.log('error=', error);
        }

    }

    get CityOptions() {
        return this.CityPicklistValue;
    }*/

    @track CountryDisable = true;
    @track StateDisable = true;
    @track InputCity = false;
    @track StateValue;
    @track CountryValue;
    @track selectedCountryId;
    /*HandleCityStatus(event) {

        debugger;
        let city = event.detail.value;
        if (city) {
            this.cityValue = city;
            let state;
            let TempValue;
            let country;
            TempValue = city;

            console.log('Tempstate=', TempValue);

            if (TempValue == "Other") {
                this.StateDisable = false;
                this.CountryDisable = false;
                this.InputCity = true;
                alert('Please Type Your State and Country');
            }
            else {
                this.StateDisable = true;
                this.CountryDisable = true;
                this.InputCity = false;
            }

            if (TempValue) {
                TempValue = TempValue.charAt(0).toUpperCase() + TempValue.slice(1);
                console.log('Tempstate2=', TempValue);
                state = this.StateCountryValue.find(item => item.City__c == TempValue);
                country = this.StateCountryValue.find(item => item.City__c == TempValue);
                console.log('state=', state);

            }
            if (state) {
                this.StateValue = state.State__c;
                this.CountryValue = country.Country__c;
                console.log('StateValue=', this.StateValue);


            }
            else {
                this.StateValue = '';
                this.CountryValue = '';
            }

            if (this.CountryValue) {
                //countrycode = this.countryCodeList.find(item => item.Name == this.CountryValue);
                //this.countrycodevalue = countrycode.CountryCode__c;
                this.handleCountrycode(this.CountryValue);
            }


            console.log('state=', this.StateValue);
        }

    }

    @track UserInputCity
    HandleUserCityStatus(event) {
        let value = event.target.value;
        if (this.cityValue == 'Other') {
            this.UserInputCity = value;
        }

    }

    HandleChangeStateCountry(event) {
        if (this.cityValue == 'Other') {

            debugger;
            let value = event.target.value;

            if (event.target.name == "State") {

                this.StateValue = value;
            }
            if (event.target.name == "Country") {

                this.CountryValue = value;
                if (this.CountryValue) {
                    this.handleCountrycode(this.CountryValue);
                }
            }
        }

    }*/
    createTaskRec() {
        debugger;
        console.log('captureownerId', this.CaptureOwnerId);
        if ((this.subjectvalue != null && this.subjectvalue != undefined && this.subjectvalue != '') && (this.CaptureOwnerId != null && this.CaptureOwnerId != undefined && this.CaptureOwnerId != '') && (this.priorityValue != null && this.priorityValue != undefined && this.priorityValue != '') && (this.statusValue != null && this.statusValue != undefined && this.statusValue != '')) {
            createTask({ subject: this.subjectvalue, assignto: this.CaptureOwnerId, priority: this.priorityValue, status: this.statusValue, duedate: this.DuedateValue, comments: this.comValue, followupDate: this.followupValue, leadId: this.recordId })

                .then((result) => {
                    console.log('result', result);
                    if (result == 'Success') {
                        this.handleConfirm('Task Created Successfully');
                        this.showtaskModal = false;
                    }

                })
                .catch((error) => {
                    this.error = error;
                    console.log('error', error);
                });
        }
        else {
            alert('Mandatory Fields are Empty,Please Check and fill that Field(s)!! ');
        }


    }

    //open modal
    newhLeadBTN() {
        debugger;
        this.isShowModal = true;
        //this.getPuckistOflead();
    }

    @track showtaskModal = false;
    newTaskBTN() {
        debugger;
        this.showtaskModal = true;
    }

    hideshowTaskModal() {
        this.showtaskModal = false;
    }

    //close modal from innner button
    handleCancel() {
        debugger;
        this.isShowModal = false;
        this.showtaskModal = false;
        this.namValue = '';
        this.lNameValue = '';
        this.commentsValue = '';
        this.emailValue = '';
        this.phoneValue = '';
        this.alterMobileValue = '';
        this.alterEmailValue = '';
        this.CourceLead = '';
        this.CountryValue = '';
        this.cityValue = '';
        this.Leadvalue = '';
        this.SelectedCountryStateList = [];

        this.LeadTobeCreated = {};
        if (this.SelectedCountryStateList.length == 0) {
            this.StateDisable = true;
        }

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

    // FnameChange(Event) {
    //     debugger;
    //     let firstname = Event.target.value;
    //     this.namValue = firstname;
    // }

    @track CountryCode
    @track CountryCodeAlt

    LeadCreationHandler(event) {
        debugger;
        var InputName = event.currentTarget.name;
        if (InputName == 'LN') {
            this.LeadTobeCreated.LastName = event.target.value;
        }
        if (InputName == 'Em') {
            this.LeadTobeCreated.Email = event.target.value;
        }
        if (InputName == 'AltEm') {
            this.LeadTobeCreated.Alternate_Email__c = event.target.value;
        }
        if (InputName == 'Country') {
            this.LeadTobeCreated.Country = event.target.value;
        }

        if (InputName == 'State') {
            this.LeadTobeCreated.State = event.target.value;
        }
        if (InputName == 'UserCity') {
            this.LeadTobeCreated.City = event.target.value;
        }
        if (InputName == 'CountryISDcode') {
            // this.LeadTobeCreated.Alternate_Email__c = event.target.value;
            this.CountryCode = event.target.value;
        }
        if (InputName == 'PH') {
            this.LeadTobeCreated.Phone = event.target.value;
        }
        if (InputName == 'CountryISDcodeAlt') {
            this.CountryCodeAlt = event.target.value;
        }
        if (InputName == 'AltPH') {
            this.LeadTobeCreated.Alternate_Phone__c = event.target.value;
        }
        if (InputName == 'course') {
            this.LeadTobeCreated.Course__c = event.target.value;
        }
        if (InputName == 'LGPath') {
            this.LeadTobeCreated.Lead_Gen_Path__c = event.target.value;
        }
        if (InputName == 'Source') {
            this.LeadTobeCreated.LeadSource = event.target.value;
        }
        if (InputName == 'Medium') {
            this.LeadTobeCreated.UTM_Medium__c = event.target.value;
        }
        if (InputName == 'VID') {
            this.LeadTobeCreated.Visitor_ID__c = event.target.value;
        }

        if (InputName == 'TransVal') {
            this.LeadTobeCreated.Transcript__c = event.target.value;
        }
        if (InputName == 'PageUrl') {
            this.LeadTobeCreated.Enter_UTM_Link__c = event.target.value;
        }
        if (InputName == 'Comments') {
            this.LeadTobeCreated.Comments__c = event.target.value;
        }


    }
    /*LnameChange(event) {
        debugger;


        let lasttname = event.target.value;
        this.lNameValue = lasttname;
    }
    EmailChange(event) {
        debugger;
        let email = event.target.value;
        //var returnvalue = this.handleIncorrectEmail(email)
        this.emailValue = email;

    }

    @track Leadvalue;
    ldGenPathValue(event) {
        debugger;
        this.Leadvalue = event.target.value;
    }


    @track SourceValue;
    HandleSource(event) {
        debugger;
        let Source = event.target.value;
        this.SourceValue = Source;
    }

    @track alterEmailValue;
    AlterEmailChange(Event) {
        this.alterEmailValue = Event.target.value;
    }
    PhoneChange(Event) {
        debugger;
        let phone = Event.target.value;
        this.phoneValue = phone;
    }

    @track alterMobileValue
    AlterPhoneChange(Event) {
        this.alterMobileValue = Event.target.value;
    }

    StatusChange(Event) {
        debugger;
        let statuss = Event.target.value;
        this.lStatus = statuss;
    }*/

    /*CompanyChange(event) {
        debugger;
        let cname = event.target.value;
        this.compnyValue = cname;
    }

    handleChange(event) {
        debugger;
        let selectedValue = event.detail.value;
        this.ismeId = selectedValue;
        console.log('MEMLIST---', this.groupMemList);
        this.gruoMemberId = this.groupMemList.find(item => item.Group_Member__c == selectedValue).Id;
        //this.groupMemList[this.ismeId];
    }*/
   /* courceHandler(event) {
        debugger;
        let selectedCource = event.detail.value;
        this.CourceLead = selectedCource;
    }
    @track cityValue;
    HandleCity(event) {
        debugger;
        let city = event.target.value;
        this.cityValue = city;
    }
    @track sourceValue;
    HandleSource(event) {
        debugger;
        let source = event.target.value;
        this.sourceValue = source;
    }
    @track MediumValue;
    HandleMedium(event) {
        debugger;
        let medium = event.target.value;
        this.MediumValue = medium;
    }
    HandleComments(event) {
        let comment = event.target.value;
        this.commentsValue = comment;
    }

    @track VisitorIdValue;
    HandleVisitorId(event) {
        debugger;
        let VId = event.target.value;
        this.VisitorIdValue = VId;
    }
    @track TranscriptValue;
    HandleTranscript(event) {
        debugger;
        let Trans = event.target.value;
        this.TranscriptValue = Trans;
    }
    @track PageUrlValue;
    HandlePageURL(event) {
        debugger;
        let Purl = event.target.value;
        this.PageUrlValue = Purl;
    }*/


    // ==================================== task Handlers ========================================
    @track subjectvalue
    subjectHandler(event) {
        debugger;
        let selectedSubject = event.target.value;
        this.subjectvalue = selectedSubject;
    }

    @track statusValue;
    statusHandler(event) {
        debugger;
        let selectedStatus = event.detail.value;
        this.statusValue = selectedStatus;
    }

    @track DuedateValue;
    duedateHandler(event) {
        debugger;
        let selectedDuedate = event.detail.value;
        this.DuedateValue = selectedDuedate;

    }

    @track comValue;
    commentHandler(event) {
        debugger;
        let selectedComment = event.target.value;
        this.comValue = selectedComment;
    }
    @track followupValue;
    followupHandler(event) {
        debugger;
        let selectedfollowup = event.target.value;
        this.followupValue = selectedfollowup;
    }


    @track priorityValue;
    priorityHandler(event) {
        debugger;
        let selectedPriority = event.detail.value;
        this.priorityValue = selectedPriority;
    }

    @track statusValue;
    statusHandler(event) {
        debugger;
        let selectedStatus = event.detail.value;
        this.statusValue = selectedStatus;
    }
    // ===============================================task handler Completed ===============================

    notifyismBTN() {
        this.handleClick();
        debugger;
        EmailIsm({ LiD: this.recordId, ownerMail: this.ownerEmail })
            .then(result => {
                debugger;
                this.ismBTNdisAble = true;
                this.handleClick();
                this.handleConfirm('Email sent successfully');

            })
            .catch(error => {
                this.handleAlert('Email not sent');
            })
    }

    /*@wire(getMember)
    wireRes(data, error) {
        if (data) {
            debugger;
            this.groupMemList = data.data;
            console.log('Picklist-----', this.groupMemList);
            let grmId = [];
            let options = [];
            if (data.data != undefined) {
                console.log('Picklist-----', data);
                for (var key in data.data) {
                    options.push({ label: data.data[key].Group_Member__r.Name, value: data.data[key].Group_Member__c });
                    grmId.push(data.data[key].Id)
                    console.log(data.data[key].Id)
                }
                if (this.ismeId == data.data[key].Group_Member__c) {
                    this.gruoMemberId = grmId;
                    console.log(`im inside the for if to match the value ${this.gruoMemberId}`);
                }
                console.log(`im  the for if to match the value ${this.gruoMemberId}`);

            }
            console.log()
            console.log(options);
            this.objectList = options;
            console.log(data);
            console.log(this.objectList);

        }
        if (error) {

        }
    }*/

    /*@wire(getPuckistOflead)
    wireRs({ error, data }) {
        if (data) {
            let options = []
            for (const [key, value] of Object.entries(data)) {
                options.push({
                    label: key,
                    value: value
                })
                console.log(`${key}: ${value}`);
            }
            this.courssweList = options;
            this.courssweList.sort((a, b) => (a.label > b.label) ? 1 : -1);

            console.log(data)
        }
        if (error) {

        }
    }*/

    // getPickiststatusOfTask
    /*@wire(getPickiststatusOfTask)
    wiredRs({ error, data }) {
        debugger;
        if (data) {
            debugger;
            let options = [];
            for (const [key, value] of Object.entries(data)) {
                options.push({
                    label: key,
                    value: value
                })
                console.log(`${key}: ${value}`);
            }
            this.StatusList = options;
            this.StatusList.sort((a, b) => (a.label > b.label) ? 1 : -1);
            console.log(data);
            console.log('statusList--', this.StatusList);
        }
        if (error) {
            console.log('error=', error);
        }
    }*/
    //getPickistpriorityOfTask
    /*@wire(getPickistpriorityOfTask)
    wireRs({ error, data }) {
        if (data) {
            let options = []
            for (const [key, value] of Object.entries(data)) {
                options.push({
                    label: key,
                    value: value
                })
                console.log(`${key}: ${value}`);
            }
            this.priorityList = options;
            this.priorityList.sort((a, b) => (a.label > b.label) ? 1 : -1);
            console.log(data)
        }
        if (error) {

        }
    }*/

    /*handlecourseList() {
        getPuckistOflead()
            .then(result => {
                ///this.data = result;
                let options = []
                for (const [key, value] of Object.entries(result)) {
                    options.push({
                        label: key,
                        value: value
                    })
                    console.log(`${key}: ${value}`);
                }
                this.courssweList = options;
                console.log(courssweList)
            })
            .catch(error => {
                this.error = error;
            });
    }*/

    @track HandleLeadCreatedisable = false;

    createNewLead() {
        console.log('transcript', this.TranscriptValue);
        console.log('lNameValue', this.lNameValue);
        this.LeadTobeCreated.ExcelR_Training_User__c = this.agentrecid;
        //(this.namValue!=undefined && this.namValue!=null && this.namValue!=''  ) && 

        if ((this.LeadTobeCreated.LastName != undefined && this.LeadTobeCreated.LastName != null && this.LeadTobeCreated.LastName != '') && (this.LeadTobeCreated.Email != undefined && this.LeadTobeCreated.Email != null && this.LeadTobeCreated.Email != '') && (this.LeadTobeCreated.Phone != undefined && this.LeadTobeCreated.Phone != null && this.LeadTobeCreated.Phone != '')
            && (this.LeadTobeCreated.Course__c != undefined && this.LeadTobeCreated.Course__c != null && this.LeadTobeCreated.Course__c != '') && (this.LeadTobeCreated.City != undefined && this.LeadTobeCreated.City != null && this.LeadTobeCreated.City != '') && (this.LeadTobeCreated.LeadSource != undefined && this.LeadTobeCreated.LeadSource != null && this.LeadTobeCreated.LeadSource != '')
            && (this.LeadTobeCreated.UTM_Medium__c != undefined && this.LeadTobeCreated.UTM_Medium__c != null && this.LeadTobeCreated.UTM_Medium__c != '') &&
            (this.LeadTobeCreated.Visitor_ID__c != undefined && this.LeadTobeCreated.Visitor_ID__c != null && this.LeadTobeCreated.Visitor_ID__c != '') && (this.LeadTobeCreated.Transcript__c != undefined && this.LeadTobeCreated.Transcript__c != null && this.LeadTobeCreated.Transcript__c != '') && (this.LeadTobeCreated.Enter_UTM_Link__c != undefined && this.LeadTobeCreated.Enter_UTM_Link__c != null && this.LeadTobeCreated.Enter_UTM_Link__c != '')) {


            var returnvalue = this.handleIncorrectEmail(this.LeadTobeCreated.Email)

            if (returnvalue == true && this.handleCorrectPhone(this.LeadTobeCreated.Phone)) {
                createLead({ Leadrec: this.LeadTobeCreated, countrycode : this.CountryCode, countrycodealternate :this.CountryCodeAlt })
                    .then(data => {

                        if (data == 'SUCCESS') {
                            this.handleConfirm('Lead Created Successfully');
                            console.log(data)
                            //alert('Lead Record created successfully');
                            this.handleCancel();
                            this.HandleLeadCreatedisable = false;
                            this.LeadTobeCreated = {};
                            this.handleSpinner();

                        }
                        else if (data == 'FAIL') {
                            this.handleSpinner();
                            this.handleAlert('Duplicate Lead Cannot be Created. Please Provide different Email and Phone');
                            this.HandleLeadCreatedisable = false;
                        }

                    })
                    .catch(error => {
                        this.handleSpinner();
                        this.handleAlert('Error updating or reloading records');
                        this.HandleLeadCreatedisable = false;
                        this.handleCancel();
                    })

            }
            else {
                alert('Incorrect Email or Phone Pattern');
                this.HandleLeadCreatedisable = false;
            }

        }
        else {
            alert('All Fields are Mandatory,Please Check any one Of Your Field Is Empty');
            this.HandleLeadCreatedisable = false;
        }





      /*  if ((this.lNameValue != undefined && this.lNameValue != null && this.lNameValue != '') && (this.emailValue != undefined && this.emailValue != null && this.emailValue != '') && (this.phoneValue != undefined && this.phoneValue != null && this.phoneValue != '')
            && (this.CourceLead != undefined && this.CourceLead != null && this.CourceLead != '') && (this.cityValue != undefined && this.cityValue != null && this.cityValue != '') && (this.sourceValue != undefined && this.sourceValue != null && this.sourceValue != '') && (this.MediumValue != undefined && this.MediumValue != null && this.MediumValue != '') &&
            (this.VisitorIdValue != undefined && this.VisitorIdValue != null && this.VisitorIdValue != '') && (this.TranscriptValue != undefined && this.TranscriptValue != null && this.TranscriptValue != '') && (this.PageUrlValue != undefined && this.PageUrlValue != null && this.PageUrlValue != '')) {
            this.HandleLeadCreatedisable = true;

            if (this.cityValue == 'Other') {
                this.cityValue = this.UserInputCity
            }

            debugger;
            var returnvalue = this.handleIncorrectEmail(this.emailValue)

            this.handleSpinner();
            if (returnvalue == true && this.handleCorrectPhone(this.phoneValue)) {  // firstname: this.namValue, 
                createLead({ Lastname: this.lNameValue, email: this.emailValue, phone: this.phoneValue, Course: this.CourceLead, agentid: this.agentrecid, city: this.cityValue, source: this.sourceValue, medium: this.MediumValue, VisitorId: this.VisitorIdValue, Transcript: this.TranscriptValue, leadGenPath: this.Leadvalue, state: this.StateValue, country: this.CountryValue, LandingPageURL: this.PageUrlValue, comments: this.commentsValue, countrycode: this.SelectedCountryISCode, AlternateMobile: this.alterMobileValue, AlternateEmail: this.alterEmailValue })
                    .then(data => {

                        if (data == 'SUCCESS') {
                            this.handleConfirm('Lead Created Successfully');
                            console.log(data)
                            //alert('Lead Record created successfully');
                            this.handleCancel();
                            this.HandleLeadCreatedisable = false;
                            this.namValue = '';
                            this.lNameValue = '';
                            this.commentsValue = '';
                            this.emailValue = '';
                            this.phoneValue = '';
                            this.alterMobileValue = '';
                            this.alterEmailValue = '';
                            this.CourceLead = '';
                            this.CountryValue = '';
                            this.cityValue = '';
                            this.Leadvalue = '';
                            this.handleSpinner();

                        }
                        else if (data == 'FAIL') {
                            this.handleSpinner();
                            this.handleAlert('Duplicate Lead Cannot be Created. Please Provide different Email and Phone');
                            this.HandleLeadCreatedisable = false;
                        }
                        else if (data == 'Lead Already exist') {
                            this.handleSpinner();
                            this.handleAlert('Duplicate Lead Cannot be Created. Please Provide different Email and Phone');

                        }
                    })
                    .catch(error => {
                        this.handleSpinner();
                        this.handleAlert('Error updating or reloading records');
                        this.HandleLeadCreatedisable = false;
                        this.handleCancel();
                    })
            }
            else {
                alert('Incorrect Email Pattern');
                this.HandleLeadCreatedisable = false;
            }
        }
        else {
            alert('All Fields are Mandatory,Please Check any one Of Your Field Is Empty');
            this.HandleLeadCreatedisable = false;
        }*/


    }

    @track spinnerLoading = false;
    handleSpinner() {
        this.spinnerLoading = !this.spinnerLoading;
    }

    async handleConfirm(message) {

            await LightningAlert.open({
                message: message,
                theme: "SUCCESS",
                label: "SUCCESS"
            }).then(() => {
                console.log("###Alert Closed");
            });
        }
        //success

        lookupRecord(event) {
            debugger;
            this.selectedrecordDetails = event.detail.selectedRecord;
            //alert('Selected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord));
        }
    async handleAlert(message) {
            await LightningAlert.open({
                message: message,
                theme: "error",
                label: "Alert"
            }).then(() => {
                console.log("###Alert Closed");
            });
        }

        handleCorrectPhone(PhoneToverify) {
            var regExpPhoneformat = /^[0-9]{1,10}$/g;
            if (PhoneToverify.match(regExpPhoneformat)) {
                return true;
            }
            else {
                return false;
            }
        }

        @api isLoaded = false;
        // change isLoaded to the opposite of its current value
        handleClick() {
            this.isLoaded = !this.isLoaded;
        }

        ShowPastLeadPage() {
            this.handleClick();
            debugger;
            QueryPastLeads({ ExcelRagentid: this.agentrecid })
                .then(data => {
                    debugger;
                    this.handleClick();
                    console.log('ertygutr54----', data);
                    this.showPastLeads = true;
                    this.showSearchDetails = false;
                    this.columns = LeadListcolumns;

                    if (data.length > 0) {
                        this.Leaddata = data;

                        // this.Leaddata = data.map(row=>{
                        //     return{...row, OwnerName: row.Owner.Name,
                        //         //if (Product__r) {
                        //             ProductName:row.Product__r.Name

                        //         //}
                        //     }
                        // })
                        this.error = undefined;
                        this.LeadrecordsFound = true;
                        //this.Leaddata = tempRecords;

                    }
                    else {
                        this.LeadrecordsNotFound = true;
                    }

                })
                .catch(error => {
                    this.handleAlert('Error updating or reloading records');

                })
        }

        ShowSearchpage() {
            debugger;

            this.showPastLeads = false;
            this.showSearchDetails = true;
            this.columns = applicationcolumns;
        }


        HandleCreateDisable = false;
        @track isLoadedApplication = false;

        createapplicationForm() {
            this.HandleCreateDisable = true;
            debugger;
            this.isLoadedApplication = true;
            if (this.courseforApp != null) {
                // this.handleClick();
                createApplication({ Course: this.courseforApp, LeadId: this.recordId })
                    .then(data => {
                        debugger;

                        this.showapplicationMOdal = false;
                        this.HandleCreateDisable = false;
                        this.handleConfirm('Application Created Successfully');
                        this.isLoadedApplication = false;
                        this.appbtndisAble = true;
                        //this.handleClick();
                        refreshApex(this.dataForApp);


                    })
                    .catch(error => {
                        this.HandleCreateDisable = false;
                        this.isLoadedApplication = false;
                        this.handleAlert('Error updating or reloading records');
                    })

            }
            else {
                alert('Course is Empty. Please Provide Course');
                this.HandleCreateDisable = false;
                this.handleClick();
            }
        }

        courseforapphandler(event) {
            let selectecourse = event.detail.value;
            this.courseforApp = selectecourse;
        }

        showpplicationForm() {
            debugger;
            this.showapplicationMOdal = true;
        }

        handleappCancel() {
            debugger;
            this.showapplicationMOdal = false;
        }

        handleOnselect(event) {
            debugger;
            var selectedVal = event.detail.value;
            if (selectedVal == 'Walk-In') {
                var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/walkInLeadPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode;
                window.open(urlString, "_self");

            }
            if (selectedVal == 'Voice') {
                var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/voiceFormPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode;
                window.open(urlString, "_self");

            }
            if (selectedVal == 'Generic') {
                var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/genericLeadAdditionPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode;
                window.open(urlString, "_self");
            }
            if (selectedVal == 'Chat') {
                var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/chatFormPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode;
                window.location.replace(urlString, "_self");
            }
        }

    }