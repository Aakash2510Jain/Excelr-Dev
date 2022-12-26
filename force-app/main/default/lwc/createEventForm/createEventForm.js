import { LightningElement,track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createEvent from "@salesforce/apex/CalenderController.createEvent";
import getPicklistFieldsValues from "@salesforce/apex/CalenderController.getPicklistFieldsValues";

export default class CreateEventForm extends LightningElement {
    
    @track eventForm = {
        Name:'',
        Slot_Duration__c:'',
        Before_Gap__c:'',
        After_Gap__c:'',
        Start_Time__c:'',
        End_Time__c:'',
    };

    @track isLoading = true;
    @track fieldValues = {};

    fieldList = ['Slot_Duration__c','Before_Gap__c','After_Gap__c'];

    @wire(getPicklistFieldsValues,{objName:'Calender_Type__c','fieldList':'$fieldList'})
    wiredResponse(result){
        console.log('Result---',result);
        
        if(result.data){
            this.fieldList.forEach(field=>{
                let list = result.data[field];
                let fList = [];

                list.forEach(item=>{
                    fList.push({label:item+' Min',value:item});
                })

                this.fieldValues[field] = fList;
            })
            console.log('FieldValues---',this.fieldValues);
           // this.fieldValues = result.data;
            this.isLoading = false;
        }
    }

    inputHandler(event){
        let fieldName = event.target.name;
        let value = event.target.value;

        this.eventForm[fieldName] = value;
    }

    createNewEvent(){
        if(!this.eventForm.Name || this.eventForm.Name.length==0){
            this.showNotification('Failed','Please enter name','error');
            return;
        }
        if(!this.eventForm.Slot_Duration__c || this.eventForm.Slot_Duration__c.length==0){
            this.showNotification('Failed','Please enter slot duration','error');
            return;
        }
        if(!this.eventForm.Start_Time__c || this.eventForm.Start_Time__c.length==0){
            this.showNotification('Failed','Please enter start time','error');
            return;
        }
        if(!this.eventForm.End_Time__c || this.eventForm.End_Time__c.length==0){
            this.showNotification('Failed','Please enter end time','error');
            return;
        }

        this.isLoading = true;

        console.log('Event---',this.eventForm);
        debugger;

        let startTime = this.eventForm.Start_Time__c;
        let endTime = this.eventForm.End_Time__c;

        delete this.eventForm.Start_Time__c;
        delete this.eventForm.End_Time__c;

        createEvent({ct:this.eventForm,startTime,endTime}).then(result=>{
            if(result=='Success'){
                this.isLoading = false;
                this.showNotification('Success','New Event Created Succesfully!','success');
                this.refreshHandler();
                this.backHandler();
            }
        }).catch(error=>{
            console.log('Error to create event----',error);
            this.showNotification('Failed',error,'error');
        })
    }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    backHandler(){
        this.eventForm = {
            Name:'',
            Slot_Duration__c:'',
            Before_Gap__c:'',
            After_Gap__c:'',
            Start_Time__c:'',
            End_Time__c:'',
        };
        let ev = new CustomEvent('close', {});
        this.dispatchEvent(ev);
    }

    refreshHandler(){
        let ev = new CustomEvent('refresh', {});
        this.dispatchEvent(ev);
    }
}