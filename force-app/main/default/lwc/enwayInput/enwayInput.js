/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';

const LABEL_CLASS_NAME = 'enway-input__label';
const LABEL_REQUIRED_CLASS_NAME = 'enway-input__label_required';
const INPUT_CLASS_NAME = 'enway-input__input';
const INPUT_ERROR_CLASS_NAME = 'enway-input__input_error';
const INPUT_SUCCESS_CLASS_NAME = 'enway-input__input_success';

export default class EnwayInput extends LightningElement {

    @api maxLength;
    @api label = 'Label';
    @api type = 'text';
    @api inputValue = '';
    @api keyName;
    @api errorText;
    @api variant;

    @api
    showError() {
        this.error = this.errorText;
        this.inputClassName = `${INPUT_CLASS_NAME} ${INPUT_ERROR_CLASS_NAME}`;
    }

    @api
    hideError() {
        this.error = null;
        this.inputClassName = INPUT_CLASS_NAME;
    }

    @api 
    setSuccess() {
        this.error = null;
        this.inputClassName = `${INPUT_CLASS_NAME} ${INPUT_SUCCESS_CLASS_NAME}`;
    }

    @track error;
    @track labelClassName;
    @track inputClassName = INPUT_CLASS_NAME;

    connectedCallback() {
        this.labelClassName = this.variant === 'required' ? `${LABEL_CLASS_NAME} ${LABEL_REQUIRED_CLASS_NAME}` : LABEL_CLASS_NAME;
    }

    handleChange(event) {
        this.inputValue = event.target.value;
        this.dispatchEvent(new CustomEvent('change', {
            detail: this.inputValue
        }));
    }
}