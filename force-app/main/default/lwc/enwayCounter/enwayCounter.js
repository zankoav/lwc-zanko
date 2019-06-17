import { LightningElement, api, track } from 'lwc';

const LABEL_CLASS_NAME = 'enway-counter__label';
const LABEL_REQUIRED_CLASS_NAME = 'enway-counter__label_required';
const INPUT_CLASS_NAME = 'enway-counter__input';

export default class EnwayCounter extends LightningElement {

    @api label = '';
    @api inputValue = '1';
    @api maxValue = 50;
    @api keyName;
    @api variant;
    @track labelClassName;
    @track inputClassName = INPUT_CLASS_NAME;

    connectedCallback() {
        this.labelClassName = this.variant === 'required' ? `${LABEL_CLASS_NAME} ${LABEL_REQUIRED_CLASS_NAME}` : LABEL_CLASS_NAME;
    }

    handleEvent(event) {
        if (event.currentTarget.hasAttribute("data-plus")) {
            const value = +this.inputValue + +event.currentTarget.getAttribute("data-plus");
            this.checkValueRange(value);
        } else if (Number.isInteger(+event.target.value)) {
            this.checkValueRange(event.target.value);
        } else {
            this.inputValue = this.inputValue;
        }

        this.dispatchEvent(new CustomEvent('change', { detail: this.inputValue }));
    }

    handlerBlur(){
        this.inputValue = this.inputValue ? this.inputValue : "1";
    }

    checkValueRange(value) {
        if (value < 1 && value !== '') { value = 1; }
        if (value > this.maxValue) { value = this.maxValue; }
        this.inputValue = value;
    }

}