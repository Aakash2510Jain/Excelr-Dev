import { LightningElement, track } from 'lwc';
import EXCELR_LOGO from '@salesforce/resourceUrl/ExcelRLogo';
import LightningAlert from 'lightning/alert';
import LightningConfirm from "lightning/confirm";
import createBankDetails from '@salesforce/apex/bankDetaklsLwcContrroler.createBankDetails';
export default class BankDetails extends LightningElement {

    imageurl = EXCELR_LOGO;
    @track bankAccountNumer;
    @track ConfirmbankAccountNumer;
    @track ifseCode;
    @track Email;
    @track Phone;
    @track bankName;
    @track readOnly = false
    @track Name;
    @track notMatch = false;
    @track AcNumberTypr = "number";
    // @track feildList=[{AcNum:this.ConfirmbankAccountNumer,Bname:this.bankName,ifseCode:this.ifseCode,CandidateEmail:this.Email,Phone:this.Phone}];

    AccountHandler(Event) {
        debugger;
        let bakAccNum = Event.target.value;
        this.bankAccountNumer = bakAccNum;
    }
    ConAccountHandler(Event) {
        debugger;
        let confirAccNum = Event.target.value;
        this.ConfirmbankAccountNumer = confirAccNum;
        if (this.ConfirmbankAccountNumer != this.bankAccountNumer) {
            this.notMatch = true;
        }
        else {
            this.notMatch = false;
            this.readOnly = true;
            this.AcNumberTypr = "password"
        }
    }
    ifseHandler(Event) {
        debugger;
        let ifseCode = Event.target.value;
        this.ifseCode = ifseCode;
    }
    emailHandler(Event) {
        debugger;
        let email = Event.target.value;
        this.Email = email;
    }
    phoneHandler(Event) {
        debugger;
        let phone = Event.target.value;
        this.Phone = phone;
    }
    bankNameHandler(Event) {
        debugger;
        let bankname = Event.target.value;
        this.bankName = bankname;
    }

    savebankDetailBTN() {

        var returnvalue = this.handleIncorrectEmail(this.Email)
        debugger;
        if (returnvalue == true){
            createBankDetails({ AcNum: this.ConfirmbankAccountNumer, Bname: this.bankName, ifseCode: this.ifseCode, CandidateEmail: this.Email, Phone: this.Phone })
            .then(result => {
                debugger;
                this.handleConfirm();
                this.ConfirmbankAccountNumer = '';
                this.bankName = '';
                this.ifseCode = '';
                this.Email = '';
                this.Phone = '';
                this.bankAccountNumer = '';
                console.log(`hii there im getting success from save bd`);
            })
            .catch(error => {
                this.handleAlert();
            })

        }else{
            alert('Enter Correct Email with Proper format');
        }
    }

    handleIncorrectEmail(emailtocheck) {
        debugger;
        
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(emailtocheck.match(regExpEmailformat)){
            return true;
        }
        else{
            return false;

        }
    }

    handlePaste(event) {
        //alert("yo");
        event.preventDefault();
    }

    handleContext(event) {
        alert('test');
        event.preventDefault();
    }
    async handleConfirm() {
        const result = await LightningConfirm.open({
            message: "Refund Form submitted Successfully",
            theme: "success",
            label: "Success"
        });
        console.log("🚀 ~ result", result);
    }

    async handleAlert() {
        await LightningAlert.open({
          message: "Error in Submission of Refund Form. Please try after Sometime",
          theme: "error",
          label: "Alert"
        }).then(() => {
          console.log("###Alert Closed");
        });
      }

}