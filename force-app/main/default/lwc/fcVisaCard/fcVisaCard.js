import { LightningElement, track, api } from 'lwc';

const CLASS_NAME = 'visa-card';
const CLASS_NAME_ACTIVE = 'visa-card_active';

export default class FcVisaCard extends LightningElement {

    @track className;

    @api name;
    @api width;
    @api heigth;
    @api active;
    @api imgName;
    url;

    @api changeState(value) {
        this.active = value;
        this.className = this.active === "active" ? `${CLASS_NAME} ${CLASS_NAME_ACTIVE}` : CLASS_NAME;
    }

    connectedCallback() {
        this.className = this.active === "active" ? `${CLASS_NAME} ${CLASS_NAME_ACTIVE}` : CLASS_NAME;
        this.url = "https://e2e-e2efleetcor.cs101.force.com/resource/1559576527000/e2e_images/" + this.imgName;
    }

    clickHandler() {
        this.active = this.active === "active" ? null : "active";
        this.className = this.active === "active" ? `${CLASS_NAME} ${CLASS_NAME_ACTIVE}` : CLASS_NAME;
        this.dispatchEvent(
            new CustomEvent('active', { detail: this.tabValue })
        );
    }
}