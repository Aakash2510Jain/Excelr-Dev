import { LightningElement, api, track, wire } from 'lwc';
import getAllData from '@salesforce/apex/CustomerDetailApexController.getAllData';
import GetAllFieldsLabelXValue from '@salesforce/apex/CustomerDetailApexController.GetAllFieldsLabelXValue';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CustomerDetailLWCController extends NavigationMixin(LightningElement) {

    @api recordId;

    @track LeadData = [];
    @track OpportunityData = [];

    @wire(getAllData, { recordId: '$recordId' })
    wiredService({ data, error }) {

        if (data) {
            debugger;
            console.log('data=', data);
            this.LeadData = data.leadsList;
            this.OpportunityData = data.opportunityList;
            console.log('LeadData=', this.leadsList);
        }
        else if (error) {
            console.log('error');
        }

    }

    ShowForm = false;
    HandleEdit() {
        this.ShowForm = true;
        // debugger;
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         objectApiName: 'Customers__c',
        //         actionName: 'edit'
        //     },
        // });
        //    if(this.Tempboolean=true){
        //       this.updateRecordView();
        //    }
    }

    HandleCancel() {
        this.ShowForm = false;
    }

    HandleSave() {
        debugger;
        var isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if (isVal) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();


            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contacts successfully created',
                    variant: 'success',
                }),

                this.ShowForm = false,
                //eval("$A.get('e.force:refreshView').fire();")
            );
            window.location.reload();
            //this.updateRecordView();
            //refreshApex(this.customerData);
            //eval("$A.get('e.force:refreshView').fire();")
            //this.handleSearch();

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please enter all the required fields',
                    variant: 'error',
                }),
            );
        }

    }

    updateRecordView() {
        debugger;
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }
    //onsuccess={handleSuccess}
    //  handleSuccess(event) {

    //     const evt = new ShowToastEvent({
    //         title: 'Account Updated',
    //         message: 'Record ID: ' + event.detail.id,
    //         variant: 'success',

    //     });

    //     this.dispatchEvent(evt);
    //     this.updateRecordView();

    // }

    //    updateRecordView() {
    //     debugger;
    //     setTimeout(() => {
    //         refreshApex(this.customerData);
    //     }, 10); 
    //  }


    @track customerData = [];
    @track customernewData = [];
    @wire(GetAllFieldsLabelXValue, { recordId: '$recordId' })
    GetAllFieldsLabelXValue(result) {
        debugger;
        if (result.data) {
            for (var key in result.data) {
                if (key != 'CID__c') {
                    this.customerData.push({ key: key, value: (result.data)[key] });
                }
                else if (key == 'CID__c') {
                    this.customernewData.push({ key: key, value: (result.data)[key] });
                }

                console.log('key Sort', this.customerData);
                console.log('New key Sort', this.customernewData);

            }
            this.customerData.unshift(this.customernewData[0]);
            console.log('Unshifted key Sort', this.customerData);
        }
        else if (result.error) {
            console.log('error');
        }

    }

    handleSearch(){
        GetAllFieldsLabelXValue({recordId: this.recordId})
        .then((result) => {
            debugger;
            if (result) {
                this.customerData = [];
                this.customernewData = [];
                for (var key in result) {
                    if (key != 'CID__c') {
                        this.customerData.push({ key: key, value: (result)[key] });
                    }
                    else if (key == 'CID__c') {
                        this.customernewData.push({ key: key, value: (result)[key] });
                    }
    
                    console.log('key Sort', this.customerData);
                    console.log('New key Sort', this.customernewData);
    
                }
                this.customerData.unshift(this.customernewData[0]);
                console.log('Unshifted key Sort', this.customerData);
            }
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
        });

    }
    ShowToastMessage() {

        const evt = new ShowToastEvent({
            title: 'Contact Created',
            message: 'Record ID: ',
            variant: 'success',

        });

        this.dispatchEvent(evt);
    }

}