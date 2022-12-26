import { LightningElement,api,track,wire} from 'lwc';
import getCalendarType from '@salesforce/apex/CalenderController.getCalendarType'

export default class UserCalendar extends LightningElement {
    
    @track userId;
    @track result;

    connectedCallback(){
        console.log('OPPPPP','LOPPPPP');
        const params = new URLSearchParams(window.location.search);
        this.userId = params.get('cId').replace('&','');
        console.log('UserId----',this.userId);

        if(this.userId){
            this.getCalendarType();
        }
    }


    getCalendarType(){
        getCalendarType({userId:this.userId}).then(result=>{
            this.result = result;
            console.log('Result----',result);
        }).catch(error=>{
            console.log('Error-----',error);
        })
    }


    eventClicked(event){
        let cId = event.currentTarget.dataset.id;
        location.href = location.origin+'/EventCalenderPage?cId='+cId;
    }
}