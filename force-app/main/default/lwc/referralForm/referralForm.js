import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COURSE_FIELD from '@salesforce/schema/Lead.Course__c';
import SubmitReferralDetails from '@salesforce/apex/ReferralFormController.SubmitReferralDetails';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';

import LightningAlert from 'lightning/alert';
import LightningConfirm from "lightning/confirm";

export default class ReferralForm extends LightningElement {
    imageurl = EXCELR_LOGO;

    @track FirstName
    @track Lastname
    @track Phone
    @track Email
    @track Coursevalue
    @track ReferralEmail
    @track ReferralPhone
    @track msg

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COURSE_FIELD })
    CoursePicklistValues

    ReferralFormInputHandler(event) {
        debugger;

        //var InputName = event.getSource().get("v.name");
        var InputName = event.currentTarget.name;
        let Textvalue = event.target.value;
        if (InputName == 'FN') {
            this.FirstName = Textvalue;
        }
        else if (InputName == 'LN') {
            this.Lastname = Textvalue;
        }
        else if (InputName == 'EM') {
            this.Email = Textvalue
        }
        else if (InputName == 'PH') {
            this.Phone = Textvalue;
        }
        else if (InputName == 'REFEM') {
            this.ReferralEmail = Textvalue;
        }
        else if (InputName == 'REFPH') {
            this.ReferralPhone = Textvalue;
        }
        else if (InputName == 'CR') {
            this.Coursevalue = Textvalue;
        }

    }

    SaveReferralFormDetails() {
        debugger;

        if ((this.FirstName != undefined && this.FirstName != null) && (this.Lastname != undefined && this.Lastname != null) && (this.Email != undefined && this.Email != null) && (this.Phone != undefined && this.Phone != null) && (this.ReferralEmail != undefined && this.ReferralEmail != null) && (this.ReferralPhone != undefined && this.ReferralPhone != null)) {
            var returnvalue = this.handleIncorrectEmail(this.Email)
            var phoneregexreturnvalue = this.handleCorrectPhone(this.Phone)
            if (returnvalue == true && this.handleCorrectPhone(this.phoneValue)) {
                SubmitReferralDetails({ FirstN: this.FirstName, LastName: this.Lastname, Email: this.Email, Phone: this.Phone, ReferralEm: this.ReferralEmail, ReferralPh: this.ReferralPhone, Course: this.Coursevalue })
                    .then(result => {
                        debugger;
                        if (result == 'SUCCESS') {
                            this.FirstName = '';
                            this.Lastname = '';
                            this.Email = '';
                            this.Phone = '';
                            this.ReferralEmail = '';
                            this.ReferralPhone = '';
                            this.Coursevalue = '';
                            this.handleConfirm('Referral Form Submitted Successfully');

                        }
                        else if (result == 'Fail') {
                            this.handleAlert('Referral Email Does not Exist In the system. Please Provide correct email Id!!!!!');
                        }

                    })
                    .catch(error => {
                        this.handleAlert('Error in Submission of Referral Form. Please try after Sometime');
                    })

            }
            else {
                alert('Incorrect Email or Phone Pattern');
                this.HandleLeadCreatedisable = false;
            }
        }
        else{
            alert('All Fields are Mandatory,Please Check any one Of Your Field Is Empty');
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

    handleCorrectPhone(PhoneToverify) {
        var regExpPhoneformat = /^[0-9]{1,10}$/g;
        if (PhoneToverify.match(regExpPhoneformat)) {
            return true;
        }
        else {
            return false;
        }
    }

    async handleConfirm(msg) {
        const result = await LightningConfirm.open({
            message: msg,
            theme: "success",
            label: "Success"
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
}