import { LightningElement, api, track } from 'lwc';

const BASE_CLASS_NAME = "fc-checkbox__icon";
const ACTIVE_CLASS_NAME = "fc-checkbox__icon_active";

export default class FcCheckbox extends LightningElement {

    @track className = BASE_CLASS_NAME;
    @api active = false;
    @api label = '';

    connectedCallback(){
        this.className = this.active === true ? `${BASE_CLASS_NAME} ${ACTIVE_CLASS_NAME}` : BASE_CLASS_NAME;
    }

    renderedCallback(){
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        this.template.querySelector('label').innerHTML = this.label;
    }

    change() {
        this.active = this.active === true ? false : true;
        this.className = this.active === true ? `${BASE_CLASS_NAME} ${ACTIVE_CLASS_NAME}` : BASE_CLASS_NAME;
        this.dispatchEvent(
            new CustomEvent('change', { detail: this.active })
        );
    }
}