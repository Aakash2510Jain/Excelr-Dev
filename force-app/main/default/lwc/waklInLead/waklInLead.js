import { api, LightningElement, track, wire } from 'lwc';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLead from '@salesforce/apex/walkInLeadLWCcontroller.getLead';
import getApplication from '@salesforce/apex/walkInLeadLWCcontroller.getApplication';
import EmailIsm from '@salesforce/apex/walkInLeadLWCcontroller.EmailIsm';
import getMember from '@salesforce/apex/walkInLeadLWCcontroller.getMember';
import getPuckistOflead from '@salesforce/apex/walkInLeadLWCcontroller.getPuckistOflead';
import createLead from '@salesforce/apex/walkInLeadLWCcontroller.createLead';
import createApplication from '@salesforce/apex/walkInLeadLWCcontroller.CreateApplication';
import FirstName from '@salesforce/schema/Lead.FirstName';
import LastName from '@salesforce/schema/Lead.LastName';
import Email from '@salesforce/schema/Lead.Email';
import Phone from '@salesforce/schema/Lead.Phone';
import ISM__c from '@salesforce/schema/Lead.ISM__c';
import Status from '@salesforce/schema/Lead.Status';
import Profession__c from '@salesforce/schema/Lead.Profession__c';
import HasOptedOutOfEmail from '@salesforce/schema/Lead.HasOptedOutOfEmail';
import HasOptedOutOfFax from '@salesforce/schema/Lead.HasOptedOutOfFax';
import Specialization__c from '@salesforce/schema/Lead.Specialization__c';
import ISM_Name__c from '@salesforce/schema/Lead.ISM_Name__c';
import Year_of_Graduation__c from '@salesforce/schema/Lead.Year_of_Graduation__c';
import Year_of_Experience__c from '@salesforce/schema/Lead.Year_of_Experience__c';
import Total_Calls__c from '@salesforce/schema/Lead.Total_Calls__c';
import Total_Applications_Submitted__c from '@salesforce/schema/Lead.Total_Applications_Submitted__c';
import Branch__c from '@salesforce/schema/Lead.Branch__c';
import Why_This_Course__c from '@salesforce/schema/Lead.Why_This_Course__c';
import Whatsapp_Opt_in__c from '@salesforce/schema/Lead.Whatsapp_Opt_in__c';
import Total_Emails__c from '@salesforce/schema/Lead.Total_Emails__c';
import Total_Conversation_Duration__c from '@salesforce/schema/Lead.Total_Conversation_Duration__c';
import Total_Connected_Call__c from '@salesforce/schema/Lead.Total_Connected_Call__c';
import Total_Call_Duration__c from '@salesforce/schema/Lead.Total_Call_Duration__c';
import Telephonic_Conversation__c from '@salesforce/schema/Lead.Telephonic_Conversation__c';
import Source__c from '@salesforce/schema/Lead.Source__c';
import Relevant_Experience__c from '@salesforce/schema/Lead.Relevant_Experience__c';
import Refree_Mob_No__c from '@salesforce/schema/Lead.Refree_Mob_No__c';
import Reason_for_On_Hold__c from '@salesforce/schema/Lead.Reason_for_On_Hold__c';
import Reason_For_Dead__c from '@salesforce/schema/Lead.Reason_For_Dead__c';
import Rating from '@salesforce/schema/Lead.Rating';
import Qualification__c from '@salesforce/schema/Lead.Qualification__c';
import LeadSource from '@salesforce/schema/Lead.LeadSource';
import OwnerId from '@salesforce/schema/Lead.OwnerId';
import Is_Phone_Invalid__c from '@salesforce/schema/Lead.Is_Phone_Invalid__c';
import Is_Email_Invalid__c from '@salesforce/schema/Lead.Is_Email_Invalid__c';
import Hi__c from '@salesforce/schema/Lead.Hi__c';
import Form_Source__c from '@salesforce/schema/Lead.Form_Source__c';
import Enquired_Course__c from '@salesforce/schema/Lead.Enquired_Course__c';
import Email_Conversation_Done__c from '@salesforce/schema/Lead.Email_Conversation_Done__c';
import Do_you__c from '@salesforce/schema/Lead.Do_you__c';
import Device__c from '@salesforce/schema/Lead.Device__c';
import Designation__c from '@salesforce/schema/Lead.Designation__c';
import Date_of_Enrollment__c from '@salesforce/schema/Lead.Date_of_Enrollment__c';
import Course__c from '@salesforce/schema/Lead.Course__c';
import CID__c from '@salesforce/schema/Lead.CID__c';
import Campaign__c from '@salesforce/schema/Lead.Campaign__c';
import Name from '@salesforce/schema/Lead.Name';

import QueryPastLeads from '@salesforce/apex/walkInLeadLWCcontroller.QueryPastLeads';
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
    @track CourceLead;
    @track courseforApp;
    @api recordId;
    @track newBTNdisAble = false;
    @track ISM_Name = ISM_Name__c;
    @track Profession = Profession__c;
    @track statusLead = Status;
    @track Fanme = FirstName;
    @track Lname = LastName;
    @track Email = Email;
    @track Phone = Phone;
    @track HasOptedOutOfEmail = HasOptedOutOfEmail;
    @track HasOptedOutOfFax = HasOptedOutOfFax;
    @track Specialization = Specialization__c;
    @track ism = ISM__c;
    @track Year_of_Graduation = Year_of_Graduation__c;
    @track Year_of_Experience = Year_of_Experience__c;
    @track Total_Calls = Total_Calls__c;
    @track Total_Applications_Submitted = Total_Applications_Submitted__c;
    @track Branch = Branch__c;
    @track objectApiName = 'Lead';

    @track Why_This_Course = Why_This_Course__c;
    @track Whatsapp_Opt_in = Whatsapp_Opt_in__c;
    @track Total_Emails = Total_Emails__c;
    @track Total_Conversation_Duration = Total_Conversation_Duration__c;
    @track Total_Connected_Call__c = Total_Connected_Call__c;
    @track Total_Call_Duration = Total_Call_Duration__c;
    @track Telephonic_Conversation = Telephonic_Conversation__c;
    @track Source = Source__c;
    @track Relevant_Experience = Relevant_Experience__c;
    @track Refree_Mob_No = Refree_Mob_No__c;
    @track Reason_for_On_Hold = Reason_for_On_Hold__c;
    @track Reason_For_Dead = Reason_For_Dead__c;
    @track Rating = Rating;
    @track Qualification = Qualification__c;
    @track LeadSource = LeadSource;
    @track ISM = OwnerId;
    @track Is_Phone_Invalid = Is_Phone_Invalid__c;
    @track Is_Email_Invalid__c = Is_Email_Invalid__c;
    @track Hic = Hi__c;
    @track Form_Source = Form_Source__c;
    @track Enquired_Course = Enquired_Course__c;
    @track Email_Conversation = Email_Conversation_Done__c;
    @track Do_you = Do_you__c;
    @track Device = Device__c;
    @track Designation = Designation__c;
    @track Date_of_Enrollment = Date_of_Enrollment__c;
    @track Course = Course__c;
    @track CID = CID__c;
    @track Campaign = Campaign__c;
    @track Name = Name;

    @track gruoMemberId;
    @track ismeId;
    @track inPutValue;
    @track objectList;
    @track columns;
    @track isShowModal = false;
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
    @track showFromOrEmpty = false;

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

    }
    emailHandler(Event) {
        debugger;
        let EmailOrPhone = Event.target.value;
        this.inPutValue = EmailOrPhone;
    }

    serachLeadBTN() {
        debugger;
        getLead({ EmailOrPhone: this.inPutValue })
            .then(data => {
                debugger;
                this.showFromOrEmpty = true;
                this.data = data;
                if (this.data.length > 0) {
                    this.newBTNdisAble = true;
                    this.recordId = this.data[0].Id;
                    this.ownerEmail = data[0].Owner_Email__c;
                    console.log(data);
                    console.log(this.data);
                    console.log(this.data[0].Id)
                    this.ismBTNdisAble = false;
                    this.ifdataNotFound = false;
                    this.appbtndisAble = false;
                }
                if (this.data.length == 0) {
                    this.ifdataNotFound = true;
                    this.newBTNdisAble = false;
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

    //open modal
    newhLeadBTN() {
        debugger;
        this.isShowModal = true;
        //this.getPuckistOflead();
    }
    //close modal from innner button
    handleCancel() {
        debugger;
        this.isShowModal = false;

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

    createNewLead() {
        debugger;
        var returnvalue = this.handleIncorrectEmail(this.emailValue)
        if (returnvalue == true) {
            createLead({ firstname: this.namValue, Lastname: this.lNameValue, email: this.emailValue, phone: this.phoneValue, ownerId: this.ismeId, agmId: this.gruoMemberId, Course: this.CourceLead, userId: this.selectedrecordDetails.Id, agentid: this.agentrecid })
                .then(data => {
                    this.handleConfirm('Lead Created Successfully');
                    console.log(data)
                    alert('Lead Record created successfully');
                    this.handleCancel();

                })
                .catch(error => {
                    this.handleAlert('Error updating or reloading records');

                })
        }
        else {
            alert('Incorrect Email Pattern');
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


    ShowPastLeadPage() {
        debugger;
        QueryPastLeads({ ExcelRagentid: this.agentrecid })
            .then(data => {
                debugger;

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

    createapplicationForm() {
        this.HandleCreateDisable=true;
        debugger;
        createApplication({ Course: this.courseforApp, LeadId: this.recordId })
            .then(data => {
                debugger;
                
                this.showapplicationMOdal = false;
                this.HandleCreateDisable=false;
                this.handleConfirm('Appication Created Successfully');
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

}