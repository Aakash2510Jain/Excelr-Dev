import { api, LightningElement, track, wire } from 'lwc';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getLead from '@salesforce/apex/walkInLeadLWCcontroller.getLead';
import getApplication from '@salesforce/apex/walkInLeadLWCcontroller.getApplication';
import EmailIsm from '@salesforce/apex/walkInLeadLWCcontroller.EmailIsm';
import LogoutAgent from '@salesforce/apex/walkInLeadLWCcontroller.LogoutAgent';
import ChatPageUrl from '@salesforce/label/c.ChatPageUrl';
import GenericPageUrl from '@salesforce/label/c.GenericPageUrl';
import VoicePageUrl from '@salesforce/label/c.VoicePageUrl';
import WalkinPageUrl from '@salesforce/label/c.WalkinPageUrl';



//import getPuckistOflead from '@salesforce/apex/walkInLeadLWCcontroller.getPuckistOflead';


import createTask from '@salesforce/apex/walkInLeadLWCcontroller.createTask';

import createLead from '@salesforce/apex/walkInLeadLWCcontroller.createLead';
import createApplication from '@salesforce/apex/walkInLeadLWCcontroller.CreateApplication';

import QueryPastLeads from '@salesforce/apex/walkInLeadLWCcontroller.QueryPastLeads';
import LightningAlert from 'lightning/alert';
//import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';

//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import LEAD_OBJECT from '@salesforce/schema/Lead';

//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import TYPE_OF_COURSE_FIELD from '@salesforce/schema/Lead.Type_of_Course__c';


import fetchCountryAndCountryCode from '@salesforce/apex/GenericLeadLWCcontroller.fetchCountryAndCountryCode';


// ================================== All Picklist values ==================================

import getallPicklistvlaues from '@salesforce/apex/SiteFormUtility.getallPicklistvlaues';

import GettingCountries from '@salesforce/apex/SiteFormUtility.FetchCountryRec';
import GettingStates from '@salesforce/apex/SiteFormUtility.FetchStateRec';
import GettingCities from '@salesforce/apex/SiteFormUtility.GetCityFromBigobject';


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


export default class WaklInLead extends LightningElement {

    // label = {
    //     ChatPageUrl,
    //     GenericPageUrl,
    //     LoginPageBaseurl,
    //     VoicePageUrl,
    //     WalkinPageUrl
    // };
    imageurl = EXCELR_LOGO;
    //feilds from schema

    @track LeadTobeCreated = {};
    @track taskTobeCreated = {};

    @track ifdataNotFound = false;
    @track ownerEmail;
    @track ismBTNdisAble = true;
    @track courssweList = [];
    @track priorityList = [];
    @track StatusList = [];
    @track CourceLead;
    @track courseforApp;
    @track recordId;
    @track newBTNdisAble = false;
    objectApiName = 'Lead';

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
    @api agentNameLWC;
    @track DepartmentList = [];
    @track mapData = [];
    @track profileLogout = [];
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
        // this.handlecourseList();
        this.convertStringtoList();
        this.lwcfilename();

    }

    // @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    // objectInfo

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TYPE_OF_COURSE_FIELD })
    // TypeofCoursePicklistValues

    lwcfilename(){
        console.log(
            this.template.host.localName // c-test-component
              .split('-')              // ['c', 'test', 'component'] 
              .slice(1)                // removes ns prefix => ['test', 'component']
              .reduce((a, b) => a + b.charAt(0).toUpperCase() + b.slice(1)) // converts to camelCase => testComponent 
          );
    }

    convertStringtoList() {
        this.DepartmentList = this.DepartmentListstring.split(';');
        for (var key in this.DepartmentList) {
            this.mapData.push({ label: this.DepartmentList[key], value: this.DepartmentList[key] }); //Here we are creating the array to show on UI.
        }
    }


    // =========================== Handle city state Country Starts ===================================================



    @track CountryDisable = true;
    @track StateDisable = true;
    @track StateValue;
    @track CountryValue;
    @track InputCity = false;

    // =========================================================Fetch Countries States with ISDCODe And Handle =================================================
    @track CountriesPicklistValue = [];
    @track countriesSateISDCodelist = [];


    @track SelectedCountryStateList = [];
    @track SelectedCountryISCode;



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

            if (data.AllformsMapwrapper.Voice.course_names__c.length > 0) {

                let tempcoursearr = [];
                for (let i = 0; i < data.AllformsMapwrapper.Voice.course_names__c.length; i++) {
                    tempcoursearr.push({ label: data.AllformsMapwrapper.Voice.course_names__c[i], value: data.AllformsMapwrapper.Voice.course_names__c[i] });
                }
                this.courssweList = tempcoursearr;
                this.courssweList.sort((a, b) => (a.label > b.label) ? 1 : -1);

            }

            // if (data.Sources.length > 0) {

            //     let tempSourcearr = [];
            //     for (let i = 0; i < data.Sources.length; i++) {
            //         tempSourcearr.push({ label: data.Sources[i], value: data.Sources[i] });
            //     }
            //     this.LeadSourcePicklist = tempSourcearr;
            //     this.LeadSourcePicklist.sort((a, b) => (a.label > b.label) ? 1 : -1);
            //     console.log('Picklistvalue=', this.LeadSourcePicklist);

            // }

            // if (data.LeadGenPath.length > 0) {

            //     let tempLeadGenPatharr = [];
            //     for (let i = 0; i < data.LeadGenPath.length; i++) {
            //         tempLeadGenPatharr.push({ label: data.LeadGenPath[i], value: data.LeadGenPath[i] });
            //     }
            //     this.LeadGenPathPicklistvalue = tempLeadGenPatharr;
            //     this.LeadGenPathPicklistvalue.sort((a, b) => (a.label > b.label) ? 1 : -1);
            //     console.log('Picklistvalue=', this.LeadGenPathPicklistvalue);

            // }

            // if (data.AllformsMapwrapper.Voice.course_names__c.length.length > 0) {

            //     let temptypeofcoursearr = [];
            //     for (let i = 0; i < data.TypeofCourse.length; i++) {
            //         temptypeofcoursearr.push({ label: data.AllformsMapwrapper.Voice.course_names__c.length[i], value: data.AllformsMapwrapper.Voice.course_names__c.length[i] });
            //     }
            //     this.TypeofCoursePicklistValues = temptypeofcoursearr;
            //     this.TypeofCoursePicklistValues.sort((a, b) => (a.label > b.label) ? 1 : -1);
            //     console.log('Picklistvalue=', this.TypeofCoursePicklistValues);

            // }

            //TypeofCourse

            if (data.pickValByFieldWrapper.TaskStatus.length > 0) {

                let tempTaskStatusarr = [];
                for (let i = 0; i < data.pickValByFieldWrapper.TaskStatus.length; i++) {
                    tempTaskStatusarr.push({ label: data.pickValByFieldWrapper.TaskStatus[i], value: data.pickValByFieldWrapper.TaskStatus[i] });
                }

                this.StatusList = tempTaskStatusarr;
                this.StatusList.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('statusList--', this.StatusList);

            }

            if (data.pickValByFieldWrapper.TaskPriority.length > 0) {
                let tempTaskPriorityarr = [];
                for (let i = 0; i < data.pickValByFieldWrapper.TaskPriority.length; i++) {
                    tempTaskPriorityarr.push({ label: data.pickValByFieldWrapper.TaskPriority[i], value: data.pickValByFieldWrapper.TaskPriority[i] });
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


    // ======================================================= Fetch Countries States with ISDCODe And Handle End Here ==================================================== 


    @track StateCountryValue = [];

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

    @track statesList = [];
    @track DefaultCountryCode;
    HandleCountryChange(event) {
        debugger;
        //let selectedCountry=event.detail.value;

        let SelectedcountryId = event.detail.value;
        this.SelectedcountryId = SelectedcountryId;

        var SelectedCountry = this.countryList.find(item => item.value == this.SelectedcountryId);
        this.LeadTobeCreated.Country__c = SelectedCountry.label;

        if (SelectedCountry.label == 'India') {
            this.DefaultCountryCode = "91";
            this.CountryCode = "91";
            this.CountryCodeAlt = "91";
        } else if (SelectedCountry.label == 'United Kingdom') {
            this.DefaultCountryCode = "44";
            this.CountryCode = "44";
            this.CountryCodeAlt = "44";
        } else if (SelectedCountry.label == 'United States') {
            this.DefaultCountryCode = "1";
            this.CountryCode = "1";
            this.CountryCodeAlt = "1";
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

                console.log('Picklistvalue=', this.statesList);
            }

            );
        if (this.SelectedStateId != null) {
            this.selectedCityValue = '';
        }

    }




    //getting States List
    @track stateList = [];



    @track SelectedCountryStateList = [];
    @track SelectedCountryISCode;


    @track FetchedcityList = [];
    @track cityList = [];
    @track CityDisable = true;
    @track searchResults = [];
    @track disableInput = true;

    HandleChangeState(event) {
        debugger;

        this.SelectedStateId = event.detail.value;
        var SelectedState = this.statesList.find(item => item.value == this.SelectedStateId);

        this.LeadTobeCreated.State__c = SelectedState.label;
        this.StateDisable = false;
        console.log('SelectedStateId-', this.SelectedStateId);
        console.log('SelectedcountryId-', this.SelectedcountryId);

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
                this.disableInput = false;
                this.CityDisable = false;

                console.log('PicklistvalueCity=', this.cityList);
            }

            );
    }

    @track selectedValue
    @track booleanValue = false;
    search(event) {
        debugger;
        let value = event.target.value;
        this.selectedresultValue = value;

        let TempValue;
        if (value) {
            TempValue = value;
        }

        let arr = [];
        if (TempValue) {
            TempValue = TempValue.charAt(0).toUpperCase() + TempValue.slice(1);
            console.log('TempValue=', TempValue);
            const results = this.FetchedcityList.filter(product => product.value.includes(TempValue));

            console.log('results====', results);
            results.forEach(element => {
                arr.push({ label: element.value, value: element.value });
            });


            console.log('arr====', arr);
        }
        this.searchResults = arr;
        if (this.searchResults.length > 0) {
            this.booleanValue = true;
        } else {
            this.booleanValue = false;
        }
        console.log('this.searchResults====', this.searchResults);
    }



    @track selectedSearchResult;
    @track selectedresultValue;

    selectSearchResult(event) {
        debugger;
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedresultValue = selectedValue;
        console.log('selectedValue--', selectedValue);
        this.selectedSearchResult = this.searchResults.find(
            (picklistOption) => picklistOption.value === selectedValue
        );
        console.log('selectedSearchResult--', this.selectedSearchResult);
        console.log('selectedresultValue--', this.selectedresultValue);

        this.clearSearchResults();
        this.booleanValue = false;
    }

    clearSearchResults() {
        this.searchResults = null;
    }



    @track selectedCityValue;
    HandleCityValue(event) {
        debugger;
        this.selectedCityValue = event.detail.value;
        this.LeadTobeCreated.City__c = event.detail.value;
    }
    //==================================================================================

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

    // =========================== Handle city state Country Ends ===================================================

    @track typeofCoursevalue;
    typeofcourseHandler(event) {
        debugger;
        this.typeofCoursevalue = event.target.value;
        this.LeadTobeCreated.Type_of_Course__c = this.typeofCoursevalue;
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
                if (this.data != null && this.data != undefined) {
                    //this.newBTNdisAble = true;
                    
                    if (this.data.OppRec != undefined) {
                        if (this.data.OppRec.length >0 ) {
                            this.taskBTNdisAble = false;
                            this.recordId = this.data.OppRec[0].Id; 
                            this.objectApiName = 'Opportunity'; 
                            this.ownerEmail = data.OppRec[0].Owner_Email__c;
                            this.CaptureOwnerId = data.OppRec[0].OwnerId;
                            this.captureownerName = data.OppRec[0].Owner.Name;
                            this.handleClick();
                            this.ismBTNdisAble = false;
                            this.ifdataNotFound = false;
                            this.appbtndisAble = false;
                        }
                    }else if (this.data.Leadrec != undefined) {
                        if (this.data.Leadrec.length >0 ) {
                            this.taskBTNdisAble = false;
                            this.recordId = this.data.Leadrec[0].Id; 
                            this.objectApiName = 'Lead'; 
                            this.ownerEmail = data.Leadrec[0].Owner_Email__c;
                            this.CaptureOwnerId = data.Leadrec[0].OwnerId;
                            this.captureownerName = data.Leadrec[0].Owner.Name;
                            this.handleClick();
                            this.ismBTNdisAble = false;
                            this.ifdataNotFound = false;
                            this.appbtndisAble = false;
                        }
                    }
                    
                }
                if ((this.data.OppRec == null || this.data.OppRec == undefined) && ( this.data.Leadrec == null || this.data.Leadrec == undefined) ) {
                    this.handleClick();
                    this.ifdataNotFound = true;
                    this.taskBTNdisAble = true;
                    // this.newBTNdisAble = false;
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
            console.log('Loaded Bro');
            console.log(this.dataForApp);
            this.columns = applicationcolumns;
            this.isLoadedApplication = false;
            if (Array.isArray(this.dataForApp.data)) {
                if (this.dataForApp.data.length > 0) {
                    //this.appbtndisAble = false;
                }
                else if (this.dataForApp.data.length == 0) {
                    //this.appbtndisAble = true;
                }
            }
        }
        // else{
        //     this.appbtndisAble = false;

        // }
        if (error) {
            this.ifdataNotFound = true;
            this.isLoadedApplication = false;

        }

    }

    handleSubmit(event) {
        return refreshApex(this.wiredbearResult);
    }

    createTaskRec() {
        debugger;
        if(this.taskTobeCreated.Subject == undefined || this.taskTobeCreated.Subject == ''){
            alert('Subject is empty, Please enter Subject !');
            return;
        }
        if(this.taskTobeCreated.Priority == undefined || this.taskTobeCreated.Priority == ''){
            alert('Priority is empty, Please enter Priority !');
            return;
        }
        if(this.taskTobeCreated.Status == undefined || this.taskTobeCreated.Status == ''){
            alert('Status is empty, Please enter Status !');
            return;
        }
        if(this.taskTobeCreated.ActivityDate == undefined || this.taskTobeCreated.ActivityDate == ''){
            alert('Due Date is empty, Please enter Due Date !');
            return;
        }
        if(this.taskTobeCreated.Followup_Date_Time__c == undefined || this.taskTobeCreated.Followup_Date_Time__c == ''){
            alert('Followup Datetime is empty, Please enter Followup Datetime !');
            return;
        }
        if ((this.CaptureOwnerId != null && this.CaptureOwnerId != undefined && this.CaptureOwnerId != '') && (this.recordId != null && this.recordId != undefined && this.recordId != '')) {
            createTask({ assignto: this.CaptureOwnerId, RecordId: this.recordId, TaskRecord: this.taskTobeCreated })

                .then((result) => {
                    console.log('result', result);
                    if (result == 'Success') {
                        this.handleConfirm('Task Created Successfully');
                        this.showtaskModal = false;
                        this.subjectvalue = '';
                        this.priorityValue = '';
                        this.statusValue = '';
                        this.DuedateValue = '';
                        this.comValue = '';
                        this.followupValue = '';
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
        this.taskTobeCreated.Subject = '',
        this.taskTobeCreated.Priority = '',
        this.taskTobeCreated.Status = '',
        this.taskTobeCreated.ActivityDate = '',
        this.taskTobeCreated.Followup_Date_Time__c = '',
        this.taskTobeCreated.Description = '',
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
        this.SelectedMedium = '';
        this.selectedresultValue = '';
        this.DefaultCountryCode = '';
        this.SelectedCountryStateList = [];
        this.CountryCode = '';

        this.booleanValue = false;
        this.disableInput = true;
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

            this.LeadTobeCreated.Country__c = event.target.value;
        }

        if (InputName == 'State') {
            this.LeadTobeCreated.State__c = event.target.value;
        }
        if (InputName == 'UserCity') {
            this.LeadTobeCreated.City__c = event.target.value;
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
            if (event.target.value != null || event.target.value != undefined || event.target.value != '') {
                this.LeadTobeCreated.Alternate_Phone__c = event.target.value;
            }
        }
        if (InputName == 'course') {
            this.LeadTobeCreated.Course__c = event.target.value;
        }
        if (InputName == 'Comments') {
            this.LeadTobeCreated.Comments__c = event.target.value;
        }
        if (InputName == 'TOCR') {
            this.LeadTobeCreated.Type_of_Course__c = event.target.value;
        }


    }


    handleCorrectPhone(PhoneToverify) {
        var regExpPhoneformat = /^[0-9]*$/;
        //var regExpPhoneformat = /^[0-9]{1,10}$/g;
        //var regExpPhoneformat = /^\d{10}$/;
        if (PhoneToverify.match(regExpPhoneformat)) {
            return true;
        }
        else {
            return false;
        }
    }



    handleChange(event) {
        debugger;
        let selectedValue = event.detail.value;
        this.ismeId = selectedValue;
        console.log('MEMLIST---', this.groupMemList);
        this.gruoMemberId = this.groupMemList.find(item => item.Group_Member__c == selectedValue).Id;
        //this.groupMemList[this.ismeId];
    }
    courceHandler(event) {
        debugger;
        let selectedCource = event.detail.value;
        this.CourceLead = selectedCource;
    }
    //=============================================Task Creation Starts Here============================================================================================

    TaskCreationHandler(event) {

        var TaskInputName = event.currentTarget.name;
        if (TaskInputName == 'subject') {

            this.taskTobeCreated.Subject = event.target.value;
        }
        if (TaskInputName == 'Priority') {

            this.taskTobeCreated.Priority = event.target.value;

        } if (TaskInputName == 'Status') {

            this.taskTobeCreated.Status = event.target.value;

        } if (TaskInputName == 'Duedate') {

            this.taskTobeCreated.ActivityDate = event.target.value;

        } if (TaskInputName == 'Followupdatetime') {

            this.taskTobeCreated.Followup_Date_Time__c = event.target.value;

        } if (TaskInputName == 'Comments') {

            this.taskTobeCreated.Description = event.target.value;
        }

    }


    //==================================================Task Creation Ends Here====================================================================================

    notifyismBTN() {
        debugger;
        EmailIsm({ LiD: this.recordId, ownerMail: this.ownerEmail })
            .then(result => {
                debugger;
                this.ismBTNdisAble = true;
                this.handleConfirm('Email sent successfully');

            })
            .catch(error => {
                this.handleAlert('Email not sent');
            })
    }

    // handlecourseList() {
    //     getPuckistOflead()
    //         .then(result => {
    //             ///this.data = result;
    //             let options = []
    //             for (const [key, value] of Object.entries(result)) {
    //                 options.push({
    //                     label: key,
    //                     value: value
    //                 })
    //                 console.log(`${key}: ${value}`);
    //             }
    //             this.courssweList = options;
    //             console.log(courssweList)
    //         })
    //         .catch(error => {
    //             this.error = error;
    //         });
    // }

    HandleLeadCreatedisable = false;
    createNewLead() {
        debugger;

        
        this.LeadTobeCreated.ExcelR_Training_User__c = this.agentrecid;
        //&& (this.LeadTobeCreated.Email != undefined && this.LeadTobeCreated.Email != null && this.LeadTobeCreated.Email != '') && (this.LeadTobeCreated.Phone != undefined && this.LeadTobeCreated.Phone != null && this.LeadTobeCreated.Phone != '')

        
        if ((this.LeadTobeCreated.LastName != undefined && this.LeadTobeCreated.LastName != null && this.LeadTobeCreated.LastName != '')
            && (this.LeadTobeCreated.Course__c != undefined && this.LeadTobeCreated.Course__c != null && this.LeadTobeCreated.Course__c != '') && (this.selectedresultValue != null && this.selectedresultValue != undefined && this.selectedresultValue != '') && (this.selectedrecordDetails != null && this.selectedrecordDetails != undefined && this.selectedrecordDetails != '')) {  
                if (this.LeadTobeCreated.Email != null && this.LeadTobeCreated.Email != '' && this.LeadTobeCreated.Email != undefined) {
                    var returnvalue = this.handleIncorrectEmail(this.LeadTobeCreated.Email)
                }
                if (this.LeadTobeCreated.Phone != null && this.LeadTobeCreated.Phone != '' && this.LeadTobeCreated.Phone != undefined) {
                    var phoneReturnvalue = this.handleCorrectPhone(this.LeadTobeCreated.Phone);
                }
    
                if (this.LeadTobeCreated.Email != null && this.LeadTobeCreated.Email != '' && this.LeadTobeCreated.Email != undefined  && (this.LeadTobeCreated.Phone == null || this.LeadTobeCreated.Phone == '' || this.LeadTobeCreated.Phone == undefined  )) {
                    if ( returnvalue == true) {
                        this.createLeadFromJS();
                        
                    }
                    else{
                        alert('Incorrect Email Pattern');
                        this.HandleLeadCreatedisable = false;
    
                    }
                    
                }
                else if ( this.LeadTobeCreated.Phone != null && this.LeadTobeCreated.Phone != '' && this.LeadTobeCreated.Phone != undefined && (this.LeadTobeCreated.Email == null || this.LeadTobeCreated.Email == '' || this.LeadTobeCreated.Email == undefined )) {
                    if (phoneReturnvalue == true) {
                        this.createLeadFromJS();
                    }
                    else{
                        alert('Incorrect Phone Pattern');
                        this.HandleLeadCreatedisable = false;
                    }
                    
                }
                else if ((this.LeadTobeCreated.Email != null  && this.LeadTobeCreated.Email != '' && this.LeadTobeCreated.Email != undefined) && (this.LeadTobeCreated.Phone != null && this.LeadTobeCreated.Phone != '' && this.LeadTobeCreated.Phone != undefined)) {
                    if (returnvalue == true && phoneReturnvalue == true) {
                        this.HandleLeadCreatedisable = true;
                        this.createLeadFromJS();
                       
    
                    }
                    else {
                        alert('Incorrect Email or Phone Pattern');
                        this.HandleLeadCreatedisable = false;
                    }
                }
            else {
                this.createLeadFromJS();
            }



            /*var returnvalue = this.handleIncorrectEmail(this.LeadTobeCreated.Email);
            var phoneregexreturnvalue = this.handleCorrectPhone(this.LeadTobeCreated.Phone);
            this.agentrecid;
            this.handleSpinner();
            if (returnvalue == true && this.handleCorrectPhone(this.LeadTobeCreated.Phone)) {
                this.HandleLeadCreatedisable=true;
                createLead({ Leadrec: this.LeadTobeCreated, countrycode : this.CountryCode, countrycodealternate :this.CountryCodeAlt,city:this.selectedresultValue })
                    .then(data => {
    
                        if (data == 'SUCCESS') {
                            this.handleConfirm('Lead Created Successfully');
                            this.HandleLeadCreatedisable = false;
                            console.log(data)
                            //alert('Lead Record created successfully');
                            this.handleCancel();
                            this.lNameValue = '';
                            this.commentsValue = '';
                            this.emailValue = '';
                            this.phoneValue = '';
                            this.AlternateMobile = '';
                            this.alterEmailValue = '';
                            this.CourceLead = '';
                            this.cityValue = '';
                            this.StateValue = '';
                            this.CountryValue = '';
                            this.typeofCoursevalue = '';
                            this.handleSpinner();
                        }
                        else if (data == 'FAIL') {
                            this.handleSpinner();
                            this.HandleLeadCreatedisable=false;
                            //this.handleAlert('Duplicate Lead Cannot be Created. Please Provide different Email and Phone');
                            
                        }
    
                    })
                    .catch(error => {
                        this.handleSpinner();
                        this.handleAlert('Error updating or reloading records');
                        this.handleCancel();
                        this.HandleLeadCreatedisable=false;
    
                    })
            }
            else {
                alert('Incorrect Email or Phone Pattern');
                this.HandleLeadCreatedisable=false;
            }*/
        } else {
            this.HandleLeadCreatedisable = false;
            alert('Some of the mandatory fields are not filled');
        }

    }

    

    createLeadFromJS() {
        debugger;
        
        if (this.FetchedcityList.find((picklistOption) => picklistOption.value === this.selectedresultValue)) {       
        this.handleSpinner();
        createLead({ Leadrec: this.LeadTobeCreated, countrycode: this.CountryCode, countrycodealternate: this.CountryCodeAlt, mediumValue: this.SelectedMedium, city: this.selectedresultValue })
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
                    this.handleAlert('Error in Creating record. Please provide correct and complete Data!');
                    // this.handleAlert('Duplicate Lead Cannot be Created. Please Provide different Email and Phone');
                    this.HandleLeadCreatedisable = false;
                }

            })
            .catch(error => {
                this.handleSpinner();
                this.handleAlert('Error updating or reloading records');
                this.HandleLeadCreatedisable = false;
                this.handleCancel();
            })

    }else{
        this.HandleLeadCreatedisable = false;
        window.alert('Choose a Correct City');
    }
}

    showLoading = false;
    handleSpinner(){
        this.showLoading = !this.showLoading;

    }

    async handleConfirm(message) {
        /*const result = await LightningConfirm.open({
            message: message,
            theme: "success",
            label: "Success",
            variant: 'header',
        });
        console.log("🚀 ~ result", result);*/

        await LightningAlert.open({
            message: message,
            theme: "SUCCESS",
            label: "SUCCESS"
        }).then(() => {
            console.log("###Alert Closed");
        });
    }

    lookupRecord(event) {
        debugger;
        this.selectedrecordDetails = event.detail.selectedRecord;
        if (this.selectedrecordDetails != null) {

            this.LeadTobeCreated.OwnerId = this.selectedrecordDetails.Id;
            this.LeadTobeCreated.Is_User_Assigned__c = 'Assigned';

        } else {
            this.LeadTobeCreated.OwnerId = '';
            this.LeadTobeCreated.Is_User_Assigned__c = 'Not-Assigned';
        }

        //alert('Selected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord));
    }

    async handleAlert(message) {
        await LightningAlert.open({
            message: message,
            theme: "error",
            label: "Error!",
            variant: 'header',
        }).then(() => {
            console.log("###Alert Closed");
        });
    }

    @api isLoaded = false;
    // change isLoaded to the opposite of its current value
    handleClick() {
        this.isLoaded = !this.isLoaded;
    }


    ShowPastLeadPage() {
        debugger;
        this.handleClick();
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

    showpplicationForm() {

    }



    HandleCreateDisable = false;
    @track isLoadedApplication = false;
    createapplicationForm() {
        debugger;
        if (this.courseforApp != null && this.courseforApp != '' && this.courseforApp != undefined ) {
            
            this.HandleCreateDisable = true;
            this.isLoadedApplication = true;
            createApplication({ Course: this.courseforApp, LeadId: this.recordId })
            .then(data => {
                debugger;

                this.showapplicationMOdal = false;
                this.HandleCreateDisable = false;
                this.handleConfirm('Application Created Successfully');
                this.HandleCreateDisable = false;
                this.isLoadedApplication = false;
                this.appbtndisAble = true;
                this.courseforApp = '';
                refreshApex(this.dataForApp);
            })
            .catch(error => {
                this.HandleCreateDisable = false;
                this.isLoadedApplication = false;
                this.handleAlert('Error updating or reloading records');
            })
            
        }
        else{
            alert('Course is Empty. Please Provide Course');
            this.HandleCreateDisable = false;
            this.isLoadedApplication = false;
            //this.handleClick();
        }
        



    }



    courseforapphandler(event) {
        debugger;
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
        //var selectedVal = event.currentTarget.dataset.id;
        if (selectedVal == 'Walk-In') {
            //var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/walkInLeadPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            var urlString = WalkinPageUrl + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            window.open(urlString, "_self");

        }
        if (selectedVal == 'Voice') { //
            //var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/voiceFormPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            var urlString = VoicePageUrl + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            window.open(urlString, "_self");

        }
        if (selectedVal == 'Generic') {
            var urlString = GenericPageUrl + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            //var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/genericLeadAdditionPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            window.open(urlString, "_self");

        }
        if (selectedVal == 'Chat') {
            var urlString = ChatPageUrl + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
           // var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/chatFormPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring + '&hascode=' + this.hashcode + '&AgentName=' + this.agentNameLWC;
            window.location.replace(urlString, "_self");
        }
    }


    handleOnselectprofile(event){
        debugger;
        var agId = this.agentrecid;
        var Hashes = this.hashcode;
        var selectedVal = event.detail.value;
        if (selectedVal == 'My Past Leads') {
            this.ShowPastLeadPage();
            
        }
        if (selectedVal == 'Logout') {
            this.LogoutAgentfromForm();
        }

    }

    LogoutAgentfromForm() {
        debugger;
        var agId = this.agentrecid;
        var Hashes = this.hashcode;
        LogoutAgent({ AgrecId: this.agentrecid, AgentHashCode: this.hashcode })
            .then(data => {
                debugger;
                if (data) {
                    if (data.Message != null && data.Message != undefined  ) {
                        var apexcookies = 'apex_' + data.HashcodeName;
                       // this.getCookie(apexcookies);
                    //    let x = document.cookie;
                    //     let username = getCookie(apexcookies);
                    //     if (username != '' ) {
                    //         document.cookie = "username=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                    //     }
                        var urlString = data.Message;
                        window.location.replace(urlString, "_self");
                        
                    }
                    
                }

            })
            .catch(error => {
                this.handleAlert('Some error in logout');
            })



    }

    getCookie(cname) {
        debugger;
        let name = cname + "=";
        let decodedCookie = decodeURIComponent(document.cookie);
        let ca = decodedCookie.split(';');
        for(let i = 0; i <ca.length; i++) {
          let c = ca[i];
          while (c.charAt(0) == ' ') {
            c = c.substring(1);
          }
          if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
          }
        }
        return "";
      }

    // LogoutPage(){
    //     debugger;
    //     var agId = this.agentrecid;
    //     var Hashes = this.hashcode;


    // }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}