import { LightningElement, wire, track, api } from 'lwc';
// import modal from "@salesforce/resourceUrl/modal";
// import { loadStyle } from "lightning/platformResourceLoader";
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getclearedApplicationData from '@salesforce/apex/programComponentController.getAllApplications';
import createOpportunities from '@salesforce/apex/programComponentController.createOpportunities';
import createLeads from '@salesforce/apex/programComponentController.createLeads';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PLACEMENT_OBJECT from '@salesforce/schema/Placement_Application__c';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Placement_Status from "@salesforce/schema/Placement_Application__c.Placement_Paid_Service_Status__c";

export default class SendPaymentLinkFToApplications extends NavigationMixin(LightningElement) {

    @api recordId;
    //@track pageLength = 6;
    @track startingRecord = 1;
    @track pageSize = 10; 

    @track Page = 1;
    @track totalPage = 0;
    @track startingRecord = 1;
    @track totalRecountCount = 0;

    @track baPage = 1;
    @track totalBAPage = 0;
    @track baStartingRecord = 1;
    @track totalBARecountCount = 0;

    @track piFailedPage = 1;
    @track totalPiFailedPage = 0;
    @track piFailedStartingRecord = 1;
    @track totalFailedRecountCount = 0;

    @track partialPage = 1;
    @track totalPartialPage = 0;
    @track partialStartingRecord = 1;
    @track totalPartialRecountCount = 0;

    @track naPage = 1;
    @track totalNAPage = 0;
    @track naStartingRecord = 1;
    @track totalNARecountCount = 0;



    @track allSelectedRows = [];

    @track baItems = []; 
    @track naItems = []; 
    @track partialItems = []; 
    @track piFailedItems = []; 

    naSelectedCheckboxIds = [];
    partialSelectedCheckboxIds = [];
    piFailedSelectedCheckboxIds = [];


    @track clearedApplicationData=[];
    @track piFailedApplicationData=[];
    @track partialClearedApplicationData=[];
    nonAttendedApplications=[];

    piFailedAppWrapper = [];
    partialClearedAppWrapper = [];
    naAppWrapper = [];

    showSpinner = true;

    showBAMsg = false;
    showPIFailedMsg = false;
    showPartialMsg = false;
    showNAMsg = false;

    msg = 'No candidates found!!'


    get handlePIFailedButton(){
        debugger;
        return (this.piFailedSelectedCheckboxIds == '' || this.piFailedSelectedCheckboxIds == undefined) ;
    }

    get handlePartialButton(){
        debugger;
        return (this.partialSelectedCheckboxIds == '' || this.partialSelectedCheckboxIds == undefined) ;
    }

    get handleNAButton(){
        debugger;
        return (this.naSelectedCheckboxIds == '' || this.naSelectedCheckboxIds == undefined) ;
    }

    @wire(getObjectInfo, { objectApiName: PLACEMENT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Placement_Status})
    StatusPicklistValues;  

    connectedCallback() {
        debugger;
        setTimeout(() => {
            this.processResult();
        },3000);
    }

    processResult(){
        debugger;
        getclearedApplicationData({programId : this.recordId}).then(result => {

            if(result.allClearedApplications.length > 0){
                let tempClearedArray = [];
                for(let i=0; i< result.allClearedApplications.length; i++){
                    let rec = {...result.allClearedApplications[i]};
                    rec.aptiColor = rec.aptiResult == 'Pass' ? "greenClass" : "redClass";
                    rec.gdColor = rec.gdResult == 'Pass' ? "greenClass" : "redClass";
                    rec.piColor = rec.piResult == 'Pass' ? "greenClass" : "redClass";
                    tempClearedArray[i] = rec;
                }

                this.baItems = tempClearedArray;
                this.clearedApplicationData = this.processBARecords(tempClearedArray);

                //this.clearedApplicationData = tempClearedArray;
                this.showBAMsg = false;
            }
            else{
                this.showBAMsg = true;
            }

            if(result.piFailedApplications.length > 0){
                let tempPIFailedArray = [];
                for(let i=0; i< result.piFailedApplications.length; i++){
                    let rec = {...result.piFailedApplications[i]};
                    rec.disableCombobox = true;
                    rec.discount = null;
                    //rec.remarks = '';
                    rec.aptiColor = rec.aptiResult == 'Pass' ? "greenClass" : "redClass";
                    rec.gdColor = rec.gdResult == 'Pass' ? "greenClass" : "redClass";
                    rec.piColor = rec.piResult == 'Pass' ? "greenClass" : "redClass";
                    tempPIFailedArray[i] = rec;
                }
                //this.piFailedApplicationData = tempPIFailedArray;
                this.piFailedItems = tempPIFailedArray;
                this.piFailedApplicationData = this.processPiFailedRecords(tempPIFailedArray);
                this.showPIFailedMsg = false;
            }
            else{
                this.showPIFailedMsg = true;
            }

            if(result.partiallyClearedApplications.length > 0){
                let tempPartialArray = [];
                for(let i=0; i< result.partiallyClearedApplications.length; i++){
                    let rec = {...result.partiallyClearedApplications[i]};
                    rec.disableCombobox = true;
                    rec.discount = null;
                    //rec.remarks = '';
                    rec.aptiColor = rec.aptiResult == 'Pass' ? "greenClass" : "redClass";
                    rec.gdColor = rec.gdResult == 'Pass' ? "greenClass" : "redClass";
                    rec.piColor = rec.piResult == 'Pass' ? "greenClass" : "redClass";
                    tempPartialArray[i] = rec;
                }
                //this.partialClearedApplicationData = tempPartialArray;
                this.partialItems = tempPartialArray;
                this.partialClearedApplicationData = this.processPartialRecords(tempPartialArray);
                this.showPartialMsg = false;
            }
            else{
                this.showPartialMsg = true;
            }2

            if(result.nonAttendedApplications.length > 0){
                let tempNAArray = [];
                for(let i=0; i< result.nonAttendedApplications.length; i++){
                    let rec = {...result.nonAttendedApplications[i]};
                    rec.disableCombobox = true;
                    rec.discount = null;
                    //rec.remarks = '';
                    rec.aptiColor = rec.aptiResult == 'Pass' ? "greenClass" : "redClass";
                    rec.gdColor = rec.gdResult == 'Pass' ? "greenClass" : "redClass";
                    rec.piColor = rec.piResult == 'Pass' ? "greenClass" : "redClass";
                    tempNAArray[i] = rec;
                }
                this.naItems = tempNAArray;
                this.nonAttendedApplications = this.processNARecords(tempNAArray);
                this.showNAMsg = false;
            }
            else{
                this.showNAMsg = true;
            }

            this.showSpinner = false;
        }).catch(error => {
            console.log("Error -- ",error);
        })

    }

    handleOpportunityClick(event) {
        debugger;
        const oppId = event.target.dataset.oppid;
        if (oppId) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": oppId,
                    "objectApiName": "Opportunity",
                    "actionName": "view"
                }
            }).then(genURL => {
                window.open(genURL);
            });
        }
    }

    handleLeadClick(event){
        debugger;
        const leadId = event.target.dataset.ldId;
        const completeURL = `${window.location.origin}/${leadId}`;
        window.open(completeURL, '_blank');
    }


    /*********   Checkbox Selection Functions Start   ********/

    handleAllPIFailedSelected(event){
        debugger;
        const isChecked = event.target.checked;
        let selectedRows = this.template.querySelectorAll('lightning-input[data-key="secondTabCheckbox"]');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }

            const appId = selectedRows[i].dataset.appId;
            if(event.target.checked){
                const status = selectedRows[i].dataset.status === undefined ? '' : selectedRows[i].dataset.status;
                const discount = selectedRows[i].dataset.discount;
                const remarks = selectedRows[i].dataset.remarks;
                
                this.piFailedItems = this.piFailedItems.map(data => {
                    return { ...data, check: isChecked, disableCombobox: !isChecked, status : status, remarks : remarks, discount : discount};
                });
                this.piFailedApplicationData = this.displayPiFailedRecordPerPage(this.piFailedPage, this.piFailedItems);

                if (!this.piFailedSelectedCheckboxIds.includes(appId)) {
                    this.piFailedSelectedCheckboxIds.push(appId);
                }
            }
            else{
                this.piFailedItems = this.piFailedItems.map(data => {
                    return { ...data,  check: !isChecked, disableCombobox: !isChecked};
                });
                this.piFailedApplicationData = this.displayPiFailedRecordPerPage(this.piFailedPage, this.piFailedItems);

                const index = this.piFailedSelectedCheckboxIds.indexOf(appId);
                if (index > -1) {
                    this.piFailedSelectedCheckboxIds.splice(index, 1);
                }
            }
        }       

    }

    handlePIFailedCheckboxSelect(event){
        debugger;

        const isChecked = event.target.checked;
        const dataId = event.target.dataset.id;
        const appId = event.target.dataset.appId;
        const status = event.target.dataset.status === undefined ? '' : event.target.dataset.status;
        const remarks = event.target.dataset.remarks;

        if (isChecked) {
            if (!this.piFailedSelectedCheckboxIds.includes(appId)) {
                this.piFailedSelectedCheckboxIds.push(appId);
            }
        } 
        else {
            const index = this.piFailedSelectedCheckboxIds.indexOf(appId);
            if (index > -1) {
                this.piFailedSelectedCheckboxIds.splice(index, 1);
            }
        }

        this.piFailedItems = this.piFailedItems.map(data => {
            if (data.applicationId === dataId) {
                return { ...data, check: isChecked, disableCombobox: !isChecked, status : status, remarks : remarks};
            }
            return data;
        });
        this.piFailedApplicationData = this.displayPiFailedRecordPerPage(this.piFailedPage, this.piFailedItems);
    }


    handleAllPartialSelected(event){
        debugger;
        const isChecked = event.target.checked;
        let selectedRows = this.template.querySelectorAll('lightning-input[data-key="thirdTabCheckbox"]');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }

            const appId = selectedRows[i].dataset.appId;
            if(event.target.checked){
                const status = selectedRows[i].dataset.status === undefined ? '' : selectedRows[i].dataset.status;
                const remarks = selectedRows[i].dataset.remarks;
                
                this.partialItems = this.partialItems.map(data => {
                    return { ...data, check: isChecked, disableCombobox: !isChecked, status : status, remarks : remarks};
                });
                this.partialClearedApplicationData = this.displayPartialRecordPerPage(this.partialPage, this.partialItems);

                if (!this.partialSelectedCheckboxIds.includes(appId)) {
                    this.partialSelectedCheckboxIds.push(appId);
                }
            }
            else{

                this.partialItems = this.partialItems.map(data => {
                    return { ...data, check: !isChecked, disableCombobox: !isChecked};
                });
                this.partialClearedApplicationData = this.displayPartialRecordPerPage(this.partialPage, this.partialItems);

                const index = this.partialSelectedCheckboxIds.indexOf(appId);
                if (index > -1) {
                    this.partialSelectedCheckboxIds.splice(index, 1);
                }
            }
        } 
    }

    handlePartialCheckboxSelect(event){
        debugger;

        const isChecked = event.target.checked;
        const dataId = event.target.dataset.id;
        const appId = event.target.dataset.appId;
        const status = event.target.dataset.status === undefined ? '' : event.target.dataset.status;
        const remarks = event.target.dataset.remarks;

        if (isChecked) {
            if (!this.partialSelectedCheckboxIds.includes(appId)) {
                this.partialSelectedCheckboxIds.push(appId);
            }
        } 
        else {
            const index = this.partialSelectedCheckboxIds.indexOf(appId);
            if (index > -1) {
                this.partialSelectedCheckboxIds.splice(index, 1);
            }
        }

        this.partialItems = this.partialItems.map(data => {
            if (data.applicationId === dataId) {
                return { ...data, check: isChecked, disableCombobox: !isChecked, status : status, remarks : remarks, discount : null};
            }
            return data;
        });
        this.partialClearedApplicationData = this.displayPartialRecordPerPage(this.partialPage, this.partialItems);
        
    }

    handleAllNASelected(event){
        debugger;

        const isChecked = event.target.checked;
        let selectedRows = this.template.querySelectorAll('lightning-input[data-key="fourthTabCheckbox"]');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }

            const appId = selectedRows[i].dataset.appId;

            if(event.target.checked){
                const status = selectedRows[i].dataset.status === undefined ? '' : selectedRows[i].dataset.status;
                const remarks = selectedRows[i].dataset.remarks;

                this.naItems = this.naItems.map(data => {
                    return { ...data, check: isChecked, disableCombobox: !isChecked, status : status, remarks : remarks};
                });
                this.nonAttendedApplications = this.displayNARecordPerPage(this.naPage, this.naItems);

                if (!this.naSelectedCheckboxIds.includes(appId)) {
                    this.naSelectedCheckboxIds.push(appId);
                }
            }
            else{
                this.naItems = this.naItems.map(data => {
                    return { ...data, check: !isChecked, disableCombobox: !isChecked};
                });
                this.nonAttendedApplications = this.displayNARecordPerPage(this.naPage, this.naItems);

                const index = this.naSelectedCheckboxIds.indexOf(appId);
                if (index > -1) {
                    this.naSelectedCheckboxIds.splice(index, 1);
                }
            }
        }
    }

    handleNACheckboxSelect(event){
        debugger;

        const isChecked = event.target.checked;
        const dataId = event.target.dataset.id;
        const appId = event.target.dataset.appId;
        const status = event.target.dataset.status === undefined ? '' : event.target.dataset.status;
        const remarks = event.target.dataset.remarks;

        if (isChecked) {
            if (!this.naSelectedCheckboxIds.includes(appId)) {
                this.naSelectedCheckboxIds.push(appId);
            }
        } 
        else {
            const index = this.naSelectedCheckboxIds.indexOf(appId);
            if (index > -1) {
                this.naSelectedCheckboxIds.splice(index, 1);
            }
        }

        this.naItems = this.naItems.map(data => {
            if (data.applicationId === dataId) {
                return { ...data, check: isChecked, disableCombobox: !isChecked, status : status, remarks : remarks};
            }
            return data;
        });
        this.nonAttendedApplications = this.displayNARecordPerPage(this.naPage, this.naItems);

    }


    /*********   Checkbox Selection Functions End   ********/



    handleChange(event){
        debugger;
        var name = event.target.name;
        const selectedValue = event.detail.value;
        const currentRecId = event.target.dataset.id;

        if ((name == 'piFailedStatus' || name == 'piFailedDiscount' || name == 'piFailedRemark') && selectedValue != '') {
            let tempFieldWrapperArray = this.piFailedItems.map(item => ({ ...item }));

            tempFieldWrapperArray.forEach(fieldWrapper => {
                if (fieldWrapper.applicationId == currentRecId) {
                    if (name == 'piFailedStatus'){
                        fieldWrapper.status = selectedValue;
                    }
                    else if (name == 'piFailedDiscount'){
                        fieldWrapper.discount = selectedValue;
                    }
                    else if (name == 'piFailedRemark'){
                        fieldWrapper.remarks = selectedValue;
                    }
                }
            });
            //this.piFailedAppWrapper = tempFieldWrapperArray;
            this.piFailedItems = tempFieldWrapperArray;
            this.piFailedApplicationData = this.displayPiFailedRecordPerPage(this.piFailedPage, this.piFailedItems);
        }
        if ((name == 'partialStatus' || name =='partialRemark' ) && selectedValue != '') {
            let tempFieldWrapperArray = this.partialItems.map(item => ({ ...item }));

            tempFieldWrapperArray.forEach(fieldWrapper => {
                if (fieldWrapper.applicationId == currentRecId) {
                    if (name == 'partialStatus'){
                        fieldWrapper.status = selectedValue;
                    }
                    else if(name == 'partialRemark'){
                        fieldWrapper.remarks = selectedValue;
                    }
                }
            });
            //this.partialClearedAppWrapper = tempFieldWrapperArray;
            this.partialItems = tempFieldWrapperArray;
            this.partialClearedApplicationData = this.displayPartialRecordPerPage(this.partialPage, this.partialItems);
        }
        if ((name == 'naStatus' || name =='naRemark' ) && selectedValue != '') {

            let tempFieldWrapperArray = this.naItems.map(item => ({ ...item }));

            tempFieldWrapperArray.forEach(fieldWrapper => {
                if (fieldWrapper.applicationId == currentRecId) {
                    if (name == 'naStatus'){
                        fieldWrapper.status = selectedValue;
                    }
                    else if(name == 'naRemark'){
                        fieldWrapper.remarks = selectedValue;
                    }
                }
            });
            this.naItems = tempFieldWrapperArray;
            this.nonAttendedApplications = this.displayNARecordPerPage(this.naPage, this.naItems);
        }
    }


    /*********   Pagination : Next and Previous Handlers Start   ********/

    baPreviousHandler() {
        debugger;
        if (this.baPage > 1) {
            this.baPage = this.baPage - 1; 
            this.clearedApplicationData = this.displayBARecordPerPage(this.baPage, this.baItems);
        }
    }

    baNextHandler() {
        debugger;
        if((this.baPage<this.totalBAPage) && this.page !== this.totalBAPage){
            this.baPage = this.baPage + 1; //increase page by 1
            this.clearedApplicationData = this.displayBARecordPerPage(this.baPage, this.baItems);            
        }
    }

    piFailedPreviousHandler() {
        debugger;
        if (this.piFailedPage > 1) {
            this.piFailedPage = this.piFailedPage - 1; 
            this.piFailedApplicationData = this.displayPiFailedRecordPerPage(this.piFailedPage, this.piFailedItems);
        }
    }

    piFailedNextHandler() {
        debugger;
        if((this.piFailedPage<this.totalPiFailedPage) && this.piFailedPage !== this.totalPiFailedPage){
            this.piFailedPage = this.piFailedPage + 1; //increase page by 1
            this.piFailedApplicationData = this.displayPiFailedRecordPerPage(this.piFailedPage, this.piFailedItems);            
        }
    }

    partialPreviousHandler() {
        debugger;
        if (this.partialPage > 1) {
            this.partialPage = this.partialPage - 1; 
            this.partialClearedApplicationData = this.displayPartialRecordPerPage(this.partialPage, this.partialItems);
        }
    }

    partialNextHandler() {
        debugger;
        if((this.partialPage < this.totalPartialPage) && this.partialPage !== this.totalPartialPage){
            this.partialPage = this.partialPage + 1; //increase page by 1
            this.partialClearedApplicationData = this.displayPartialRecordPerPage(this.partialPage, this.partialItems);            
        }
    }

    naPreviousHandler() {
        debugger;
        if (this.naPage > 1) {
            this.naPage = this.naPage - 1; 
            this.nonAttendedApplications = this.displayNARecordPerPage(this.naPage, this.naItems);
        }
    }

    naNextHandler() {
        debugger;
        if((this.naPage < this.totalNAPage) && this.naPage !== this.totalNAPage){
            this.naPage = this.naPage + 1; //increase page by 1
            this.nonAttendedApplications = this.displayNARecordPerPage(this.naPage, this.naItems);            
        }
    }

    /*********   Pagination : Next and Previous Handlers End   ********/

    

    displayBARecordPerPage(page, items){
        debugger;
        this.baStartingRecord = ((page -1) * this.pageSize) ;
        this.baEndingRecord = (this.pageSize * page);

        this.baEndingRecord = (this.baEndingRecord > this.totalBARecountCount) 
                            ? this.totalBARecountCount : this.baEndingRecord; 

        var assignedTo = items.slice(this.baStartingRecord, this.baEndingRecord);
        this.baStartingRecord = this.baStartingRecord + 1;
        return assignedTo;
    }   

    processBARecords(data){
        debugger;
        var item = data;
        this.totalBARecountCount = data.length; 
        this.totalBAPage = Math.ceil(this.totalBARecountCount / this.pageSize); 
        
        var assignedTo = item.slice(0,this.pageSize); 
        this.baEndingRecord = this.pageSize;
        return assignedTo;
    }

    displayPiFailedRecordPerPage(page, items){
        debugger;
        this.piFailedStartingRecord = ((page -1) * this.pageSize) ;
        this.piFailedEndingRecord = (this.pageSize * page);

        this.piFailedEndingRecord = (this.piFailedEndingRecord > this.totalPiFailedRecountCount) 
                            ? this.totalPiFailedRecountCount : this.piFailedEndingRecord; 

        var assignedTo = items.slice(this.piFailedStartingRecord, this.piFailedEndingRecord);
        this.piFailedStartingRecord = this.piFailedStartingRecord + 1;
        return assignedTo;
    }   

    processPiFailedRecords(data){
        debugger;
        var item = data;
        this.totalPiFailedRecountCount = data.length; 
        this.totalPiFailedPage = Math.ceil(this.totalPiFailedRecountCount / this.pageSize); 
        
        var assignedTo = item.slice(0,this.pageSize); 
        this.piFailedEndingRecord = this.pageSize;
        return assignedTo;
    }

    displayPartialRecordPerPage(page, items){
        debugger;
        this.partialStartingRecord = ((page -1) * this.pageSize) ;
        this.partialEndingRecord = (this.pageSize * page);

        this.partialEndingRecord = (this.partialEndingRecord > this.totalPartialRecountCount) 
                            ? this.totalPartialRecountCount : this.partialEndingRecord; 

        var assignedTo = items.slice(this.partialStartingRecord, this.partialEndingRecord);
        this.partialStartingRecord = this.partialStartingRecord + 1;
        return assignedTo;
    }   

    processPartialRecords(data){
        debugger;
        var item = data;
        this.totalPartialRecountCount = data.length; 
        this.totalPartialPage = Math.ceil(this.totalPartialRecountCount / this.pageSize); 
        
        var assignedTo = item.slice(0,this.pageSize); 
        this.partialEndingRecord = this.pageSize;
        return assignedTo;
    }

    displayNARecordPerPage(page, items){
        debugger;
        console.log("items",items);
        this.naStartingRecord = ((page -1) * this.pageSize) ;
        this.naEndingRecord = (this.pageSize * page);

        this.naEndingRecord = (this.naEndingRecord > this.totalNARecountCount) 
                            ? this.totalNARecountCount : this.naEndingRecord; 

        var assignedTo = items.slice(this.naStartingRecord, this.naEndingRecord);
        this.naStartingRecord = this.naStartingRecord + 1;
        return assignedTo;
    }   

    processNARecords(data){
        debugger;
        
        var item = data;
        this.totalNARecountCount = data.length; 
        this.totalNAPage = Math.ceil(this.totalNARecountCount / this.pageSize); 
        
        var assignedTo = item.slice(0,this.pageSize); 
        this.naEndingRecord = this.pageSize;
        return assignedTo;
    }




    /*********   Save Functions Start  ********/

    doCreatePIFailedOpportunity(){
        debugger;

        console.log('this.piFailedSelectedCheckboxIds  -- ', this.piFailedSelectedCheckboxIds);

        let oppWrapper = [];
        for(let i = 0; i < this.piFailedItems.length; i++) {
            if (this.piFailedSelectedCheckboxIds.includes(this.piFailedItems[i].applicationId)) {
                const appId = this.piFailedItems[i].applicationId;
                const status = this.piFailedItems[i].status;
                const remarks = this.piFailedItems[i].remarks;
                const discount = this.piFailedItems[i].discount;
                oppWrapper.push({status: status,  discount : discount, remarks : remarks, appId : appId});
            }
        }
        this.piFailedAppWrapper = oppWrapper;
        console.log('this.piFailedAppWrapper  -- ', this.piFailedAppWrapper);

        createOpportunities({ rWrapperList : this.piFailedAppWrapper, programId : this.recordId}).then(result => {
            console.log(result);
            if(result === 'success'){
                this.showToast('Success', 'Opportunity has been created successfully!!!', 'SUCCESS');
                this.closeModal();
            }
            else{
                this.showToast('Error', result, 'error');
            }
        }).catch(error => {
            console.log("Error -- ",error);
        })
    }

    doCreatePartialLead(){
        debugger;
        console.log('this.partialSelectedCheckboxIds  -- ', this.partialSelectedCheckboxIds);

        let ldWrapper = [];
        for(let i = 0; i < this.partialItems.length; i++) {
            if (this.partialSelectedCheckboxIds.includes(this.partialItems[i].applicationId)) {
                const appId = this.partialItems[i].applicationId;
                const status = this.partialItems[i].status;
                const remarks = this.partialItems[i].remarks;
                ldWrapper.push({status: status, remarks : remarks, appId : appId});
            }
        }
        this.partialClearedAppWrapper = ldWrapper;
        console.log('this.partialClearedAppWrapper  -- ', this.partialClearedAppWrapper);

        createLeads({ rWrapperList : this.partialClearedAppWrapper, programId : this.recordId}).then(result => {
            console.log(result);
            if(result === 'success'){
                this.showToast('Success', 'Lead has been created successfully!!!', 'SUCCESS');
                this.closeModal();
            }
            else{
                this.showToast('Error', result, 'error');
            }
        }).catch(error => {
            console.log("Error -- ",error);
        })
    }

    doCreateLead(){
        debugger;
        console.log('this.naSelectedCheckboxIds  -- ', this.naSelectedCheckboxIds);

        let ldWrapper = [];
        for(let i = 0; i < this.naItems.length; i++) {
            if (this.naSelectedCheckboxIds.includes(this.naItems[i].applicationId)) {
                const appId = this.naItems[i].applicationId;
                const status = this.naItems[i].status;
                const remarks = this.naItems[i].remarks;
                ldWrapper.push({status: status, remarks : remarks, appId : appId});
            }
        }

        this.naAppWrapper = ldWrapper;
        console.log('this.naAppWrapper  -- ', this.naAppWrapper);

        createLeads({rWrapperList : this.naAppWrapper, programId : this.recordId}).then(result => {
            console.log(result);
            if(result === 'success'){
                this.showToast('Success', 'Lead has been created successfully!!!', 'SUCCESS');
                this.closeModal();
            }
        }).catch(error => {
            console.log("Error -- ",error);
        })
    }

    /*********   Save Functions End  ********/
    

    handleCancel(){
        debugger;
        this.closeModal();
    }

    showToast(toastTitle, toastmessage, toastvariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastmessage,
            variant: toastvariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


}