import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import sendPaymentLink from '@salesforce/apex/RazorpayPaymentLWCController.sendPaymentLink';
import updateOpp from '@salesforce/apex/RazorpayPaymentLWCController.updateOpp';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Razorpaypaymentinitiate extends LightningElement {
    @api recordId;

    @wire(sendPaymentLink, { recordId: "$recordId" })
    paymentResp(result) {
        debugger;
        console.log('RecordId--',this.recordId);
        if (result.data) {
            console.log(result);
            if(result.data=='Success'){
                this.showNotification('Success','Payment link sent succesfully!','success');
                this.updateOpportunity();
                this.refreshPage();
            }else{
                this.showNotification('Failed',result.data,'error');
                this.closeAction();
            }
        }else if (!this.recordId && !result.data) {
            console.log('Payment Initated ----------------------')
        } else if (this.recordId && !result.data) {
            alert('Payment Failed');
            this.closeAction();
        }
    }


    updateOpportunity(){

        updateOpp({recordId:this.recordId}).then(result=>{

        }).catch(error=>{
            console.log('Error to update the contact')
        })
    }

    refreshPage(){

        this.dispatchEvent(new CloseActionScreenEvent());

        if(window && this.recordId) {

            window.location.href='/lightning/r/Opportunity/'+this.recordId+'/view';

        }

    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}