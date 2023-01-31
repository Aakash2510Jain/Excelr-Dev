import { LightningElement,api,track,wire } from 'lwc';
import getUser from '@salesforce/apex/ModifyMaxLeads.getUser';
import { refreshApex } from '@salesforce/apex';
import updaterecord from '@salesforce/apex/ModifyMaxLeads.updaterecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ModifyMaxLead extends LightningElement 
{
    @track data;
    @track errors;
  @api   columns = [
        { label: 'Username', fieldName: 'Username', editable: true },
        { label: 'Max Lead Per Day', fieldName: 'Max_Lead_Per_Day__c', editable: true },
        { label: 'Max Lead Per Month', fieldName: 'Max_Lead_Per_Month__c', editable: true },
        
    ];
    draftValues ;

     
    connectedCallback()
    {

        this.handleLoad();
      //  this.handleSave(event);
    }

    handleLoad() {
        getUser()
            .then(result => {
                this.data = result;
                console.log('Dataaa',this.data);
            })
            .catch(error => {
                this.error = error;
            });
    }

    
    handleSave(event){
        debugger;
        this.draftValues = event.detail.draftValues;
       
      //  alert('draf '+JSON.stringify(this.draftValues))
      //  onsave={handleSave}  handleSave(event){
    /*  //Modification Start
        for(var i =0; i<this.draftValues.length;i++)
        {
            if(draftValues[i].Max_Lead_Per_Day__c == 0 || draftValues[i].Max_Lead_Per_Month__c ==0 )
            {
                const evt = new ShowToastEvent({
                    message: 'User Max lead and Montly Lead Caanot be 0 ',
                    variant: 'error',
                }); 
                this.dispatchEvent(evt);
                break;
            } 
        }
      //  modification End*/
        this.errors = { rows: {}, table: {} }
        var checkbool = false;
      this.draftValues.forEach(element => {
        if(element.Max_Lead_Per_Day__c == 0 || element.Max_Lead_Per_Month__c == 0 )
        checkbool = true;
        error => this.errors.rows[error.Id] = { 
            title: " We Found Errors ", 
            messages: ['Value should be Greater than Zero','Value should be Greater than Zero'], 
            fieldNames:[Max_Lead_Per_Day__c, Max_Lead_Per_Month__c,] };
      });
      if(checkbool) {
      this.errors.table.title = "We found "+this.draftValues.length+" error(s). ...";
     this.errors.table.messages = ['Value should be Greater than Zero','Value should be Greater than Zero'];
      return ;
      }
      
        updaterecord({userList: this.draftValues})
         .then( result => {
            console.log( JSON.stringify( "Apex update result: " + result ) )
            debugger;
            if(result === true){
                this.handleLoad();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'successfully User  has been updated',
                        variant: 'success'
                    })

                );
                this.draftValues = []
                return refreshApex(this.data);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'something went wrong please try again',
                        variant: 'error'
                    })
                );
            }

         })
    }

}