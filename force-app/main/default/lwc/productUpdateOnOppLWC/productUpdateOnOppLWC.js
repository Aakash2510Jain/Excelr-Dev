import { LightningElement,track,wire} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import TYPE_FIELD from '@salesforce/schema/Product2.Type__c';
import MODE_FIELD from '@salesforce/schema/Product2.Mode__c';
import fetchCities from '@salesforce/apex/ProductUpdateOnOppApexController.fetchCities';
import ProdList from '@salesforce/apex/ProductUpdateOnOppApexController.ProdList';
import InsertOppLineItem from '@salesforce/apex/ProductUpdateOnOppApexController.InsertOppLineItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// const columns = [
//     { label: 'Product Name', fieldName: 'Name' },
//     { label: 'Product Mode', fieldName: 'Mode__c' },
//     { label: 'Product Type', fieldName: 'Type__c' },
   
// ];

export default class ProductUpdateOnOppLWC extends LightningElement {

   // columns=columns;

    //Tempcolumns=columns;
    //Firstcolumns=columns;

    @track currentStep=1;

    @track Typevalue
    @track  FirstScreen=true;
    @track SecondScreen=false;

    @track TypePicklistvalue=[];

    //All Type From Product
    @wire(getObjectInfo, {objectApiName:PRODUCT_OBJECT})
    objectInfo

    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:TYPE_FIELD})
    wiredPicklistValuesType({data,error}){
        debugger;
       if(data){
          console.log('data=',data);
          console.log('dataValues=',data.values);
          let arr=[];
          for(let i=0;i<data.values.length;i++){
             arr.push({label:data.values[i].label,value:data.values[i].value});
          }
          this.TypePicklistvalue=arr;
          console.log('Picklistvalue=',this.TypePicklistvalue);
       }
       else {
           console.log('error=',error)
       }
    }

    get Typeoptions(){
        return this.TypePicklistvalue;
     }

    handleChangeType(event){
        debugger;
        this.Typevalue=event.detail.value;
           
    }


    @track ModePicklistvalue=[];
    @track Modevalue;

    //All Mode From Product
    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:MODE_FIELD})
    wiredPicklistValuesMode({data,error}){
        debugger;
       if(data){
          console.log('data=',data);
          console.log('dataValues=',data.values);
          let arr=[];
          for(let i=0;i<data.values.length;i++){
             arr.push({label:data.values[i].label,value:data.values[i].value});
          }
          this.ModePicklistvalue=arr;
          console.log('ModePicklistvalue=',this.ModePicklistvalue);
       }
       else {
           console.log('error=',error)
       }
    }

    get Modeoptions(){
        return this.ModePicklistvalue;
     }

     @track ModalPriorValue;
    handleChangeMode(event){
        debugger;
        let value=event.detail.value;
        this.Modevalue=value;
  
        this.ModalPriorValue=value;

        // if(this.Typevalue!=null && (this.Modevalue!=this.ModalPriorValue) && this.Cityvalue){
        //     ProdList({mode:this.Modevalue,typevalue:this.Typevalue,city:this.Cityvalue})
        //     .then(result=>{

        //         if(result){
        //              this.data=result;
        //              this.Firstdata=result;
        //              console.log('data====',this.data);
        //              console.log('this.Firstdata====',this.Firstdata);
        //         }
        //         else{
        //             console.log('error===',error);
        //         }

        //     })
        //     .catch(error=>{
        //          console.log('error=',error);
        //     })

        // }
           
    }

    //All City From Custom Setting
    @track CityPicklistvalue=[];
     @track Cityvalue;

    @wire(fetchCities)
    wiredPicklistValuesCity({data,error}){
        debugger;
       if(data){
          console.log('data=',data);
          console.log('dataValues=',data.values);
          let arr=[];
          for(let i=0;i<data.length;i++){
             arr.push({label:data[i].Name,value:data[i].Name});
          }
          this.CityPicklistvalue=arr;
          console.log('CityPicklistvalue=',this.CityPicklistvalue);
       }
       else {
           console.log('error=',error)
       }
    }

    get Cityoptions(){
        return this.CityPicklistvalue;
     }

     @track data=[];
     @track Firstdata=[];
     handleChangeCity(event){
        debugger;
        this.Cityvalue=event.detail.value;
        // if(this.Typevalue!=null && this.Modevalue!=null && this.Cityvalue){
        //     ProdList({mode:this.Modevalue,typevalue:this.Typevalue,city:this.Cityvalue})
        //     .then(result=>{

        //         if(result){
        //              this.data=result;
        //              this.Firstdata=result;
        //              console.log('data====',this.data);
        //              console.log('this.Firstdata====',this.Firstdata);
        //         }
        //         else{
        //             console.log('error===',error);
        //         }

        //     })
        //     .catch(error=>{
        //          console.log('error=',error);
        //     })

        // }
           
    }

    HandleClick(){
        debugger;
        //this.currentStep=this.currentStep + 1;

        if(this.Typevalue!=null && this.Modevalue!=null && this.Cityvalue){
            ProdList({mode:this.Modevalue,typevalue:this.Typevalue,city:this.Cityvalue})
            .then(result=>{

                if(result){
                     this.data=result;
                     this.Firstdata=result;
                     console.log('data====',this.data);
                     console.log('this.Firstdata====',this.Firstdata);
                }
                else{
                    console.log('error===',error);
                }

            })
            .catch(error=>{
                 console.log('error=',error);
            })

        }

        this.FirstScreen=false;
        this.SecondScreen=true;

        this.currentStep = '2';

        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }

    @track ThirdScreen=false;
    HandleClickNext(){

        if(this.selectedRecords.length==0){
            window.alert('Please Select Any Product')
        }
        else if(this.selectedRecords.length > 0){
           
            this.FirstScreen=false;
            this.SecondScreen=false;
            this.ThirdScreen=true;
    
            this.currentStep = '3';
    
            this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            this.template
                .querySelector('div.stepThree')
                .classList.remove('slds-hide');
        }

       
    }

    HandlePrevious(){
        this.SecondScreen=false;
        this.FirstScreen=true;

        this.currentStep = '1';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');
    }

   
    @track FirstTable=true;
    @track ProductValue;
    @track TempArray=[];
    @track SecondTable=false;
    //@track Tempdata=[];

    //Search Bar second Screen
    HandleProduct(event){
        debugger;
        let value=event.target.value;
        //this.TempValue=value;
        let TempValue;
        if(value){
            //this.ProductValue=value;
           
            TempValue=value;
        }
        //const DELAY=300;
    //     typingTimer;
    //     searchTextHelper = '';
    //         this.searchTextHelper = event.target.value;
    //         window.clearTimeout(this.typingTimer);
    //         this.typingTimer = setTimeout(() => { 
    //            // this.showSpinner = true; 
    //     this.searchText = this.searchTextHelper;
    //     this.searchText = this.searchText.charAt(0).toUpperCase() + this.searchText.slice(1);
    //  }, DELAY);
         
         //console.log('searchText=',this.searchText);
        let arr=[];
        if(TempValue){
            TempValue = TempValue.charAt(0).toUpperCase() + TempValue.slice(1);
            console.log('TempValue=',TempValue);
            const results = this.data.filter(product => product.Name.includes(TempValue));
            // let interestRate = this.data.find(item=>item.Name==TempValue);
            // console.log('interestRate----',interestRate);
            console.log('results====',results);
            results.forEach(element => {
                arr.push(element);
            });
            
            //arr.push(results.product);
            console.log('arr====',arr);
        }
         this.FirstTable=false;
        // for(let i=0;arr.length;i++){
        //     this.TempArray.push(arr[i]);
        // }
        this.TempArray=arr;
        console.log('this.TempArray====',this.TempArray);

        if(this.TempArray.length==0){
              this.FirstTable=true;
        }else if(this.TempArray.length > 0){
                //this.SecondTable=true;
               this.FirstTable=false;
        }
    
  }

  //Code For Third Screen
  @track ThirdScreen=false;

  HandlePreviousThird(){

    this.SecondScreen=true;
    this.ThirdScreen=false;

    this.currentStep = '2';

    this.template.querySelector('div.stepThree').classList.add('slds-hide');
    this.template
        .querySelector('div.stepTwo')
        .classList.remove('slds-hide');
  }

//   FinalArrayFirst=[];
//   FinalArraySecond=[];

  AllSelectedProducts=[];

  getSelectedRowFirst(event){
    debugger;
    const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let arr=[];
        for (let i = 0; i < selectedRows.length; i++) {
            //alert('You selected: ' + selectedRows[i].opportunityName);
            console.log('selectedRowsFirst====',selectedRows);
             arr.push(selectedRows[i]);
             console.log('arrselectedRowsFirst====',arr);
        }
       
            arr.forEach(element => {
             if(this.AllSelectedProducts.find(item=>item.Id==element.Id)){
                console.log('Same Id');
             }else{
                this.AllSelectedProducts.push(element); 
             }
               
            });
       
        //console.log('Final Array First===',this.FinalArray);
        // if(arr.length>0){
        //      this.AllSelectedProducts=arr;
        // }
        
  }

  getSelectedNameRowSecond(event){
    debugger;
    const selectedRows = event.detail.selectedRows;
    // Display that fieldName of the selected rows
    let arr=[];
    for (let i = 0; i < selectedRows.length; i++) {
        //alert('You selected: ' + selectedRows[i].opportunityName);
        console.log('selectedRowsSecond====',selectedRows);
        arr.push(selectedRows[i]);
        console.log('arrselectedRowsSecond====',arr);
    }
   
        // arr.forEach(element => {
        //  if(!this.AllSelectedProducts.includes(element.Id)){
        //     this.AllSelectedProducts.push(element);
        //  }
            
        // });

        arr.forEach(element => {
            if(this.AllSelectedProducts.find(item=>item.Id==element.Id)){
               console.log('Same Id');
            }else{
               this.AllSelectedProducts.push(element); 
            }
              
           });
    

    console.log('AllSelectedProducts===',this.AllSelectedProducts);
    // if(arr.length>0){
    //     this.FinalArraySecond=arr;
    // }
//     const unique = Array.from(new Set(this.AllSelectedProducts));

//     unique.forEach(element => {
//         arr.push(element);
//     });
 }

 //@track Discount;
 handleInputChange(event){
 debugger;
    //let DiscountPrice;
    let value=event.target.value;
    this.textid = event.target.dataset.id;

    for(let i = 0; i < this.selectedRecords.length; i++) {
        if(this.selectedRecords[i].Id === this.textid) {
            if(event.target.name=='Discount'){
                this.selectedRecords[i]['Discount__c'] = value;
            }
           
        }
    }

    // let updatedDiscontPrice = [];

    // this.selectedRecords.forEach(prod => {
    //     if (this.textid == prod.Id) {
    //         updatedDiscontPrice.push({
    //             Id: prod.Id ? prod.Id : "",
    //             Name: prod.Name ? prod.Name : "",
    //             Mode__c: prod.Mode__c ? prod.Mode__c : "",
    //             Type__c: prod.Type__c ? prod.Type__c : "",
    //             this.Discount: value ? value : "",
    //             //UnitPrice: prod.PricebookEntries.UnitPrice ? prod.PricebookEntries.UnitPrice : "" 
    //         })
    //     }
    //   else{
    //     updatedDiscontPrice.push({
    //         Id: prod.Id ? prod.Id : "",
    //         Name: prod.Name ? prod.Name : "",
    //         Mode__c: prod.Mode__c ? prod.Mode__c : "",
    //         Type__c: prod.Type__c ? prod.Type__c : "",
    //          DiscountPrice: '' ? '' : "",
    //         //UnitPrice: prod.PricebookEntries.UnitPrice ? prod.PricebookEntries.UnitPrice : ""

    //         })
    //     }
    // })
    // this.selectedRecords = updatedDiscontPrice;
    // console.log('AllSelectedProducts After Discount===',this.selectedRecords);
}

        HandleClickSave(){
            InsertOppLineItem({Prodlist:this.selectedRecords})
            .then(result=>{

                if(result=='success'){
                        this.showNotification();
                        eval("$A.get('e.force:refreshView').fire();");
                }
            })
            .catch(error=>{

            })

        }

        showNotification() {
            const evt = new ShowToastEvent({
                title: 'SUCCESS',
                message: 'OppLine Item Created Successfully',
                variant: 'success',
            });
            this.dispatchEvent(evt);
        }

        @track checkedboxdata=[];
        @track selectedRecords=[];
        @track arr=[];
        @track checkedvalue;
        changeHandler(event) {
                debugger;
                
                 const recordId = event.target.dataset.id;
                if (event.target.checked) {
                    this.checkedvalue=event.target.checked;
                    if(this.selectedRecords.find(item=>item.Id==recordId)){
                        console.log('This Id Exists')
                    }
                    else{
                         // push the selected record to the array
                        this.selectedRecords.push(this.data.find(record => record.Id === recordId));
                    }
                  } else {
                    // remove the unselected record from the array
                    this.checkedvalue=event.target.checked;
                    this.selectedRecords = this.selectedRecords.filter(record => record.Id !== recordId);
                }
                console.log('selectedRecords===',this.selectedRecords);

                

            }
                 //arr=[];
            //     let GetRecord=this.data.find((item)=>{
            //          return  item.Id===recordId
            //     });
                
            //         this.arr.push(GetRecord); 
            //        // this.checkedboxdata = arr;
            //         console.log('arr=',this.arr);
            // }
              
            // let testlist = [{id:1, name:"one"},{id:2, name:"two"},{id:3, name:"three"}];
            // let searchID = 1;
            // let foundRecord = testlist.find((record) => {
            //     return record.id === searchID;
            // });
            // console.log(foundRecord);


            //debugger;
            // let datasetId = event.target.dataset.id ;
            // console.log('datasetId===',datasetId);

            // // for(let i=0;i < this.data.length;i++){
                //   var arr=[];
                // let GetRecord=this.data.find((item)=>{
                //      return  item.Id===datasetId
                // });
                
                //     arr.push(GetRecord); 
            //     //this.checkedboxdata.push(arr);
            //         //this.checkedboxdata.push(GetRecord);
            //     console.log(GetRecord);
            //     console.log('arr=',arr);

                // for (let i = 0; i < this.checkedboxdata.length; i++) {
                //     if (arrayOfLetters[i] !== 'b') {
                //         arrayWithoutH.push(arrayOfLetters[i]);
                //     }
                // }
            // }

            removeRow(event){
                debugger;
                //let recordId= event.target.dataset.id;
                this.selectedRecords.splice(this.selectedRecords.findIndex(row => row.Id === event.target.dataset.id), 1);
       
                // if(this.selectedRecords.find(item=>item.Id==recordId)){

                    
                //     const index = this.selectedRecords.indexOf(item.Id);

                //     const x = this.selectedRecords.splice(index, 1);
                //     console.log('selectedRecords=',x);
                    
                // }
                console.log('selectedRecords=',this.selectedRecords);
                
            }
            

        }