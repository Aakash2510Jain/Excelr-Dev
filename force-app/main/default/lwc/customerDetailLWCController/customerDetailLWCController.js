import { LightningElement,api ,track,wire} from 'lwc';
import ShowAllLeads from '@salesforce/apex/CustomerDetailApexController.ShowAllLeads';


export default class CustomerDetailLWCController extends LightningElement {

   @api recordId;
   
   @track LeadData=[];
  
   @wire(ShowAllLeads,{recordId:'$recordId'})
   wiredService({data,error}){

    if(data){
        console.log('data=',data);
        this.LeadData=data;
    }
    else if(error){
        console.log('error');
    }

   }
   
}