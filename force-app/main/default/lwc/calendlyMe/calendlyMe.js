import { LightningElement,track,wire,api} from 'lwc';
import Id from '@salesforce/user/Id';
import getCalendarsUserInfo from "@salesforce/apex/CalenderController.getCalendarsUserInfo";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CalendlyMe extends LightningElement {
    userId = Id;
    @track isFirstTabActive = true;
    @track firstTabClass ='slds-tabs_default__item slds-is-active';
    @track secTabClass = 'slds-tabs_default__item'; 
    @track wiredResult;
    @track calUserInfo;
    @track showCreateEvent = false;
    @track initials = '';


    @wire(getCalendarsUserInfo,{userId:Id})
    wiredResponse(result){
        this.wiredResult = result;
        if(result.data){
            console.log('Result----',result);
            this.calUserInfo = result.data;
            this.initials = this.calUserInfo.user.Name.charAt(0);
        }
    }

    tabSwitchHandler(event){
        let activeTab = event.currentTarget.dataset.name;
        debugger;
        this.isFirstTabActive =  activeTab=='first';
        if(this.isFirstTabActive){
            this.firstTabClass = 'slds-tabs_default__item slds-is-active';
            this.secTabClass = 'slds-tabs_default__item';
        }else{
            this.firstTabClass = 'slds-tabs_default__item';
            this.secTabClass = 'slds-tabs_default__item slds-is-active';
        }
    }

    showCreateEventHandler(){
        this.showCreateEvent = true;
    }

    refreshPage(){
        refreshApex(this.wiredResult);
    }

    hideCreateEventHandler(){
        this.showCreateEvent = false;
    }


    searchHanlder(event){
        let value = event.target.value;
    }

    copy(event) {
        let text = event.currentTarget.dataset.id;
        debugger;
        if (window.clipboardData && window.clipboardData.setData) {
            // Internet Explorer-specific code path to prevent textarea being shown while dialog is visible.
            return window.clipboardData.setData("Text", text);
    
        }
        else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
            var textarea = document.createElement("textarea");
            textarea.textContent = text;
            textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in Microsoft Edge.
            document.body.appendChild(textarea);
            textarea.select();
            try {
                return document.execCommand("copy");  // Security exception may be thrown by some browsers.
            }
            catch (ex) {
                console.warn("Copy to clipboard failed.", ex);
                return prompt("Copy to clipboard: Ctrl+C, Enter", text);
            }
            finally {
                document.body.removeChild(textarea);
                this.showNotification('Success','Link copied successfully!','success');
            }
        } 
      }

      showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}