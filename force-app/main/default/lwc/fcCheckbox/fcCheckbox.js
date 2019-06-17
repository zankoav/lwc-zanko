import { LightningElement, api, track } from 'lwc';

const BASE_CLASS_NAME = "fc-checkbox__icon";
const ACTIVE_CLASS_NAME = "fc-checkbox__icon_active";

export default class FcCheckbox extends LightningElement {

    @track className = BASE_CLASS_NAME;
    @api active = false;

    connectedCallback(){
        this.className = this.active ? `${BASE_CLASS_NAME} ${ACTIVE_CLASS_NAME}` : BASE_CLASS_NAME;
    }

    change() {
        this.active = !this.active;
        this.className = this.active ? `${BASE_CLASS_NAME} ${ACTIVE_CLASS_NAME}` : BASE_CLASS_NAME;
        this.dispatchEvent(
            new CustomEvent('change', { detail: this.status })
        );
    }
}