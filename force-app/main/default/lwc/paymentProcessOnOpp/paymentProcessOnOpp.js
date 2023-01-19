import { LightningElement,wire,api,track } from 'lwc';
import staticimage from '@salesforce/resourceUrl/RazorPay';
import CcStatic from '@salesforce/resourceUrl/ccAvenue';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ShowAmount from '@salesforce/apex/PaymentProcessOnOpportunityController.ShowAmount';
import ShowNbfcPartners from '@salesforce/apex/PaymentProcessOnOpportunityController.ShowNbfcPartners';
import CreateOppLineItem from '@salesforce/apex/PaymentProcessOnOpportunityController.CreateOppLineItem';
import OppUpdateOnFullLoan from '@salesforce/apex/PaymentProcessOnOpportunityController.OppUpdateOnFullLoan';
import OppUpdateOnPartialLoan from '@salesforce/apex/PaymentProcessOnOpportunityController.OppUpdateOnPartialLoan';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';
import PAYMENT_FIELD from '@salesforce/schema/Opportunity.Payment_Mode__c';
import ShowPriceIncludingGST from '@salesforce/apex/PaymentProcessOnOpportunityController.ShowPriceIncludingGST';
import CreateInvoice from '@salesforce/apex/PaymentProcessOnOpportunityController.CreateInvoice';

export default class PaymentProcessOnOpp extends LightningElement {  
   // RazorPayImage=staticimage;
   // CcAvenueImage=CcStatic;

    @api recordId;

    @track ShowForm=true;
    @track ShowFormButton=true;
    @track ShowPaymentCard=false;

    @track Loanvalue

    @track HandleButtonDisable=true;
    @track DisableSave=true;
    @track DisableNext=true;

    @track ProductValue;
    @track QuantityValue=1;
    @track originalPrice;
    @track  Amount;
    @track loanAmount;


    //Here Getting The Payment Types
    Picklistvalue=[];
    @wire(getObjectInfo, {objectApiName:OPP_OBJECT})
    objectInfo

    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:PAYMENT_FIELD})
     wiredPicklistValues({data,error}){
         debugger;
        if(data){
           console.log('data=',data);
           console.log('dataValues=',data.values);
           let arr=[];
           for(let i=0;i<data.values.length;i++){
              arr.push({label:data.values[i].label,value:data.values[i].value});
           }
           this.Picklistvalue=arr;
           console.log('Picklistvalue=',this.Picklistvalue);
        }
        else {
            console.log('error=',error)
        }
     }

     get Paymentoptions(){
        return this.Picklistvalue;
     }

     HandlePaymentType(event){
        debugger;
        this.PaymentType=event.detail.value;

        if(this.PaymentType=='RazorPay'){
            this.HandleRazorPay();
        }
        else if(this.PaymentType=='CC Avenue'){
            this.HandleCCAvenuePay();
        }
        else if( this.LoanButtonName=='LoanNotNeed' && (this.PaymentType=='Cash' || this.PaymentType=='POS' || this.PaymentType=='Cheque' )){
            this.HandlePaymentMethods();
        }
        else if( this.Loanvalue=='Partial Loan' && (this.PaymentType=='Cash' || this.PaymentType=='POS' || this.PaymentType=='Cheque' )){
            this.HandlePaymentMethods();
        }
     }

     HandlePaymentMethods(){
        debugger;
        this.LoadSpinner=true;
        this.ShowPaymentCard=false;
        CreateInvoice({recordId:this.recordId,FinalAmount:this.Amount,PartialTenureValue:this.PartialLoanTenureValue,partialNBFCValue:this.PartialLoanNBFCPartnervalue,PartialUpfrontValue: this.PartialLoanUpfrontpaymentvalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.priceIncludingGst,paymentType:this.PaymentType})
        .then(result=>{
            if(result=='Success'){
                this.LoadSpinner=false;
                this.showToast('success','Invoice created successfully!','success');
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else{
                this.showToast('Failed',result,'error');
            }

        })
        .catch(error=>{
            this.showToast('Failed',error,'error');
            

        })
    }


    @wire(ShowAmount,{ProductName:'$ProductValue'})
     wiredResponse({data,error}){
        console.log('Amount recieved---',data);
        console.log('ProductName---',this.ProductValue);
        debugger;
        console.log('data='+data);
        if(data){
            this.originalPrice = data;
           this.Amount=data;
           console.log('Amount='+this.Amount);
        }
        else{
            console.log('error='+error);
        }
     }

     @track fetchedArr=[];
     @track nbfcCSList = [];
 
    //Here Getting NBFC Partner List
    @wire(ShowNbfcPartners)
    wiredNbfcResponse({data,error}){
          debugger;
         if(data){
            this.nbfcCSList = data;

            console.log('data=',data);
            
            for(var key in data){
                this.fetchedArr.push({label:key,value:key});
            }
            console.log('fetchedArr=',this.fetchedArr);
         }
         else if(error){
            console.log('error='+error);
         }
      }

       get options(){
        return this.fetchedArr;
       }


     HandleProductQuantityInput(event){
        debugger;
        let name = event.currentTarget.dataset.id;
        let value = event.target.value;

        if(name=='Quantity'){
            this.QuantityValue = value;
        }else{
            this.ProductValue = value;
        }


        this.Amount = this.originalPrice * this.QuantityValue;
        this.HandleButtonDisable = this.ProductValue==undefined || this.QuantityValue==undefined;

    //    if((this.ProductValue!=undefined && this.QuantityValue!=undefined)){
    //       this.HandleButtonDisable=false;
    //    }
    }

   


    @track FullLoanTenureValue;
    @track FullLoanNBFCPartnervalue;


    @track tenureList=[];
       @track tenurevalue=[];

       HandleFullLoanInputNBFCPartner(event){
        debugger;
        let name = event.target.name;
        let value = event.target.value;

        if(this.FullLoanNBFCPartnervalue!=value){
            this.FullLoanTenureValue='';
            this.FullLoanNBFCPartnervalue=value;
        }
           // this.FullLoanNBFCPartnervalue=value;

             this.tenureList=this.nbfcCSList[value];
             console.log('tenureList='+this.tenureList);

             let arr=[];
             this.tenureList.forEach(element => {
             debugger;
                         
             arr.push({label:element,value:element});
              });
              this.tenurevalue=arr;
              console.log('tenurevalue=',this.tenurevalue);
                  
    }

    get TenureOptions(){
        return this.tenurevalue;
     }

     @track priceIncludingGst;

     HandleFullLoanInput(event){
        debugger;
       this.FullLoanTenureValue = parseInt(event.detail.value);
       console.log('event.c/bankDetails=',event.detail.value);
       console.log('FullLoanNBFCPartnervalue',this.FullLoanNBFCPartnervalue)

       ShowPriceIncludingGST({NbfcValue:this.FullLoanNBFCPartnervalue,tenure:this.FullLoanTenureValue,originalAmount:this.originalPrice})
        .then(result=>{  
           this.priceIncludingGst=result;
           console.log('priceIncludingGst=',this.priceIncludingGst); 
        })
        .catch(error=>{
             console.log('error',error);
        })
        
       if((this.FullLoanTenureValue!=undefined  && this.FullLoanNBFCPartnervalue!=undefined)){
             this.DisableSave=false;
             }

             
   }




//     @track priceIncludingGst=0;
//     HandleFullLoanInput(event){
//         debugger;
//         let name = event.target.name;
//         let value = event.target.value;

//         if(name=='Tenure'){
//             this.FullLoanTenureValue='';
//         }
//        else if(name=='NBFCPartner'){
//            this.FullLoanNBFCPartnervalue=value;
//            let interestRate = this.nbfcCSList.find(item=>item.Name==value).Interest_Rate__c;
//            let GSTRate = this.nbfcCSList.find(item=>item.Name==value).GST_on_Subvention__c;
//            let ProcessingFee = this.nbfcCSList.find(item=>item.Name==value).Processing_Fee__c;
//            let Tenure = this.nbfcCSList.find(item=>item.Name==value).Tenure__c;
//            console.log('interestRate----',interestRate);
//            console.log('GSTRate----',GSTRate);
//            console.log('ProcessingFee----',ProcessingFee);
//            console.log('Tenure----',Tenure);
//            this.FullLoanTenureValue=Tenure;
//            if(ProcessingFee!=0 ){
//             var basePlusProcessing = this.originalPrice + ProcessingFee ;
//                 var basePlusProcessingPlusInter = basePlusProcessing + basePlusProcessing*(interestRate/100);
//                 var finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter*(GSTRate/100);

//                 this.Amount = finalWithGST;
//                  //this.loanAmount=(this.Amount*this.QuantityValue)-this.PartialLoanUpfrontpaymentvalue;
            
            
//            }
//            else{
//             var basePlusInter = this.originalPrice + this.originalPrice*(interestRate/100) ;
//             var finalWithGST= basePlusInter + basePlusInter*(GSTRate/100)
//             this.Amount = finalWithGST;
//            }

//            if(this.Amount!=this.originalPrice){
//             this.priceIncludingGst=(this.Amount).toFixed(2);
//            }
//        }


//      if((this.FullLoanTenureValue!=undefined  && this.FullLoanNBFCPartnervalue!=undefined)){
//           this.DisableSave=false;
//    }
//   }

//   get options(){
//     return this.fetchedArr;
//    }

@track ProcessingFees;
@track GstValue;

HandlePartialLoanInputNBFCPartner(event){
    debugger;
    let name = event.target.name;
    let value = event.target.value;

    if(this.PartialLoanNBFCPartnervalue!=value){
        this.PartialLoanTenureValue='';
        this.PartialLoanNBFCPartnervalue=value;
    }
        this.PartialLoanNBFCPartnervalue=value;

         this.tenureList=this.nbfcCSList[value];
         console.log('tenureList='+this.tenureList);

         let arr=[];
         this.tenureList.forEach(element => {
         debugger;
                     
         arr.push({label:element,value:element});
          });
          this.tenurevalue=arr;
          console.log('tenurevalue=',this.tenurevalue);

}
     
    get PartialTenureoptions(){
        return this.tenurevalue;
    }

    HandlePartialLoanInput(event){
        debugger;
        let value = parseInt(event.detail.value);

        if(this.PartialLoanTenureValue!=value){

            this.PartialLoanUpfrontpaymentvalue=0;
            this.loanAmount='';
            this.PartialLoanTenureValue=parseInt(value);
        }
        ShowPriceIncludingGST({NbfcValue:this.PartialLoanNBFCPartnervalue,tenure:this.PartialLoanTenureValue,originalAmount:this.originalPrice})
        .then(result=>{
             
           this.priceIncludingGst=result;
           console.log('priceIncludingGst=',this.priceIncludingGst);
        })
        .catch(error=>{
             console.log('error',error);
        })

    }

    HandlePartialLoanInputUpfront(event){

        let value=event.detail.value;
        this.PartialLoanUpfrontpaymentvalue=value;

        this.loanAmount=this.priceIncludingGst-this.PartialLoanUpfrontpaymentvalue;

        if((this.PartialLoanTenureValue!=undefined  && this.PartialLoanNBFCPartnervalue!=undefined && this.PartialLoanUpfrontpaymentvalue!=undefined)){
            this.DisableNext=false;
              } 
    }


   @track PartialLoanTenureValue;
   @track PartialLoanNBFCPartnervalue;
   @track PartialLoanUpfrontpaymentvalue;

//    HandlePartialLoanInput(event){
//     debugger;
//     let name = event.target.name;
//     let value = event.target.value;

//     if(name=='Tenure'){
//         this.PartialLoanTenureValue=' ';
//     }
//    else if(name=='NBFCPartner'){
//        this.PartialLoanNBFCPartnervalue=value;
//        let interestRate = this.nbfcCSList.find(item=>item.Name==value).Interest_Rate__c;
//        let GSTRate = this.nbfcCSList.find(item=>item.Name==value).GST_on_Subvention__c;
//        let ProcessingFee = this.nbfcCSList.find(item=>item.Name==value).Processing_Fee__c;
//        let Tenure = this.nbfcCSList.find(item=>item.Name==value).Tenure__c;
//        console.log('interestRate----',interestRate);
//        console.log('GSTRate----',GSTRate);
//        console.log('ProcessingFee----',ProcessingFee);
//        console.log('Tenure----',Tenure);
//        this.ProcessingFees=ProcessingFee;
//        this.GstValue=GSTRate;
//        this.PartialLoanTenureValue=Tenure;
//        if(ProcessingFee!=0){
            
//             var basePlusProcessing = this.originalPrice + ProcessingFee ;
//             var basePlusProcessingPlusInter = basePlusProcessing + basePlusProcessing*(interestRate/100);
//             var finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter*(GSTRate/100);

//             this.Amount = finalWithGST;
//              this.loanAmount=((this.Amount*this.QuantityValue)-this.PartialLoanUpfrontpaymentvalue).toFixed(2);
             
          
//        }
//        else{

//         var basePlusInter = this.originalPrice + this.originalPrice*(interestRate/100) ;
//         var finalWithGST= basePlusInter + basePlusInter*(GSTRate/100)
//         this.Amount = finalWithGST;
//         this.loanAmount=((this.Amount*this.QuantityValue)-this.PartialLoanUpfrontpaymentvalue).toFixed(2);
           
//        }

//        if(this.Amount!=this.originalPrice){
//         this.priceIncludingGst=(this.Amount).toFixed(2);
//        }
//    }
//    else if(name=='Upfrontpayment'){
//        this.PartialLoanUpfrontpaymentvalue=value;
       
//        if( this.ProcessingFees!=0){
//         this.loanAmount=((this.Amount*this.QuantityValue)-this.PartialLoanUpfrontpaymentvalue).toFixed(2);  
        
//        }
//        else{
//         this.loanAmount=((this.Amount*this.QuantityValue)-this.PartialLoanUpfrontpaymentvalue).toFixed(2);  
        
//        }
         
//    }

//    if((this.PartialLoanTenureValue!=undefined && this.PartialLoanNBFCPartnervalue!=undefined && this.PartialLoanUpfrontpaymentvalue!=undefined)){
//         this.DisableNext=false;
//    }
//   }

  @track LoanButtonName;
    HandleLoanNotNeed(event){
        this.LoanButtonName=event.target.name;
        this.ShowPaymentCard=true;
        this.ShowForm=false;

        this.ShowFormButton=false;
        this.PaymentSectionButton=true;
       
       
  
    }

    HandleLoanNeed(){
        debugger;
        this.ShowLoanOption=true;
        this.ShowForm=false;
        this.ShowFormButton=false;
        //this.ShowFullLoanOption=false;
       // this.ShowFullLoanOption=true;
        //this.FullLoanButton=true;
       
        
        if(this.Loanvalue=='100% Loan'){
            this.ShowFullLoanOption=true;
            this.FullLoanButton=true;

            // this.ShowPartialLoanOption=false;
            // this.PartialLoanButton=false;
            //this.ShowFormButton=false;
  
        }
        else if(this.Loanvalue=='Partial Loan'){
            this.ShowPartialLoanOption=true;
            this.PartialLoanButton=true;
            //  this.FullLoanButton=false;
            // this.ShowFormButton=false;
        }

  
    }

    get Loanoptions(){
        return [
            { label: '100% Loan', value: '100% Loan' },
            { label: 'Partial Loan', value: 'Partial Loan' },
        ];
    }

    HandleRadioButton(event){
        this.Loanvalue=event.detail.value;

        if(this.Loanvalue=='100% Loan'){
             this.ShowFullLoanOption=true;          
             this.FullLoanButton=true;
             this.ShowPartialLoanOption=false;
             this.PartialLoanButton=false;
        }
        else if(this.Loanvalue=='Partial Loan'){
            this.ShowPartialLoanOption=true;
            this.PartialLoanButton=true;
            this.ShowFullLoanOption=false;
            this.FullLoanButton=false;
        }
    }

    HandleNext(){
        this.ShowPaymentCard=true;
        this.ShowPartialLoanOption=false;
        this.PartialLoanButton=false;
        this.ShowLoanOption=false;
        this.PaymentSectionButton=true;
    }

    HandlePrevious(event){
        if(event.target.name=='PaymentSection'){
             this.ShowForm=true;
             this.ShowPaymentCard=false;
             this.ShowFormButton=true;
             this.PaymentSectionButton=false;

             if(this.Loanvalue=='Partial Loan'){
                this.ShowForm=false;
                this.ShowFormButton=false;
                this.ShowFullLoanOption=false;
                this.ShowPartialLoanOption=true;
                this.PartialLoanButton=true;
                //this.PartialLoanButton=true;
             }
        }
        else if(event.target.name=='FullSection'){

            this.ShowForm=true;
            this.ShowFormButton=true;
            this.ShowLoanOption=false;
            this.ShowFullLoanOption=false;
            this.FullLoanButton=false;
            
        }
        else if(event.target.name=='PartialSection'){

            this.ShowForm=true;
            this.ShowLoanOption=false;
            this.ShowFormButton=true;
            // this.ShowFullLoanOption=false;
            this.ShowPartialLoanOption=false;
            this.PartialLoanButton=false;
            
        }
     }

     LoadSpinner=false;
     HandleRazorPay(){
        debugger;
        this.LoadSpinner=true;
        this.ShowPaymentCard=false;
       if(this.LoanButtonName=='LoanNotNeed'){

        CreateOppLineItem({recordId:this.recordId,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.Amount,paymentType:'razorpay'})
           .then(result=>{

           if(result=='Success'){
               this.showToast('Success','Invoice created successfully!','success');
               this.dispatchEvent(new CloseActionScreenEvent());
           }
           else{

               this.showToast('Failed',result,'error');
           }
           
          })
           .catch(error=>{

                 this.showToast('Failed',error,'error');
                 console.log('error='+error);
          })
       }

       if(this.Loanvalue=='Partial Loan'){

        if(this.PartialLoanTenureValue!=undefined && this.PartialLoanNBFCPartnervalue!=undefined && this.PartialLoanUpfrontpaymentvalue!=undefined){
            debugger;
            OppUpdateOnPartialLoan({recordId:this.recordId,PartialTenureValue:this.PartialLoanTenureValue,partialNBFCValue:this.PartialLoanNBFCPartnervalue,PartialUpfrontValue:this.PartialLoanUpfrontpaymentvalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.priceIncludingGst,paymentType:'razorpay',LoanType:this.Loanvalue})
             .then(result=>{

                if(result=='Success'){
                    this.showToast('Success','Invoice created successfully!','success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    this.showToast('Failed',result,'error');
                }
             })
             .catch(error=>{
                console.log('error=',error);
                this.showToast('Failed',error,'error');
             })
        } 
         }
    }

    HandleCCAvenuePay(){
        this.LoadSpinner=true;
        this.ShowPaymentCard=false;
        if(this.LoanButtonName=='LoanNotNeed'){
             debugger;
             CreateOppLineItem({recordId:this.recordId,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.Amount})
            .then(result=>{

                if(result=='Success'){
                    this.showToast('Success','Invoice created successfully!','success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    this.showToast('Failed',result,'error');
                }
             })
             .catch(error=>{
                this.showToast('Failed',error,'error');
             })
        }

        if(this.Loanvalue=='Partial Loan'){

            if(this.PartialLoanTenureValue!=undefined && this.PartialLoanNBFCPartnervalue!=undefined && this.PartialLoanUpfrontpaymentvalue!=undefined){
                debugger;
                OppUpdateOnPartialLoan({recordId:this.recordId,PartialTenureValue:this.PartialLoanTenureValue,partialNBFCValue:this.PartialLoanNBFCPartnervalue,PartialUpfrontValue:this.PartialLoanUpfrontpaymentvalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.priceIncludingGst,paymentType:'razorpay',LoanType:this.Loanvalue})
                 .then(result=>{
    
                    if(result=='Success'){
                        this.showToast('Success','Invoice created successfully!','success');
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }else{
                        this.showToast('Failed',result,'error');
                    }
                 })
                 .catch(error=>{
                    console.log('error=',error);
                    this.showToast('Failed',error,'error');
                 })
            } 
             }

    }

    
    HandleSave(){
        debugger;
        OppUpdateOnFullLoan({recordId:this.recordId,FullTenureValue:this.FullLoanTenureValue,FullNBFCValue:this.FullLoanNBFCPartnervalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount: this.priceIncludingGst,LoanType:this.Loanvalue})
        .then(result=>{

            if(result=='success'){

                this.showToast('success','Invoice created successfully!','success');
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else{
                this.showToast('Failed',result,'error');
            }

        })
        .catch(error=>{
            this.showToast('Failed',error,'error');
            console.log('FullLoanerror=',error);

        })

     }
    
    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
  
}