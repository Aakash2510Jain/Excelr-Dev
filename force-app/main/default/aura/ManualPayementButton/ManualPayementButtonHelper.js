({
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    uploadHelper : function(component, event) {
        debugger;	
        var fileInput = component.find("fileuplod").get("v.files");
        var file = fileInput[0];
        var self = this;
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function(){
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents);
        }); 
        objFileReader.readAsDataURL(file);
    }, 
    
    uploadProcess: function(component, file, fileContents) {
        debugger;
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        debugger;
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action= component.get("c.SaveFile");
        action.setParams({
            "parentId" : component.get("v.fileParentId"),
            "fileName" : file.name,
            "base64Data" : encodeURIComponent(getchunk),
            "contentType" : file.type,
            "fileId" : attachId
        });
        action.setCallback(this, function(response){
            var State = response.getState();
            if (State === "SUCCESS") {
                var data = response.getReturnValue();
                if (data != null) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'SUCCESS',
                        message: 'Details Saved Successfully !',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getCurrentInoiceRecord : function(component,event) {
        debugger;
        var action = component.get("c.ManualpaymentcreateInvoice");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var data = response.getReturnValue();
                component.set("v.currentRecord", data);
                if(data.Invoices__r  != null ){
                    component.set("v.oppAmount",data.Invoices__r[0].Due_Amount__c);
                    component.set("v.dueAmountRemaning", data.Invoices__r[0].Due_Amount__c);
                }else{
                    component.set("v.oppAmount", data.Amount);
                    component.set("v.dueAmountRemaning", data.Amount);
                }                
            }
        });
        $A.enqueueAction(action);
    },

    getPaymentTypeRecord :function(component,event){
        debugger;
        var action = component.get("c.getAllPaymentType");

        action.setCallback(this, function(response){
            var pay = response.getState();
            if(pay === "SUCCESS"){
                var data = response.getReturnValue();
                component.set("v.paymentTypeList",data);
            }
        });
        $A.enqueueAction(action);
    },
    
})