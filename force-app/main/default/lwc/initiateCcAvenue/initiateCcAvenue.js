import { LightningElement, wire,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import GettingPaymentLink from '@salesforce/apex/ccAvenueLwcController.GettingPaymentLink';

export default class InitiateCcAvenue extends LightningElement {

    @api recordId;

    
    renderedCallback() {
        setTimeout(() => {

            this.GetPaymentLinkCreateInvoice();

        }, 3);
    }

     GetPaymentLinkCreateInvoice(){
        GettingPaymentLink({recordId:this.recordId})
        .then(result=>{

            if(result=='SUCCESS'){
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error=>{

        })
     }
     
}