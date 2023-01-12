import { LightningElement,track, wire,api } from 'lwc';
import staticimage from '@salesforce/resourceUrl/RazorPay';
import CcStatic from '@salesforce/resourceUrl/ccAvenue';
import { CloseActionScreenEvent } from 'lightning/actions';
import ShowNbfcPartners from '@salesforce/apex/PaymentProcessOnLeadController.ShowNbfcPartners';
import InsertProduct from '@salesforce/apex/PaymentProcessOnLeadController.InsertProduct';
import LeadUpdateOnFullLoan from '@salesforce/apex/PaymentProcessOnLeadController.LeadUpdateOnFullLoan';
import leadUpdateOnPartialLoan from '@salesforce/apex/PaymentProcessOnLeadController.leadUpdateOnPartialLoan';
import ShowAmount from '@salesforce/apex/PaymentProcessOnLeadController.ShowAmount';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import PAYMENT_FIELD from '@salesforce/schema/Lead.Payment_Type__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ShowPriceIncludingGST from '@salesforce/apex/PaymentProcessOnLeadController.ShowPriceIncludingGST';
import CreateInvoice from '@salesforce/apex/PaymentProcessOnLeadController.CreateInvoice';


export default class PaymentProcessOnLead extends LightningElement {
    // RazorPayImage=staticimage;
    // CcAvenueImage=CcStatic;

   //Here Getting The Payment Types
    Picklistvalue=[];
    @wire(getObjectInfo, {objectApiName:LEAD_OBJECT})
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

        if(this.PaymentType=='razorpay'){
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


    @api recordId;
    @track loanAmount;

    @track ShowForm =true;
   
    ShowPaymentCard=false;
    ShowLoanOption=false;
    @track Loanvalue='';
    ShowFullLoanOption=false;
    ShowPartialLoanOption=false;

    HandleButtonDisable=true;
    @track ProductValue;
    @track QuantityValue=1;

    @track FullLoanTenureValue='';
    @track FullLoanNBFCPartnervalue;
    @track DisableSave=true;

    @track PartialLoanTenureValue;
    @track PartialLoanNBFCPartnervalue;
    @track PartialLoanUpfrontpaymentvalue;

    @track  DisableNext=true;

    @track ShowFormButton=true;
    @track  PaymentSectionButton=false;
    @track FullLoanButton=false;
    @track  PartialLoanButton=false;

    @track originalPrice;
    @track  Amount;
    //Here Getting Product Original Value
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
           console.log('originalPrice='+this.originalPrice);
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

       }

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

     @track priceIncludingGst

     //Passing The Value To Apex To Get The Prive Including GST
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

    

    HandleSave(){
        debugger;
        LeadUpdateOnFullLoan({recordId:this.recordId,FullTenureValue:this.FullLoanTenureValue,FullNBFCValue:this.FullLoanNBFCPartnervalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount: this.priceIncludingGst})
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
          
    
    


    // priceIncludingGst=0;
    // HandleFullLoanInput(event){
    //       debugger;
    //       let name = event.target.name;
    //       let value = event.target.value;

    //     if(name=='Tenure'){
    //         this.FullLoanTenureValue='';
    //     }
    //    else if(name=='NBFCPartner'){
    //        this.FullLoanNBFCPartnervalue=value;
    //        let interestRate = this.nbfcCSList.find(item=>item.Name==value).Interest_Rate__c;
    //        let GSTRate = this.nbfcCSList.find(item=>item.Name==value).GST_on_Subvention__c;
    //        let ProcessingFee = this.nbfcCSList.find(item=>item.Name==value).Processing_Fee__c;
    //        let Tenure = this.nbfcCSList.find(item=>item.Name==value).Tenure__c;
    //        console.log('interestRate----',interestRate);
    //        console.log('GSTRate----',GSTRate);
    //        console.log('ProcessingFee----',ProcessingFee);
    //        console.log('Tenure----',Tenure);
    //        this.FullLoanTenureValue=Tenure;
    //        if(ProcessingFee!=0 ){
    //         var basePlusProcessing = this.originalPrice + ProcessingFee ;
    //             var basePlusProcessingPlusInter = basePlusProcessing + basePlusProcessing*(interestRate/100);
    //             var finalWithGST = basePlusProcessingPlusInter + basePlusProcessingPlusInter*(GSTRate/100);

    //             this.Amount = finalWithGST;
    //              //this.loanAmount=(this.Amount*this.QuantityValue)-this.PartialLoanUpfrontpaymentvalue;
            
            
    //        }
    //        else{
    //         var basePlusInter = this.originalPrice + this.originalPrice*(interestRate/100) ;
    //         var finalWithGST= basePlusInter + basePlusInter*(GSTRate/100)
    //         this.Amount = finalWithGST;
    //        }

    //        if(this.Amount!=this.originalPrice){
    //         this.priceIncludingGst=(this.Amount).toFixed(2);
    //        }
    //    }

    //    if((this.FullLoanTenureValue!=undefined  && this.FullLoanNBFCPartnervalue!=undefined)){
    //     this.DisableSave=false;
    //  }
    // }

   @track ProcessingFees;
    @track GstValue
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
    //  }
    

   
    LoanButtonName;
    HandleLoanNotNeed(event){
        debugger;
        this.LoanButtonName=event.target.name;
        this.ShowPaymentCard=true;
        this.ShowForm=false;

        this.ShowFormButton=false;
        this.PaymentSectionButton=true;
       
       
  
    }

    HandleLoanNeed(event){
        this.LoanButtonName=event.target.name;
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
    LoadSpinner=false;


    
    HandleRazorPay(){
         debugger;
         this.LoadSpinner=true;
         this.ShowPaymentCard=false;
        if(this.LoanButtonName=='LoanNotNeed'){
            InsertProduct({recordId:this.recordId,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.Amount,paymentType:'razorpay'})
            .then(result=>{
            if(result=='Success'){
                this.LoadSpinner=false;
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
        

       //Works when You Choose  Partial Loan
       if(this.Loanvalue=='Partial Loan'){

        if(this.PartialLoanTenureValue!=undefined && this.PartialLoanNBFCPartnervalue!=undefined && this.PartialLoanUpfrontpaymentvalue!=undefined){
            debugger;
            leadUpdateOnPartialLoan({recordId:this.recordId,PartialTenureValue:this.PartialLoanTenureValue,partialNBFCValue:this.PartialLoanNBFCPartnervalue,PartialUpfrontValue:this.PartialLoanUpfrontpaymentvalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.priceIncludingGst,paymentType:'razorpay'})
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
            InsertProduct({recordId:this.recordId,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.Amount})
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
        

       //Works when You Choose  Partial Loan
       if(this.Loanvalue=='Partial Loan'){
            debugger;
        if(this.PartialLoanTenureValue!=undefined && this.PartialLoanNBFCPartnervalue!=undefined && this.PartialLoanUpfrontpaymentvalue!=undefined){
            leadUpdateOnPartialLoan({recordId:this.recordId,PartialTenureValue:this.PartialLoanTenureValue,partialNBFCValue:this.PartialLoanNBFCPartnervalue,PartialUpfrontValue:this.PartialLoanUpfrontpaymentvalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount:this.priceIncludingGst})
             .then(result=>{

                if(result=='Success'){
                    this.showToast('Success','Invoice created successfully!','success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    this.showToast('Failed',result,'error');
                }
             })
             .catch(error=>{
                console.log('error='+error);
                this.showToast('Failed',error,'error');
             })
        }
         }
    }

    

  

    //  HandleSave(){
    //     debugger;
    //     LeadUpdateOnFullLoan({recordId:this.recordId,FullTenureValue:this.FullLoanTenureValue,FullNBFCValue:this.FullLoanNBFCPartnervalue,Quantity:this.QuantityValue,ProductName:this.ProductValue,Amount: this.priceIncludingGst})
    //     .then(result=>{

    //         if(result=='success'){

    //             this.showToast('success','Invoice created successfully!','success');
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         }
    //         else{
    //             this.showToast('Failed',result,'error');
    //         }

    //     })
    //     .catch(error=>{
    //         this.showToast('Failed',error,'error');
    //         console.log('FullLoanerror=',error);

    //     })

    //  }

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

     showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}