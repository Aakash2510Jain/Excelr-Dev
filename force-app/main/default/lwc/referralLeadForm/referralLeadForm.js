import { LightningElement } from 'lwc';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import Lead_LastName from '@salesforce/schema/Lead.LastName';
import Lead_Company from '@salesforce/schema/Lead.Company';


export default class ReferralLeadForm extends LightningElement {
    leadObject = LEAD_OBJECT;
    myFields = [Lead_LastName, Lead_Company];

    handleLeadCreated(){
        // Run code when account is created.
    }
}