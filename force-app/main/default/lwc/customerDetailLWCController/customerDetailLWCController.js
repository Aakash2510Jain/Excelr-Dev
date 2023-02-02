import { LightningElement,api ,track,wire} from 'lwc';
import ShowAllLeads from '@salesforce/apex/CustomerDetailApexController.ShowAllLeads';
import GetAllFieldsLabelXValue from '@salesforce/apex/CustomerDetailApexController.GetAllFieldsLabelXValue';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';


export default class CustomerDetailLWCController extends NavigationMixin(LightningElement) {

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

   Tempboolean=false;
   HandleEdit(){
    this.Tempboolean=true;
    debugger;
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Customers__c',
            actionName: 'edit'
        },
    });
       if(this.Tempboolean=true){
          this.updateRecordView();
       }
   }

   updateRecordView() {
    debugger;
    setTimeout(() => {
         eval("$A.get('e.force:refreshView').fire();");
    }, 3000); 
 }
  

   @track customerData=[];
   @wire(GetAllFieldsLabelXValue,{recordId:'$recordId'})
   GetAllFieldsLabelXValue(result){
       debugger;
    if (result.data) {
        for (var key in result.data) {
            this.customerData.push({ key: key, value:(result.data)[key] });
            console.log('key', this.customerData);
           
        }            
    }
    else if(result.error){
        console.log('error');
    }

   }
}