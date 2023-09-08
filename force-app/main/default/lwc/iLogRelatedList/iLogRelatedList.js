import { LightningElement, api, wire } from 'lwc';
import passRecordIds from '@salesforce/apex/ILogRelatedListLwcController.passRecordIds';

export default class ILogRelatedList extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
        { label: 'EndPoint', fieldName: 'endPoint' },
        { label: 'HTTP_Method', fieldName: 'methodType' },
        { label: 'Integration_Type', fieldName: 'integrationType' },
        { label: 'Processing_Time_in_MilliSeconds', fieldName: 'processingTimeInMilliseconds' },
        { label: 'Reference_Id', fieldName: 'referenceId' },
        { label: 'Request_Body', fieldName: 'requestBody' },
        { label: 'Response_Body', fieldName: 'responseBody' },
        { label: 'Response_Status_Code', fieldName: 'responseStatusCode' },
        { label: 'CreatedDate', fieldName: 'createdDate' },
    ];

    @api recordId;
    data = [];
    error;

    @wire(passRecordIds, { recIds: '$recordId' })
    wiredRecords({ error, data }) {
        debugger;
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = [];
        }
    }
}