({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    uploadLoanAttachmentHelper : function(component, event) {
        debugger;	
        var fileInput = component.find("loanAttachment").get("v.files");
        var file = fileInput[0];
        var self = this;
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.loanAttachmentName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function(){
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.LoanAttachmentUploadProcess(component, file, fileContents);
        }); 
        objFileReader.readAsDataURL(file);
    }, 
    
    LoanAttachmentUploadProcess: function(component, file, fileContents ){
        debugger;
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.LoanAttachmentUploadInChunk(component, file, fileContents, startPosition, endPosition);
    },
    
    LoanAttachmentUploadInChunk: function(component, file, fileContents, startPosition, endPosition) {
        debugger;
        var getchunk = fileContents.substring(startPosition, endPosition);
       
        var action= component.get("c.saveAttachmentUnderInvoice");
        action.setParams({
            "invoiceId" : component.get("v.invoiceId"),
            "FileName" : file.name,
            "Base64Data" : encodeURIComponent(getchunk),
            "ContentType" : file.type,
            "isLoanAttachment":"yes"
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
    uploadDownPaymentAttachmentHelper : function(component, event) {
        debugger;	
        var fileInput = component.find("downPaymentAttachment").get("v.files");
        var file = fileInput[0];
        var self = this;
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.downPaymentAttachmentName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function(){
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadDownPaymentAttachmentUploadProcess(component, file, fileContents);
        }); 
        objFileReader.readAsDataURL(file);
    }, 
    
    uploadDownPaymentAttachmentUploadProcess: function(component, file, fileContents) {
        debugger;
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.uploadDownPaymentAttachmentUploadInChunk(component, file, fileContents, startPosition, endPosition);
    },
    
    uploadDownPaymentAttachmentUploadInChunk: function(component, file, fileContents, startPosition, endPosition) {
        debugger;
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action= component.get("c.saveAttachmentUnderInvoice");
        
         action.setParams({
            "invoiceId" : component.get("v.invoiceId"),
            "FileName" : file.name,
            "Base64Data" : encodeURIComponent(getchunk),
            "ContentType" : file.type,
            "isLoanAttachment":"no"
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
    
})