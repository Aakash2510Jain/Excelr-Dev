import { LightningElement,track,wire,api} from 'lwc';
import OpportunityRec from '@salesforce/apex/ProductUpdateOnOppApexController.GetOppDetail';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import TYPE_FIELD from '@salesforce/schema/Product2.Type__c';
import MODE_FIELD from '@salesforce/schema/Product2.Mode__c';
import fetchCities from '@salesforce/apex/ProductUpdateOnOppApexController.fetchCities';
import ProdList from '@salesforce/apex/ProductUpdateOnOppApexController.ProdList';
import InsertOppLineItem from '@salesforce/apex/ProductUpdateOnOppApexController.InsertOppLineItem';
import CourseList from '@salesforce/apex/ProductUpdateOnOppApexController.CourseList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FetchAddOns from '@salesforce/apex/ProductUpdateOnOppApexController.FetchAddOns';
import { NavigationMixin } from 'lightning/navigation';
// const columns = [
//     { label: 'Product Name', fieldName: 'Name' },
//     { label: 'Product Mode', fieldName: 'Mode__c' },
//     { label: 'Product Type', fieldName: 'Type__c' },
   
// ];

export default class ProductUpdateOnOppLWC extends NavigationMixin(LightningElement) {

   // columns=columns;

    //Tempcolumns=columns;
    //Firstcolumns=columns;
    @api navigateToList;
    @track currentStep=1;
    @api recordId;
    @track Typevalue
    @track  FirstScreen=true;
    @track SecondScreen=false;
    @track RevenueValue;
    @track ShowText=false;
    
    @wire(OpportunityRec,{recordId: '$recordId'})
    wiredOpportunity({data,error}){
        if(data){
           console.log('oppData--',data); 
           this.RevenueValue=data.Expected_Revenue__c;
           console.log('RevenueValue--',this.RevenueValue);
           if(this.RevenueValue < 0 || this.RevenueValue==null || this.RevenueValue==undefined){
               this.ShowText=true;
           } 
        }else{
            console.log('error--',error);
        }
    }
    
    //Here Getting All The Courses
    @track AllCourses=[];

    @wire(CourseList)
    wiredPicklistValuesCourses({data,error}){
        debugger;
       if(data){
          console.log('data=',data);
          console.log('dataValues=',data.values);
          let arr=[];
          for(let i=0;i<data.length;i++){
             arr.push({label:data[i].Name,value:data[i].Name});
          }
          this.AllCourses=arr;
          console.log('AllCourses=',this.AllCourses);
       }
       else {
           console.log('error=',error)
       }
    }

    get Courseoptions(){
        return this.AllCourses;
     }

     @track Coursevalue;

     handleChangeCourse(event){
        debugger;
        this.Coursevalue=event.target.value;
     }
    

    //All Type From Product

    @track TypePicklistvalue=[];

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

     @track ShowModeAndCourse=false;
     @track ShowMode=true;
    handleChangeType(event){
        debugger;
        this.Typevalue=event.detail.value;
        if(this.Typevalue=='Combo'){
                this.ShowModeAndCourse=true;
                this.ShowMode=false;
                this.ShowCity=true;
        }
        else {
            this.ShowMode=true;
            this.ShowModeAndCourse=false;
            if(this.Modevalue=='Classroom'){
                this.ShowCity=true;
            }else{
                this.ShowCity=false;
            }
           
        }
           
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
    
     @track ShowCity=false;
    handleChangeMode(event){
        debugger;
        let value=event.detail.value;
        this.Modevalue=value;
  
        this.ModalPriorValue=value;

        if(this.Modevalue=='Classroom'){
            this.ShowCity=true;
        }else{
            this.ShowCity=false;
        }

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

    @track addOnValues=[];
    @track data=[];
    @track showmessagge;
    HandleClick(){
        debugger;
        this.currentStep="2"

        if(this.Typevalue=='Single' && this.Modevalue!=null && this.Cityvalue!=null){
            ProdList({mode:this.Modevalue,typevalue:this.Typevalue,city:this.Cityvalue})
            .then(result=>{
                   let arr=[];
                if(result){
                     this.data=result;
                     this.Firstdata=result;
                     console.log('If Part data====',this.data);
                     console.log('If Part this.Firstdata====',this.Firstdata);
                     this.FirstTable=true;
                     if(this.data.length == 0){
                        this.showmessagge=true;
                    }else if(this.data.length > 0){
                        this.showmessagge=false;
                    }
                     
                    //  this.data.forEach(element => { 
                    //          console.log('element==',element);
                    //          if(element.Add_Ons__r > 0){
                    //             element.Add_Ons__r.forEach(element=>{
                    //                 console.log('Addons==',element.Name);
                    //                 arr.push({label:element.Name,value:element.Name});
                    //                 console.log('arr Addons==',arr);
                    //             })
                    //          }
                           
                    //        console.log('arr Addons==',arr);
                    //        this.addOnValues=arr;
                    //        console.log('addOnValues==',this.addOnValues);
                    //  });
                }
                else {
                    console.log('error===',error);
                }

            })
            .catch(error=>{
                 console.log('error=',error);
            })
        }else if(this.Typevalue!=null && this.Modevalue!=null && this.Typevalue!='Combo' ){
            
            ProdList({mode:this.Modevalue,typevalue:this.Typevalue})
            .then(result=>{
                   //let arr=[];
                if(result){
                     this.data=result;
                     this.Firstdata=result;
                     console.log('In Else data====',this.data);
                     console.log('In Else this.Firstdata====',this.Firstdata);
                     this.FirstTable=true;
                     if(this.data.length == 0){
                        this.showmessagge=true;
                    }else if(this.data.length > 0){
                        this.showmessagge=false;
                    }
                    //  this.data.forEach(element => { 
                    //          console.log('element==',element);
                    //          if(element.Add_Ons__r > 0){
                    //             element.Add_Ons__r.forEach(element=>{
                    //                 console.log('Addons==',element.Name);
                    //                 arr.push({label:element.Name,value:element.Name});
                    //                 console.log('arr Addons==',arr);
                    //             })
                    //          }
                           
                    //        console.log('arr Addons==',arr);
                    //        this.addOnValues=arr;
                    //        console.log('addOnValues==',this.addOnValues);
                    //  });
                }
                else {
                    console.log('error===',error);
                }

            })
            .catch(error=>{
                 console.log('error=',error);
            })
        }else if((this.Typevalue=='Combo' && this.itemList!=null)|| this.Cityvalue!=null){
            ProdList({typevalue:this.Typevalue,city:this.Cityvalue,ProdRec:this.itemList})
            .then(result=>{
                   let arr=[];
                if(result){
                     this.data=result;
                     this.Firstdata=result;
                     console.log('If Part data====',this.data);
                     console.log('If Part this.Firstdata====',this.Firstdata);
                     this.FirstTable=true;
                     if(this.data.length == 0){
                        this.showmessagge=true;
                    }else if(this.data.length > 0){
                        this.showmessagge=false;
                    }
                    //  this.data.forEach(element => { 
                    //          console.log('element==',element);
                    //             element.Add_Ons__r.forEach(element=>{
                    //                 console.log('Addons==',element.Name);
                    //                 arr.push({label:element.Name,value:element.Name});
                    //                 console.log('arr Addons==',arr);
                    //             })
                    //        console.log('arr Addons==',arr);
                    //        this.addOnValues=arr;
                    //        console.log('addOnValues==',this.addOnValues);
                    //  });
                }
                else {
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

        // this.template.querySelector('div.stepOne').class.add('slds-hide');
        // this.template
        //     .querySelector('div.stepTwo')
        //     .class.remove('slds-hide');

        

    }

   // @track ValuesAddOn;
    get AddOnsoptions(){
        return this.addOnValues;
    }

    // handleChangeAddOns(event){
    //     debugger;
    //     this.ValuesAddOn=event.target.value;
    // }
    @track LoadingSpinner = false;
    @track ThirdScreen=false;
    HandleClickNext(){
          debugger;
          
          
        if(this.selectedRecords.length==0){
            window.alert('Please Select Any Product')
        }
        else if(this.selectedRecords.length > 0){

             for(let i=0;i<this.selectedRecords.length;i++){
                     //delete this.selectedRecords[i].checkedvalue;
               }

            this.NewFunction();
            
            this.FirstScreen=false;
            this.SecondScreen=false;
            this.ThirdScreen=true;
            
            this.currentStep = '3';
    
            // this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            // this.template
            //     .querySelector('div.stepThree')
            //     .classList.remove('slds-hide');
        }

       
    }

    HandlePrevious(){
        debugger;
        this.SecondScreen=false;
        this.FirstScreen=true;

        this.currentStep = '1';
        this.TempArray=[];
            this.data=[];
            this.Firstdata=[];
            this.Searchvalue='';

        if(this.selectedRecords.length>0){
            this.selectedRecords=[];    
        }

        // this.template.querySelector('div.stepTwo').class.add('slds-hide');
        // this.template
        //     .querySelector('div.stepOne')
        //     .class.remove('slds-hide');
    }

   
    @track FirstTable=true;
    @track ProductValue;
    @track TempArray=[];
    @track SecondTable=false;
    @track Searchvalue;
    //@track Tempdata=[];

    //Search Bar second Screen
    HandleProduct(event){
        debugger;
        this.Searchvalue=event.target.value;
        //this.TempValue=value;
        let TempValue;
        if(this.Searchvalue){
            //this.ProductValue=value;
           
            TempValue=this.Searchvalue;
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
    debugger;
    this.AddOnPrice=0;
    this.ProductPrice=0;
    this.SecondScreen=true;
    this.ThirdScreen=false;

    this.currentStep = '2';

    // this.template.querySelector('div.stepThree').class.add('slds-hide');
    // this.template
    //     .querySelector('div.stepTwo')
    //     .class.remove('slds-hide');

       

  }

//   FinalArrayFirst=[];
//   FinalArraySecond=[];

  AllSelectedProducts=[];

//   getSelectedRowFirst(event){
//     debugger;
//     const selectedRows = event.detail.selectedRows;
//         // Display that fieldName of the selected rows
//         let arr=[];
//         for (let i = 0; i < selectedRows.length; i++) {
//             //alert('You selected: ' + selectedRows[i].opportunityName);
//             console.log('selectedRowsFirst====',selectedRows);
//              arr.push(selectedRows[i]);
//              console.log('arrselectedRowsFirst====',arr);
//         }
       
//             arr.forEach(element => {
//              if(this.AllSelectedProducts.find(item=>item.Id==element.Id)){
//                 console.log('Same Id');
//              }else{
//                 this.AllSelectedProducts.push(element); 
//              }
               
//             });
       
//         //console.log('Final Array First===',this.FinalArray);
//         // if(arr.length>0){
//         //      this.AllSelectedProducts=arr;
//         // }
        
//   }

//   getSelectedNameRowSecond(event){
//     debugger;
//     const selectedRows = event.detail.selectedRows;
//     // Display that fieldName of the selected rows
//     let arr=[];
//     for (let i = 0; i < selectedRows.length; i++) {
//         //alert('You selected: ' + selectedRows[i].opportunityName);
//         console.log('selectedRowsSecond====',selectedRows);
//         arr.push(selectedRows[i]);
//         console.log('arrselectedRowsSecond====',arr);
//     }
   
        // arr.forEach(element => {
        //  if(!this.AllSelectedProducts.includes(element.Id)){
        //     this.AllSelectedProducts.push(element);
        //  }
            
        // });

        // arr.forEach(element => {
        //     if(this.AllSelectedProducts.find(item=>item.Id==element.Id)){
        //        console.log('Same Id');
        //     }else{
        //        this.AllSelectedProducts.push(element); 
        //     }
              
        //    });
    

    //console.log('AllSelectedProducts===',this.AllSelectedProducts);
    // if(arr.length>0){
    //     this.FinalArraySecond=arr;
    // }
//     const unique = Array.from(new Set(this.AllSelectedProducts));

//     unique.forEach(element => {
//         arr.push(element);
//     });
 //}

 //@track Discount;
 //@track  ActualPriceValue;
 //DISCOUNT CALCULATION IN TABLE

 get DiscountOption() {
    return [
        { label: '0', value: 0 },
        { label: '5', value: 5 },
        { label: '10', value: 10 },
        { label: '15', value: 15 },
        { label: '20', value: 20 },
        { label: '25', value: 25 },
        { label: '30', value: 30 },
        { label: '35', value: 35 },
        { label: '40', value: 40 },
        { label: '45', value: 45 },
        { label: '50', value: 50 },
          

    ];
}
 
  //@track Discount__c=0
 handleInputChange(event){
   
 debugger;
    //let DiscountPrice;
    let value=parseInt(event.target.value);
    this.textid = event.target.dataset.id;
    var totalDiscountedPrice = 0;
    for(let i = 0; i < this.AllSelectedProductsXRelatedAddOns.length; i++) {
        
        if(this.AllSelectedProductsXRelatedAddOns[i].Id === this.textid) {
            //this.AllSelectedProductsXRelatedAddOns[i].Discount__c=0;
            //let DiscountPrice;
            if(event.target.name=='Discount'){
               
                    this.AllSelectedProductsXRelatedAddOns[i].Discount__c = value;
             
                
                if(this.AllSelectedProductsXRelatedAddOns[i].Price__c!=null || this.AllSelectedProductsXRelatedAddOns[i].Price__c!=undefined){
                   
                    // let  Prdis  = ((this.AllSelectedProductsXRelatedAddOns[i].Discount__c/100)*this.AllSelectedProductsXRelatedAddOns[i].Price__c);
                    // let PriceDeducted=Prdis;
                    // console.log('PriceDeducted in Addon--',PriceDeducted);
                    let DiscountPrice=this.AllSelectedProductsXRelatedAddOns[i].Price__c - ((this.AllSelectedProductsXRelatedAddOns[i].Discount__c/100)*this.AllSelectedProductsXRelatedAddOns[i].Price__c);
                    totalDiscountedPrice = totalDiscountedPrice + DiscountPrice;
                        // this.TotalAddonXProd=this.TotalAddonXProd-PriceDeducted;
                        this.AllSelectedProductsXRelatedAddOns[i].ActualPriceValue=DiscountPrice;
                    
                    
                }

                else if(this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice!=null || this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice!=undefined){

                
                    let DiscountPrice=this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice - ((this.AllSelectedProductsXRelatedAddOns[i].Discount__c/100)*this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice);
                    totalDiscountedPrice = totalDiscountedPrice + DiscountPrice;
                    
                    // let TotalPricecount=this.AddOnXTotalPrice;
                    // let PriceDeducted=((this.AllSelectedProductsXRelatedAddOns[i].Discount__c/100)*this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice);

                    //  TotalPricecount=TotalPricecount-PriceDeducted.toFixed(1);
                    //  let remainingPrice=TotalPricecount;
                    //  this.AddOnXTotalPrice=remainingPrice;
                    //this.TotalAddonXProd=this.AddOnXTotalPrice.toFixed(2);
                        //  let ActualDiscount=this.TotalAddonXProd-(PriceDeducted.toFixed(2));
                        //  this.TotalAddonXProd=ActualDiscount;
                        //  console.log('PriceDeducted in prod--',this.TotalAddonXProd.toFixed(2))
                        this.AllSelectedProductsXRelatedAddOns[i].ActualPriceValue=DiscountPrice;  
                }
                 
               
                 console.log('AllSelectedProductsXRelatedAddOns--',this.AllSelectedProductsXRelatedAddOns);
                
                //this.ActualPriceValue[i]=this.selectedRecords[i]['ActualPriceValue'];
                //this.ActualPriceValue=value;
            }
            // else if(event.target.name=='AddOns'){
            //     this.selectedRecords[i]['Discount__c'] = value;
            // }

            // if(event.target.name=='Actual Price'){
            //     this.ActualPriceValue[i]=DiscountPrice;
            // }
           
        }
        else{
            var recordfinded = this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==this.AllSelectedProductsXRelatedAddOns[i].Id)
                if (recordfinded.Discount__c !=null) {
                    totalDiscountedPrice = totalDiscountedPrice + this.AllSelectedProductsXRelatedAddOns[i].ActualPriceValue;
                    
                }else if(this.AllSelectedProductsXRelatedAddOns[i].Price__c!=null){

                    totalDiscountedPrice = totalDiscountedPrice + this.AllSelectedProductsXRelatedAddOns[i].Price__c;
               }else{

                totalDiscountedPrice = totalDiscountedPrice + this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice;
               }
            

        }

       
        //this.ActualPriceValue=value;
    }
    this.TotalAddonXProd = totalDiscountedPrice.toFixed(2);

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
            @track SelectedAddons=[];
            @track SelectedProduct=[];

            cancelAndReddirect(){
                var urlString = 'https://excelr2--dev.sandbox.lightning.force.com/lightning/r/Opportunity/'+this.recordId + '/view';//sandbox
                //var urlString = 'https://excelr2.lightning.force.com/lightning/r/Opportunity/'+this.recordId + '/view';//production
                 //              this.showNotification();
                this.navigateToList(urlString);
            }
            disableButton=false;

        HandleClickSave(){
            this.LoadingSpinner=true;
            debugger;
            this.disableButton=true;
            for(let i=0;i<this.AllSelectedProductsXRelatedAddOns.length;i++){
                delete this.AllSelectedProductsXRelatedAddOns[i].checkedvalue;
          }
            this.AllSelectedProductsXRelatedAddOns.forEach(element => {
                
                  if(element.Addon_Product__c!=null){
                    if(this.SelectedAddons.find(item=>item.Id==element.Id)){
                        console.log('This Id Exist');
                    }else{
                        this.SelectedAddons.push(element);
                    }
                         
                  }else{

                    if(this.SelectedProduct.find(item=>item.Id==element.Id)){
                        console.log('This Id Exist');
                    }else{
                        this.SelectedProduct.push(element);
                    }
                        
                  }
            });
                 
              console.log('SelectedAddons--',this.SelectedAddons);
              console.log('SelectedProduct--',this.SelectedProduct);
            InsertOppLineItem({Prodlist:this.SelectedProduct,AddOnList:this.SelectedAddons,oppId:this.recordId})
            .then(result=>{
                console.log('result',result);
                if(result=='SUCCESS' || result==null || result==undefined){
                       console.log('result---',result);
                       this.LoadingSpinner=false;
                       //location.href='https://excelr2--qa.sandbox.lightning.force.com/lightning/r/Opportunity'+this.recordId + '/view';
                       //'https://excelr2--qa.sandbox.lightning.force.com/lightning/r/Opportunity/006N000000KDlI8IAL/view'
                         var windowlocation = JSON.stringify(document.URL);
                         
                         var urlString = 'https://excelr2--dev.sandbox.lightning.force.com/lightning/r/Opportunity/'+this.recordId + '/view';
                       this.showNotification();

                       this.navigateToList(urlString);

                       //window.open(urlString);
                       //window.location.href = urlString;
                       //window.location.assign(urlString, "_self");
                       //window.location.reload();
                       //window.location.replace(urlString);
                       //window.location('https://excelr2--qa.sandbox.lightning.force.com/lightning/r/Opportunity'+this.recordId);
                       
                       //this.Navigate();
                        //this.showCustomToast('SUCCESS','OppLine Item Created Successfully');
                        
                    //eval("$A.get('e.force:refreshView').fire();");
                }
            })
            .catch(error=>{

            })

        }
        //recordPageUrl ='https://excelr2--qa.sandbox.lightning.force.com/lightning/r/Opportunity';

        
        Navigate(){
            debugger;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                },
            });
          }
        
        

        showNotification() {
            debugger;
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
                 const recId = event.target.dataset.id;
                 if (event.target.checked){
                    for (let i = 0; i < this.data.length; i++) {
                        if (this.data[i].Id == recId ) {
                            this.data[i].checkedvalue = true;
                            this.selectedRecords.push(this.data[i]);
                        }
                        else{
                            this.data[i].checkedvalue = false;
                           // if (this.selectedRecords.length >0) {
                                var recordfound = this.selectedRecords.find(record => record.Id === this.data[i].Id);
                                console.log('recordfound',recordfound);
                                if(recordfound != null && recordfound!= undefined){
                                    this.selectedRecords = this.selectedRecords.filter(record => record.Id !== recordfound.Id);
                                }  
                            
                        }   
                    }

                 }else{
                    //this.checkedvalue=event.target.checked;
                    

                 }
                 console.log('this.selectedRecords-',this.selectedRecords);
                 
                // if (event.target.checked) {
                //     this.checkedvalue=event.target.checked;
                    
                //     if(this.selectedRecords.find(item=>item.Id==recordId)){
                //         console.log('This Id Exists')
                //     }
                //     else{
                //          // push the selected record to the array
                //         this.selectedRecords.push(this.data.find(record => record.Id === recordId));
                //     }
                //   } else {
                //     // remove the unselected record from the array
                //     this.checkedvalue=event.target.checked;
                //     this.selectedRecords = this.selectedRecords.filter(record => record.Id !== recordId);
                // }
                // console.log('selectedRecords===',this.selectedRecords);

                

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

           // removeRow(event){
                
                // let id=parseInt(event.currentTarget.dataset.id);
       
                // this.AllSelectedProductsXRelatedAddOns = this.AllSelectedProductsXRelatedAddOns.filter(item=>item.id!=id);

       
                // if(this.selectedRecords.find(item=>item.Id==recordId)){

                    
                //     const index = this.selectedRecords.indexOf(item.Id);

                //     const x = this.selectedRecords.splice(index, 1);
                //     console.log('selectedRecords=',x);
                    
                // }
               // console.log('AllSelectedProductsXRelatedAddOns=',this.AllSelectedProductsXRelatedAddOns);
                
           // }
            removeRowFinalArray(event){
                  
                debugger;
                let foundRecord;
                let SelectedFoundRecord;
                let index;
                let SelectedRecodIndex;
                let recordId= event.target.dataset.id;

                foundRecord = this.AllSelectedProductsXRelatedAddOns.find((record) => {
                    return record.Id === recordId;
                });
                 
                //-----Here Deleting The AddOn Record----Starts HERE-----
            //     if(foundRecord.Add_Ons__r!=null){
            //         console.log('AddOns Exist');
                    
            //         foundRecord.Add_Ons__r.forEach(element => {
            //             console.log('Element--',element);
            //            if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==element.Id)){
            //                console.log('This Addon Id  Exist');
            //                let AddOnRecord = this.AllSelectedProductsXRelatedAddOns.find((record) => {
            //                 return record.Id === element.Id;
            //             });
            //                console.log('AddOnRecord',AddOnRecord);
            //              let AddOnIndex=this.AllSelectedProductsXRelatedAddOns.indexOf(AddOnRecord);
            //                 console.log('AddOnIndex',AddOnIndex);
            //              this.AllSelectedProductsXRelatedAddOns.splice(AddOnIndex, 1);
            //              this.TotalAddonXProd=this.TotalAddonXProd-AddOnRecord.Price__c;
            //              console.log('TotalAddonxProd After Addon&Product Delete',this.TotalAddonXProd);
            //            }
            //      });

            // }
            //----------------------Ends Here------------------


                SelectedFoundRecord = this.selectedRecords.find((record)=>{
                    return record.Id === recordId;
                })

                console.log('foundRecord==',foundRecord);
                console.log('SelectedFoundRecord==',SelectedFoundRecord);
                
                 index=this.AllSelectedProductsXRelatedAddOns.indexOf(foundRecord);
                console.log('index==',index);

                // SelectedRecodIndex=this.selectedRecords.indexOf(foundRecord);
                // console.log('index==',index);

                // if(this.AllSelectedProductsXRelatedAddOns[index].Discount__c!=null){
                     
                //     this.AllSelectedProductsXRelatedAddOns[index].Discount__c=0;
                //     //this.AllSelectedProductsXRelatedAddOns[index].ActualPriceValue=this.AllSelectedProductsXRelatedAddOns[index].PricebookEntries[0].UnitPrice;
                // }
                 
                this.AllSelectedProductsXRelatedAddOns.splice(index, 1);
                //this.selectedRecords.splice(SelectedRecodIndex, 1);
                

                if(foundRecord.Price__c!=null){
                    let value=this.TotalAddonXProd;
                   let recordPrice=foundRecord.Price__c;
                      value=value-recordPrice;

                   let  remainingvalue=value;
                   this.AddOnXTotalPrice=remainingvalue;
                    this.TotalAddonXProd=this.AddOnXTotalPrice.toFixed(2);
                    console.log('TotalAddonxProd After Addon Delete',this.TotalAddonXProd);
                }else{
                    let value=this.TotalAddonXProd;
                    if(foundRecord.Discount__c!=null){
                        let recordPrice=foundRecord.ActualPriceValue;
                        value=value-recordPrice;
                         
                    }else{
                        let recordPrice=foundRecord.PricebookEntries[0].UnitPrice;
                        value=value-recordPrice;
                    }
                    
                     
                      let  remainingvalue=value;
                      this.AddOnXTotalPrice=remainingvalue;
                    this.TotalAddonXProd=this.AddOnXTotalPrice;
                    console.log('TotalAddonxProd After Product Delete',this.TotalAddonXProd);
                }
                console.log('this.AllSelectedProductsXRelatedAddOns',this.AllSelectedProductsXRelatedAddOns.length);

                // if(this.AllSelectedProductsXRelatedAddOns.length==0){
                //     this.TotalAddonXProd=0;
                //     console.log('this.TotalAddonXProd',this.TotalAddonXProd);

                //     // for(let i=0;i<this.selectedRecords.length;i++){
                //     //         this.selectedRecords[i].checkedvalue=false;  

                //     //  }
                // }

                //this.AllSelectedProductsXRelatedAddOns.splice(this.AllSelectedProductsXRelatedAddOns.findIndex(row => row.Id === recordId), 1);

                console.log('AllSelectedProductsXRelatedAddOns==',this.AllSelectedProductsXRelatedAddOns);
                console.log('selectedRecords==',this.selectedRecords);
            }


            //For Adding Row In FirstScreen

            KeyIndex=0;

                @track itemList=[{id:0,Course_1__c:null,Mode_One__c:null,Course_2__c:null,Mode_Two__c:null,Mode_Three__c:null,Course_3__c:null}];
                //Create Rows
                addRowFirstScreen(){
                debugger;
                ++this.KeyIndex;
                if(this.KeyIndex > 2 ){
                    this.KeyIndex=this.KeyIndex-1;
                    let newItem={id:this.KeyIndex,Course_1__c:null,Mode_One__c:null,Course_2__c:null,Mode_Two__c:null,Mode_Three__c:null,Course_3__c:null};
                    this.itemList.push(newItem);
                }else{
                    
                    let newItem={id:this.KeyIndex,Course_1__c:null,Mode_One__c:null,Course_2__c:null,Mode_Two__c:null,Mode_Three__c:null,Course_3__c:null};
                    this.itemList.push(newItem);
                }
                 
        }

        //Delete Rows
    removeRow(event) {
        debugger;
          if (this.itemList.length >= 2) {
              this.itemList = this.itemList.filter(function (element) {
                  return parseInt(element.id) !== parseInt(event.target.accessKey);
              });
          }
        //   for(let i = 0; i < this.itemList.length; i++) {
        //       this.itemList.id=i; 
        //     }

      }

      @track newModevalue;
      @track newCoursevalue;

      handleChange(event){
        debugger;
        let index = event.target.dataset.id;
            let fieldName = event.target.name;
            let value = event.target.value;
            
    
        for(let i = 0; i < this.itemList.length; i++) {
            if(this.itemList[i].id === 0){
                if(this.itemList[i].id === parseInt(index)) {
                    if(fieldName=='Select Course'){
                     this.itemList[i].Course_1__c = value;
                     this.itemList[i].newCoursevalue=value
                   }
                   else if(fieldName=='Select Mode'){
                     this.itemList[i].Mode_One__c = value;
                     this.itemList[i].newModevalue=value;
                   }
                  
                   
                }
            }else if(this.itemList[i].id === 1){
                
                if(this.itemList[i].id === parseInt(index)) {
                    if(fieldName=='Select Course'){
                     this.itemList[i].Course_2__c = value;
                     this.itemList[i].newCoursevalue=value
                   }
                   else if(fieldName=='Select Mode'){
                     this.itemList[i].Mode_Two__c = value;
                     this.itemList[i].newModevalue=value;
                   }
                  
                   
                }
            }else if(this.itemList[i].id === 2){
                
                if(this.itemList[i].id === parseInt(index)) {
                    if(fieldName=='Select Course'){
                     this.itemList[i].Course_3__c = value;
                     this.itemList[i].newCoursevalue=value
                   }
                   else if(fieldName=='Select Mode'){
                     this.itemList[i].Mode_Three__c = value;
                     this.itemList[i].newModevalue=value;
                   }
                  
                   
                }
            }
            
        }
       
        console.log('ItemList On HandleChange=',this.itemList);
      }

       KeyIndexTrack=0;
       @track TargetRecId;
       @track ComoboBoxShow=false;
       @track newitemList=[];
       @track targetId;
       @track AddOnList=[];
       @track optionsMaster=[];
       @track TempAddOnList=[];

       @track AddOnProductswithPrice=[];
       //=[{id:null,AddOnvalues:null}];
      addRowAddonsFirstTable(event){
        debugger;
        this.ComoboBoxShow=true;

        let foundRecord;
        let index;
        this.TargetRecId = event.target.dataset.id;
        foundRecord = this.data.find((record) => {
            return record.Id === this.TargetRecId;
        });
        console.log('foundRecord==',foundRecord);

        //Here It Finds The Index Of Selected Record Id
         index=this.data.indexOf(foundRecord);
        console.log('index==',index);

        let targetId = event.target.dataset.targetId;
          this.data[index].Add_Ons__r;

          if(this.data[index].Add_Ons__r==null){
                
            FetchAddOns({ProdId:this.TargetRecId})
            .then(result=>{
                console.log('result--',result);
                console.log('result--',result.length);
               // this.AddOnProductswithPrice=result;
               if(result.length== 0){
                this.optionsMaster=[];
               }
                let arr=[];
                if(result.length > 0){
    
                    console.log('IF result--',result);
                    console.log('IF result--',result.length);
                    for(let i=0;i < result.length;i++){
                        arr.push({label:result[i].Addon_Product__r.Name,value:result[i].Addon_Product__r.Name})
                    }
                    console.log('arr AddOn Values--',arr);
                    this.AddOnList=arr;
                    this.optionsMaster=arr;
                    console.log('AddOnList AddOn Values--',this.AddOnList);
                    console.log('optionsMaster AddOn Values--',this.optionsMaster);
                    this.AddOnProductswithPrice=result;
                    console.log('AddOnProductswithPrice--',this.AddOnProductswithPrice);
                }
    
                //If For That Product Previously Any Certificate Is Choosed Then Show It In The Combo Box
                // if(this.data.find(item=>item.Id==this.TargetRecId)){
                //     console.log('This Id Exists')
                // }
            })
            .catch(error=>{
    
            })
          }
          else if(this.data[index].Add_Ons__r!=null){

            
            FetchAddOns({ProdId:this.TargetRecId})
            .then(result=>{
                console.log('result--',result);
                console.log('result--',result.length);
               // this.AddOnProductswithPrice=result;
                if(result.length > 0){

                    let arr=[];
                    console.log('IF result--',result);
                    console.log('IF result--',result.length);
                    for(let i=0;i < result.length;i++){
                        arr.push({label:result[i].Addon_Product__r.Name,value:result[i].Addon_Product__r.Name})
                    }
                    this.AddOnList=arr;
                    this.AddOnProductswithPrice=result;
                }
            })
                .catch(error=>{
                      console.log('error--',error);
                })

            
               this.data[index].Add_Ons__r.forEach(element => {
                
                        this.allValues.push(element.Addon_Product__r.Name);
                        
                });

                // if(this.AddOnList!=null){
                //     this.modifyOptions();
                // }

              
                   //this.allValues=this.data[index].AddOnNames;
             }
        

        //
    //    let targetId = event.target.dataset.targetId;
    //             debugger;
    //             let newItem={id:this.KeyIndexTrack,AddOnvalues:null};
    //             this.newitemList.push(newItem);
    //             if(this.Firstdata.find(item=>item.Id==targetId)){
    //                 console.log('This Id Exists');
    //                 //let index=this.data.indexOf(targetId);
                    
    //                 let foundRecord  = this.Firstdata.find((record) => {
    //                         return record.Id === targetId;
    //                     });
    //                     console.log('foundRecord==',foundRecord);
    //                     let index=this.Firstdata.indexOf(foundRecord);
    //                     console.log('index==',index);
    //                     this.Firstdata[index]['Add_Ons__r']=this.newitemList;
    //                     console.log('this.data==',this.Firstdata);
    //             }
    //             this.ShowAddons=true;
    //             ++this.KeyIndexTrack;

      }

      get AddOnOptions(){
        return  this.AddOnList;
      }

      HandelCancel(){
        this.ComoboBoxShow=false;
      }

    //   handleChangeAddOns(event){
    //     debugger;
    //     var valueaddonforindex =event.detail.value;
    //     let indexvalue = event.currentTarget.dataset.id;
    //     let targetId = event.target.dataset.targetId;
    //     for(let i=0;i<this.newitemList.length;i++){
    //         if (i == indexvalue ) {
    //             this.newitemList[i].AddOnvalues=valueaddonforindex;                
    //         }
            
    //     }
    //     console.log('this.newitemList=',this.newitemList);

    //     let foundRecord ;

    //     if(this.Firstdata.find(item=>item.Id==targetId)){
    //         console.log('This Id Exists');
    //         //let index=this.data.indexOf(targetId);
            
    //         foundRecord = this.Firstdata.find((record) => {
    //                 return record.Id === targetId;
    //             });
    //             console.log('foundRecord==',foundRecord);
    //             let index=this.data.indexOf(foundRecord);
    //             console.log('index==',index);
    //             //this.Firstdata[index].unshift(this.newitemList);
    //             console.log('this.data==',this.data);
    //     }else{
            
    //     }
    //   }

      //MultiSelect Picklist In ComboBox
      //This Is A MultiSelect Picklist Combo Box ----Starts Here--
      @track  allValues=[];
      @track ValuesAddOn;
      handleChangeAddOns(event)
      {
        debugger;
        let value=event.target.value;
        this.ValuesAddOn=value;

        if(!this.allValues.includes(this.ValuesAddOn)){
            this.allValues.push(this.ValuesAddOn);
        }
        this.modifyOptions();
      }

      handleRemove(event)
  {
    debugger;
    this.ValuesAddOn='';
    const valueRemoved=event.target.name;
    this.allValues.splice(this.allValues.indexOf(valueRemoved),1);
    this.modifyOptions();
  }
        
  modifyOptions()
  {
    debugger;
    this.AddOnList=this.optionsMaster.filter(elem=>{
      if(!this.allValues.includes(elem.value))
        return elem;
    })
    console.log('allValues After Modify==',this.allValues);
    console.log('AddOnList After Modify==',this.AddOnList);
    console.log('optionsMaster After Modify==',this.optionsMaster);
  }

  //------------Ends Here------------------

  //Here This Code is Written on Save(Button On Modal PopUp)
  @track NewArrayTostoreProdAddOn=[];
  HandleSave(){
   
      debugger;
      let foundRecord;
      let index;
      console.log('this.TargetRecId=',this.TargetRecId);

      if(this.selectedRecords.find(item=>item.Id==this.TargetRecId)){
                console.log('This Id Exists On Selected Record');
                //let index=this.data.indexOf(targetId);
                
                foundRecord = this.selectedRecords.find((record) => {
                        return record.Id === this.TargetRecId;
                    });
                    console.log('foundRecord==',foundRecord);

                    //Here It Finds The Index Of Selected Record Id
                     index=this.selectedRecords.indexOf(foundRecord);
                    console.log('index==',index);
                    //this.Firstdata[index].unshift(this.newitemList);
                    let text;
                    if(this.allValues.length>1){
                         text = this.allValues.join(" ; ");
                    }else{
                        text = this.allValues; 
                    }
                    this.selectedRecords[index]['AddOnNames']=text;
                    console.log('this.data==',this.selectedRecords); 
                    
                        
                        this.allValues.forEach(element => {
                          let GetRecord = this.AddOnProductswithPrice.find((record) => {
                                return record.Addon_Product__r.Name === element;
                            });
                            console.log('GetRecord',GetRecord);
                            if(this.NewArrayTostoreProdAddOn.find(item=>item.Id==GetRecord.Id)){
                                     console.log('This Addon Id Exist Or Selected Before');
                            }else{
                                this.NewArrayTostoreProdAddOn.push(GetRecord);
                            }
                               
                          });
                      
                          console.log('NewArrayTostoreProdAddOn--',this.NewArrayTostoreProdAddOn);

                        //   this.NewArrayTostoreProdAddOn.forEach(element=>{
                        //          console.log('Element --',element);
                        //          console.log('Element Id--',element.Id);
                        //          console.log('Element Name--',element.Name);
                        //          if(this.data[index]['Add_Ons__r'].find(item=>item.Id==element.Id)){
                        //             console.log('This Id Exists')
                        //         }
                        //         else{
                        //              // push the selected record to the array
                        //             this.selectedRecords.push(this.data.find(record => record.Id === recordId));
                        //         }
                        //   });

                          this.selectedRecords[index]['Add_Ons__r']=this.NewArrayTostoreProdAddOn;
                    
                   console.log('AddOnNames--',this.selectedRecords[index].AddOnNames);

            }
            else if(this.data.find(item=>item.Id==this.TargetRecId)){
                console.log('This Id Exists In data Record');
                //let index=this.data.indexOf(targetId);
                
                foundRecord = this.data.find((record) => {
                        return record.Id === this.TargetRecId;
                    });
                    console.log('foundRecord==',foundRecord);
                     index=this.data.indexOf(foundRecord);
                    console.log('index==',index);
                    //this.Firstdata[index].unshift(this.newitemList);
                    let text;
                    if(this.allValues.length>1){
                         text = this.allValues.join(" ; ");
                    }else{
                        text = this.allValues; 
                    }
                    this.data[index]['AddOnNames']=text;
                    console.log('this.data==',this.data); 
                    
                        
                        this.allValues.forEach(element => {
                          let GetRecord = this.AddOnProductswithPrice.find((record) => {
                                return record.Addon_Product__r.Name === element;
                            });
                            if(this.NewArrayTostoreProdAddOn.find(item=>item.Id==GetRecord.Id)){
                                     console.log('This Addon Id Exist Or Selected Before');
                            }else{
                                this.NewArrayTostoreProdAddOn.push(GetRecord);
                            }
                               
                          });
                      
                          console.log('NewArrayTostoreProdAddOn--',this.NewArrayTostoreProdAddOn);
                          this.data[index]['Add_Ons__r']=this.NewArrayTostoreProdAddOn;
                    
                          console.log('AddOnNames--',this.data[index].AddOnNames);

            }

            //Here The Modal Pop-Up Is Closed on Click Of Save Button
            if(((this.optionsMaster!=null) && (this.data[index].AddOnNames!=null || this.data[index].AddOnNames!=undefined)) || ((this.optionsMaster!=null) && (this.selectedRecords[index].AddOnNames!=null || this.selectedRecords[index].AddOnNames!=undefined))){
                this.ComoboBoxShow=false;
                this.allValues=[];
                this.AddOnList=[];
                this.NewArrayTostoreProdAddOn=[];
                this.ValuesAddOn;
                console.log('allValues After FirstCondition--',this.allValues);
                console.log('AddOnList After FirstCondition--',this.AddOnList)
            }else if(((this.optionsMaster==null) && (this.data[index].AddOnNames==null || this.data[index].AddOnNames==undefined)) || (this.optionsMaster==null) && (this.selectedRecords[index].AddOnNames==null || this.selectedRecords[index].AddOnNames==undefined)){
                this.ComoboBoxShow=false;
                window.alert('This Product Has No AddOns');
                console.log('This Product Has No AddOns');
            }

  }

  //Add_Ons__r
  //Now Here I am Going To Create A new Array For Storing All The Selected Products And Their AddOns
 @track AllSelectedProductsXRelatedAddOns=[];
 @track AddOnPrice=0;
 @track ProductPrice=0;
 @track TotalAddonXProd=0;
 @track AddOnXTotalPrice=0;
  NewFunction(){
        debugger;

        if(this.AllSelectedProductsXRelatedAddOns.length>0){

            for(let i=0;i<this.selectedRecords.length;i++){
                if(this.selectedRecords[i].Id===this.AllSelectedProductsXRelatedAddOns[i].Id){
                    console.log('No Need To Empty The List');
                }else{
                    this.AllSelectedProductsXRelatedAddOns[i].Discount__c=0;
                    this.AllSelectedProductsXRelatedAddOns=[];
                }
                
            }
            if(this.AllSelectedProductsXRelatedAddOns.length==0){
                this.TotalAddonXProd=0;
            }
         }

     for(let i=0;i<this.selectedRecords.length;i++){

        if(this.selectedRecords[i].Add_Ons__r!=null || this.selectedRecords[i].Add_Ons__r!=undefined){
             
            if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==this.selectedRecords[i].Id)){
                console.log('This Id Already Exist');
                this.selectedRecords[i].Add_Ons__r.forEach(element => {
                    console.log('Element--',element);
                   if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==element.Id)){
                       console.log('This Addon Id Already Exist')
                   }else{
                       this.AllSelectedProductsXRelatedAddOns.push(element);
                       let prod=element.Price__c;
                       this.AddOnPrice=this.AddOnPrice + prod;
                   }
                      
               });
            }
            else{
                this.AllSelectedProductsXRelatedAddOns.push(this.selectedRecords[i]);
                let prod=this.selectedRecords[i].PricebookEntries[0].UnitPrice;
                this.ProductPrice=this.ProductPrice + prod;
                 //this.AllSelectedProductsXRelatedAddOns[i].Discount__c=0;

                this.selectedRecords[i].Add_Ons__r.forEach(element => {
                    console.log('Element--',element);
                   if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==element.Id)){
                       console.log('This Addon Id Already Exist')
                   }else{
                       this.AllSelectedProductsXRelatedAddOns.push(element);
                       
                       let prod=element.Price__c;
                       this.AddOnPrice=this.AddOnPrice + prod;
                       //this.AllSelectedProductsXRelatedAddOns[]
                   }
                      
               });
            }
                // for(let j=0;j<this.selectedRecords[i].Add_Ons__r.length;i++){
                //     if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==this.selectedRecords[i].Id)){
                //             console.log('This ID Already Exist');       
                //     }
                //     else{
                //         this.AllSelectedProductsXRelatedAddOns.push(this.selectedRecords[i]);

                //         this.selectedRecords[i].Add_Ons__r.forEach(element => {
                //               console.log('Element--',element);  
                //          });
                //         // if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==this.selectedRecords[i].Add_Ons__r[j].Id)){
                //         //     console.log('This AddOn Id Exist');
                //         // }else{
                //         //     this.AllSelectedProductsXRelatedAddOns.push(this.selectedRecords[i].Add_Ons__r[j]);
                //         // }
                //     }
                    
                    
                // }
            
                console.log('AllSelectedProductsXRelatedAddOns---',this.AllSelectedProductsXRelatedAddOns); 
            
            
        }else if(this.selectedRecords[i].Add_Ons__r==null || this.selectedRecords[i].Add_Ons__r==undefined){

            if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==this.selectedRecords[i].Id)){
                console.log('This Id Already Exist');
            }else{
                this.AllSelectedProductsXRelatedAddOns.push(this.selectedRecords[i]);
                let prod=this.selectedRecords[i].PricebookEntries[0].UnitPrice;
                //console.log('PriceBook',this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice);
                //this.AllSelectedProductsXRelatedAddOns[i].Discount__c=0;
                this.ProductPrice=this.ProductPrice + prod;

            }
            
            console.log('Process Completed');
        }

        // if(this.AllSelectedProductsXRelatedAddOns.find(item=>item.Id==this.selectedRecords[i].Id)) {
        //        console.log('This Id Already Exist ');
        // }else{
        //     this.AllSelectedProductsXRelatedAddOns.push(this.selectedRecords[i]);
        // }
        console.log('AllSelectedProductsXRelatedAddOns---',this.AllSelectedProductsXRelatedAddOns);

       

    //     this.AllSelectedProductsXRelatedAddOns.forEach(element => {
    //         if(element.Price__c!=null){
    //             this.AddOnPrice=this.AddOnPrice + element.Price__c;
    //             console.log('AddOnPrice--',this.AddOnPrice);
    //         }else{
    //             console.log('ProductPrice--',element.PricebookEntries[0].UnitPrice);

    //                 this.ProductPrice= this.ProductPrice + element.PricebookEntries[0].UnitPrice  ;
    //                 if( element.PricebookEntries[0].UnitPrice!=this.ProductPrice)
              
                
    //             console.log('ProductPrice--',this.ProductPrice);
    //         }
             
    //     });
    //  
     }

    
     console.log('ProductPrice--',this.ProductPrice);
     console.log('AddOnPrice--',this.AddOnPrice);
     let TotalPrice=this.ProductPrice+this.AddOnPrice;
     this.AddOnXTotalPrice=TotalPrice;
     if( this.AddOnXTotalPrice==0){
        this.TotalAddonXProd = this.TotalAddonXProd;
     }else{
        this.TotalAddonXProd = parseInt(this.TotalAddonXProd) + this.AddOnXTotalPrice;
     }
     
     //this.TotalAddonXProd;
     console.log('TotalAddonXProd--',this.TotalAddonXProd);
     console.log('TotalPrice--',TotalPrice);

    //  for(let i=0;i<this.AllSelectedProductsXRelatedAddOns.length;i++){

    //     if(this.AllSelectedProductsXRelatedAddOns[i].Price__c!=null){
    //         this.AddOnPrice=this.AddOnPrice + this.AllSelectedProductsXRelatedAddOns[i].Price__c;
    //     }else{
    //         let prod=this.AllSelectedProductsXRelatedAddOns[i].PricebookEntries[0].UnitPrice;
    //         this.ProductPrice=this.ProductPrice + prod;
    //         console.log('ProductPrice--',this.ProductPrice);
    //     }
    // }
     
 }

//  showCustomToast(title,message){
//     this.template.querySelector('c-custom-toast').showToast(title,'<span>'+message+'<span/>','utility:warning',10000);
//   }

}