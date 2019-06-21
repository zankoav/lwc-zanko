import { LightningElement, api, track } from 'lwc';

const CLASS_NAME = 'fc-checkbox-ios__action-view-port';
const CLASS_NAME_ACTIVE = 'fc-checkbox-ios__action-view-port_active';
const ACTIVE = 'active';

export default class FcCheckBoxIos extends LightningElement {
    @api title;
    @api subtitle;
    @api active = false;
    @api titleOn;
    @api titleOff;
    @api description;
    @api helpText;

    @track className;

    clickHandler() {
        this.active = this.active === ACTIVE ? false : ACTIVE;
        this.updateState();
        this.dispatchEvent(
            new CustomEvent('change', { detail: this.active })
        );
    }

    renderedCallback(){
        this.updateState();
    }

    updateState(){
        this.className = this.active === ACTIVE ? `${CLASS_NAME} ${CLASS_NAME_ACTIVE}` : CLASS_NAME;
    }
}