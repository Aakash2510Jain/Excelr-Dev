import { LightningElement } from 'lwc';

export default class LookupdemoforUser extends LightningElement {


    lookupRecord(event){
        debugger;
        var selectedrecordDetails = event.detail.selectedRecord;
        alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
    }
}