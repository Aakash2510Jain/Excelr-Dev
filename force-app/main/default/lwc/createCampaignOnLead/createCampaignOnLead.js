import { LightningElement,api,wire,track } from 'lwc';
import CreateCampRecord from '@salesforce/apex/CreateCampaign.CreateCampRecord'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class CreateCampaignOnLead extends LightningElement {

    @track inputName ;
    
    @track campaignName;
    @track startDate;
    @track startTime
    @track endDate;
    @track endTime;
    @track stakeHolderEmail;

    @api recordId ;

   // @track formattedTime ;
   // @track formattedDate ;
      
    changeHandler(event){
        
        debugger;
        this.inputName = event.target.name;

        if(this.inputName == 'campName'){
            this.campaignName =  event.target.value;
        }
        if(this.inputName == 'sdt'){
            this.startDate =  event.target.value;
        }
        else if(this.inputName == 'sdtTime'){
            this.startTime = event.target.value;
        }
        else if(this.inputName == 'edt'){
            this.endDate = event.target.value;
        }
        else if( this.inputName == 'edtTime'){
            this.endTime =  event.target.value;
        }
        else if( this.inputName == 'she'){
            this.stakeHolderEmail =  event.target.value;
        }
    }   
       
    
     
     onSave(){
        debugger;
        console.log('this.campaignName --->', this.campaignName );
         console.log('this.startDate --->', this.startDate );
         console.log('this.startTime--->',this.startTime);
        console.log('this.endDate--->',this.endDate);
        console.log('this.endTime--->', this.endTime);   // startDateTime:this.startdateTime
        console.log(' this.stakeHolderEmail--->', this.stakeHolderEmail);

         CreateCampRecord({ leadId: this.recordId, campainName : this.campaignName, sDateValue : this.startDate , sTimevalue :this.startTime, eDateValue:this.endDate, eTimeValue:this.endTime,  stackholderEmail:this.stakeHolderEmail })
            .then(result => {
                if(result == 'SUCCESS'){
                    this.showNotification('Success','New Campaign Created Succesfully!','success');
                    this.closeModal();
                    if(location)
                        location.href = '/'+ this.recordId;
                }     
                else if(result == 'exists'){
                    this.showNotification('Warning','Campaign record with this Start Date Time already exists!','warning');
                }   
            }).catch(error => {
               this.showNotification('Failed',error,'error');
            });
     }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeModal() {
     this.dispatchEvent(new CloseActionScreenEvent());
    }


}