import { LightningElement, api, track } from 'lwc';

const BASE_CLASS_NAME = "fc-checkbox__icon";
const ACTIVE_CLASS_NAME = "fc-checkbox__icon_active";

export default class FcCheckbox extends LightningElement {
    @track status = false;
    @track className = BASE_CLASS_NAME;
    @api 
    set active(value){
        this.status = !this.status;
        this.className = this.status ? `${BASE_CLASS_NAME} ${ACTIVE_CLASS_NAME}` : BASE_CLASS_NAME;
    }
    get active(){
        return this.status;
    }

    change(){
        this.active = !this.active;
        this.dispatchEvent(
            new CustomEvent('change', { detail: this.status })
        );
    }
}