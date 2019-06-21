import { LightningElement, api, track } from 'lwc';

const CLASS_NAME = 'product-tab';
const CLASS_NAME_ACTIVE = 'product-tab_active';

export default class FcProductTab extends LightningElement {

    @track className;

    @api tabItem;
    @api tabValue;
    @api active;

    @api changeState(value) {
        this.active = value;
        this.className = this.active === "active" ? `${CLASS_NAME} ${CLASS_NAME_ACTIVE}` : CLASS_NAME;
    }

    connectedCallback() {
        this.className = this.active === "active" ? `${CLASS_NAME} ${CLASS_NAME_ACTIVE}` : CLASS_NAME;
    }

    clickHandler() {
        this.dispatchEvent(
            new CustomEvent('active', { detail: this.tabValue })
        );
    }
}