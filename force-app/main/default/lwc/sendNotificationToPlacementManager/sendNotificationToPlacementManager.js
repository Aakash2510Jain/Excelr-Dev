import { LightningElement, wire, api, track } from 'lwc';
import getPlacementApplications from '@salesforce/apex/SendNotificationToPlacementManager.getPlacementApplications';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendEmailToQueueMembers from '@salesforce/apex/SendNotificationToPlacementManager.sendEmailToQueueMembers';

export default class SendNotificationToPlacementManager extends LightningElement {

    @api recordId;
    ProgramName = '';
    placementApplications;
    class = '';

    actualList = [];

    @track pageLength = 6;
    @track startingRecord = 1;
    @track pageSize = 10; 
    @track page = 1;
    @track totalPage = 0;
    @track totalRecountCount = 0;

    @wire(getPlacementApplications, { programId: '$recordId' })
    wiredPlacementApplications({ data, error }) {
        debugger;
        if (data) {
            this.ProgramName = data[0].Program__r.Name;

            let tempArray = [];
            for(let i=0; i< data.length; i++){

                let rec = {...data[i]};
                rec.aptiColor = rec.Aptitude_Result__c == 'Pass' ? "greenClass" : "redClass";
                rec.gdColor = rec.GD_Result__c == 'Pass' ? "greenClass" : "redClass";
                rec.piColor = rec.Personal_Interview_Result__c == 'Pass' ? "greenClass" : "redClass";

                tempArray[i] = rec;
            }
            this.actualList = tempArray;
            this.placementApplications = this.processRecords(tempArray);
        } 
        else if (error) {
            console.error(error);
        }
    }

    processRecords(data){
        debugger;
        var item = data;
        this.totalRecountCount = data.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        
        var assignedTo = item.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
        return assignedTo;
    }

    handleSendClick() {
        debugger;
        sendEmailToQueueMembers({ queueName: 'Placement_Drive_Team', programId : this.recordId})
            .then(result => {
                this.showToast('Success', 'Emails sent to Placement Drive Team members.', 'success');
                this.closeModal();
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while sending emails.', 'error');
                console.error(error);
            });
   }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    previousHandler() {
        debugger;
        if (this.page > 1) {
            this.page = this.page - 1; 
            this.placementApplications = this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        debugger;
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.placementApplications = this.displayRecordPerPage(this.page);            
        }
    }

    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        var assignedTo = this.actualList.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        return assignedTo;
    } 

}