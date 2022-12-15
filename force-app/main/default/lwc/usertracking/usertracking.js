import { LightningElement,wire,track} from 'lwc';
import uId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import user_checkin from '@salesforce/apex/UserTracking.UserCheckin';
import user_checkout from '@salesforce/apex/UserTracking.UserCheckout';
import checkin_check from '@salesforce/apex/UserTracking.OnpageLoad';
import manage_breakTime from '@salesforce/apex/UserTracking.manageBreakTime';
import { refreshApex } from '@salesforce/apex';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Usertracking extends LightningElement {

    userId = uId;
   
    wiredResult;
    @track disableCheckin = true;
    @track disableCheckout = true;
    @track disableBreak = true;
    @track breakStatus = 'Start BreakTime';

    @track showCheckoutPopup = false;
    @track showCheckoutSpinner = false;
    @track usernameChoosed;

    @wire(checkin_check,{userId: uId})
    wiredResponse(result){
        this.wiredResult = result;
        if(result.data){
            this.disableCheckin = result.data.checkin;
            this.disableCheckout = result.data.checkout;

            if(result.data.checkin && !result.data.checkout){
                this.disableBreak = false;
                this.breakStatus = result.data.IsbreakStarted?'End BreakTime':'Start BreakTime'
            }else{
                this.disableBreak = true;
            }
        }
        console.log('Result: ' , result)
    }

    checkin() {
        debugger;
        user_checkin({ userId: uId }).then(result => {
            refreshApex(this.wiredResult);
            debugger;
            if (result == 'Checkin successful') {                
                this.showToast('Checkin',result,'success');
            }
            if (result == 'You can not checkin on sunday.') {
                this.showToast('Checkin',result,'warning');
            }
            if (result == 'Your checkin was already created.') {
                this.showToast('Checkin',result,'info');
            }
            if (result == 'User is not registered in system.Please contact to your admin.') {
                this.showWarningToast('Checkin',result,'warning');
            }
            if (result == 'You can not checkin before 10:00 AM.') {
                this.showWarningToast('Checkin',result,'warning');
            }
        }).catch(err => {
            console.log('Error:::' + err);
        })
    }

    checkoutPopupHandler(){
        this.showCheckoutPopup = true;
    }

    dismissCheckoutPopupHanlder(){
        this.showCheckoutPopup = false;
    }

    userNameHandler(event){
        this.usernameChoosed = event.target.value;
    }

    checkout() {

        if(this.wiredResult.data.username){
            console.log(this.wiredResult.data.username.trim().toLowerCase())
            console.log(this.usernameChoosed.trim().toLowerCase());

            debugger;
            if(this.wiredResult.data.username.replace(' ','').toLowerCase()==this.usernameChoosed.replace(' ','').toLowerCase()){
                this.showCheckoutSpinner = true;

                user_checkout({ userId: uId }).then(result => {
                    this.showCheckoutSpinner = false;
                    this.dismissCheckoutPopupHanlder();
                    refreshApex(this.wiredResult);
                    this.showToast('Checkout',result,'success');
                }).catch(err => {
                    console.log('err::' + err);
                })
            }else{
                this.showToast('Error','Incorrect Username','error');
            }
            console.log('UserName----',this.wiredResult.data.username)
        }else{
            this.showToast('Error','username not found','error');
        }
    }

    breakStart() {
        manage_breakTime({ userId: uId }).then(result => {
            this.showToast('Success',`${this.breakStatus!='Start BreakTime'?'BreakTime ended 😐':'BreakTime Started, Yay! 😃🎉'}`,'success')
            refreshApex(this.wiredResult);
        }).catch(err => {
            console.log('err::' + err);
        })
    }

    showToast(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showWarningToast(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}