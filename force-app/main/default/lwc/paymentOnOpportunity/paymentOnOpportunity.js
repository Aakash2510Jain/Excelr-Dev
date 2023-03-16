import { LightningElement, api, wire, track } from 'lwc';
import ShowOppAmount from '@salesforce/apex/PaymentOnOpportunityApexController.ShowOppAmount';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ShowAmount from '@salesforce/apex/PaymentOnOpportunityApexController.ShowAmount';
import ShowNbfcPartners from '@salesforce/apex/PaymentOnOpportunityApexController.ShowNbfcPartners';
//import CreateOppLineItem from '@salesforce/apex/PaymentOnOpportunityApexController.CreateOppLineItem';
import OppUpdateOnFullLoan from '@salesforce/apex/PaymentOnOpportunityApexController.OppUpdateOnFullLoan';
import OppUpdateOnPartialLoan from '@salesforce/apex/PaymentOnOpportunityApexController.OppUpdateOnPartialLoan';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';
//import PAYMENT_FIELD from '@salesforce/schema/Opportunity.Payment_Mode__c';
import ShowPriceIncludingGST from '@salesforce/apex/PaymentOnOpportunityApexController.ShowPriceIncludingGST';
//import CreateInvoice from '@salesforce/apex/PaymentOnOpportunityApexController.CreateInvoice';
import UpdateOPPforFullPayment from '@salesforce/apex/PaymentOnOpportunityApexController.UpdateOPPforFullPayment';
import UpdateOPPforPartialPayment from '@salesforce/apex/PaymentOnOpportunityApexController.UpdateOPPforPartialPayment';
import { updateRecord } from 'lightning/uiRecordApi';


export default class PaymentOnOpportunity extends LightningElement {

    @api recordId;
    @track originalPrice;
    @track Amount;

    @track ShowForm = true;
    @track ShowFormButton = true;
    @track ShowPaymentCard = false;

    @track Loanvalue

    @track HandleButtonDisable = false;
    @track DisableSave = true;
    @track DisableNext = true;

    @track ProductValue;
    @track QuantityValue = 1;
    //@track originalPrice;
    //@track  Amount;
    @track loanAmount;

    @track ShowOriginalAmount = true;
    @track maximumvalue;
    @track selectedDate;

    HandleNextDueDate(event) {
        debugger;
        this.selectedDate = event.detail.value;
    }
    minDate = new Date().toISOString().slice(0, 10);

    //Getting Amount From Opportunity
    @wire(ShowOppAmount, { recordId: '$recordId' })
    ShowOppAmount({ data, error }) {
        console.log('Amount recieved---', data);
        //console.log('ProductName---',this.ProductValue);
        debugger;
        console.log('data=', data);
        if (data) {
            this.originalPrice = data.Amount;
            this.maximumvalue = this.originalPrice;
            this.Amount = data;
            console.log('Amount=', this.Amount);
            console.log('Amount=', this.originalPrice);
        }
        else {
            console.log('error=' + error);
        }
    }

    //Here Getting The Payment Types
    Picklistvalue = [];
    @wire(getObjectInfo, { objectApiName: OPP_OBJECT })
    objectInfo

    // @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:PAYMENT_FIELD})
    //  wiredPicklistValues({data,error}){
    //      debugger;
    //     if(data){
    //        console.log('data=',data);
    //        console.log('dataValues=',data.values);
    //        let arr=[];
    //        for(let i=0;i<data.values.length;i++){
    //           arr.push({label:data.values[i].label,value:data.values[i].value});
    //        }
    //        this.Picklistvalue=arr;
    //        console.log('Picklistvalue=',this.Picklistvalue);
    //     }
    //     else {
    //         console.log('error=',error)
    //     }
    //  }

    get Paymentoptions() {
        return [{ label: 'RazorPay', value: 'RazorPay' },
        { label: 'CC Avenue', value: 'CC Avenue' },
        ];
    }


    HandlePaymentType(event) {
        debugger;
        //this.PaymentType=event.detail.value;

        if (this.PaymentType == 'RazorPay') {
            this.HandleRazorPay();
        }
        else if (this.PaymentType == 'CC Avenue') {
            this.HandleCCAvenuePay();
        }
        // else if( this.LoanButtonName=='LoanNotNeed' && (this.PaymentType=='Cash' || this.PaymentType=='POS' || this.PaymentType=='Cheque' )){
        //     this.HandlePaymentMethods();
        // }
        // else if( this.Loanvalue=='Partial Loan' && (this.PaymentType=='Cash' || this.PaymentType=='POS' || this.PaymentType=='Cheque' )){
        //     this.HandlePaymentMethods();
        // }
    }

    //  HandlePaymentMethods(){
    //     debugger;
    //     this.LoadSpinner=true;
    //     this.ShowPaymentCard=false;
    //     CreateInvoice({recordId:this.recordId,FinalAmount:this.Amount,PartialTenureValue:this.PartialLoanTenureValue,partialNBFCValue:this.PartialLoanNBFCPartnervalue,PartialUpfrontValue: this.PartialLoanUpfrontpaymentvalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.priceIncludingGst,paymentType:this.PaymentType})
    //     .then(result=>{
    //         if(result=='Success'){
    //             this.LoadSpinner=false;
    //             this.showToast('success','Invoice created successfully!','success');
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         }
    //         else{
    //             this.showToast('Failed',result,'error');
    //         }

    //     })
    //     .catch(error=>{
    //         this.showToast('Failed',error,'error');


    //     })
    // }

    //Getting Payment Option After Loan Not Needed
    @track ShowPaymentOption = false;
    get PaymentOptionType() {
        return [
            { label: '100% Payment', value: '100% Payment' },
            { label: 'Partial Payment', value: 'Partial Payment' },
        ];
    }

    @track Paymentvalue;

    @track ShowPartialPaymentOption = false;

    HandlePaymentRadioButton(event) {
        debugger;
        this.Paymentvalue = event.target.value;
        if (this.Paymentvalue == '100% Payment') {
            this.ShowPaymentCard = true;
            this.ShowOriginalAmount = true;
            this.ShowPartialPaymentOption = false;
            this.showpaymentButton = false;
        }
        else if (this.Paymentvalue == 'Partial Payment') {
            this.ShowPartialPaymentOption = true;
            this.ShowPaymentCard = true;
            this.ShowOriginalAmount = false;


        }
    }

    @track PartialUpfrontAmount;
    @track PartialAmount;

    HandlePartialLoanInputUpfrontAmount(event) {
        debugger;
        this.PartialUpfrontAmount = event.target.value;

        this.PartialAmount = this.originalPrice - this.PartialUpfrontAmount;
    }


    // @wire(ShowAmount,{ProductName:'$ProductValue'})
    //  wiredResponse({data,error}){
    //     console.log('Amount recieved---',data);
    //     console.log('ProductName---',this.ProductValue);
    //     debugger;
    //     console.log('data='+data);
    //     if(data){
    //         this.originalPrice = data;
    //        this.Amount=data;
    //        console.log('Amount='+this.Amount);
    //     }
    //     else{
    //         console.log('error='+error);
    //     }
    //  }

    @track fetchedArr = [];
    @track nbfcCSList = [];

    //Here Getting NBFC Partner List
    @wire(ShowNbfcPartners)
    wiredNbfcResponse({ data, error }) {
        debugger;
        if (data) {
            this.nbfcCSList = data;

            console.log('data=', data);

            for (var key in data) {
                this.fetchedArr.push({ label: key, value: key });
            }
            console.log('fetchedArr=', this.fetchedArr);
        }
        else if (error) {
            console.log('error=' + error);
        }
    }

    get options() {
        return this.fetchedArr;
    }


    HandleProductQuantityInput(event) {
        debugger;
        let name = event.currentTarget.dataset.id;
        let value = event.target.value;

        if (name == 'Quantity') {
            this.QuantityValue = value;
        } else {
            this.ProductValue = value;
        }


        this.Amount = this.originalPrice * this.QuantityValue;
        this.HandleButtonDisable = this.ProductValue == undefined || this.QuantityValue == undefined;

        //    if((this.ProductValue!=undefined && this.QuantityValue!=undefined)){
        //       this.HandleButtonDisable=false;
        //    }
    }

    @track FullLoanTenureValue;
    @track FullLoanNBFCPartnervalue;


    @track tenureList = [];
    @track tenurevalue = [];

    HandleFullLoanInputNBFCPartner(event) {
        debugger;
        let name = event.target.name;
        let value = event.target.value;

        if (this.FullLoanNBFCPartnervalue != value) {
            this.FullLoanTenureValue = '';
            this.FullLoanNBFCPartnervalue = value;
        }
        // this.FullLoanNBFCPartnervalue=value;

        this.tenureList = this.nbfcCSList[value];
        console.log('tenureList=' + this.tenureList);

        let arr = [];
        this.tenureList.forEach(element => {
            debugger;

            arr.push({ label: element, value: element });
        });
        this.tenurevalue = arr;
        console.log('tenurevalue=', this.tenurevalue);

    }

    get TenureOptions() {
        return this.tenurevalue;
    }

    @track priceIncludingGst;

    HandleFullLoanInput(event) {
        debugger;
        this.FullLoanTenureValue = parseInt(event.detail.value);
        console.log('event.c/bankDetails=', event.detail.value);
        console.log('FullLoanNBFCPartnervalue', this.FullLoanNBFCPartnervalue)

        ShowPriceIncludingGST({ NbfcValue: this.FullLoanNBFCPartnervalue, tenure: this.FullLoanTenureValue, originalAmount: this.originalPrice })
            .then(result => {
                this.priceIncludingGst = result;
                console.log('priceIncludingGst=', this.priceIncludingGst);
            })
            .catch(error => {
                console.log('error', error);
            })

        if ((this.FullLoanTenureValue != undefined && this.FullLoanNBFCPartnervalue != undefined)) {
            this.DisableSave = false;
        }


    }

    @track ProcessingFees;
    @track GstValue;

    HandlePartialLoanInputNBFCPartner(event) {
        debugger;
        let name = event.target.name;
        let value = event.target.value;

        if (this.PartialLoanNBFCPartnervalue != value) {
            this.PartialLoanTenureValue = '';
            this.PartialLoanNBFCPartnervalue = value;
        }
        this.PartialLoanNBFCPartnervalue = value;

        this.tenureList = this.nbfcCSList[value];
        console.log('tenureList=' + this.tenureList);

        let arr = [];
        this.tenureList.forEach(element => {
            debugger;

            arr.push({ label: element, value: element });
        });
        this.tenurevalue = arr;
        console.log('tenurevalue=', this.tenurevalue);

    }

    get PartialTenureoptions() {
        return this.tenurevalue;
    }

    HandlePartialLoanInput(event) {
        debugger;
        let value = parseInt(event.detail.value);

        if (this.PartialLoanTenureValue != value) {

            this.PartialLoanUpfrontpaymentvalue = 0;
            this.loanAmount = '';
            this.PartialLoanTenureValue = parseInt(value);
        }
        ShowPriceIncludingGST({ NbfcValue: this.PartialLoanNBFCPartnervalue, tenure: this.PartialLoanTenureValue, originalAmount: this.originalPrice })
            .then(result => {

                this.priceIncludingGst = result;
                console.log('priceIncludingGst=', this.priceIncludingGst);
            })
            .catch(error => {
                console.log('error', error);
            })

    }

    HandlePartialLoanInputUpfront(event) {

        let value = event.detail.value;
        this.PartialLoanUpfrontpaymentvalue = value;

        this.loanAmount = this.priceIncludingGst - this.PartialLoanUpfrontpaymentvalue;

        if ((this.PartialLoanTenureValue != undefined && this.PartialLoanNBFCPartnervalue != undefined && this.PartialLoanUpfrontpaymentvalue != undefined)) {
            this.DisableNext = false;
        }
    }


    @track PartialLoanTenureValue;
    @track PartialLoanNBFCPartnervalue;
    @track PartialLoanUpfrontpaymentvalue;

    @track LoanButtonName;
    HandleLoanNotNeed(event) {
        this.LoanButtonName = event.target.name;
        this.ShowPaymentOption = true;
        this.ShowOriginalAmount = false;

        this.ShowForm = false;

        this.ShowFormButton = false;
        this.PaymentSectionButton = true;
        if (this.Paymentvalue == '100% Payment') {
            this.ShowPaymentCard = true;
        }
        else if (this.Paymentvalue == 'Partial Payment') {
            this.ShowPartialPaymentOption = true;
            this.ShowPaymentCard = true;
        }



    }



    HandleLoanNeed() {
        debugger;
        this.ShowLoanOption = true;
        this.ShowOriginalAmount = false;
        this.ShowForm = false;
        this.ShowFormButton = false;
        //this.ShowFullLoanOption=false;
        // this.ShowFullLoanOption=true;
        //this.FullLoanButton=true;


        if (this.Loanvalue == '100% Loan') {
            this.ShowFullLoanOption = true;
            this.FullLoanButton = true;
            this.ShowOriginalAmount = false;

            // this.ShowPartialLoanOption=false;
            // this.PartialLoanButton=false;
            //this.ShowFormButton=false;

        }
        else if (this.Loanvalue == 'Partial Loan') {
            this.ShowPartialLoanOption = true;
            this.PartialLoanButton = true;
            this.ShowOriginalAmount = false;
            //  this.FullLoanButton=false;
            // this.ShowFormButton=false;
        }


    }

    get Loanoptions() {
        return [
            { label: '100% Loan', value: '100% Loan' },
            { label: 'Partial Loan', value: 'Partial Loan' },
        ];
    }

    HandleRadioButton(event) {
        this.Loanvalue = event.detail.value;

        if (this.Loanvalue == '100% Loan') {
            this.ShowFullLoanOption = true;
            this.FullLoanButton = true;
            this.ShowPartialLoanOption = false;
            this.PartialLoanButton = false;
            this.ShowOriginalAmount = false;
        }
        else if (this.Loanvalue == 'Partial Loan') {
            this.ShowPartialLoanOption = true;
            this.PartialLoanButton = true;
            this.ShowFullLoanOption = false;
            this.FullLoanButton = false;
            this.ShowOriginalAmount = false;
        }
    }

    HandleNext() {
        this.ShowPaymentCard = true;
        this.ShowPartialLoanOption = false;
        this.PartialLoanButton = false;
        this.ShowLoanOption = false;
        this.PaymentSectionButton = true;
        this.ShowOriginalAmount = false;
    }

    HandlePrevious(event) {
        if (event.target.name == 'PaymentSection') {
            this.ShowForm = true;
            this.ShowPaymentCard = false;
            this.ShowFormButton = true;
            this.PaymentSectionButton = false;
            this.ShowPaymentOption = false;
            this.ShowPartialPaymentOption = false;
            this.ShowOriginalAmount = true;

            if (this.Loanvalue == 'Partial Loan') {
                this.ShowForm = false;
                this.ShowFormButton = false;
                this.ShowFullLoanOption = false;
                this.ShowPartialLoanOption = true;
                this.PartialLoanButton = true;
                //this.PartialLoanButton=true;
            }
        }
        else if (event.target.name == 'FullSection') {

            this.ShowForm = true;
            this.ShowFormButton = true;
            this.ShowLoanOption = false;
            this.ShowFullLoanOption = false;
            this.FullLoanButton = false;
            this.ShowOriginalAmount = true;

        }
        else if (event.target.name == 'PartialSection') {

            this.ShowForm = true;
            this.ShowLoanOption = false;
            this.ShowFormButton = true;
            // this.ShowFullLoanOption=false;
            this.ShowPartialLoanOption = false;
            this.PartialLoanButton = false;
            this.ShowOriginalAmount = true;

        }
    }

    LoadSpinner = false;
    HandleRazorPay() {
        debugger;
        this.LoadSpinner = true;
        this.ShowPaymentCard = false;
        if (this.LoanButtonName == 'LoanNotNeed') {

            if (this.Paymentvalue == '100% Payment') {

                UpdateOPPforFullPayment({ recordId: this.recordId, paymentType: 'razorpay', Amount: this.originalPrice, PaymentOptiontype: 'Full Payment' })
                    .then(result => {

                        if (result == 'Success') {
                            this.showToast('Success', 'Invoice created successfully!', 'success');
                            this.dispatchEvent(new CloseActionScreenEvent());
                            updateRecord({ fields: { Id: this.recordId } });
                        }
                        else {

                            this.showToast('Failed', result, 'error');
                        }

                    })
                    .catch(error => {

                        this.showToast('Failed', error, 'error');
                        console.log('error=' + error);
                    })

            }
            else if (this.Paymentvalue == 'Partial Payment') {
                if (this.selectedDate != null && this.selectedDate != '' && this.selectedDate != undefined) {
                    UpdateOPPforPartialPayment({ recordId: this.recordId, paymentType: 'razorpay', Amount: this.PartialUpfrontAmount, PendingAmount: this.PartialAmount, PaymentOptiontype: 'Partial Payment', nextPaymentDueDate: this.selectedDate })
                        .then(result => {

                            if (result == 'Success') {
                                console.log('result', result);
                                this.showToast('Success', 'Invoice created successfully!', 'success');
                                this.dispatchEvent(new CloseActionScreenEvent());
                                updateRecord({ fields: { Id: this.recordId } });
                            }
                            else {
                                console.log('result', result);
                                this.showToast('Failed', result, 'error');
                            }

                        })
                        .catch(error => {

                            this.showToast('Failed', error, 'error');
                            console.log('error=', error);
                            this.LoadSpinner = false;
                        })

                }
                else {
                    this.showToast('Alert', 'Please Fill Next due Date', 'alert');
                    this.LoadSpinner = false;
                    this.ShowPaymentCard = true;

                }

            }
        }

        if (this.Loanvalue == 'Partial Loan') {

            if (this.PartialLoanTenureValue != undefined && this.PartialLoanNBFCPartnervalue != undefined && this.PartialLoanUpfrontpaymentvalue != undefined) {
                debugger;
                OppUpdateOnPartialLoan({ recordId: this.recordId, PartialTenureValue: this.PartialLoanTenureValue, partialNBFCValue: this.PartialLoanNBFCPartnervalue, PartialUpfrontValue: this.PartialLoanUpfrontpaymentvalue, Quantity: this.QuantityValue, ProductName: this.ProductValue, Amount: this.priceIncludingGst, paymentType: 'razorpay', LoanType: this.Loanvalue })
                    .then(result => {

                        if (result == 'Success') {
                            this.showToast('Success', 'Invoice created successfully!', 'success');
                            this.dispatchEvent(new CloseActionScreenEvent());
                            updateRecord({ fields: { Id: this.recordId } });
                        } else {
                            this.showToast('Failed', result, 'error');
                        }
                    })
                    .catch(error => {
                        console.log('error=', error);
                        this.showToast('Failed', error, 'error');
                        this.LoadSpinner = false;
                    })
            }
        }
    }

    HandleCCAvenuePay() {
        this.LoadSpinner = true;
        this.ShowPaymentCard = false;
        if (this.LoanButtonName == 'LoanNotNeed') {
            debugger;
            if (this.Paymentvalue == '100% Payment') {

                UpdateOPPforFullPayment({ recordId: this.recordId, paymentType: 'CC Avenue' })
                    .then(result => {

                        if (result == 'Success') {
                            this.showToast('Success', 'Invoice created successfully!', 'success');
                            this.dispatchEvent(new CloseActionScreenEvent());
                            updateRecord({ fields: { Id: this.recordId } });
                        }
                        else {

                            this.showToast('Failed', result, 'error');
                        }

                    })
                    .catch(error => {

                        this.showToast('Failed', error, 'error');
                        console.log('error=' + error);
                    })

            }
            else if (this.Paymentvalue == 'Partial Payment') {

                if (this.selectedDate != null && this.selectedDate != '' && this.selectedDate != undefined) {
                    UpdateOPPforPartialPayment({ recordId: this.recordId, paymentType: 'CC Avenue', Amount: this.PartialUpfrontAmount, PendingAmount: this.PartialAmount, PaymentOptiontype: 'Partial Payment', nextPaymentDueDate: this.selectedDate })
                    //UpdateOPPforPartialPayment({recordId:this.recordId,paymentType:'CC Avenue'})
                    .then(result => {

                        if (result == 'Success') {
                            this.showToast('Success', 'Invoice created successfully!', 'success');
                            this.dispatchEvent(new CloseActionScreenEvent());
                            updateRecord({ fields: { Id: this.recordId } });
                        }
                        else {

                            this.showToast('Failed', result, 'error');
                        }

                    })
                    .catch(error => {

                        this.showToast('Failed', error, 'error');
                        console.log('error=' + error);
                    })
                    
                }
                else{
                    this.showToast('Alert', 'Please Fill Next due Date', 'alert');
                    this.LoadSpinner = false;
                    this.ShowPaymentCard = true;
                }
            }
        }

        if (this.Loanvalue == 'Partial Loan') {

            if (this.PartialLoanTenureValue != undefined && this.PartialLoanNBFCPartnervalue != undefined && this.PartialLoanUpfrontpaymentvalue != undefined) {
                debugger;
                OppUpdateOnPartialLoan({ recordId: this.recordId, PartialTenureValue: this.PartialLoanTenureValue, partialNBFCValue: this.PartialLoanNBFCPartnervalue, PartialUpfrontValue: this.PartialLoanUpfrontpaymentvalue, Quantity: this.QuantityValue, ProductName: this.ProductValue, Amount: this.priceIncludingGst, paymentType: 'CC Avenue', LoanType: this.Loanvalue })
                    .then(result => {

                        if (result == 'Success') {
                            this.showToast('Success', 'Invoice created successfully!', 'success');
                            this.dispatchEvent(new CloseActionScreenEvent());
                            updateRecord({ fields: { Id: this.recordId } });
                        } else {
                            this.showToast('Failed', result, 'error');
                        }
                    })
                    .catch(error => {
                        console.log('error=', error);
                        this.showToast('Failed', error, 'error');
                    })
            }
        }

    }
    @track showpaymentButton = false;
    Showsavebutton(event) {
        debugger;
        this.PaymentType = event.detail.value;
        this.showpaymentButton = true;
    }


    HandleSave() {
        debugger;
        OppUpdateOnFullLoan({ recordId: this.recordId, FullTenureValue: this.FullLoanTenureValue, FullNBFCValue: this.FullLoanNBFCPartnervalue, Quantity: this.QuantityValue, ProductName: this.ProductValue, Amount: this.priceIncludingGst, LoanType: this.Loanvalue })
            .then(result => {

                if (result == 'success') {

                    this.showToast('success', 'Invoice created successfully!', 'success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                    updateRecord({ fields: { Id: this.recordId } });


                }
                else {
                    this.showToast('Failed', result, 'error');
                }

            })
            .catch(error => {
                this.showToast('Failed', error, 'error');
                console.log('FullLoanerror=', error);

            })

    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}