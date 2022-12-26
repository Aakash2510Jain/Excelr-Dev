import { LightningElement,wire,api,track } from 'lwc';
import fetchApp from '@salesforce/apex/AppWithLead.fetchApp';

export default class AppWithLeadLwc extends LightningElement 
{

    @api recordId ;

     columns = [
        { label: 'App Name', fieldName: 'Name' },
        { label: 'Date & Time', fieldName: 'Applied_Date_Time__c',type: 'date', typeAttributes: {day: 'numeric',  month: 'short',   year: 'numeric',hour: '2-digit',  minute: '2-digit',  second: '2-digit',  hour12: true }},
        { label: 'Course', fieldName: 'Course__c' },
        { label: 'LID', fieldName: 'LID__c'}
    ];

    @track activeSections ;
    handleSectionToggle(event)
    {
         this.activeSections = event.detail.openSections;
    }
    
    @track data =[];

    @wire(fetchApp,{recordId: '$recordId'})
    wiredAccounts({data,error})
    {
        debugger;
       if(data)
       {
        this.data = data;
        console.log('data',data);
       }
       else if(error)
       {
        console.log(error);
       }
    }
}