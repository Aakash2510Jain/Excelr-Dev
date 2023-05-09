({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getOpportunityData");
        action.setParams({
            "opportunityId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var opportunityRecordValue = response.getReturnValue().opportunityRecord;
                component.set("v.opportunityRecord", response.getReturnValue().opportunityRecord);
                if(opportunityRecordValue.Email__c == null || opportunityRecordValue.Phone__c == null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'Please Fill Phone and Email.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                component.set("v.loanAmount", response.getReturnValue().opportunityRecord.Amount);
                component.set("v.NBFCList", response.getReturnValue().NBFCPartnerList);
                component.set("v.downPaymentTypes", response.getReturnValue().downPaymentTypeList);
                component.set('v.todaysDate', new Date().toISOString().split('T')[0]);
                component.set('v.selectedDate', new Date().toISOString().split('T')[0]);
                var NBFCNames = [];
                for(var i =0;i<response.getReturnValue().NBFCPartnerList.length;i++){
                    if(!NBFCNames.includes(response.getReturnValue().NBFCPartnerList[i].NBFC_Name__c)){
                        NBFCNames.push(response.getReturnValue().NBFCPartnerList[i].NBFC_Name__c);
                    }
                }
                component.set("v.NBFCNames", NBFCNames);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Some error Occured',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);	
    },
    handleUpfrontAmount :  function(component, event, helper) {
        debugger;
        var upfrontAmount = component.get("v.upfrontAmount");
        var loanAmount = 0;
        if(upfrontAmount > component.get("v.opportunityRecord").Amount){
            alert("Down payment cannot be greater then Course Amount");
            component.set("v.upfrontAmount",0);
            component.set("v.loanAmount", component.get("v.opportunityRecord").Amount);
        }else{
            if(upfrontAmount != undefined && upfrontAmount >0 && upfrontAmount < component.get("v.opportunityRecord").Amount ){
                loanAmount = parseInt(component.get("v.opportunityRecord").Amount) - parseInt(upfrontAmount);
                component.set("v.loanAmount", loanAmount);
                component.set("v.downPaymentIsNotZero", true);
            }else{
                component.set("v.downPaymentIsNotZero", false);
                component.set("v.upfrontAmount",0);
                component.set("v.loanAmount", component.get("v.opportunityRecord").Amount);
            }
        }
    },
    handleNBFCPartnerChanged :  function(component, event, helper) {
        debugger;
        var selectedNBFC = event.getSource().get("v.value");
        var NBFCList = component.get("v.NBFCList");
        component.set("v.selectedTenure", null);
        var loanTenure = [];
        for(var i =0;i<NBFCList.length;i++){
            if(NBFCList[i].NBFC_Name__c == selectedNBFC){
                loanTenure.push(NBFCList[i].Tenure__c);
            }
        }
        loanTenure = loanTenure.sort(function (a, b) {  return a - b;  });
        
        //loanTenure = loanTenure.reverse();
        component.set("v.loanTenureList", loanTenure);
        component.set("v.selectedNBFC", selectedNBFC);
    },
    handleTenureChanged :  function(component, event, helper) {
        debugger;
        var tenureSelected = event.getSource().get("v.value");
        component.set("v.selectedTenure", tenureSelected);
    },
    handleDownPaymentChanged :  function(component, event, helper) {
        debugger;
        var downPaymentSelected = event.getSource().get("v.value");
        component.set("v.selectedDownPaymentMode", downPaymentSelected);
        if(downPaymentSelected == "RazorPay" || downPaymentSelected == "CC Avenue"){
            component.set("v.captureExpiryDate", true);
            component.set("v.captureDownPaymentAttachment", false);
        }else{
            component.set("v.captureExpiryDate", false);
            component.set("v.captureDownPaymentAttachment", true);
        }
    },
    handleLoanAttachment : function(component, event, helper) {
        debugger;
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.loanAttachmentName", fileName);
    },
    handleDownPaymentAttachment : function(component, event, helper) {
        debugger;
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.downPaymentAttachmentName", fileName);
    },
    handleExpiryDate : function(component, event, helper) {
        debugger;
        var selectedDate = event.getSource().get("v.value");
        component.set("v.selectedDate", selectedDate);
    },
    handleCancel : function(component, event, helper) {
        debugger;
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    handleSave : function(component, event, helper) {
        debugger;
        component.set("v.disableSaveButton",true);
        //create invoice
        var opportunityAmountJS = component.get("v.opportunityRecord").Amount;
        opportunityAmountJS = opportunityAmountJS.toString();
        var downPaymentJS = component.get("v.upfrontAmount");
        
        downPaymentJS = downPaymentJS.toString();
        var loanAmountJS = component.get("v.loanAmount");
        loanAmountJS = loanAmountJS.toString();
        var loanPartnerJS = component.get("v.selectedNBFC");
        if(loanPartnerJS == null || loanPartnerJS == undefined){
            alert('Select a NBFC Partner');
            component.set("v.disableSaveButton",false);
            return;
        }
        var loanTenureJS = component.get("v.selectedTenure");
        if(loanTenureJS == null || loanTenureJS == undefined){
            alert('Select Loan Tenure');
            component.set("v.disableSaveButton",false);
            return;
        }
       
        var expiryDateJS = component.get("v.selectedDate");
        expiryDateJS = expiryDateJS.toString();
        var opportunityIdFromPage = component.get("v.recordId");
        
        if(component.find("loanAttachment").get("v.files") == null || component.find("loanAttachment").get("v.files") == undefined){
            alert('Select Loan Attachment');
            component.set("v.disableSaveButton",false);
            return;
        }
        var downPaymentTypeJS = component.get("v.selectedDownPaymentMode");
        if(downPaymentJS != null && downPaymentJS != undefined && downPaymentJS != "0"){
            if(component.get("v.selectedDownPaymentMode") == null || component.get("v.selectedDownPaymentMode") == undefined || component.get("v.selectedDownPaymentMode") == "" ){
                alert('Select Down Payment Type');
                component.set("v.disableSaveButton",false);
                return;
            }else{
                if(component.get("v.selectedDownPaymentMode") != 'CC Avenue' && component.get("v.selectedDownPaymentMode") != 'RazorPay'){
                    if(component.find("downPaymentAttachment").get("v.files") == null || component.find("downPaymentAttachment").get("v.files") == undefined){
                        alert('Select Down Payment Attachment');
                        component.set("v.disableSaveButton",false);
                        return;
                    }
                }
            }
        }
        var action = component.get("c.handleLoanPayment");
        
        action.setParams({
            opportunityId : opportunityIdFromPage,
            loanPartner : loanPartnerJS,
            loanTenure : loanTenureJS,
            downPaymentType : downPaymentTypeJS,
            downPayment : downPaymentJS,
            loanAmount : loanAmountJS,
            opportunityAmount : opportunityAmountJS,
            expiryDate : expiryDateJS
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var invoiceId = response.getReturnValue();
                component.set("v.invoiceId", invoiceId);
                helper.uploadLoanAttachmentHelper(component, event);
                if(component.get("v.upfrontAmount") != undefined && component.get("v.upfrontAmount") > 0){
                    helper.uploadDownPaymentAttachmentHelper(component, event);
                }
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'success',
                    message:'Success',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Some error Occured',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        
        $A.enqueueAction(action);	
    },
    
    
    
    
    /*var upfrontAmount = component.get("v.upfrontAmount");
        if(upfrontAmount != undefined && upfrontAmount > 0){
            //handle both attachments
            uploadLoanAttachmentHelper(component, event);
            uploadDownPaymentAttachmentHelper(component, event);
            
        }else{
            // handle laon attachment
            uploadLoanAttachmentHelper(component, event);

        }
        */
    
    
})