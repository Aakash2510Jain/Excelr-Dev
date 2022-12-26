import { LightningElement, api, track, wire } from 'lwc';

export default class ParentFormLWC extends LightningElement {
    @api agentrecid;
    @api DepartmentListstring;
    @track isModalOpen = true;
    @track Formvalue;
    @track DepartmentList = [];
    mapData = [];
    //var conts = result.data;
    connectedCallback() {
        debugger;
        this.convertlisttomap();

    }
    convertlisttomap() {
        debugger;
        this.DepartmentList = this.DepartmentListstring.split(';');
        for (var key in this.DepartmentList) {
            this.mapData.push({ label: this.DepartmentList[key], value: this.DepartmentList[key] }); //Here we are creating the array to show on UI.
        }
    }

    handleChange(event) {
        this.Formvalue = event.detail.value; //walkInLeadPage
        

    }

    submitDetails(){
        debugger;
        if (this.Formvalue == 'Walk-In') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/walkInLeadPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.open(urlString, "_self");
            
        }
        if (this.Formvalue == 'Voice') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/voiceFormPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.open(urlString, "_self");
            
        }
        if (this.Formvalue == 'Generic') {
            var urlString = 'https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/genericLeadAdditionPage'+'?id='+ this.agentrecid + '&departments=' + this.DepartmentListstring;
            window.open(urlString, "_self");
            
        }

    }
}