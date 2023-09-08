import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductDetails from '@salesforce/apex/UpdateCourseAndProductPrice.getProductDetails';
import updateProductPrice from '@salesforce/apex/UpdateCourseAndProductPrice.updateProductPrice';

export default class UpdateCourseAndProductPrice extends LightningElement {
    @api recId;
    @track productData;
    showModal = true; 
    @track unitPrice = '';

    renderedCallback() {
        if (this.showModal) {
            this.loadProductDetails();
            this.showModal = false; // Hide modal after loading data
        }
    }

    @wire(getProductDetails, { productId: '$recId' })
    wiredProduct({ error, data }) {
        if (data) {
            this.productData = data;
        } else if (error) {
            console.error(error);
        }
    }

    loadProductDetails() {
        getProductDetails({ productId: this.recId })
            .then(result => {
                this.productData = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleUnitPriceChange(event) {
        debugger;
        this.unitPrice = event.target.value;
    }

        handleCancel() {
        this.showModal = false;
    }

    handleProductSaveClick() {
        const newUnitPrice = parseFloat(this.unitPrice);

        if (isNaN(newUnitPrice) || newUnitPrice === null || newUnitPrice === 0) {
            this.showToast('Error', 'Unit price must be a non-zero number.', 'error');
            return;
        }

        updateProductPrice({ pricebookEntryId: this.productData.pricebookEntryId, newUnitPrice: this.unitPrice, prodId : this.recId })
            .then(result => {
                if (result === 'Success') {
                    this.showToast('Success', 'Product unit price updated successfully.', 'success');
                    window.location.reload();

                    // if (this.productData.type === 'Combo') {
                    //     doProductPriceUpdate({ productId: this.productData.lmsExternalId, newUnitPrice: this.unitPrice })
                    //         .then(() => {
                    //             window.location.reload();
                    //         })
                    //         .catch(error => {
                    //             console.error(error);
                    //             this.showToast('Error', 'An error occurred while updating product price.', 'error');
                    //         });
                    // } else if (this.productData.type === 'Single') {
                    //     doCoursePriceUpdate({ courseId: this.productData.lmsExternalId, newUnitPrice: this.unitPrice })
                    //         .then(() => {
                    //             window.location.reload();
                    //         })
                    //         .catch(error => {
                    //             console.error(error);
                    //             this.showToast('Error', 'An error occurred while updating course price.', 'error');
                    //         });
                    // }
                } else {
                    this.showToast('Error', 'An error occurred while updating unit price.', 'error');
                }
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'An error occurred while updating unit price.', 'error');
            });
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }


  
}