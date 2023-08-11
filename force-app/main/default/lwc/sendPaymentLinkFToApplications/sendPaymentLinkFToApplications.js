import { LightningElement, wire, track, api } from 'lwc';
// import modal from "@salesforce/resourceUrl/modal";
// import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getApplicationData from '@salesforce/apex/placementApplicationController.getAllApplications';
import submitAllStudentApplications from '@salesforce/apex/placementApplicationController.submitAllStudentApplications';

    const COLS = [ 
        { label: 'Student Id', fieldName: 'Contact__c', editable: false },
        { label: 'Name', fieldName: 'Contact__c', editable: false },
        { label: 'Email', fieldName: 'Contact__c', editable: false },
        { label: 'Aptitude Marks', fieldName: 'Aptitude_Marks__c', editable: false },
        { label: 'Aptitude Result', fieldName: 'Aptitude_Result__c', editable: false },
        { label: 'GD Result', fieldName: 'GD_Result__c', editable: false },
        { label: 'Personal Interview Result', fieldName: 'Personal_Interview_Result__c', editable: false },
        { label: 'Remarks', fieldName: 'Remarks__c', editable: false }
    ];

export default class SendPaymentLinkFToApplications extends LightningElement {

    columns = COLS;
    @api recordId;
    @track pageLength = 6;
    @track startingRecord = 1;
    @track pageSize = 10; 
    @track page = 1;
    @track totalPage = 0;
    @track totalRecountCount = 0;
    @track applicationData=[];
    @track allSelectedRows = [];
    @track items = []; 
    @track selectedContactIds = [];

    get getMainButton(){
        debugger;
        return (this.selectedContactIds == '' || this.selectedContactIds == undefined) ;
    }

    connectedCallback() {
        debugger;
        //loadStyle(this, modal);
        setTimeout(() => {
            getApplicationData({oppId : this.recordId}).then(result => {
                this.items = result;
                this.processRecords(result);
            }).catch(error => {
                console.log("Error -- ",error);
            })
        },300);
    }

    processRecords(data){
        debugger;
        var item = data;
        this.totalRecountCount = data.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        
        this.applicationData = item.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }

    handleRowSelection = event => {
        debugger;
        var selectedRows=event.detail.selectedRows;
        var applicationListToIterate = selectedRows;
        var contactIdList= [];

        for(var i in applicationListToIterate){
            contactIdList.push(applicationListToIterate[i].Contact__c);           
        }

        this.selectedContactIds = contactIdList;
        console.log(this.selectedContactIds);       
    }

    previousHandler() {
        debugger;
        var el = this.template.querySelector('lightning-datatable');
        var selectedRows=el.selectedRows;
        this.allSelectedRows = selectedRows;

        this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    //clicking on next button this method will be called
    nextHandler() {
        debugger;
        this.isPageChanged = true;
        var el = this.template.querySelector('lightning-datatable');
        var selectedRows=el.selectedRows;
        this.allSelectedRows = selectedRows;

        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    handleSubmit(){
        debugger;

        submitAllStudentApplications({contactIdList : this.selectedContactIds}).then(result => {
                console.log(result);
                if(result == 'Success'){
                    this.showToast('Success', 'Payment Link has been sent Succesfully!!!', 'SUCCESS');
                    this.closeModal();
                }
            }).catch(error => {
                console.log("Error -- ",error);
        })
    }

    handleCancel(){
        debugger;
        this.closeModal();
    }

    showToast(toastTitle, toastmessage, toastvariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastmessage,
            variant: toastvariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


}