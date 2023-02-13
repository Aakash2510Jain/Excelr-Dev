import { api, LightningElement, track, wire } from 'lwc';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLead from '@salesforce/apex/GenericLeadLWCcontroller.getLead';
import getApplication from '@salesforce/apex/GenericLeadLWCcontroller.getApplication';
import EmailIsm from '@salesforce/apex/GenericLeadLWCcontroller.EmailIsm';
import getMember from '@salesforce/apex/GenericLeadLWCcontroller.getMember';
import getPuckistOflead from '@salesforce/apex/GenericLeadLWCcontroller.getPuckistOflead';

import getPickiststatusOfTask from '@salesforce/apex/GenericLeadLWCcontroller.getPickiststatusOfTask';
import getPickistpriorityOfTask from '@salesforce/apex/GenericLeadLWCcontroller.getPickistpriorityOfTask';
import createTask from '@salesforce/apex/GenericLeadLWCcontroller.createTaskForVoice';

import createLead from '@salesforce/apex/GenericLeadLWCcontroller.createLead';
import createApplication from '@salesforce/apex/GenericLeadLWCcontroller.CreateApplication';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_GEN_PATH from '@salesforce/schema/Lead.Lead_Gen_Path__c';
import LEAD_SOURCE from '@salesforce/schema/Lead.LeadSource';
import LEAD_MEDIUM from '@salesforce/schema/Lead.UTM_Medium__c';
import FetchStateCounty from '@salesforce/apex/GenericLeadLWCcontroller.FetchStateCounty';
import Fetchcities from '@salesforce/apex/GenericLeadLWCcontroller.Fetchcities';
import fetchCountryAndCountryCode from '@salesforce/apex/GenericLeadLWCcontroller.fetchCountryAndCountryCode';

import FetchCountriesStateWithISDcode from '@salesforce/apex/voiceFormLWCcontroller.getCountryStateAndISDCode';

import COUNTRY_FIELD from '@salesforce/schema/Lead.Country';

import QueryPastLeads from '@salesforce/apex/GenericLeadLWCcontroller.QueryPastLeads';
import LightningAlert from 'lightning/alert';
import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';



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
    imageurl = EXCELR_LOGO;
    //feilds from schema
    @track ifdataNotFound = false;
    @track ownerEmail;
    @track ismBTNdisAble = true;
    @track courssweList = [];
    @track priorityList = [];
    @track StatusList = [];
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
    @track commentsValue;
    @track dataForApp;
    @track Leaddata = [];
    @track showPastLeads = false;
    @track showSearchDetails = true;
    @track LeadrecordsNotFound = false;
    @track LeadrecordsFound = false;

    @track showapplicationMOdal = false;
    @track appbtndisAble = true;

    connectedCallback() {
        //defined a varibale
        this.handlecourseList();
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


    @track countryPicklist;
    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:COUNTRY_FIELD})
    wiredCountryPicklistValues({ data, error }) {
        debugger;
        if (data) {
            console.log('data=', data);
            console.log('dataValues=', data.values);
            let arr = [];
            for (let i = 0; i < data.values.length; i++) {
                arr.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.countryPicklist = arr;
            this.countryPicklist.sort((a, b) => (a.label > b.label) ? 1 : -1);
            console.log('countryPicklist =======', this.countryPicklist);
        }
        else {
            console.log('error=', error)
        }
    }
    IndustryPicklistValues

    @track taskBTNdisAble = true;
    @track captureownerName;
    @track CaptureOwnerId;
    serachLeadBTN() {
        this.handleClick();
        debugger;
        getLead({ EmailOrPhone: this.inPutValue })
            .then(data => {
                debugger;

                this.showFromOrEmpty = true;
                this.data = data;
                if (this.data.length > 0) {
                    // this.newBTNdisAble = true;
                    this.taskBTNdisAble = false;
                    this.handleClick();
                    this.recordId = this.data[0].Id;
                    this.ownerEmail = data[0].Owner_Email__c;
                    this.CaptureOwnerId = data[0].OwnerId;
                    this.captureownerName = data[0].Owner.Name;
                    //this.handleClick();
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
        // else{
        //     this.appbtndisAble = false;

        // }
        if (error) {
            this.ifdataNotFound = true;

        }

    }


    
    // =========================================================Fetch Countries States with ISDCODe And Handle =================================================
    @track CountriesPicklistValue=[];
    @track countriesSateISDCodelist = [];
    @wire(FetchCountriesStateWithISDcode)
    wiredCounstriesStatesWithISD({data,error}){
        debugger;
        if(data){
            this.countriesSateISDCodelist = data;
            console.log('CityValuedata=',data);

              let arr=[];
              for(let i=0;i<data.length;i++){
                 arr.push({label:data[i].MasterLabel,value:data[i].MasterLabel});
              }
              this.CountriesPicklistValue=arr;
              console.log('Picklistvalue=',this.CountriesPicklistValue);
           }
           else if(error){
               console.log('error=',error);
           }

    }

    @track SelectedCountryStateList = [];
    @track SelectedCountryISCode;
    HandleChangeCountry(event){
        debugger;
        let Selectedcountry=event.detail.value;
        this.CountryValue = Selectedcountry;
        var SelectedcountryStateISDCode = this.countriesSateISDCodelist.find(item => item.MasterLabel == Selectedcountry);
        this.SelectedCountryISCode = SelectedcountryStateISDCode.Country_Code__c;
        //this.countrycodevalue = countrycode.CountryCode__c;
        let tempStateArr = []; 
        var tempStateString = SelectedcountryStateISDCode.States__c;
        var tempStateArrafterCommaSeperated = tempStateString.split(',');
        for(let i=0;i<tempStateArrafterCommaSeperated.length;i++){
            tempStateArr.push({label:tempStateArrafterCommaSeperated[i],value:tempStateArrafterCommaSeperated[i]});
         }
         this.SelectedCountryStateList = tempStateArr;
         this.StateDisable = false;

    }

    HandleChangeState(event){
        debugger;
        let SelectedState=event.detail.value;
        this.StateValue = SelectedState;
        //this.StateDisable = false;

    }

    HandleCityValue(event){
        this.cityValue = event.detail.value;
    }


    // ======================================================= Fetch Countries States with ISDCODe And Handle End Here ==================================================== 


    @track StateCountryValue = [];
    @wire(FetchStateCounty)
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

    }

    Picklistvalue = [];
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LEAD_GEN_PATH })
    wiredPicklistValues({ data, error }) {
        debugger;
        if (data) {
            console.log('data=', data);
            console.log('dataValues=', data.values);
            let arr = [];
            for (let i = 0; i < data.values.length; i++) {
                arr.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.Picklistvalue = arr;
            this.Picklistvalue.sort((a, b) => (a.label > b.label) ? 1 : -1);
            console.log('Picklistvalue=', this.Picklistvalue);
        }
        else {
            console.log('error=', error)
        }
    }

    get ldGenPath() {
        return this.Picklistvalue;
    }

    ldGenPathValue(event) {
        debugger;
        this.Leadvalue = event.target.value;
    }

    //Getting Picklist Field Of LeadSource
    @track LeadSourcePicklist = [];
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LEAD_SOURCE })
    wiredPicklistLeadSource({ data, error }) {
        debugger;
        if (data) {
            console.log('data=', data);
            console.log('dataValues=', data.values);
            let arr = [];
            for (let i = 0; i < data.values.length; i++) {
                arr.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.LeadSourcePicklist = arr;
            this.LeadSourcePicklist.sort((a, b) => (a.label > b.label) ? 1 : -1);
            console.log('Picklistvalue=', this.LeadSourcePicklist);
        }
        else {
            console.log('error=', error)
        }
    }

    get leadSource() {
        return this.LeadSourcePicklist;
    }

    @track SourceValue;
    HandleSource(event) {
        debugger;
        let Source = event.target.value;
        this.SourceValue = Source;
    }

    //Getting Picklist Field Of Medium
    @track LeadMediumPicklist = [];
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LEAD_MEDIUM })
    wiredPicklistLeadMedium({ data, error }) {
        debugger;
        if (data) {
            console.log('data=', data);
            console.log('dataValues=', data.values);
            let arr = [];
            for (let i = 0; i < data.values.length; i++) {
                arr.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.LeadMediumPicklist = arr;
            this.LeadMediumPicklist.sort((a, b) => (a.label > b.label) ? 1 : -1);   
            console.log('Picklistvalue=', this.LeadMediumPicklist);
        }
        else {
            console.log('error=', error)
        }
    }

    get leadmedium() {
        return this.LeadMediumPicklist;
    }

    @track MediumValue;

    HandleMedium(event) {
        debugger;
        let Medium = event.target.value;
        this.MediumValue = Medium;
    }

    @track CityPicklistValue = [];
    @track cityValue;
    @wire(Fetchcities)
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
    }

    @track countryCodeList = [];
    @wire(fetchCountryAndCountryCode)
    wiredcountryCountrycode({ data, error }) {
        debugger;
        if (data) {
           this.countryCodeList = data;
        }
        else if (error) {
            console.log('error=', error);
        }

    }

    @track CountryDisable = true;
    @track StateDisable = true;
    @track StateValue;
    @track CountryValue;
    @track InputCity = false;

    @track countrycodevalue;
    HandleCityStatus(event) {

        debugger;
        let city = event.detail.value;
        if (city) {
            this.cityValue = city;
            let state;
            let TempValue;
            let country;
            let countrycode;
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

    handleCountrycode(country){
        debugger;
        let countrycode;
        country = country.toLowerCase();
        country = country.charAt(0).toUpperCase() + country.slice(1);
        countrycode = this.countryCodeList.find(item => item.Name == this.CountryValue);
        this.countrycodevalue = countrycode.CountryCode__c;

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

    }
    createTaskRec() {
        debugger;
        if ((this.subjectvalue != null && this.subjectvalue != undefined && this.subjectvalue != '') && (this.CaptureOwnerId != null && this.CaptureOwnerId != undefined && this.CaptureOwnerId != '') && (this.priorityValue != null && this.priorityValue != undefined && this.priorityValue != '') && (this.statusValue != null && this.statusValue != undefined && this.statusValue != '')){
            createTask({ subject: this.subjectvalue, assignto: this.CaptureOwnerId, priority: this.priorityValue, status: this.statusValue, duedate: this.DuedateValue, taskcomments: this.comValue, followupDate: this.followupValue, leadId: this.recordId })

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
        else{
            alert('Mandatory Fields are Empty,Please Check and fill that Field(s)!! ');
        }
        
    }

    //open modal
    newhLeadBTN() {
        debugger;
        this.isShowModal = true;
        //this.getPuckistOflead();
    }
    // new task button
    @track showtaskModal = false;
    newTaskBTN() {
        debugger;
        this.showtaskModal = true;
    }

    hideshowTaskModal() {
        this.showtaskModal = false;
    }

    //close modal from innner button
    lookupRecord(event) {
        debugger;
        this.selectedrecordDetails = event.detail.selectedRecord;
        //alert('Selected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord));
    }
    handleCancel() {
        debugger;
        this.isShowModal = false;
        this.showtaskModal = false;

    }

    //close modal from innner button
    handleCancels() {
        debugger;
        this.isShowModal = false;
        //this.HandleLeadCreatedisable = false;
                        //this.namValue = '';
                        this.lNameValue = '';
                        this.commentsValue = '';
                        this.emailValue = '';
                        this.phoneValue = '';
                        this.CourceLead = '';
                        this.alterMobileValue = '';
                        this.alterEmailValue  = '';
                        this.CountryValue = '';
                        this.cityValue = '';
                        this.Leadvalue = '';
                        this.pageurl = '';
                        this.SelectedCountryStateList = [];
                        if (this.SelectedCountryStateList.length == 0) {
                            this.StateDisable = true;
                        }

    }
    FnameChange(Event) {
        debugger;
        let firstname = Event.target.value;
        this.namValue = firstname;
    }
    LnameChange(Event) {
        debugger;
        let lasttname = Event.target.value;
        this.lNameValue = lasttname;
    }
    EmailChange(Event) {
        debugger;
        let email = Event.target.value;
        //var returnvalue = this.handleIncorrectEmail(email)
        this.emailValue = email;


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

    handleCorrectPhone(PhoneToverify){
        var regExpPhoneformat = /^[0-9]{1,10}$/g;
        if (PhoneToverify.match(regExpPhoneformat)) {
            return true;
        }
        else {
            return false;
        }
    }
    HandleComments(event) {
        let comment = event.target.value;
        this.commentsValue = comment;
    }

    @track pageurl
    Handleurl(event){
        debugger;
        let purl = event.target.value;
        this.pageurl = purl;
    }


    PhoneChange(Event) {
        debugger;
        let phone = Event.target.value;
        this.phoneValue = phone;
    }

    @track alterEmailValue;
    AlterEmailChange(Event){
        this.alterEmailValue = Event.target.value;
    }
    @track alterMobileValue
    AlterPhoneChange(Event){
        this.alterMobileValue = Event.target.value;
    }

    StatusChange(Event) {
        debugger;
        let statuss = Event.target.value;
        this.lStatus = statuss;
    }

    CompanyChange(event) {
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
    }
    courceHandler(event) {
        debugger;
        let selectedCource = event.detail.value;
        this.CourceLead = selectedCource;
    }

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
    // @track LGEValue;
    // HandleLGE(event){
    //     debugger;
    //     let LGE=event.target.value;
    //     this.LGEValue=LGE;
    //}
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
    // @track PageUrlValue;
    // HandlePageURL(event){
    //     debugger;
    //     let Purl=event.target.value;
    //     this.PageUrlValue=Purl;
    // }

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

    //For Creating Task


    @wire(getMember)
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
    }

    @wire(getPuckistOflead)
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
    }

    // getPickiststatusOfTask
    @wire(getPickiststatusOfTask)
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
    }
    //getPickistpriorityOfTask
    @wire(getPickistpriorityOfTask)
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
    }

    handlecourseList() {
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
    }

    @track HandleLeadCreatedisable = false;

    createNewLead() {

        //(this.namValue != undefined && this.namValue != null && this.namValue != '') && 
        if ((this.lNameValue != undefined && this.lNameValue != null && this.lNameValue != '') && (this.emailValue != undefined && this.emailValue != null && this.emailValue != '') && (this.phoneValue != undefined && this.phoneValue != null && this.phoneValue != '')
            && (this.CourceLead != undefined && this.CourceLead != null && this.CourceLead != '') && (this.cityValue != undefined && this.cityValue != null && this.cityValue != '') && (this.sourceValue != undefined && this.sourceValue != null && this.sourceValue != '') && (this.MediumValue != undefined && this.MediumValue != null && this.MediumValue != '') &&
            (this.Leadvalue != undefined && this.Leadvalue != null && this.Leadvalue != '')) {
            this.HandleLeadCreatedisable = true;

            if (this.cityValue == 'Other') {
                this.cityValue = this.UserInputCity
            }
            debugger;
            var returnvalue = this.handleIncorrectEmail(this.emailValue)
            if (returnvalue == true && this.handleCorrectPhone(this.phoneValue)) { //firstname: this.namValue, 
                createLead({ Lastname: this.lNameValue, email: this.emailValue, phone: this.phoneValue, Course: this.CourceLead, agentid: this.agentrecid, city: this.cityValue, source: this.sourceValue, medium: this.MediumValue, VisitorId: this.VisitorIdValue, Transcript: this.TranscriptValue, leadGenPath: this.Leadvalue, state: this.StateValue, country: this.CountryValue, comments: this.commentsValue, pageurllanding:this.pageurl, countrycode : this.SelectedCountryISCode, AlternateMobile : this.alterMobileValue, AlternateEmail : this.alterEmailValue })
                    .then(data => {

                        if (data == 'SUCCESS') {
                            this.handleConfirm('Lead Created Successfully');
                        console.log(data)
                        //alert('Lead Record created successfully');
                        this.handleCancel();
                        this.HandleLeadCreatedisable = false;
                        //this.namValue = '';
                        this.lNameValue = '';
                        this.commentsValue = '';
                        this.emailValue = '';
                        this.phoneValue = '';
                        this.CourceLead = '';
                        this.alterMobileValue = '';
                        this.alterEmailValue  = '';
                        this.CountryValue = '';
                        this.cityValue = '';
                        this.Leadvalue = '';
                        this.pageurl = '';
                        }
                        else if (data == 'FAIL'){
                            this.HandleLeadCreatedisable=false;
                            this.handleAlert('Duplicate Lead Cannot be Created. Please Provide different Email and Phone');
                        }
                        
                    })
                    .catch(error => {
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
    }

    async handleConfirm(message) {
        /*const result = await LightningConfirm.open({
            message: message,
            theme: "success",
            label: "Success"
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

    
    async handleAlert(message) {
        await LightningAlert.open({
            message: message,
            theme: "error",
            label: "Alert"
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

    showpplicationForm() {

    }



    HandleCreateDisable = false;
    @track isLoadedApplication = false;

    createapplicationForm() {
        this.HandleCreateDisable = true;
        debugger;
        this.isLoadedApplication = true;
        createApplication({ Course: this.courseforApp, LeadId: this.recordId })
            .then(data => {
                debugger;

                this.showapplicationMOdal = false;
                this.HandleCreateDisable = false;
                this.handleConfirm('Application Created Successfully');
                this.isLoadedApplication = false;
                this.appbtndisAble = true;
                refreshApex(this.dataForApp);




            })
            .catch(error => {
                this.HandleCreateDisable = false;
                this.isLoadedApplication = false;
                this.handleAlert('Error updating or reloading records');
            })



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
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/walkInLeadPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring+ '&hascode=' + this.hashcode;
            window.open(urlString, "_self");

        }
        if (selectedVal == 'Voice') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/voiceFormPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring+ '&hascode=' + this.hashcode;
            window.open(urlString, "_self");

        }
        if (selectedVal == 'Generic') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/genericLeadAdditionPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring+ '&hascode=' + this.hashcode;
            window.open(urlString, "_self");

        }
        if (selectedVal == 'Chat') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/chatFormPage' + '?id=' + this.agentrecid + '&departments=' + this.DepartmentListstring+ '&hascode=' + this.hashcode;
            window.location.replace(urlString, "_self");
        }
    }

}