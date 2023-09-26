import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import getUserData from '@salesforce/apex/ChangeOutgoingNameController.getUserData';
import changeSenderName from '@salesforce/apex/ChangeOutgoingNameController.changeSenderName';

const ERROR_TITLE = 'Error';
const ERROR_VARIANT = 'error';
const SUCCESS_TITLE = 'Success';
const SUCCESS_VARIANT = 'success';
const SUCCESS_MESSAGE = 'Your outgoing name is changed.';

export default class ChangeOutgoingName extends LightningElement {

    wiredData;

    @wire(getUserData)
    getCurrentName(result) {
        this.wiredData = result;
        const {data, error} = result;
        if (data) {
            this.currentName = data?.SenderName ? data.SenderName : data.Name
        } else if (error) {
            this.showToast(ERROR_TITLE, ERROR_VARIANT, error.message || error.body?.message);
        }
    }

    currentName;

    newName;

    isSpinner = false;

    handleNewNameChange({currentTarget}) {
        this.newName = currentTarget?.value;
    }

    handleNewNameBlur({currentTarget}) {
        this.newName = currentTarget.value?.trim();
    }

    save() {
        if (this.checkValidity()) {
            this.isSpinner = true;
            changeSenderName({
                newName: this.newName
            }).then(() => {
                this.showToast(SUCCESS_TITLE, SUCCESS_VARIANT, SUCCESS_MESSAGE);
                refreshApex(this.wiredData);
                this.newName = '';
            }).catch(e => {
                this.showToast(ERROR_TITLE, ERROR_VARIANT, e.message || e.body?.message);
            }).finally(() => {
                this.isSpinner = false;
            })
        }
    }

    checkValidity() {
        return [...this.template.querySelectorAll('lightning-input')]
        .reduce((result, item) => result && item?.reportValidity(), true);
    }

    showToast(title, variant, message, mode) {
        const event = new ShowToastEvent({
            title: title || 'Info',
            variant: variant || 'info',
            message: message,
            mode: mode || 'dismissable'
        });
        this.dispatchEvent(event);
    }

}