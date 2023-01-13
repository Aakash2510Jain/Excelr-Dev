import { api, LightningElement, track, wire } from 'lwc';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLead from '@salesforce/apex/voiceFormLWCcontroller.getLead';
import getApplication from '@salesforce/apex/voiceFormLWCcontroller.getApplication';
import EmailIsm from '@salesforce/apex/voiceFormLWCcontroller.EmailIsm';
import getMember from '@salesforce/apex/voiceFormLWCcontroller.getMember';
import getPuckistOflead from '@salesforce/apex/voiceFormLWCcontroller.getPuckistOflead';

import getPickiststatusOfTask from '@salesforce/apex/voiceFormLWCcontroller.getPickiststatusOfTask';
import getPickistpriorityOfTask from '@salesforce/apex/voiceFormLWCcontroller.getPickistpriorityOfTask';
import createTask from '@salesforce/apex/voiceFormLWCcontroller.createTaskForVoice';

import createLead from '@salesforce/apex/voiceFormLWCcontroller.createLead';
import createApplication from '@salesforce/apex/voiceFormLWCcontroller.CreateApplication';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_GEN_PATH from '@salesforce/schema/Lead.Lead_Gen_Path__c';
import LEAD_SOURCE from '@salesforce/schema/Lead.LeadSource';
import LEAD_MEDIUM from '@salesforce/schema/Lead.UTM_Medium__c';
import FetchStateCounty from '@salesforce/apex/voiceFormLWCcontroller.FetchStateCounty';
import Fetchcities from '@salesforce/apex/voiceFormLWCcontroller.Fetchcities';



import QueryPastLeads from '@salesforce/apex/voiceFormLWCcontroller.QueryPastLeads';
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


export default class voiceForm extends LightningElement {
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
    @track commentsValue ;
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
 
    @track Leadvalue;

    connectedCallback() {
        //defined a varibale
        this.convertStringtoList();

    }
    convertStringtoList(){
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

    Picklistvalue=[];
    @wire(getObjectInfo, {objectApiName:LEAD_OBJECT})
    objectInfo
     //Getting Picklist Field Of Lead GenPath
    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:LEAD_GEN_PATH})
     wiredPicklistLeadGenPath({data,error}){
         debugger;
        if(data){
           console.log('data=',data);
           console.log('dataValues=',data.values);
           let arr=[];
           for(let i=0;i<data.values.length;i++){
            if((data.values[i].value=="Direct Calls") || (data.values[i].value=="Tollfree") ){
                arr.push({label:data.values[i].label,value:data.values[i].value});
            }  
           }
           this.Picklistvalue=arr;
           console.log('Picklistvalue=',this.Picklistvalue);
        }
        else {
            console.log('error=',error)
        }
     }

     get ldGenPath(){
        return this.Picklistvalue;
     }

     ldGenPathValue(event){
        debugger;
        this.Leadvalue=event.target.value;
     }

     //Getting Picklist Field Of LeadSource
     @track LeadSourcePicklist=[];
     @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:LEAD_SOURCE})
     wiredPicklistLeadSource({data,error}){
         debugger;
        if(data){
           console.log('data=',data);
           console.log('dataValues=',data.values);
           let arr=[];
           for(let i=0;i<data.values.length;i++){
              arr.push({label:data.values[i].label,value:data.values[i].value});
           }
           this.LeadSourcePicklist=arr;
           console.log('Picklistvalue=',this.LeadSourcePicklist);
        }
        else {
            console.log('error=',error)
        }
     }

     get leadSource(){
        return this.LeadSourcePicklist;
     }

     @track SourceValue;
     HandleSource(event){
        debugger;
        let Source=event.target.value;
        this.SourceValue=Source;
     }

     //Getting Picklist Field Of Medium
     @track LeadMediumPicklist=[];
     @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:LEAD_MEDIUM})
     wiredPicklistLeadMedium({data,error}){
         debugger;
        if(data){
           console.log('data=',data);
           console.log('dataValues=',data.values);
           let arr=[];
           for(let i=0;i<data.values.length;i++){
              arr.push({label:data.values[i].label,value:data.values[i].value});
           }
           this.LeadMediumPicklist=arr;
           console.log('Picklistvalue=',this.LeadMediumPicklist);
        }
        else {
            console.log('error=',error)
        }
     }

     get leadmedium(){
        return this.LeadMediumPicklist;
     }

     @track MediumValue;

    HandleMedium(event){
        debugger;
      let Medium=event.target.value;
      this.MediumValue=Medium;
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
                console.log('LeadId===',this.data.Id);
                if (this.data.length > 0) {
                    //this.newBTNdisAble = true;
                    this.taskBTNdisAble = false;
                    this.recordId = this.data[0].Id;
                    this.ownerEmail = data[0].Owner_Email__c;
                    this.CaptureOwnerId = data[0].OwnerId;
                    this.captureownerName = data[0].Owner.Name;
                    this.handleClick();
                    console.log(data);
                    console.log(this.data);
                    console.log(this.data[0].Id)
                   console.log('Capture Owner Name',this.captureownerName);
                    this.ismBTNdisAble = false;
                    this.ifdataNotFound = false;
                    this.appbtndisAble = false;
                    
                }
                if (this.data.length == 0) {
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
            console.log(this.dataForApp);
            this.columns = applicationcolumns;
            if (Array.isArray(this.dataForApp.data)) {
                if (this.dataForApp.data.length > 0) {
                    //this.appbtndisAble = false;
                }
                else if(this.dataForApp.data.length == 0) {
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
    createTaskRec()
    {
         debugger;
        createTask({ subject: this.subjectvalue, assignto:this.CaptureOwnerId,priority:this.priorityValue,status:this.statusValue,duedate:this.DuedateValue,comments:this.comValue,followupDate:this.followupValue,leadId:this.recordId })

            .then((result) => {
                console.log('result',result);
                if(result=='Success'){
                    this.handleConfirm('Task Created Successfully');
                    this.showtaskModal=false;
                }
               
            })
            .catch((error) => {
                this.error = error;
                console.log('error',error);
            });
    }
    

    //open modal
    newhLeadBTN() {
        debugger;
        this.isShowModal = true;
        //this.getPuckistOflead();
    }
    
    @track showtaskModal=false;
    newTaskBTN()
    {
        debugger;
        this.showtaskModal = true;
    }

    hideshowTaskModal()
    {
        this.showtaskModal = false;  
    }

    //close modal from innner button
   
    handleCancel() {
        debugger;
        this.isShowModal = false;
        this.showtaskModal=false;

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

    @track StateCountryValue=[];
    @wire(FetchStateCounty)
    WiredResponsestatesCountry({data,error}){
        debugger;
        if(data){
            console.log('StateCountryValuedata=',data);
           this.StateCountryValue=data;
           console.log('StateCountryValue=',this.StateCountryValue); 
        }
        else if(error){
            console.log('error=',error);
        }

    }

    @track CityPicklistValue=[];
    @track cityValue;
    @wire(Fetchcities)
    WiredResponsecities({data,error}){
        debugger;
        if(data){
         console.log('CityValuedata=',data);
           let arr=[];
           for(let i=0;i<data.length;i++){
              arr.push({label:data[i].City__c,value:data[i].City__c});
           }
           this.CityPicklistValue=arr;
           console.log('Picklistvalue=',this.CityPicklistValue);
        }
        else if(error){
            console.log('error=',error);
        }

    }

   get CityOptions(){
     return this.CityPicklistValue;
   }

    @track CountryDisable=true;
    @track StateDisable=true;
    @track StateValue;
    @track CountryValue;
    @track InputCity=false;
    HandleCityStatus(event){

        debugger;
        let city=event.detail.value;
        if(city){
            this.cityValue=city;
            let state;
            let TempValue;
            let country;
            TempValue=city;
           
            console.log('Tempstate=',TempValue);

            if(TempValue=="Other"){
                this.StateDisable=false;
                this.CountryDisable=false;
                alert('Please Type Your State and Country');
                this.InputCity=true;
               
            }
            else{
                this.StateDisable=true;
                this.CountryDisable=true;
            }

            if(TempValue){
                TempValue=TempValue.charAt(0).toUpperCase() + TempValue.slice(1);
                console.log('Tempstate2=',TempValue);
                state = this.StateCountryValue.find(item=>item.City__c==TempValue);
                country=this.StateCountryValue.find(item=>item.City__c==TempValue);
                console.log('state=',state);
                
            }

            if(state){
                this.StateValue=state.State__c;
                this.CountryValue=country.Country__c;
                console.log('StateValue=',this.StateValue); 
            }
            else {
                this.StateValue='';
                this.CountryValue='';
            }
           

            
            console.log('state=',this.StateValue);
        }
        
    }

    @track UserInputCity
    HandleUserCityStatus(event){
        let value=event.target.value;
        if(this.cityValue=='Other'){
            this.UserInputCity=value;
        }

    }

    HandleChangeStateCountry(event){
        if(this.cityValue=='Other'){
            debugger;
           let value=event.target.value;
    
           if(event.target.name=="State"){
    
            this.StateValue=value;
           }
           if(event.target.name=="Country"){
    
            this.CountryValue=value;
           }
        }
          
       }

    // @track LGEValue;
    // HandleLGE(event){
    //     debugger;
    //     let LGE=event.target.value;
    //     this.LGEValue=LGE;
    // }


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
    HandleComments(event)
    {
       let comment = event.target.value;
       this.commentsValue = comment;
    }
    PhoneChange(Event) {
        debugger;
        let phone = Event.target.value;
        this.phoneValue = phone;
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
    subjectHandler(event)
    {
       debugger;
       let selectedSubject = event.target.value;
       this.subjectvalue = selectedSubject;
    }

    @track statusValue;
    statusHandler(event)
    {
        debugger;
        let selectedStatus = event.detail.value;
        this.statusValue = selectedStatus;
    }

    @track DuedateValue;
    duedateHandler(event)
    {
        debugger;
        let selectedDuedate = event.detail.value;
        this.DuedateValue = selectedDuedate;

    }

    @track comValue;
    commentHandler(event)
    {
        debugger;
        let selectedComment = event.target.value;
        this.comValue = selectedComment;
    }
    @track followupValue;
    followupHandler(event)
    {
        debugger;
        let selectedfollowup = event.target.value;
        this.followupValue = selectedfollowup;
    }

   
    @track priorityValue;
    priorityHandler(event)
    {
        debugger;
        let selectedPriority = event.detail.value;
        this.priorityValue = selectedPriority;
    }
   
    @track statusValue;
    statusHandler(event)
    {
        debugger;
       let selectedStatus = event.detail.value;
       this.statusValue =  selectedStatus;
    }


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
    //wire method name changed
    @wire(getPuckistOflead)
    wireRss({ error, data }) {
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
            console.log(data);
            console.log('statusList--',this.StatusList);
        }
        if (error) {
             console.log('error=',error);
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
            console.log(data)
        }
        if (error) {

        }
    }

   /* 793 - 812 */
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
                console.log('error=',error);
            });
     }
    HandleLeadCreatedisable=false;
    createNewLead() {
        debugger;
        if((this.namValue!=undefined && this.namValue!=null ) && (this.lNameValue!=undefined && this.lNameValue!=null ) && (this.emailValue!=undefined && this.emailValue!=null ) && (this.phoneValue!=undefined && this.phoneValue!=null ) 
        && (this.CourceLead!=undefined && this.CourceLead!=null ) && (this.cityValue!=undefined && this.cityValue!=null ) && (this.SourceValue!=undefined && this.SourceValue!=null ) && (this.MediumValue!=undefined && this.MediumValue!=null ) && 
            (this.Leadvalue!=undefined && this.Leadvalue!=null ))
           {

            this.HandleLeadCreatedisable=true; 

            if(this.cityValue=='Other'){
                this.cityValue=this.UserInputCity
            }
            
        
        var returnvalue = this.handleIncorrectEmail(this.emailValue)
        var phoneregexreturnvalue = this.handleCorrectPhone(this.phoneValue)
        console.log('returnVALUE=',returnvalue);
        if (returnvalue == true && this.handleCorrectPhone(this.phoneValue)) {
            createLead({ firstname: this.namValue, Lastname: this.lNameValue, email: this.emailValue, phone: this.phoneValue, ownerId: this.ismeId, agmId: this.gruoMemberId, Course: this.CourceLead, agentid: this.agentrecid,city:this.cityValue,LdGenPath:this.Leadvalue,source:this.SourceValue,medium:this.MediumValue,country:this.CountryValue,state:this.StateValue,comments:this.commentsValue})
                .then(data => {
                    this.handleConfirm('Lead Created Successfully');
                    this.HandleLeadCreatedisable=false; 
                    console.log(data)
                    //alert('Lead Record created successfully');
                    this.handleCancel();
                    this.namValue = '';
                    this.lNameValue = '';
                    this.commentsValue = '';
                    this.agentrecid= '';
                    this.ismeId = '';
                    this.emailValue = '';
                    this.phoneValue = '';
                    this.gruoMemberId = '';
                    this.CourceLead = '';
                    this.CountryValue = '';
                    this.cityValue = '';
                    this.Leadvalue = '';

                })
                .catch(error => {
                    this.handleAlert('Error updating or reloading records');
                    this.handleCancel();
                    this.HandleLeadCreatedisable=false; 
                    
                })
       }
        else {
            alert('Incorrect Email or Phone Pattern');
            this.HandleLeadCreatedisable=false; 
        }

    }
    else{
        alert('All Fields are Mandatory,Please Check any one Of Your Field Is Empty');
        this.HandleLeadCreatedisable=false; 
    }

    }

    async handleConfirm(message) {
        const result = await LightningConfirm.open({
            message: message,
            theme: "success",
            label: "Success"
        });
        console.log("🚀 ~ result", result);
    }

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

    
    
    HandleCreateDisable=false;
    @track isLoadedApplication=false;
    createapplicationForm() {
        this.HandleCreateDisable=true;
        this.isLoadedApplication=true;
        debugger;
        createApplication({ Course: this.courseforApp, LeadId: this.recordId })
            .then(data => {
                debugger;
                this.showapplicationMOdal = false;
                this.HandleCreateDisable=false;  
                this.handleConfirm('Application Created Successfully');
                this.isLoadedApplication=false;
                this.appbtndisAble = true;
                refreshApex(this.dataForApp);
                
                
                
                
            })
            .catch(error => {
                this.HandleCreateDisable=false;
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
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/walkInLeadPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.open(urlString, "_self");
            
        }
        if (selectedVal == 'Voice') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/voiceFormPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.open(urlString, "_self");
            
        }
        if (selectedVal == 'Generic') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/genericLeadAdditionPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.open(urlString, "_self");
        }
        if (selectedVal == 'Chat') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/chatFormPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.location.replace(urlString, "_self");
        }
    }

}