import { LightningElement, api,wire,track} from 'lwc';
import fetchingAGM from '@salesforce/apex/GetAGMRecordsHelper.getAGMMembers';

export default class GetAGMRecordLWC extends LightningElement {
@api inputUserName;
@track data;
@track isLoaded = false;
@track message ='';

searchAGM(event) {
    debugger;
    this.inputUserName = this.template.querySelector('lightning-input').value;
    //this.inputUserName = event.target.value;
     fetchingAGM({ 'userName' : this.inputUserName })
      .then(result => {
        if(result.length > 0){
            this.isLoaded = true;
            this.data = result;
        }else{
            this.isLoaded = false;
            this.message = 'No Assignment Group Found';
        }
        
      })
      .catch(error => {
        // Handle the error from the Apex method
      });
  }
}